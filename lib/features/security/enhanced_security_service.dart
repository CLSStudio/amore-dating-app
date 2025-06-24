import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// 增強安全服務提供者
final enhancedSecurityServiceProvider = Provider<EnhancedSecurityService>((ref) {
  return EnhancedSecurityService();
});

// 安全威脅級別
enum ThreatLevel {
  low,
  medium,
  high,
  critical,
}

// 安全事件類型
enum SecurityEventType {
  suspiciousLogin,
  contentViolation,
  spamBehavior,
  fakeProfile,
  harassment,
  fraudAttempt,
  underage,
  violentContent,
}

// 用戶行為分析結果
class BehaviorAnalysisResult {
  final String userId;
  final double riskScore; // 0.0 - 1.0
  final ThreatLevel threatLevel;
  final List<String> riskFactors;
  final Map<String, dynamic> behaviorMetrics;
  final DateTime analyzedAt;
  final String? recommendation;

  BehaviorAnalysisResult({
    required this.userId,
    required this.riskScore,
    required this.threatLevel,
    required this.riskFactors,
    required this.behaviorMetrics,
    required this.analyzedAt,
    this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'riskScore': riskScore,
      'threatLevel': threatLevel.toString(),
      'riskFactors': riskFactors,
      'behaviorMetrics': behaviorMetrics,
      'analyzedAt': analyzedAt.toIso8601String(),
      'recommendation': recommendation,
    };
  }
}

// 內容安全檢測結果
class ContentSafetyResult {
  final bool isSafe;
  final double confidenceScore;
  final List<String> violations;
  final ThreatLevel threatLevel;
  final String? actionRequired;

  ContentSafetyResult({
    required this.isSafe,
    required this.confidenceScore,
    required this.violations,
    required this.threatLevel,
    this.actionRequired,
  });
}

// 安全事件模型
class SecurityEvent {
  final String id;
  final String userId;
  final SecurityEventType type;
  final ThreatLevel severity;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceFingerprint;
  final bool isResolved;

  SecurityEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.description,
    required this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.deviceFingerprint,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'severity': severity.toString(),
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceFingerprint': deviceFingerprint,
      'isResolved': isResolved,
    };
  }
}

class EnhancedSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 用戶行為追蹤
  final Map<String, List<Map<String, dynamic>>> _userActivities = {};
  final Map<String, DateTime> _lastLoginAttempts = {};
  final Map<String, int> _failedLoginCounts = {};

  /// AI 內容安全檢測
  Future<ContentSafetyResult> analyzeContentSafety(String content) async {
    try {
      print('🔍 開始分析內容安全性...');

      // 基本關鍵詞檢測
      final violations = <String>[];
      double riskScore = 0.0;

      // 檢測不當詞彙
      final inappropriateWords = [
        '騙子', '詐騙', '轉帳', '匯款', '借錢', '投資', '賺錢',
        '色情', '性交易', '援交', '一夜情',
        '暴力', '殺', '死', '自殺',
        '毒品', '大麻', '海洛因',
      ];

      for (final word in inappropriateWords) {
        if (content.toLowerCase().contains(word.toLowerCase())) {
          violations.add('包含不當詞彙: $word');
          riskScore += 0.3;
        }
      }

      // 檢測個人信息洩露
      if (_containsPersonalInfo(content)) {
        violations.add('可能包含個人敏感信息');
        riskScore += 0.2;
      }

      // 檢測垃圾信息模式
      if (_isSpamContent(content)) {
        violations.add('疑似垃圾信息');
        riskScore += 0.4;
      }

      // 檢測騷擾行為
      if (_isHarassmentContent(content)) {
        violations.add('疑似騷擾內容');
        riskScore += 0.5;
      }

      // 限制風險分數
      riskScore = riskScore.clamp(0.0, 1.0);

      // 確定威脅級別
      ThreatLevel threatLevel;
      if (riskScore >= 0.8) {
        threatLevel = ThreatLevel.critical;
      } else if (riskScore >= 0.6) {
        threatLevel = ThreatLevel.high;
      } else if (riskScore >= 0.3) {
        threatLevel = ThreatLevel.medium;
      } else {
        threatLevel = ThreatLevel.low;
      }

      final result = ContentSafetyResult(
        isSafe: riskScore < 0.6,
        confidenceScore: 1.0 - riskScore,
        violations: violations,
        threatLevel: threatLevel,
        actionRequired: _getActionRequired(threatLevel),
      );

      // 記錄安全事件
      if (!result.isSafe) {
        await _recordSecurityEvent(
          type: SecurityEventType.contentViolation,
          severity: threatLevel,
          description: '檢測到不安全內容',
          metadata: {
            'content': content,
            'violations': violations,
            'riskScore': riskScore,
          },
        );
      }

      print('✅ 內容安全分析完成 - 風險分數: $riskScore');
      return result;
    } catch (e) {
      print('❌ 內容安全分析失敗: $e');
      // 安全起見，返回不安全結果
      return ContentSafetyResult(
        isSafe: false,
        confidenceScore: 0.0,
        violations: ['分析失敗'],
        threatLevel: ThreatLevel.medium,
        actionRequired: '需要人工審核',
      );
    }
  }

  /// AI 圖片安全檢測
  Future<ContentSafetyResult> analyzeImageSafety(String imageUrl) async {
    try {
      print('🔍 開始分析圖片安全性: $imageUrl');

      // 模擬AI圖片分析
      await Future.delayed(const Duration(seconds: 2));

      // 基本檢查
      final violations = <String>[];
      double riskScore = 0.0;

      // 檢查圖片大小和格式
      try {
        final ref = _storage.refFromURL(imageUrl);
        final metadata = await ref.getMetadata();
        final size = metadata.size ?? 0;

        if (size > 10 * 1024 * 1024) { // 10MB
          violations.add('圖片文件過大');
          riskScore += 0.1;
        }
      } catch (e) {
        violations.add('無法獲取圖片信息');
        riskScore += 0.2;
      }

      // 模擬AI檢測結果
      final random = DateTime.now().millisecond % 100;
      
      // 模擬不同的檢測結果
      if (random < 5) {
        violations.add('檢測到不當內容');
        riskScore += 0.8;
      } else if (random < 15) {
        violations.add('圖片質量不佳');
        riskScore += 0.3;
      } else if (random < 25) {
        violations.add('可能包含虛假信息');
        riskScore += 0.4;
      }

      // 確定威脅級別
      ThreatLevel threatLevel;
      if (riskScore >= 0.7) {
        threatLevel = ThreatLevel.critical;
      } else if (riskScore >= 0.5) {
        threatLevel = ThreatLevel.high;
      } else if (riskScore >= 0.2) {
        threatLevel = ThreatLevel.medium;
      } else {
        threatLevel = ThreatLevel.low;
      }

      final result = ContentSafetyResult(
        isSafe: riskScore < 0.5,
        confidenceScore: 1.0 - riskScore,
        violations: violations,
        threatLevel: threatLevel,
        actionRequired: _getActionRequired(threatLevel),
      );

      print('✅ 圖片安全分析完成 - 風險分數: $riskScore');
      return result;
    } catch (e) {
      print('❌ 圖片安全分析失敗: $e');
      return ContentSafetyResult(
        isSafe: false,
        confidenceScore: 0.0,
        violations: ['分析失敗'],
        threatLevel: ThreatLevel.medium,
        actionRequired: '需要人工審核',
      );
    }
  }

  /// 用戶行為分析
  Future<BehaviorAnalysisResult> analyzeBehavior(String userId) async {
    try {
      print('🔍 開始分析用戶行為: $userId');

      // 獲取用戶活動記錄
      final activities = await _getUserActivities(userId);
      final behaviorMetrics = await _calculateBehaviorMetrics(userId, activities);

      // 計算風險分數
      double riskScore = 0.0;
      final riskFactors = <String>[];

      // 分析登入模式
      final loginAnalysis = _analyzeLoginPattern(userId);
      if (loginAnalysis['suspicious'] == true) {
        riskScore += 0.3;
        riskFactors.add('異常登入模式');
      }

      // 分析消息發送頻率
      final messageFreq = behaviorMetrics['messageFrequency'] as double? ?? 0.0;
      if (messageFreq > 50) {
        riskScore += 0.4;
        riskFactors.add('消息發送過於頻繁');
      }

      // 分析檔案瀏覽行為
      final profileViews = behaviorMetrics['profileViewsPerHour'] as double? ?? 0.0;
      if (profileViews > 20) {
        riskScore += 0.3;
        riskFactors.add('檔案瀏覽頻率異常');
      }

      // 分析舉報記錄
      final reportCount = await _getUserReportCount(userId);
      if (reportCount > 3) {
        riskScore += 0.5;
        riskFactors.add('收到多次舉報');
      }

      // 分析帳戶年齡
      final accountAge = await _getAccountAge(userId);
      if (accountAge.inDays < 7) {
        riskScore += 0.2;
        riskFactors.add('新註冊帳戶');
      }

      // 限制風險分數
      riskScore = riskScore.clamp(0.0, 1.0);

      // 確定威脅級別
      ThreatLevel threatLevel;
      if (riskScore >= 0.8) {
        threatLevel = ThreatLevel.critical;
      } else if (riskScore >= 0.6) {
        threatLevel = ThreatLevel.high;
      } else if (riskScore >= 0.3) {
        threatLevel = ThreatLevel.medium;
      } else {
        threatLevel = ThreatLevel.low;
      }

      final result = BehaviorAnalysisResult(
        userId: userId,
        riskScore: riskScore,
        threatLevel: threatLevel,
        riskFactors: riskFactors,
        behaviorMetrics: behaviorMetrics,
        analyzedAt: DateTime.now(),
        recommendation: _getBehaviorRecommendation(threatLevel, riskFactors),
      );

      // 記錄分析結果
      await _saveBehaviorAnalysis(result);

      // 如果風險較高，記錄安全事件
      if (threatLevel == ThreatLevel.high || threatLevel == ThreatLevel.critical) {
        await _recordSecurityEvent(
          type: SecurityEventType.suspiciousLogin,
          severity: threatLevel,
          description: '檢測到可疑用戶行為',
          metadata: {
            'riskScore': riskScore,
            'riskFactors': riskFactors,
          },
        );
      }

      print('✅ 用戶行為分析完成 - 風險分數: $riskScore');
      return result;
    } catch (e) {
      print('❌ 用戶行為分析失敗: $e');
      return BehaviorAnalysisResult(
        userId: userId,
        riskScore: 0.5,
        threatLevel: ThreatLevel.medium,
        riskFactors: ['分析失敗'],
        behaviorMetrics: {},
        analyzedAt: DateTime.now(),
        recommendation: '需要進一步檢查',
      );
    }
  }

  /// 實時安全監控
  Future<void> startSecurityMonitoring(String userId) async {
    try {
      print('🛡️ 開始實時安全監控: $userId');

      // 設置定期行為分析
      Timer.periodic(const Duration(hours: 1), (timer) async {
        try {
          await analyzeBehavior(userId);
        } catch (e) {
          print('❌ 定期行為分析失敗: $e');
        }
      });

      // 監控登入活動
      _auth.authStateChanges().listen((user) {
        if (user != null && user.uid == userId) {
          _recordLoginActivity(userId);
        }
      });

      print('✅ 安全監控已啟動');
    } catch (e) {
      print('❌ 啟動安全監控失敗: $e');
    }
  }

  /// 緊急安全響應
  Future<void> emergencySecurityResponse({
    required String userId,
    required SecurityEventType eventType,
    required ThreatLevel severity,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🚨 緊急安全響應: $userId - ${eventType.toString()}');

      // 記錄安全事件
      await _recordSecurityEvent(
        type: eventType,
        severity: severity,
        description: '緊急安全事件',
        metadata: metadata ?? {},
      );

      // 根據嚴重程度執行不同措施
      switch (severity) {
        case ThreatLevel.critical:
          // 立即暫停帳戶
          await _suspendUser(userId, '檢測到嚴重安全威脅');
          // 通知管理員
          await _notifyAdministrators(userId, eventType, severity);
          break;

        case ThreatLevel.high:
          // 限制功能使用
          await _restrictUserFunctions(userId);
          // 要求額外驗證
          await _requireAdditionalVerification(userId);
          break;

        case ThreatLevel.medium:
          // 增加監控頻率
          await _increaseMonitoringFrequency(userId);
          // 發送警告通知
          await _sendSecurityWarning(userId);
          break;

        case ThreatLevel.low:
          // 記錄事件
          break;
      }

      print('✅ 緊急安全響應完成');
    } catch (e) {
      print('❌ 緊急安全響應失敗: $e');
    }
  }

  /// 獲取用戶安全評分
  Future<double> getUserSecurityScore(String userId) async {
    try {
      final analysis = await analyzeBehavior(userId);
      return 1.0 - analysis.riskScore; // 轉換為安全分數
    } catch (e) {
      print('❌ 獲取安全評分失敗: $e');
      return 0.5; // 默認中等安全分數
    }
  }

  /// 檢查用戶是否被封鎖
  Future<bool> isUserBlocked(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_status')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return data['blocked'] == true;
      }
      return false;
    } catch (e) {
      print('❌ 檢查用戶封鎖狀態失敗: $e');
      return false;
    }
  }

  /// 報告安全問題
  Future<void> reportSecurityIssue({
    required String reportedUserId,
    required SecurityEventType issueType,
    required String description,
    List<String>? evidence,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('security_reports').add({
        'reporterId': currentUserId,
        'reportedUserId': reportedUserId,
        'issueType': issueType.toString(),
        'description': description,
        'evidence': evidence ?? [],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ 安全問題報告已提交');
    } catch (e) {
      print('❌ 提交安全報告失敗: $e');
    }
  }

  /// 私有輔助方法

  bool _containsPersonalInfo(String content) {
    // 檢測電話號碼
    if (RegExp(r'\d{8,}').hasMatch(content)) return true;
    
    // 檢測電子郵件
    if (RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b').hasMatch(content)) return true;
    
    // 檢測身份證號碼模式
    if (RegExp(r'\b[A-Z]\d{9}\b').hasMatch(content)) return true;
    
    return false;
  }

  bool _isSpamContent(String content) {
    // 檢測重複字符
    if (RegExp(r'(.)\1{5,}').hasMatch(content)) return true;
    
    // 檢測過度使用表情符號
    final emojiCount = '😀😁😂🤣😃😄😅😆😉😊😋😎😍😘🥰😗'.split('').where((char) => content.contains(char)).length;
    if (emojiCount > content.length * 0.5) return true;
    
    // 檢測廣告模式
    final adWords = ['免費', '賺錢', '投資', '點擊', '加我', '私聊'];
    int adWordCount = 0;
    for (final word in adWords) {
      if (content.contains(word)) adWordCount++;
    }
    if (adWordCount >= 3) return true;
    
    return false;
  }

  bool _isHarassmentContent(String content) {
    final harassmentWords = ['滾', '死', '笨蛋', '白痴', '神經病', '變態'];
    for (final word in harassmentWords) {
      if (content.contains(word)) return true;
    }
    return false;
  }

  String? _getActionRequired(ThreatLevel threatLevel) {
    switch (threatLevel) {
      case ThreatLevel.critical:
        return '立即封鎖內容並暫停用戶';
      case ThreatLevel.high:
        return '隱藏內容並警告用戶';
      case ThreatLevel.medium:
        return '標記內容並記錄事件';
      case ThreatLevel.low:
        return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getUserActivities(String userId) async {
    try {
      final query = await _firestore
          .collection('user_activities')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ 獲取用戶活動失敗: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _calculateBehaviorMetrics(String userId, List<Map<String, dynamic>> activities) async {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    // 計算最近一小時的活動頻率
    final recentActivities = activities.where((activity) {
      final timestamp = (activity['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(oneHourAgo);
    }).toList();

    return {
      'totalActivities': activities.length,
      'recentActivities': recentActivities.length,
      'messageFrequency': recentActivities.where((a) => a['type'] == 'message').length.toDouble(),
      'profileViewsPerHour': recentActivities.where((a) => a['type'] == 'profile_view').length.toDouble(),
      'loginFrequency': recentActivities.where((a) => a['type'] == 'login').length.toDouble(),
    };
  }

  Map<String, dynamic> _analyzeLoginPattern(String userId) {
    final lastLogin = _lastLoginAttempts[userId];
    final failedCount = _failedLoginCounts[userId] ?? 0;
    
    return {
      'suspicious': failedCount > 3 || (lastLogin != null && DateTime.now().difference(lastLogin).inMinutes < 1),
      'failedAttempts': failedCount,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  Future<int> _getUserReportCount(String userId) async {
    try {
      final query = await _firestore
          .collection('user_reports')
          .where('reportedUserId', isEqualTo: userId)
          .get();
      return query.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<Duration> _getAccountAge(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final createdAt = (doc.data()!['createdAt'] as Timestamp).toDate();
        return DateTime.now().difference(createdAt);
      }
      return Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }

  String _getBehaviorRecommendation(ThreatLevel threatLevel, List<String> riskFactors) {
    switch (threatLevel) {
      case ThreatLevel.critical:
        return '建議立即暫停帳戶並進行人工審核';
      case ThreatLevel.high:
        return '建議限制部分功能並增加監控';
      case ThreatLevel.medium:
        return '建議發送警告並持續觀察';
      case ThreatLevel.low:
        return '建議維持正常監控';
    }
  }

  Future<void> _recordSecurityEvent({
    required SecurityEventType type,
    required ThreatLevel severity,
    required String description,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final event = SecurityEvent(
        id: _firestore.collection('security_events').doc().id,
        userId: currentUserId,
        type: type,
        severity: severity,
        description: description,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('security_events')
          .doc(event.id)
          .set(event.toJson());

      print('✅ 安全事件已記錄: ${event.id}');
    } catch (e) {
      print('❌ 記錄安全事件失敗: $e');
    }
  }

  Future<void> _saveBehaviorAnalysis(BehaviorAnalysisResult result) async {
    try {
      await _firestore
          .collection('behavior_analysis')
          .doc('${result.userId}_${DateTime.now().millisecondsSinceEpoch}')
          .set(result.toJson());
    } catch (e) {
      print('❌ 保存行為分析結果失敗: $e');
    }
  }

  void _recordLoginActivity(String userId) {
    _lastLoginAttempts[userId] = DateTime.now();
    // 重置失敗計數
    _failedLoginCounts[userId] = 0;
  }

  Future<void> _suspendUser(String userId, String reason) async {
    try {
      await _firestore.collection('user_status').doc(userId).set({
        'suspended': true,
        'suspensionReason': reason,
        'suspendedAt': FieldValue.serverTimestamp(),
      });
      print('⚠️ 用戶已暫停: $userId');
    } catch (e) {
      print('❌ 暫停用戶失敗: $e');
    }
  }

  Future<void> _restrictUserFunctions(String userId) async {
    try {
      await _firestore.collection('user_status').doc(userId).update({
        'restricted': true,
        'restrictedAt': FieldValue.serverTimestamp(),
      });
      print('⚠️ 用戶功能已限制: $userId');
    } catch (e) {
      print('❌ 限制用戶功能失敗: $e');
    }
  }

  Future<void> _requireAdditionalVerification(String userId) async {
    // TODO: 實現額外驗證邏輯
    print('🔐 要求額外驗證: $userId');
  }

  Future<void> _increaseMonitoringFrequency(String userId) async {
    // TODO: 實現增加監控頻率邏輯
    print('👁️ 增加監控頻率: $userId');
  }

  Future<void> _sendSecurityWarning(String userId) async {
    // TODO: 實現發送安全警告邏輯
    print('⚠️ 發送安全警告: $userId');
  }

  Future<void> _notifyAdministrators(String userId, SecurityEventType eventType, ThreatLevel severity) async {
    // TODO: 實現通知管理員邏輯
    print('📧 通知管理員: $userId - $eventType');
  }
} 