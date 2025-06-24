import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dating_mode_strategy.dart';
import '../../features/dating/modes/dating_mode_system.dart';

/// 🔒 Amore 安全管理器
/// 負責三大交友模式的安全保護機制
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 安全配置
  final Map<DatingMode, SecurityConfig> _securityConfigs = {};
  
  // 威脅檢測
  final ThreatDetector _threatDetector = ThreatDetector();
  
  // 數據加密
  final DataEncryption _encryption = DataEncryption();
  
  // 隱私保護
  final PrivacyProtector _privacyProtector = PrivacyProtector();
  
  // 安全審計
  final SecurityAuditor _auditor = SecurityAuditor();

  /// 🎯 初始化安全管理器
  Future<void> initialize() async {
    await _initializeSecurityConfigs();
    await _threatDetector.initialize();
    await _encryption.initialize();
    await _privacyProtector.initialize();
    await _auditor.initialize();
    
    debugPrint('🔒 安全管理器已初始化');
  }

  /// ⚙️ 初始化安全配置
  Future<void> _initializeSecurityConfigs() async {
    // 認真交往模式 - 最高安全級別
    _securityConfigs[DatingMode.serious] = SecurityConfig(
      encryptionLevel: EncryptionLevel.maximum,
      privacyLevel: PrivacyLevel.strict,
      auditLevel: AuditLevel.comprehensive,
      dataRetention: const Duration(days: 365 * 2), // 2年
      requireVerification: true,
      allowAnonymous: false,
      maxFailedAttempts: 3,
      sessionTimeout: const Duration(hours: 2),
    );

    // 探索模式 - 平衡安全級別
    _securityConfigs[DatingMode.explore] = SecurityConfig(
      encryptionLevel: EncryptionLevel.standard,
      privacyLevel: PrivacyLevel.balanced,
      auditLevel: AuditLevel.standard,
      dataRetention: const Duration(days: 365), // 1年
      requireVerification: false,
      allowAnonymous: true,
      maxFailedAttempts: 5,
      sessionTimeout: const Duration(hours: 4),
    );

    // 激情模式 - 隱私優先級別
    _securityConfigs[DatingMode.passion] = SecurityConfig(
      encryptionLevel: EncryptionLevel.maximum,
      privacyLevel: PrivacyLevel.maximum,
      auditLevel: AuditLevel.minimal,
      dataRetention: const Duration(days: 30), // 30天
      requireVerification: true,
      allowAnonymous: true,
      maxFailedAttempts: 3,
      sessionTimeout: const Duration(hours: 1),
    );
  }

  /// 🔐 用戶數據加密
  Future<Map<String, dynamic>> encryptUserData(
    Map<String, dynamic> data,
    DatingMode mode,
  ) async {
    final config = _securityConfigs[mode]!;
    return await _encryption.encryptData(data, config.encryptionLevel);
  }

  /// 🔓 用戶數據解密
  Future<Map<String, dynamic>> decryptUserData(
    Map<String, dynamic> encryptedData,
    DatingMode mode,
  ) async {
    final config = _securityConfigs[mode]!;
    return await _encryption.decryptData(encryptedData, config.encryptionLevel);
  }

  /// 🛡️ 威脅檢測
  Future<ThreatAssessment> assessThreat(
    String userId,
    String action,
    Map<String, dynamic> context,
  ) async {
    return await _threatDetector.assessThreat(userId, action, context);
  }

  /// 🕵️ 隱私保護
  Future<Map<String, dynamic>> protectPrivacy(
    Map<String, dynamic> data,
    DatingMode mode,
    String userId,
  ) async {
    final config = _securityConfigs[mode]!;
    return await _privacyProtector.protectData(data, config.privacyLevel, userId);
  }

  /// 📊 安全審計
  Future<void> auditSecurityEvent(
    String userId,
    String event,
    DatingMode mode,
    Map<String, dynamic> details,
  ) async {
    final config = _securityConfigs[mode]!;
    await _auditor.logSecurityEvent(userId, event, config.auditLevel, details);
  }

  /// 🔍 驗證用戶身份
  Future<VerificationResult> verifyUserIdentity(
    String userId,
    DatingMode mode,
  ) async {
    final config = _securityConfigs[mode]!;
    
    if (!config.requireVerification) {
      return VerificationResult.success('驗證已跳過');
    }

    // 檢查用戶驗證狀態
    final user = _auth.currentUser;
    if (user == null) {
      return VerificationResult.failure('用戶未登入');
    }

    // 檢查電子郵件驗證
    if (!user.emailVerified) {
      return VerificationResult.failure('電子郵件未驗證');
    }

    // 檢查手機號碼驗證
    if (user.phoneNumber == null) {
      return VerificationResult.failure('手機號碼未驗證');
    }

    // 檢查身份文件驗證（認真交往模式）
    if (mode == DatingMode.serious) {
      final idVerified = await _checkIdVerification(userId);
      if (!idVerified) {
        return VerificationResult.failure('身份文件未驗證');
      }
    }

    return VerificationResult.success('身份驗證成功');
  }

  /// 📱 檢查身份文件驗證
  Future<bool> _checkIdVerification(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_verifications')
          .doc(userId)
          .get();
      
      return doc.exists && doc.data()?['id_verified'] == true;
    } catch (e) {
      debugPrint('檢查身份驗證失敗: $e');
      return false;
    }
  }

  /// 🚫 內容安全檢查
  Future<ContentSafetyResult> checkContentSafety(
    String content,
    DatingMode mode,
  ) async {
    // 檢查不當內容
    final inappropriateContent = await _detectInappropriateContent(content);
    if (inappropriateContent.isDetected) {
      return ContentSafetyResult.unsafe(inappropriateContent.reason);
    }

    // 檢查垃圾訊息
    final spamDetection = await _detectSpam(content);
    if (spamDetection.isSpam) {
      return ContentSafetyResult.unsafe('檢測到垃圾訊息');
    }

    // 檢查個人資訊洩露
    final piiDetection = await _detectPII(content, mode);
    if (piiDetection.hasPersonalInfo) {
      return ContentSafetyResult.warning('內容包含個人資訊');
    }

    return ContentSafetyResult.safe();
  }

  /// 🔍 檢測不當內容
  Future<InappropriateContentResult> _detectInappropriateContent(String content) async {
    // 不當內容關鍵字列表
    final inappropriateKeywords = [
      '色情', '暴力', '仇恨', '歧視', '詐騙', '毒品',
      '賭博', '自殺', '自殘', '恐怖主義', '極端主義',
    ];

    final lowerContent = content.toLowerCase();
    
    for (final keyword in inappropriateKeywords) {
      if (lowerContent.contains(keyword)) {
        return InappropriateContentResult(
          isDetected: true,
          reason: '包含不當內容: $keyword',
          severity: ContentSeverity.high,
        );
      }
    }

    return InappropriateContentResult(isDetected: false);
  }

  /// 📧 檢測垃圾訊息
  Future<SpamDetectionResult> _detectSpam(String content) async {
    // 垃圾訊息特徵檢測
    final spamIndicators = [
      RegExp(r'(免費|優惠|促銷|限時)', caseSensitive: false),
      RegExp(r'(點擊|連結|網址|http)', caseSensitive: false),
      RegExp(r'(賺錢|投資|理財|貸款)', caseSensitive: false),
      RegExp(r'(加我|聯繫|微信|QQ)', caseSensitive: false),
    ];

    int spamScore = 0;
    for (final indicator in spamIndicators) {
      if (indicator.hasMatch(content)) {
        spamScore++;
      }
    }

    // 檢查重複字符
    if (_hasExcessiveRepetition(content)) {
      spamScore++;
    }

    // 檢查過多表情符號
    if (_hasExcessiveEmojis(content)) {
      spamScore++;
    }

    return SpamDetectionResult(
      isSpam: spamScore >= 3,
      confidence: spamScore / spamIndicators.length,
      indicators: spamScore,
    );
  }

  /// 🔍 檢測個人資訊
  Future<PIIDetectionResult> _detectPII(String content, DatingMode mode) async {
    final piiPatterns = [
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'), // 信用卡號
      RegExp(r'\b\d{8,11}\b'), // 電話號碼
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // 電子郵件
      RegExp(r'\b[A-Z]\d{6}\(\d\)\b'), // 香港身份證
    ];

    final detectedPII = <String>[];
    
    for (final pattern in piiPatterns) {
      if (pattern.hasMatch(content)) {
        detectedPII.add(pattern.pattern);
      }
    }

    // 激情模式對個人資訊更敏感
    final threshold = mode == DatingMode.passion ? 1 : 2;
    
    return PIIDetectionResult(
      hasPersonalInfo: detectedPII.length >= threshold,
      detectedTypes: detectedPII,
      riskLevel: detectedPII.length >= 2 ? RiskLevel.high : RiskLevel.medium,
    );
  }

  /// 🔄 檢查重複字符
  bool _hasExcessiveRepetition(String content) {
    if (content.length < 10) return false;
    
    int repetitionCount = 0;
    for (int i = 0; i < content.length - 1; i++) {
      if (content[i] == content[i + 1]) {
        repetitionCount++;
      }
    }
    
    return repetitionCount > content.length * 0.3;
  }

  /// 😀 檢查過多表情符號
  bool _hasExcessiveEmojis(String content) {
    final emojiPattern = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    final emojiMatches = emojiPattern.allMatches(content);
    
    return emojiMatches.length > content.length * 0.2;
  }

  /// 🔐 生成安全令牌
  String generateSecureToken(String userId, DatingMode mode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(999999);
    final data = '$userId:${mode.name}:$timestamp:$random';
    
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// 🕐 檢查會話超時
  bool isSessionExpired(String token, DatingMode mode) {
    final config = _securityConfigs[mode]!;
    // 實際實現需要從令牌中提取時間戳
    // 這裡簡化處理
    return false;
  }

  /// 📊 獲取安全報告
  Future<SecurityReport> getSecurityReport(String userId) async {
    final threats = await _threatDetector.getThreatHistory(userId);
    final auditLogs = await _auditor.getAuditLogs(userId);
    
    return SecurityReport(
      userId: userId,
      threatCount: threats.length,
      lastThreatDetected: threats.isNotEmpty ? threats.last.timestamp : null,
      auditEventCount: auditLogs.length,
      securityScore: _calculateSecurityScore(threats, auditLogs),
      recommendations: _generateSecurityRecommendations(threats, auditLogs),
    );
  }

  /// 📈 計算安全分數
  double _calculateSecurityScore(List<ThreatEvent> threats, List<AuditEvent> auditLogs) {
    double baseScore = 100.0;
    
    // 威脅扣分
    for (final threat in threats) {
      switch (threat.severity) {
        case ThreatSeverity.low:
          baseScore -= 1.0;
          break;
        case ThreatSeverity.medium:
          baseScore -= 5.0;
          break;
        case ThreatSeverity.high:
          baseScore -= 15.0;
          break;
        case ThreatSeverity.critical:
          baseScore -= 30.0;
          break;
      }
    }
    
    return (baseScore).clamp(0.0, 100.0);
  }

  /// 💡 生成安全建議
  List<String> _generateSecurityRecommendations(List<ThreatEvent> threats, List<AuditEvent> auditLogs) {
    final recommendations = <String>[];
    
    if (threats.any((t) => t.type == ThreatType.bruteForce)) {
      recommendations.add('建議啟用雙重驗證以防止暴力破解攻擊');
    }
    
    if (threats.any((t) => t.type == ThreatType.suspiciousActivity)) {
      recommendations.add('檢測到可疑活動，建議檢查帳戶安全設置');
    }
    
    if (auditLogs.any((a) => a.event == 'failed_login')) {
      recommendations.add('多次登入失敗，建議更改密碼');
    }
    
    return recommendations;
  }

  /// 🛑 停止安全管理器
  void dispose() {
    _threatDetector.dispose();
    _auditor.dispose();
    debugPrint('🛑 安全管理器已停止');
  }
}

