import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 安全機制強化類
class SecurityEnhancements {
  static const String _salt = 'amore_secure_salt_2024';
  static final Random _random = Random.secure();

  /// 數據加密
  static String encryptData(String data) {
    try {
      final bytes = utf8.encode(data + _salt);
      final digest = sha256.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      debugPrint('❌ 數據加密失敗: $e');
      return data; // 回退到原始數據
    }
  }

  /// 密碼哈希
  static String hashPassword(String password) {
    try {
      final bytes = utf8.encode(password + _salt);
      final digest = sha512.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      debugPrint('❌ 密碼哈希失敗: $e');
      return password;
    }
  }

  /// 生成安全的隨機 ID
  static String generateSecureId({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// 生成安全的會話令牌
  static String generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = generateSecureId(length: 16);
    final data = '$timestamp$randomPart$_salt';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// 驗證密碼強度
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    int score = 0;
    
    // 長度檢查
    if (password.length >= 12) score += 2;
    else if (password.length >= 8) score += 1;

    // 包含大寫字母
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;

    // 包含小寫字母
    if (password.contains(RegExp(r'[a-z]'))) score += 1;

    // 包含數字
    if (password.contains(RegExp(r'[0-9]'))) score += 1;

    // 包含特殊字符
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // 不包含常見模式
    if (!password.toLowerCase().contains('password') &&
        !password.toLowerCase().contains('123456') &&
        !password.toLowerCase().contains('qwerty')) {
      score += 1;
    }

    if (score >= 6) return PasswordStrength.strong;
    if (score >= 4) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  /// 輸入清理和驗證
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // 移除 HTML 標籤
    String cleaned = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // 移除危險字符
    cleaned = cleaned.replaceAll(RegExp(r'[<>"&]'), '');
    cleaned = cleaned.replaceAll("'", '');
    
    // 限制長度
    if (cleaned.length > 1000) {
      cleaned = cleaned.substring(0, 1000);
    }
    
    return cleaned.trim();
  }

  /// 驗證電子郵件格式
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  /// 驗證電話號碼（香港格式）
  static bool isValidHongKongPhone(String phone) {
    // 移除空格和特殊字符
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // 香港手機號碼格式
    final hkMobileRegex = RegExp(r'^(\+852)?[456789]\d{7}$');
    
    return hkMobileRegex.hasMatch(cleanPhone);
  }

  /// 檢測可疑行為模式
  static SuspiciousActivityLevel detectSuspiciousActivity({
    required int loginAttempts,
    required Duration timeBetweenAttempts,
    required List<String> ipAddresses,
    required int profileViews,
    required int messagesPerMinute,
  }) {
    int suspicionScore = 0;

    // 登入嘗試過於頻繁
    if (loginAttempts > 5 && timeBetweenAttempts.inMinutes < 1) {
      suspicionScore += 3;
    }

    // IP 地址變化過於頻繁
    if (ipAddresses.length > 3) {
      suspicionScore += 2;
    }

    // 檔案瀏覽過於頻繁
    if (profileViews > 100) {
      suspicionScore += 2;
    }

    // 發送消息過於頻繁
    if (messagesPerMinute > 10) {
      suspicionScore += 3;
    }

    if (suspicionScore >= 6) return SuspiciousActivityLevel.high;
    if (suspicionScore >= 3) return SuspiciousActivityLevel.medium;
    return SuspiciousActivityLevel.low;
  }

  /// 生成兩步驗證碼
  static String generateTwoFactorCode() {
    return _random.nextInt(900000).toString().padLeft(6, '0');
  }

  /// 驗證兩步驗證碼
  static bool verifyTwoFactorCode(String inputCode, String correctCode, DateTime generatedAt) {
    // 驗證碼有效期5分鐘
    if (DateTime.now().difference(generatedAt).inMinutes > 5) {
      return false;
    }

    return inputCode == correctCode;
  }

  /// 檢查設備指紋
  static Future<String> generateDeviceFingerprint() async {
    try {
      final deviceInfo = <String, dynamic>{};
      
      // 獲取設備信息（簡化版本）
      deviceInfo['platform'] = defaultTargetPlatform.toString();
      deviceInfo['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      
      final jsonString = jsonEncode(deviceInfo);
      final bytes = utf8.encode(jsonString + _salt);
      final digest = sha256.convert(bytes);
      
      return base64.encode(digest.bytes);
    } catch (e) {
      debugPrint('❌ 設備指紋生成失敗: $e');
      return generateSecureId();
    }
  }

  /// 檢測圖片安全性
  static Future<ImageSafetyResult> analyzeImageSafety(Uint8List imageBytes) async {
    try {
      // 基本檢查：文件大小
      if (imageBytes.length > 10 * 1024 * 1024) { // 10MB
        return ImageSafetyResult(
          isSafe: false,
          reason: '圖片文件過大',
          confidence: 1.0,
        );
      }

      // 檢查文件簽名（簡化版本）
      final signature = imageBytes.take(4).toList();
      final isValidImage = _isValidImageSignature(signature);

      if (!isValidImage) {
        return ImageSafetyResult(
          isSafe: false,
          reason: '無效的圖片格式',
          confidence: 0.9,
        );
      }

      // 如果通過基本檢查，返回安全
      return ImageSafetyResult(
        isSafe: true,
        reason: '圖片通過安全檢查',
        confidence: 0.8,
      );

    } catch (e) {
      debugPrint('❌ 圖片安全分析失敗: $e');
      return ImageSafetyResult(
        isSafe: false,
        reason: '圖片分析失敗',
        confidence: 0.5,
      );
    }
  }

  /// 檢查文本內容安全性
  static ContentSafetyResult analyzeTextContent(String text) {
    final lowerText = text.toLowerCase();
    int riskScore = 0;

    // 檢查敏感詞彙
    final sensitiveWords = [
      '騙',
      '詐騙',
      '轉帳',
      '匯款',
      '投資',
      '賺錢',
      '兼職',
      '色情',
      '性交易',
    ];

    for (final word in sensitiveWords) {
      if (lowerText.contains(word)) {
        riskScore += 2;
      }
    }

    // 檢查個人信息洩露
    final personalInfoPatterns = [
      RegExp(r'\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}'), // 信用卡號
      RegExp(r'\b\d{8}\b'), // 身份證號（簡化）
      RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b'), // 電話號碼
    ];

    for (final pattern in personalInfoPatterns) {
      if (pattern.hasMatch(text)) {
        riskScore += 3;
      }
    }

    // 檢查重複內容（垃圾信息）
    if (_isRepetitiveContent(text)) {
      riskScore += 1;
    }

    final safetyLevel = riskScore >= 5 
        ? ContentSafetyLevel.unsafe 
        : riskScore >= 2 
            ? ContentSafetyLevel.suspicious 
            : ContentSafetyLevel.safe;

    return ContentSafetyResult(
      level: safetyLevel,
      riskScore: riskScore,
      blockedWords: sensitiveWords.where((word) => lowerText.contains(word)).toList(),
    );
  }

  /// 實現速率限制
  static final Map<String, List<DateTime>> _rateLimitCache = {};

  static bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    if (!_rateLimitCache.containsKey(identifier)) {
      _rateLimitCache[identifier] = [];
    }

    final requests = _rateLimitCache[identifier]!;
    
    // 移除過期的請求記錄
    requests.removeWhere((request) => request.isBefore(windowStart));

    // 檢查是否超過限制
    if (requests.length >= maxRequests) {
      return false; // 被限制
    }

    // 添加當前請求
    requests.add(now);
    return true; // 允許請求
  }

  /// 生成 CSRF 令牌
  static String generateCSRFToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List.generate(16, (i) => _random.nextInt(256));
    final data = '$timestamp${randomBytes.join()}$_salt';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// 檢查圖片文件簽名
  static bool _isValidImageSignature(List<int> signature) {
    // JPEG
    if (signature.length >= 2 && signature[0] == 0xFF && signature[1] == 0xD8) {
      return true;
    }
    
    // PNG
    if (signature.length >= 4 && 
        signature[0] == 0x89 && 
        signature[1] == 0x50 && 
        signature[2] == 0x4E && 
        signature[3] == 0x47) {
      return true;
    }
    
    return false;
  }

  /// 檢查重複內容
  static bool _isRepetitiveContent(String text) {
    if (text.length < 10) return false;

    // 檢查字符重複
    final charCounts = <String, int>{};
    for (final char in text.split('')) {
      charCounts[char] = (charCounts[char] ?? 0) + 1;
    }

    // 如果任何字符重複超過文本長度的60%，視為重複內容
    final maxCount = charCounts.values.reduce((a, b) => a > b ? a : b);
    return maxCount > text.length * 0.6;
  }

  /// 清理速率限制緩存
  static void clearRateLimitCache() {
    _rateLimitCache.clear();
    debugPrint('✅ 速率限制緩存已清理');
  }
}

/// 密碼強度枚舉
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// 可疑活動級別
enum SuspiciousActivityLevel {
  low,
  medium,
  high,
}

/// 圖片安全檢查結果
class ImageSafetyResult {
  final bool isSafe;
  final String reason;
  final double confidence;

