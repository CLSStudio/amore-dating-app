import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_service.dart';
import '../../core/firebase_config.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _showIcebreakers = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // 標記消息為已讀
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatServiceProvider).markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('載入消息失敗: ${snapshot.error}'),
                  );
                }
                
                final messages = snapshot.data ?? [];
                
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
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          
          // AI 破冰話題區域
          if (_showIcebreakers) _buildIcebreakersSection(),
          
          // 輸入區域
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Row(
        children: [
          // 用戶頭像
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.otherUserPhoto != null
                ? CachedNetworkImageProvider(widget.otherUserPhoto!)
                : null,
            backgroundColor: Colors.pink[300],
            child: widget.otherUserPhoto == null
                ? Text(
                    widget.otherUserName.isNotEmpty 
                        ? widget.otherUserName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // 用戶名稱
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '在線',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // AI 助手按鈕
        IconButton(
          icon: Icon(
            Icons.psychology,
            color: _showIcebreakers ? Colors.pink : Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _showIcebreakers = !_showIcebreakers;
            });
            if (_showIcebreakers) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          tooltip: 'AI 破冰話題',
        ),
        
        // 更多選項
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'report':
                _showReportDialog();
                break;
              case 'block':
                _showBlockDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('舉報'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('封鎖'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '開始對話吧！',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '發送第一條消息來打破僵局',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          
          // 快速破冰按鈕
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showIcebreakers = true;
              });
              _animationController.forward();
            },
            icon: const Icon(Icons.psychology),
            label: const Text('AI 破冰話題'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
    final isIcebreaker = message.type == MessageType.icebreaker;
    final isDateIdea = message.type == MessageType.dateIdea;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUserPhoto != null
                  ? CachedNetworkImageProvider(widget.otherUserPhoto!)
                  : null,
              backgroundColor: Colors.pink[300],
              child: widget.otherUserPhoto == null
                  ? Text(
                      widget.otherUserName.isNotEmpty 
                          ? widget.otherUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          // 消息氣泡
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe 
                    ? Colors.pink 
                    : isIcebreaker || isDateIdea
                        ? Colors.blue[50]
                        : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isIcebreaker || isDateIdea
                    ? Border.all(color: Colors.blue[200]!, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 特殊消息類型標籤
                  if (isIcebreaker) ...[
                    Row(
                      children: [
                        Icon(Icons.psychology, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          'AI 破冰話題',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (isDateIdea) ...[
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.pink[600]),
                        const SizedBox(width: 4),
                        Text(
                          '約會建議',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // 消息內容
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  // 時間戳
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe 
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) ...[
            const SizedBox(width: 8),
            // 已讀狀態
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcebreakersSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(
            top: BorderSide(color: Colors.blue[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'AI 破冰話題建議',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showIcebreakers = false;
                    });
                    _animationController.reverse();
                  },
                  child: const Text('收起'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 破冰話題列表
            FutureBuilder<List<IcebreakerSuggestion>>(
              future: ref.read(chatServiceProvider).generateIcebreakers(
                otherUserId: widget.otherUserId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Text('載入失敗: ${snapshot.error}');
                }
                
                final suggestions = snapshot.data ?? [];
                
                return Column(
                  children: suggestions.map((suggestion) => 
                    _buildIcebreakerCard(suggestion)
                  ).toList(),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // 約會建議按鈕
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _generateDateIdeas,
                icon: const Icon(Icons.favorite),
                label: const Text('生成約會建議'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  side: const BorderSide(color: Colors.pink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcebreakerCard(IcebreakerSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _sendIcebreaker(suggestion),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.content,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.send,
                color: Colors.blue[600],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          // 輸入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '輸入消息...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 發送按鈕
          Container(
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(chatServiceProvider).sendMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUserId,
        content: content,
      );
      
      _messageController.clear();
      
      // 滾動到底部
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendIcebreaker(IcebreakerSuggestion suggestion) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(chatServiceProvider).sendMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUserId,
        content: suggestion.content,
        type: MessageType.icebreaker,
        metadata: {
          'category': suggestion.category,
          'tags': suggestion.tags,
          'relevanceScore': suggestion.relevanceScore,
        },
      );
      
      // 隱藏破冰話題區域
      setState(() {
        _showIcebreakers = false;
      });
      _animationController.reverse();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('破冰話題已發送！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateDateIdeas() async {
    try {
      final dateIdeas = await ref.read(chatServiceProvider).generateDateIdeas(
        otherUserId: widget.otherUserId,
      );
      
      if (dateIdeas.isNotEmpty) {
        final selectedIdea = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('約會建議'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: dateIdeas.map((idea) => 
                ListTile(
                  title: Text(idea),
                  onTap: () => Navigator.of(context).pop(idea),
                )
              ).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ],
          ),
        );
        
        if (selectedIdea != null) {
          await ref.read(chatServiceProvider).sendMessage(
            chatId: widget.chatId,
            receiverId: widget.otherUserId,
            content: selectedIdea,
            type: MessageType.dateIdea,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成約會建議失敗: $e')),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('舉報用戶'),
        content: const Text('您確定要舉報這個用戶嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(chatServiceProvider).reportChat(
                chatId: widget.chatId,
                reason: '不當行為',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('舉報已提交')),
              );
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('封鎖用戶'),
        content: const Text('封鎖後您將無法收到此用戶的消息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 實現封鎖功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('用戶已封鎖')),
              );
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
} 