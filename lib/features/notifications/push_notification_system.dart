import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 通知類型
enum NotificationType {
  newMatch,
  newMessage,
  storyUpdate,
  videoCall,
  superLike,
  profileView,
  boost,
  subscription,
  system,
  promotion,
}

// 通知優先級
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

// 通知模型
class PushNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isRead;
  final bool isDelivered;
  final NotificationPriority priority;
  final String? actionUrl;
  final List<NotificationAction> actions;

  PushNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.isDelivered = false,
    this.priority = NotificationPriority.normal,
    this.actionUrl,
    this.actions = const [],
  });

  PushNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    bool? isDelivered,
    NotificationPriority? priority,
    String? actionUrl,
    List<NotificationAction>? actions,
  }) {
    return PushNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
      actions: actions ?? this.actions,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${createdAt.month}/${createdAt.day}';
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.newMatch:
        return Icons.favorite;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.storyUpdate:
        return Icons.photo_library;
      case NotificationType.videoCall:
        return Icons.videocam;
      case NotificationType.superLike:
        return Icons.star;
      case NotificationType.profileView:
        return Icons.visibility;
      case NotificationType.boost:
        return Icons.trending_up;
      case NotificationType.subscription:
        return Icons.diamond;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.newMatch:
        return Colors.pink;
      case NotificationType.newMessage:
        return Colors.blue;
      case NotificationType.storyUpdate:
        return Colors.purple;
      case NotificationType.videoCall:
        return Colors.green;
      case NotificationType.superLike:
        return Colors.orange;
      case NotificationType.profileView:
        return Colors.teal;
      case NotificationType.boost:
        return Colors.red;
      case NotificationType.subscription:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.promotion:
        return Colors.indigo;
    }
  }
}

// 通知動作
class NotificationAction {
  final String id;
  final String title;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  NotificationAction({
    required this.id,
    required this.title,
    this.actionUrl,
    this.data,
  });
}

// 通知設置
class NotificationSettings {
  final bool pushEnabled;
  final bool newMatchEnabled;
  final bool newMessageEnabled;
  final bool storyUpdateEnabled;
  final bool videoCallEnabled;
  final bool superLikeEnabled;
  final bool profileViewEnabled;
  final bool boostEnabled;
  final bool subscriptionEnabled;
  final bool systemEnabled;
  final bool promotionEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool quietHoursEnabled;

