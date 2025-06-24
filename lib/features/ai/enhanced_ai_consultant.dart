import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// AI 諮詢類型
enum ConsultationType {
  relationship,
  communication,
  dating,
  conflict,
  personal,
}

// 建議卡片類型
enum SuggestionCardType {
  dating,
  communication,
  relationship,
  location,
  activity,
}

// AI 建議模型
class AISuggestion {
  final String id;
  final SuggestionCardType type;
  final String title;
  final String subtitle;
  final String content;
  final String? location;
  final String? imageUrl;
  final List<String> tags;
  final double confidence;
  final DateTime createdAt;
  final bool isPersonalized;

  AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.content,
    this.location,
    this.imageUrl,
    this.tags = const [],
    this.confidence = 0.8,
    required this.createdAt,
    this.isPersonalized = false,
  });
}

// 對話消息模型
class ConsultationMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ConsultationType? type;
  final List<AISuggestion>? suggestions;
  final bool isTyping;

  ConsultationMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type,
    this.suggestions,
    this.isTyping = false,
  });
}

// AI 諮詢狀態管理
final aiConsultantProvider = StateNotifierProvider<AIConsultantNotifier, AIConsultantState>((ref) {
  return AIConsultantNotifier();
});

class AIConsultantState {
  final List<ConsultationMessage> messages;
  final bool isTyping;
  final ConsultationType? currentType;
  final List<AISuggestion> personalizedSuggestions;
  final String? currentLocation;

  AIConsultantState({
    this.messages = const [],
    this.isTyping = false,
    this.currentType,
    this.personalizedSuggestions = const [],
    this.currentLocation = '香港',
  });

