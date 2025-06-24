import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../ai/services/google_ai_service.dart';
import '../profile/photo_upload_service.dart';
import '../security/safety_service.dart';
import '../security/report_user_page.dart';
// 導入個人檔案頁面
import '../profile/enhanced_profile_page.dart';
// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 聊天狀態管理
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList());
});

final typingStatusProvider = StreamProvider.family<List<String>, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('typing')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => doc.id)
          .toList());
});

// 用戶兼容性信息模型
class UserCompatibilityInfo {
  final String mbtiType;
  final int compatibilityScore;
  final List<String> commonInterests;
  final String matchReason;

  UserCompatibilityInfo({
    required this.mbtiType,
    required this.compatibilityScore,
    required this.commonInterests,
    required this.matchReason,
  });
}

// 聊天消息模型
class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.metadata,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

enum MessageType {
  text,
  image,
  icebreaker,
  dateIdea,
  system,
}

// 破冰話題建議
class IcebreakerSuggestion {
  final String id;
  final String text;
  final String category;

  IcebreakerSuggestion({
    required this.id,
    required this.text,
    required this.category,
  });
}

// 模擬聊天數據
final sampleMessages = [
  ChatMessage(
    id: '1',
    senderId: 'other',
    content: '你好！很高興認識你 😊',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
    type: MessageType.text,
  ),
  ChatMessage(
    id: '2',
    senderId: 'me',
    content: '你好！我也很高興認識你',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
    type: MessageType.text,
  ),
  ChatMessage(
    id: '3',
    senderId: 'other',
    content: '我看到你的個人檔案很有趣，你平時喜歡做什麼？',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: true,
    type: MessageType.text,
  ),
  ChatMessage(
    id: '4',
    senderId: 'me',
    content: '我喜歡攝影和旅行，你呢？',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: true,
    type: MessageType.text,
  ),
];

// 破冰話題建議
final icebreakerSuggestions = [
  IcebreakerSuggestion(
    id: '1',
    text: '你最喜歡的旅行目的地是哪裡？',
    category: '旅行',
  ),
  IcebreakerSuggestion(
    id: '2',
    text: '週末你通常會做什麼？',
    category: '生活',
  ),
  IcebreakerSuggestion(
    id: '3',
    text: '你最近看了什麼好電影嗎？',
    category: '娛樂',
  ),
  IcebreakerSuggestion(
    id: '4',
    text: '你的興趣愛好是什麼？',
    category: '興趣',
  ),
];

class RealTimeChatPage extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final UserCompatibilityInfo? compatibilityInfo;

  const RealTimeChatPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    this.compatibilityInfo,
  });

  @override
  ConsumerState<RealTimeChatPage> createState() => _RealTimeChatPageState();
}

