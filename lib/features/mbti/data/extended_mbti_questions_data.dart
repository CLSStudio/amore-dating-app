import '../models/mbti_question.dart';

class ExtendedMBTIQuestionsData {
  static List<MBTIQuestion> getQuestions([TestMode mode = TestMode.simple]) {
    final allQuestions = _getAllQuestions();
    
    switch (mode) {
      case TestMode.simple:
        // 返回每個維度約4題，總共15題
        return _getQuestionsByMode(allQuestions, TestMode.simple, 4);
      case TestMode.professional:
        // 返回每個維度15題，總共60題
        return _getQuestionsByMode(allQuestions, TestMode.professional, 15);
      case TestMode.both:
        return allQuestions;
    }
  }

  static List<MBTIQuestion> _getQuestionsByMode(
    List<MBTIQuestion> allQuestions,
    TestMode targetMode,
    int questionsPerDimension,
  ) {
    final categories = ['E/I', 'S/N', 'T/F', 'J/P'];
    final result = <MBTIQuestion>[];

    if (targetMode == TestMode.simple) {
      // 簡單模式：總共15題，每個維度3-4題
      final questionsPerCategory = [4, 4, 4, 3]; // 總共15題
      
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final categoryQuestions = allQuestions
            .where((q) => q.category == category && 
                         (q.mode == targetMode || q.mode == TestMode.both))
            .toList();
        
        // 按優先級排序，取指定數量的題目
        categoryQuestions.sort((a, b) => b.priority.compareTo(a.priority));
        result.addAll(categoryQuestions.take(questionsPerCategory[i]));
      }
    } else {
      // 專業模式：每個維度固定數量
      for (final category in categories) {
        final categoryQuestions = allQuestions
            .where((q) => q.category == category && 
                         (q.mode == targetMode || q.mode == TestMode.both))
            .toList();
        
        // 按優先級排序，取前N題
        categoryQuestions.sort((a, b) => b.priority.compareTo(a.priority));
        result.addAll(categoryQuestions.take(questionsPerDimension));
      }
    }

