import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase 服務類
class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  /// 初始化 Firebase
  static Future<void> initialize() async {
    try {
      // 初始化 Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 配置 Firestore
      await _configureFirestore();

      // 配置 Crashlytics
      await _configureCrashlytics();

      // 配置 Analytics
      await _configureAnalytics();

      // 配置 Messaging
      await _configureMessaging();

      print('✅ Firebase 初始化成功');
    } catch (e) {
      print('❌ Firebase 初始化失敗: $e');
      rethrow;
    }
  }

  /// 配置 Firestore
  static Future<void> _configureFirestore() async {
    try {
      // 啟用離線持久化
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // 在開發模式下啟用網絡日誌
      if (kDebugMode) {
        await firestore.enableNetwork();
      }

      print('✅ Firestore 配置完成');
    } catch (e) {
      print('❌ Firestore 配置失敗: $e');
    }
  }

  /// 配置 Crashlytics
  static Future<void> _configureCrashlytics() async {
    try {
      // 在調試模式下禁用 Crashlytics
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // 設置用戶標識符（當用戶登入後）
      if (auth.currentUser != null) {
        await crashlytics.setUserIdentifier(auth.currentUser!.uid);
      }

      print('✅ Crashlytics 配置完成');
    } catch (e) {
      print('❌ Crashlytics 配置失敗: $e');
    }
  }

  /// 配置 Analytics
  static Future<void> _configureAnalytics() async {
    try {
      // 在調試模式下禁用 Analytics
      await analytics.setAnalyticsCollectionEnabled(!kDebugMode);

      print('✅ Analytics 配置完成');
    } catch (e) {
      print('❌ Analytics 配置失敗: $e');
    }
  }

  /// 配置 Messaging
  static Future<void> _configureMessaging() async {
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
        print('✅ 用戶已授權通知');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ 用戶已授權臨時通知');
      } else {
        print('❌ 用戶拒絕通知權限');
      }

      // 獲取 FCM Token
      String? token = await messaging.getToken();
      print('📱 FCM Token: $token');

      print('✅ Messaging 配置完成');
    } catch (e) {
      print('❌ Messaging 配置失敗: $e');
    }
  }

  /// 記錄自定義事件
  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print('❌ 記錄事件失敗: $e');
    }
  }

  /// 記錄錯誤
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      print('❌ 記錄錯誤失敗: $e');
    }
  }

  /// 設置用戶屬性
  static Future<void> setUserProperties({
    required String userId,
    String? age,
    String? gender,
    String? location,
  }) async {
    try {
      await analytics.setUserId(id: userId);
      
      if (age != null) {
        await analytics.setUserProperty(name: 'age_group', value: age);
      }
      
      if (gender != null) {
        await analytics.setUserProperty(name: 'gender', value: gender);
      }
      
      if (location != null) {
        await analytics.setUserProperty(name: 'location', value: location);
      }

      await crashlytics.setUserIdentifier(userId);
    } catch (e) {
      print('❌ 設置用戶屬性失敗: $e');
    }
  }
} 