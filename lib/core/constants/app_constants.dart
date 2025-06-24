/// 應用程式常量
class AppConstants {
  // 應用程式信息
  static const String appName = 'Amore';
  static const String appVersion = '1.0.0';
  static const String appDescription = '深度連結的約會應用程式';
  
  // 公司信息
  static const String companyName = 'Amore HK Limited';
  static const String supportEmail = 'support@amore.hk';
  static const String websiteUrl = 'https://amore.hk';
  
  // API 配置
  static const String baseUrl = 'https://api.amore.hk';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // 存儲鍵值
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // 頁面大小
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 圖片配置
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxProfileImages = 6;
  
  // 視頻配置
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const Duration maxVideoDuration = Duration(seconds: 30);
  
  // 聊天配置
  static const int maxMessageLength = 1000;
  static const int maxVoiceMessageDuration = 60; // 秒
  
  // 地理位置配置
  static const double defaultLocationRadius = 50.0; // 公里
  static const double maxLocationRadius = 200.0; // 公里
  
  // 年齡限制
  static const int minAge = 18;
  static const int maxAge = 99;
  
  // 社交媒體
  static const String facebookUrl = 'https://facebook.com/amore.hk';
  static const String instagramUrl = 'https://instagram.com/amore.hk';
  static const String twitterUrl = 'https://twitter.com/amore_hk';
  
  // 法律文件
  static const String privacyPolicyUrl = 'https://amore.hk/privacy';
  static const String termsOfServiceUrl = 'https://amore.hk/terms';
  static const String communityGuidelinesUrl = 'https://amore.hk/guidelines';
  
  // 付費功能
  static const String premiumProductId = 'amore_premium_monthly';
  static const String premiumYearlyProductId = 'amore_premium_yearly';
  
  // 動畫持續時間
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // 防止實例化
  AppConstants._();
} 