  AIConsultantState copyWith({
    List<ConsultationMessage>? messages,
    bool? isTyping,
    ConsultationType? currentType,
    List<AISuggestion>? personalizedSuggestions,
    String? currentLocation,
  }) {
    return AIConsultantState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      currentType: currentType ?? this.currentType,
      personalizedSuggestions: personalizedSuggestions ?? this.personalizedSuggestions,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class AIConsultantNotifier extends StateNotifier<AIConsultantState> {
  AIConsultantNotifier() : super(AIConsultantState()) {
    _initializeConsultation();
  }

  void _initializeConsultation() {
    final welcomeMessage = ConsultationMessage(
      id: 'welcome',
      content: '你好！我是 Amore AI 愛情顧問 💕\n\n我是專業的關係諮詢師，擁有豐富的心理學背景和約會指導經驗。我可以為你提供：\n\n• 個性化約會建議\n• 溝通技巧指導\n• 關係發展策略\n• 衝突解決方案\n\n請告訴我你目前遇到的情況，我會為你提供專業的建議。',
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: _getWelcomeSuggestions(),
    );

    state = state.copyWith(
      messages: [welcomeMessage],
      personalizedSuggestions: _generatePersonalizedSuggestions(),
    );
  }

  List<AISuggestion> _getWelcomeSuggestions() {
    return [
      AISuggestion(
        id: 'dating_advice',
        type: SuggestionCardType.dating,
        title: '約會建議',
        subtitle: '獲取個性化約會指導',
        content: '我需要約會建議',
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'communication_help',
        type: SuggestionCardType.communication,
        title: '溝通技巧',
        subtitle: '改善對話和表達',
        content: '如何更好地溝通',
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'relationship_guidance',
        type: SuggestionCardType.relationship,
        title: '關係指導',
        subtitle: '發展健康的關係',
        content: '關係發展建議',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<AISuggestion> _generatePersonalizedSuggestions() {
    return [
      AISuggestion(
        id: 'hk_dating_spots',
        type: SuggestionCardType.location,
        title: '香港約會聖地',
        subtitle: '精選本地約會地點',
        content: '中環海濱長廊 - 浪漫海景，適合黃昏散步',
        location: '中環',
        tags: ['浪漫', '海景', '散步'],
        confidence: 0.9,
        createdAt: DateTime.now(),
        isPersonalized: true,
      ),
      AISuggestion(
        id: 'weekend_activity',
        type: SuggestionCardType.activity,
        title: '週末約會活動',
        subtitle: '有趣的雙人活動',
        content: '太古廣場購物 + 咖啡廳聊天',
        location: '太古',
        tags: ['購物', '咖啡', '室內'],
        confidence: 0.85,
        createdAt: DateTime.now(),
        isPersonalized: true,
      ),
      AISuggestion(
        id: 'conversation_starter',
        type: SuggestionCardType.communication,
        title: '破冰話題',
        subtitle: '開啟有趣對話',
        content: '分享你最喜歡的香港美食',
        tags: ['破冰', '美食', '本地'],
        confidence: 0.8,
        createdAt: DateTime.now(),
        isPersonalized: true,
      ),
    ];
  }

  void sendMessage(String content) {
    final userMessage = ConsultationMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    _generateAIResponse(content);
  }

  void _generateAIResponse(String userInput) async {
    await Future.delayed(const Duration(seconds: 2));

    final aiResponse = _createAIResponse(userInput);
    
    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isTyping: false,
    );
  }

  ConsultationMessage _createAIResponse(String userInput) {
    final lowerInput = userInput.toLowerCase();
    
    String response;
    List<AISuggestion>? suggestions;
    ConsultationType? type;

    if (lowerInput.contains('約會') || lowerInput.contains('date')) {
      type = ConsultationType.dating;
      response = _getDatingAdvice();
      suggestions = _getDatingSuggestions();
    } else if (lowerInput.contains('溝通') || lowerInput.contains('聊天')) {
      type = ConsultationType.communication;
      response = _getCommunicationAdvice();
      suggestions = _getCommunicationSuggestions();
    } else if (lowerInput.contains('關係') || lowerInput.contains('感情')) {
      type = ConsultationType.relationship;
      response = _getRelationshipAdvice();
      suggestions = _getRelationshipSuggestions();
    } else if (lowerInput.contains('衝突') || lowerInput.contains('爭吵')) {
      type = ConsultationType.conflict;
      response = _getConflictAdvice();
      suggestions = _getConflictSuggestions();
    } else {
      type = ConsultationType.personal;
      response = _getPersonalAdvice(userInput);
      suggestions = _getGeneralSuggestions();
    }

    return ConsultationMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
      suggestions: suggestions,
    );
  }

  String _getDatingAdvice() {
    return '''作為你的愛情顧問，我建議你採用以下約會策略：

🎯 **約會前準備**
• 選擇舒適且有話題的環境
• 準備一些開放性問題
• 保持輕鬆愉快的心態

🌟 **香港約會推薦地點**
• 中環海濱長廊 - 浪漫海景
• 太古廣場 - 購物 + 美食
• 山頂纜車 - 經典香港體驗

💡 **約會技巧**
• 真誠地表達興趣
• 積極聆聽對方分享
• 適時分享自己的故事

記住，最好的約會是雙方都感到舒適和開心的。''';
  }

  String _getCommunicationAdvice() {
    return '''良好的溝通是關係成功的關鍵。以下是我的專業建議：

🗣️ **有效溝通技巧**
• 使用「我」語句表達感受
• 積極聆聽，不急於反駁
• 保持開放和好奇的心態

💬 **對話技巧**
• 問開放性問題
• 分享個人經歷和感受
• 給予正面回饋和鼓勵

🎭 **非語言溝通**
• 保持眼神接觸
• 開放的身體語言
• 適當的觸碰（在合適時機）

溝通是一門藝術，需要練習和耐心。''';
  }

  String _getRelationshipAdvice() {
    return '''建立健康關係需要時間和努力。我的專業建議：

💕 **關係發展階段**
• 初期：建立信任和了解
• 發展期：深化情感連結
• 穩定期：維持和成長

🔑 **關係成功要素**
• 相互尊重和理解
• 共同價值觀和目標
• 有效的衝突解決能力

🌱 **關係維護**
• 定期表達感謝和愛意
• 保持個人成長和獨立
• 創造共同美好回憶

每段關係都是獨特的，要根據具體情況調整策略。''';
  }

  String _getConflictAdvice() {
    return '''衝突是關係中的正常現象，關鍵是如何處理：

🕊️ **衝突解決步驟**
1. 冷靜下來，避免情緒化反應
2. 傾聽對方的觀點和感受
3. 表達自己的立場，不攻擊對方
4. 尋找共同點和解決方案

🛡️ **預防衝突**
• 定期溝通，不累積問題
• 設立健康的界限
• 學會妥協和讓步

🤝 **修復關係**
• 真誠道歉（如果有錯）
• 承諾改變行為
• 給彼此時間和空間

記住，衝突處理得當可以讓關係更加堅固。''';
  }

  String _getPersonalAdvice(String input) {
    return '''感謝你分享你的情況。作為專業的愛情顧問，我建議：

🎯 **個性化建議**
基於你的描述，我認為你需要：
• 更多的自信和自我肯定
• 清晰的關係目標和期望
• 適合的溝通策略

💪 **個人成長**
• 培養自己的興趣愛好
• 提升情商和社交技能
• 保持積極正面的心態

🌟 **行動計劃**
• 設定具體可行的目標
• 逐步實施改變
• 定期反思和調整

每個人的情況都不同，我會根據你的具體需求提供更精準的建議。''';
  }

  List<AISuggestion> _getDatingSuggestions() {
    return [
      AISuggestion(
        id: 'hk_romantic_spots',
        type: SuggestionCardType.location,
        title: '香港浪漫約會地點',
        subtitle: '精選浪漫場所',
        content: '山頂纜車 + 凌霄閣觀景台',
        location: '山頂',
        tags: ['浪漫', '夜景', '經典'],
        confidence: 0.95,
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'casual_dating',
        type: SuggestionCardType.activity,
        title: '輕鬆約會活動',
        subtitle: '減壓的約會方式',
        content: '海洋公園一日遊',
        location: '南區',
        tags: ['娛樂', '刺激', '一日遊'],
        confidence: 0.8,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<AISuggestion> _getCommunicationSuggestions() {
    return [
      AISuggestion(
        id: 'conversation_topics',
        type: SuggestionCardType.communication,
        title: '對話話題建議',
        subtitle: '有趣的聊天主題',
        content: '分享童年回憶和夢想',
        tags: ['深度對話', '個人分享'],
        confidence: 0.85,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<AISuggestion> _getRelationshipSuggestions() {
    return [
      AISuggestion(
        id: 'relationship_milestones',
        type: SuggestionCardType.relationship,
        title: '關係里程碑',
        subtitle: '重要的關係節點',
        content: '第一次見朋友的時機',
        tags: ['關係發展', '里程碑'],
        confidence: 0.9,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<AISuggestion> _getConflictSuggestions() {
    return [
      AISuggestion(
        id: 'conflict_resolution',
        type: SuggestionCardType.communication,
        title: '衝突解決技巧',
        subtitle: '和平解決分歧',
        content: '使用「我感到...」句式',
        tags: ['衝突解決', '溝通技巧'],
        confidence: 0.88,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<AISuggestion> _getGeneralSuggestions() {
    return [
      AISuggestion(
        id: 'self_improvement',
        type: SuggestionCardType.relationship,
        title: '個人提升',
        subtitle: '成為更好的自己',
        content: '培養新的興趣愛好',
        tags: ['自我提升', '個人成長'],
        confidence: 0.75,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void selectSuggestion(AISuggestion suggestion) {
    sendMessage(suggestion.content);
  }

  void setCurrentType(ConsultationType type) {
    state = state.copyWith(currentType: type);
  }
}

// 增強版 AI 諮詢頁面
class EnhancedAIConsultant extends ConsumerStatefulWidget {
  const EnhancedAIConsultant({super.key});

  @override
  ConsumerState<EnhancedAIConsultant> createState() => _EnhancedAIConsultantState();
}

class _EnhancedAIConsultantState extends ConsumerState<EnhancedAIConsultant>
    with TickerProviderStateMixin {
  
  late AnimationController _messageAnimationController;
  late AnimationController _suggestionAnimationController;
  late ScrollController _scrollController;
  
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController = ScrollController();
  }

  void _setupAnimations() {
    _messageAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _suggestionAnimationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _messageAnimationController.forward();
    _suggestionAnimationController.forward();
  }

  @override
  void dispose() {
    _messageAnimationController.dispose();
    _suggestionAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiConsultantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildProfessionalHeader(),
          Expanded(
            child: Row(
              children: [
                // 主要對話區域
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildMessagesList(state),
                      ),
                      _buildMessageInput(state),
                    ],
                  ),
                ),
                
                // 側邊建議面板
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      left: BorderSide(
                        color: AppColors.textTertiary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: _buildSuggestionsPanel(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          // AI 顧問頭像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Amore AI',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '專業愛情諮詢師 • 24/7 在線',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '在線中',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 專業認證標誌
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '認證',
                  style: AppTextStyles.overline.copyWith(
                    color: Colors.white,
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

  Widget _buildMessagesList(AIConsultantState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppSpacing.pagePadding,
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isTyping) {
          return _buildTypingIndicator();
        }
        
        final message = state.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ConsultationMessage message) {
    return AnimatedBuilder(
      animation: _messageAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _messageAnimationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(message.isUser ? 1.0 : -1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _messageAnimationController, curve: Curves.easeOutCubic),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser) ...[
                    _buildAvatarWidget(false),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: message.isUser 
                          ? CrossAxisAlignment.end 
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: AppSpacing.cardPadding,
                          decoration: BoxDecoration(
                            gradient: message.isUser
                                ? AppColors.primaryGradient
                                : null,
                            color: message.isUser 
                                ? null 
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                            boxShadow: AppShadows.medium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!message.isUser && message.type != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(message.type!).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                                  ),
                                  child: Text(
                                    _getTypeLabel(message.type!),
                                    style: AppTextStyles.overline.copyWith(
                                      color: _getTypeColor(message.type!),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              
                              Text(
                                message.content,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: message.isUser 
                                      ? Colors.white 
                                      : AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        Text(
                          _formatTime(message.timestamp),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        
                        // 建議卡片
                        if (message.suggestions != null && message.suggestions!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.md),
                            child: _buildSuggestionCards(message.suggestions!),
                          ),
                      ],
                    ),
                  ),
                  
                  if (message.isUser) ...[
                    const SizedBox(width: AppSpacing.md),
                    _buildAvatarWidget(true),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget(bool isUser) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: isUser 
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
              ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: AppShadows.medium,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildSuggestionCards(List<AISuggestion> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 建議選項',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(aiConsultantProvider.notifier).selectSuggestion(suggestion);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSuggestionIcon(suggestion.type),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      suggestion.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          _buildAvatarWidget(false),
          const SizedBox(width: AppSpacing.md),
          
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.medium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dr. Amore 正在輸入',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(AIConsultantState state) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.textTertiary.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: AppColors.textTertiary.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: '描述你的情況，我會提供專業建議...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: AppSpacing.cardPadding,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.medium,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: state.isTyping ? null : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsPanel(AIConsultantState state) {
    return Column(
      children: [
        // 面板標題
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: AppColors.textTertiary.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '個性化建議',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        // 建議列表
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.cardPadding,
            itemCount: state.personalizedSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = state.personalizedSuggestions[index];
              return _buildSuggestionCard(suggestion);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(AISuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(aiConsultantProvider.notifier).selectSuggestion(suggestion);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSuggestionTypeColor(suggestion.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    _getSuggestionIcon(suggestion.type),
                    size: 20,
                    color: _getSuggestionTypeColor(suggestion.type),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        suggestion.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (suggestion.isPersonalized)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      '個性化',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Text(
              suggestion.content,
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.4,
              ),
            ),
            
            if (suggestion.location != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suggestion.location!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            
            if (suggestion.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: suggestion.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: AppSpacing.sm),
            
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '信心度 ${(suggestion.confidence * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ConsultationType type) {
    switch (type) {
      case ConsultationType.dating:
        return AppColors.primary;
      case ConsultationType.communication:
        return AppColors.info;
      case ConsultationType.relationship:
        return AppColors.secondary;
      case ConsultationType.conflict:
        return AppColors.warning;
      case ConsultationType.personal:
        return AppColors.success;
    }
  }

  String _getTypeLabel(ConsultationType type) {
    switch (type) {
      case ConsultationType.dating:
        return '約會建議';
      case ConsultationType.communication:
        return '溝通指導';
      case ConsultationType.relationship:
        return '關係諮詢';
      case ConsultationType.conflict:
        return '衝突解決';
      case ConsultationType.personal:
        return '個人成長';
    }
  }

  IconData _getSuggestionIcon(SuggestionCardType type) {
    switch (type) {
      case SuggestionCardType.dating:
        return Icons.favorite;
      case SuggestionCardType.communication:
        return Icons.chat_bubble_outline;
      case SuggestionCardType.relationship:
        return Icons.people;
      case SuggestionCardType.location:
        return Icons.location_on;
      case SuggestionCardType.activity:
        return Icons.local_activity;
    }
  }

  Color _getSuggestionTypeColor(SuggestionCardType type) {
    switch (type) {
      case SuggestionCardType.dating:
        return AppColors.primary;
      case SuggestionCardType.communication:
        return AppColors.info;
      case SuggestionCardType.relationship:
        return AppColors.secondary;
      case SuggestionCardType.location:
        return AppColors.success;
      case SuggestionCardType.activity:
        return AppColors.warning;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${difference.inDays} 天前';
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      ref.read(aiConsultantProvider.notifier).sendMessage(content);
      _messageController.clear();
      
      // 滾動到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.medium,
          curve: Curves.easeOut,
        );
      });
    }
  }
} 