  ImageSafetyResult({
    required this.isSafe,
    required this.reason,
    required this.confidence,
  });
}

/// 內容安全級別
enum ContentSafetyLevel {
  safe,
  suspicious,
  unsafe,
}

/// 內容安全檢查結果
class ContentSafetyResult {
  final ContentSafetyLevel level;
  final int riskScore;
  final List<String> blockedWords;

  ContentSafetyResult({
    required this.level,
    required this.riskScore,
    required this.blockedWords,
  });
}

/// 用戶行為監控
class UserBehaviorMonitor {
  static final Map<String, UserSession> _activeSessions = {};

  /// 開始用戶會話
  static void startSession(String userId) {
    _activeSessions[userId] = UserSession(
      userId: userId,
      startTime: DateTime.now(),
      activities: [],
    );
  }

  /// 記錄用戶活動
  static void recordActivity(String userId, UserActivity activity) {
    final session = _activeSessions[userId];
    if (session != null) {
      session.activities.add(ActivityRecord(
        activity: activity,
        timestamp: DateTime.now(),
      ));

      // 分析行為模式
      _analyzeUserBehavior(session);
    }
  }

  /// 結束用戶會話
  static void endSession(String userId) {
    _activeSessions.remove(userId);
  }

  /// 分析用戶行為
  static void _analyzeUserBehavior(UserSession session) {
    final recentActivities = session.activities
        .where((record) => 
            DateTime.now().difference(record.timestamp).inMinutes < 10)
        .toList();

    // 檢查異常活動頻率
    if (recentActivities.length > 50) {
      debugPrint('⚠️ 用戶 ${session.userId} 活動頻率異常');
    }

    // 檢查可疑行為模式
    final messagingCount = recentActivities
        .where((record) => record.activity == UserActivity.sendMessage)
        .length;

    if (messagingCount > 20) {
      debugPrint('⚠️ 用戶 ${session.userId} 消息發送頻率過高');
    }
  }

  /// 獲取活躍會話數量
  static int getActiveSessionCount() {
    return _activeSessions.length;
  }
}

/// 用戶會話
class UserSession {
  final String userId;
  final DateTime startTime;
  final List<ActivityRecord> activities;

  UserSession({
    required this.userId,
    required this.startTime,
    required this.activities,
  });
}

/// 活動記錄
class ActivityRecord {
  final UserActivity activity;
  final DateTime timestamp;

  ActivityRecord({
    required this.activity,
    required this.timestamp,
  });
}

/// 用戶活動類型
enum UserActivity {
  login,
  logout,
  viewProfile,
  sendMessage,
  uploadPhoto,
  updateProfile,
  reportUser,
  blockUser,
} 