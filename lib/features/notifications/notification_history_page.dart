import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 通知類型枚舉
enum NotificationType {
  match,
  message,
  like,
  superLike,
  aiRecommendation,
  weeklyInsight,
  promotional,
  system,
}

// 通知項目模型
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? actionData;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionData,
  });

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl,
      actionData: actionData,
    );
  }
}

// 通知歷史狀態管理
final notificationHistoryProvider = StateNotifierProvider<NotificationHistoryNotifier, List<NotificationItem>>((ref) {
  return NotificationHistoryNotifier();
});

class NotificationHistoryNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationHistoryNotifier() : super([]) {
    _loadNotifications();
  }

  void _loadNotifications() {
    // 模擬載入通知數據
    final notifications = [
      NotificationItem(
        id: '1',
        type: NotificationType.match,
        title: '新配對！',
        message: '你和 Sarah Chen 互相喜歡，開始聊天吧！',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        imageUrl: 'https://picsum.photos/400/600?random=1',
        actionData: {'userId': 'sarah_chen', 'matchId': 'match_1'},
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.message,
        title: '新消息',
        message: 'Emma Wong: 你好！很高興認識你 😊',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: 'https://picsum.photos/400/600?random=2',
        actionData: {'userId': 'emma_wong', 'chatId': 'chat_1'},
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.superLike,
        title: '超級喜歡！',
        message: 'Amy Liu 給了你一個超級喜歡 ⭐',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        imageUrl: 'https://picsum.photos/400/600?random=4',
        actionData: {'userId': 'amy_liu'},
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.like,
        title: '有人喜歡你',
        message: '3 個新的喜歡等待你查看',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NotificationItem(
        id: '5',
        type: NotificationType.aiRecommendation,
        title: 'AI 推薦',
        message: '根據你的偏好，我們為你推薦了 5 個新的潛在配對',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: '6',
        type: NotificationType.weeklyInsight,
        title: '週報洞察',
        message: '你本週收到了 12 個喜歡，配對成功率提升了 25%！',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationItem(
        id: '7',
        type: NotificationType.promotional,
        title: 'Premium 特惠',
        message: '限時優惠！Premium 會員享受 50% 折扣，僅限今日',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationItem(
        id: '8',
        type: NotificationType.system,
        title: '系統更新',
        message: 'Amore 已更新至最新版本，體驗全新的配對算法！',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    state = notifications;
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
    state = state.map((notification) => notification.copyWith(isRead: true)).toList();
  }

  void deleteNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  void clearAll() {
    state = [];
  }
}

class NotificationHistoryPage extends ConsumerStatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  ConsumerState<NotificationHistoryPage> createState() => _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends ConsumerState<NotificationHistoryPage> {
  NotificationType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationHistoryProvider);
    final notifier = ref.read(notificationHistoryProvider.notifier);

    final filteredNotifications = _selectedFilter == null
        ? notifications
        : notifications.where((n) => n.type == _selectedFilter).toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('通知'),
            if (unreadCount > 0)
              Text(
                '$unreadCount 條未讀',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  notifier.markAllAsRead();
                  break;
                case 'clear_all':
                  _showClearAllDialog(notifier);
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/notification_settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 12),
                    Text('全部標為已讀'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('清空所有通知'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('通知設置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 篩選器
          _buildFilterChips(),
          
          // 通知列表
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification, notifier);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filterOptions = [
      {'type': null, 'label': '全部', 'icon': Icons.all_inclusive},
      {'type': NotificationType.match, 'label': '配對', 'icon': Icons.favorite},
      {'type': NotificationType.message, 'label': '消息', 'icon': Icons.chat_bubble},
      {'type': NotificationType.like, 'label': '喜歡', 'icon': Icons.thumb_up},
      {'type': NotificationType.aiRecommendation, 'label': 'AI', 'icon': Icons.psychology},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = _selectedFilter == option['type'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFFE91E63),
                  ),
                  const SizedBox(width: 6),
                  Text(option['label'] as String),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? option['type'] as NotificationType? : null;
                });
              },
              selectedColor: const Color(0xFFE91E63),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, NotificationHistoryNotifier notifier) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        notifier.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('通知已刪除'),
            action: SnackBarAction(
              label: '撤銷',
              onPressed: () {
                // 這裡可以實現撤銷功能
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead 
              ? null 
              : Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              notifier.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 通知圖標或頭像
                _buildNotificationIcon(notification),
                
                const SizedBox(width: 16),
                
                // 通知內容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 未讀指示器
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    if (notification.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(notification.imageUrl!),
      );
    }

    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Icons.favorite;
      case NotificationType.message:
        return Icons.chat_bubble;
      case NotificationType.like:
        return Icons.thumb_up;
      case NotificationType.superLike:
        return Icons.star;
      case NotificationType.aiRecommendation:
        return Icons.psychology;
      case NotificationType.weeklyInsight:
        return Icons.analytics;
      case NotificationType.promotional:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.system_update;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Colors.pink;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.like:
        return Colors.green;
      case NotificationType.superLike:
        return Colors.amber;
      case NotificationType.aiRecommendation:
        return Colors.purple;
      case NotificationType.weeklyInsight:
        return Colors.indigo;
      case NotificationType.promotional:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暫無通知',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '當有新的配對、消息或活動時\n我們會在這裡通知你',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // 根據通知類型導航到相應頁面
    switch (notification.type) {
      case NotificationType.match:
        if (notification.actionData != null) {
          // 導航到配對頁面或聊天頁面
          Navigator.pushNamed(context, '/chat', arguments: notification.actionData);
        }
        break;
      case NotificationType.message:
        if (notification.actionData != null) {
          // 導航到聊天頁面
          Navigator.pushNamed(context, '/chat', arguments: notification.actionData);
        }
        break;
      case NotificationType.like:
      case NotificationType.superLike:
        // 導航到喜歡我的頁面
        Navigator.pushNamed(context, '/likes');
        break;
      case NotificationType.aiRecommendation:
        // 導航到推薦頁面
        Navigator.pushNamed(context, '/recommendations');
        break;
      case NotificationType.weeklyInsight:
        // 導航到統計頁面
        Navigator.pushNamed(context, '/insights');
        break;
      case NotificationType.promotional:
        // 導航到 Premium 頁面
        Navigator.pushNamed(context, '/premium');
        break;
      case NotificationType.system:
        // 可能顯示更新詳情或不做任何操作
        break;
    }
  }

  void _showClearAllDialog(NotificationHistoryNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有通知'),
        content: const Text('確定要清空所有通知嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
} 