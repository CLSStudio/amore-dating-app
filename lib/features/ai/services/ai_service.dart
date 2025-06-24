import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_recommendation.dart';
import '../../profile/models/user_profile.dart';
import '../../mbti/models/mbti_question.dart';

class AIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 生成用戶匹配推薦
  Future<List<AIRecommendation>> generateUserMatchRecommendations(
    UserProfile currentUser,
    List<UserProfile> potentialMatches,
  ) async {
    final recommendations = <AIRecommendation>[];
    
    for (final match in potentialMatches.take(10)) {
      final compatibility = _calculateCompatibility(currentUser, match);
      if (compatibility.score >= 0.7) {
        final recommendation = AIRecommendation(
          id: _generateId(),
          userId: currentUser.id,
          type: RecommendationType.userMatch,
          title: '高匹配度推薦：${match.name}',
          description: '基於你們的 MBTI 類型和共同興趣，你們有很高的匹配度！',
          content: {
            'matchUserId': match.id,
            'compatibilityScore': compatibility.score,
            'sharedInterests': compatibility.sharedInterests,
            'mbtiCompatibility': compatibility.mbtiScore,
          },
          confidenceScore: compatibility.score,
          reasons: compatibility.reasons,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        recommendations.add(recommendation);
      }
    }

    // 保存推薦到數據庫
    for (final rec in recommendations) {
      await _saveRecommendation(rec);
    }

    return recommendations;
  }

  // 計算用戶兼容性
  CompatibilityResult _calculateCompatibility(UserProfile user1, UserProfile user2) {
    double totalScore = 0.0;
    final reasons = <String>[];
    final sharedInterests = <String>[];

    // MBTI 兼容性 (40%)
    double mbtiScore = 0.0;
    if (user1.mbtiType != null && user2.mbtiType != null) {
      mbtiScore = _calculateMBTICompatibility(user1.mbtiType!, user2.mbtiType!);
      totalScore += mbtiScore * 0.4;
      
      if (mbtiScore >= 0.8) {
        reasons.add('你們的性格類型非常互補');
      } else if (mbtiScore >= 0.6) {
        reasons.add('你們的性格有很好的匹配度');
      }
    }

    // 興趣匹配 (30%)
    if (user1.interests.isNotEmpty && user2.interests.isNotEmpty) {
      final common = user1.interests.toSet().intersection(user2.interests.toSet());
      sharedInterests.addAll(common);
      final interestScore = common.length / max(user1.interests.length, user2.interests.length);
      totalScore += interestScore * 0.3;
      
      if (common.isNotEmpty) {
        reasons.add('你們都喜歡：${common.take(3).join('、')}');
      }
    }

    // 年齡兼容性 (20%)
    final ageDiff = (user1.age - user2.age).abs();
    double ageScore = 1.0;
    if (ageDiff <= 2) {
      ageScore = 1.0;
    } else if (ageDiff <= 5) ageScore = 0.8;
    else if (ageDiff <= 10) ageScore = 0.6;
    else ageScore = 0.3;
    totalScore += ageScore * 0.2;

    // 位置兼容性 (10%)
    double locationScore = 0.8; // 假設都在香港，給予較高分數
    totalScore += locationScore * 0.1;

    return CompatibilityResult(
      score: totalScore,
      mbtiScore: mbtiScore,
      sharedInterests: sharedInterests,
      reasons: reasons,
    );
  }

  // MBTI 兼容性計算
  double _calculateMBTICompatibility(String type1, String type2) {
    // 使用之前實現的 MBTI 兼容性矩陣
    final compatibilityMatrix = {
      'ENFP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7, 'ENTP': 0.8},
      'ENFJ': {'INFP': 0.9, 'ISFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.7},
      'ENTP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFP': 0.8, 'INTP': 0.7},
      'ENTJ': {'INTP': 0.9, 'INFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.8},
      // ... 其他類型
    };

    return compatibilityMatrix[type1]?[type2] ?? 
           compatibilityMatrix[type2]?[type1] ?? 
           0.5;
  }

  // 生成愛情顧問建議
  Future<LoveConsultation> generateLoveConsultation({
    required String question,
    required String situation,
    required ConsultationCategory category,
    required Map<String, dynamic> userContext,
    bool isAnonymous = false,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    // 基於類別和情況生成 AI 回應
    final aiResponse = _generateAIResponse(category, question, situation, userContext);
    final actionItems = _generateActionItems(category, situation);
    final resources = _generateResources(category);

    final consultation = LoveConsultation(
      id: _generateId(),
      userId: currentUserId,
      category: category,
      question: question,
      situation: situation,
      userContext: userContext,
      aiResponse: aiResponse,
      actionItems: actionItems,
      resources: resources,
      createdAt: DateTime.now(),
      followUpAt: DateTime.now().add(const Duration(days: 7)),
      isAnonymous: isAnonymous,
    );

    // 保存到數據庫
    await _firestore
        .collection('love_consultations')
        .doc(consultation.id)
        .set(consultation.toJson());

    return consultation;
  }

  // 生成 AI 回應
  String _generateAIResponse(
    ConsultationCategory category,
    String question,
    String situation,
    Map<String, dynamic> userContext,
  ) {
    final mbtiType = userContext['mbtiType'] as String?;
    final age = userContext['age'] as int?;
    
    switch (category) {
      case ConsultationCategory.communication:
        return _generateCommunicationAdvice(question, situation, mbtiType);
      case ConsultationCategory.dating:
        return _generateDatingAdvice(question, situation, mbtiType, age);
      case ConsultationCategory.relationship:
        return _generateRelationshipAdvice(question, situation, mbtiType);
      case ConsultationCategory.conflict:
        return _generateConflictAdvice(question, situation, mbtiType);
      default:
        return _generateGeneralAdvice(question, situation);
    }
  }

  String _generateCommunicationAdvice(String question, String situation, String? mbtiType) {
    const baseAdvice = '''
根據你的情況，我建議你採用以下溝通策略：

1. **主動傾聽**：給對方充分表達的機會，不要急於反駁或解釋。

2. **使用「我」語句**：表達感受時說「我覺得...」而不是「你總是...」。

3. **選擇合適時機**：在雙方都冷靜且有時間的時候進行重要對話。

4. **保持開放心態**：嘗試理解對方的觀點，即使你不同意。
''';

    if (mbtiType != null) {
      if (mbtiType.contains('F')) {
        return '$baseAdvice\n\n**針對你的性格特點**：作為情感型的人，記住有時候對方可能更注重邏輯而非情感，試著用事實和理由來支持你的觀點。';
      } else if (mbtiType.contains('T')) {
        return '$baseAdvice\n\n**針對你的性格特點**：作為思考型的人，記住對方的情感同樣重要，在表達邏輯觀點的同時，也要關注對方的感受。';
      }
    }

    return baseAdvice;
  }

  String _generateDatingAdvice(String question, String situation, String? mbtiType, int? age) {
    String advice = '''
約會是建立關係的重要階段，以下是一些建議：

1. **真實做自己**：不要為了迎合對方而偽裝，真實的你才最有魅力。

2. **保持好奇心**：主動了解對方的興趣、價值觀和生活方式。

3. **創造共同體驗**：選擇能讓你們互動和交流的活動。

4. **注意節奏**：不要急於推進關係，讓感情自然發展。
''';

    if (age != null && age < 25) {
      advice += '\n\n**年齡建議**：年輕時期是探索和學習的好時機，不要給自己太大壓力，享受認識新朋友的過程。';
    } else if (age != null && age >= 30) {
      advice += '\n\n**年齡建議**：在這個年齡階段，你可能更清楚自己想要什麼，可以更直接地表達你的期望和目標。';
    }

    return advice;
  }

  String _generateRelationshipAdvice(String question, String situation, String? mbtiType) {
    return '''
維持健康的關係需要雙方的努力：

1. **建立信任**：誠實、可靠，言行一致。

2. **保持獨立性**：在關係中保持自己的興趣和朋友圈。

3. **定期溝通**：分享日常生活、感受和未來計劃。

4. **處理分歧**：學會健康地處理衝突，尋求雙贏的解決方案。

5. **表達感激**：經常表達對伴侶的感謝和欣賞。

記住，好的關係是兩個完整的人選擇在一起，而不是兩個半個人拼湊成一個整體。
''';
  }

  String _generateConflictAdvice(String question, String situation, String? mbtiType) {
    return '''
處理關係中的衝突是一門藝術：

1. **冷靜下來**：在情緒激動時暫停討論，等雙方都冷靜後再繼續。

2. **專注問題本身**：避免人身攻擊，專注於解決具體問題。

3. **尋找共同點**：找出你們都同意的部分，從這裡開始建立共識。

4. **妥協和讓步**：關係中沒有絕對的對錯，學會適當妥協。

5. **尋求專業幫助**：如果問題持續存在，考慮尋求專業諮詢師的幫助。

衝突本身不是問題，如何處理衝突才是關鍵。
''';
  }

  String _generateGeneralAdvice(String question, String situation) {
    return '''
感謝你的信任，讓我來幫助你分析這個情況。

每個人的情況都是獨特的，但有一些通用的原則可以幫助你：

1. **自我反思**：先了解自己的需求、期望和底線。

2. **開放溝通**：誠實地表達你的想法和感受。

3. **耐心等待**：好的關係需要時間來建立和發展。

4. **學習成長**：把每次經歷都當作學習的機會。

記住，你值得被愛和尊重。如果情況沒有改善，不要害怕尋求更多幫助或做出改變。
''';
  }

  // 生成行動建議
  List<String> _generateActionItems(ConsultationCategory category, String situation) {
    switch (category) {
      case ConsultationCategory.communication:
        return [
          '今天就嘗試用「我」語句表達一次感受',
          '安排一個不被打擾的時間進行深度對話',
          '練習主動傾聽技巧',
        ];
      case ConsultationCategory.dating:
        return [
          '計劃一個能促進交流的約會活動',
          '準備一些開放性問題來了解對方',
          '反思自己在約會中的表現',
        ];
      case ConsultationCategory.relationship:
        return [
          '每天表達一次對伴侶的感謝',
          '安排定期的關係檢視時間',
          '培養共同興趣或活動',
        ];
      default:
        return [
          '記錄自己的感受和想法',
          '與信任的朋友分享並尋求建議',
          '給自己一些時間來處理情緒',
        ];
    }
  }

  // 生成相關資源
  List<String> _generateResources(ConsultationCategory category) {
    switch (category) {
      case ConsultationCategory.communication:
        return [
          '《非暴力溝通》- 馬歇爾·盧森堡',
          '《關鍵對話》- 科里·帕特森',
          'TED Talk: 如何進行困難的對話',
        ];
      case ConsultationCategory.dating:
        return [
          '《約會聖經》- 艾倫·費恩',
          '《現代愛情》- 阿茲·安薩里',
          '約會安全指南',
        ];
      case ConsultationCategory.relationship:
        return [
          '《愛的五種語言》- 蓋瑞·巧門',
          '《依戀理論》- 阿米爾·萊文',
          '關係諮詢師推薦清單',
        ];
      default:
        return [
          '心理健康資源',
          '專業諮詢師聯絡方式',
          '相關書籍推薦',
        ];
    }
  }

  // 分析用戶行為
  Future<UserBehaviorAnalysis> analyzeUserBehavior(String userId) async {
    // 獲取用戶活動數據
    final activities = await _getUserActivities(userId);
    final preferences = await _analyzePreferences(userId);
    final mbtiInsights = await _getMBTIInsights(userId);
    
    final analysis = UserBehaviorAnalysis(
      userId: userId,
      activityCounts: activities,
      preferences: preferences,
      interests: await _extractInterests(userId),
      mbtiInsights: mbtiInsights,
      lastUpdated: DateTime.now(),
      engagementScore: _calculateEngagementScore(activities),
      communicationStyle: await _analyzeCommunicationStyle(userId),
    );

    // 保存分析結果
    await _firestore
        .collection('user_behavior_analysis')
        .doc(userId)
        .set(analysis.toJson());

    return analysis;
  }

  // 生成智能通知
  Future<void> generateSmartNotifications(String userId) async {
    final analysis = await analyzeUserBehavior(userId);
    final notifications = <SmartNotification>[];

    // 基於用戶行為生成個性化通知
    if (analysis.engagementScore < 0.3) {
      notifications.add(SmartNotification(
        id: _generateId(),
        userId: userId,
        title: '來看看新的匹配吧！',
        message: '有幾位很棒的人想認識你，快來看看吧！',
        type: 'suggestion',
        actionData: {'action': 'view_matches'},
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        priority: 3,
      ));
    }

    if (analysis.activityCounts['messages_sent'] == 0) {
      notifications.add(SmartNotification(
        id: _generateId(),
        userId: userId,
        title: '開始對話吧！',
        message: '我們為你準備了一些破冰話題，讓聊天變得更輕鬆！',
        type: 'suggestion',
        actionData: {'action': 'view_icebreakers'},
        scheduledAt: DateTime.now().add(const Duration(hours: 6)),
        priority: 4,
      ));
    }

    // 保存通知
    for (final notification in notifications) {
      await _firestore
          .collection('smart_notifications')
          .doc(notification.id)
          .set(notification.toJson());
    }
  }

  // 輔助方法
  String _generateId() => _firestore.collection('temp').doc().id;

  Future<void> _saveRecommendation(AIRecommendation recommendation) async {
    await _firestore
        .collection('ai_recommendations')
        .doc(recommendation.id)
        .set(recommendation.toJson());
  }

  Future<Map<String, int>> _getUserActivities(String userId) async {
    // 實際實現中會從數據庫獲取用戶活動數據
    return {
      'profile_views': 10,
      'messages_sent': 5,
      'matches_made': 3,
      'app_opens': 15,
    };
  }

  Future<Map<String, double>> _analyzePreferences(String userId) async {
    // 分析用戶偏好
    return {
      'outdoor_activities': 0.8,
      'cultural_events': 0.6,
      'casual_dining': 0.9,
      'nightlife': 0.4,
    };
  }

  Future<Map<String, dynamic>> _getMBTIInsights(String userId) async {
    // 獲取 MBTI 相關洞察
    return {
      'dominant_function': 'Extraverted Feeling',
      'communication_style': 'Warm and expressive',
      'decision_making': 'Values-based',
    };
  }

  Future<List<String>> _extractInterests(String userId) async {
    // 從用戶檔案和行為中提取興趣
    return ['旅行', '美食', '電影', '音樂'];
  }

  double _calculateEngagementScore(Map<String, int> activities) {
    final totalActivities = activities.values.fold(0, (sum, count) => sum + count);
    return (totalActivities / 50).clamp(0.0, 1.0); // 假設50為滿分
  }

  Future<Map<String, dynamic>> _analyzeCommunicationStyle(String userId) async {
    // 分析溝通風格
    return {
      'response_time': 'Quick',
      'message_length': 'Medium',
      'emoji_usage': 'High',
      'question_asking': 'Frequent',
    };
  }
}

class CompatibilityResult {
  final double score;
  final double mbtiScore;
  final List<String> sharedInterests;
  final List<String> reasons;

  CompatibilityResult({
    required this.score,
    required this.mbtiScore,
    required this.sharedInterests,
    required this.reasons,
  });
} 