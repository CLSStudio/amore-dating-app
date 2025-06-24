import 'package:flutter/foundation.dart';

class AIConfig {
  // Google AI API 密鑰配置 - 在生產環境中應從環境變量讀取
  static const String _geminiApiKey = kDebugMode 
      ? 'YOUR_DEVELOPMENT_GEMINI_API_KEY' 
      : 'YOUR_PRODUCTION_GEMINI_API_KEY';
      
  static const String _visionApiKey = kDebugMode 
      ? 'YOUR_DEVELOPMENT_VISION_API_KEY'
      : 'YOUR_PRODUCTION_VISION_API_KEY';

  // API 端點配置
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String visionEndpoint = 'https://vision.googleapis.com/v1/images:annotate';

  // 獲取 Gemini API 密鑰
  static String get geminiApiKey => _geminiApiKey;

  // 獲取 Vision API 密鑰
  static String get visionApiKey => _visionApiKey;

  // 檢查配置是否完整
  static bool get isConfigured {
    return _geminiApiKey.isNotEmpty && 
           _visionApiKey.isNotEmpty &&
           !_geminiApiKey.contains('YOUR_') &&
           !_visionApiKey.contains('YOUR_') &&
           _geminiApiKey.length >= 35 &&
           _visionApiKey.length >= 35;
  }

  // 獲取配置狀態
  static Map<String, bool> get configurationStatus {
    return {
      'gemini': _geminiApiKey.isNotEmpty && !_geminiApiKey.contains('YOUR_') && _geminiApiKey.length >= 35,
      'vision': _visionApiKey.isNotEmpty && !_visionApiKey.contains('YOUR_') && _visionApiKey.length >= 35,
      'environment': kDebugMode ? true : false,
    };
  }

  // Gemini 生成配置
  static const Map<String, dynamic> geminiGenerationConfig = {
    'temperature': 0.7,
    'topK': 40,
    'topP': 0.95,
    'maxOutputTokens': 1024,
  };

  // Gemini 安全設置
  static const List<Map<String, String>> geminiSafetySettings = [
    {
      'category': 'HARM_CATEGORY_HARASSMENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_HATE_SPEECH',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    }
  ];

  // Vision API 功能配置
  static const List<Map<String, dynamic>> visionFeatures = [
    {'type': 'FACE_DETECTION', 'maxResults': 10},
    {'type': 'SAFE_SEARCH_DETECTION'},
    {'type': 'IMAGE_PROPERTIES'},
    {'type': 'LABEL_DETECTION', 'maxResults': 10},
  ];

  // AI 使用限制配置
  static const Map<String, int> usageLimits = {
    'dailyAdviceLimit': 10,
    'dailyIcebreakersLimit': 20,
    'dailyDateIdeasLimit': 5,
    'dailyPhotoAnalysisLimit': 50,
    'monthlyTotalLimit': 500,
  };

  // 錯誤重試配置
  static const Map<String, int> retryConfig = {
    'maxRetries': 3,
    'retryDelayMs': 1000,
    'timeoutMs': 30000,
  };

  // 快取配置
  static const Map<String, Duration> cacheConfig = {
    'adviceCache': Duration(hours: 24),
    'icebreakersCache': Duration(hours: 12),
    'dateIdeasCache': Duration(hours: 6),
    'photoAnalysisCache': Duration(hours: 48),
  };

  // 獲取完整的 Gemini API URL
  static String getGeminiUrl() {
    return '$geminiEndpoint?key=$geminiApiKey';
  }

  // 獲取完整的 Vision API URL
  static String getVisionUrl() {
    return '$visionEndpoint?key=$visionApiKey';
  }

  // 驗證 API 密鑰格式
  static bool validateApiKey(String apiKey) {
    // Google API 密鑰通常以 AIza 開頭，長度約 39 字符
    return apiKey.startsWith('AIza') && apiKey.length >= 35;
  }

  // 獲取環境信息
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'isDebug': kDebugMode,
      'isRelease': kReleaseMode,
      'isProfile': kProfileMode,
      'platform': defaultTargetPlatform.toString(),
      'configuredApis': configurationStatus,
    };
  }

  // 日誌配置
  static const bool enableLogging = kDebugMode;
  static const bool enableDetailedLogging = kDebugMode;

  // 性能監控配置
  static const bool enablePerformanceMonitoring = true;
  static const Duration performanceThreshold = Duration(seconds: 5);

  // API 錯誤處理配置
  static const Map<String, String> errorMessages = {
    'api_key_invalid': 'API 密鑰無效，請檢查配置',
    'quota_exceeded': 'API 配額已用完，請稍後再試',
    'network_error': '網絡連接錯誤，請檢查網絡狀態',
    'service_unavailable': 'AI 服務暫時不可用',
    'rate_limit': '請求過於頻繁，請稍後再試',
  };

  // 備用響應配置
  static const Map<String, List<String>> fallbackResponses = {
    'loveAdvice': [
      '建議保持真誠的溝通，了解彼此的想法和感受。',
      '給對方一些個人空間，同時表達你的關心。',
      '分享你的生活和興趣，讓關係更加親密。',
    ],
    'icebreakers': [
      '你好！很高興認識你，你平時喜歡做什麼？',
      '我看到你的興趣愛好很有趣，能告訴我更多嗎？',
      '你最近有什麼特別的體驗想分享嗎？',
    ],
    'dateIdeas': [
      '去海濱長廊散步，享受美景和輕鬆對話',
      '參觀博物館或藝術館，分享彼此的想法',
      '嘗試新的餐廳，體驗不同的美食',
    ],
  };

  // 獲取備用響應
  static List<String> getFallbackResponse(String type) {
    return fallbackResponses[type] ?? ['抱歉，暫時無法提供建議'];
  }

  // API 狀態檢查
  static Future<bool> checkAPIHealth() async {
    try {
      // 這裡可以添加實際的API健康檢查邏輯
      return isConfigured;
    } catch (e) {
      if (enableLogging) {
        print('API 健康檢查失敗: $e');
      }
      return false;
    }
  }
} 