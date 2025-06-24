import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 導入聊天頁面
import 'real_time_chat_page.dart';
import '../ai/pages/conversation_analysis_page.dart';

// 聊天數據模型
class ChatItem {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;

  ChatItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
  });
}

// 模擬聊天數據
final sampleChats = [
  ChatItem(
    id: '1',
    name: '小雅',
    avatar: '👩‍🦰',
    lastMessage: '你好！很高興認識你 😊 我看到你也喜歡攝影，有什麼推薦的拍攝地點嗎？',
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 3,
    isOnline: true,
    isTyping: false,
  ),
  ChatItem(
    id: '2',
    name: '志明',
    avatar: '👨‍💻',
    lastMessage: '週末想一起看電影嗎？我知道一家很棒的電影院',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 1,
    isOnline: false,
    isTyping: false,
  ),
  ChatItem(
    id: '3',
    name: '美玲',
    avatar: '🧘‍♀️',
    lastMessage: '今天的瑜伽課很棒！你也應該來試試',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 0,
    isOnline: true,
    isTyping: true,
  ),
  ChatItem(
    id: '4',
    name: '建華',
    avatar: '👨‍🍳',
    lastMessage: '我做了你喜歡的意大利麵，下次一起做菜吧！',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
    isOnline: false,
    isTyping: false,
  ),
  ChatItem(
    id: '5',
    name: '詩婷',
    avatar: '👩‍🎨',
    lastMessage: '謝謝你的讚美！我的新畫作完成了',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 2,
    isOnline: true,
    isTyping: false,
  ),
];

class EnhancedChatListPage extends ConsumerWidget {
  const EnhancedChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildAIAnalysisCard(context),
          Expanded(
            child: _buildChatList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppBorderRadius.bottomOnly,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '💬 聊天',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => _showSearchDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationAnalysisPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisCard(BuildContext context) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: AppCard(
        backgroundColor: AppColors.primary.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 對話分析',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '深度分析聊天內容，了解對方真心度',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureItem(
                    Icons.favorite_border,
                    '真心度分析',
                    '評估對方誠意',
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.compare,
                    '對象比較',
                    '找出最佳匹配',
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.chat_bubble_outline,
                    '對話模式',
                    '分析溝通風格',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: '開始分析',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationAnalysisPage(),
                ),
              ),
              isFullWidth: true,
              icon: Icons.analytics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChatList(BuildContext context) {
    if (sampleChats.isEmpty) {
      return const AppEmptyState(
        icon: Icons.chat_bubble_outline,
        title: '暫時沒有聊天記錄',
        subtitle: '開始配對後就可以聊天了',
        actionText: '開始探索',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: sampleChats.length,
      itemBuilder: (context, index) {
        return _buildChatItem(context, sampleChats[index]);
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatItem chat) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _openChat(context, chat),
      child: Row(
        children: [
          // 頭像
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    chat.avatar,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              
              // 在線狀態
              if (chat.isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // 聊天信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      chat.name,
                      style: AppTextStyles.h6,
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(chat.lastMessageTime),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: chat.isTyping
                          ? Row(
                              children: [
                                Text(
                                  '正在輸入',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              chat.lastMessage,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: chat.unreadCount > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else {
      return '${difference.inDays}天前';
    }
  }

  void _openChat(BuildContext context, ChatItem chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealTimeChatPage(
          chatId: chat.id,
          otherUserId: chat.id,
          otherUserName: chat.name,
          otherUserPhoto: null, // 使用 emoji 作為頭像
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: const Text('搜索聊天'),
        content: const AppTextField(
          hint: '輸入姓名或消息內容...',
          prefixIcon: Icons.search,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          AppButton(
            text: '搜索',
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
} 