import '../../domain/entities/mbti_question.dart';

/// MBTI 測試問題數據源
class MbtiQuestionsData {
  static List<MbtiQuestion> getQuestions() {
    return [
      // 外向-內向 (E-I) 問題
      const MbtiQuestion(
        id: 'ei_1',
        question: '在聚會中，你通常會：',
        dimension: MbtiDimension.extraversionIntroversion,
        order: 1,
        options: [
          MbtiOption(
            id: 'ei_1_a',
            text: '主動與很多人交談，享受社交',
            type: MbtiType.extraversion,
            score: 3,
          ),
          MbtiOption(
            id: 'ei_1_b',
            text: '與少數幾個人深入交談',
            type: MbtiType.introversion,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'ei_2',
        question: '當你需要充電時，你更喜歡：',
        dimension: MbtiDimension.extraversionIntroversion,
        order: 2,
        options: [
          MbtiOption(
            id: 'ei_2_a',
            text: '和朋友出去活動',
            type: MbtiType.extraversion,
            score: 3,
          ),
          MbtiOption(
            id: 'ei_2_b',
            text: '獨自安靜地待著',
            type: MbtiType.introversion,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'ei_3',
        question: '在工作中，你更傾向於：',
        dimension: MbtiDimension.extraversionIntroversion,
        order: 3,
        options: [
          MbtiOption(
            id: 'ei_3_a',
            text: '在開放的環境中與同事互動',
            type: MbtiType.extraversion,
            score: 2,
          ),
          MbtiOption(
            id: 'ei_3_b',
            text: '在安靜的環境中專注工作',
            type: MbtiType.introversion,
            score: 2,
          ),
        ],
      ),
      
      // 感覺-直覺 (S-N) 問題
      const MbtiQuestion(
        id: 'sn_1',
        question: '當學習新事物時，你更喜歡：',
        dimension: MbtiDimension.sensingIntuition,
        order: 4,
        options: [
          MbtiOption(
            id: 'sn_1_a',
            text: '從具體的例子和實際應用開始',
            type: MbtiType.sensing,
            score: 3,
          ),
          MbtiOption(
            id: 'sn_1_b',
            text: '先了解整體概念和理論',
            type: MbtiType.intuition,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'sn_2',
        question: '你更信任：',
        dimension: MbtiDimension.sensingIntuition,
        order: 5,
        options: [
          MbtiOption(
            id: 'sn_2_a',
            text: '經驗和已被證實的方法',
            type: MbtiType.sensing,
            score: 3,
          ),
          MbtiOption(
            id: 'sn_2_b',
            text: '直覺和新的可能性',
            type: MbtiType.intuition,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'sn_3',
        question: '在描述事情時，你更傾向於：',
        dimension: MbtiDimension.sensingIntuition,
        order: 6,
        options: [
          MbtiOption(
            id: 'sn_3_a',
            text: '提供具體的細節和事實',
            type: MbtiType.sensing,
            score: 2,
          ),
          MbtiOption(
            id: 'sn_3_b',
            text: '描述整體印象和含義',
            type: MbtiType.intuition,
            score: 2,
          ),
        ],
      ),
      
      // 思考-情感 (T-F) 問題
      const MbtiQuestion(
        id: 'tf_1',
        question: '做決定時，你更重視：',
        dimension: MbtiDimension.thinkingFeeling,
        order: 7,
        options: [
          MbtiOption(
            id: 'tf_1_a',
            text: '邏輯分析和客觀標準',
            type: MbtiType.thinking,
            score: 3,
          ),
          MbtiOption(
            id: 'tf_1_b',
            text: '人際關係和個人價值觀',
            type: MbtiType.feeling,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'tf_2',
        question: '當朋友遇到問題時，你更傾向於：',
        dimension: MbtiDimension.thinkingFeeling,
        order: 8,
        options: [
          MbtiOption(
            id: 'tf_2_a',
            text: '幫助分析問題並提供解決方案',
            type: MbtiType.thinking,
            score: 3,
          ),
          MbtiOption(
            id: 'tf_2_b',
            text: '提供情感支持和理解',
            type: MbtiType.feeling,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'tf_3',
        question: '你更看重：',
        dimension: MbtiDimension.thinkingFeeling,
        order: 9,
        options: [
          MbtiOption(
            id: 'tf_3_a',
            text: '公平和一致性',
            type: MbtiType.thinking,
            score: 2,
          ),
          MbtiOption(
            id: 'tf_3_b',
            text: '和諧和個人考量',
            type: MbtiType.feeling,
            score: 2,
          ),
        ],
      ),
      
      // 判斷-知覺 (J-P) 問題
      const MbtiQuestion(
        id: 'jp_1',
        question: '你更喜歡：',
        dimension: MbtiDimension.judgingPerceiving,
        order: 10,
        options: [
          MbtiOption(
            id: 'jp_1_a',
            text: '制定計劃並按計劃執行',
            type: MbtiType.judging,
            score: 3,
          ),
          MbtiOption(
            id: 'jp_1_b',
            text: '保持靈活性，隨機應變',
            type: MbtiType.perceiving,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'jp_2',
        question: '在工作中，你更傾向於：',
        dimension: MbtiDimension.judgingPerceiving,
        order: 11,
        options: [
          MbtiOption(
            id: 'jp_2_a',
            text: '提前完成任務，避免最後期限的壓力',
            type: MbtiType.judging,
            score: 3,
          ),
          MbtiOption(
            id: 'jp_2_b',
            text: '在截止日期前工作，享受時間壓力',
            type: MbtiType.perceiving,
            score: 3,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'jp_3',
        question: '你的生活方式更像：',
        dimension: MbtiDimension.judgingPerceiving,
        order: 12,
        options: [
          MbtiOption(
            id: 'jp_3_a',
            text: '有組織、有結構的',
            type: MbtiType.judging,
            score: 2,
          ),
          MbtiOption(
            id: 'jp_3_b',
            text: '自發的、適應性強的',
            type: MbtiType.perceiving,
            score: 2,
          ),
        ],
      ),
      
      // 額外的深度問題
      const MbtiQuestion(
        id: 'ei_4',
        question: '在會議中，你更可能：',
        dimension: MbtiDimension.extraversionIntroversion,
        order: 13,
        options: [
          MbtiOption(
            id: 'ei_4_a',
            text: '積極發言，分享想法',
            type: MbtiType.extraversion,
            score: 2,
          ),
          MbtiOption(
            id: 'ei_4_b',
            text: '仔細聆聽，深思後發言',
            type: MbtiType.introversion,
            score: 2,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'sn_4',
        question: '你更喜歡的書籍類型：',
        dimension: MbtiDimension.sensingIntuition,
        order: 14,
        options: [
          MbtiOption(
            id: 'sn_4_a',
            text: '實用指南和傳記',
            type: MbtiType.sensing,
            score: 2,
          ),
          MbtiOption(
            id: 'sn_4_b',
            text: '科幻小說和哲學書籍',
            type: MbtiType.intuition,
            score: 2,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'tf_4',
        question: '在衝突中，你更傾向於：',
        dimension: MbtiDimension.thinkingFeeling,
        order: 15,
        options: [
          MbtiOption(
            id: 'tf_4_a',
            text: '專注於事實和邏輯',
            type: MbtiType.thinking,
            score: 2,
          ),
          MbtiOption(
            id: 'tf_4_b',
            text: '考慮每個人的感受',
            type: MbtiType.feeling,
            score: 2,
          ),
        ],
      ),
      
      const MbtiQuestion(
        id: 'jp_4',
        question: '對於變化，你的態度是：',
        dimension: MbtiDimension.judgingPerceiving,
        order: 16,
        options: [
          MbtiOption(
            id: 'jp_4_a',
            text: '需要時間適應，喜歡穩定',
            type: MbtiType.judging,
            score: 2,
          ),
          MbtiOption(
            id: 'jp_4_b',
            text: '歡迎變化，享受新體驗',
            type: MbtiType.perceiving,
            score: 2,
          ),
        ],
      ),
    ];
  }
  
  /// 計算 MBTI 結果
  static MbtiResult calculateResult(Map<String, String> answers, String userId) {
    final scores = <MbtiDimension, int>{
      MbtiDimension.extraversionIntroversion: 0,
      MbtiDimension.sensingIntuition: 0,
      MbtiDimension.thinkingFeeling: 0,
      MbtiDimension.judgingPerceiving: 0,
    };
    
    final questions = getQuestions();
    
    for (final question in questions) {
      final answerId = answers[question.id];
      if (answerId != null) {
        final selectedOption = question.options.firstWhere(
          (option) => option.id == answerId,
          orElse: () => question.options.first,
        );
        
        // 根據選項類型增加相應維度的分數
        switch (selectedOption.type) {
          case MbtiType.extraversion:
            scores[MbtiDimension.extraversionIntroversion] = 
                (scores[MbtiDimension.extraversionIntroversion] ?? 0) + selectedOption.score;
            break;
          case MbtiType.introversion:
            scores[MbtiDimension.extraversionIntroversion] = 
                (scores[MbtiDimension.extraversionIntroversion] ?? 0) - selectedOption.score;
            break;
          case MbtiType.sensing:
            scores[MbtiDimension.sensingIntuition] = 
                (scores[MbtiDimension.sensingIntuition] ?? 0) - selectedOption.score;
            break;
          case MbtiType.intuition:
            scores[MbtiDimension.sensingIntuition] = 
                (scores[MbtiDimension.sensingIntuition] ?? 0) + selectedOption.score;
            break;
          case MbtiType.thinking:
            scores[MbtiDimension.thinkingFeeling] = 
                (scores[MbtiDimension.thinkingFeeling] ?? 0) + selectedOption.score;
            break;
          case MbtiType.feeling:
            scores[MbtiDimension.thinkingFeeling] = 
                (scores[MbtiDimension.thinkingFeeling] ?? 0) - selectedOption.score;
            break;
          case MbtiType.judging:
            scores[MbtiDimension.judgingPerceiving] = 
                (scores[MbtiDimension.judgingPerceiving] ?? 0) + selectedOption.score;
            break;
          case MbtiType.perceiving:
            scores[MbtiDimension.judgingPerceiving] = 
                (scores[MbtiDimension.judgingPerceiving] ?? 0) - selectedOption.score;
            break;
        }
      }
    }
    
    // 確定 MBTI 類型
    String type = '';
    
    // E vs I
    type += (scores[MbtiDimension.extraversionIntroversion]! >= 0) ? 'E' : 'I';
    
    // S vs N
    type += (scores[MbtiDimension.sensingIntuition]! >= 0) ? 'N' : 'S';
    
    // T vs F
    type += (scores[MbtiDimension.thinkingFeeling]! >= 0) ? 'T' : 'F';
    
    // J vs P
    type += (scores[MbtiDimension.judgingPerceiving]! >= 0) ? 'J' : 'P';
    
    // 將分數轉換為百分比（0-100）
    final normalizedScores = <MbtiDimension, int>{};
    for (final entry in scores.entries) {
      normalizedScores[entry.key] = ((entry.value.abs() / 10.0) * 100).round().clamp(0, 100);
    }
    
    return MbtiResult(
      type: type,
      scores: normalizedScores,
      completedAt: DateTime.now(),
      userId: userId,
    );
  }
} 