/// 🔧 安全配置
class SecurityConfig {
  final EncryptionLevel encryptionLevel;
  final PrivacyLevel privacyLevel;
  final AuditLevel auditLevel;
  final Duration dataRetention;
  final bool requireVerification;
  final bool allowAnonymous;
  final int maxFailedAttempts;
  final Duration sessionTimeout;

  const SecurityConfig({
    required this.encryptionLevel,
    required this.privacyLevel,
    required this.auditLevel,
    required this.dataRetention,
    required this.requireVerification,
    required this.allowAnonymous,
    required this.maxFailedAttempts,
    required this.sessionTimeout,
  });
}

/// 🔐 數據加密器
class DataEncryption {
  Future<void> initialize() async {
    debugPrint('🔐 數據加密器已初始化');
  }

  Future<Map<String, dynamic>> encryptData(
    Map<String, dynamic> data,
    EncryptionLevel level,
  ) async {
    // 實際實現需要使用真實的加密算法
    final encryptedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      encryptedData[entry.key] = 'encrypted_${entry.value}';
    }
    
    return encryptedData;
  }

  Future<Map<String, dynamic>> decryptData(
    Map<String, dynamic> encryptedData,
    EncryptionLevel level,
  ) async {
    final decryptedData = <String, dynamic>{};
    
    for (final entry in encryptedData.entries) {
      final value = entry.value.toString();
      if (value.startsWith('encrypted_')) {
        decryptedData[entry.key] = value.substring(10);
      } else {
        decryptedData[entry.key] = value;
      }
    }
    
    return decryptedData;
  }
}

