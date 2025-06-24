import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/dating/modes/dating_mode_system.dart';
import '../models/mode_profile.dart';
import '../../models/user_model.dart';

/// 🎯 Amore 內容過濾服務
/// 為三大核心模式提供差異化的內容管理和過濾功能
class ContentFilterService {
  static final ContentFilterService _instance = ContentFilterService._internal();
  factory ContentFilterService() => _instance;
  ContentFilterService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📝 根據模式過濾Story內容
  Future<List<StoryContent>> filterStoriesForMode(
    DatingMode mode, 
    String userId,
    {int limit = 20}
  ) async {
    try {
      Query query = _firestore
          .collection('stories')
          .where('targetModes', arrayContains: mode.toString())
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      final stories = snapshot.docs
          .map((doc) => StoryContent.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // 根據模式進行二次過濾
      return await _applyModeSpecificFiltering(stories, mode, userId);
    } catch (e) {
      print('Error filtering stories: $e');
      return [];
    }
  }

  /// 🔍 探索內容推薦
  Future<List<ExploreContent>> getExploreContentForMode(
    DatingMode mode,
    String userId,
    {int limit = 10}
  ) async {
    switch (mode) {
      case DatingMode.serious:
        return await _getSeriousExploreContent(userId, limit: limit);
      case DatingMode.explore:
        return await _getGeneralExploreContent(userId, limit: limit);
      case DatingMode.passion:
        return await _getPassionExploreContent(userId, limit: limit);
    }
  }

  /// 🎯 認真交往模式探索內容
  Future<List<ExploreContent>> _getSeriousExploreContent(
    String userId, 
    {int limit = 10}
  ) async {
    final userProfile = await _getUserProfile(userId);
    
    return [
      ExploreContent(
        id: 'serious_values_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.valueAssessment,
        title: '深度價值觀評估',
        description: '完善你的價值觀檔案，找到真正契合的另一半',
        content: _generateValueAssessmentContent(userProfile),
        priority: 10,
        estimatedTime: '15分鐘',
        benefits: ['提高匹配精準度', '深入了解自己', '吸引同頻率的人'],
      ),
      ExploreContent(
        id: 'serious_goals_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.lifeGoalPlanning,
        title: '未來規劃討論',
        description: '分享你的人生目標，找到同路人',
        content: _generateLifeGoalContent(userProfile),
        priority: 9,
        estimatedTime: '10分鐘',
        benefits: ['找到有共同目標的伴侶', '明確關係期望', '建立深度連結'],
      ),
      ExploreContent(
        id: 'serious_mbti_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.personalityInsight,
        title: 'MBTI深度匹配',
        description: '探索你的性格類型如何影響戀愛關係',
        content: _generateMBTIInsightContent(userProfile),
        priority: 8,
        estimatedTime: '12分鐘',
        benefits: ['了解性格互補', '避免常見衝突', '建立和諧關係'],
      ),
      ExploreContent(
        id: 'serious_communication_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.communicationSkill,
        title: '深度溝通技巧',
        description: '學習如何進行有意義的對話',
        content: _generateCommunicationContent(),
        priority: 7,
        estimatedTime: '8分鐘',
        benefits: ['提升對話品質', '建立情感連結', '減少誤解'],
      ),
    ];
  }

  /// 🌟 探索模式探索內容
  Future<List<ExploreContent>> _getGeneralExploreContent(
    String userId,
    {int limit = 10}
  ) async {
    final userProfile = await _getUserProfile(userId);
    
    return [
      ExploreContent(
        id: 'explore_interests_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.interestDiscovery,
        title: '興趣探索之旅',
        description: '發現新興趣，擴展你的社交圈',
        content: _generateInterestDiscoveryContent(userProfile),
        priority: 10,
        estimatedTime: '10分鐘',
        benefits: ['發現新愛好', '遇見同好', '豐富生活體驗'],
      ),
      ExploreContent(
        id: 'explore_activities_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.activityRecommendation,
        title: '香港活動推薦',
        description: '探索香港有趣的社交活動和約會地點',
        content: _generateActivityRecommendationContent(),
        priority: 9,
        estimatedTime: '5分鐘',
        benefits: ['發現新景點', '創造約會話題', '豐富約會體驗'],
      ),
      ExploreContent(
        id: 'explore_personality_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.personalityTest,
        title: '性格特質探索',
        description: '了解你的社交風格和偏好',
        content: _generatePersonalityTestContent(),
        priority: 8,
        estimatedTime: '12分鐘',
        benefits: ['了解自己', '改善社交技巧', '吸引合適的人'],
      ),
      ExploreContent(
        id: 'explore_social_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.socialSkill,
        title: '社交技能提升',
        description: '掌握輕鬆自然的交友技巧',
        content: _generateSocialSkillContent(),
        priority: 7,
        estimatedTime: '8分鐘',
        benefits: ['提升魅力', '減少緊張感', '建立自信'],
      ),
    ];
  }

  /// 🔥 激情模式探索內容
  Future<List<ExploreContent>> _getPassionExploreContent(
    String userId,
    {int limit = 10}
  ) async {
    final userProfile = await _getUserProfile(userId);
    
    return [
      ExploreContent(
        id: 'passion_nearby_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.locationBased,
        title: '附近即時連結',
        description: '發現身邊有趣的人和即時約會機會',
        content: _generateNearbyContent(userProfile),
        priority: 10,
        estimatedTime: '即時',
        benefits: ['即時匹配', '減少等待', '抓住機會'],
      ),
      ExploreContent(
        id: 'passion_venues_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.venueRecommendation,
        title: '熱門約會場所',
        description: '探索香港最適合即時約會的地點',
        content: _generateVenueRecommendationContent(),
        priority: 9,
        estimatedTime: '3分鐘',
        benefits: ['快速決定地點', '氣氛佳', '便於交通'],
      ),
      ExploreContent(
        id: 'passion_safety_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.safetyTips,
        title: '安全約會指南',
        description: '享受自由的同時保護自己',
        content: _generateSafetyTipsContent(),
        priority: 8,
        estimatedTime: '5分鐘',
        benefits: ['保障安全', '增加信心', '享受自由'],
      ),
      ExploreContent(
        id: 'passion_communication_${DateTime.now().millisecondsSinceEpoch}',
        type: ExploreContentType.directCommunication,
        title: '直接溝通技巧',
        description: '學會清晰表達需求和界限',
        content: _generateDirectCommunicationContent(),
        priority: 7,
        estimatedTime: '6分鐘',
        benefits: ['避免誤解', '建立信任', '享受過程'],
      ),
    ];
  }

  /// 🔄 模式專屬過濾邏輯
  Future<List<StoryContent>> _applyModeSpecificFiltering(
    List<StoryContent> stories, 
    DatingMode mode,
    String userId
  ) async {
    final userProfile = await _getUserProfile(userId);
    
    return stories.where((story) {
      switch (mode) {
        case DatingMode.serious:
          return _isSuitableForSeriousMode(story, userProfile);
        case DatingMode.explore:
          return _isSuitableForExploreMode(story, userProfile);
        case DatingMode.passion:
          return _isSuitableForPassionMode(story, userProfile);
      }
    }).toList();
  }

  /// 🎯 認真交往模式內容適合性檢查
  bool _isSuitableForSeriousMode(StoryContent story, UserModel userProfile) {
    // 檢查內容是否適合認真交往模式
    final seriousKeywords = [
      '價值觀', '人生目標', '未來規劃', '家庭', '責任', '承諾',
      '深度', '成長', '穩定', '真誠', '長期', '婚姻'
    ];
    
    final inappropriateKeywords = [
      '一夜情', '約炮', '玩玩', '隨便', '刺激'
    ];
    
    // 正面關鍵字加分
    bool hasPositiveKeywords = seriousKeywords.any((keyword) => 
        story.content.contains(keyword) || story.title.contains(keyword));
    
    // 負面關鍵字扣分
    bool hasNegativeKeywords = inappropriateKeywords.any((keyword) => 
        story.content.contains(keyword) || story.title.contains(keyword));
    
    return hasPositiveKeywords && !hasNegativeKeywords;
  }

  /// 🌟 探索模式內容適合性檢查
  bool _isSuitableForExploreMode(StoryContent story, UserModel userProfile) {
    // 探索模式適合各種內容類型
    final exploreKeywords = [
      '嘗試', '探索', '發現', '體驗', '學習', '成長',
      '興趣', '活動', '冒險', '新鮮', '多元', '開放'
    ];
    
    return exploreKeywords.any((keyword) => 
        story.content.contains(keyword) || 
        story.title.contains(keyword) ||
        story.hashtags.any((tag) => tag.contains(keyword)));
  }

  /// 🔥 激情模式內容適合性檢查
  bool _isSuitableForPassionMode(StoryContent story, UserModel userProfile) {
    final passionKeywords = [
      '即時', '現在', '附近', '當下', '直接', '坦率',
      '自由', '釋放', '激情', '熱情', '大膽', '真實'
    ];
    
    final inappropriateKeywords = [
      '承諾', '永遠', '結婚', '家庭', '責任'
    ];
    
    bool hasPositiveKeywords = passionKeywords.any((keyword) => 
        story.content.contains(keyword) || story.title.contains(keyword));
    
    bool hasNegativeKeywords = inappropriateKeywords.any((keyword) => 
        story.content.contains(keyword) || story.title.contains(keyword));
    
    return hasPositiveKeywords && !hasNegativeKeywords;
  }

  /// 👤 獲取用戶檔案
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel.empty(); // 返回空用戶模型
    } catch (e) {
      print('Error getting user profile: $e');
      return UserModel.empty();
    }
  }

  /// 生成內容的輔助方法
  Map<String, dynamic> _generateValueAssessmentContent(UserModel user) {
    return {
      'questions': [
        {
          'question': '在關係中，什麼對你最重要？',
          'options': ['忠誠與信任', '共同成長', '相互支持', '深度溝通'],
          'type': 'multiple_choice'
        },
        {
          'question': '你理想的未來包含什麼？',
          'options': ['穩定的家庭', '事業發展', '環遊世界', '個人成長'],
          'type': 'multiple_choice'
        },
      ],
      'estimated_time': 15,
      'result_insights': '根據你的答案，我們會為你推薦價值觀相符的人選'
    };
  }

  Map<String, dynamic> _generateLifeGoalContent(UserModel user) {
    return {
      'categories': [
        {
          'category': '事業發展',
          'questions': ['你的職業規劃是什麼？', '工作對你的意義？'],
        },
        {
          'category': '家庭規劃',
          'questions': ['你希望何時建立家庭？', '對孩子的想法？'],
        },
      ],
    };
  }

  Map<String, dynamic> _generateMBTIInsightContent(UserModel user) {
    return {
      'mbti_analysis': {
        'energy': '你從哪裡獲得能量？',
        'information': '你如何處理資訊？',
        'decisions': '你如何做決定？',
        'lifestyle': '你偏好什麼樣的生活方式？',
      },
      'compatibility_tips': '根據你的MBTI類型，我們會分析你與不同類型人的相容性'
    };
  }

  Map<String, dynamic> _generateCommunicationContent() {
    return {
      'techniques': [
        {
          'name': '主動聆聽',
          'description': '真正聽懂對方的話',
          'tips': ['保持眼神接觸', '問開放性問題', '重複確認理解']
        },
        {
          'name': '表達感受',
          'description': '誠實分享你的感受',
          'tips': ['使用"我"陳述', '避免指責', '表達需求']
        },
      ]
    };
  }

  Map<String, dynamic> _generateInterestDiscoveryContent(UserModel user) {
    return {
      'interest_categories': [
        '戶外活動', '藝術文化', '美食探索', '科技數碼',
        '健身運動', '音樂娛樂', '閱讀學習', '旅行探險'
      ],
      'discovery_method': '通過簡單的測試發現你可能喜歡但還沒嘗試過的興趣'
    };
  }

  Map<String, dynamic> _generateActivityRecommendationContent() {
    return {
      'hong_kong_activities': [
        {
          'name': '維港夜景欣賞',
          'location': '尖沙咀海傍',
          'type': '浪漫約會',
          'cost': '免費',
          'suitable_for': ['第一次約會', '情侶約會']
        },
        {
          'name': '藝術空間探索',
          'location': '中環PMQ',
          'type': '文化體驗',
          'cost': '中等',
          'suitable_for': ['有共同興趣', '深度交流']
        },
      ]
    };
  }

  Map<String, dynamic> _generatePersonalityTestContent() {
    return {
      'test_dimensions': [
        '外向性 vs 內向性',
        '開放性 vs 保守性',
        '隨和性 vs 競爭性',
        '責任性 vs 自由性'
      ],
      'result_application': '了解你的性格特質如何影響你的交友和約會方式'
    };
  }

  Map<String, dynamic> _generateSocialSkillContent() {
    return {
      'skills': [
        {
          'skill': '破冰技巧',
          'description': '自然開始對話',
          'examples': ['讚美對方的選擇', '分享有趣的觀察', '詢問開放性問題']
        },
        {
          'skill': '維持對話',
          'description': '讓聊天持續下去',
          'examples': ['找共同話題', '分享個人經歷', '問後續問題']
        },
      ]
    };
  }

  Map<String, dynamic> _generateNearbyContent(UserModel user) {
    return {
      'live_updates': true,
      'radius_km': 5,
      'active_users': '根據你的位置顯示附近活躍用戶',
      'instant_matching': '即時配對功能，快速找到有興趣的人'
    };
  }

  Map<String, dynamic> _generateVenueRecommendationContent() {
    return {
      'venue_types': [
        {
          'type': '咖啡廳',
          'examples': ['中環IFC咖啡廳', '銅鑼灣時代廣場星巴克'],
          'benefits': '輕鬆氣氛，適合聊天'
        },
        {
          'type': '酒吧',
          'examples': ['蘭桂坊', '諾士佛台'],
          'benefits': '晚間社交，氣氛活躍'
        },
      ]
    };
  }

  Map<String, dynamic> _generateSafetyTipsContent() {
    return {
      'safety_guidelines': [
        '首次見面選擇公共場所',
        '告知朋友你的行程',
        '保持清醒的判斷力',
        '相信你的直覺',
        '準備好離開的方式'
      ],
      'emergency_contacts': '緊急聯絡方式和求助資源'
    };
  }

  Map<String, dynamic> _generateDirectCommunicationContent() {
    return {
      'communication_principles': [
        {
          'principle': '明確表達需求',
          'description': '直接說出你想要什麼',
          'example': '我希望我們能...'
        },
        {
          'principle': '設定界限',
          'description': '清楚說明你的底線',
          'example': '我不太舒服...'
        },
      ]
    };
  }
}

