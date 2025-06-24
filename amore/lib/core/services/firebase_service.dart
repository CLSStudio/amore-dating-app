// 暫時模擬的 Firebase 服務（不依賴實際 Firebase SDK）
// 在實際部署時需要取消註釋 pubspec.yaml 中的 Firebase 依賴項

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../app_config.dart';

/// Firebase 服務管理類
/// 統一管理所有 Firebase 相關功能
class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  static FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  static bool _initialized = false;

  /// 初始化 Firebase 服務
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 確保 Firebase 已初始化
      await Firebase.initializeApp();
      
      if (AppConfig.enableDebugLogs) {
        print('✅ Firebase Core 初始化成功');
      }
      
      // 配置 Firestore
      await _configureFirestore();
      
      // 配置推送通知
      if (AppConfig.enablePushNotifications) {
        await _configurePushNotifications();
      }
      
      // 配置分析
      if (AppConfig.enableAnalytics) {
        await _configureAnalytics();
      }
      
      // 配置崩潰報告
      if (AppConfig.enableCrashlytics) {
        await _configureCrashlytics();
      }
      
      // 配置遠程配置
      await _configureRemoteConfig();

      _initialized = true;
      
      if (AppConfig.enableDebugLogs) {
        print('🔥 Firebase 服務初始化完成');
      }
    } catch (e, stackTrace) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Firebase 初始化失敗: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// 配置 Firestore
  static Future<void> _configureFirestore() async {
    try {
      // 在調試模式下啟用網絡日誌
      if (AppConfig.enableDebugLogs && !kIsWeb) {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
      
      // 設置離線持久化
      if (!kIsWeb) {
        await firestore.enableNetwork();
      }
      
      if (AppConfig.enableDebugLogs) {
        print('✅ Firestore 配置完成');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Firestore 配置失敗: $e');
      }
    }
  }

  /// 配置推送通知
  static Future<void> _configurePushNotifications() async {
    try {
      // 請求通知權限
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (AppConfig.enableDebugLogs) {
          print('✅ 用戶授權推送通知');
        }
        
        // 獲取 FCM token
        String? token = await messaging.getToken();
        if (token != null) {
          if (AppConfig.enableDebugLogs) {
            print('📱 FCM Token: ${token.substring(0, 20)}...');
          }
          // 保存 token 到用戶資料中
          await _saveFCMToken(token);
        }
        
        // 監聽 token 刷新
        messaging.onTokenRefresh.listen((newToken) {
          if (AppConfig.enableDebugLogs) {
            print('🔄 FCM Token 更新');
          }
          _saveFCMToken(newToken);
        });
        
        // 配置前台消息處理
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (AppConfig.enableDebugLogs) {
            print('📬 收到前台消息: ${message.notification?.title}');
          }
          _handleForegroundMessage(message);
        });
        
        // 配置背景消息處理
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          if (AppConfig.enableDebugLogs) {
            print('👆 用戶點擊通知打開應用');
          }
          _handleNotificationTap(message);
        });
        
      } else {
        if (AppConfig.enableDebugLogs) {
          print('❌ 用戶拒絕推送通知權限');
        }
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 推送通知配置失敗: $e');
      }
    }
  }

  /// 配置分析
  static Future<void> _configureAnalytics() async {
    try {
      await analytics.setAnalyticsCollectionEnabled(true);
      
      // 設置用戶屬性
      await analytics.setUserProperty(
        name: 'app_version',
        value: AppConfig.appVersion,
      );
      
      await analytics.setUserProperty(
        name: 'platform',
        value: kIsWeb ? 'web' : (defaultTargetPlatform.name),
      );
      
      if (AppConfig.enableDebugLogs) {
        print('✅ Firebase Analytics 配置完成');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Analytics 配置失敗: $e');
      }
    }
  }

  /// 配置崩潰報告
  static Future<void> _configureCrashlytics() async {
    try {
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // 設置自定義信息
      await crashlytics.setCustomKey('app_version', AppConfig.appVersion);
      await crashlytics.setCustomKey('build_number', AppConfig.buildNumber);
      await crashlytics.setCustomKey('platform', defaultTargetPlatform.name);
      
      // 在調試模式下禁用自動收集
      if (kDebugMode) {
        await crashlytics.setCrashlyticsCollectionEnabled(false);
      }
      
      if (AppConfig.enableDebugLogs) {
        print('✅ Firebase Crashlytics 配置完成');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Crashlytics 配置失敗: $e');
      }
    }
  }

  /// 配置遠程配置
  static Future<void> _configureRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // 設置默認值
      await remoteConfig.setDefaults({
        'feature_video_call_enabled': AppConfig.enableVideoCall,
        'feature_voice_call_enabled': AppConfig.enableVoiceCall,
        'daily_swipe_limit': AppConfig.dailySwipeLimit,
        'premium_daily_swipe_limit': AppConfig.premiumDailySwipeLimit,
        'min_match_threshold': AppConfig.minMatchThreshold,
      });

      // 獲取遠程配置
      await remoteConfig.fetchAndActivate();
      
      if (AppConfig.enableDebugLogs) {
        print('✅ Firebase Remote Config 配置完成');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Remote Config 配置失敗: $e');
      }
    }
  }

  /// 保存 FCM Token
  static Future<void> _saveFCMToken(String token) async {
    if (isUserLoggedIn) {
      try {
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (AppConfig.enableDebugLogs) {
          print('❌ 保存 FCM Token 失敗: $e');
        }
      }
    }
  }

  /// 處理前台消息
  static void _handleForegroundMessage(RemoteMessage message) {
    // 這裡可以顯示應用內通知
    // 實際實現時會調用通知管理器
  }

  /// 處理通知點擊
  static void _handleNotificationTap(RemoteMessage message) {
    // 這裡處理通知點擊後的導航邏輯
    final data = message.data;
    if (data.containsKey('route')) {
      // 導航到特定頁面
    }
  }

  /// 記錄自定義事件
  static Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (!AppConfig.enableAnalytics) return;
    
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      
      if (AppConfig.enableDebugLogs) {
        print('📊 記錄事件: $name');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 記錄事件失敗: $e');
      }
    }
  }

  /// 設置用戶ID
  static Future<void> setUserId(String userId) async {
    try {
      if (AppConfig.enableAnalytics) {
        await analytics.setUserId(id: userId);
      }
      
      if (AppConfig.enableCrashlytics) {
        await crashlytics.setUserIdentifier(userId);
      }
      
      if (AppConfig.enableDebugLogs) {
        print('👤 設置用戶ID: $userId');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 設置用戶ID失敗: $e');
      }
    }
  }

  /// 記錄錯誤
  static Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!AppConfig.enableCrashlytics) return;
    
    try {
      // 添加額外的上下文信息
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
      
      await crashlytics.recordError(
        exception,
        stackTrace,
        fatal: fatal,
      );
      
      if (AppConfig.enableDebugLogs) {
        print('🐛 記錄錯誤: $exception');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 記錄錯誤失敗: $e');
      }
    }
  }

  /// 檢查用戶是否已登錄
  static bool get isUserLoggedIn => auth.currentUser != null;

  /// 獲取當前用戶
  static User? get currentUser => auth.currentUser;

  /// 獲取當前用戶ID
  static String? get currentUserId => auth.currentUser?.uid;

  /// 獲取遠程配置值
  static T getRemoteConfigValue<T>(String key, T defaultValue) {
    try {
      final value = remoteConfig.getValue(key);
      if (value.source == ValueSource.valueStatic) {
        return defaultValue;
      }
      
      switch (T) {
        case bool:
          return value.asBool() as T;
        case int:
          return value.asInt() as T;
        case double:
          return value.asDouble() as T;
        case String:
          return value.asString() as T;
        default:
          return defaultValue;
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 獲取遠程配置失敗 $key: $e');
      }
      return defaultValue;
    }
  }

  /// 更新用戶在線狀態
  static Future<void> updateUserPresence(bool isOnline) async {
    if (!isUserLoggedIn) return;
    
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 更新用戶在線狀態失敗: $e');
      }
    }
  }

  /// 清理服務
  static Future<void> dispose() async {
    if (isUserLoggedIn) {
      await updateUserPresence(false);
    }
    _initialized = false;
  }
} 