  NotificationSettings({
    this.pushEnabled = true,
    this.newMatchEnabled = true,
    this.newMessageEnabled = true,
    this.storyUpdateEnabled = true,
    this.videoCallEnabled = true,
    this.superLikeEnabled = true,
    this.profileViewEnabled = false,
    this.boostEnabled = true,
    this.subscriptionEnabled = true,
    this.systemEnabled = true,
    this.promotionEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.quietHoursEnabled = false,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? newMatchEnabled,
    bool? newMessageEnabled,
    bool? storyUpdateEnabled,
    bool? videoCallEnabled,
    bool? superLikeEnabled,
    bool? profileViewEnabled,
    bool? boostEnabled,
    bool? subscriptionEnabled,
    bool? systemEnabled,
    bool? promotionEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      newMatchEnabled: newMatchEnabled ?? this.newMatchEnabled,
      newMessageEnabled: newMessageEnabled ?? this.newMessageEnabled,
      storyUpdateEnabled: storyUpdateEnabled ?? this.storyUpdateEnabled,
      videoCallEnabled: videoCallEnabled ?? this.videoCallEnabled,
      superLikeEnabled: superLikeEnabled ?? this.superLikeEnabled,
      profileViewEnabled: profileViewEnabled ?? this.profileViewEnabled,
      boostEnabled: boostEnabled ?? this.boostEnabled,
      subscriptionEnabled: subscriptionEnabled ?? this.subscriptionEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      promotionEnabled: promotionEnabled ?? this.promotionEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }

  bool isTypeEnabled(NotificationType type) {
    if (!pushEnabled) return false;
    
    switch (type) {
      case NotificationType.newMatch:
        return newMatchEnabled;
      case NotificationType.newMessage:
        return newMessageEnabled;
      case NotificationType.storyUpdate:
        return storyUpdateEnabled;
      case NotificationType.videoCall:
        return videoCallEnabled;
      case NotificationType.superLike:
        return superLikeEnabled;
      case NotificationType.profileView:
        return profileViewEnabled;
      case NotificationType.boost:
        return boostEnabled;
      case NotificationType.subscription:
        return subscriptionEnabled;
      case NotificationType.system:
        return systemEnabled;
      case NotificationType.promotion:
        return promotionEnabled;
    }
  }
}

// 通知狀態管理
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<PushNotification>>((ref) {
  return NotificationsNotifier();
});

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationsNotifier extends StateNotifier<List<PushNotification>> {
  NotificationsNotifier() : super([]) {
    _loadSampleNotifications();
  }

  void _loadSampleNotifications() {
    final now = DateTime.now();
    final sampleNotifications = [
      PushNotification(
        id: 'notif_1',
        userId: 'current_user',
        type: NotificationType.newMatch,
        title: '新配對！',
        body: '你和小雅互相喜歡了！開始聊天吧 💕',
        imageUrl: '👩‍🦰',
        createdAt: now.subtract(const Duration(minutes: 5)),
        data: {'matchId': 'match_1', 'userId': '1'},
        actions: [
          NotificationAction(
            id: 'chat',
            title: '開始聊天',
            actionUrl: '/chat/1',
          ),
          NotificationAction(
            id: 'view_profile',
            title: '查看資料',
            actionUrl: '/profile/1',
          ),
        ],
      ),
      PushNotification(
        id: 'notif_2',
        userId: 'current_user',
        type: NotificationType.newMessage,
        title: '志明',
        body: '你好！很高興認識你 😊',
        imageUrl: '👨‍💻',
        createdAt: now.subtract(const Duration(hours: 1)),
        data: {'chatId': 'chat_2', 'userId': '2'},
        actions: [
          NotificationAction(
            id: 'reply',
            title: '回覆',
            actionUrl: '/chat/2',
          ),
        ],
      ),
      PushNotification(
        id: 'notif_3',
        userId: 'current_user',
        type: NotificationType.storyUpdate,
        title: 'Stories 更新',
        body: '美玲發布了新的 Story',
        imageUrl: '🧘‍♀️',
        createdAt: now.subtract(const Duration(hours: 2)),
        data: {'storyId': 'story_3', 'userId': '3'},
        actions: [
          NotificationAction(
            id: 'view_story',
            title: '查看 Story',
            actionUrl: '/stories/3',
          ),
        ],
      ),
      PushNotification(
        id: 'notif_4',
        userId: 'current_user',
        type: NotificationType.superLike,
        title: '超級喜歡！',
        body: '建華給了你一個超級喜歡 ⭐',
        imageUrl: '👨‍🍳',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
        data: {'userId': '4'},
        actions: [
          NotificationAction(
            id: 'view_profile',
            title: '查看資料',
            actionUrl: '/profile/4',
          ),
        ],
      ),
      PushNotification(
        id: 'notif_5',
        userId: 'current_user',
        type: NotificationType.boost,
        title: 'Boost 生效中',
        body: '你的資料正在被更多人看到！',
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: true,
        priority: NotificationPriority.high,
      ),
    ];
    
    state = sampleNotifications;
  }

  void addNotification(PushNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
  }

  void removeNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  void clearAll() {
    state = [];
  }

  List<PushNotification> getNotificationsByType(NotificationType type) {
    return state.where((notification) => notification.type == type).toList();
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings());

  void updateSettings(NotificationSettings newSettings) {
    state = newSettings;
  }

  void togglePushEnabled() {
    state = state.copyWith(pushEnabled: !state.pushEnabled);
  }

  void toggleTypeEnabled(NotificationType type, bool enabled) {
    switch (type) {
      case NotificationType.newMatch:
        state = state.copyWith(newMatchEnabled: enabled);
        break;
      case NotificationType.newMessage:
        state = state.copyWith(newMessageEnabled: enabled);
        break;
      case NotificationType.storyUpdate:
        state = state.copyWith(storyUpdateEnabled: enabled);
        break;
      case NotificationType.videoCall:
        state = state.copyWith(videoCallEnabled: enabled);
        break;
      case NotificationType.superLike:
        state = state.copyWith(superLikeEnabled: enabled);
        break;
      case NotificationType.profileView:
        state = state.copyWith(profileViewEnabled: enabled);
        break;
      case NotificationType.boost:
        state = state.copyWith(boostEnabled: enabled);
        break;
      case NotificationType.subscription:
        state = state.copyWith(subscriptionEnabled: enabled);
        break;
      case NotificationType.system:
        state = state.copyWith(systemEnabled: enabled);
        break;
      case NotificationType.promotion:
        state = state.copyWith(promotionEnabled: enabled);
        break;
    }
  }

  void updateQuietHours(String start, String end, bool enabled) {
    state = state.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
      quietHoursEnabled: enabled,
    );
  }
}

