import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/safety_models.dart';

class SafetyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 提交照片驗證
  Future<PhotoVerification> submitPhotoVerification({
    required File photoFile,
    File? referencePhotoFile,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    try {
      // 上傳照片到 Firebase Storage
      final photoUrl = await _uploadPhoto(photoFile, 'verification_photos');
      String? referencePhotoUrl;
      
      if (referencePhotoFile != null) {
        referencePhotoUrl = await _uploadPhoto(referencePhotoFile, 'reference_photos');
      }

      // 進行 AI 照片分析
      final analysisResult = await _analyzePhoto(photoFile, referencePhotoFile);
      
      final verification = PhotoVerification(
        id: _generateId(),
        userId: currentUserId,
        photoUrl: photoUrl,
        referencePhotoUrl: referencePhotoUrl,
        status: analysisResult['confidence'] >= 0.8 
            ? VerificationStatus.verified 
            : VerificationStatus.pending,
        confidenceScore: analysisResult['confidence'],
        analysisResult: analysisResult,
        submittedAt: DateTime.now(),
        verifiedAt: analysisResult['confidence'] >= 0.8 ? DateTime.now() : null,
        verifiedBy: 'AI_SYSTEM',
      );

      // 保存到數據庫
      await _firestore
          .collection('photo_verifications')
          .doc(verification.id)
          .set(verification.toJson());

      return verification;
    } catch (e) {
      throw Exception('照片驗證提交失敗: $e');
    }
  }

  // AI 照片分析
  Future<Map<String, dynamic>> _analyzePhoto(File photo, File? referencePhoto) async {
    // 模擬 AI 照片分析邏輯
    // 實際實現中會調用 AI 服務 API
    
    final analysisResult = <String, dynamic>{};
    
    // 基本照片質量檢查
    final fileSize = await photo.length();
    final isGoodQuality = fileSize > 100000 && fileSize < 10000000; // 100KB - 10MB
    
    // 模擬人臉檢測
    final hasFace = await _detectFace(photo);
    
    // 模擬真實性檢測
    final isReal = await _detectRealPerson(photo);
    
    // 模擬不當內容檢測
    final isAppropriate = await _detectAppropriateContent(photo);
    
    // 如果有參考照片，進行人臉比對
    double faceMatchScore = 0.0;
    if (referencePhoto != null) {
      faceMatchScore = await _compareFaces(photo, referencePhoto);
    }
    
    // 計算總體信心度
    double confidence = 0.0;
    final factors = <String>[];
    
    if (isGoodQuality) {
      confidence += 0.2;
      factors.add('照片質量良好');
    }
    
    if (hasFace) {
      confidence += 0.3;
      factors.add('檢測到人臉');
    }
    
    if (isReal) {
      confidence += 0.3;
      factors.add('真實人物照片');
    }
    
    if (isAppropriate) {
      confidence += 0.2;
      factors.add('內容適當');
    } else {
      factors.add('內容可能不適當');
    }
    
    if (referencePhoto != null && faceMatchScore > 0.7) {
      confidence += 0.2;
      factors.add('與參考照片匹配');
    }
    
    analysisResult.addAll({
      'confidence': confidence.clamp(0.0, 1.0),
      'hasface': hasFace,
      'isReal': isReal,
      'isAppropriate': isAppropriate,
      'faceMatchScore': faceMatchScore,
      'qualityScore': isGoodQuality ? 0.8 : 0.3,
      'factors': factors,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    return analysisResult;
  }

  // 模擬人臉檢測
  Future<bool> _detectFace(File photo) async {
    // 實際實現中會使用 ML Kit 或其他 AI 服務
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // 模擬檢測到人臉
  }

  // 模擬真實性檢測
  Future<bool> _detectRealPerson(File photo) async {
    // 實際實現中會檢測是否為真實人物而非卡通、AI生成等
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // 模擬檢測為真實人物
  }

  // 模擬內容適當性檢測
  Future<bool> _detectAppropriateContent(File photo) async {
    // 實際實現中會檢測不當內容
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // 模擬內容適當
  }

  // 模擬人臉比對
  Future<double> _compareFaces(File photo1, File photo2) async {
    // 實際實現中會進行人臉比對
    await Future.delayed(const Duration(milliseconds: 800));
    return 0.85; // 模擬高匹配度
  }

  // 上傳照片到 Firebase Storage
  Future<String> _uploadPhoto(File photo, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('$folder/$fileName');
    
    final uploadTask = ref.putFile(photo);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // 分析用戶行為
  Future<BehaviorAnalysis> analyzeUserBehavior(String userId) async {
    try {
      // 獲取用戶活動數據
      final userActivities = await _getUserActivities(userId);
      final communicationData = await _getCommunicationData(userId);
      final reportHistory = await _getReportHistory(userId);
      
      // 計算風險分數
      final riskScore = _calculateRiskScore(userActivities, communicationData, reportHistory);
      final riskLevel = _determineRiskLevel(riskScore);
      
      // 分析風險因素
      final riskFactors = _identifyRiskFactors(userActivities, communicationData, reportHistory);
      final positiveFactors = _identifyPositiveFactors(userActivities, communicationData);
      
      final analysis = BehaviorAnalysis(
        userId: userId,
        riskLevel: riskLevel,
        riskScore: riskScore,
        behaviorMetrics: {
          'messageFrequency': userActivities['messages_sent'] ?? 0,
          'profileViews': userActivities['profile_views'] ?? 0,
          'reportCount': reportHistory.length,
          'responseRate': communicationData['response_rate'] ?? 0.0,
          'averageMessageLength': communicationData['avg_message_length'] ?? 0,
        },
        riskFactors: riskFactors,
        positiveFactors: positiveFactors,
        lastAnalyzed: DateTime.now(),
        communicationAnalysis: communicationData,
        activityPattern: userActivities,
        requiresReview: riskScore > 0.7,
      );

      // 保存分析結果
      await _firestore
          .collection('behavior_analysis')
          .doc(userId)
          .set(analysis.toJson());

      // 如果風險較高，創建安全警報
      if (riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical) {
        await _createSafetyAlert(userId, analysis);
      }

      return analysis;
    } catch (e) {
      throw Exception('行為分析失敗: $e');
    }
  }

  // 計算風險分數
  double _calculateRiskScore(
    Map<String, dynamic> activities,
    Map<String, dynamic> communication,
    List<UserReport> reports,
  ) {
    double score = 0.0;
    
    // 舉報次數影響 (30%)
    final reportCount = reports.length;
    if (reportCount > 0) {
      score += (reportCount / 10).clamp(0.0, 0.3);
    }
    
    // 溝通模式分析 (40%)
    final responseRate = communication['response_rate'] ?? 1.0;
    final avgMessageLength = communication['avg_message_length'] ?? 50;
    final inappropriateLanguage = communication['inappropriate_language_count'] ?? 0;
    
    if (responseRate < 0.3) score += 0.1; // 回應率過低
    if (avgMessageLength < 10) score += 0.1; // 消息過短
    if (inappropriateLanguage > 0) score += 0.2; // 不當語言
    
    // 活動模式分析 (30%)
    final messageFrequency = activities['messages_sent'] ?? 0;
    final profileViews = activities['profile_views'] ?? 0;
    
    if (messageFrequency > 100) score += 0.1; // 過度發送消息
    if (profileViews > 200) score += 0.1; // 過度瀏覽檔案
    if (messageFrequency == 0 && profileViews > 50) score += 0.1; // 只看不聊
    
    return score.clamp(0.0, 1.0);
  }

  // 確定風險等級
  RiskLevel _determineRiskLevel(double riskScore) {
    if (riskScore >= 0.8) return RiskLevel.critical;
    if (riskScore >= 0.6) return RiskLevel.high;
    if (riskScore >= 0.3) return RiskLevel.medium;
    return RiskLevel.low;
  }

  // 識別風險因素
  List<String> _identifyRiskFactors(
    Map<String, dynamic> activities,
    Map<String, dynamic> communication,
    List<UserReport> reports,
  ) {
    final factors = <String>[];
    
    if (reports.isNotEmpty) {
      factors.add('收到用戶舉報 (${reports.length} 次)');
    }
    
    final inappropriateLanguage = communication['inappropriate_language_count'] ?? 0;
    if (inappropriateLanguage > 0) {
      factors.add('使用不當語言');
    }
    
    final responseRate = communication['response_rate'] ?? 1.0;
    if (responseRate < 0.3) {
      factors.add('回應率過低');
    }
    
    final messageFrequency = activities['messages_sent'] ?? 0;
    if (messageFrequency > 100) {
      factors.add('過度發送消息');
    }
    
    return factors;
  }

  // 識別正面因素
  List<String> _identifyPositiveFactors(
    Map<String, dynamic> activities,
    Map<String, dynamic> communication,
  ) {
    final factors = <String>[];
    
    final responseRate = communication['response_rate'] ?? 0.0;
    if (responseRate > 0.8) {
      factors.add('高回應率');
    }
    
    final avgMessageLength = communication['avg_message_length'] ?? 0;
    if (avgMessageLength > 30) {
      factors.add('消息內容豐富');
    }
    
    final profileCompleteness = activities['profile_completeness'] ?? 0.0;
    if (profileCompleteness > 0.8) {
      factors.add('檔案資料完整');
    }
    
    final verificationStatus = activities['photo_verified'] ?? false;
    if (verificationStatus) {
      factors.add('照片已驗證');
    }
    
    return factors;
  }

  // 創建安全警報
  Future<void> _createSafetyAlert(String userId, BehaviorAnalysis analysis) async {
    final alert = SafetyAlert(
      id: _generateId(),
      userId: userId,
      alertType: 'suspicious_behavior',
      title: '檢測到可疑行為',
      description: '用戶 $userId 的行為分析顯示較高風險，建議進行人工審核。',
      severity: analysis.riskLevel,
      alertData: {
        'riskScore': analysis.riskScore,
        'riskFactors': analysis.riskFactors,
        'analysisId': analysis.userId,
      },
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('safety_alerts')
        .doc(alert.id)
        .set(alert.toJson());
  }

  // 提交用戶舉報
  Future<UserReport> submitUserReport({
    required String reportedUserId,
    required ReportType type,
    required String description,
    List<File>? evidenceFiles,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    try {
      // 上傳證據文件
      final evidenceUrls = <String>[];
      if (evidenceFiles != null) {
        for (final file in evidenceFiles) {
          final url = await _uploadPhoto(file, 'evidence');
          evidenceUrls.add(url);
        }
      }

      final report = UserReport(
        id: _generateId(),
        reporterId: currentUserId,
        reportedUserId: reportedUserId,
        type: type,
        description: description,
        evidenceUrls: evidenceUrls,
        createdAt: DateTime.now(),
      );

      // 保存舉報
      await _firestore
          .collection('user_reports')
          .doc(report.id)
          .set(report.toJson());

      // 觸發被舉報用戶的行為分析
      await analyzeUserBehavior(reportedUserId);

      return report;
    } catch (e) {
      throw Exception('提交舉報失敗: $e');
    }
  }

  // 封鎖用戶
  Future<void> blockUser(String blockedUserId, String reason) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    final blockedUser = BlockedUser(
      id: _generateId(),
      blockerId: currentUserId,
      blockedUserId: blockedUserId,
      reason: reason,
      blockedAt: DateTime.now(),
    );

    await _firestore
        .collection('blocked_users')
        .doc(blockedUser.id)
        .set(blockedUser.toJson());
  }

  // 解除封鎖
  Future<void> unblockUser(String blockedUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final query = await _firestore
        .collection('blocked_users')
        .where('blockerId', isEqualTo: currentUserId)
        .where('blockedUserId', isEqualTo: blockedUserId)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  // 獲取封鎖列表
  Future<List<BlockedUser>> getBlockedUsers() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    final query = await _firestore
        .collection('blocked_users')
        .where('blockerId', isEqualTo: currentUserId)
        .where('isActive', isEqualTo: true)
        .get();

    return query.docs
        .map((doc) => BlockedUser.fromJson(doc.data()))
        .toList();
  }

  // 檢查是否被封鎖
  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    final query = await _firestore
        .collection('blocked_users')
        .where('blockerId', isEqualTo: otherUserId)
        .where('blockedUserId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    return query.docs.isNotEmpty;
  }

  // 獲取安全設置
  Future<SafetySettings> getSafetySettings(String userId) async {
    final doc = await _firestore
        .collection('safety_settings')
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      return SafetySettings.fromJson(doc.data()!);
    }

    // 返回默認設置
    return SafetySettings(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }

  // 更新安全設置
  Future<void> updateSafetySettings(SafetySettings settings) async {
    await _firestore
        .collection('safety_settings')
        .doc(settings.userId)
        .set(settings.toJson());
  }

  // 獲取安全警報
  Stream<List<SafetyAlert>> getSafetyAlertsStream(String userId) {
    return _firestore
        .collection('safety_alerts')
        .where('userId', isEqualTo: userId)
        .where('isResolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SafetyAlert.fromJson(doc.data()))
            .toList());
  }

  // 輔助方法
  String _generateId() => _firestore.collection('temp').doc().id;

  Future<Map<String, dynamic>> _getUserActivities(String userId) async {
    // 實際實現中會從數據庫獲取用戶活動數據
    return {
      'messages_sent': 25,
      'profile_views': 45,
      'matches_made': 8,
      'app_opens': 30,
      'profile_completeness': 0.9,
      'photo_verified': true,
    };
  }

  Future<Map<String, dynamic>> _getCommunicationData(String userId) async {
    // 實際實現中會分析用戶的溝通數據
    return {
      'response_rate': 0.85,
      'avg_message_length': 45,
      'inappropriate_language_count': 0,
      'conversation_starters': 12,
      'emoji_usage': 0.3,
    };
  }

  Future<List<UserReport>> _getReportHistory(String userId) async {
    final query = await _firestore
        .collection('user_reports')
        .where('reportedUserId', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) => UserReport.fromJson(doc.data()))
        .toList();
  }
} 