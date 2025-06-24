import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 檔案管理服務 - 增強版
class FileManagerService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 智能檔案上傳
  static Future<String> smartUpload({
    required File file,
    required String category, // 'profile', 'chat', 'verification'
    Function(double)? onProgress,
    bool compress = true,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      // 檢查檔案大小
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) { // 50MB 限制
        throw Exception('檔案太大，請選擇小於 50MB 的檔案');
      }

      // 生成唯一檔案名
      final extension = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      
      // 壓縮圖片
      File uploadFile = file;
      if (compress && _isImage(extension)) {
        uploadFile = await _compressImage(file);
      }

      // 創建存儲路徑
      final storagePath = 'users/${currentUser.uid}/$category/$fileName';
      final storageRef = _storage.ref().child(storagePath);

      // 上傳檔案
      final uploadTask = storageRef.putFile(uploadFile);
      
      // 監聽進度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // 等待完成
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 記錄檔案信息
      await _recordFileInfo(
        userId: currentUser.uid,
        fileName: fileName,
        originalPath: file.path,
        downloadUrl: downloadUrl,
        category: category,
        size: fileSize,
      );

      // 清理臨時檔案
      if (uploadFile.path != file.path) {
        await uploadFile.delete();
      }

      print('✅ 檔案上傳成功: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ 檔案上傳失敗: $e');
      throw Exception('檔案上傳失敗: $e');
    }
  }

  /// 批量上傳檔案
  static Future<List<String>> batchUpload({
    required List<File> files,
    required String category,
    Function(int, double)? onProgress,
  }) async {
    final urls = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      final url = await smartUpload(
        file: files[i],
        category: category,
        onProgress: (progress) => onProgress?.call(i, progress),
      );
      urls.add(url);
    }
    
    return urls;
  }

  /// 下載檔案到本地
  static Future<String> downloadFile(String url, {String? fileName}) async {
    try {
      final ref = _storage.refFromURL(url);
      final localFileName = fileName ?? path.basename(ref.fullPath);
      
      // 獲取下載目錄
      final appDir = await getApplicationDocumentsDirectory();
      final localFile = File(path.join(appDir.path, 'downloads', localFileName));
      
      // 確保目錄存在
      await localFile.parent.create(recursive: true);
      
      // 下載檔案
      await ref.writeToFile(localFile);
      
      print('✅ 檔案下載成功: ${localFile.path}');
      return localFile.path;
    } catch (e) {
      print('❌ 檔案下載失敗: $e');
      throw Exception('檔案下載失敗: $e');
    }
  }

  /// 刪除檔案
  static Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      
      // 刪除記錄
      await _deleteFileRecord(url);
      
      print('✅ 檔案刪除成功: $url');
    } catch (e) {
      print('❌ 檔案刪除失敗: $e');
      throw Exception('檔案刪除失敗: $e');
    }
  }

  /// 獲取用戶檔案列表
  static Future<List<Map<String, dynamic>>> getUserFiles(String category) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final query = await _firestore
          .collection('user_files')
          .where('userId', isEqualTo: currentUser.uid)
          .where('category', isEqualTo: category)
          .orderBy('uploadedAt', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ 獲取檔案列表失敗: $e');
      return [];
    }
  }

  /// 清理舊檔案
  static Future<void> cleanupOldFiles({Duration maxAge = const Duration(days: 30)}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final cutoffDate = DateTime.now().subtract(maxAge);
      
      final query = await _firestore
          .collection('user_files')
          .where('userId', isEqualTo: currentUser.uid)
          .where('uploadedAt', isLessThan: cutoffDate)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final url = data['downloadUrl'] as String?;
        
        if (url != null) {
          await deleteFile(url);
        }
      }

      print('✅ 清理完成，清理了 ${query.docs.length} 個舊檔案');
    } catch (e) {
      print('❌ 清理舊檔案失敗: $e');
    }
  }

  /// 獲取存儲使用統計
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {};

      final query = await _firestore
          .collection('user_files')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      int totalSize = 0;
      final categoryStats = <String, int>{};

      for (final doc in query.docs) {
        final data = doc.data();
        final size = data['size'] as int? ?? 0;
        final category = data['category'] as String? ?? 'unknown';
        
        totalSize += size;
        categoryStats[category] = (categoryStats[category] ?? 0) + size;
      }

      return {
        'totalFiles': query.docs.length,
        'totalSize': totalSize,
        'categoryStats': categoryStats,
      };
    } catch (e) {
      print('❌ 獲取存儲統計失敗: $e');
      return {};
    }
  }

  /// 檢查是否為圖片檔案
  static bool _isImage(String extension) {
    const imageExts = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExts.contains(extension.toLowerCase());
  }

  /// 壓縮圖片
  static Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('無法解析圖片');
      }

      // 計算新尺寸
      int newWidth = image.width;
      int newHeight = image.height;
      
      // 限制最大尺寸為 1920x1920
      if (newWidth > 1920 || newHeight > 1920) {
        if (newWidth > newHeight) {
          newHeight = (newHeight * 1920 / newWidth).round();
          newWidth = 1920;
        } else {
          newWidth = (newWidth * 1920 / newHeight).round();
          newHeight = 1920;
        }
      }

      // 調整圖片大小
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
      );

      // 壓縮圖片
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      // 保存到臨時檔案
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        path.join(tempDir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg')
      );
      
      await compressedFile.writeAsBytes(compressedBytes);
      
      print('📦 圖片壓縮完成: ${imageFile.lengthSync()} -> ${compressedFile.lengthSync()} bytes');
      return compressedFile;
    } catch (e) {
      print('❌ 圖片壓縮失敗: $e');
      return imageFile; // 回退到原始檔案
    }
  }

  /// 記錄檔案信息
  static Future<void> _recordFileInfo({
    required String userId,
    required String fileName,
    required String originalPath,
    required String downloadUrl,
    required String category,
    required int size,
  }) async {
    try {
      await _firestore.collection('user_files').add({
        'userId': userId,
        'fileName': fileName,
        'originalPath': originalPath,
        'downloadUrl': downloadUrl,
        'category': category,
        'size': size,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ 記錄檔案信息失敗: $e');
    }
  }

  /// 刪除檔案記錄
  static Future<void> _deleteFileRecord(String downloadUrl) async {
    try {
      final query = await _firestore
          .collection('user_files')
          .where('downloadUrl', isEqualTo: downloadUrl)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('❌ 刪除檔案記錄失敗: $e');
    }
  }
}

/// 檔案管理服務提供者
final fileManagerServiceProvider = Provider<FileManagerService>((ref) {
  return FileManagerService();
}); 