/// 🕵️ 隱私保護器
class PrivacyProtector {
  Future<void> initialize() async {
    debugPrint('🕵️ 隱私保護器已初始化');
  }

  Future<Map<String, dynamic>> protectData(
    Map<String, dynamic> data,
    PrivacyLevel level,
    String userId,
  ) async {
    final protectedData = Map<String, dynamic>.from(data);
    
    switch (level) {
      case PrivacyLevel.maximum:
        protectedData.remove('location');
        protectedData.remove('phone');
        protectedData.remove('email');
        break;
      case PrivacyLevel.strict:
        protectedData['location'] = _anonymizeLocation(data['location']);
        break;
      case PrivacyLevel.balanced:
        // 保持大部分數據，僅模糊化敏感信息
        break;
    }
    
    return protectedData;
  }

  String _anonymizeLocation(dynamic location) {
    if (location == null) return '';
    
    final locationStr = location.toString();
    if (locationStr.contains('香港')) {
      return '香港'; // 只保留城市級別
    }
    
    return '未知位置';
  }
}

/// 🛡️ 威脅檢測器
class ThreatDetector {
  final List<ThreatEvent> _threatHistory = [];

  Future<void> initialize() async {
    debugPrint('🛡️ 威脅檢測器已初始化');
  }

  Future<ThreatAssessment> assessThreat(
    String userId,
    String action,
    Map<String, dynamic> context,
  ) async {
    // 簡化的威脅評估邏輯
    final riskScore = _calculateRiskScore(action, context);
    final severity = _determineSeverity(riskScore);
    
    final threat = ThreatEvent(
      userId: userId,
      action: action,
      context: context,
      riskScore: riskScore,
      severity: severity,
      timestamp: DateTime.now(),
      type: _determineThreatType(action, context),
    );
    
    _threatHistory.add(threat);
    
    return ThreatAssessment(
      isThreatenening: riskScore > 0.7,
      riskScore: riskScore,
      severity: severity,
      recommendations: _generateThreatRecommendations(threat),
    );
  }

