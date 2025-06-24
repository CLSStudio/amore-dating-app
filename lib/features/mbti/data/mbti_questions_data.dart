import '../models/mbti_question.dart';

class MBTIQuestionsData {
  static List<MBTIQuestion> getQuestions([TestMode mode = TestMode.simple]) {
    return [
      // 外向性 vs 內向性 (E/I)
      const MBTIQuestion(
        id: 'ei_1',
        category: 'E/I',
        question: '在聚會中，你通常會：',
        mode: TestMode.both,
        priority: 5,
        answers: [
          MBTIAnswer(id: 'ei_1_a', text: '主動與陌生人交談，享受認識新朋友', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_1_b', text: '與幾個熟悉的朋友深入交談', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_1_c', text: '觀察周圍的人和環境', type: 'I', weight: 2),
          MBTIAnswer(id: 'ei_1_d', text: '在人群中感到精力充沛', type: 'E', weight: 2),
        ],
      ),
      
      const MBTIQuestion(
        id: 'ei_2',
        category: 'E/I',
        question: '當你需要解決問題時，你傾向於：',
        mode: TestMode.both,
        priority: 4,
        answers: [
          MBTIAnswer(id: 'ei_2_a', text: '與他人討論，集思廣益', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_2_b', text: '獨自思考，仔細分析', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_2_c', text: '先思考再與信任的人討論', type: 'I', weight: 2),
          MBTIAnswer(id: 'ei_2_d', text: '邊說邊想，通過交流理清思路', type: 'E', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_3',
        category: 'E/I',
        question: '週末你更喜歡：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'ei_3_a', text: '參加朋友聚會或戶外活動', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_3_b', text: '在家看書、看電影或做興趣愛好', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_3_c', text: '與一兩個親密朋友安靜地相處', type: 'I', weight: 2),
          MBTIAnswer(id: 'ei_3_d', text: '探索新的地方和體驗', type: 'E', weight: 2),
        ],
      ),

      // 感覺 vs 直覺 (S/N)
      const MBTIQuestion(
        id: 'sn_1',
        category: 'S/N',
        question: '在學習新事物時，你更注重：',
        mode: TestMode.both,
        priority: 5,
        answers: [
          MBTIAnswer(id: 'sn_1_a', text: '具體的事實和細節', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_1_b', text: '整體概念和可能性', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_1_c', text: '實際應用和操作步驟', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_1_d', text: '理論背景和創新想法', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_2',
        category: 'S/N',
        question: '當描述一個地方時，你會：',
        mode: TestMode.both,
        priority: 4,
        answers: [
          MBTIAnswer(id: 'sn_2_a', text: '詳細描述具體的景象、聲音和感受', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_2_b', text: '描述整體氛圍和給你的印象', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_2_c', text: '提到實用信息如交通、價格等', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_2_d', text: '聯想到其他相似的地方或體驗', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_3',
        category: 'S/N',
        question: '在工作中，你更喜歡：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'sn_3_a', text: '按照既定程序和標準操作', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_3_b', text: '探索新方法和創新解決方案', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_3_c', text: '處理具體、實際的任務', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_3_d', text: '思考未來的可能性和改進', type: 'N', weight: 2),
        ],
      ),

      // 思考 vs 情感 (T/F)
      const MBTIQuestion(
        id: 'tf_1',
        category: 'T/F',
        question: '做重要決定時，你主要依據：',
        mode: TestMode.both,
        priority: 5,
        answers: [
          MBTIAnswer(id: 'tf_1_a', text: '邏輯分析和客觀事實', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_1_b', text: '個人價值觀和對他人的影響', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_1_c', text: '理性的利弊權衡', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_1_d', text: '內心的感受和直覺', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_2',
        category: 'T/F',
        question: '當朋友向你尋求建議時，你會：',
        mode: TestMode.both,
        priority: 4,
        answers: [
          MBTIAnswer(id: 'tf_2_a', text: '客觀分析問題並提供解決方案', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_2_b', text: '傾聽並給予情感支持', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_2_c', text: '指出問題的關鍵點', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_2_d', text: '理解他們的感受並鼓勵', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_3',
        category: 'T/F',
        question: '在團隊衝突中，你傾向於：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'tf_3_a', text: '專注於事實和邏輯來解決分歧', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_3_b', text: '關注每個人的感受和需求', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_3_c', text: '尋找最有效率的解決方案', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_3_d', text: '努力維護團隊和諧', type: 'F', weight: 2),
        ],
      ),

      // 判斷 vs 感知 (J/P)
      const MBTIQuestion(
        id: 'jp_1',
        category: 'J/P',
        question: '對於計劃，你的態度是：',
        mode: TestMode.both,
        priority: 5,
        answers: [
          MBTIAnswer(id: 'jp_1_a', text: '喜歡制定詳細計劃並嚴格執行', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_1_b', text: '保持靈活性，隨機應變', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_1_c', text: '有基本框架但允許調整', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_1_d', text: '享受自發性和驚喜', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_2',
        category: 'J/P',
        question: '在工作環境中，你更喜歡：',
        mode: TestMode.both,
        priority: 4,
        answers: [
          MBTIAnswer(id: 'jp_2_a', text: '明確的截止日期和結構化任務', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_2_b', text: '開放式任務和彈性時間', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_2_c', text: '有序的工作流程', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_2_d', text: '多樣化和變化的工作內容', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_3',
        category: 'J/P',
        question: '面對未完成的任務，你會：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'jp_3_a', text: '感到不安，優先完成它們', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_3_b', text: '保持冷靜，在截止日期前完成', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_3_c', text: '制定時間表逐步完成', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_3_d', text: '在壓力下工作效率更高', type: 'P', weight: 2),
        ],
      ),
    ];
  }

  static Map<String, String> getMBTIDescriptions() {
    return {
      'ENFP': '熱情洋溢的激勵者 - 充滿創意和可能性，善於激勵他人',
      'ENFJ': '熱情的教導者 - 關懷他人，善於引導和啟發',
      'ENTP': '富有創意的辯論家 - 聰明好奇，喜歡探索新想法',
      'ENTJ': '果斷的領導者 - 天生的領導者，善於組織和指揮',
      'ESFP': '自由奔放的表演者 - 熱愛生活，善於娛樂他人',
      'ESFJ': '熱心的支持者 - 關心他人福祉，善於照顧和協調',
      'ESTP': '精力充沛的實踐家 - 行動派，善於解決實際問題',
      'ESTJ': '嚴謹的管理者 - 實用主義者，善於組織和管理',
      'INFP': '理想主義的治療師 - 追求內在和諧，富有同情心',
      'INFJ': '深刻的諮詢師 - 具有洞察力，關心他人的成長',
      'INTP': '邏輯的思想家 - 理論家，喜歡分析和理解',
      'INTJ': '獨立的戰略家 - 有遠見，善於制定長期計劃',
      'ISFP': '溫和的藝術家 - 敏感細膩，追求美和和諧',
      'ISFJ': '忠誠的保護者 - 可靠負責，善於照顧他人',
      'ISTP': '靈活的工匠 - 實用主義者，善於解決技術問題',
      'ISTJ': '可靠的檢查員 - 務實穩重，注重細節和責任',
    };
  }

  static Map<String, List<String>> getMBTITraits() {
    return {
      'ENFP': ['創意豐富', '熱情洋溢', '善於溝通', '靈活適應', '關心他人'],
      'ENFJ': ['富有同情心', '善於教導', '組織能力強', '理想主義', '人際關係佳'],
      'ENTP': ['創新思維', '辯論能力強', '適應性強', '好奇心旺盛', '邏輯思維'],
      'ENTJ': ['天生領導者', '戰略思維', '決斷力強', '目標導向', '組織能力'],
      'ESFP': ['熱愛生活', '善於表演', '關心他人', '靈活性強', '樂觀積極'],
      'ESFJ': ['關懷他人', '責任感強', '組織能力', '傳統價值', '團隊合作'],
      'ESTP': ['行動力強', '實用主義', '適應能力', '危機處理', '社交能力'],
      'ESTJ': ['組織能力強', '責任感', '實用主義', '決斷力', '傳統價值'],
      'INFP': ['理想主義', '創意思維', '同情心強', '價值觀明確', '獨立性'],
      'INFJ': ['洞察力強', '理想主義', '同情心', '創意思維', '組織能力'],
      'INTP': ['邏輯思維', '理論思考', '獨立性強', '好奇心', '分析能力'],
      'INTJ': ['戰略思維', '獨立性', '創新能力', '長遠規劃', '決斷力'],
      'ISFP': ['藝術天賦', '同情心', '靈活性', '價值觀強', '和諧追求'],
      'ISFJ': ['責任感強', '關懷他人', '細心周到', '傳統價值', '忠誠度高'],
      'ISTP': ['實用技能', '邏輯思維', '獨立性', '適應能力', '問題解決'],
      'ISTJ': ['責任感', '細節導向', '可靠性', '組織能力', '傳統價值'],
    };
  }
} 