class _RealTimeChatPageState extends ConsumerState<RealTimeChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  late AnimationController _fabAnimationController;
  late AnimationController _icebreakerAnimationController;
  
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _icebreakerSlideAnimation;
  
  bool _showIcebreakers = false;
  bool _isTyping = false;
  bool _isUploading = false;
  List<String> _icebreakers = [];
  List<ChatMessage> _messages = List.from(sampleMessages);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _markMessagesAsRead();
    _loadIcebreakers();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _icebreakerAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _icebreakerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _icebreakerAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _icebreakerAnimationController.dispose();
    _setTypingStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final typingAsync = ref.watch(typingStatusProvider(widget.chatId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessagesList(messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('載入消息失敗: $error'),
              ),
            ),
          ),
          
          // 輸入狀態指示器
          typingAsync.when(
            data: (typingUsers) => _buildTypingIndicator(typingUsers),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // 破冰話題建議
          if (_showIcebreakers) _buildIcebreakersPanel(),
          
          // 消息輸入區域
          _buildMessageInput(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.small,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      title: Row(
        children: [
          // 用戶頭像（帶在線狀態）
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppShadows.small,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  backgroundImage: widget.otherUserPhoto != null
                      ? NetworkImage(widget.otherUserPhoto!)
                      : null,
                  child: widget.otherUserPhoto == null
                      ? Text(
                          widget.otherUserName[0].toUpperCase(),
                          style: AppTextStyles.h6.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              // 在線狀態指示器
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: AppShadows.small,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.otherUserName,
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // MBTI 兼容性分數
                    if (widget.compatibilityInfo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCompatibilityColor(widget.compatibilityInfo!.compatibilityScore).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCompatibilityColor(widget.compatibilityInfo!.compatibilityScore),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 12,
                              color: _getCompatibilityColor(widget.compatibilityInfo!.compatibilityScore),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.compatibilityInfo!.compatibilityScore}%',
                              style: AppTextStyles.caption.copyWith(
                                color: _getCompatibilityColor(widget.compatibilityInfo!.compatibilityScore),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '線上',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // MBTI 類型顯示
                    if (widget.compatibilityInfo != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.compatibilityInfo!.mbtiType,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.secondary,
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
      actions: [
        // 視頻通話按鈕
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.primary),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _startVideoCall();
            },
          ),
        ),
        // 語音通話按鈕
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.call, color: AppColors.primary),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _startAudioCall();
            },
          ),
        ),
        // 更多選項
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.small,
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: _handleMenuAction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('查看個人檔案'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'compatibility',
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('兼容性分析'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('封鎖用戶'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(Icons.report, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('舉報'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCompatibilityColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildMessagesList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
        final showAvatar = index == 0 || 
            messages[index - 1].senderId != message.senderId;
        
        return _buildMessageBubble(message, isMe, showAvatar);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '開始與 ${widget.otherUserName} 的對話',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '發送第一條消息來打破僵局！',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showIcebreakers = true;
              });
              _icebreakerAnimationController.forward();
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('獲取破冰話題'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool showAvatar) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            AppAvatar(
              imageUrl: widget.otherUserPhoto,
              name: widget.otherUserName,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (!isMe) ...[
            const SizedBox(width: 40),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe 
                          ? AppColors.primaryGradient
                          : null,
                      color: isMe 
                          ? null 
                          : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppBorderRadius.lg),
                        topRight: const Radius.circular(AppBorderRadius.lg),
                        bottomLeft: Radius.circular(isMe ? AppBorderRadius.lg : AppBorderRadius.xs),
                        bottomRight: Radius.circular(isMe ? AppBorderRadius.xs : AppBorderRadius.lg),
                      ),
                      boxShadow: isMe 
                          ? AppShadows.floating
                          : AppShadows.card,
                      border: !isMe 
                          ? Border.all(
                              color: AppColors.textTertiary.withOpacity(0.1),
                              width: 1,
                            )
                          : null,
                    ),
                    child: _buildMessageContent(message, isMe),
                  ),
                  const SizedBox(height: 4),
                  // 消息狀態和時間
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMe && message.type == MessageType.icebreaker)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lightbulb, size: 10, color: Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                '破冰',
                                style: AppTextStyles.overline.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? AppColors.primary : AppColors.textTertiary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: const Center(
                        child: AppLoadingIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: AppColors.textTertiary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '圖片載入失敗',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        );
      
      case MessageType.icebreaker:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMe 
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(
              color: isMe 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    size: 16,
                    color: isMe ? Colors.white : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '破冰話題',
                    style: AppTextStyles.caption.copyWith(
                      color: isMe ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      
      case MessageType.dateIdea:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMe 
                ? Colors.white.withOpacity(0.2)
                : Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(
              color: isMe 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 16,
                    color: isMe ? Colors.white : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '約會建議',
                    style: AppTextStyles.caption.copyWith(
                      color: isMe ? Colors.white : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      
      default:
        return Text(
          message.content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? Colors.white : AppColors.textPrimary,
          ),
        );
    }
  }

  Widget _buildTypingIndicator(List<String> typingUsers) {
    final otherUserTyping = typingUsers.contains(widget.otherUserId);
    
    if (!otherUserTyping) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: widget.otherUserPhoto != null
                ? NetworkImage(widget.otherUserPhoto!)
                : null,
            backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_fabAnimationController.value - delay).clamp(0.0, 1.0);
        final scale = 0.5 + (0.5 * animationValue);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcebreakersPanel() {
    return SlideTransition(
      position: _icebreakerSlideAnimation,
            child: Container(
        height: 200,
        margin: AppSpacing.pagePadding,
              decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.large,
          boxShadow: AppShadows.medium,
              ),
              child: Column(
                children: [
                  Container(
              padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.lg),
                  topRight: Radius.circular(AppBorderRadius.lg),
                      ),
                    ),
                    child: Row(
                      children: [
                  const Icon(
                            Icons.lightbulb,
                    color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                              Text(
                    'AI 破冰話題建議',
                                style: AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                                ),
                              ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.primary,
                            onPressed: () {
                              setState(() {
                                _showIcebreakers = false;
                              });
                      _icebreakerAnimationController.reverse();
                            },
                        ),
                      ],
                    ),
                  ),
                  
                              Expanded(
                                child: ListView.builder(
                padding: AppSpacing.cardPadding,
                itemCount: icebreakerSuggestions.length,
                                  itemBuilder: (context, index) {
                  final suggestion = icebreakerSuggestions[index];
                  return _buildIcebreakerItem(suggestion);
                                  },
                                ),
                              ),
                            ],
            ),
          ),
    );
  }

  Widget _buildIcebreakerItem(IcebreakerSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () => _sendIcebreaker(suggestion),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Text(
                suggestion.category,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                suggestion.text,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const Icon(
              Icons.send,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
        ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 附件按鈕
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: AppColors.primary,
              onPressed: _showAttachmentOptions,
            ),
            
            // 輸入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  border: Border.all(
                    color: AppColors.textTertiary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: '輸入消息...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.sm),
            
            // 發送按鈕
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                ),
                child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          FloatingActionButton.small(
            heroTag: 'icebreaker',
          onPressed: () {
            setState(() {
              _showIcebreakers = !_showIcebreakers;
            });
            if (_showIcebreakers) {
                _icebreakerAnimationController.forward();
            } else {
                _icebreakerAnimationController.reverse();
            }
          },
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.lightbulb_outline, color: Colors.white),
        ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.small(
            heroTag: 'camera',
            onPressed: _openCamera,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ],
      ),
    );
  }

  // 輔助方法
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }

  // 事件處理方法
  void _onTextChanged(String text) {
    final isTyping = text.isNotEmpty;
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      _setTypingStatus(isTyping);
    }
  }

  void _setTypingStatus(bool isTyping) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final typingRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('typing')
        .doc(currentUserId);

    if (isTyping) {
      typingRef.set({'timestamp': FieldValue.serverTimestamp()});
    } else {
      typingRef.delete();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _sendTextMessage(content);
    _messageController.clear();
    _setTypingStatus(false);
  }

  void _sendTextMessage(String content) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message.toMap());

    _scrollToBottom();
  }

  void _sendIcebreaker(IcebreakerSuggestion suggestion) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      content: suggestion.text,
      type: MessageType.icebreaker,
      timestamp: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message.toMap());

    setState(() {
      _showIcebreakers = false;
    });
    _icebreakerAnimationController.reverse();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: AppAnimations.fast,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _markMessagesAsRead() {
    // 實現標記消息為已讀的邏輯
  }

  void _loadIcebreakers() async {
    try {
      // 這裡可以根據用戶的 MBTI 和興趣生成個性化破冰話題
      final icebreakers = await GoogleAIService.generateIcebreakersWithGemini(
        userMBTI: 'ENFP', // 從用戶數據獲取
        partnerMBTI: 'INTJ', // 從對方數據獲取
        commonInterests: ['音樂', '旅行'], // 從共同興趣獲取
        count: 5,
      );
      
      setState(() {
        _icebreakers = icebreakers;
      });
    } catch (e) {
      // 使用備用破冰話題
      setState(() {
        _icebreakers = [
          '你最近有看什麼好看的電影嗎？',
          '你週末通常喜歡做什麼？',
          '你最喜歡的旅行目的地是哪裡？',
          '你有什麼特別的興趣愛好嗎？',
          '你最近學了什麼新技能嗎？',
        ];
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFFE91E63)),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFE91E63)),
              title: const Text('從相冊選擇'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        // 這裡應該上傳圖片到 Firebase Storage 並發送圖片消息
        _sendImageMessage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選擇圖片失敗: $e')),
      );
    }
  }

  void _sendImageMessage(String imagePath) async {
    try {
      setState(() {
        _isUploading = true;
      });

      // 上傳圖片到 Firebase Storage
      final imageFile = XFile(imagePath);
      final imageUrl = await PhotoUploadService.uploadChatImage(
        imageFile: imageFile,
        chatId: widget.chatId,
        onProgress: (progress) {
          // 可以在這裡顯示上傳進度
        },
      );

      // 發送圖片消息
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: '', // 圖片消息可以沒有文字內容
        type: MessageType.image,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(message.toMap());

      setState(() {
        _isUploading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送圖片失敗: $e')),
      );
    }
  }

  void _openCamera() {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('相機功能開發中...')),
      );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('視頻通話功能開發中...')),
    );
  }

  void _startAudioCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('語音通話功能開發中...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        _viewUserProfile();
        break;
      case 'block':
        _showBlockConfirmation();
        break;
      case 'report':
        _reportUser();
        break;
    }
  }

  void _viewUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedProfilePage(userId: widget.otherUserId),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('封鎖用戶'),
        content: Text('確定要封鎖 ${widget.otherUserName} 嗎？\n\n封鎖後：\n• 您將不會再收到對方的消息\n• 對方無法查看您的個人檔案\n• 您們的匹配關係將被移除'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('封鎖'),
          ),
        ],
      ),
    );
  }

  void _blockUser() async {
    try {
      await SafetyService.blockUser(
        blockedUserId: widget.otherUserId,
        reason: '從聊天中封鎖',
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已封鎖 ${widget.otherUserName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('封鎖失敗: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _reportUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportUserPage(
          reportedUserId: widget.otherUserId,
          reportedUserName: widget.otherUserName,
          chatId: widget.chatId,
        ),
      ),
    );
  }
} 