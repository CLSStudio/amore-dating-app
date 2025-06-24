import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIChatPage extends ConsumerStatefulWidget {
  const AIChatPage({super.key});

  @override
  ConsumerState<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends ConsumerState<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: '你好！我是 Amore AI 愛情顧問 💕\n\n我可以為你提供以下服務：\n• 破冰話題建議\n• 約會規劃建議\n• 對話技巧指導\n• 關係發展建議\n\n請告訴我你需要什麼幫助？',
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: [
          '我需要破冰話題',
          '約會地點建議',
          '如何開始對話',
          '關係進展建議',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 愛情顧問',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                Text(
                  '24/7 在線諮詢',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAIFeatures,
            icon: Icon(
              Icons.help_outline,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFFE91E63)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.suggestions?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.suggestions!.map((suggestion) {
                      return GestureDetector(
                        onTap: () => _sendMessage(suggestion),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE91E63).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: '輸入你的問題...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage(_messageController.text.trim());
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                  ),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // 模擬 AI 回應
    Future.delayed(const Duration(milliseconds: 1500), () {
      _generateAIResponse(text);
    });
  }

  void _generateAIResponse(String userMessage) {
    String aiResponse = '';
    List<String>? suggestions;

    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('破冰') || lowerMessage.contains('開始對話')) {
      aiResponse = '''基於你們的共同興趣，我推薦這些破冰話題：

🎵 **音樂話題**
"我看到你喜歡 [音樂類型]，有什麼推薦的歌手嗎？"

🏃‍♀️ **運動話題**  
"你平時喜歡什麼運動？我也在尋找運動夥伴呢！"

📱 **輕鬆話題**
"你的照片很有趣！那是在哪裡拍的？"

記住，真誠和好奇心是最好的破冰工具！''';
      
      suggestions = ['約會地點建議', '如何保持對話', '下一步怎麼做'];
    } else if (lowerMessage.contains('約會') || lowerMessage.contains('地點')) {
      aiResponse = '''根據香港的熱門約會地點，我為你推薦：

☕ **輕鬆第一次約會**
• 中環咖啡廳 - 輕鬆聊天環境
• 太古廣場 - 購物+用餐

🌅 **浪漫約會**
• 山頂纜車 - 欣賞夜景
• 星光大道 - 海邊散步

🎯 **互動式約會**
• 海洋公園 - 刺激有趣
• 密室逃脫 - 增進默契

選擇符合你們共同興趣的地點最重要！''';
      
      suggestions = ['對話技巧', '約會準備', '後續發展'];
    } else if (lowerMessage.contains('關係') || lowerMessage.contains('進展')) {
      aiResponse = '''關係發展需要循序漸進：

📅 **初期階段 (1-2週)**
• 保持規律但不過分的聯繫
• 分享日常生活片段
• 展現真實的自己

💕 **發展階段 (2-4週)**
• 安排面對面約會
• 深入了解對方價值觀
• 建立情感連接

🤝 **穩定階段 (1個月+)**
• 討論未來規劃
• 介紹給朋友圈
• 確立關係狀態

每個人的節奏不同，要尊重彼此的感受！''';
      
      suggestions = ['如何表達感情', '處理分歧', 'MBTI兼容性'];
    } else {
      aiResponse = '''我理解你的問題。作為 AI 愛情顧問，我建議：

💡 **個性化建議**
根據你的具體情況，我需要更多資訊來提供精準建議。

🎯 **通用原則**
• 保持真誠和開放的態度
• 聆聽比說話更重要
• 給對方時間和空間

📞 **進一步諮詢**
如果你有具體的情況想討論，請詳細描述，我會提供更有針對性的建議。''';
      
      suggestions = ['破冰話題建議', '約會規劃', '關係問題'];
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: suggestions,
        ),
      );
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAIFeatures() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                    'AI 愛情顧問功能',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.forum,
                    title: '破冰話題生成',
                    description: '基於共同興趣的個性化開場白',
                  ),
                  _buildFeatureItem(
                    icon: Icons.location_on,
                    title: '約會地點推薦',
                    description: '香港本地熱門約會場所建議',
                  ),
                  _buildFeatureItem(
                    icon: Icons.psychology,
                    title: '對話技巧指導',
                    description: '提升聊天技巧和溝通效果',
                  ),
                  _buildFeatureItem(
                    icon: Icons.favorite,
                    title: '關係發展建議',
                    description: '循序漸進的關係發展策略',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE91E63),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
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

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
} 