import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'Amore';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // 環境配置
  static const bool isProduction = false;
  static const bool enableDebugLogs = !isProduction;
  
  // API 配置
  static const String baseUrl = 'https://api.amore.hk';
  static const String wsUrl = 'wss://ws.amore.hk';
  
  // Firebase 配置
  static const String firebaseProjectId = 'amore-dating-hk';
  
  // 功能開關
  static const bool enableVideoCall = true;
  static const bool enableVoiceCall = true;
  static const bool enableLocationServices = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // 業務邏輯配置
  static const int maxPhotosPerProfile = 6;
  static const int minAgeLimit = 18;
  static const int maxAgeLimit = 99;
  static const int maxDistanceKm = 100;
  static const int dailySwipeLimit = 100;
  static const int premiumDailySwipeLimit = 500;
  
  // AI 配置
  static const int mbtiQuestionCount = 60;
  static const int valuesQuestionCount = 30;
  static const double minMatchThreshold = 0.6;
  static const double highMatchThreshold = 0.8;
  
  // 付費功能配置
  static const List<String> premiumFeatures = [
    'unlimited_swipes',
    'super_likes',
    'profile_boost',
    'see_who_liked_you',
    'advanced_filters',
    'read_receipts',
    'love_consultant',
    'priority_support',
  ];
  
  // 本地化配置
  static const String defaultLanguage = 'zh';
  static const String defaultCountry = 'HK';
  static const String defaultCurrency = 'HKD';
  
  // 支持的語言區域
  static const List<Locale> supportedLocales = [
    Locale('zh', 'HK'), // 繁體中文 (香港)
    Locale('zh', 'TW'), // 繁體中文 (台灣)
    Locale('en', 'US'), // 英語
  ];
  
  // 安全配置
  static const int photoVerificationTimeout = 30; // 秒
  static const int maxLoginAttempts = 5;
  static const int accountLockoutDuration = 15; // 分鐘
  
  // 緩存配置
  static const int imageCacheDuration = 7; // 天
  static const int dataCacheDuration = 1; // 天
}

class AppConstants {
  // 路由名稱
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String matchingRoute = '/matching';
  static const String chatRoute = '/chat';
  static const String settingsRoute = '/settings';
  static const String premiumRoute = '/premium';
  
  // 本地存儲鍵
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';
  static const String settingsKey = 'app_settings';
  static const String firstLaunchKey = 'first_launch';
  static const String lastLocationKey = 'last_location';
  
  // Firebase 集合名稱
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String matchesCollection = 'matches';
  static const String swipesCollection = 'swipes';
  static const String likesCollection = 'likes';
  static const String blocksCollection = 'blocks';
  static const String videoChatCollection = 'video_chats';
  static const String reportsCollection = 'reports';
  static const String feedbackCollection = 'feedback';
  
  // 錯誤消息
  static const String networkErrorMessage = '網絡連接錯誤，請檢查網絡設置';
  static const String serverErrorMessage = '服務器錯誤，請稍後再試';
  static const String unauthorizedErrorMessage = '認證失敗，請重新登錄';
  static const String permissionDeniedMessage = '權限被拒絕';
  static const String locationPermissionMessage = '需要位置權限才能查找附近的用戶';
  static const String cameraPermissionMessage = '需要相機權限才能拍照';
  static const String photoPermissionMessage = '需要相冊權限才能選擇照片';
} 