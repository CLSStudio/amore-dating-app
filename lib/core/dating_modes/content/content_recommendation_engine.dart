import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/dating/modes/dating_mode_system.dart';
import '../../models/user_model.dart';

/// 🚀 Amore 內容推薦引擎
/// 為三大核心模式提供個人化內容推薦和管理
class ContentRecommendationEngine {
  static final ContentRecommendationEngine _instance = ContentRecommendationEngine._internal();
  factory ContentRecommendationEngine() => _instance;
  ContentRecommendationEngine._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🎯 獲取模式專屬內容推薦
  Future<List<ContentRecommendation>> getRecommendationsForMode(
    DatingMode mode,
    String userId,
    {int limit = 10}
  ) async {
    switch (mode) {
      case DatingMode.serious:
        return await _getSeriousContentRecommendations(userId, limit: limit);
      case DatingMode.explore:
        return await _getExploreContentRecommendations(userId, limit: limit);
      case DatingMode.passion:
        return await _getPassionContentRecommendations(userId, limit: limit);
    }
  }

  /// 💬 獲取模式專屬聊天建議
  Future<List<ChatSuggestion>> getChatSuggestionsForMode(
    DatingMode mode,
    String userId,
    String matchId,
    {String? context}
  ) async {
    final userProfile = await _getUserProfile(userId);
    final matchProfile = await _getUserProfile(matchId);
    
    switch (mode) {
      case DatingMode.serious:
        return await _getSeriousChatSuggestions(userProfile, matchProfile, context);
      case DatingMode.explore:
        return await _getExploreChatSuggestions(userProfile, matchProfile, context);
      case DatingMode.passion:
        return await _getPassionChatSuggestions(userProfile, matchProfile, context);
    }
  }

  /// 🎯 認真交往模式內容推薦
  Future<List<ContentRecommendation>> _getSeriousContentRecommendations(
    String userId,
    {int limit = 10}
  ) async {
    return [
      ContentRecommendation(
        id: 'serious_values_center',
        type: ContentType.interactive,
        title: '價值觀匹配中心',
        description: '深入了解你的核心價值觀，找到真正契合的伴侶',
        content: {
          'type': 'value_assessment',
          'core_values': ['家庭價值', '事業理念', '金錢觀念', '生活方式'],
        },
        priority: 10,
        targetAudience: [DatingMode.serious],
      ),
      ContentRecommendation(
        id: 'serious_relationship_roadmap',
        type: ContentType.guidance,
        title: '關係發展路線圖',
        description: '專業指導如何建立穩定長久的關係',
        content: {
          'type': 'relationship_stages',
          'stages': ['初次認識期', '深入了解期', '確立關係期'],
        },
        priority: 9,
        targetAudience: [DatingMode.serious],
      ),
    ];
  }

  /// 🌟 探索模式內容推薦
  Future<List<ContentRecommendation>> _getExploreContentRecommendations(
    String userId,
    {int limit = 10}
  ) async {
    return [
      ContentRecommendation(
        id: 'explore_activity_community',
        type: ContentType.community,
        title: '活動興趣社區',
        description: '根據你的興趣找到同好，參與有趣的活動',
        content: {
          'type': 'activity_community',
          'categories': ['戶外探險', '文化藝術', '美食體驗'],
        },
        priority: 10,
        targetAudience: [DatingMode.explore],
      ),
    ];
  }

  /// 🔥 激情模式內容推薦
  Future<List<ContentRecommendation>> _getPassionContentRecommendations(
    String userId,
    {int limit = 10}
  ) async {
    return [
      ContentRecommendation(
        id: 'passion_live_map',
        type: ContentType.realtime,
        title: '即時地圖介面',
        description: '發現附近的即時連結機會',
        content: {
          'type': 'live_map',
          'features': ['即時活躍用戶', '熱門聚集地', '即時邀請'],
        },
        priority: 10,
        targetAudience: [DatingMode.passion],
      ),
    ];
  }

  /// 💬 認真交往模式聊天建議
  Future<List<ChatSuggestion>> _getSeriousChatSuggestions(
    UserModel user,
    UserModel match,
    String? context,
  ) async {
    return [
      ChatSuggestion(
        type: ChatSuggestionType.icebreaker,
        category: '價值觀探索',
        text: '看到你的檔案提到興趣愛好，我也很感興趣！什麼讓你開始喜歡這個的？',
        explanation: '基於共同興趣開始深度對話',
        appropriateTime: 'conversation_start',
      ),
    ];
  }

  /// 🌟 探索模式聊天建議
  Future<List<ChatSuggestion>> _getExploreChatSuggestions(
    UserModel user,
    UserModel match,
    String? context,
  ) async {
    return [
      ChatSuggestion(
        type: ChatSuggestionType.playful,
        category: '輕鬆互動',
        text: '我們來玩個小遊戲：說出一個你從未嘗試過但很想試的活動！',
        explanation: '通過遊戲了解對方的興趣和冒險精神',
        appropriateTime: 'conversation_start',
      ),
    ];
  }

