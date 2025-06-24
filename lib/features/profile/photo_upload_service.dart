import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 照片上傳服務提供者
final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService();
});

// 照片數據模型
class PhotoData {
  final String id;
  final String url;
  final String localPath;
  final bool isMain;
  final DateTime uploadedAt;

  PhotoData({
    required this.id,
    required this.url,
    required this.localPath,
    required this.isMain,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'isMain': isMain,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory PhotoData.fromMap(Map<String, dynamic> map) {
    return PhotoData(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      localPath: map['localPath'] ?? '',
      isMain: map['isMain'] ?? false,
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}

class PhotoUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final ImagePicker _imagePicker = ImagePicker();

  /// 上傳個人檔案照片
  static Future<String> uploadProfilePhoto({
    required XFile imageFile,
    required int photoIndex,
    Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      // 壓縮圖片
      final compressedFile = await _compressImage(imageFile);
      
      // 創建存儲路徑
      final fileName = 'profile_photo_${photoIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage
          .ref()
          .child('users')
          .child(currentUser.uid)
          .child('photos')
          .child(fileName);

      // 上傳文件
      final uploadTask = storageRef.putFile(compressedFile);
      
      // 監聽上傳進度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // 等待上傳完成
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 更新用戶檔案
      await _updateUserPhotos(downloadUrl, photoIndex);

      // 清理臨時文件
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('上傳照片失敗: $e');
    }
  }

  /// 上傳聊天圖片
  static Future<String> uploadChatImage({
    required XFile imageFile,
    required String chatId,
    Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      // 壓縮圖片
      final compressedFile = await _compressImage(imageFile);
      
      // 創建存儲路徑
      final fileName = 'chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage
          .ref()
          .child('chats')
          .child(chatId)
          .child('images')
          .child(fileName);

      // 上傳文件
      final uploadTask = storageRef.putFile(compressedFile);
      
      // 監聽上傳進度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // 等待上傳完成
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 清理臨時文件
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('上傳聊天圖片失敗: $e');
    }
  }

  /// 從相機拍照
  static Future<XFile?> takePhoto() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
    } catch (e) {
      throw Exception('拍照失敗: $e');
    }
  }

  /// 從相冊選擇照片
  static Future<XFile?> pickFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
    } catch (e) {
      throw Exception('選擇照片失敗: $e');
    }
  }

  /// 選擇多張照片
  static Future<List<XFile>> pickMultipleImages({int maxImages = 6}) async {
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      // 限制選擇數量
      if (images.length > maxImages) {
        return images.take(maxImages).toList();
      }
      
      return images;
    } catch (e) {
      throw Exception('選擇多張照片失敗: $e');
    }
  }

  /// 刪除照片
  static Future<void> deletePhoto({
    required String photoUrl,
    required int photoIndex,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      // 從 Storage 刪除文件
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();

      // 從用戶檔案中移除照片 URL
      await _removePhotoFromProfile(photoUrl, photoIndex);
    } catch (e) {
      throw Exception('刪除照片失敗: $e');
    }
  }

  /// 重新排序照片
  static Future<void> reorderPhotos(List<String> photoUrls) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'photos': photoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('重新排序照片失敗: $e');
    }
  }

  /// 獲取用戶所有照片
  static Future<List<String>> getUserPhotos() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['photos'] ?? []);
      }

      return [];
    } catch (e) {
      throw Exception('獲取用戶照片失敗: $e');
    }
  }

  /// 驗證照片（AI 照片驗證的基礎）
  static Future<PhotoVerificationResult> verifyPhoto(XFile imageFile) async {
    try {
      // 基本驗證
      final file = File(imageFile.path);
      final fileSize = await file.length();
      
      // 檢查文件大小（最大 10MB）
      if (fileSize > 10 * 1024 * 1024) {
        return PhotoVerificationResult(
          isValid: false,
          reason: '照片文件過大，請選擇小於 10MB 的照片',
        );
      }

      // 檢查圖片格式
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return PhotoVerificationResult(
          isValid: false,
          reason: '無效的圖片格式',
        );
      }

      // 檢查圖片尺寸
      if (image.width < 200 || image.height < 200) {
        return PhotoVerificationResult(
          isValid: false,
          reason: '照片尺寸太小，請選擇至少 200x200 像素的照片',
        );
      }

      // 檢查圖片比例
      final aspectRatio = image.width / image.height;
      if (aspectRatio < 0.5 || aspectRatio > 2.0) {
        return PhotoVerificationResult(
          isValid: false,
          reason: '照片比例不合適，請選擇比例適中的照片',
        );
      }

      // TODO: 集成 AI 照片驗證服務
      // - 檢測是否為真人照片
      // - 檢測是否包含不當內容
      // - 檢測是否為重複照片

      return PhotoVerificationResult(
        isValid: true,
        reason: '照片驗證通過',
        confidence: 0.95,
      );
    } catch (e) {
      return PhotoVerificationResult(
        isValid: false,
        reason: '照片驗證失敗: $e',
      );
    }
  }

  /// 生成照片縮略圖
  static Future<File> generateThumbnail(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('無法解析圖片');
      }

      // 生成 300x300 的縮略圖
      final thumbnail = img.copyResize(image, width: 300, height: 300);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

      // 保存縮略圖
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File(path.join(
        tempDir.path,
        'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));
      
      await thumbnailFile.writeAsBytes(thumbnailBytes);
      return thumbnailFile;
    } catch (e) {
      throw Exception('生成縮略圖失敗: $e');
    }
  }

  /// 批量上傳照片
  static Future<List<String>> uploadMultiplePhotos({
    required List<XFile> imageFiles,
    Function(int, double)? onProgress,
  }) async {
    try {
      final uploadedUrls = <String>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        
        // 驗證照片
        final verification = await verifyPhoto(imageFile);
        if (!verification.isValid) {
          throw Exception('照片 ${i + 1} 驗證失敗: ${verification.reason}');
        }

        // 上傳照片
        final url = await uploadProfilePhoto(
          imageFile: imageFile,
          photoIndex: i,
          onProgress: (progress) {
            onProgress?.call(i, progress);
          },
        );
        
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('批量上傳照片失敗: $e');
    }
  }

  /// 壓縮圖片
  static Future<File> _compressImage(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('無法解析圖片');
      }

      // 計算新尺寸（最大 1920x1920）
      int newWidth = image.width;
      int newHeight = image.height;
      
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

      // 保存壓縮後的圖片
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      throw Exception('壓縮圖片失敗: $e');
    }
  }

  /// 更新用戶照片列表
  static Future<void> _updateUserPhotos(String photoUrl, int photoIndex) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final photos = List<String>.from(data['photos'] ?? []);
        
        // 確保列表有足夠的空間
        while (photos.length <= photoIndex) {
          photos.add('');
        }
        
        // 更新指定位置的照片
        photos[photoIndex] = photoUrl;
        
        transaction.update(userRef, {
          'photos': photos,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 創建新的照片列表
        final photos = List<String>.filled(6, '');
        photos[photoIndex] = photoUrl;
        
        transaction.set(userRef, {
          'photos': photos,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  /// 從個人檔案中移除照片
  static Future<void> _removePhotoFromProfile(String photoUrl, int photoIndex) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final photos = List<String>.from(data['photos'] ?? []);
        
        if (photoIndex < photos.length) {
          photos[photoIndex] = '';
        }
        
        transaction.update(userRef, {
          'photos': photos,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

/// 照片驗證結果
class PhotoVerificationResult {
  final bool isValid;
  final String reason;
  final double? confidence;
  final Map<String, dynamic>? metadata;

  PhotoVerificationResult({
    required this.isValid,
    required this.reason,
    this.confidence,
    this.metadata,
  });
}

/// 照片上傳進度
class PhotoUploadProgress {
  final int photoIndex;
  final double progress;
  final String? error;

  PhotoUploadProgress({
    required this.photoIndex,
    required this.progress,
    this.error,
  });
}

/// 照片管理異常
class PhotoManagementException implements Exception {
  final String message;
  final String? code;

  PhotoManagementException(this.message, {this.code});

  @override
  String toString() => 'PhotoManagementException: $message';
} 