/// 📝 Story內容模型
class StoryContent {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> hashtags;
  final List<String> targetModes;
  final DateTime createdAt;
  final bool isActive;
  final int viewCount;
  final int likeCount;

  const StoryContent({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.hashtags,
    required this.targetModes,
    required this.createdAt,
    required this.isActive,
    this.viewCount = 0,
    this.likeCount = 0,
  });

  static StoryContent fromMap(Map<String, dynamic> map) {
    return StoryContent(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      targetModes: List<String>.from(map['targetModes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'hashtags': hashtags,
      'targetModes': targetModes,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'viewCount': viewCount,
      'likeCount': likeCount,
    };
  }
}

/// 🔍 探索內容模型
class ExploreContent {
  final String id;
  final ExploreContentType type;
  final String title;
  final String description;
  final Map<String, dynamic> content;
  final int priority;
  final String estimatedTime;
  final List<String> benefits;

  const ExploreContent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.content,
    required this.priority,
    required this.estimatedTime,
    required this.benefits,
  });
}

/// 🎯 探索內容類型
enum ExploreContentType {
  valueAssessment,
  lifeGoalPlanning,
  personalityInsight,
  communicationSkill,
  interestDiscovery,
  activityRecommendation,
  personalityTest,
  socialSkill,
  locationBased,
  venueRecommendation,
  safetyTips,
  directCommunication,
} 