import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase_config.dart';

// 通知服務提供者
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// 通知類型枚舉
enum NotificationType {
  newMatch,
  newMessage,
  likeReceived,
  profileView,
  icebreaker,
  dateReminder,
  system,
}

// 通知數據模型
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.system,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': createdAt,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _channelId = 'amore_notifications';
  static const String _channelName = 'Amore 通知';
  static const String _channelDescription = 'Amore 應用的推送通知';

  // 初始化通知服務
  Future<void> initialize() async {
    try {
      // 請求通知權限
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('通知權限狀態: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 初始化本地通知
        await _initializeLocalNotifications();
        
        // 設置 FCM 監聽器
        await _setupFCMListeners();
        
        // 獲取並保存 FCM Token
        await _updateFCMToken();
        
        print('通知服務初始化成功');
      } else {
        print('通知權限被拒絕');
      }
    } catch (e) {
      print('初始化通知服務失敗: $e');
    }
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 創建 Android 通知頻道
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannel();
    }
  }

  // 創建 Android 通知頻道
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // 設置 FCM 監聽器
  Future<void> _setupFCMListeners() async {
    // 前台消息處理
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // 背景消息處理
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // 應用終止狀態下的消息處理
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // 處理前台消息
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('收到前台消息: ${message.messageId}');
    
    // 保存通知到 Firestore
    await _saveNotificationToFirestore(message);
    
    // 顯示本地通知
    await _showLocalNotification(message);
  }

  // 處理背景消息
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('處理背景消息: ${message.messageId}');
    
    // 保存通知到 Firestore
    await _saveNotificationToFirestore(message);
    
    // 處理導航邏輯
    _handleNotificationNavigation(message);
  }

  // 顯示本地通知
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

         final androidDetails = AndroidNotificationDetails(
       _channelId,
       _channelName,
       channelDescription: _channelDescription,
       importance: Importance.high,
       priority: Priority.high,
       icon: '@mipmap/ic_launcher',
       color: const Color(0xFFE91E63), // Pink color
       styleInformation: BigTextStyleInformation(
         notification.body ?? '',
         contentTitle: notification.title,
       ),
     );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['actionUrl'],
    );
  }



  // 通知點擊處理
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationNavigation(RemoteMessage(data: {'actionUrl': payload}));
    }
  }

  // 處理通知導航
  void _handleNotificationNavigation(RemoteMessage message) {
    final actionUrl = message.data['actionUrl'];
    if (actionUrl == null) return;

    // TODO: 實現路由導航邏輯
    print('導航到: $actionUrl');
  }

  // 保存通知到 Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final notification = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUserId,
        type: _getNotificationTypeFromData(message.data),
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        data: message.data,
        createdAt: DateTime.now(),
        imageUrl: message.data['imageUrl'],
        actionUrl: message.data['actionUrl'],
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      print('通知已保存到 Firestore');
    } catch (e) {
      print('保存通知失敗: $e');
    }
  }

  // 從數據中獲取通知類型
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString == null) return NotificationType.system;

    return NotificationType.values.firstWhere(
      (e) => e.toString() == 'NotificationType.$typeString',
      orElse: () => NotificationType.system,
    );
  }

  // 更新 FCM Token
  Future<void> _updateFCMToken() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await FirebaseConfig.usersCollection.doc(currentUserId).update({
        'fcmToken': token,
        'lastTokenUpdate': DateTime.now(),
      });

      print('FCM Token 已更新: ${token.substring(0, 20)}...');
    } catch (e) {
      print('更新 FCM Token 失敗: $e');
    }
  }

  // 發送配對通知
  Future<void> sendMatchNotification({
    required String targetUserId,
    required String matchUserName,
    required String? matchUserPhoto,
  }) async {
    try {
      await _sendNotificationToUser(
        targetUserId: targetUserId,
        type: NotificationType.newMatch,
        title: '🎉 新配對！',
        body: '你和 $matchUserName 互相喜歡！開始聊天吧',
        data: {
          'matchUserId': _auth.currentUser?.uid,
          'matchUserName': matchUserName,
          'matchUserPhoto': matchUserPhoto,
        },
        imageUrl: matchUserPhoto,
        actionUrl: '/chat/$targetUserId',
      );

      print('配對通知已發送給: $targetUserId');
    } catch (e) {
      print('發送配對通知失敗: $e');
    }
  }

  // 發送消息通知
  Future<void> sendMessageNotification({
    required String targetUserId,
    required String senderName,
    required String messageContent,
    required String chatId,
    String? senderPhoto,
  }) async {
    try {
      await _sendNotificationToUser(
        targetUserId: targetUserId,
        type: NotificationType.newMessage,
        title: senderName,
        body: messageContent,
        data: {
          'senderId': _auth.currentUser?.uid,
          'senderName': senderName,
          'chatId': chatId,
        },
        imageUrl: senderPhoto,
        actionUrl: '/chat/$chatId',
      );

      print('消息通知已發送給: $targetUserId');
    } catch (e) {
      print('發送消息通知失敗: $e');
    }
  }

  // 發送喜歡通知
  Future<void> sendLikeNotification({
    required String targetUserId,
    required String likerName,
    String? likerPhoto,
  }) async {
    try {
      await _sendNotificationToUser(
        targetUserId: targetUserId,
        type: NotificationType.likeReceived,
        title: '💕 有人喜歡你！',
        body: '$likerName 對你表示了興趣',
        data: {
          'likerId': _auth.currentUser?.uid,
          'likerName': likerName,
        },
        imageUrl: likerPhoto,
        actionUrl: '/profile/${_auth.currentUser?.uid}',
      );

      print('喜歡通知已發送給: $targetUserId');
    } catch (e) {
      print('發送喜歡通知失敗: $e');
    }
  }

  // 發送破冰話題通知
  Future<void> sendIcebreakerNotification({
    required String targetUserId,
    required String senderName,
    required String icebreakerContent,
    required String chatId,
  }) async {
    try {
      await _sendNotificationToUser(
        targetUserId: targetUserId,
        type: NotificationType.icebreaker,
        title: '🧊 $senderName 發送了破冰話題',
        body: icebreakerContent,
        data: {
          'senderId': _auth.currentUser?.uid,
          'senderName': senderName,
          'chatId': chatId,
        },
        actionUrl: '/chat/$chatId',
      );

      print('破冰話題通知已發送給: $targetUserId');
    } catch (e) {
      print('發送破冰話題通知失敗: $e');
    }
  }

  // 發送約會提醒通知
  Future<void> sendDateReminderNotification({
    required String targetUserId,
    required String partnerName,
    required String dateDetails,
    required DateTime dateTime,
  }) async {
    try {
      await _sendNotificationToUser(
        targetUserId: targetUserId,
        type: NotificationType.dateReminder,
        title: '📅 約會提醒',
        body: '別忘了和 $partnerName 的約會：$dateDetails',
        data: {
          'partnerId': _auth.currentUser?.uid,
          'partnerName': partnerName,
          'dateDetails': dateDetails,
          'dateTime': dateTime.toIso8601String(),
        },
        actionUrl: '/dates',
      );

      print('約會提醒通知已發送給: $targetUserId');
    } catch (e) {
      print('發送約會提醒通知失敗: $e');
    }
  }

  // 向特定用戶發送通知
  Future<void> _sendNotificationToUser({
    required String targetUserId,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // 獲取目標用戶的 FCM Token
      final userDoc = await FirebaseConfig.usersCollection.doc(targetUserId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;
      if (fcmToken == null) return;

      // 構建通知數據
      final notificationData = {
        'type': type.toString().split('.').last,
        'imageUrl': imageUrl,
        'actionUrl': actionUrl,
        ...data,
      };

      // 發送 FCM 消息
      await _firestore.collection('fcm_messages').add({
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
          'image': imageUrl,
        },
        'data': notificationData,
        'android': {
          'notification': {
            'channel_id': _channelId,
            'priority': 'high',
            'default_sound': true,
            'default_vibrate_timings': true,
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'alert': {
                'title': title,
                'body': body,
              },
              'badge': 1,
              'sound': 'default',
            },
          },
        },
        'createdAt': DateTime.now(),
        'processed': false,
      });

      // 保存通知記錄
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: targetUserId,
        type: type,
        title: title,
        body: body,
        data: notificationData,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

    } catch (e) {
      print('發送通知失敗: $e');
      throw Exception('發送通知失敗: $e');
    }
  }

  // 獲取用戶通知列表
  Stream<List<AppNotification>> getUserNotificationsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  // 標記通知為已讀
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      print('通知已標記為已讀: $notificationId');
    } catch (e) {
      print('標記通知已讀失敗: $e');
    }
  }

  // 標記所有通知為已讀
  Future<void> markAllNotificationsAsRead() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('所有通知已標記為已讀');
    } catch (e) {
      print('標記所有通知已讀失敗: $e');
    }
  }

  // 獲取未讀通知數量
  Stream<int> getUnreadNotificationCountStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 刪除通知
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();

      print('通知已刪除: $notificationId');
    } catch (e) {
      print('刪除通知失敗: $e');
    }
  }

  // 清除所有通知
  Future<void> clearAllNotifications() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('所有通知已清除');
    } catch (e) {
      print('清除通知失敗: $e');
    }
  }

  // 設置通知偏好
  Future<void> updateNotificationPreferences({
    bool? enablePushNotifications,
    bool? enableMatchNotifications,
    bool? enableMessageNotifications,
    bool? enableLikeNotifications,
    bool? enableDateReminders,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final preferences = <String, dynamic>{};
      
      if (enablePushNotifications != null) {
        preferences['enablePushNotifications'] = enablePushNotifications;
      }
      if (enableMatchNotifications != null) {
        preferences['enableMatchNotifications'] = enableMatchNotifications;
      }
      if (enableMessageNotifications != null) {
        preferences['enableMessageNotifications'] = enableMessageNotifications;
      }
      if (enableLikeNotifications != null) {
        preferences['enableLikeNotifications'] = enableLikeNotifications;
      }
      if (enableDateReminders != null) {
        preferences['enableDateReminders'] = enableDateReminders;
      }
      if (quietHoursStart != null) {
        preferences['quietHoursStart'] = quietHoursStart;
      }
      if (quietHoursEnd != null) {
        preferences['quietHoursEnd'] = quietHoursEnd;
      }

      await FirebaseConfig.usersCollection.doc(currentUserId).update({
        'notificationPreferences': preferences,
        'lastPreferencesUpdate': DateTime.now(),
      });

      print('通知偏好已更新');
    } catch (e) {
      print('更新通知偏好失敗: $e');
    }
  }

  // 檢查通知權限
  Future<bool> checkNotificationPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // 請求通知權限
  Future<bool> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // 取消所有本地通知
  Future<void> cancelAllLocalNotifications() async {
    await _localNotifications.cancelAll();
    print('所有本地通知已取消');
  }

  // 訂閱主題
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('已訂閱主題: $topic');
    } catch (e) {
      print('訂閱主題失敗: $e');
    }
  }

  // 取消訂閱主題
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('已取消訂閱主題: $topic');
    } catch (e) {
      print('取消訂閱主題失敗: $e');
    }
  }
}

// 背景消息處理器（必須是頂級函數）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('處理背景消息: ${message.messageId}');
  // 這裡可以處理背景消息邏輯
} 