// 推送通知服務
class PushNotificationService {
  static Future<void> initialize() async {
    // 初始化推送通知服務
    await _requestPermissions();
    await _setupNotificationChannels();
  }

  static Future<void> _requestPermissions() async {
    // 請求通知權限
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> _setupNotificationChannels() async {
    // 設置通知頻道
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> sendNotification(PushNotification notification) async {
    // 發送推送通知
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> scheduleNotification(PushNotification notification) async {
    // 排程推送通知
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> cancelNotification(String notificationId) async {
    // 取消推送通知
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> cancelAllNotifications() async {
    // 取消所有推送通知
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // 創建特定類型的通知
  static PushNotification createNewMatchNotification({
    required String matchId,
    required String userName,
    required String userAvatar,
  }) {
    return PushNotification(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      type: NotificationType.newMatch,
      title: '新配對！',
      body: '你和$userName互相喜歡了！開始聊天吧 💕',
      imageUrl: userAvatar,
      createdAt: DateTime.now(),
      priority: NotificationPriority.high,
      data: {'matchId': matchId, 'userName': userName},
      actions: [
        NotificationAction(
          id: 'chat',
          title: '開始聊天',
          actionUrl: '/chat/$matchId',
        ),
        NotificationAction(
          id: 'view_profile',
          title: '查看資料',
          actionUrl: '/profile/$matchId',
        ),
      ],
    );
  }

  static PushNotification createNewMessageNotification({
    required String chatId,
    required String senderName,
    required String senderAvatar,
    required String message,
  }) {
    return PushNotification(
      id: 'message_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      type: NotificationType.newMessage,
      title: senderName,
      body: message,
      imageUrl: senderAvatar,
      createdAt: DateTime.now(),
      priority: NotificationPriority.normal,
      data: {'chatId': chatId, 'senderName': senderName},
      actions: [
        NotificationAction(
          id: 'reply',
          title: '回覆',
          actionUrl: '/chat/$chatId',
        ),
      ],
    );
  }

  static PushNotification createStoryUpdateNotification({
    required String storyId,
    required String userName,
    required String userAvatar,
  }) {
    return PushNotification(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      type: NotificationType.storyUpdate,
      title: 'Stories 更新',
      body: '$userName發布了新的 Story',
      imageUrl: userAvatar,
      createdAt: DateTime.now(),
      priority: NotificationPriority.low,
      data: {'storyId': storyId, 'userName': userName},
      actions: [
        NotificationAction(
          id: 'view_story',
          title: '查看 Story',
          actionUrl: '/stories/$storyId',
        ),
      ],
    );
  }

  static PushNotification createVideoCallNotification({
    required String callId,
    required String callerName,
    required String callerAvatar,
    required bool isVideoCall,
  }) {
    return PushNotification(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      type: NotificationType.videoCall,
      title: '${isVideoCall ? '視頻' : '語音'}通話邀請',
      body: '$callerName邀請你進行${isVideoCall ? '視頻' : '語音'}通話',
      imageUrl: callerAvatar,
      createdAt: DateTime.now(),
      priority: NotificationPriority.urgent,
      data: {'callId': callId, 'callerName': callerName, 'isVideoCall': isVideoCall},
      actions: [
        NotificationAction(
          id: 'accept',
          title: '接聽',
          actionUrl: '/call/accept/$callId',
        ),
        NotificationAction(
          id: 'decline',
          title: '拒絕',
          actionUrl: '/call/decline/$callId',
        ),
      ],
    );
  }

  static PushNotification createSuperLikeNotification({
    required String userId,
    required String userName,
    required String userAvatar,
  }) {
    return PushNotification(
      id: 'superlike_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      type: NotificationType.superLike,
      title: '超級喜歡！',
      body: '$userName給了你一個超級喜歡 ⭐',
      imageUrl: userAvatar,
      createdAt: DateTime.now(),
      priority: NotificationPriority.high,
      data: {'userId': userId, 'userName': userName},
      actions: [
        NotificationAction(
          id: 'view_profile',
          title: '查看資料',
          actionUrl: '/profile/$userId',
        ),
      ],
    );
  }
}

// 通知頁面
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('通知'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('全部已讀'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showNotificationSettings(context, ref),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(context, ref, notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '還沒有通知',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '新的配對和消息會在這裡顯示',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, PushNotification notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: notification.imageUrl != null
                  ? Center(
                      child: Text(
                        notification.imageUrl!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    )
                  : Icon(
                      notification.icon,
                      color: notification.color,
                      size: 24,
                    ),
            ),
            if (!notification.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.timeAgo,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (notification.actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: notification.actions.take(2).map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => _handleNotificationAction(context, ref, notification, action),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        action.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        onTap: () => _handleNotificationTap(context, ref, notification),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleNotificationMenu(context, ref, notification, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Text(notification.isRead ? '標記為未讀' : '標記為已讀'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('刪除'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, PushNotification notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // 根據通知類型導航到相應頁面
    switch (notification.type) {
      case NotificationType.newMatch:
        // 導航到聊天頁面
        break;
      case NotificationType.newMessage:
        // 導航到聊天頁面
        break;
      case NotificationType.storyUpdate:
        // 導航到 Stories 頁面
        break;
      case NotificationType.videoCall:
        // 處理通話邀請
        break;
      default:
        break;
    }
  }

  void _handleNotificationAction(BuildContext context, WidgetRef ref, PushNotification notification, NotificationAction action) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // 處理通知動作
    switch (action.id) {
      case 'chat':
      case 'reply':
        // 導航到聊天頁面
        break;
      case 'view_profile':
        // 導航到用戶資料頁面
        break;
      case 'view_story':
        // 導航到 Stories 頁面
        break;
      case 'accept':
        // 接聽通話
        break;
      case 'decline':
        // 拒絕通話
        break;
    }
  }

  void _handleNotificationMenu(BuildContext context, WidgetRef ref, PushNotification notification, String action) {
    switch (action) {
      case 'mark_read':
        if (notification.isRead) {
          // 標記為未讀（需要實現）
        } else {
          ref.read(notificationsProvider.notifier).markAsRead(notification.id);
        }
        break;
      case 'delete':
        ref.read(notificationsProvider.notifier).removeNotification(notification.id);
        break;
    }
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }
}

// 通知設置頁面
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('通知設置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 總開關
          _buildSettingsCard(
            title: '推送通知',
            children: [
              _buildSwitchTile(
                title: '啟用推送通知',
                subtitle: '接收所有類型的通知',
                value: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier).togglePushEnabled(),
              ),
            ],
          ),

          // 通知類型設置
          _buildSettingsCard(
            title: '通知類型',
            children: [
              _buildSwitchTile(
                title: '新配對',
                subtitle: '當有新的配對時通知',
                value: settings.newMatchEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.newMatch, value),
              ),
              _buildSwitchTile(
                title: '新消息',
                subtitle: '收到新消息時通知',
                value: settings.newMessageEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.newMessage, value),
              ),
              _buildSwitchTile(
                title: 'Stories 更新',
                subtitle: '配對對象發布新 Story 時通知',
                value: settings.storyUpdateEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.storyUpdate, value),
              ),
              _buildSwitchTile(
                title: '視頻通話',
                subtitle: '收到通話邀請時通知',
                value: settings.videoCallEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.videoCall, value),
              ),
              _buildSwitchTile(
                title: '超級喜歡',
                subtitle: '收到超級喜歡時通知',
                value: settings.superLikeEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.superLike, value),
              ),
              _buildSwitchTile(
                title: '資料瀏覽',
                subtitle: '有人查看你的資料時通知',
                value: settings.profileViewEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.profileView, value),
              ),
              _buildSwitchTile(
                title: 'Boost 相關',
                subtitle: 'Boost 狀態更新通知',
                value: settings.boostEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.boost, value),
              ),
              _buildSwitchTile(
                title: '訂閱相關',
                subtitle: '訂閱狀態和優惠通知',
                value: settings.subscriptionEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.subscription, value),
              ),
              _buildSwitchTile(
                title: '系統通知',
                subtitle: '系統更新和維護通知',
                value: settings.systemEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.system, value),
              ),
              _buildSwitchTile(
                title: '推廣通知',
                subtitle: '特別優惠和活動通知',
                value: settings.promotionEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .toggleTypeEnabled(NotificationType.promotion, value),
              ),
            ],
          ),

          // 聲音和震動設置
          _buildSettingsCard(
            title: '聲音和震動',
            children: [
              _buildSwitchTile(
                title: '通知聲音',
                subtitle: '播放通知聲音',
                value: settings.soundEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .updateSettings(settings.copyWith(soundEnabled: value)),
              ),
              _buildSwitchTile(
                title: '震動',
                subtitle: '收到通知時震動',
                value: settings.vibrationEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .updateSettings(settings.copyWith(vibrationEnabled: value)),
              ),
            ],
          ),

          // 免打擾時間
          _buildSettingsCard(
            title: '免打擾時間',
            children: [
              _buildSwitchTile(
                title: '啟用免打擾時間',
                subtitle: '在指定時間內不接收通知',
                value: settings.quietHoursEnabled,
                enabled: settings.pushEnabled,
                onChanged: (value) => ref.read(notificationSettingsProvider.notifier)
                    .updateSettings(settings.copyWith(quietHoursEnabled: value)),
              ),
              if (settings.quietHoursEnabled) ...[
                ListTile(
                  title: const Text('開始時間'),
                  subtitle: Text(settings.quietHoursStart),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, ref, true),
                ),
                ListTile(
                  title: const Text('結束時間'),
                  subtitle: Text(settings.quietHoursEnd),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, ref, false),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? Colors.grey[600] : Colors.grey[400],
          fontSize: 12,
        ),
      ),
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
      activeColor: Colors.pink,
    );
  }

  void _selectTime(BuildContext context, WidgetRef ref, bool isStart) async {
    final settings = ref.read(notificationSettingsProvider);
    final currentTime = isStart ? settings.quietHoursStart : settings.quietHoursEnd;
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      
      if (isStart) {
        ref.read(notificationSettingsProvider.notifier).updateQuietHours(
          timeString,
          settings.quietHoursEnd,
          settings.quietHoursEnabled,
        );
      } else {
        ref.read(notificationSettingsProvider.notifier).updateQuietHours(
          settings.quietHoursStart,
          timeString,
          settings.quietHoursEnabled,
        );
      }
    }
  }
} 