  double _calculateRiskScore(String action, Map<String, dynamic> context) {
    double score = 0.0;
    
    // 基於行為的風險評估
    switch (action) {
      case 'login':
        if (context['failed_attempts'] != null && context['failed_attempts'] > 3) {
          score += 0.5;
        }
        break;
      case 'message_send':
        if (context['message_length'] != null && context['message_length'] > 1000) {
          score += 0.3;
        }
        break;
      case 'profile_update':
        if (context['update_frequency'] != null && context['update_frequency'] > 10) {
          score += 0.4;
        }
        break;
    }
    
    return score.clamp(0.0, 1.0);
  }

  ThreatSeverity _determineSeverity(double riskScore) {
    if (riskScore >= 0.9) return ThreatSeverity.critical;
    if (riskScore >= 0.7) return ThreatSeverity.high;
    if (riskScore >= 0.4) return ThreatSeverity.medium;
    return ThreatSeverity.low;
  }

  ThreatType _determineThreatType(String action, Map<String, dynamic> context) {
    if (action == 'login' && context['failed_attempts'] != null) {
      return ThreatType.bruteForce;
    }
    
    return ThreatType.suspiciousActivity;
  }

  List<String> _generateThreatRecommendations(ThreatEvent threat) {
    final recommendations = <String>[];
    
    switch (threat.type) {
      case ThreatType.bruteForce:
        recommendations.add('啟用帳戶鎖定機制');
        recommendations.add('要求更強的密碼');
        break;
      case ThreatType.suspiciousActivity:
        recommendations.add('監控用戶行為');
        recommendations.add('考慮臨時限制功能');
        break;
      default:
        recommendations.add('繼續監控');
    }
    
    return recommendations;
  }

  Future<List<ThreatEvent>> getThreatHistory(String userId) async {
    return _threatHistory.where((t) => t.userId == userId).toList();
  }

