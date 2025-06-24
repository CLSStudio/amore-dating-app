import '../../domain/entities/values_assessment.dart';

/// 價值觀問題數據源
class ValuesQuestionsData {
  static List<ValuesQuestion> getQuestions() {
    return [
      // 家庭 vs 事業
      const ValuesQuestion(
        id: 'family_career_1',
        question: '在人生的重要決定中，您更傾向於：',
        description: '這個問題幫助我們了解您對家庭和事業的優先級',
        category: ValueCategory.family,
        order: 1,
        options: [
          ValuesOption(
            id: 'family_career_1_a',
            text: '優先考慮家庭需要和親人感受',
            score: 5,
          ),
          ValuesOption(
            id: 'family_career_1_b',
            text: '在家庭和事業之間尋求平衡',
            score: 3,
          ),
          ValuesOption(
            id: 'family_career_1_c',
            text: '優先考慮職業發展和個人成就',
            score: 1,
          ),
        ],
      ),

      // 穩定 vs 冒險
      const ValuesQuestion(
        id: 'stability_adventure_1',
        question: '對於未來的生活規劃，您更喜歡：',
        description: '了解您對穩定性和冒險的態度',
        category: ValueCategory.stability,
        order: 2,
        options: [
          ValuesOption(
            id: 'stability_adventure_1_a',
            text: '制定詳細的長期計劃並嚴格執行',
            score: 5,
          ),
          ValuesOption(
            id: 'stability_adventure_1_b',
            text: '有基本規劃但保持靈活性',
            score: 3,
          ),
          ValuesOption(
            id: 'stability_adventure_1_c',
            text: '隨心而行，享受不確定性帶來的驚喜',
            score: 1,
          ),
        ],
      ),

      // 財富 vs 自由
      const ValuesQuestion(
        id: 'wealth_freedom_1',
        question: '如果必須在以下兩者中選擇，您會選擇：',
        description: '探索您對物質財富和個人自由的重視程度',
        category: ValueCategory.wealth,
        order: 3,
        options: [
          ValuesOption(
            id: 'wealth_freedom_1_a',
            text: '高薪但工作時間長、限制較多的工作',
            score: 5,
          ),
          ValuesOption(
            id: 'wealth_freedom_1_b',
            text: '薪水適中但有彈性和自主權的工作',
            score: 3,
          ),
          ValuesOption(
            id: 'wealth_freedom_1_c',
            text: '薪水較低但完全自由的工作',
            score: 1,
          ),
        ],
      ),

      // 個人成長 vs 人際關係
      const ValuesQuestion(
        id: 'growth_relationships_1',
        question: '在空閒時間，您更願意：',
        description: '了解您對個人發展和社交關係的偏好',
        category: ValueCategory.personalGrowth,
        order: 4,
        options: [
          ValuesOption(
            id: 'growth_relationships_1_a',
            text: '獨自學習新技能或閱讀',
            score: 5,
          ),
          ValuesOption(
            id: 'growth_relationships_1_b',
            text: '參加學習小組或工作坊',
            score: 3,
          ),
          ValuesOption(
            id: 'growth_relationships_1_c',
            text: '與朋友聚會或社交活動',
            score: 1,
          ),
        ],
      ),

      // 創造力 vs 穩定
      const ValuesQuestion(
        id: 'creativity_stability_1',
        question: '在工作環境中，您更喜歡：',
        description: '探索您對創新和穩定工作環境的偏好',
        category: ValueCategory.creativity,
        order: 5,
        options: [
          ValuesOption(
            id: 'creativity_stability_1_a',
            text: '充滿創意挑戰但不可預測的項目',
            score: 5,
          ),
          ValuesOption(
            id: 'creativity_stability_1_b',
            text: '有創意空間但結構清晰的工作',
            score: 3,
          ),
          ValuesOption(
            id: 'creativity_stability_1_c',
            text: '程序化、可預測的日常工作',
            score: 1,
          ),
        ],
      ),

      // 健康 vs 享樂
      const ValuesQuestion(
        id: 'health_pleasure_1',
        question: '對於生活方式，您更傾向於：',
        description: '了解您對健康生活和即時享樂的態度',
        category: ValueCategory.health,
        order: 6,
        options: [
          ValuesOption(
            id: 'health_pleasure_1_a',
            text: '嚴格的健康飲食和運動計劃',
            score: 5,
          ),
          ValuesOption(
            id: 'health_pleasure_1_b',
            text: '健康生活但偶爾放縱',
            score: 3,
          ),
          ValuesOption(
            id: 'health_pleasure_1_c',
            text: '享受當下，不過分限制自己',
            score: 1,
          ),
        ],
      ),

      // 社會影響 vs 個人利益
      const ValuesQuestion(
        id: 'social_impact_personal_1',
        question: '在選擇職業時，您更重視：',
        description: '探索您對社會貢獻和個人利益的平衡',
        category: ValueCategory.socialImpact,
        order: 7,
        options: [
          ValuesOption(
            id: 'social_impact_personal_1_a',
            text: '能夠幫助他人和改善社會的工作',
            score: 5,
          ),
          ValuesOption(
            id: 'social_impact_personal_1_b',
            text: '既有社會價值又有個人回報的工作',
            score: 3,
          ),
          ValuesOption(
            id: 'social_impact_personal_1_c',
            text: '能夠實現個人目標和財務成功的工作',
            score: 1,
          ),
        ],
      ),

      // 精神信仰 vs 物質主義
      const ValuesQuestion(
        id: 'spirituality_materialism_1',
        question: '對於人生意義，您更相信：',
        description: '了解您的精神價值觀和物質觀念',
        category: ValueCategory.spirituality,
        order: 8,
        options: [
          ValuesOption(
            id: 'spirituality_materialism_1_a',
            text: '內在平靜和精神成長最重要',
            score: 5,
          ),
          ValuesOption(
            id: 'spirituality_materialism_1_b',
            text: '精神和物質生活都很重要',
            score: 3,
          ),
          ValuesOption(
            id: 'spirituality_materialism_1_c',
            text: '物質成就和現實目標更實際',
            score: 1,
          ),
        ],
      ),

      // 家庭責任深度問題
      const ValuesQuestion(
        id: 'family_2',
        question: '關於未來的家庭規劃，您認為：',
        description: '深入了解您對家庭責任的看法',
        category: ValueCategory.family,
        order: 9,
        options: [
          ValuesOption(
            id: 'family_2_a',
            text: '家庭是人生最重要的部分，願意為此犧牲其他',
            score: 5,
          ),
          ValuesOption(
            id: 'family_2_b',
            text: '家庭很重要，但也要保持個人空間',
            score: 3,
          ),
          ValuesOption(
            id: 'family_2_c',
            text: '重視家庭，但個人發展同樣重要',
            score: 1,
          ),
        ],
      ),

      // 事業野心
      const ValuesQuestion(
        id: 'career_2',
        question: '對於職業成就，您的態度是：',
        description: '了解您的事業野心和職業目標',
        category: ValueCategory.career,
        order: 10,
        options: [
          ValuesOption(
            id: 'career_2_a',
            text: '追求卓越，希望在專業領域達到頂峰',
            score: 5,
          ),
          ValuesOption(
            id: 'career_2_b',
            text: '希望有穩定發展和合理晉升',
            score: 3,
          ),
          ValuesOption(
            id: 'career_2_c',
            text: '工作只是生活的一部分，不是全部',
            score: 1,
          ),
        ],
      ),

      // 冒險精神
      const ValuesQuestion(
        id: 'adventure_2',
        question: '面對新的機會和挑戰時，您通常：',
        description: '評估您的冒險精神和風險承受能力',
        category: ValueCategory.adventure,
        order: 11,
        options: [
          ValuesOption(
            id: 'adventure_2_a',
            text: '興奮地接受，享受未知的刺激',
            score: 5,
          ),
          ValuesOption(
            id: 'adventure_2_b',
            text: '謹慎評估後再決定',
            score: 3,
          ),
          ValuesOption(
            id: 'adventure_2_c',
            text: '傾向於選擇熟悉和安全的選項',
            score: 1,
          ),
        ],
      ),

      // 人際關係深度
      const ValuesQuestion(
        id: 'relationships_2',
        question: '在人際關係中，您最重視：',
        description: '探索您對人際關係的深度需求',
        category: ValueCategory.relationships,
        order: 12,
        options: [
          ValuesOption(
            id: 'relationships_2_a',
            text: '深度的情感連結和相互理解',
            score: 5,
          ),
          ValuesOption(
            id: 'relationships_2_b',
            text: '真誠的友誼和相互支持',
            score: 3,
          ),
          ValuesOption(
            id: 'relationships_2_c',
            text: '廣泛的社交網絡和多樣化的關係',
            score: 1,
          ),
        ],
      ),
    ];
  }

