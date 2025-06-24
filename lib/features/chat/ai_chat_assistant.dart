import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// AI 建議類型
enum AISuggestionType {
  icebreaker,      // 破冰話題
  conversation,    // 對話建議
  dateIdea,        // 約會建議
  response,        // 回覆建議
  timing,          // 時機建議
  relationship,    // 關係進展建議
}

// AI 建議模型
class AISuggestion {
  final String id;
  final AISuggestionType type;
  final String title;
  final String content;
  final String reasoning;
  final double confidence;
  final List<String> tags;
  final DateTime createdAt;
  final bool isUsed;

  AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.reasoning,
    this.confidence = 0.8,
    this.tags = const [],
    required this.createdAt,
    this.isUsed = false,
  });

  AISuggestion copyWith({
    String? id,
    AISuggestionType? type,
    String? title,
    String? content,
    String? reasoning,
    double? confidence,
    List<String>? tags,
    DateTime? createdAt,
    bool? isUsed,
  }) {
    return AISuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      reasoning: reasoning ?? this.reasoning,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

// 對話上下文分析
class ConversationContext {
  final List<String> recentMessages;
  final Map<String, int> topicFrequency;
  final double sentimentScore;
  final int messageCount;
  final Duration conversationLength;
  final String lastMessageSender;
  final DateTime lastMessageTime;
  final List<String> mentionedInterests;
  final bool hasAskedQuestion;
  final bool hasSharedPersonalInfo;

  ConversationContext({
    this.recentMessages = const [],
    this.topicFrequency = const {},
    this.sentimentScore = 0.5,
    this.messageCount = 0,
    this.conversationLength = Duration.zero,
    this.lastMessageSender = '',
    required this.lastMessageTime,
    this.mentionedInterests = const [],
    this.hasAskedQuestion = false,
    this.hasSharedPersonalInfo = false,
  });
}

// AI 聊天助手服務
class AIChatAssistant {
  // 破冰話題生成
  static List<AISuggestion> generateIcebreakers({
    required UserProfile currentUser,
    required UserProfile targetUser,
    int count = 5,
  }) {
    List<AISuggestion> suggestions = [];
    
    // 基於共同興趣的破冰話題
    Set<String> commonInterests = currentUser.interests.toSet()
        .intersection(targetUser.interests.toSet());
    
    if (commonInterests.isNotEmpty) {
      for (String interest in commonInterests.take(2)) {
        suggestions.add(_createIcebreakerFromInterest(interest, targetUser));
      }
    }

    // 基於 MBTI 的破冰話題
    suggestions.add(_createMBTIIcebreaker(currentUser.mbtiType, targetUser.mbtiType));

    // 基於職業的破冰話題
    suggestions.add(_createProfessionIcebreaker(targetUser.profession));

    // 基於地理位置的破冰話題
    suggestions.add(_createLocationIcebreaker(targetUser.location));

    return suggestions.take(count).toList();
  }

  // 對話建議生成
  static List<AISuggestion> generateConversationSuggestions({
    required ConversationContext context,
    required UserProfile currentUser,
    required UserProfile targetUser,
    int count = 3,
  }) {
    List<AISuggestion> suggestions = [];

    // 分析對話狀態
    if (context.messageCount < 5) {
      // 初期對話建議
      suggestions.addAll(_generateEarlyConversationSuggestions(targetUser));
    } else if (context.messageCount < 20) {
      // 中期對話建議
      suggestions.addAll(_generateMidConversationSuggestions(context, targetUser));
    } else {
      // 深度對話建議
      suggestions.addAll(_generateDeepConversationSuggestions(context, targetUser));
    }

    // 基於情感分析的建議
    if (context.sentimentScore > 0.7) {
      suggestions.add(_createPositiveMomentumSuggestion());
    } else if (context.sentimentScore < 0.3) {
      suggestions.add(_createConversationRecoverySuggestion());
    }

    return suggestions.take(count).toList();
  }

  // 約會建議生成
  static List<AISuggestion> generateDateIdeas({
    required UserProfile currentUser,
    required UserProfile targetUser,
    required ConversationContext context,
    String? budget,
    String? timeOfDay,
    int count = 5,
  }) {
    List<AISuggestion> suggestions = [];

    // 基於共同興趣的約會建議
    Set<String> commonInterests = currentUser.interests.toSet()
        .intersection(targetUser.interests.toSet());

    for (String interest in commonInterests.take(3)) {
      suggestions.add(_createInterestBasedDateIdea(interest, targetUser.location, budget));
    }

    // 基於 MBTI 的約會建議
    suggestions.add(_createMBTIBasedDateIdea(
      currentUser.mbtiType, 
      targetUser.mbtiType, 
      targetUser.location
    ));

    // 基於對話內容的約會建議
    if (context.mentionedInterests.isNotEmpty) {
      suggestions.add(_createContextBasedDateIdea(
        context.mentionedInterests.first,
        targetUser.location
      ));
    }

    return suggestions.take(count).toList();
  }

  // 回覆建議生成
  static List<AISuggestion> generateResponseSuggestions({
    required String lastMessage,
    required UserProfile targetUser,
    required ConversationContext context,
    int count = 3,
  }) {
    List<AISuggestion> suggestions = [];

    // 分析最後一條消息的類型
    if (_isQuestion(lastMessage)) {
      suggestions.addAll(_generateQuestionResponses(lastMessage, targetUser));
    } else if (_isPersonalShare(lastMessage)) {
      suggestions.addAll(_generateEmpathyResponses(lastMessage, targetUser));
    } else if (_isCompliment(lastMessage)) {
      suggestions.addAll(_generateComplimentResponses(lastMessage));
    } else {
      suggestions.addAll(_generateGeneralResponses(lastMessage, targetUser));
    }

    return suggestions.take(count).toList();
  }

  // 時機建議
  static AISuggestion? generateTimingSuggestion({
    required ConversationContext context,
    required UserProfile targetUser,
  }) {
    // 建議約會的時機
    if (context.messageCount > 15 && 
        context.sentimentScore > 0.6 && 
        context.hasSharedPersonalInfo) {
      return AISuggestion(
        id: 'timing_date_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.timing,
        title: '約會時機建議',
        content: '現在是提出約會的好時機！你們已經建立了良好的對話基礎。',
        reasoning: '基於對話長度、情感分析和個人信息分享程度的綜合評估',
        confidence: 0.85,
        tags: ['約會', '時機'],
        createdAt: DateTime.now(),
      );
    }

    // 建議深入對話的時機
    if (context.messageCount > 8 && !context.hasAskedQuestion) {
      return AISuggestion(
        id: 'timing_question_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.timing,
        title: '提問時機建議',
        content: '可以問一些更深入的問題來了解 ${targetUser.name}。',
        reasoning: '對話已經進行一段時間，但缺乏深度互動',
        confidence: 0.75,
        tags: ['提問', '深度對話'],
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  // 關係進展建議
  static List<AISuggestion> generateRelationshipAdvice({
    required ConversationContext context,
    required UserProfile currentUser,
    required UserProfile targetUser,
    int count = 2,
  }) {
    List<AISuggestion> suggestions = [];

    // 基於對話進展的建議
    if (context.messageCount > 30 && context.sentimentScore > 0.7) {
      suggestions.add(AISuggestion(
        id: 'relationship_progress_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.relationship,
        title: '關係進展建議',
        content: '你們的對話很順利！考慮分享更多個人故事或計劃一次約會。',
        reasoning: '高質量的長期對話表明良好的兼容性',
        confidence: 0.8,
        tags: ['關係進展', '約會'],
        createdAt: DateTime.now(),
      ));
    }

    // 基於 MBTI 兼容性的建議
    double mbtiCompatibility = _calculateMBTICompatibility(
      currentUser.mbtiType, 
      targetUser.mbtiType
    );
    
    if (mbtiCompatibility > 0.8) {
      suggestions.add(AISuggestion(
        id: 'mbti_advice_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.relationship,
        title: 'MBTI 兼容性洞察',
        content: '你們的性格類型非常互補！${_getMBTIAdvice(currentUser.mbtiType, targetUser.mbtiType)}',
        reasoning: '基於 MBTI 兼容性分析',
        confidence: 0.85,
        tags: ['MBTI', '兼容性'],
        createdAt: DateTime.now(),
      ));
    }

    return suggestions.take(count).toList();
  }

  // 私有輔助方法

  static AISuggestion _createIcebreakerFromInterest(String interest, UserProfile targetUser) {
    Map<String, List<String>> interestQuestions = {
      '旅行': [
        '我看到你也喜歡旅行！最近有什麼特別想去的地方嗎？',
        '你的旅行照片看起來很棒！有什麼難忘的旅行經歷可以分享嗎？',
        '作為旅行愛好者，你更喜歡自由行還是跟團？'
      ],
      '攝影': [
        '我也對攝影很感興趣！你最喜歡拍什麼類型的照片？',
        '你的攝影作品一定很棒！有什麼攝影技巧可以分享嗎？',
        '最近有發現什麼好的攝影地點嗎？'
      ],
      '音樂': [
        '我們都喜歡音樂！你最近在聽什麼歌？',
        '你會演奏樂器嗎？我很好奇你的音樂品味！',
        '有沒有特別喜歡的音樂類型或歌手？'
      ],
      '運動': [
        '看到你也喜歡運動！你平常都做什麼運動？',
        '我們可以一起運動！你最喜歡的運動是什麼？',
        '你有什麼保持運動習慣的秘訣嗎？'
      ],
      '美食': [
        '我們都是美食愛好者！你最喜歡什麼料理？',
        '有什麼推薦的餐廳嗎？我也很愛探索美食！',
        '你會自己下廚嗎？最拿手的菜是什麼？'
      ],
    };

    List<String> questions = interestQuestions[interest] ?? [
      '我看到你也喜歡$interest！能跟我分享一下嗎？'
    ];

    String selectedQuestion = questions[math.Random().nextInt(questions.length)];

    return AISuggestion(
      id: 'icebreaker_${interest}_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.icebreaker,
      title: '基於共同興趣：$interest',
      content: selectedQuestion,
      reasoning: '你們都對$interest感興趣，這是很好的對話起點',
      confidence: 0.9,
      tags: [interest, '共同興趣'],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createMBTIIcebreaker(String userMBTI, String targetMBTI) {
    Map<String, String> mbtiQuestions = {
      'ENFP': '你看起來很有創意！最近有什麼新的想法或計劃嗎？',
      'INTJ': '我很好奇你對未來的規劃，你有什麼長期目標嗎？',
      'ESFP': '你的生活看起來很精彩！最近有什麼有趣的經歷嗎？',
      'ISFJ': '你給人很溫暖的感覺，你平常喜歡怎麼放鬆？',
      'ENTP': '你一定有很多有趣的想法！最近在思考什麼問題？',
      'ISTJ': '你看起來很可靠！你是怎麼保持這麼好的生活節奏的？',
    };

    String question = mbtiQuestions[targetMBTI] ?? '你的性格很有趣！能跟我分享一下你的想法嗎？';

    return AISuggestion(
      id: 'mbti_icebreaker_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.icebreaker,
      title: '基於性格類型',
      content: question,
      reasoning: '基於$targetMBTI性格特點設計的開場白',
      confidence: 0.8,
      tags: ['MBTI', '性格'],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createProfessionIcebreaker(String profession) {
    Map<String, String> professionQuestions = {
      '攝影師': '攝影師的工作一定很有趣！你最喜歡拍攝什麼主題？',
      '軟體工程師': '程式設計的世界很神奇！你最近在開發什麼有趣的項目嗎？',
      '瑜伽教練': '瑜伽教練真的很棒！你是怎麼開始接觸瑜伽的？',
      '主廚': '主廚的工作一定很有創意！你最拿手的料理是什麼？',
      '藝術家': '藝術家的世界很精彩！你最近在創作什麼作品？',
    };

    String question = professionQuestions[profession] ?? 
        '你的工作聽起來很有趣！能跟我分享一下嗎？';

    return AISuggestion(
      id: 'profession_icebreaker_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.icebreaker,
      title: '基於職業背景',
      content: question,
      reasoning: '基於對方的職業背景設計的開場白',
      confidence: 0.75,
      tags: ['職業', profession],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createLocationIcebreaker(String location) {
    Map<String, String> locationQuestions = {
      '香港島': '你在香港島住了多久？有什麼私房景點推薦嗎？',
      '九龍': '九龍有很多好地方！你最喜歡九龍的哪個區域？',
      '新界': '新界的環境很不錯！你喜歡那裡的生活節奏嗎？',
    };

    String question = locationQuestions[location] ?? 
        '你在$location住得習慣嗎？有什麼推薦的地方？';

    return AISuggestion(
      id: 'location_icebreaker_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.icebreaker,
      title: '基於地理位置',
      content: question,
      reasoning: '基於地理位置的本地化開場白',
      confidence: 0.7,
      tags: ['地理位置', location],
      createdAt: DateTime.now(),
    );
  }

  static List<AISuggestion> _generateEarlyConversationSuggestions(UserProfile targetUser) {
    return [
      AISuggestion(
        id: 'early_conv_1_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '了解興趣愛好',
        content: '你平常都喜歡做什麼？我很好奇你的興趣愛好！',
        reasoning: '初期對話適合了解基本興趣',
        confidence: 0.8,
        tags: ['興趣', '初期對話'],
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'early_conv_2_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '分享生活方式',
        content: '你的週末通常怎麼過？我也想分享一下我的生活！',
        reasoning: '了解生活方式有助於建立連結',
        confidence: 0.75,
        tags: ['生活方式', '週末'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<AISuggestion> _generateMidConversationSuggestions(
    ConversationContext context, 
    UserProfile targetUser
  ) {
    return [
      AISuggestion(
        id: 'mid_conv_1_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '深入了解價值觀',
        content: '你覺得什麼對你來說最重要？我很想了解你的想法。',
        reasoning: '中期對話適合探討更深層的話題',
        confidence: 0.8,
        tags: ['價值觀', '深度對話'],
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'mid_conv_2_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '分享個人經歷',
        content: '有什麼經歷對你影響很大嗎？我也有一些想分享的故事。',
        reasoning: '分享個人經歷能增進彼此了解',
        confidence: 0.75,
        tags: ['個人經歷', '故事分享'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<AISuggestion> _generateDeepConversationSuggestions(
    ConversationContext context, 
    UserProfile targetUser
  ) {
    return [
      AISuggestion(
        id: 'deep_conv_1_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '探討未來規劃',
        content: '你對未來有什麼期待？我們可以聊聊彼此的夢想。',
        reasoning: '深度對話階段適合討論未來規劃',
        confidence: 0.85,
        tags: ['未來規劃', '夢想'],
        createdAt: DateTime.now(),
      ),
      AISuggestion(
        id: 'deep_conv_2_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.conversation,
        title: '討論關係觀念',
        content: '你覺得什麼樣的關係是理想的？我很好奇你的想法。',
        reasoning: '了解關係觀念對建立深度連結很重要',
        confidence: 0.8,
        tags: ['關係觀念', '理想關係'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static AISuggestion _createPositiveMomentumSuggestion() {
    return AISuggestion(
      id: 'positive_momentum_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.conversation,
      title: '保持積極氛圍',
      content: '你們的對話很愉快！可以考慮分享更多有趣的經歷或計劃見面。',
      reasoning: '對話氛圍積極，適合進一步發展',
      confidence: 0.9,
      tags: ['積極氛圍', '進展'],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createConversationRecoverySuggestion() {
    return AISuggestion(
      id: 'recovery_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.conversation,
      title: '重新點燃對話',
      content: '可以嘗試問一個開放性問題或分享一個有趣的故事來重新點燃對話。',
      reasoning: '對話氛圍需要改善',
      confidence: 0.7,
      tags: ['對話恢復', '重新開始'],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createInterestBasedDateIdea(String interest, String location, String? budget) {
    Map<String, Map<String, String>> dateIdeas = {
      '旅行': {
        '香港島': '可以一起探索太平山頂或中環的文化景點',
        '九龍': '尖沙咀海濱長廊散步，欣賞維港夜景',
        '新界': '到大埔或沙田的公園享受自然風光',
      },
      '攝影': {
        '香港島': '到中環或銅鑼灣拍攝城市風光',
        '九龍': '在尖沙咀文化中心附近拍攝建築',
        '新界': '到郊野公園拍攝自然風景',
      },
      '美食': {
        '香港島': '探索中環或灣仔的特色餐廳',
        '九龍': '到旺角或油麻地品嚐地道美食',
        '新界': '尋找新界的隱藏美食寶藏',
      },
    };

    String idea = dateIdeas[interest]?[location] ?? '根據你們的共同興趣安排一次特別的約會';

    return AISuggestion(
      id: 'date_idea_${interest}_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.dateIdea,
      title: '基於$interest的約會建議',
      content: idea,
      reasoning: '基於你們的共同興趣$interest設計',
      confidence: 0.85,
      tags: [interest, '約會', location],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createMBTIBasedDateIdea(String userMBTI, String targetMBTI, String location) {
    // 基於 MBTI 類型的約會建議邏輯
    bool isIntrovert = targetMBTI.startsWith('I');
    bool isFeeling = targetMBTI.contains('F');
    
    String idea;
    if (isIntrovert && isFeeling) {
      idea = '安靜的咖啡廳或書店，適合深度對話';
    } else if (!isIntrovert && isFeeling) {
      idea = '有趣的市集或文化活動，能夠互動交流';
    } else if (isIntrovert && !isFeeling) {
      idea = '博物館或展覽，可以理性討論';
    } else {
      idea = '戶外活動或運動，充滿活力';
    }

    return AISuggestion(
      id: 'mbti_date_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.dateIdea,
      title: '基於性格的約會建議',
      content: idea,
      reasoning: '基於$targetMBTI性格特點設計',
      confidence: 0.8,
      tags: ['MBTI', '約會', targetMBTI],
      createdAt: DateTime.now(),
    );
  }

  static AISuggestion _createContextBasedDateIdea(String mentionedInterest, String location) {
    return AISuggestion(
      id: 'context_date_${DateTime.now().millisecondsSinceEpoch}',
      type: AISuggestionType.dateIdea,
      title: '基於對話內容的約會建議',
      content: '既然你們聊到了$mentionedInterest，可以安排相關的活動！',
      reasoning: '基於對話中提到的興趣',
      confidence: 0.75,
      tags: [mentionedInterest, '對話內容', '約會'],
      createdAt: DateTime.now(),
    );
  }

  // 消息分析輔助方法
  static bool _isQuestion(String message) {
    return message.contains('?') || message.contains('？') || 
           message.contains('嗎') || message.contains('呢');
  }

  static bool _isPersonalShare(String message) {
    List<String> personalKeywords = ['我', '我的', '我覺得', '我想', '我喜歡', '我不喜歡'];
    return personalKeywords.any((keyword) => message.contains(keyword));
  }

  static bool _isCompliment(String message) {
    List<String> complimentKeywords = ['很棒', '很好', '很美', '很帥', '很有趣', '很聰明'];
    return complimentKeywords.any((keyword) => message.contains(keyword));
  }

  static List<AISuggestion> _generateQuestionResponses(String question, UserProfile targetUser) {
    return [
      AISuggestion(
        id: 'question_response_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.response,
        title: '回答問題並反問',
        content: '先回答問題，然後問一個相關的問題來延續對話',
        reasoning: '問答互動是建立對話的好方法',
        confidence: 0.8,
        tags: ['問答', '互動'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<AISuggestion> _generateEmpathyResponses(String share, UserProfile targetUser) {
    return [
      AISuggestion(
        id: 'empathy_response_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.response,
        title: '表達理解和共鳴',
        content: '表達你的理解，並分享類似的經歷或感受',
        reasoning: '共鳴能夠建立情感連結',
        confidence: 0.85,
        tags: ['共鳴', '情感連結'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<AISuggestion> _generateComplimentResponses(String compliment) {
    return [
      AISuggestion(
        id: 'compliment_response_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.response,
        title: '優雅地接受讚美',
        content: '謝謝對方的讚美，並給予真誠的回讚',
        reasoning: '適當的回應讚美能增進好感',
        confidence: 0.8,
        tags: ['讚美', '回應'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<AISuggestion> _generateGeneralResponses(String message, UserProfile targetUser) {
    return [
      AISuggestion(
        id: 'general_response_${DateTime.now().millisecondsSinceEpoch}',
        type: AISuggestionType.response,
        title: '延續對話',
        content: '基於對方的消息，提出相關的話題或問題',
        reasoning: '保持對話的連續性',
        confidence: 0.7,
        tags: ['對話延續'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static double _calculateMBTICompatibility(String userMBTI, String targetMBTI) {
    // 簡化的 MBTI 兼容性計算
    if (userMBTI == targetMBTI) return 0.8;
    
    Map<String, List<String>> highCompatibility = {
      'INTJ': ['ENFP', 'ENTP'],
      'ENFP': ['INTJ', 'INFJ'],
      'INFJ': ['ENFP', 'ENTP'],
      'ENTP': ['INTJ', 'INFJ'],
    };
    
    if (highCompatibility[userMBTI]?.contains(targetMBTI) == true) {
      return 0.9;
    }
    
    return 0.6;
  }

  static String _getMBTIAdvice(String userMBTI, String targetMBTI) {
    Map<String, Map<String, String>> advice = {
      'INTJ': {
        'ENFP': '你的理性思維和對方的創意熱情能夠很好地互補',
        'ENTP': '你們都喜歡深度思考，但表達方式不同，這很有趣',
      },
      'ENFP': {
        'INTJ': '你的熱情能夠激發對方的創意，而對方的穩定能平衡你的活力',
        'INFJ': '你們都重視深度連結和個人成長',
      },
    };
    
    return advice[userMBTI]?[targetMBTI] ?? '你們的性格類型有很好的互補性';
  }
}

// 用戶檔案模型（如果需要的話）
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String mbtiType;
  final int compatibilityScore;
  final String location;
  final String profession;
  final List<String> values;
  final bool isVerified;
  final String distance;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.mbtiType,
    required this.compatibilityScore,
    required this.location,
    required this.profession,
    required this.values,
    this.isVerified = false,
    this.distance = '2 公里',
  });
} 