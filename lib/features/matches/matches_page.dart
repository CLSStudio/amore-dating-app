import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesPage extends ConsumerStatefulWidget {
  const MatchesPage({super.key});

  @override
  ConsumerState<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<MatchesPage> {
  final List<MatchItem> _matches = [
    MatchItem(
      name: 'Sarah',
      age: 25,
      avatar: 'https://picsum.photos/200/200?random=1',
      lastMessage: '你好！很高興認識你 😊',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isOnline: true,
      unreadCount: 2,
      compatibility: 92,
    ),
    MatchItem(
      name: 'Emma',
      age: 28,
      avatar: 'https://picsum.photos/200/200?random=2',
      lastMessage: '那個咖啡廳真的很棒！',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isOnline: false,
      unreadCount: 0,
      compatibility: 87,
    ),
    MatchItem(
      name: 'Lily',
      age: 26,
      avatar: 'https://picsum.photos/200/200?random=3',
      lastMessage: '週末想一起去瑜伽課嗎？',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isOnline: true,
      unreadCount: 1,
      compatibility: 78,
    ),
    MatchItem(
      name: 'Amy',
      age: 24,
      avatar: 'https://picsum.photos/200/200?random=4',
      lastMessage: '謝謝你分享的音樂！',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isOnline: false,
      unreadCount: 0,
      compatibility: 95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '我的配對',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showMatchFilters,
            icon: Icon(
              Icons.filter_list,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMatchStats(),
          Expanded(
            child: _buildMatchList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '總配對數',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_matches.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '新配對',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_matches.where((m) => m.unreadCount > 0).length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '在線',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_matches.where((m) => m.isOnline).length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _buildMatchItem(match);
      },
    );
  }

  Widget _buildMatchItem(MatchItem match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(match.avatar),
            ),
            if (match.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${match.name}, ${match.age}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCompatibilityColor(match.compatibility),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${match.compatibility}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              match.lastMessage,
              style: TextStyle(
                fontSize: 14,
                color: match.unreadCount > 0 
                    ? Colors.black87 
                    : Colors.grey.shade600,
                fontWeight: match.unreadCount > 0 
                    ? FontWeight.w500 
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(match.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (match.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${match.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _openChat(match),
      ),
    );
  }

  Color _getCompatibilityColor(int compatibility) {
    if (compatibility >= 90) {
      return Colors.green;
    } else if (compatibility >= 80) {
      return Colors.orange;
    } else {
      return Colors.red.withOpacity(0.8);
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
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _openChat(MatchItem match) {
    // 跳轉到聊天頁面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('開始與 ${match.name} 聊天'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMatchFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    '配對篩選',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.schedule, color: Color(0xFFE91E63)),
                    title: const Text('最近活躍'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.message, color: Color(0xFFE91E63)),
                    title: const Text('有新消息'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite, color: Color(0xFFE91E63)),
                    title: const Text('高配對度'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchItem {
  final String name;
  final int age;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  final bool isOnline;
  final int unreadCount;
  final int compatibility;

  MatchItem({
    required this.name,
    required this.age,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.isOnline,
    required this.unreadCount,
    required this.compatibility,
  });
} 