  /// 計算價值觀評估結果
  static ValuesAssessment calculateResult(
    Map<String, String> answers,
    String userId,
  ) {
    final scores = <ValueCategory, int>{};
    
    // 初始化所有類別的分數
    for (final category in ValueCategory.values) {
      scores[category] = 0;
    }

    final questions = getQuestions();
    
    for (final question in questions) {
      final answerId = answers[question.id];
      if (answerId != null) {
        final selectedOption = question.options.firstWhere(
          (option) => option.id == answerId,
          orElse: () => question.options.first,
        );
        
        // 根據問題類別增加分數
        scores[question.category] = 
            (scores[question.category] ?? 0) + selectedOption.score;
      }
    }

    // 正規化分數到 0-100 範圍
    final normalizedScores = <ValueCategory, int>{};
    for (final entry in scores.entries) {
      // 每個類別最多有幾個問題，計算最大可能分數
      final questionsInCategory = questions
          .where((q) => q.category == entry.key)
          .length;
      final maxScore = questionsInCategory * 5; // 每題最高5分
      
      if (maxScore > 0) {
        normalizedScores[entry.key] = 
            ((entry.value / maxScore) * 100).round().clamp(0, 100);
      } else {
        normalizedScores[entry.key] = 0;
      }
    }

    return ValuesAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      scores: normalizedScores,
      answers: answers,
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// 獲取價值觀建議
  static List<String> getValuesSuggestions(ValuesAssessment assessment) {
    final topValues = assessment.topValues;
    final suggestions = <String>[];

    for (final value in topValues) {
      switch (value) {
        case ValueCategory.family:
          suggestions.add('考慮尋找同樣重視家庭的伴侶');
          suggestions.add('在約會時分享您的家庭價值觀');
          break;
        case ValueCategory.career:
          suggestions.add('尋找有共同職業目標的伴侶');
          suggestions.add('討論彼此的事業規劃和支持方式');
          break;
        case ValueCategory.adventure:
          suggestions.add('尋找喜歡探索和嘗試新事物的伴侶');
          suggestions.add('計劃一些冒險性的約會活動');
          break;
        case ValueCategory.stability:
          suggestions.add('重視可靠性和一致性的關係');
          suggestions.add('尋找生活目標明確的伴侶');
          break;
        case ValueCategory.creativity:
          suggestions.add('尋找欣賞藝術和創新的伴侶');
          suggestions.add('分享您的創意項目和興趣');
          break;
        case ValueCategory.spirituality:
          suggestions.add('討論精神信仰和人生哲學');
          suggestions.add('尋找有相似精神追求的伴侶');
          break;
        case ValueCategory.health:
          suggestions.add('尋找重視健康生活方式的伴侶');
          suggestions.add('一起參與運動和健康活動');
          break;
        case ValueCategory.wealth:
          suggestions.add('討論財務目標和金錢觀念');
          suggestions.add('尋找有相似經濟目標的伴侶');
          break;
        case ValueCategory.freedom:
          suggestions.add('重視個人空間和獨立性');
          suggestions.add('尋找理解並支持您自由的伴侶');
          break;
        case ValueCategory.socialImpact:
          suggestions.add('尋找有社會責任感的伴侶');
          suggestions.add('一起參與公益活動');
          break;
        case ValueCategory.personalGrowth:
          suggestions.add('尋找支持個人發展的伴侶');
          suggestions.add('一起學習和成長');
          break;
        case ValueCategory.relationships:
          suggestions.add('重視深度情感連結');
          suggestions.add('投資時間建立有意義的關係');
          break;
      }
    }

    return suggestions;
  }
} 