  void dispose() {
    _threatHistory.clear();
  }
}

/// 📊 安全審計器
class SecurityAuditor {
  final List<AuditEvent> _auditLogs = [];

  Future<void> initialize() async {
    debugPrint('📊 安全審計器已初始化');
  }

  Future<void> logSecurityEvent(
    String userId,
    String event,
    AuditLevel level,
    Map<String, dynamic> details,
  ) async {
    if (level == AuditLevel.minimal && !_isCriticalEvent(event)) {
      return; // 最小審計級別只記錄關鍵事件
    }

    final auditEvent = AuditEvent(
      userId: userId,
      event: event,
      details: details,
      timestamp: DateTime.now(),
      level: level,
    );

    _auditLogs.add(auditEvent);
    
    // 保持最近1000條記錄
    if (_auditLogs.length > 1000) {
      _auditLogs.removeAt(0);
    }
  }

  bool _isCriticalEvent(String event) {
    final criticalEvents = [
      'login_failed',
      'account_locked',
      'suspicious_activity',
      'data_breach_attempt',
      'unauthorized_access',
    ];
    
    return criticalEvents.contains(event);
  }

  Future<List<AuditEvent>> getAuditLogs(String userId) async {
    return _auditLogs.where((a) => a.userId == userId).toList();
  }

  void dispose() {
    _auditLogs.clear();
  }
}

// 枚舉定義
enum EncryptionLevel { standard, high, maximum }
enum PrivacyLevel { balanced, strict, maximum }
enum AuditLevel { minimal, standard, comprehensive }
enum ThreatSeverity { low, medium, high, critical }
enum ThreatType { bruteForce, suspiciousActivity, dataLeak, unauthorized }
enum ContentSeverity { low, medium, high, critical }
enum RiskLevel { low, medium, high, critical }

// 結果類定義
class VerificationResult {
  final bool isSuccess;
  final String message;

  VerificationResult.success(this.message) : isSuccess = true;
  VerificationResult.failure(this.message) : isSuccess = false;
}

class ContentSafetyResult {
  final bool isSafe;
  final String? reason;
  final bool isWarning;

  ContentSafetyResult.safe() : isSafe = true, reason = null, isWarning = false;
  ContentSafetyResult.unsafe(this.reason) : isSafe = false, isWarning = false;
  ContentSafetyResult.warning(this.reason) : isSafe = true, isWarning = true;
}

class InappropriateContentResult {
  final bool isDetected;
  final String? reason;
  final ContentSeverity? severity;

  InappropriateContentResult({
    required this.isDetected,
    this.reason,
    this.severity,
  });
}

class SpamDetectionResult {
  final bool isSpam;
  final double confidence;
  final int indicators;

  SpamDetectionResult({
    required this.isSpam,
    required this.confidence,
    required this.indicators,
  });
}

class PIIDetectionResult {
  final bool hasPersonalInfo;
  final List<String> detectedTypes;
  final RiskLevel riskLevel;

  PIIDetectionResult({
    required this.hasPersonalInfo,
    required this.detectedTypes,
    required this.riskLevel,
  });
}

class ThreatAssessment {
  final bool isThreatenening;
  final double riskScore;
  final ThreatSeverity severity;
  final List<String> recommendations;

  ThreatAssessment({
    required this.isThreatenening,
    required this.riskScore,
    required this.severity,
    required this.recommendations,
  });
}

class ThreatEvent {
  final String userId;
  final String action;
  final Map<String, dynamic> context;
  final double riskScore;
  final ThreatSeverity severity;
  final DateTime timestamp;
  final ThreatType type;

  ThreatEvent({
    required this.userId,
    required this.action,
    required this.context,
    required this.riskScore,
    required this.severity,
    required this.timestamp,
    required this.type,
  });
}

class AuditEvent {
  final String userId;
  final String event;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final AuditLevel level;

  AuditEvent({
    required this.userId,
    required this.event,
    required this.details,
    required this.timestamp,
    required this.level,
  });
}

class SecurityReport {
  final String userId;
  final int threatCount;
  final DateTime? lastThreatDetected;
  final int auditEventCount;
  final double securityScore;
  final List<String> recommendations;

  SecurityReport({
    required this.userId,
    required this.threatCount,
    this.lastThreatDetected,
    required this.auditEventCount,
    required this.securityScore,
    required this.recommendations,
  });
}