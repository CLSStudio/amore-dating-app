import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase_config.dart';

// AI 愛情顧問服務提供者
final aiLoveConsultantServiceProvider = Provider<AILoveConsultantService>((ref) {
  return AILoveConsultantService();
});

// 約會建議類型枚舉
enum DateSuggestionType {
  firstDate,
  secondDate,
  romantic,
  casual,
  activity,
  indoor,
  outdoor,
  budget,
  luxury,
}

// 關係階段枚舉
enum RelationshipStage {
  initial,        // 初期接觸
  getting_to_know, // 了解階段
  dating,         // 約會階段
  exclusive,      // 專一關係
  serious,        // 認真關係
  committed,      // 承諾關係
}

// 溝通風格枚舉
enum CommunicationStyle {
  direct,         // 直接
  gentle,         // 溫和
  playful,        // 俏皮
  romantic,       // 浪漫
  intellectual,   // 理性
  emotional,      // 感性
}

// 約會建議模型
class DateSuggestion {
  final String id;
  final String title;
  final String description;
  final String location;
  final int estimatedCost;
  final Duration estimatedDuration;
  final DateSuggestionType type;
  final List<String> tags;
  final double compatibilityScore;
  final String reasoning;
  final Map<String, dynamic> details;

  DateSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.estimatedCost,
    required this.estimatedDuration,
    required this.type,
    required this.tags,
    required this.compatibilityScore,
    required this.reasoning,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'estimatedCost': estimatedCost,
      'estimatedDuration': estimatedDuration.inMinutes,
      'type': type.toString().split('.').last,
      'tags': tags,
      'compatibilityScore': compatibilityScore,
      'reasoning': reasoning,
      'details': details,
    };
  }
}

// 關係分析結果模型
class RelationshipAnalysis {
  final String userId;
  final String partnerId;
  final RelationshipStage currentStage;
  final double compatibilityScore;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> recommendations;
  final Map<String, double> dimensionScores;
  final DateTime analyzedAt;

  RelationshipAnalysis({
    required this.userId,
    required this.partnerId,
    required this.currentStage,
    required this.compatibilityScore,
    required this.strengths,
    required this.challenges,
    required this.recommendations,
    required this.dimensionScores,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partnerId': partnerId,
      'currentStage': currentStage.toString().split('.').last,
      'compatibilityScore': compatibilityScore,
      'strengths': strengths,
      'challenges': challenges,
      'recommendations': recommendations,
      'dimensionScores': dimensionScores,
      'analyzedAt': analyzedAt,
    };
  }
}

// 溝通建議模型
class CommunicationAdvice {
  final String id;
  final String scenario;
  final CommunicationStyle recommendedStyle;
  final String suggestion;
  final List<String> dosList;
  final List<String> dontsList;
  final String reasoning;
  final double confidenceScore;

  CommunicationAdvice({
    required this.id,
    required this.scenario,
    required this.recommendedStyle,
    required this.suggestion,
    required this.dosList,
    required this.dontsList,
    required this.reasoning,
    required this.confidenceScore,
  });
}

// 關係里程碑模型
class RelationshipMilestone {
  final String id;
  final String title;
  final String description;
  final RelationshipStage stage;
  final DateTime suggestedTiming;
  final List<String> preparationTips;
  final double importance;

  RelationshipMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.stage,
    required this.suggestedTiming,
    required this.preparationTips,
    required this.importance,
  });
}

class AILoveConsultantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 生成個性化約會建議
  Future<List<DateSuggestion>> generateDateSuggestions({
    required String partnerId,
    required DateSuggestionType type,
    required int budget,
    String? location = '香港',
    int limit = 5,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      print('生成約會建議: $type, 預算: $budget, 地點: $location');

      // 獲取雙方用戶資料
      final currentUserDoc = await FirebaseConfig.usersCollection.doc(currentUserId).get();
      final partnerDoc = await FirebaseConfig.usersCollection.doc(partnerId).get();

      if (!currentUserDoc.exists || !partnerDoc.exists) {
        throw Exception('用戶資料不存在');
      }

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final partnerData = partnerDoc.data() as Map<String, dynamic>;

      // 分析共同興趣和偏好
      final suggestions = await _generatePersonalizedDateSuggestions(
        currentUserData,
        partnerData,
        type,
        budget,
        location ?? '香港',
        limit,
      );

      // 保存建議記錄
      await _saveDateSuggestions(currentUserId, partnerId, suggestions);

      return suggestions;
    } catch (e) {
      print('生成約會建議失敗: $e');
      return _getDefaultDateSuggestions(type, budget, location ?? '香港', limit);
    }
  }

  // 生成個性化約會建議
  Future<List<DateSuggestion>> _generatePersonalizedDateSuggestions(
    Map<String, dynamic> currentUser,
    Map<String, dynamic> partner,
    DateSuggestionType type,
    int budget,
    String location,
    int limit,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 分析共同興趣
    final currentInterests = List<String>.from(currentUser['interests'] ?? []);
    final partnerInterests = List<String>.from(partner['interests'] ?? []);
    final commonInterests = currentInterests.where((interest) => 
        partnerInterests.contains(interest)).toList();

    // 分析 MBTI 兼容性
    final currentMBTI = currentUser['mbtiType'] as String?;
    final partnerMBTI = partner['mbtiType'] as String?;
    final mbtiCompatibility = _calculateMBTICompatibility(currentMBTI, partnerMBTI);

    // 根據約會類型生成建議
    switch (type) {
      case DateSuggestionType.firstDate:
        suggestions.addAll(await _generateFirstDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
        break;
      case DateSuggestionType.romantic:
        suggestions.addAll(await _generateRomanticDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
        break;
      case DateSuggestionType.activity:
        suggestions.addAll(await _generateActivityDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
        break;
      case DateSuggestionType.indoor:
        suggestions.addAll(await _generateIndoorDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
        break;
      case DateSuggestionType.outdoor:
        suggestions.addAll(await _generateOutdoorDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
        break;
      default:
        suggestions.addAll(await _generateGeneralDateSuggestions(
          commonInterests, budget, location, mbtiCompatibility));
    }

    // 按兼容性分數排序
    suggestions.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

    return suggestions.take(limit).toList();
  }

  // 生成首次約會建議
  Future<List<DateSuggestion>> _generateFirstDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 咖啡約會
    suggestions.add(DateSuggestion(
      id: 'first_coffee_${DateTime.now().millisecondsSinceEpoch}',
      title: '舒適咖啡廳聊天',
      description: '在溫馨的咖啡廳享受輕鬆對話，是認識彼此的完美開始',
      location: '$location 中環/銅鑼灣咖啡廳',
      estimatedCost: budget < 200 ? 150 : 200,
      estimatedDuration: const Duration(hours: 2),
      type: DateSuggestionType.firstDate,
      tags: ['輕鬆', '對話', '舒適'],
      compatibilityScore: 0.8 + (mbtiCompatibility * 0.2),
      reasoning: '首次約會適合選擇輕鬆的環境，有助於自然對話和相互了解',
      details: {
        'atmosphere': 'casual',
        'conversation_friendly': true,
        'escape_route': true,
      },
    ));

    // 藝術展覽
    if (commonInterests.contains('藝術') || commonInterests.contains('文化')) {
      suggestions.add(DateSuggestion(
        id: 'first_art_${DateTime.now().millisecondsSinceEpoch}',
        title: '藝術展覽參觀',
        description: '一起欣賞藝術作品，在文化氛圍中深入交流',
        location: '$location 藝術館/畫廊',
        estimatedCost: budget < 300 ? 100 : 150,
        estimatedDuration: const Duration(hours: 3),
        type: DateSuggestionType.firstDate,
        tags: ['文化', '藝術', '深度對話'],
        compatibilityScore: 0.85 + (mbtiCompatibility * 0.15),
        reasoning: '共同的藝術興趣為對話提供自然話題，展現文化品味',
        details: {
          'intellectual_stimulation': true,
          'conversation_starters': true,
          'cultural_value': true,
        },
      ));
    }

    // 海濱散步
    suggestions.add(DateSuggestion(
      id: 'first_waterfront_${DateTime.now().millisecondsSinceEpoch}',
      title: '海濱長廊漫步',
      description: '在美麗的海景中悠閒散步，享受自然的浪漫氛圍',
      location: '$location 中環海濱長廊/尖沙咀海濱',
      estimatedCost: 0,
      estimatedDuration: const Duration(hours: 2),
      type: DateSuggestionType.firstDate,
      tags: ['免費', '浪漫', '自然'],
      compatibilityScore: 0.75 + (mbtiCompatibility * 0.25),
      reasoning: '免費且浪漫的選擇，美麗的環境有助於放鬆心情',
      details: {
        'cost_effective': true,
        'romantic_setting': true,
        'flexible_timing': true,
      },
    ));

    return suggestions;
  }

  // 生成浪漫約會建議
  Future<List<DateSuggestion>> _generateRomanticDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 高級餐廳晚餐
    if (budget >= 800) {
      suggestions.add(DateSuggestion(
        id: 'romantic_dinner_${DateTime.now().millisecondsSinceEpoch}',
        title: '高級餐廳燭光晚餐',
        description: '在優雅的環境中享用精緻料理，創造難忘的浪漫回憶',
        location: '$location 高級餐廳',
        estimatedCost: budget >= 1500 ? 1200 : 800,
        estimatedDuration: const Duration(hours: 3),
        type: DateSuggestionType.romantic,
        tags: ['高級', '浪漫', '精緻'],
        compatibilityScore: 0.9 + (mbtiCompatibility * 0.1),
        reasoning: '精緻的用餐環境和優質服務營造浪漫氛圍',
        details: {
          'dress_code': 'formal',
          'reservation_required': true,
          'romantic_atmosphere': true,
        },
      ));
    }

    // 太平山頂夜景
    suggestions.add(DateSuggestion(
      id: 'romantic_peak_${DateTime.now().millisecondsSinceEpoch}',
      title: '太平山頂觀賞夜景',
      description: '在香港最美的夜景中分享浪漫時光',
      location: '$location 太平山頂',
      estimatedCost: budget < 300 ? 100 : 200,
      estimatedDuration: const Duration(hours: 4),
      type: DateSuggestionType.romantic,
      tags: ['夜景', '浪漫', '經典'],
      compatibilityScore: 0.85 + (mbtiCompatibility * 0.15),
      reasoning: '香港經典浪漫地點，壯麗夜景營造完美氛圍',
      details: {
        'iconic_location': true,
        'photo_opportunities': true,
        'weather_dependent': true,
      },
    ));

    // 私人遊艇
    if (budget >= 2000) {
      suggestions.add(DateSuggestion(
        id: 'romantic_yacht_${DateTime.now().millisecondsSinceEpoch}',
        title: '私人遊艇海上之旅',
        description: '在私密的海上空間享受獨特的浪漫體驗',
        location: '$location 遊艇碼頭',
        estimatedCost: 2500,
        estimatedDuration: const Duration(hours: 4),
        type: DateSuggestionType.romantic,
        tags: ['奢華', '私密', '獨特'],
        compatibilityScore: 0.95 + (mbtiCompatibility * 0.05),
        reasoning: '獨特且私密的體驗，展現特別的用心',
        details: {
          'luxury_experience': true,
          'privacy': true,
          'weather_dependent': true,
        },
      ));
    }

    return suggestions;
  }

  // 生成活動約會建議
  Future<List<DateSuggestion>> _generateActivityDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 運動活動
    if (commonInterests.contains('運動')) {
      suggestions.add(DateSuggestion(
        id: 'activity_sports_${DateTime.now().millisecondsSinceEpoch}',
        title: '運動中心活動',
        description: '一起運動，在活力中增進感情',
        location: '$location 運動中心',
        estimatedCost: budget < 400 ? 200 : 300,
        estimatedDuration: const Duration(hours: 2),
        type: DateSuggestionType.activity,
        tags: ['運動', '健康', '活力'],
        compatibilityScore: 0.8 + (mbtiCompatibility * 0.2),
        reasoning: '共同運動有助於建立團隊合作精神和身體接觸',
        details: {
          'physical_activity': true,
          'team_building': true,
          'health_conscious': true,
        },
      ));
    }

    // 烹飪課程
    suggestions.add(DateSuggestion(
      id: 'activity_cooking_${DateTime.now().millisecondsSinceEpoch}',
      title: '情侶烹飪課程',
      description: '一起學習烹飪，創造美味和美好回憶',
      location: '$location 烹飪學校',
      estimatedCost: budget < 600 ? 400 : 500,
      estimatedDuration: const Duration(hours: 3),
      type: DateSuggestionType.activity,
      tags: ['學習', '合作', '美食'],
      compatibilityScore: 0.85 + (mbtiCompatibility * 0.15),
      reasoning: '合作烹飪增進默契，共享成果帶來成就感',
      details: {
        'collaborative': true,
        'skill_learning': true,
        'tangible_outcome': true,
      },
    ));

    return suggestions;
  }

  // 生成室內約會建議
  Future<List<DateSuggestion>> _generateIndoorDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 電影院
    suggestions.add(DateSuggestion(
      id: 'indoor_cinema_${DateTime.now().millisecondsSinceEpoch}',
      title: '電影院觀影',
      description: '在舒適的環境中一起欣賞精彩電影',
      location: '$location 電影院',
      estimatedCost: budget < 300 ? 200 : 250,
      estimatedDuration: const Duration(hours: 3),
      type: DateSuggestionType.indoor,
      tags: ['娛樂', '舒適', '經典'],
      compatibilityScore: 0.7 + (mbtiCompatibility * 0.3),
      reasoning: '經典約會選擇，適合各種天氣條件',
      details: {
        'weather_independent': true,
        'entertainment': true,
        'conversation_after': true,
      },
    ));

    // 博物館
    if (commonInterests.contains('文化') || commonInterests.contains('歷史')) {
      suggestions.add(DateSuggestion(
        id: 'indoor_museum_${DateTime.now().millisecondsSinceEpoch}',
        title: '博物館探索',
        description: '在知識的海洋中一起探索和學習',
        location: '$location 博物館',
        estimatedCost: budget < 200 ? 50 : 100,
        estimatedDuration: const Duration(hours: 3),
        type: DateSuggestionType.indoor,
        tags: ['文化', '學習', '深度'],
        compatibilityScore: 0.8 + (mbtiCompatibility * 0.2),
        reasoning: '文化活動展現知識品味，提供豐富話題',
        details: {
          'educational': true,
          'conversation_rich': true,
          'cultural_value': true,
        },
      ));
    }

    return suggestions;
  }

  // 生成戶外約會建議
  Future<List<DateSuggestion>> _generateOutdoorDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 郊野公園遠足
    if (commonInterests.contains('戶外活動') || commonInterests.contains('自然')) {
      suggestions.add(DateSuggestion(
        id: 'outdoor_hiking_${DateTime.now().millisecondsSinceEpoch}',
        title: '郊野公園遠足',
        description: '在大自然中享受清新空氣和美麗景色',
        location: '$location 郊野公園',
        estimatedCost: budget < 200 ? 50 : 100,
        estimatedDuration: const Duration(hours: 4),
        type: DateSuggestionType.outdoor,
        tags: ['自然', '運動', '健康'],
        compatibilityScore: 0.8 + (mbtiCompatibility * 0.2),
        reasoning: '親近自然有助於放鬆心情，共同挑戰增進感情',
        details: {
          'nature_connection': true,
          'physical_challenge': true,
          'weather_dependent': true,
        },
      ));
    }

    // 海灘活動
    suggestions.add(DateSuggestion(
      id: 'outdoor_beach_${DateTime.now().millisecondsSinceEpoch}',
      title: '海灘休閒時光',
      description: '在陽光沙灘上享受悠閒的約會時光',
      location: '$location 海灘',
      estimatedCost: budget < 300 ? 100 : 200,
      estimatedDuration: const Duration(hours: 4),
      type: DateSuggestionType.outdoor,
      tags: ['海灘', '陽光', '放鬆'],
      compatibilityScore: 0.75 + (mbtiCompatibility * 0.25),
      reasoning: '海灘環境輕鬆愉快，適合深入交流',
      details: {
        'relaxing': true,
        'seasonal': true,
        'photo_opportunities': true,
      },
    ));

    return suggestions;
  }

  // 生成通用約會建議
  Future<List<DateSuggestion>> _generateGeneralDateSuggestions(
    List<String> commonInterests,
    int budget,
    String location,
    double mbtiCompatibility,
  ) async {
    final suggestions = <DateSuggestion>[];

    // 市場/夜市
    suggestions.add(DateSuggestion(
      id: 'general_market_${DateTime.now().millisecondsSinceEpoch}',
      title: '傳統市場/夜市探索',
      description: '體驗本地文化，品嚐地道美食',
      location: '$location 傳統市場',
      estimatedCost: budget < 400 ? 200 : 300,
      estimatedDuration: const Duration(hours: 3),
      type: DateSuggestionType.casual,
      tags: ['文化', '美食', '本地'],
      compatibilityScore: 0.7 + (mbtiCompatibility * 0.3),
      reasoning: '體驗本地文化，輕鬆愉快的氛圍',
      details: {
        'cultural_experience': true,
        'food_variety': true,
        'casual_atmosphere': true,
      },
    ));

    return suggestions;
  }

  // 計算 MBTI 兼容性
  double _calculateMBTICompatibility(String? mbti1, String? mbti2) {
    if (mbti1 == null || mbti2 == null) return 0.5;

    // 簡化的 MBTI 兼容性計算
    final compatibilityMatrix = {
      'ENFP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7, 'ENTP': 0.8},
      'INTJ': {'ENFP': 0.9, 'ENTP': 0.8, 'INFP': 0.7, 'ENTJ': 0.7},
      'INFJ': {'ENFP': 0.8, 'ENTP': 0.7, 'INFP': 0.8, 'ENFJ': 0.7},
      'ENFJ': {'INFP': 0.9, 'ISFP': 0.8, 'ENFP': 0.7, 'INFJ': 0.7},
    };

    return compatibilityMatrix[mbti1]?[mbti2] ?? 0.6;
  }

  // 獲取默認約會建議
  List<DateSuggestion> _getDefaultDateSuggestions(
    DateSuggestionType type,
    int budget,
    String location,
    int limit,
  ) {
    final defaultSuggestions = [
      DateSuggestion(
        id: 'default_coffee',
        title: '咖啡廳聊天',
        description: '在舒適的咖啡廳享受輕鬆對話',
        location: '$location 咖啡廳',
        estimatedCost: 150,
        estimatedDuration: const Duration(hours: 2),
        type: type,
        tags: ['輕鬆', '對話'],
        compatibilityScore: 0.7,
        reasoning: '安全的選擇，適合初次約會',
        details: {},
      ),
      DateSuggestion(
        id: 'default_movie',
        title: '電影院觀影',
        description: '一起欣賞精彩電影',
        location: '$location 電影院',
        estimatedCost: 200,
        estimatedDuration: const Duration(hours: 3),
        type: type,
        tags: ['娛樂', '經典'],
        compatibilityScore: 0.6,
        reasoning: '經典約會選擇',
        details: {},
      ),
    ];

    return defaultSuggestions.take(limit).toList();
  }

  // 保存約會建議
  Future<void> _saveDateSuggestions(
    String userId,
    String partnerId,
    List<DateSuggestion> suggestions,
  ) async {
    try {
      await _firestore.collection('date_suggestions').add({
        'userId': userId,
        'partnerId': partnerId,
        'suggestions': suggestions.map((s) => s.toMap()).toList(),
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      print('保存約會建議失敗: $e');
    }
  }

  // 分析關係狀態
  Future<RelationshipAnalysis> analyzeRelationship({
    required String partnerId,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      print('分析關係狀態: $currentUserId <-> $partnerId');

      // 獲取雙方用戶資料
      final currentUserDoc = await FirebaseConfig.usersCollection.doc(currentUserId).get();
      final partnerDoc = await FirebaseConfig.usersCollection.doc(partnerId).get();

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final partnerData = partnerDoc.data() as Map<String, dynamic>;

      // 獲取聊天記錄
      final chatHistory = await _getChatHistory(currentUserId, partnerId);

      // 執行關係分析
      final analysis = await _performRelationshipAnalysis(
        currentUserData,
        partnerData,
        chatHistory,
      );

      // 保存分析結果
      await _saveRelationshipAnalysis(analysis);

      return analysis;
    } catch (e) {
      print('關係分析失敗: $e');
      throw Exception('關係分析失敗: $e');
    }
  }

  // 獲取聊天記錄
  Future<List<Map<String, dynamic>>> _getChatHistory(
    String userId1,
    String userId2,
  ) async {
    final chatId = _generateChatId(userId1, userId2);
    
    final messagesQuery = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    return messagesQuery.docs.map((doc) => doc.data()).toList();
  }

  // 執行關係分析
  Future<RelationshipAnalysis> _performRelationshipAnalysis(
    Map<String, dynamic> currentUser,
    Map<String, dynamic> partner,
    List<Map<String, dynamic>> chatHistory,
  ) async {
    // 計算兼容性分數
    final compatibilityScore = _calculateOverallCompatibility(currentUser, partner);

    // 分析關係階段
    final currentStage = _analyzeRelationshipStage(chatHistory);

    // 識別優勢
    final strengths = _identifyRelationshipStrengths(currentUser, partner, chatHistory);

    // 識別挑戰
    final challenges = _identifyRelationshipChallenges(currentUser, partner, chatHistory);

    // 生成建議
    final recommendations = _generateRelationshipRecommendations(
      currentStage,
      strengths,
      challenges,
      compatibilityScore,
    );

    // 計算各維度分數
    final dimensionScores = _calculateDimensionScores(currentUser, partner);

    return RelationshipAnalysis(
      userId: currentUser['uid'] ?? '',
      partnerId: partner['uid'] ?? '',
      currentStage: currentStage,
      compatibilityScore: compatibilityScore,
      strengths: strengths,
      challenges: challenges,
      recommendations: recommendations,
      dimensionScores: dimensionScores,
      analyzedAt: DateTime.now(),
    );
  }

  // 計算整體兼容性
  double _calculateOverallCompatibility(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
  ) {
    double totalScore = 0.0;
    int factors = 0;

    // MBTI 兼容性 (30%)
    final mbti1 = user1['mbtiType'] as String?;
    final mbti2 = user2['mbtiType'] as String?;
    if (mbti1 != null && mbti2 != null) {
      totalScore += _calculateMBTICompatibility(mbti1, mbti2) * 0.3;
      factors++;
    }

    // 興趣兼容性 (25%)
    final interests1 = List<String>.from(user1['interests'] ?? []);
    final interests2 = List<String>.from(user2['interests'] ?? []);
    final commonInterests = interests1.where((i) => interests2.contains(i)).length;
    final interestScore = commonInterests / (interests1.length + interests2.length - commonInterests);
    totalScore += interestScore * 0.25;
    factors++;

    // 價值觀兼容性 (25%)
    final values1 = Map<String, dynamic>.from(user1['values'] ?? {});
    final values2 = Map<String, dynamic>.from(user2['values'] ?? {});
    final valueScore = _calculateValueCompatibility(values1, values2);
    totalScore += valueScore * 0.25;
    factors++;

    // 年齡兼容性 (10%)
    final age1 = user1['age'] as int? ?? 25;
    final age2 = user2['age'] as int? ?? 25;
    final ageDiff = (age1 - age2).abs();
    final ageScore = ageDiff <= 5 ? 1.0 : (ageDiff <= 10 ? 0.7 : 0.4);
    totalScore += ageScore * 0.1;
    factors++;

    // 地理位置兼容性 (10%)
    final location1 = user1['location'] as String? ?? '';
    final location2 = user2['location'] as String? ?? '';
    final locationScore = location1 == location2 ? 1.0 : 0.6;
    totalScore += locationScore * 0.1;
    factors++;

    return factors > 0 ? totalScore : 0.5;
  }

  // 計算價值觀兼容性
  double _calculateValueCompatibility(
    Map<String, dynamic> values1,
    Map<String, dynamic> values2,
  ) {
    if (values1.isEmpty || values2.isEmpty) return 0.5;

    final importantValues = ['family', 'career', 'travel', 'health', 'spirituality'];
    double totalDiff = 0.0;
    int comparisons = 0;

    for (final value in importantValues) {
      final score1 = values1[value] as double? ?? 0.5;
      final score2 = values2[value] as double? ?? 0.5;
      totalDiff += (score1 - score2).abs();
      comparisons++;
    }

    final avgDiff = totalDiff / comparisons;
    return 1.0 - avgDiff; // 差異越小，兼容性越高
  }

  // 分析關係階段
  RelationshipStage _analyzeRelationshipStage(List<Map<String, dynamic>> chatHistory) {
    if (chatHistory.isEmpty) return RelationshipStage.initial;

    final messageCount = chatHistory.length;
    final daysSinceFirstMessage = _calculateDaysSinceFirstMessage(chatHistory);

    if (messageCount < 10 || daysSinceFirstMessage < 3) {
      return RelationshipStage.initial;
    } else if (messageCount < 50 || daysSinceFirstMessage < 14) {
      return RelationshipStage.getting_to_know;
    } else if (messageCount < 200 || daysSinceFirstMessage < 30) {
      return RelationshipStage.dating;
    } else if (daysSinceFirstMessage < 90) {
      return RelationshipStage.exclusive;
    } else if (daysSinceFirstMessage < 180) {
      return RelationshipStage.serious;
    } else {
      return RelationshipStage.committed;
    }
  }

  // 計算首次消息以來的天數
  int _calculateDaysSinceFirstMessage(List<Map<String, dynamic>> chatHistory) {
    if (chatHistory.isEmpty) return 0;

    final firstMessage = chatHistory.last;
    final timestamp = firstMessage['timestamp'] as Timestamp?;
    if (timestamp == null) return 0;

    final firstMessageDate = timestamp.toDate();
    return DateTime.now().difference(firstMessageDate).inDays;
  }

  // 識別關係優勢
  List<String> _identifyRelationshipStrengths(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
    List<Map<String, dynamic>> chatHistory,
  ) {
    final strengths = <String>[];

    // 共同興趣
    final interests1 = List<String>.from(user1['interests'] ?? []);
    final interests2 = List<String>.from(user2['interests'] ?? []);
    final commonInterests = interests1.where((i) => interests2.contains(i)).toList();
    
    if (commonInterests.isNotEmpty) {
      strengths.add('擁有共同興趣：${commonInterests.join('、')}');
    }

    // MBTI 兼容性
    final mbti1 = user1['mbtiType'] as String?;
    final mbti2 = user2['mbtiType'] as String?;
    if (mbti1 != null && mbti2 != null) {
      final compatibility = _calculateMBTICompatibility(mbti1, mbti2);
      if (compatibility > 0.7) {
        strengths.add('MBTI 性格類型高度兼容');
      }
    }

    // 溝通頻率
    if (chatHistory.length > 50) {
      strengths.add('溝通頻繁，互動良好');
    }

    // 價值觀一致性
    final values1 = Map<String, dynamic>.from(user1['values'] ?? {});
    final values2 = Map<String, dynamic>.from(user2['values'] ?? {});
    final valueCompatibility = _calculateValueCompatibility(values1, values2);
    if (valueCompatibility > 0.7) {
      strengths.add('核心價值觀高度一致');
    }

    return strengths;
  }

  // 識別關係挑戰
  List<String> _identifyRelationshipChallenges(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
    List<Map<String, dynamic>> chatHistory,
  ) {
    final challenges = <String>[];

    // 年齡差距
    final age1 = user1['age'] as int? ?? 25;
    final age2 = user2['age'] as int? ?? 25;
    final ageDiff = (age1 - age2).abs();
    if (ageDiff > 10) {
      challenges.add('年齡差距較大，可能存在生活階段差異');
    }

    // 地理距離
    final location1 = user1['location'] as String? ?? '';
    final location2 = user2['location'] as String? ?? '';
    if (location1 != location2 && location1.isNotEmpty && location2.isNotEmpty) {
      challenges.add('地理位置不同，可能影響見面頻率');
    }

    // 溝通模式
    if (chatHistory.length < 20) {
      challenges.add('溝通頻率較低，建議增加互動');
    }

    // 興趣差異
    final interests1 = List<String>.from(user1['interests'] ?? []);
    final interests2 = List<String>.from(user2['interests'] ?? []);
    final commonInterests = interests1.where((i) => interests2.contains(i)).length;
    if (commonInterests < 2) {
      challenges.add('共同興趣較少，需要探索新的共同點');
    }

    return challenges;
  }

  // 生成關係建議
  List<String> _generateRelationshipRecommendations(
    RelationshipStage stage,
    List<String> strengths,
    List<String> challenges,
    double compatibilityScore,
  ) {
    final recommendations = <String>[];

    // 基於關係階段的建議
    switch (stage) {
      case RelationshipStage.initial:
        recommendations.addAll([
          '保持輕鬆愉快的對話氛圍',
          '分享日常生活和興趣愛好',
          '安排輕鬆的見面活動',
        ]);
        break;
      case RelationshipStage.getting_to_know:
        recommendations.addAll([
          '深入了解彼此的價值觀和目標',
          '嘗試不同類型的約會活動',
          '開始建立更深層的情感連結',
        ]);
        break;
      case RelationshipStage.dating:
        recommendations.addAll([
          '討論關係的發展方向',
          '增加見面的頻率和質量',
          '開始規劃共同的未來活動',
        ]);
        break;
      case RelationshipStage.exclusive:
        recommendations.addAll([
          '建立更深的信任和承諾',
          '討論長期關係的期望',
          '開始融入彼此的社交圈',
        ]);
        break;
      case RelationshipStage.serious:
        recommendations.addAll([
          '討論未來的生活規劃',
          '處理關係中的重要議題',
          '考慮更進一步的承諾',
        ]);
        break;
      case RelationshipStage.committed:
        recommendations.addAll([
          '維持關係的新鮮感',
          '共同面對生活挑戰',
          '規劃長期的人生目標',
        ]);
        break;
    }

    // 基於兼容性分數的建議
    if (compatibilityScore > 0.8) {
      recommendations.add('你們的兼容性很高，珍惜這段關係');
    } else if (compatibilityScore < 0.5) {
      recommendations.add('需要更多時間了解彼此，保持開放的心態');
    }

    // 基於挑戰的建議
    for (final challenge in challenges) {
      if (challenge.contains('溝通')) {
        recommendations.add('建議增加日常溝通，分享更多生活細節');
      } else if (challenge.contains('興趣')) {
        recommendations.add('嘗試一起探索新的活動和興趣');
      } else if (challenge.contains('距離')) {
        recommendations.add('善用視頻通話和線上活動維持聯繫');
      }
    }

    return recommendations;
  }

  // 計算各維度分數
  Map<String, double> _calculateDimensionScores(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
  ) {
    return {
      'personality': _calculateMBTICompatibility(
        user1['mbtiType'] as String?,
        user2['mbtiType'] as String?,
      ),
      'interests': _calculateInterestCompatibility(user1, user2),
      'values': _calculateValueCompatibility(
        Map<String, dynamic>.from(user1['values'] ?? {}),
        Map<String, dynamic>.from(user2['values'] ?? {}),
      ),
      'lifestyle': _calculateLifestyleCompatibility(user1, user2),
      'communication': 0.7, // 基於聊天分析，這裡簡化處理
    };
  }

  // 計算興趣兼容性
  double _calculateInterestCompatibility(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
  ) {
    final interests1 = List<String>.from(user1['interests'] ?? []);
    final interests2 = List<String>.from(user2['interests'] ?? []);
    
    if (interests1.isEmpty || interests2.isEmpty) return 0.5;
    
    final commonInterests = interests1.where((i) => interests2.contains(i)).length;
    final totalInterests = interests1.length + interests2.length - commonInterests;
    
    return totalInterests > 0 ? commonInterests / totalInterests : 0.0;
  }

  // 計算生活方式兼容性
  double _calculateLifestyleCompatibility(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
  ) {
    // 簡化的生活方式兼容性計算
    final age1 = user1['age'] as int? ?? 25;
    final age2 = user2['age'] as int? ?? 25;
    final ageDiff = (age1 - age2).abs();
    
    final profession1 = user1['profession'] as String? ?? '';
    final profession2 = user2['profession'] as String? ?? '';
    
    double score = 1.0;
    
    // 年齡因素
    if (ageDiff > 10) {
      score -= 0.3;
    } else if (ageDiff > 5) score -= 0.1;
    
    // 職業因素（簡化處理）
    if (profession1.isNotEmpty && profession2.isNotEmpty) {
      if (profession1 == profession2) score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }

  // 保存關係分析
  Future<void> _saveRelationshipAnalysis(RelationshipAnalysis analysis) async {
    try {
      await _firestore.collection('relationship_analysis').add(analysis.toMap());
    } catch (e) {
      print('保存關係分析失敗: $e');
    }
  }

  // 生成溝通建議
  Future<CommunicationAdvice> generateCommunicationAdvice({
    required String partnerId,
    required String scenario,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      // 獲取用戶資料
      final currentUserDoc = await FirebaseConfig.usersCollection.doc(currentUserId).get();
      final partnerDoc = await FirebaseConfig.usersCollection.doc(partnerId).get();

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final partnerData = partnerDoc.data() as Map<String, dynamic>;

      // 分析最佳溝通方式
      final advice = _generatePersonalizedCommunicationAdvice(
        currentUserData,
        partnerData,
        scenario,
      );

      return advice;
    } catch (e) {
      print('生成溝通建議失敗: $e');
      throw Exception('生成溝通建議失敗: $e');
    }
  }

  // 生成個性化溝通建議
  CommunicationAdvice _generatePersonalizedCommunicationAdvice(
    Map<String, dynamic> currentUser,
    Map<String, dynamic> partner,
    String scenario,
  ) {
    final partnerMBTI = partner['mbtiType'] as String?;
    final currentMBTI = currentUser['mbtiType'] as String?;

    // 基於 MBTI 類型選擇溝通風格
    CommunicationStyle recommendedStyle = CommunicationStyle.gentle;
    List<String> dosList = [];
    List<String> dontsList = [];
    String suggestion = '';
    String reasoning = '';

    if (partnerMBTI != null) {
      switch (partnerMBTI.substring(0, 2)) {
        case 'EN': // 外向
          recommendedStyle = CommunicationStyle.direct;
          dosList = ['直接表達想法', '保持活力和熱情', '給予充分的關注'];
          dontsList = ['過於含蓄', '長時間沉默', '忽視他們的感受'];
          break;
        case 'IN': // 內向
          recommendedStyle = CommunicationStyle.gentle;
          dosList = ['給予思考時間', '創造安全的對話環境', '耐心傾聽'];
          dontsList = ['強迫立即回應', '在公共場合討論敏感話題', '過於激進'];
          break;
      }

      if (partnerMBTI.contains('F')) { // 情感型
        dosList.add('表達關心和理解');
        dosList.add('重視他們的感受');
        dontsList.add('過於理性分析');
        dontsList.add('忽視情感需求');
      } else { // 思考型
        dosList.add('提供邏輯清晰的論點');
        dosList.add('尊重他們的分析過程');
        dontsList.add('過於情緒化');
        dontsList.add('缺乏邏輯支撐');
      }
    }

    // 基於場景調整建議
    switch (scenario.toLowerCase()) {
      case '表達不滿':
        suggestion = '選擇合適的時機，以"我"的角度表達感受，避免指責性語言';
        reasoning = '建設性的溝通有助於解決問題而不是製造衝突';
        break;
      case '討論未來':
        suggestion = '分享你的想法和期望，同時詢問對方的看法，尋求共同點';
        reasoning = '開放的討論有助於建立共同的未來願景';
        break;
      case '道歉':
        suggestion = '真誠地承認錯誤，表達改進的意願，給對方時間處理情緒';
        reasoning = '真誠的道歉是修復關係的重要步驟';
        break;
      default:
        suggestion = '保持開放和誠實的態度，積極傾聽對方的想法';
        reasoning = '良好的溝通是健康關係的基礎';
    }

    return CommunicationAdvice(
      id: 'advice_${DateTime.now().millisecondsSinceEpoch}',
      scenario: scenario,
      recommendedStyle: recommendedStyle,
      suggestion: suggestion,
      dosList: dosList,
      dontsList: dontsList,
      reasoning: reasoning,
      confidenceScore: 0.8,
    );
  }

  // 生成關係里程碑建議
  Future<List<RelationshipMilestone>> generateRelationshipMilestones({
    required String partnerId,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      // 分析當前關係階段
      final chatHistory = await _getChatHistory(currentUserId, partnerId);
      final currentStage = _analyzeRelationshipStage(chatHistory);

      // 生成適合的里程碑
      final milestones = _generateStageMilestones(currentStage);

      return milestones;
    } catch (e) {
      print('生成關係里程碑失敗: $e');
      return [];
    }
  }

  // 生成階段里程碑
  List<RelationshipMilestone> _generateStageMilestones(RelationshipStage currentStage) {
    final milestones = <RelationshipMilestone>[];
    final now = DateTime.now();

    switch (currentStage) {
      case RelationshipStage.initial:
        milestones.addAll([
          RelationshipMilestone(
            id: 'first_call',
            title: '第一次語音通話',
            description: '進行第一次語音或視頻通話，聽到彼此的聲音',
            stage: RelationshipStage.getting_to_know,
            suggestedTiming: now.add(const Duration(days: 3)),
            preparationTips: ['選擇安靜的環境', '準備一些話題', '保持輕鬆的心態'],
            importance: 0.8,
          ),
          RelationshipMilestone(
            id: 'first_date',
            title: '第一次見面',
            description: '安排第一次線下見面，在安全的公共場所',
            stage: RelationshipStage.getting_to_know,
            suggestedTiming: now.add(const Duration(days: 7)),
            preparationTips: ['選擇公共場所', '告知朋友行程', '保持真實的自己'],
            importance: 0.9,
          ),
        ]);
        break;
      case RelationshipStage.getting_to_know:
        milestones.addAll([
          RelationshipMilestone(
            id: 'share_interests',
            title: '分享深層興趣',
            description: '分享更深層的興趣愛好和人生經歷',
            stage: RelationshipStage.dating,
            suggestedTiming: now.add(const Duration(days: 14)),
            preparationTips: ['準備分享真實的故事', '保持開放的心態', '尊重對方的分享'],
            importance: 0.7,
          ),
        ]);
        break;
      case RelationshipStage.dating:
        milestones.addAll([
          RelationshipMilestone(
            id: 'exclusive_talk',
            title: '專一關係討論',
            description: '討論是否建立專一的戀愛關係',
            stage: RelationshipStage.exclusive,
            suggestedTiming: now.add(const Duration(days: 30)),
            preparationTips: ['選擇合適的時機', '誠實表達想法', '尊重對方的決定'],
            importance: 0.9,
          ),
        ]);
        break;
      default:
        break;
    }

    return milestones;
  }

  // 生成聊天 ID
  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
} 