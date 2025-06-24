import 'package:flutter/material.dart';
import 'enhanced_mbti_test_page.dart';

/// MBTI 問題數據模型
class MBTIQuestion {
  final String question;
  final String trueAnswer;  // True 時的傾向
  final String falseAnswer; // False 時的傾向
  final String dimension;   // E/I, S/N, T/F, J/P
  final String context;     // 問題背景説明

  MBTIQuestion({
    required this.question,
    required this.trueAnswer,
    required this.falseAnswer,
    required this.dimension,
    this.context = '',
  });
}

/// MBTI 結果數據模型
class MBTIResult {
  final String type;
  final String title;
  final String subtitle;
  final String description;
  final List<String> traits;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> careerSuggestions;
  final List<String> relationshipTips;
  final Color primaryColor;
  final Color secondaryColor;
  final String compatibility;
  final double confidence;

  MBTIResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.traits,
    required this.strengths,
    required this.challenges,
    required this.careerSuggestions,
    required this.relationshipTips,
    required this.primaryColor,
    required this.secondaryColor,
    required this.compatibility,
    required this.confidence,
  });
}

/// MBTI 問題庫管理
class MBTIQuestions {
  
  static List<MBTIQuestion> getQuestions(MBTITestMode mode) {
    switch (mode) {
      case MBTITestMode.quick:
        return _getQuickQuestions();
      case MBTITestMode.professional:
        return _getProfessionalQuestions();
      case MBTITestMode.interactive:
      default:
        return _getInteractiveQuestions();
    }
  }

  // 快速版 - 16題
  static List<MBTIQuestion> _getQuickQuestions() {
    return [
      // E/I 維度 - 4題
      MBTIQuestion(
        question: "在聚會中，我通常...",
        trueAnswer: "主動與陌生人交談，享受熱鬧的氣氛",
        falseAnswer: "更喜歡與少數熟悉的朋友深入交談",
        dimension: "E/I",
        context: "這題測試你的社交能量來源",
      ),
      MBTIQuestion(
        question: "當我需要恢復精力時，我會...",
        trueAnswer: "和朋友出去或參加社交活動",
        falseAnswer: "獨自一人安靜地休息",
        dimension: "E/I",
        context: "能量恢復方式反映了你的性格傾向",
      ),
      MBTIQuestion(
        question: "在工作場所，我傾向於...",
        trueAnswer: "在開放的環境中與團隊協作",
        falseAnswer: "在安靜的環境中專注工作",
        dimension: "E/I",
        context: "工作環境偏好顯示你的精力類型",
      ),
      MBTIQuestion(
        question: "我在決策時通常...",
        trueAnswer: "喜歡與他人討論來獲得不同觀點",
        falseAnswer: "喜歡獨自思考後再做決定",
        dimension: "E/I",
        context: "決策過程反映了思考的外向或內向傾向",
      ),

      // S/N 維度 - 4題
      MBTIQuestion(
        question: "我更信任...",
        trueAnswer: "具體的事實和經驗",
        falseAnswer: "直覺和可能性",
        dimension: "S/N",
        context: "信息來源偏好顯示感知方式差異",
      ),
      MBTIQuestion(
        question: "在學習新事物時，我喜歡...",
        trueAnswer: "從實際例子和步驟開始",
        falseAnswer: "先了解整體概念和理論",
        dimension: "S/N",
        context: "學習方式反映對具體與抽象的偏好",
      ),
      MBTIQuestion(
        question: "我對細節的態度是...",
        trueAnswer: "注重準確性和具體細節",
        falseAnswer: "關注大局，細節可以後續完善",
        dimension: "S/N",
        context: "細節關注度體現感覺與直覺的差別",
      ),
      MBTIQuestion(
        question: "在解決問題時，我依賴...",
        trueAnswer: "過往的經驗和已證實的方法",
        falseAnswer: "創新的想法和未來的可能性",
        dimension: "S/N",
        context: "問題解決方式顯示現實與理想的傾向",
      ),

      // T/F 維度 - 4題
      MBTIQuestion(
        question: "做決定時，我更重視...",
        trueAnswer: "邏輯分析和客觀標準",
        falseAnswer: "個人價值觀和他人感受",
        dimension: "T/F",
        context: "決策標準反映思考與情感的優先順序",
      ),
      MBTIQuestion(
        question: "在衝突中，我傾向於...",
        trueAnswer: "分析問題並尋找合理解決方案",
        falseAnswer: "考慮所有人的感受並尋求和諧",
        dimension: "T/F",
        context: "衝突處理方式體現邏輯與人際的重視程度",
      ),
      MBTIQuestion(
        question: "我更容易被什麼說服？",
        trueAnswer: "邏輯論證和數據證據",
        falseAnswer: "情感共鳴和個人故事",
        dimension: "T/F",
        context: "說服方式偏好顯示思考與感受的影響力",
      ),
      MBTIQuestion(
        question: "給他人建議時，我會...",
        trueAnswer: "提供客觀分析和實用建議",
        falseAnswer: "提供情感支持和理解",
        dimension: "T/F",
        context: "建議方式反映幫助他人的不同路徑",
      ),

      // J/P 維度 - 4題
      MBTIQuestion(
        question: "我的工作風格是...",
        trueAnswer: "有計劃、有截止日期，提前完成",
        falseAnswer: "靈活應變，在壓力下迸發創意",
        dimension: "J/P",
        context: "工作方式體現對結構與彈性的偏好",
      ),
      MBTIQuestion(
        question: "對於計劃，我...",
        trueAnswer: "喜歡制定詳細計劃並嚴格執行",
        falseAnswer: "喜歡保持選擇的開放性",
        dimension: "J/P",
        context: "計劃態度反映對確定性的不同需求",
      ),
      MBTIQuestion(
        question: "在旅行時，我傾向於...",
        trueAnswer: "提前預訂並制定詳細行程",
        falseAnswer: "保持彈性，隨興探索",
        dimension: "J/P",
        context: "旅行方式顯示對控制與自由的偏好",
      ),
      MBTIQuestion(
        question: "我對變化的態度是...",
        trueAnswer: "需要時間適應，喜歡穩定性",
        falseAnswer: "享受新變化帶來的刺激",
        dimension: "J/P",
        context: "變化態度體現對穩定與變動的接受度",
      ),
    ];
  }

