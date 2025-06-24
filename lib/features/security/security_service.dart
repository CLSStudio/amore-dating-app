import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/firebase_config.dart';

// 安全服務提供者
final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

// 驗證狀態枚舉
enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

// 舉報類型枚舉
enum ReportType {
  inappropriateContent,
  fakeProfile,
  harassment,
  spam,
  underage,
  violence,
  other,
}

// 安全事件類型枚舉
enum SecurityEventType {
  photoVerification,
  behaviorAnalysis,
  contentModeration,
  userReport,
  suspiciousActivity,
  accountSuspension,
}

// 照片驗證結果模型
class PhotoVerificationResult {
  final String id;
  final String userId;
  final String photoUrl;
  final VerificationStatus status;
  final double confidenceScore;
  final List<String> detectedIssues;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;

  PhotoVerificationResult({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.status,
    required this.confidenceScore,
    required this.detectedIssues,
    required this.createdAt,
    this.reviewedAt,
    this.reviewerNotes,
  });

  factory PhotoVerificationResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoVerificationResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${data['status']}',
        orElse: () => VerificationStatus.pending,
      ),
      confidenceScore: (data['confidenceScore'] ?? 0.0).toDouble(),
      detectedIssues: List<String>.from(data['detectedIssues'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null 
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewerNotes: data['reviewerNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
      'confidenceScore': confidenceScore,
      'detectedIssues': detectedIssues,
      'createdAt': createdAt,
      'reviewedAt': reviewedAt,
      'reviewerNotes': reviewerNotes,
    };
  }
}

// 用戶舉報模型
class UserReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportType type;
  final String description;
  final List<String> evidenceUrls;
  final DateTime createdAt;
  final String status;
  final String? reviewerNotes;
  final DateTime? reviewedAt;

  UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.type,
    required this.description,
    required this.evidenceUrls,
    required this.createdAt,
    this.status = 'pending',
    this.reviewerNotes,
    this.reviewedAt,
  });

  factory UserReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReport(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reportedUserId: data['reportedUserId'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${data['type']}',
        orElse: () => ReportType.other,
      ),
      description: data['description'] ?? '',
      evidenceUrls: List<String>.from(data['evidenceUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      reviewerNotes: data['reviewerNotes'],
      reviewedAt: data['reviewedAt'] != null 
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'type': type.toString().split('.').last,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'createdAt': createdAt,
      'status': status,
      'reviewerNotes': reviewerNotes,
      'reviewedAt': reviewedAt,
    };
  }
}

// 行為分析結果模型
class BehaviorAnalysisResult {
  final String userId;
  final double riskScore;
  final List<String> riskFactors;
  final Map<String, dynamic> metrics;
  final DateTime analyzedAt;
  final String recommendation;

  BehaviorAnalysisResult({
    required this.userId,
    required this.riskScore,
    required this.riskFactors,
    required this.metrics,
    required this.analyzedAt,
    required this.recommendation,
  });
}

// 安全事件記錄模型
class SecurityEvent {
  final String id;
  final String userId;
  final SecurityEventType type;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String severity;

  SecurityEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.metadata,
    required this.createdAt,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt,
      'severity': severity,
    };
  }
}

class SecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // AI 照片驗證
  Future<PhotoVerificationResult> verifyPhoto({
    required String photoUrl,
    required String userId,
  }) async {
    try {
      print('開始照片驗證: $photoUrl');

      // 模擬 AI 照片分析
      final analysisResult = await _analyzePhotoWithAI(photoUrl);
      
      final verificationResult = PhotoVerificationResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        photoUrl: photoUrl,
        status: analysisResult['status'] as VerificationStatus,
        confidenceScore: analysisResult['confidence'] as double,
        detectedIssues: List<String>.from(analysisResult['issues'] ?? []),
        createdAt: DateTime.now(),
      );

      // 保存驗證結果
      await _firestore
          .collection('photo_verifications')
          .doc(verificationResult.id)
          .set(verificationResult.toMap());

      // 記錄安全事件
      await _logSecurityEvent(
        userId: userId,
        type: SecurityEventType.photoVerification,
        description: '照片驗證完成',
        metadata: {
          'photoUrl': photoUrl,
          'status': verificationResult.status.toString(),
          'confidence': verificationResult.confidenceScore,
          'issues': verificationResult.detectedIssues,
        },
        severity: verificationResult.status == VerificationStatus.verified ? 'low' : 'medium',
      );

      print('照片驗證完成: ${verificationResult.status}');
      return verificationResult;
    } catch (e) {
      print('照片驗證失敗: $e');
      throw Exception('照片驗證失敗: $e');
    }
  }

  // AI 照片分析（模擬實現）
  Future<Map<String, dynamic>> _analyzePhotoWithAI(String photoUrl) async {
    // 模擬 AI 分析延遲
    await Future.delayed(const Duration(seconds: 2));

    // 模擬分析結果
    final random = DateTime.now().millisecond;
    final confidence = 0.7 + (random % 30) / 100; // 0.7-0.99
    
    final issues = <String>[];
    VerificationStatus status = VerificationStatus.verified;

    // 模擬檢測邏輯
    if (confidence < 0.8) {
      issues.add('圖片質量較低');
      status = VerificationStatus.pending;
    }
    
    if (random % 10 == 0) {
      issues.add('檢測到多個人臉');
      status = VerificationStatus.rejected;
    }
    
    if (random % 15 == 0) {
      issues.add('可能包含不當內容');
      status = VerificationStatus.rejected;
    }

    return {
      'status': status,
      'confidence': confidence,
      'issues': issues,
    };
  }

  // 實時行為監控
  Future<BehaviorAnalysisResult> analyzeBehavior(String userId) async {
    try {
      print('開始行為分析: $userId');

      // 獲取用戶活動數據
      final userActivities = await _getUserActivities(userId);
      
      // 分析行為模式
      final analysisResult = await _performBehaviorAnalysis(userActivities);
      
      // 記錄分析結果
      await _saveBehaviorAnalysis(userId, analysisResult);
      
      // 如果風險分數過高，記錄安全事件
      if (analysisResult.riskScore > 0.7) {
        await _logSecurityEvent(
          userId: userId,
          type: SecurityEventType.behaviorAnalysis,
          description: '檢測到高風險行為',
          metadata: {
            'riskScore': analysisResult.riskScore,
            'riskFactors': analysisResult.riskFactors,
            'metrics': analysisResult.metrics,
          },
          severity: 'high',
        );
      }

      print('行為分析完成: 風險分數 ${analysisResult.riskScore}');
      return analysisResult;
    } catch (e) {
      print('行為分析失敗: $e');
      throw Exception('行為分析失敗: $e');
    }
  }

  // 獲取用戶活動數據
  Future<Map<String, dynamic>> _getUserActivities(String userId) async {
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(days: 1));
    
    // 獲取最近24小時的活動
    final messagesQuery = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: oneDayAgo)
        .get();
    
    final matchesQuery = await _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .where('createdAt', isGreaterThan: oneDayAgo)
        .get();

    return {
      'messageCount': messagesQuery.docs.length,
      'matchCount': matchesQuery.docs.length,
      'messages': messagesQuery.docs.map((doc) => doc.data()).toList(),
      'timeRange': {
        'start': oneDayAgo,
        'end': now,
      },
    };
  }

  // 執行行為分析
  Future<BehaviorAnalysisResult> _performBehaviorAnalysis(
    Map<String, dynamic> activities,
  ) async {
    final messageCount = activities['messageCount'] as int;
    final matchCount = activities['matchCount'] as int;
    final messages = activities['messages'] as List<dynamic>;
    
    double riskScore = 0.0;
    final riskFactors = <String>[];
    final metrics = <String, dynamic>{};

    // 分析消息頻率
    if (messageCount > 100) {
      riskScore += 0.3;
      riskFactors.add('異常高頻消息發送');
    }
    
    // 分析配對頻率
    if (matchCount > 20) {
      riskScore += 0.2;
      riskFactors.add('異常高頻配對行為');
    }

    // 分析消息內容
    final inappropriateContent = _analyzeMessageContent(messages);
    if (inappropriateContent > 0) {
      riskScore += inappropriateContent * 0.1;
      riskFactors.add('檢測到不當內容');
    }

    // 分析時間模式
    final timePattern = _analyzeTimePattern(messages);
    if (timePattern['suspicious'] == true) {
      riskScore += 0.1;
      riskFactors.add('異常活動時間模式');
    }

    metrics.addAll({
      'messageCount': messageCount,
      'matchCount': matchCount,
      'inappropriateContentScore': inappropriateContent,
      'timePattern': timePattern,
    });

    // 確保風險分數在 0-1 範圍內
    riskScore = riskScore.clamp(0.0, 1.0);

    String recommendation;
    if (riskScore < 0.3) {
      recommendation = '正常用戶，無需特殊關注';
    } else if (riskScore < 0.7) {
      recommendation = '中等風險，建議加強監控';
    } else {
      recommendation = '高風險用戶，建議人工審核';
    }

    return BehaviorAnalysisResult(
      userId: activities['userId'] ?? '',
      riskScore: riskScore,
      riskFactors: riskFactors,
      metrics: metrics,
      analyzedAt: DateTime.now(),
      recommendation: recommendation,
    );
  }

  // 分析消息內容
  double _analyzeMessageContent(List<dynamic> messages) {
    if (messages.isEmpty) return 0.0;

    final inappropriateKeywords = [
      '錢', '轉帳', '投資', '賺錢', '兼職', '代購',
      '色情', '裸體', '性愛', '約炮',
      '毒品', '大麻', '搖頭丸',
      '詐騙', '假的', '騙子',
    ];

    int inappropriateCount = 0;
    for (final message in messages) {
      final content = (message['content'] as String? ?? '').toLowerCase();
      for (final keyword in inappropriateKeywords) {
        if (content.contains(keyword)) {
          inappropriateCount++;
          break;
        }
      }
    }

    return inappropriateCount / messages.length;
  }

  // 分析時間模式
  Map<String, dynamic> _analyzeTimePattern(List<dynamic> messages) {
    if (messages.isEmpty) {
      return {'suspicious': false, 'pattern': 'no_data'};
    }

    final hourCounts = <int, int>{};
    for (final message in messages) {
      final timestamp = message['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final hour = timestamp.toDate().hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    // 檢查是否在深夜時段（凌晨2-6點）有異常活動
    final lateNightActivity = (hourCounts[2] ?? 0) + 
                             (hourCounts[3] ?? 0) + 
                             (hourCounts[4] ?? 0) + 
                             (hourCounts[5] ?? 0);
    
    final totalMessages = messages.length;
    final lateNightRatio = lateNightActivity / totalMessages;

    return {
      'suspicious': lateNightRatio > 0.5,
      'lateNightRatio': lateNightRatio,
      'hourDistribution': hourCounts,
      'pattern': lateNightRatio > 0.5 ? 'suspicious_late_night' : 'normal',
    };
  }

  // 保存行為分析結果
  Future<void> _saveBehaviorAnalysis(
    String userId,
    BehaviorAnalysisResult result,
  ) async {
    await _firestore.collection('behavior_analysis').add({
      'userId': userId,
      'riskScore': result.riskScore,
      'riskFactors': result.riskFactors,
      'metrics': result.metrics,
      'analyzedAt': result.analyzedAt,
      'recommendation': result.recommendation,
    });
  }

  // 內容審核
  Future<bool> moderateContent({
    required String content,
    required String contentType,
    required String userId,
  }) async {
    try {
      print('開始內容審核: $contentType');

      final moderationResult = await _performContentModeration(content, contentType);
      
      // 記錄審核結果
      await _firestore.collection('content_moderation').add({
        'userId': userId,
        'content': content,
        'contentType': contentType,
        'approved': moderationResult['approved'],
        'confidence': moderationResult['confidence'],
        'reasons': moderationResult['reasons'],
        'createdAt': DateTime.now(),
      });

      // 如果內容被拒絕，記錄安全事件
      if (!moderationResult['approved']) {
        await _logSecurityEvent(
          userId: userId,
          type: SecurityEventType.contentModeration,
          description: '內容審核失敗',
          metadata: {
            'content': content,
            'contentType': contentType,
            'reasons': moderationResult['reasons'],
          },
          severity: 'medium',
        );
      }

      print('內容審核完成: ${moderationResult['approved']}');
      return moderationResult['approved'];
    } catch (e) {
      print('內容審核失敗: $e');
      return false;
    }
  }

  // 執行內容審核
  Future<Map<String, dynamic>> _performContentModeration(
    String content,
    String contentType,
  ) async {
    final inappropriateKeywords = [
      // 色情內容
      '色情', '裸體', '性愛', '約炮', '一夜情',
      // 詐騙內容
      '轉帳', '投資', '賺錢', '兼職', '代購', '刷單',
      // 暴力內容
      '殺死', '自殺', '暴力', '恐嚇',
      // 毒品內容
      '毒品', '大麻', '搖頭丸', '冰毒',
      // 仇恨言論
      '歧視', '仇恨', '種族',
    ];

    final reasons = <String>[];
    bool approved = true;
    double confidence = 1.0;

    final lowerContent = content.toLowerCase();
    
    for (final keyword in inappropriateKeywords) {
      if (lowerContent.contains(keyword)) {
        approved = false;
        reasons.add('包含不當關鍵詞: $keyword');
        confidence = 0.9;
      }
    }

    // 檢查內容長度
    if (content.length > 1000) {
      confidence -= 0.1;
      reasons.add('內容過長');
    }

    // 檢查重複字符
    if (_hasExcessiveRepetition(content)) {
      approved = false;
      reasons.add('包含過多重複字符');
      confidence = 0.8;
    }

    return {
      'approved': approved,
      'confidence': confidence,
      'reasons': reasons,
    };
  }

  // 檢查重複字符
  bool _hasExcessiveRepetition(String content) {
    if (content.length < 10) return false;
    
    final chars = content.split('');
    int maxRepeat = 1;
    int currentRepeat = 1;
    
    for (int i = 1; i < chars.length; i++) {
      if (chars[i] == chars[i - 1]) {
        currentRepeat++;
        maxRepeat = maxRepeat > currentRepeat ? maxRepeat : currentRepeat;
      } else {
        currentRepeat = 1;
      }
    }
    
    return maxRepeat > 5;
  }

  // 提交用戶舉報
  Future<String> submitUserReport({
    required String reportedUserId,
    required ReportType type,
    required String description,
    List<String>? evidenceUrls,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final report = UserReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reporterId: currentUserId,
        reportedUserId: reportedUserId,
        type: type,
        description: description,
        evidenceUrls: evidenceUrls ?? [],
        createdAt: DateTime.now(),
      );

      // 保存舉報
      await _firestore
          .collection('user_reports')
          .doc(report.id)
          .set(report.toMap());

      // 記錄安全事件
      await _logSecurityEvent(
        userId: reportedUserId,
        type: SecurityEventType.userReport,
        description: '收到用戶舉報',
        metadata: {
          'reporterId': currentUserId,
          'reportType': type.toString(),
          'description': description,
        },
        severity: 'medium',
      );

      print('用戶舉報已提交: ${report.id}');
      return report.id;
    } catch (e) {
      print('提交舉報失敗: $e');
      throw Exception('提交舉報失敗: $e');
    }
  }

  // 記錄安全事件
  Future<void> _logSecurityEvent({
    required String userId,
    required SecurityEventType type,
    required String description,
    required Map<String, dynamic> metadata,
    required String severity,
  }) async {
    try {
      final event = SecurityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: type,
        description: description,
        metadata: metadata,
        createdAt: DateTime.now(),
        severity: severity,
      );

      await _firestore
          .collection('security_events')
          .doc(event.id)
          .set(event.toMap());

      print('安全事件已記錄: ${event.id}');
    } catch (e) {
      print('記錄安全事件失敗: $e');
    }
  }

  // 檢查用戶安全狀態
  Future<Map<String, dynamic>> checkUserSecurityStatus(String userId) async {
    try {
      // 獲取照片驗證狀態
      final photoVerifications = await _firestore
          .collection('photo_verifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      // 獲取最近的行為分析
      final behaviorAnalysis = await _firestore
          .collection('behavior_analysis')
          .where('userId', isEqualTo: userId)
          .orderBy('analyzedAt', descending: true)
          .limit(1)
          .get();

      // 獲取舉報記錄
      final reports = await _firestore
          .collection('user_reports')
          .where('reportedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      // 獲取安全事件
      final securityEvents = await _firestore
          .collection('security_events')
          .where('userId', isEqualTo: userId)
          .where('severity', whereIn: ['medium', 'high'])
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

             final photoData = photoVerifications.docs.isNotEmpty 
           ? photoVerifications.docs.first.data() as Map<String, dynamic>?
           : null;
       final behaviorData = behaviorAnalysis.docs.isNotEmpty
           ? behaviorAnalysis.docs.first.data() as Map<String, dynamic>?
           : null;
           
       return {
         'photoVerified': photoData?['status'] == 'verified',
         'riskScore': (behaviorData?['riskScore'] as double?) ?? 0.0,
        'pendingReports': reports.docs.length,
        'recentSecurityEvents': securityEvents.docs.length,
        'overallStatus': _calculateOverallSecurityStatus(
          photoVerifications.docs,
          behaviorAnalysis.docs,
          reports.docs,
          securityEvents.docs,
        ),
      };
    } catch (e) {
      print('檢查安全狀態失敗: $e');
      return {
        'photoVerified': false,
        'riskScore': 1.0,
        'pendingReports': 0,
        'recentSecurityEvents': 0,
        'overallStatus': 'unknown',
      };
    }
  }

  // 計算整體安全狀態
  String _calculateOverallSecurityStatus(
    List<QueryDocumentSnapshot> photoVerifications,
    List<QueryDocumentSnapshot> behaviorAnalysis,
    List<QueryDocumentSnapshot> reports,
    List<QueryDocumentSnapshot> securityEvents,
  ) {
    int score = 100;

         // 照片未驗證扣分
     final firstPhotoData = photoVerifications.isNotEmpty 
         ? photoVerifications.first.data() as Map<String, dynamic>?
         : null;
     if (photoVerifications.isEmpty || firstPhotoData?['status'] != 'verified') {
       score -= 30;
     }

     // 高風險行為扣分
     if (behaviorAnalysis.isNotEmpty) {
       final data = behaviorAnalysis.first.data() as Map<String, dynamic>?;
       final riskScore = (data?['riskScore'] as double?) ?? 0.0;
       score -= (riskScore * 40).round();
     }

    // 舉報記錄扣分
    score -= reports.length * 20;

    // 安全事件扣分
    score -= securityEvents.length * 10;

    if (score >= 80) return 'excellent';
    if (score >= 60) return 'good';
    if (score >= 40) return 'fair';
    if (score >= 20) return 'poor';
    return 'critical';
  }

  // 暫停用戶帳戶
  Future<void> suspendUser({
    required String userId,
    required String reason,
    required Duration duration,
  }) async {
    try {
      final suspensionEnd = DateTime.now().add(duration);
      
      await FirebaseConfig.usersCollection.doc(userId).update({
        'suspended': true,
        'suspensionReason': reason,
        'suspensionEnd': suspensionEnd,
        'suspendedAt': DateTime.now(),
      });

      // 記錄安全事件
      await _logSecurityEvent(
        userId: userId,
        type: SecurityEventType.accountSuspension,
        description: '帳戶已暫停',
        metadata: {
          'reason': reason,
          'duration': duration.inDays,
          'suspensionEnd': suspensionEnd.toIso8601String(),
        },
        severity: 'high',
      );

      print('用戶帳戶已暫停: $userId');
    } catch (e) {
      print('暫停用戶失敗: $e');
      throw Exception('暫停用戶失敗: $e');
    }
  }

  // 恢復用戶帳戶
  Future<void> unsuspendUser(String userId) async {
    try {
      await FirebaseConfig.usersCollection.doc(userId).update({
        'suspended': false,
        'suspensionReason': FieldValue.delete(),
        'suspensionEnd': FieldValue.delete(),
        'unsuspendedAt': DateTime.now(),
      });

      print('用戶帳戶已恢復: $userId');
    } catch (e) {
      print('恢復用戶失敗: $e');
      throw Exception('恢復用戶失敗: $e');
    }
  }

  // 獲取安全統計
  Future<Map<String, dynamic>> getSecurityStatistics() async {
    try {
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(days: 1));
      
      // 今日照片驗證數量
      final todayVerifications = await _firestore
          .collection('photo_verifications')
          .where('createdAt', isGreaterThan: oneDayAgo)
          .get();

      // 今日舉報數量
      final todayReports = await _firestore
          .collection('user_reports')
          .where('createdAt', isGreaterThan: oneDayAgo)
          .get();

      // 今日安全事件數量
      final todayEvents = await _firestore
          .collection('security_events')
          .where('createdAt', isGreaterThan: oneDayAgo)
          .get();

      // 待處理舉報數量
      final pendingReports = await _firestore
          .collection('user_reports')
          .where('status', isEqualTo: 'pending')
          .get();

      return {
        'todayVerifications': todayVerifications.docs.length,
        'todayReports': todayReports.docs.length,
        'todaySecurityEvents': todayEvents.docs.length,
        'pendingReports': pendingReports.docs.length,
        'lastUpdated': now.toIso8601String(),
      };
    } catch (e) {
      print('獲取安全統計失敗: $e');
      return {};
    }
  }
} 