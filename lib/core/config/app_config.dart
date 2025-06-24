/// 應用配置
class AppConfig {
  // 調試設置
  static const bool enableDebugLogs = true;
  static const bool enablePerformanceMonitoring = true;
  
  // API 設置
  static const String baseUrl = 'https://api.amore.hk';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Firebase 設置
  static const String firebaseProjectId = 'amore-hk';
  
  // Agora 設置
  static const String agoraAppId = 'your-agora-app-id';
  
  // 應用設置
  static const String appName = 'Amore';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@amore.hk';
  
  // 功能開關
  static const bool enableVideoCall = true;
  static const bool enableVoiceCall = true;
  static const bool enableLocationServices = true;
  static const bool enablePushNotifications = true;
  
  // UI 設置
  static const int maxPhotosPerProfile = 6;
  static const int maxInterestsPerUser = 10;
  static const double defaultRadius = 50.0; // km
  
  // 匹配設置
  static const int maxMatchesPerDay = 100;
  static const int maxLikesPerDay = 50;
  static const int maxSuperLikesPerDay = 5;
  
  // 聊天設置
  static const int maxMessageLength = 1000;
  static const int maxChatRooms = 100;
  
  // 安全設置
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutMinutes = 60;
  
  // 環境檢查
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
  
  static bool get isProduction => !isDebug;
} 