  // 互動式版本 - 32題
  static List<MBTIQuestion> _getInteractiveQuestions() {
    return [
      ..._getQuickQuestions(),
      ..._getAdditionalInteractiveQuestions(),
    ];
  }

  // 專業版 - 60題
  static List<MBTIQuestion> _getProfessionalQuestions() {
    return [
      ..._getInteractiveQuestions(),
      ..._getAdvancedProfessionalQuestions(),
    ];
  }

  static List<MBTIQuestion> _getAdditionalInteractiveQuestions() {
    return [
      // E/I 維度額外題目
      MBTIQuestion(
        question: "在團隊會議中，我通常...",
        trueAnswer: "積極發言，分享我的想法",
        falseAnswer: "仔細聆聽，深思熟慮後才發言",
        dimension: "E/I",
        context: "會議表現顯示溝通的主動性差異",
      ),
      MBTIQuestion(
        question: "學習新技能時，我傾向於...",
        trueAnswer: "參加課程或小組學習",
        falseAnswer: "自學或一對一指導",
        dimension: "E/I",
        context: "學習偏好反映對群體與個人環境的選擇",
      ),
      MBTIQuestion(
        question: "在壓力下，我會...",
        trueAnswer: "尋求他人的支持和建議",
        falseAnswer: "獨自處理，避免打擾他人",
        dimension: "E/I",
        context: "壓力應對顯示能量的外向或內向流動",
      ),
      MBTIQuestion(
        question: "表達想法時，我習慣...",
        trueAnswer: "邊想邊說，通過交流整理思路",
        falseAnswer: "先整理好思路再表達",
        dimension: "E/I",
        context: "思考表達方式體現處理信息的模式",
      ),

      // S/N 維度額外題目
      MBTIQuestion(
        question: "閱讀時，我更喜歡...",
        trueAnswer: "實用指南和具體案例",
        falseAnswer: "理論探討和抽象概念",
        dimension: "S/N",
        context: "閱讀偏好顯示對實用與理論的興趣差異",
      ),
      MBTIQuestion(
        question: "記憶信息時，我依賴...",
        trueAnswer: "具體的細節和事實",
        falseAnswer: "整體印象和關聯性",
        dimension: "S/N",
        context: "記憶方式反映信息處理的不同策略",
      ),
      MBTIQuestion(
        question: "我對變化的反應是...",
        trueAnswer: "需要具體了解變化的內容",
        falseAnswer: "對新可能性感到興奮",
        dimension: "S/N",
        context: "變化反應體現對具體與可能性的關注",
      ),
      MBTIQuestion(
        question: "我的注意力通常集中在...",
        trueAnswer: "當前的現實情況",
        falseAnswer: "未來的可能性",
        dimension: "S/N",
        context: "注意力焦點顯示時間取向的差異",
      ),

      // T/F 維度額外題目
      MBTIQuestion(
        question: "評價他人時，我更看重...",
        trueAnswer: "能力和成就",
        falseAnswer: "品格和動機",
        dimension: "T/F",
        context: "評價標準反映客觀與主觀的重視程度",
      ),
      MBTIQuestion(
        question: "在團隊中，我的角色通常是...",
        trueAnswer: "分析問題，提供解決方案",
        falseAnswer: "協調關係，維護團隊和諧",
        dimension: "T/F",
        context: "團隊角色體現任務與人際的優先順序",
      ),
      MBTIQuestion(
        question: "面對批評時，我會...",
        trueAnswer: "客觀分析批評的合理性",
        falseAnswer: "關注批評者的情感和動機",
        dimension: "T/F",
        context: "批評反應顯示邏輯與情感的處理方式",
      ),
      MBTIQuestion(
        question: "我更容易注意到...",
        trueAnswer: "邏輯漏洞和不一致之處",
        falseAnswer: "他人的情緒變化",
        dimension: "T/F",
        context: "注意力焦點反映分析與感知的差異",
      ),

      // J/P 維度額外題目
      MBTIQuestion(
        question: "我的工作桌通常是...",
        trueAnswer: "整潔有序，物品分類擺放",
        falseAnswer: "看起來雜亂，但我知道東西在哪",
        dimension: "J/P",
        context: "工作環境體現對秩序與靈活性的偏好",
      ),
      MBTIQuestion(
        question: "面對截止日期，我會...",
        trueAnswer: "提前完成，避免最後時刻的壓力",
        falseAnswer: "在壓力下工作效率更高",
        dimension: "J/P",
        context: "時間管理方式反映對壓力的不同反應",
      ),
      MBTIQuestion(
        question: "做決定時，我傾向於...",
        trueAnswer: "快速決定，然後執行",
        falseAnswer: "保持選擇開放，直到必須決定",
        dimension: "J/P",
        context: "決策速度顯示對確定性的需求差異",
      ),
      MBTIQuestion(
        question: "我對規則的態度是...",
        trueAnswer: "規則提供必要的結構",
        falseAnswer: "規則可以靈活解釋",
        dimension: "J/P",
        context: "規則態度體現對結構與自由的看法",
      ),
    ];
  }

