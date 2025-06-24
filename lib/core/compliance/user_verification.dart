import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

/// 驗證狀態枚舉
enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

/// 驗證類型枚舉
enum VerificationType {
  phone,
  email,
  identity,
  photo,
  age,
  location,
}

/// 用戶驗證信息類
class UserVerification {
  final String id;
  final String userId;
  final VerificationType type;
  final VerificationStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;
  final String? rejectionReason;

  UserVerification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.expiresAt,
    this.metadata = const {},
    this.rejectionReason,
  });

  factory UserVerification.fromMap(Map<String, dynamic> map) {
    return UserVerification(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: VerificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => VerificationType.phone,
      ),
      status: VerificationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => VerificationStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      verifiedAt: map['verifiedAt']?.toDate(),
      expiresAt: map['expiresAt']?.toDate(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
      'rejectionReason': rejectionReason,
    };
  }

  bool get isValid => status == VerificationStatus.verified && 
                     (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

/// 用戶驗證管理器
class UserVerificationManager {
  static final UserVerificationManager _instance = UserVerificationManager._internal();
  factory UserVerificationManager() => _instance;
  UserVerificationManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 發送手機驗證碼
  Future<bool> sendPhoneVerification(String phoneNumber) async {
    try {
      debugPrint('📱 發送手機驗證碼: $phoneNumber');

      final user = _auth.currentUser;
      if (user == null) return false;

      // 生成6位數驗證碼
      final verificationCode = _generateVerificationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // 保存驗證碼到數據庫
      await _firestore.collection('verifications').add({
        'userId': user.uid,
        'type': VerificationType.phone.name,
        'status': VerificationStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'metadata': {
          'phoneNumber': phoneNumber,
          'code': verificationCode, // 實際應用中應該加密
          'attempts': 0,
        },
      });

      // 實際實現中，這裡會調用 SMS 服務發送驗證碼
      debugPrint('📱 驗證碼: $verificationCode (開發模式顯示)');

      return true;
    } catch (e) {
      debugPrint('❌ 發送手機驗證碼失敗: $e');
      return false;
    }
  }

  /// 驗證手機驗證碼
  Future<bool> verifyPhoneCode(String phoneNumber, String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // 查找待驗證的記錄
      final query = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: VerificationType.phone.name)
          .where('status', isEqualTo: VerificationStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('❌ 未找到待驗證的手機記錄');
        return false;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final metadata = data['metadata'] as Map<String, dynamic>;
      final storedCode = metadata['code'] as String;
      final storedPhone = metadata['phoneNumber'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = metadata['attempts'] as int;

      // 檢查驗證碼是否過期
      if (DateTime.now().isAfter(expiresAt)) {
        await doc.reference.update({
          'status': VerificationStatus.expired.name,
        });
        debugPrint('❌ 驗證碼已過期');
        return false;
      }

      // 檢查嘗試次數
      if (attempts >= 3) {
        await doc.reference.update({
          'status': VerificationStatus.rejected.name,
          'rejectionReason': '嘗試次數過多',
        });
        debugPrint('❌ 驗證碼嘗試次數過多');
        return false;
      }

      // 檢查手機號碼和驗證碼
      if (storedPhone == phoneNumber && storedCode == code) {
        await doc.reference.update({
          'status': VerificationStatus.verified.name,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // 更新用戶資料
        await _firestore.collection('users').doc(user.uid).update({
          'phoneNumber': phoneNumber,
          'phoneVerified': true,
          'verificationLevel': FieldValue.increment(1),
        });

        debugPrint('✅ 手機驗證成功');
        return true;
      } else {
        // 增加嘗試次數
        await doc.reference.update({
          'metadata.attempts': attempts + 1,
        });
        debugPrint('❌ 驗證碼錯誤');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 驗證手機驗證碼失敗: $e');
      return false;
    }
  }

  /// 照片真實性驗證
  Future<bool> verifyPhotoAuthenticity(File photoFile) async {
    try {
      debugPrint('📸 開始照片真實性驗證');

      final user = _auth.currentUser;
      if (user == null) return false;

      // 上傳照片到 Firebase Storage
      final storageRef = _storage
          .ref()
          .child('verifications')
          .child(user.uid)
          .child('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(photoFile);
      final photoUrl = await uploadTask.ref.getDownloadURL();

      // 進行 AI 照片分析
      final analysisResult = await _analyzePhotoAuthenticity(photoFile);

      // 保存驗證記錄
      final verificationId = _firestore.collection('verifications').doc().id;
      await _firestore.collection('verifications').doc(verificationId).set({
        'id': verificationId,
        'userId': user.uid,
        'type': VerificationType.photo.name,
        'status': analysisResult.isAuthentic 
            ? VerificationStatus.verified.name 
            : VerificationStatus.rejected.name,
        'createdAt': FieldValue.serverTimestamp(),
        'verifiedAt': analysisResult.isAuthentic 
            ? FieldValue.serverTimestamp() 
            : null,
        'metadata': {
          'photoUrl': photoUrl,
          'confidenceScore': analysisResult.confidenceScore,
          'analysisDetails': analysisResult.details,
        },
        'rejectionReason': analysisResult.isAuthentic 
            ? null 
            : '照片未通過真實性檢測',
      });

      if (analysisResult.isAuthentic) {
        // 更新用戶資料
        await _firestore.collection('users').doc(user.uid).update({
          'photoVerified': true,
          'verificationLevel': FieldValue.increment(1),
        });

        debugPrint('✅ 照片驗證成功');
        return true;
      } else {
        debugPrint('❌ 照片驗證失敗: ${analysisResult.details}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 照片驗證異常: $e');
      return false;
    }
  }

  /// 年齡驗證
  Future<bool> verifyAge(DateTime birthDate) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final now = DateTime.now();
      final age = now.year - birthDate.year;
      final isOver18 = age >= 18;

      // 考慮月份和日期的精確計算
      if (!isOver18 && 
          (now.month < birthDate.month || 
           (now.month == birthDate.month && now.day < birthDate.day))) {
        return false;
      }

      // 保存年齡驗證記錄
      final verificationId = _firestore.collection('verifications').doc().id;
      await _firestore.collection('verifications').doc(verificationId).set({
        'id': verificationId,
        'userId': user.uid,
        'type': VerificationType.age.name,
        'status': isOver18 
            ? VerificationStatus.verified.name 
            : VerificationStatus.rejected.name,
        'createdAt': FieldValue.serverTimestamp(),
        'verifiedAt': isOver18 ? FieldValue.serverTimestamp() : null,
        'metadata': {
          'birthDate': Timestamp.fromDate(birthDate),
          'calculatedAge': age,
        },
        'rejectionReason': isOver18 ? null : '未滿18歲',
      });

      if (isOver18) {
        // 更新用戶資料
        await _firestore.collection('users').doc(user.uid).update({
          'birthDate': Timestamp.fromDate(birthDate),
          'age': age,
          'ageVerified': true,
          'verificationLevel': FieldValue.increment(1),
        });

        debugPrint('✅ 年齡驗證成功: $age 歲');
        return true;
      } else {
        debugPrint('❌ 年齡驗證失敗: 未滿18歲');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 年齡驗證異常: $e');
      return false;
    }
  }

  /// 身份驗證（香港身份證）
  Future<bool> verifyIdentity(String idNumber, File idPhotoFile) async {
    try {
      debugPrint('🆔 開始身份驗證');

      final user = _auth.currentUser;
      if (user == null) return false;

      // 上傳身份證照片
      final storageRef = _storage
          .ref()
          .child('verifications')
          .child(user.uid)
          .child('id_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(idPhotoFile);
      final idPhotoUrl = await uploadTask.ref.getDownloadURL();

      // 驗證香港身份證格式
      final isValidFormat = _validateHKIDFormat(idNumber);
      
      if (!isValidFormat) {
        debugPrint('❌ 身份證格式無效');
        return false;
      }

      // 進行 OCR 識別和驗證
      final ocrResult = await _performOCRVerification(idPhotoFile, idNumber);

      // 保存驗證記錄
      final verificationId = _firestore.collection('verifications').doc().id;
      await _firestore.collection('verifications').doc(verificationId).set({
        'id': verificationId,
        'userId': user.uid,
        'type': VerificationType.identity.name,
        'status': ocrResult.isValid 
            ? VerificationStatus.verified.name 
            : VerificationStatus.rejected.name,
        'createdAt': FieldValue.serverTimestamp(),
        'verifiedAt': ocrResult.isValid ? FieldValue.serverTimestamp() : null,
        'metadata': {
          'idNumber': _hashSensitiveData(idNumber), // 加密存儲
          'idPhotoUrl': idPhotoUrl,
          'ocrConfidence': ocrResult.confidence,
          'extractedData': ocrResult.extractedData,
        },
        'rejectionReason': ocrResult.isValid ? null : ocrResult.rejectionReason,
      });

      if (ocrResult.isValid) {
        // 更新用戶資料（不存儲完整身份證號）
        await _firestore.collection('users').doc(user.uid).update({
          'identityVerified': true,
          'verificationLevel': FieldValue.increment(2), // 身份驗證權重更高
        });

        debugPrint('✅ 身份驗證成功');
        return true;
      } else {
        debugPrint('❌ 身份驗證失敗: ${ocrResult.rejectionReason}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 身份驗證異常: $e');
      return false;
    }
  }

  /// 獲取用戶驗證狀態
  Future<Map<VerificationType, UserVerification?>> getUserVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final query = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: VerificationStatus.verified.name)
          .get();

      final verifications = <VerificationType, UserVerification?>{};
      
      for (final type in VerificationType.values) {
        verifications[type] = null;
      }

      for (final doc in query.docs) {
        final verification = UserVerification.fromMap(doc.data());
        if (verification.isValid) {
          verifications[verification.type] = verification;
        }
      }

      return verifications;
    } catch (e) {
      debugPrint('❌ 獲取驗證狀態失敗: $e');
      return {};
    }
  }

  /// 計算用戶驗證等級
  Future<int> calculateVerificationLevel() async {
    final verifications = await getUserVerificationStatus();
    
    int level = 0;
    
    // 基礎驗證
    if (verifications[VerificationType.email]?.isValid == true) level += 1;
    if (verifications[VerificationType.phone]?.isValid == true) level += 1;
    
    // 進階驗證
    if (verifications[VerificationType.photo]?.isValid == true) level += 2;
    if (verifications[VerificationType.age]?.isValid == true) level += 1;
    
    // 最高級驗證
    if (verifications[VerificationType.identity]?.isValid == true) level += 3;
    if (verifications[VerificationType.location]?.isValid == true) level += 1;
    
    return level;
  }

  /// 生成驗證碼
  String _generateVerificationCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  /// 照片真實性分析
  Future<PhotoAnalysisResult> _analyzePhotoAuthenticity(File photoFile) async {
    try {
      // 讀取圖片
      final bytes = await photoFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return PhotoAnalysisResult(
          isAuthentic: false,
          confidenceScore: 0.0,
          details: '無法解析圖片',
        );
      }

      // 簡單的圖片質量檢查
      final width = image.width;
      final height = image.height;
      final aspectRatio = width / height;

      // 基本檢查
      if (width < 300 || height < 300) {
        return PhotoAnalysisResult(
          isAuthentic: false,
          confidenceScore: 0.2,
          details: '圖片解析度過低',
        );
      }

      if (aspectRatio < 0.5 || aspectRatio > 2.0) {
        return PhotoAnalysisResult(
          isAuthentic: false,
          confidenceScore: 0.3,
          details: '圖片比例異常',
        );
      }

      // 模擬 AI 分析結果
      final confidenceScore = 0.85 + (DateTime.now().millisecond % 15) / 100;
      
      return PhotoAnalysisResult(
        isAuthentic: confidenceScore > 0.8,
        confidenceScore: confidenceScore,
        details: '通過基本真實性檢測',
      );
    } catch (e) {
      return PhotoAnalysisResult(
        isAuthentic: false,
        confidenceScore: 0.0,
        details: '分析過程出錯: $e',
      );
    }
  }

  /// 驗證香港身份證格式
  bool _validateHKIDFormat(String idNumber) {
    // 香港身份證格式: X123456(A) 或 XX123456(A)
    final regex = RegExp(r'^[A-Z]{1,2}\d{6}\([A-Z0-9]\)$');
    return regex.hasMatch(idNumber.toUpperCase());
  }

  /// OCR 驗證
  Future<OCRResult> _performOCRVerification(File idPhoto, String inputIdNumber) async {
    try {
      // 模擬 OCR 識別
      await Future.delayed(const Duration(seconds: 3));
      
      // 在實際實現中，這裡會調用 Google Cloud Vision 或其他 OCR 服務
      final confidence = 0.9 + (DateTime.now().millisecond % 10) / 100;
      
      return OCRResult(
        isValid: confidence > 0.85,
        confidence: confidence,
        extractedData: {
          'idNumber': inputIdNumber,
          'confidence': confidence,
        },
        rejectionReason: confidence > 0.85 ? null : 'OCR 識別信心度不足',
      );
    } catch (e) {
      return OCRResult(
        isValid: false,
        confidence: 0.0,
        extractedData: {},
        rejectionReason: 'OCR 處理失敗: $e',
      );
    }
  }

  /// 加密敏感數據
  String _hashSensitiveData(String data) {
    // 在實際實現中，應該使用更安全的加密方法
    return data.hashCode.toString();
  }
}

/// 照片分析結果
class PhotoAnalysisResult {
  final bool isAuthentic;
  final double confidenceScore;
  final String details;

  PhotoAnalysisResult({
    required this.isAuthentic,
    required this.confidenceScore,
    required this.details,
  });
}

/// OCR 結果
class OCRResult {
  final bool isValid;
  final double confidence;
  final Map<String, dynamic> extractedData;
  final String? rejectionReason;

  OCRResult({
    required this.isValid,
    required this.confidence,
    required this.extractedData,
    this.rejectionReason,
  });
}

/// 合規檢查管理器
class ComplianceManager {
  static final ComplianceManager _instance = ComplianceManager._internal();
  factory ComplianceManager() => _instance;
  ComplianceManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 檢查用戶是否符合使用條件
  Future<ComplianceCheckResult> checkUserCompliance(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return ComplianceCheckResult(
          isCompliant: false,
          reason: '用戶不存在',
          requiredActions: ['重新註冊'],
        );
      }

      final userData = userDoc.data()!;
      final verificationLevel = userData['verificationLevel'] as int? ?? 0;
      final ageVerified = userData['ageVerified'] as bool? ?? false;
      final phoneVerified = userData['phoneVerified'] as bool? ?? false;

      final issues = <String>[];
      final actions = <String>[];

      // 年齡檢查
      if (!ageVerified) {
        issues.add('未完成年齡驗證');
        actions.add('完成年齡驗證');
      }

      // 手機驗證檢查
      if (!phoneVerified) {
        issues.add('未完成手機驗證');
        actions.add('完成手機驗證');
      }

      // 最低驗證等級檢查
      if (verificationLevel < 2) {
        issues.add('驗證等級不足');
        actions.add('完成更多身份驗證');
      }

      final isCompliant = issues.isEmpty;

      return ComplianceCheckResult(
        isCompliant: isCompliant,
        reason: isCompliant ? '符合合規要求' : issues.join(', '),
        requiredActions: actions,
        verificationLevel: verificationLevel,
      );
    } catch (e) {
      return ComplianceCheckResult(
        isCompliant: false,
        reason: '合規檢查失敗: $e',
        requiredActions: ['重新檢查'],
      );
    }
  }

  /// 記錄合規事件
  Future<void> recordComplianceEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _firestore.collection('compliance_events').add({
        'userId': userId,
        'eventType': eventType,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('❌ 記錄合規事件失敗: $e');
    }
  }
}

/// 合規檢查結果
class ComplianceCheckResult {
  final bool isCompliant;
  final String reason;
  final List<String> requiredActions;
  final int verificationLevel;

  ComplianceCheckResult({
    required this.isCompliant,
    required this.reason,
    required this.requiredActions,
    this.verificationLevel = 0,
  });
} 