  /// 🔥 激情模式聊天建議
  Future<List<ChatSuggestion>> _getPassionChatSuggestions(
    UserModel user,
    UserModel match,
    String? context,
  ) async {
    return [
      ChatSuggestion(
        type: ChatSuggestionType.direct,
        category: '直接表達',
        text: '你的能量很吸引我，有興趣現在出來喝杯咖啡嗎？',
        explanation: '直接表達興趣和即時見面意願',
        appropriateTime: 'immediate_connection',
      ),
    ];
  }

  /// 輔助方法
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel.empty();
    } catch (e) {
      print('Error getting user profile: $e');
      return UserModel.empty();
    }
  }
}

/// 📋 內容推薦模型
class ContentRecommendation {
  final String id;
  final ContentType type;
  final String title;
  final String description;
  final Map<String, dynamic> content;
  final int priority;
  final List<DatingMode> targetAudience;

  const ContentRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.content,
    required this.priority,
    required this.targetAudience,
  });
}

/// 🎯 內容類型
enum ContentType {
  interactive,
  guidance,
  skill,
  community,
  assessment,
  realtime,
  location,
}

/// 💬 聊天建議模型
class ChatSuggestion {
  final ChatSuggestionType type;
  final String category;
  final String text;
  final String explanation;
  final String appropriateTime;

  const ChatSuggestion({
    required this.type,
    required this.category,
    required this.text,
    required this.explanation,
    required this.appropriateTime,
  });
}

/// 💬 聊天建議類型
enum ChatSuggestionType {
  icebreaker,
  deepening,
  emotional,
  playful,
  activity,
  direct,
  location,
}

/// 🎯 價值觀匹配中心相關模型
class ValueMatchingCenter {
  final List<CoreValue> coreValues;

  const ValueMatchingCenter({required this.coreValues});
}

class CoreValue {
  final String name;
  final String description;
  final List<String> questions;
  final double weight;

  const CoreValue({
    required this.name,
    required this.description,
    required this.questions,
    required this.weight,
  });
}

/// 📍 關係發展路線圖相關模型
class RelationshipRoadmap {
  final List<RelationshipStage> stages;

  const RelationshipRoadmap({required this.stages});
}

class RelationshipStage {
  final String name;
  final String duration;
  final List<String> objectives;
  final List<String> activities;
  final List<String> milestones;

  const RelationshipStage({
    required this.name,
    required this.duration,
    required this.objectives,
    required this.activities,
    required this.milestones,
  });
}

/// 💬 對話技巧相關模型
class ConversationSkills {
  final List<ConversationTechnique> techniques;

  const ConversationSkills({required this.techniques});
}

class ConversationTechnique {
  final String name;
  final String description;
  final List<String> examples;
  final String whenToUse;

  const ConversationTechnique({
    required this.name,
    required this.description,
    required this.examples,
    required this.whenToUse,
  });
}

/// 🏃 活動社區相關模型
class ActivityCommunity {
  final List<ActivityCategory> categories;

  const ActivityCommunity({required this.categories});
}

class ActivityCategory {
  final String name;
  final String description;
  final List<CommunityActivity> activities;
  final List<String> tags;

  const ActivityCategory({
    required this.name,
    required this.description,
    required this.activities,
    required this.tags,
  });
}

class CommunityActivity {
  final String name;
  final String location;
  final DateTime datetime;
  final int participants;
  final int maxParticipants;
  final String organizer;
  final String difficulty;
  final String description;

  const CommunityActivity({
    required this.name,
    required this.location,
    required this.datetime,
    required this.participants,
    required this.maxParticipants,
    required this.organizer,
    required this.difficulty,
    required this.description,
  });
}

/// 🧠 性格探索相關模型
class PersonalityDiscovery {
  final List<PersonalityAssessment> assessments;

  const PersonalityDiscovery({required this.assessments});
}

class PersonalityAssessment {
  final String name;
  final String description;
  final List<AssessmentQuestion> questions;
  final String resultInsights;

  const PersonalityAssessment({
    required this.name,
    required this.description,
    required this.questions,
    required this.resultInsights,
  });
}

class AssessmentQuestion {
  final String question;
  final List<String> options;
  final String category;

  const AssessmentQuestion({
    required this.question,
    required this.options,
    required this.category,
  });
}

/// 🗺️ 即時地圖介面相關模型
class LiveMapInterface {
  final List<MapFeature> features;
  final List<String> safetyFeatures;

  const LiveMapInterface({
    required this.features,
    required this.safetyFeatures,
  });
}

class MapFeature {
  final String name;
  final String description;
  final double radius;
  final Duration updateInterval;

  const MapFeature({
    required this.name,
    required this.description,
    required this.radius,
    required this.updateInterval,
  });
}

/// 📍 即時場所相關模型
class InstantVenues {
  final List<VenueCategory> venueCategories;

  const InstantVenues({required this.venueCategories});
}

class VenueCategory {
  final String name;
  final String description;
  final List<Venue> venues;

  const VenueCategory({
    required this.name,
    required this.description,
    required this.venues,
  });
}

class Venue {
  final String name;
  final String address;
  final double distance;
  final double rating;
  final String atmosphere;
  final String priceRange;
  final String busyLevel;
  final String bestTimeToVisit;

  const Venue({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.atmosphere,
    required this.priceRange,
    required this.busyLevel,
    required this.bestTimeToVisit,
  });
} 