  static List<MBTIQuestion> _getAdvancedProfessionalQuestions() {
    return [
      // 更深入的專業版問題
      // E/I 維度高級題目
      MBTIQuestion(
        question: "在領導團隊時，我傾向於...",
        trueAnswer: "公開討論，集思廣益",
        falseAnswer: "深度思考後提出方向",
        dimension: "E/I",
        context: "領導風格體現能量導向的差異",
      ),
      MBTIQuestion(
        question: "處理複雜問題時，我會...",
        trueAnswer: "與他人討論不同角度",
        falseAnswer: "獨自深入分析各種因素",
        dimension: "E/I",
        context: "問題解決方式顯示思考的社交傾向",
      ),

      // S/N 維度高級題目
      MBTIQuestion(
        question: "在創新過程中，我更關注...",
        trueAnswer: "實際可行性和具體實施",
        falseAnswer: "概念突破和理論框架",
        dimension: "S/N",
        context: "創新關注點反映實用與理想的平衡",
      ),
      MBTIQuestion(
        question: "分析數據時，我首先看...",
        trueAnswer: "具體數字和明確趨勢",
        falseAnswer: "隱含模式和潛在關聯",
        dimension: "S/N",
        context: "數據分析方式體現具體與抽象的偏好",
      ),

      // T/F 維度高級題目
      MBTIQuestion(
        question: "制定政策時，我優先考慮...",
        trueAnswer: "邏輯一致性和效率",
        falseAnswer: "人性化和公平性",
        dimension: "T/F",
        context: "政策制定反映邏輯與人文的權衡",
      ),
      MBTIQuestion(
        question: "評估風險時，我主要依據...",
        trueAnswer: "客觀數據和概率分析",
        falseAnswer: "直覺感受和經驗判斷",
        dimension: "T/F",
        context: "風險評估方式顯示理性與感性的差異",
      ),

      // J/P 維度高級題目
      MBTIQuestion(
        question: "管理專案時，我傾向於...",
        trueAnswer: "制定詳細計劃並嚴格執行",
        falseAnswer: "設定大方向，過程中靈活調整",
        dimension: "J/P",
        context: "專案管理風格體現結構與彈性的平衡",
      ),
      MBTIQuestion(
        question: "面對不確定性時，我會...",
        trueAnswer: "尋求更多信息以做出明確決定",
        falseAnswer: "接受模糊性，保持開放態度",
        dimension: "J/P",
        context: "不確定性處理顯示控制與接受的傾向",
      ),
    ];
  }
}