    return result;
  }

  static List<MBTIQuestion> _getAllQuestions() {
    return [
      // ===== 外向性 vs 內向性 (E/I) =====
      
      // 簡單模式 + 專業模式 (高優先級)
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
        priority: 5,
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
        priority: 4,
        answers: [
          MBTIAnswer(id: 'ei_3_a', text: '參加朋友聚會或戶外活動', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_3_b', text: '在家看書、看電影或做興趣愛好', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_3_c', text: '與一兩個親密朋友安靜地相處', type: 'I', weight: 2),
          MBTIAnswer(id: 'ei_3_d', text: '探索新的地方和體驗', type: 'E', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_4',
        category: 'E/I',
        question: '在工作中，你更容易：',
        mode: TestMode.both,
        priority: 4,
        answers: [
          MBTIAnswer(id: 'ei_4_a', text: '通過與同事交流獲得靈感', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_4_b', text: '在安靜的環境中專注工作', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_4_c', text: '喜歡團隊合作和頭腦風暴', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_4_d', text: '需要獨處時間來恢復精力', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_5',
        category: 'E/I',
        question: '面對新環境時，你會：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'ei_5_a', text: '主動探索並與人交流', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_5_b', text: '先觀察再慢慢適應', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_5_c', text: '尋找熟悉的人或事物', type: 'I', weight: 2),
          MBTIAnswer(id: 'ei_5_d', text: '享受新鮮感和刺激', type: 'E', weight: 2),
        ],
      ),

      // 專業模式額外問題
      const MBTIQuestion(
        id: 'ei_6',
        category: 'E/I',
        question: '在學習新技能時，你偏好：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'ei_6_a', text: '參加小組學習或課程', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_6_b', text: '自己研究和練習', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_6_c', text: '通過討論加深理解', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_6_d', text: '需要安靜的學習環境', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_7',
        category: 'E/I',
        question: '壓力大的時候，你會：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'ei_7_a', text: '找朋友聊天尋求支持', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_7_b', text: '獨自處理和思考', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_7_c', text: '通過社交活動放鬆', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_7_d', text: '需要獨處時間恢復', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_8',
        category: 'E/I',
        question: '在會議中，你通常：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_8_a', text: '積極發言和分享想法', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_8_b', text: '仔細聆聽，深思後發言', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_8_c', text: '喜歡與他人互動討論', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_8_d', text: '更願意會後私下交流', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_9',
        category: 'E/I',
        question: '選擇工作環境時，你偏好：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_9_a', text: '開放式辦公室，便於交流', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_9_b', text: '獨立辦公室，減少干擾', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_9_c', text: '團隊協作空間', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_9_d', text: '安靜的專注環境', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_10',
        category: 'E/I',
        question: '在社交媒體上，你傾向於：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_10_a', text: '經常發布動態和互動', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_10_b', text: '主要瀏覽，較少發布', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_10_c', text: '喜歡評論和分享', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_10_d', text: '偏好私訊交流', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_11',
        category: 'E/I',
        question: '參加培訓課程時，你更喜歡：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_11_a', text: '小組討論和角色扮演', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_11_b', text: '個人練習和自主學習', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_11_c', text: '互動式工作坊', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_11_d', text: '理論講座和閱讀', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_12',
        category: 'E/I',
        question: '處理複雜問題時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_12_a', text: '立即與團隊討論', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_12_b', text: '先獨自分析再尋求意見', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_12_c', text: '通過對話理清思路', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_12_d', text: '需要安靜思考時間', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_13',
        category: 'E/I',
        question: '在團隊項目中，你的角色通常是：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'ei_13_a', text: '協調者和溝通橋樑', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_13_b', text: '專業貢獻者和分析師', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_13_c', text: '想法產生者和推動者', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_13_d', text: '深度研究和質量把關', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_14',
        category: 'E/I',
        question: '獲得認可時，你更重視：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'ei_14_a', text: '公開表揚和團隊認可', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_14_b', text: '私下肯定和個人成就感', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_14_c', text: '同事的讚賞和支持', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_14_d', text: '內在滿足和自我實現', type: 'I', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'ei_15',
        category: 'E/I',
        question: '面對變化時，你的第一反應是：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'ei_15_a', text: '與他人討論影響和對策', type: 'E', weight: 3),
          MBTIAnswer(id: 'ei_15_b', text: '獨自評估和適應', type: 'I', weight: 3),
          MBTIAnswer(id: 'ei_15_c', text: '尋求團隊支持', type: 'E', weight: 2),
          MBTIAnswer(id: 'ei_15_d', text: '需要時間消化和接受', type: 'I', weight: 2),
        ],
      ),

      // ===== 感覺 vs 直覺 (S/N) =====
      
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
        priority: 4,
        answers: [
          MBTIAnswer(id: 'sn_3_a', text: '按照既定程序和標準操作', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_3_b', text: '探索新方法和創新解決方案', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_3_c', text: '處理具體、實際的任務', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_3_d', text: '思考未來的可能性和改進', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_4',
        category: 'S/N',
        question: '閱讀時，你更喜歡：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'sn_4_a', text: '實用的指南和具體案例', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_4_b', text: '理論探討和抽象概念', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_4_c', text: '詳細的事實和數據', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_4_d', text: '創意和想像力豐富的內容', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_5',
        category: 'S/N',
        question: '做計劃時，你傾向於：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'sn_5_a', text: '制定詳細的步驟和時間表', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_5_b', text: '設定大方向，保持靈活性', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_5_c', text: '考慮實際的資源和限制', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_5_d', text: '探索多種可能的方案', type: 'N', weight: 2),
        ],
      ),

      // S/N 專業模式額外問題
      const MBTIQuestion(
        id: 'sn_6',
        category: 'S/N',
        question: '解決問題時，你更依賴：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'sn_6_a', text: '過往經驗和已驗證的方法', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_6_b', text: '創新思維和新穎方法', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_6_c', text: '具體數據和事實分析', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_6_d', text: '直覺洞察和模式識別', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_7',
        category: 'S/N',
        question: '在會議中，你更關注：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'sn_7_a', text: '具體的議程和實際行動', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_7_b', text: '整體願景和未來方向', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_7_c', text: '詳細的執行計劃', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_7_d', text: '創新想法和可能性', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_8',
        category: 'S/N',
        question: '記憶信息時，你更容易記住：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_8_a', text: '具體的細節和事實', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_8_b', text: '整體印象和概念', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_8_c', text: '實用的操作步驟', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_8_d', text: '理論框架和模式', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_9',
        category: 'S/N',
        question: '面對新技術時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_9_a', text: '先了解具體功能和操作', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_9_b', text: '探索其潛在應用和可能性', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_9_c', text: '關注實際效益和成本', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_9_d', text: '想像未來的發展趨勢', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_10',
        category: 'S/N',
        question: '在創意工作中，你傾向於：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_10_a', text: '改進現有的方法和流程', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_10_b', text: '開發全新的概念和方法', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_10_c', text: '注重實用性和可操作性', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_10_d', text: '追求創新性和突破性', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_11',
        category: 'S/N',
        question: '學習新概念時，你喜歡：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_11_a', text: '通過具體例子和實踐', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_11_b', text: '理解抽象原理和理論', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_11_c', text: '循序漸進的學習方式', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_11_d', text: '跳躍式的思維連結', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_12',
        category: 'S/N',
        question: '在團隊討論中，你更傾向於：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_12_a', text: '提供具體的數據和案例', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_12_b', text: '分享創新想法和願景', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_12_c', text: '關注實際的執行細節', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_12_d', text: '探討未來的可能性', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_13',
        category: 'S/N',
        question: '處理信息時，你更重視：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'sn_13_a', text: '信息的準確性和完整性', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_13_b', text: '信息的含義和潛在聯繫', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_13_c', text: '信息的實用價值', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_13_d', text: '信息的創新啟發', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_14',
        category: 'S/N',
        question: '面對複雜項目時，你會：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'sn_14_a', text: '分解成具體的小任務', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_14_b', text: '先構建整體框架和概念', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_14_c', text: '制定詳細的執行計劃', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_14_d', text: '探索多種實現路徑', type: 'N', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'sn_15',
        category: 'S/N',
        question: '評估成果時，你更看重：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'sn_15_a', text: '具體的量化指標和結果', type: 'S', weight: 3),
          MBTIAnswer(id: 'sn_15_b', text: '長遠影響和潛在價值', type: 'N', weight: 3),
          MBTIAnswer(id: 'sn_15_c', text: '實際效益和投資回報', type: 'S', weight: 2),
          MBTIAnswer(id: 'sn_15_d', text: '創新程度和突破性', type: 'N', weight: 2),
        ],
      ),

      // ===== 思考 vs 情感 (T/F) =====
      
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
        priority: 4,
        answers: [
          MBTIAnswer(id: 'tf_3_a', text: '專注於事實和邏輯來解決分歧', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_3_b', text: '關注每個人的感受和需求', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_3_c', text: '尋找最有效率的解決方案', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_3_d', text: '努力維護團隊和諧', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_4',
        category: 'T/F',
        question: '評價一個想法時，你首先考慮：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'tf_4_a', text: '是否邏輯合理和可行', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_4_b', text: '是否符合價值觀和對人有益', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_4_c', text: '效率和成本效益', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_4_d', text: '對相關人員的影響', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_5',
        category: 'T/F',
        question: '在批評他人時，你會：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'tf_5_a', text: '直接指出問題和改進方法', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_5_b', text: '考慮對方的感受，溫和表達', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_5_c', text: '專注於事實，避免個人情感', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_5_d', text: '先肯定優點再提出建議', type: 'F', weight: 2),
        ],
      ),

      // T/F 專業模式額外問題
      const MBTIQuestion(
        id: 'tf_6',
        category: 'T/F',
        question: '在領導團隊時，你更重視：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'tf_6_a', text: '效率和結果導向', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_6_b', text: '團隊和諧和成員發展', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_6_c', text: '客觀的績效評估', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_6_d', text: '個人化的關懷和支持', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_7',
        category: 'T/F',
        question: '面對道德兩難時，你會：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'tf_7_a', text: '依據原則和規則判斷', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_7_b', text: '考慮對所有人的影響', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_7_c', text: '尋求最公正的解決方案', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_7_d', text: '優先考慮人的感受和需求', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_8',
        category: 'T/F',
        question: '在工作評估中，你更看重：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_8_a', text: '客觀的能力和成果', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_8_b', text: '努力程度和團隊貢獻', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_8_c', text: '邏輯思維和分析能力', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_8_d', text: '人際關係和合作精神', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_9',
        category: 'T/F',
        question: '處理客戶投訴時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_9_a', text: '分析問題根源，提供解決方案', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_9_b', text: '先安撫情緒，表達理解和同情', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_9_c', text: '依據政策和程序處理', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_9_d', text: '個性化服務，超越期望', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_10',
        category: 'T/F',
        question: '在團隊決策中，你傾向於：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_10_a', text: '基於數據和邏輯分析', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_10_b', text: '考慮所有成員的意見和感受', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_10_c', text: '追求最優化的結果', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_10_d', text: '尋求共識和團隊認同', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_11',
        category: 'T/F',
        question: '給予反饋時，你更注重：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_11_a', text: '準確性和改進建議', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_11_b', text: '鼓勵性和建設性', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_11_c', text: '客觀的事實和標準', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_11_d', text: '個人成長和發展', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_12',
        category: 'T/F',
        question: '面對工作壓力時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_12_a', text: '理性分析壓力來源和解決方案', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_12_b', text: '尋求情感支持和理解', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_12_c', text: '專注於任務完成', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_12_d', text: '關注對團隊的影響', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_13',
        category: 'T/F',
        question: '在招聘面試中，你更看重：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'tf_13_a', text: '技能水平和工作經驗', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_13_b', text: '人格特質和團隊適應性', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_13_c', text: '邏輯思維和問題解決能力', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_13_d', text: '溝通能力和情商', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_14',
        category: 'T/F',
        question: '制定公司政策時，你會：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'tf_14_a', text: '基於效率和公平原則', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_14_b', text: '考慮員工的感受和需求', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_14_c', text: '確保一致性和可執行性', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_14_d', text: '促進和諧和員工滿意度', type: 'F', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'tf_15',
        category: 'T/F',
        question: '評價一個決策的成功時，你主要看：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'tf_15_a', text: '是否達到預期目標和指標', type: 'T', weight: 3),
          MBTIAnswer(id: 'tf_15_b', text: '是否讓相關人員滿意和受益', type: 'F', weight: 3),
          MBTIAnswer(id: 'tf_15_c', text: '邏輯性和合理性', type: 'T', weight: 2),
          MBTIAnswer(id: 'tf_15_d', text: '對人際關係的正面影響', type: 'F', weight: 2),
        ],
      ),

      // ===== 判斷 vs 感知 (J/P) =====
      
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
        priority: 4,
        answers: [
          MBTIAnswer(id: 'jp_3_a', text: '感到不安，優先完成它們', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_3_b', text: '保持冷靜，在截止日期前完成', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_3_c', text: '制定時間表逐步完成', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_3_d', text: '在壓力下工作效率更高', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_4',
        category: 'J/P',
        question: '整理房間時，你的風格是：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'jp_4_a', text: '每樣東西都有固定位置', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_4_b', text: '看起來整潔就好，不必太嚴格', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_4_c', text: '定期整理，保持秩序', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_4_d', text: '創意性的擺放，隨心情變化', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_5',
        category: 'J/P',
        question: '做決定時，你傾向於：',
        mode: TestMode.both,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'jp_5_a', text: '快速決定並堅持執行', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_5_b', text: '保持選項開放，隨時調整', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_5_c', text: '充分考慮後做出最終決定', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_5_d', text: '喜歡探索不同的可能性', type: 'P', weight: 2),
        ],
      ),

      // J/P 專業模式額外問題
      const MBTIQuestion(
        id: 'jp_6',
        category: 'J/P',
        question: '在項目管理中，你更偏好：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'jp_6_a', text: '詳細的時間表和里程碑', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_6_b', text: '靈活的進度和適應性調整', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_6_c', text: '明確的責任分工', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_6_d', text: '創意空間和自由發揮', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_7',
        category: 'J/P',
        question: '面對多個任務時，你會：',
        mode: TestMode.professional,
        priority: 3,
        answers: [
          MBTIAnswer(id: 'jp_7_a', text: '按優先級順序逐一完成', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_7_b', text: '根據興趣和靈感切換', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_7_c', text: '制定詳細的執行計劃', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_7_d', text: '保持多線程並行處理', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_8',
        category: 'J/P',
        question: '在會議安排上，你傾向於：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_8_a', text: '提前安排，嚴格按時間進行', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_8_b', text: '靈活安排，允許延長討論', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_8_c', text: '有明確的議程和目標', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_8_d', text: '開放式討論，隨機應變', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_9',
        category: 'J/P',
        question: '處理工作流程時，你更喜歡：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_9_a', text: '標準化的操作程序', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_9_b', text: '靈活的方法和創新', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_9_c', text: '可預測的工作節奏', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_9_d', text: '多樣化的工作內容', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_10',
        category: 'J/P',
        question: '在學習新技能時，你偏好：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_10_a', text: '系統性的課程和結構', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_10_b', text: '探索式的學習和實驗', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_10_c', text: '循序漸進的學習計劃', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_10_d', text: '隨興趣驅動的學習', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_11',
        category: 'J/P',
        question: '面對變化的工作要求時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_11_a', text: '希望有明確的新指導方針', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_11_b', text: '享受變化帶來的新挑戰', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_11_c', text: '需要時間適應和重新規劃', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_11_d', text: '快速調整並找到新方法', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_12',
        category: 'J/P',
        question: '在團隊協作中，你的風格是：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_12_a', text: '按計劃推進，確保進度', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_12_b', text: '靈活配合，適應團隊節奏', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_12_c', text: '明確分工，各司其職', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_12_d', text: '跨界合作，互相支援', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_13',
        category: 'J/P',
        question: '處理緊急情況時，你會：',
        mode: TestMode.professional,
        priority: 2,
        answers: [
          MBTIAnswer(id: 'jp_13_a', text: '依據既定的應急預案', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_13_b', text: '即興應對，靈活處理', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_13_c', text: '快速制定行動計劃', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_13_d', text: '保持冷靜，隨機應變', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_14',
        category: 'J/P',
        question: '在個人發展規劃上，你傾向於：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'jp_14_a', text: '制定明確的職業發展路徑', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_14_b', text: '保持開放，隨機會調整', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_14_c', text: '設定具體的目標和時間表', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_14_d', text: '探索多種可能的發展方向', type: 'P', weight: 2),
        ],
      ),

      const MBTIQuestion(
        id: 'jp_15',
        category: 'J/P',
        question: '對於工作與生活的平衡，你認為：',
        mode: TestMode.professional,
        priority: 1,
        answers: [
          MBTIAnswer(id: 'jp_15_a', text: '需要明確的界限和時間安排', type: 'J', weight: 3),
          MBTIAnswer(id: 'jp_15_b', text: '可以靈活融合，隨情況調整', type: 'P', weight: 3),
          MBTIAnswer(id: 'jp_15_c', text: '按計劃分配時間和精力', type: 'J', weight: 2),
          MBTIAnswer(id: 'jp_15_d', text: '順其自然，保持彈性', type: 'P', weight: 2),
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