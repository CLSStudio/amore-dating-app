import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AI 約會顧問服務提供者
final datingAdvisorServiceProvider = Provider<DatingAdvisorService>((ref) {
  return DatingAdvisorService();
});

// 約會建議類型
enum AdviceType {
  firstDate,
  conversation,
  relationship,
  conflict,
  longTerm,
}

// 約會建議模型
class DatingAdvice {
  final String id;
  final AdviceType type;
  final String title;
  final String content;
  final List<String> tips;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  DatingAdvice({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.tips,
    required this.metadata,
    required this.createdAt,
  });
}

// 溝通分析結果
class CommunicationAnalysis {
  final double compatibilityScore;
  final String communicationStyle;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> suggestions;

  CommunicationAnalysis({
    required this.compatibilityScore,
    required this.communicationStyle,
    required this.strengths,
    required this.improvements,
    required this.suggestions,
  });
}

// 關係階段
enum RelationshipStage {
  initial,      // 初期接觸
  dating,       // 約會階段
  exclusive,    // 專一關係
  committed,    // 承諾關係
  longTerm,     // 長期關係
}

class DatingAdvisorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 獲取個性化約會建議
  static Future<DatingAdvice> getPersonalizedAdvice({
    required String partnerUserId,
    required AdviceType type,
    String? specificSituation,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      // 獲取用戶和對方的資料
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final partnerDoc = await _firestore
          .collection('users')
          .doc(partnerUserId)
          .get();

      if (!userDoc.exists || !partnerDoc.exists) {
        throw Exception('用戶資料不完整');
      }

      final userData = userDoc.data()!;
      final partnerData = partnerDoc.data()!;

      // 根據類型生成建議
      switch (type) {
        case AdviceType.firstDate:
          return await _generateFirstDateAdvice(userData, partnerData);
        case AdviceType.conversation:
          return await _generateConversationAdvice(userData, partnerData, specificSituation);
        case AdviceType.relationship:
          return await _generateRelationshipAdvice(userData, partnerData);
        case AdviceType.conflict:
          return await _generateConflictResolutionAdvice(userData, partnerData, specificSituation);
        case AdviceType.longTerm:
          return await _generateLongTermAdvice(userData, partnerData);
      }
    } catch (e) {
      throw Exception('獲取約會建議失敗: $e');
    }
  }

  /// 生成首次約會建議
  static Future<DatingAdvice> _generateFirstDateAdvice(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
  ) async {
    final userMBTI = userData['mbtiType'] as String?;
    final partnerMBTI = partnerData['mbtiType'] as String?;
    final userInterests = List<String>.from(userData['interests'] ?? []);
    final partnerInterests = List<String>.from(partnerData['interests'] ?? []);
    final sharedInterests = userInterests
        .where((interest) => partnerInterests.contains(interest))
        .toList();

    // 基於 MBTI 和興趣生成建議
    final suggestions = <String>[];
    final tips = <String>[];

    // MBTI 特定建議
    if (partnerMBTI != null) {
      switch (partnerMBTI[0]) { // E/I
        case 'E':
          suggestions.add('選擇有活力的環境，如咖啡廳、市集或戶外活動');
          tips.add('外向型的人喜歡互動和新體驗');
          break;
        case 'I':
          suggestions.add('選擇安靜舒適的環境，如書店咖啡廳、博物館或小餐廳');
          tips.add('內向型的人更喜歡深度對話和安靜的環境');
          break;
      }
    }

    // 共同興趣建議
    if (sharedInterests.isNotEmpty) {
      for (final interest in sharedInterests.take(3)) {
        switch (interest) {
          case '音樂':
            suggestions.add('參觀音樂展覽或去有現場音樂的咖啡廳');
            break;
          case '美食':
            suggestions.add('嘗試新餐廳或一起做料理');
            break;
          case '運動':
            suggestions.add('去健身房、打保齡球或戶外運動');
            break;
          case '藝術':
            suggestions.add('參觀美術館、畫廊或藝術工作坊');
            break;
          case '旅行':
            suggestions.add('探索城市新區域或計劃短途旅行');
            break;
        }
      }
    }

    // 通用建議
    tips.addAll([
      '準時到達，展現你的可靠性',
      '保持開放的心態，真誠地分享自己',
      '專注聆聽，展現對對方的興趣',
      '避免過於私人的話題，如前任關係',
      '保持輕鬆愉快的氛圍',
    ]);

    return DatingAdvice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AdviceType.firstDate,
      title: '首次約會完美指南',
      content: '基於你們的性格類型和共同興趣，我為你們精心設計了這次約會建議。記住，最重要的是做真實的自己，享受彼此的陪伴。',
      tips: tips,
      metadata: {
        'suggestions': suggestions,
        'sharedInterests': sharedInterests,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
      },
      createdAt: DateTime.now(),
    );
  }

  /// 生成對話建議
  static Future<DatingAdvice> _generateConversationAdvice(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
    String? situation,
  ) async {
    final userMBTI = userData['mbtiType'] as String?;
    final partnerMBTI = partnerData['mbtiType'] as String?;
    
    final tips = <String>[];
    final suggestions = <String>[];

    // 基於對方 MBTI 的溝通建議
    if (partnerMBTI != null) {
      // 思維偏好 (T/F)
      if (partnerMBTI.contains('T')) {
        tips.add('使用邏輯和事實來支持你的觀點');
        tips.add('保持客觀和理性的討論方式');
        suggestions.add('分享你的目標和計劃');
      } else {
        tips.add('表達你的感受和價值觀');
        tips.add('展現同理心和理解');
        suggestions.add('分享個人經歷和情感故事');
      }

      // 感知偏好 (J/P)
      if (partnerMBTI.contains('J')) {
        tips.add('討論具體的計劃和目標');
        tips.add('展現你的組織能力和決斷力');
      } else {
        tips.add('保持開放和靈活的態度');
        tips.add('探索各種可能性和選項');
      }
    }

    // 通用對話技巧
    tips.addAll([
      '問開放式問題，鼓勵深度分享',
      '分享你的真實想法和感受',
      '避免爭論，尊重不同觀點',
      '使用積極的肢體語言',
      '適時給予讚美和肯定',
    ]);

    // 話題建議
    suggestions.addAll([
      '分享童年有趣的回憶',
      '討論未來的夢想和目標',
      '交流旅行經歷和想去的地方',
      '分享最近學到的新東西',
      '討論喜歡的書籍或電影',
    ]);

    return DatingAdvice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AdviceType.conversation,
      title: '完美對話指南',
      content: '良好的溝通是建立深度連結的關鍵。基於對方的性格特點，這些建議將幫助你們建立更深層的理解和連結。',
      tips: tips,
      metadata: {
        'suggestions': suggestions,
        'situation': situation,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
      },
      createdAt: DateTime.now(),
    );
  }

  /// 生成關係發展建議
  static Future<DatingAdvice> _generateRelationshipAdvice(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
  ) async {
    final userMBTI = userData['mbtiType'] as String?;
    final partnerMBTI = partnerData['mbtiType'] as String?;
    
    final tips = <String>[];
    final suggestions = <String>[];

    // 基於 MBTI 兼容性的關係建議
    if (userMBTI != null && partnerMBTI != null) {
      final compatibility = _calculateMBTICompatibility(userMBTI, partnerMBTI);
      
      if (compatibility >= 0.8) {
        tips.add('你們的性格高度互補，要珍惜這種天然的和諧');
        suggestions.add('建立共同的長期目標和價值觀');
      } else if (compatibility >= 0.6) {
        tips.add('你們有良好的基礎，需要更多溝通和理解');
        suggestions.add('學習欣賞彼此的不同之處');
      } else {
        tips.add('差異可以帶來成長，關鍵是相互尊重和包容');
        suggestions.add('專注於共同點，耐心處理分歧');
      }
    }

    // 通用關係建議
    tips.addAll([
      '保持開放和誠實的溝通',
      '給彼此足夠的個人空間',
      '定期表達感謝和欣賞',
      '一起創造美好的回憶',
      '支持對方的個人成長',
    ]);

    suggestions.addAll([
      '建立定期的約會時間',
      '分享日常生活的小細節',
      '一起嘗試新的活動和體驗',
      '討論未來的計劃和期望',
      '建立共同的興趣愛好',
    ]);

    return DatingAdvice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AdviceType.relationship,
      title: '關係發展指南',
      content: '健康的關係需要時間、努力和相互理解。這些建議將幫助你們建立更深層、更持久的連結。',
      tips: tips,
      metadata: {
        'suggestions': suggestions,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
      },
      createdAt: DateTime.now(),
    );
  }

  /// 生成衝突解決建議
  static Future<DatingAdvice> _generateConflictResolutionAdvice(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
    String? situation,
  ) async {
    final tips = <String>[
      '保持冷靜，避免情緒化的反應',
      '專注於問題本身，而不是人身攻擊',
      '使用"我"的表達方式，而不是"你"的指責',
      '傾聽對方的觀點，嘗試理解他們的感受',
      '尋找雙贏的解決方案',
      '必要時暫停討論，給彼此冷靜的時間',
      '事後進行反思和總結',
    ];

    final suggestions = <String>[
      '選擇合適的時間和地點進行討論',
      '明確表達你的需求和期望',
      '承認自己的錯誤和不足',
      '尋求專業幫助（如需要）',
      '制定預防類似問題的計劃',
    ];

    return DatingAdvice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AdviceType.conflict,
      title: '衝突解決指南',
      content: '衝突是關係中的正常現象，關鍵是如何以建設性的方式處理。這些策略將幫助你們化解分歧，增強關係。',
      tips: tips,
      metadata: {
        'suggestions': suggestions,
        'situation': situation,
      },
      createdAt: DateTime.now(),
    );
  }

  /// 生成長期關係建議
  static Future<DatingAdvice> _generateLongTermAdvice(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
  ) async {
    final tips = <String>[
      '保持關係的新鮮感和激情',
      '建立共同的生活目標和價值觀',
      '定期評估和調整關係期望',
      '培養獨立性，同時增進親密感',
      '學會處理生活壓力和挑戰',
      '保持身心健康，為關係注入活力',
      '建立支持網絡，包括朋友和家人',
    ];

    final suggestions = <String>[
      '制定共同的財務計劃',
      '討論家庭和事業的平衡',
      '規劃定期的旅行和冒險',
      '建立傳統和儀式感',
      '持續學習和成長',
      '保持浪漫和驚喜',
    ];

    return DatingAdvice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AdviceType.longTerm,
      title: '長期關係維護指南',
      content: '長期關係需要持續的投入和維護。這些建議將幫助你們建立穩固、幸福的長期伴侶關係。',
      tips: tips,
      metadata: {
        'suggestions': suggestions,
      },
      createdAt: DateTime.now(),
    );
  }

  /// 分析溝通模式
  static Future<CommunicationAnalysis> analyzeCommunication({
    required String chatId,
    required String partnerUserId,
  }) async {
    try {
      // 獲取聊天記錄
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (messages.docs.isEmpty) {
        throw Exception('沒有足夠的聊天記錄進行分析');
      }

      // 分析消息模式
      final currentUserId = _auth.currentUser!.uid;
      int userMessages = 0;
      int partnerMessages = 0;
      int totalLength = 0;
      List<String> userWords = [];
      List<String> partnerWords = [];

      for (final doc in messages.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String;
        final content = data['content'] as String;
        
        if (senderId == currentUserId) {
          userMessages++;
          userWords.addAll(content.split(' '));
        } else {
          partnerMessages++;
          partnerWords.addAll(content.split(' '));
        }
        totalLength += content.length;
      }

      // 計算兼容性分數
      final messageBalance = (userMessages / (userMessages + partnerMessages) - 0.5).abs();
      final compatibilityScore = (1.0 - messageBalance * 2).clamp(0.0, 1.0);

      // 分析溝通風格
      String communicationStyle;
      if (messageBalance < 0.1) {
        communicationStyle = '平衡互動型';
      } else if (userMessages > partnerMessages) {
        communicationStyle = '主動表達型';
      } else {
        communicationStyle = '傾聽回應型';
      }

      // 生成建議
      final strengths = <String>[];
      final improvements = <String>[];
      final suggestions = <String>[];

      if (compatibilityScore >= 0.8) {
        strengths.add('溝通頻率平衡，互動良好');
        suggestions.add('保持現有的溝通模式');
      } else {
        improvements.add('調整消息頻率，增進互動平衡');
        suggestions.add('鼓勵較少發言的一方多表達');
      }

      return CommunicationAnalysis(
        compatibilityScore: compatibilityScore,
        communicationStyle: communicationStyle,
        strengths: strengths,
        improvements: improvements,
        suggestions: suggestions,
      );
    } catch (e) {
      throw Exception('溝通分析失敗: $e');
    }
  }

  /// 獲取每日關係提示
  static Future<String> getDailyRelationshipTip() async {
    final tips = [
      '今天給你的伴侶一個意外的讚美',
      '分享一個你今天學到的新東西',
      '問問對方今天最開心的事情',
      '表達你對這段關係的感謝',
      '計劃一個小驚喜或浪漫的舉動',
      '傾聽對方的想法，不要急於給建議',
      '分享一個童年的美好回憶',
      '一起做一件你們都沒嘗試過的事',
    ];

    final random = DateTime.now().day % tips.length;
    return tips[random];
  }

  /// 計算 MBTI 兼容性（簡化版）
  static double _calculateMBTICompatibility(String type1, String type2) {
    if (type1 == type2) return 0.8;
    
    // 簡化的兼容性計算
    int compatibility = 0;
    for (int i = 0; i < 4; i++) {
      if (type1[i] != type2[i]) compatibility++;
    }
    
    // 2-3個差異通常有較好的互補性
    switch (compatibility) {
      case 0: return 0.8;  // 完全相同
      case 1: return 0.7;  // 1個差異
      case 2: return 0.9;  // 2個差異（最佳互補）
      case 3: return 0.8;  // 3個差異
      case 4: return 0.6;  // 完全相反
      default: return 0.5;
    }
  }
} 