/// MBTI 結果數據庫
class MBTIResults {
  static Map<String, MBTIResult> get results => {
    'INTJ': MBTIResult(
      type: 'INTJ',
      title: '建築師',
      subtitle: '理性而獨立的策略家',
      description: '具有強烈的直覺和創造力，善於規劃和實現長遠目標。獨立思考，追求知識和能力的提升。在約會中，他們重視深度和真誠的對話。',
      traits: ['獨立', '理性', '有遠見', '堅定', '創新'],
      strengths: ['戰略思維', '獨立自主', '追求完美', '高效執行'],
      challenges: ['過於理想化', '社交困難', '完美主義', '情感表達'],
      careerSuggestions: ['戰略顧問', '科學研究', '系統架構師', '投資分析師'],
      relationshipTips: ['重視精神層面的連結', '需要個人空間', '欣賞聰明的伴侶', '慢熱但忠誠'],
      primaryColor: const Color(0xFF6B46C1),
      secondaryColor: const Color(0xFF9333EA),
      compatibility: '與 ENFP、ENTP 最兼容',
      confidence: 0.92,
    ),

    'ENFP': MBTIResult(
      type: 'ENFP',
      title: '競選者',
      subtitle: '熱情而富有創造力的自由精神',
      description: '充滿熱情和創意，善於看到事物之間的聯繫。樂觀向上，能夠激發他人的熱情。在愛情中，他們帶來活力和驚喜。',
      traits: ['熱情', '創意', '樂觀', '靈活', '富有感染力'],
      strengths: ['激勵他人', '創新思維', '適應能力強', '人際關係佳'],
      challenges: ['注意力分散', '避免衝突', '過度理想化', '缺乏持續性'],
      careerSuggestions: ['市場營銷', '心理諮詢', '媒體創作', '教育培訓'],
      relationshipTips: ['喜歡變化和驚喜', '重視情感連結', '需要自由空間', '善於表達愛意'],
      primaryColor: const Color(0xFFEF4444),
      secondaryColor: const Color(0xFFF97316),
      compatibility: '與 INTJ、INFJ 最兼容',
      confidence: 0.89,
    ),

    // 可以繼續添加其他15種類型...
  };
} 