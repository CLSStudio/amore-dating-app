import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'package:flutter/foundation.dart';

/// 通知服務類
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// 初始化通知服務
  static Future<void> initialize() async {
    try {
      // 請求通知權限
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info('✅ 用戶已授權推送通知');
      } else {
        Logger.warning('❌ 用戶拒絕推送通知');
      }

      // 初始化本地通知
      await _initializeLocalNotifications();
      
      // 設置前台消息處理
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 設置背景消息處理
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // 獲取 FCM Token
      String? token = await _firebaseMessaging.getToken();
      Logger.info('📱 FCM Token: $token');
    } catch (e, stackTrace) {
      Logger.error('❌ 通知服務初始化失敗', error: e, stackTrace: stackTrace);
    }
  }

  /// 初始化本地通知
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// 處理前台消息
  static void _handleForegroundMessage(RemoteMessage message) {
    Logger.info('📨 收到前台消息: ${message.notification?.title}');
    
    // 顯示本地通知
    _showLocalNotification(
      title: message.notification?.title ?? 'Amore',
      body: message.notification?.body ?? '你有新消息',
      payload: message.data.toString(),
    );
  }

  /// 處理背景消息
  static void _handleBackgroundMessage(RemoteMessage message) {
    Logger.info('📨 用戶點擊背景消息: ${message.notification?.title}');
    // 導航到相應頁面
    _navigateToPage(message.data);
  }

  /// 通知點擊回調
  static void _onNotificationTapped(NotificationResponse response) {
    Logger.info('👆 用戶點擊通知: ${response.payload}');
    // 解析 payload 並導航
    if (response.payload != null) {
      // 導航邏輯
    }
  }

  /// 顯示本地通知
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'amore_channel',
      'Amore 通知',
      channelDescription: 'Amore 應用的通知頻道',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE91E63),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// 導航到相應頁面
  static void _navigateToPage(Map<String, dynamic> data) {
    final type = data['type'];
    final targetId = data['targetId'];

    switch (type) {
      case 'new_match':
        // 導航到配對頁面
        break;
      case 'new_message':
        // 導航到聊天頁面
        break;
      case 'profile_view':
        // 導航到個人檔案
        break;
      default:
        // 導航到主頁
        break;
    }
  }

  /// 發送配對通知
  static Future<void> sendMatchNotification({
    required String userId,
    required String matchName,
    required String matchPhoto,
  }) async {
    await _showLocalNotification(
      title: '🎉 新配對！',
      body: '你和 $matchName 互相喜歡！開始聊天吧',
      payload: 'match:$userId',
    );
  }

  /// 發送消息通知
  static Future<void> sendMessageNotification({
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    await _showLocalNotification(
      title: senderName,
      body: message,
      payload: 'message:$senderId',
    );
  }

  /// 發送檔案瀏覽通知
  static Future<void> sendProfileViewNotification({
    required String viewerId,
    required String viewerName,
  }) async {
    await _showLocalNotification(
      title: '👀 有人查看了你的檔案',
      body: '$viewerName 查看了你的檔案',
      payload: 'profile_view:$viewerId',
    );
  }

  /// 發送超級喜歡通知
  static Future<void> sendSuperLikeNotification({
    required String likerId,
    required String likerName,
  }) async {
    await _showLocalNotification(
      title: '⭐ 超級喜歡！',
      body: '$likerName 給了你一個超級喜歡！',
      payload: 'super_like:$likerId',
    );
  }

  /// 發送約會提醒
  static Future<void> sendDateReminderNotification({
    required String matchName,
    required String dateTime,
    required String location,
  }) async {
    await _showLocalNotification(
      title: '📅 約會提醒',
      body: '別忘了今天 $dateTime 和 $matchName 在 $location 的約會',
      payload: 'date_reminder',
    );
  }

  /// 發送每日推薦通知
  static Future<void> sendDailyRecommendationNotification() async {
    await _showLocalNotification(
      title: '💕 今日推薦',
      body: '有新的優質配對等你發現！',
      payload: 'daily_recommendation',
    );
  }

  /// 清除所有通知
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 設置通知偏好
  static Future<void> updateNotificationPreferences({
    required bool enableMatches,
    required bool enableMessages,
    required bool enableProfileViews,
    required bool enableDailyRecommendations,
  }) async {
    // 保存到本地存儲或 Firebase
    // 根據偏好設置決定是否發送特定類型的通知
  }

  /// 檢查通知權限
  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// 請求通知權限
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
} 