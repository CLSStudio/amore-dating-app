import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// 專業 MBTI 測試狀態管理
final professionalTestProvider = StateNotifierProvider<ProfessionalMBTITestNotifier, ProfessionalMBTIState>((ref) {
  return ProfessionalMBTITestNotifier();
});

class ProfessionalMBTIState {
  final int currentPhase;
  final int currentQuestion;
  final Map<String, List<int>> dimensionScores;
  final List<String> answers;
  final bool isCompleted;
  final MBTIPersonalityProfile? result;

  ProfessionalMBTIState({
    this.currentPhase = 0,
    this.currentQuestion = 0,
    Map<String, List<int>>? dimensionScores,
    this.answers = const [],
    this.isCompleted = false,
    this.result,
  }) : dimensionScores = dimensionScores ?? {
      'E': <int>[],
      'I': <int>[],
      'S': <int>[],
      'N': <int>[],
      'T': <int>[],
      'F': <int>[],
      'J': <int>[],
      'P': <int>[],
    };

  ProfessionalMBTIState copyWith({
    int? currentPhase,
    int? currentQuestion,
    Map<String, List<int>>? dimensionScores,
    List<String>? answers,
    bool? isCompleted,
    MBTIPersonalityProfile? result,
  }) {
    return ProfessionalMBTIState(
      currentPhase: currentPhase ?? this.currentPhase,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      dimensionScores: dimensionScores ?? this.dimensionScores,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
    );
  }
}

class MBTIPersonalityProfile {
  final String type;
  final String title;
  final String archetype;
  final Map<String, double> dimensionStrengths;
  final List<String> coreTraits;
  final List<String> strengths;
  final List<String> developmentAreas;
  final List<String> idealCareers;
  final List<String> relationshipStyle;
  final List<String> stressManagement;
  final List<String> learningStyle;
  final String personalGrowthAdvice;
  final String datingInsights;

  MBTIPersonalityProfile({
    required this.type,
    required this.title,
    required this.archetype,
    required this.dimensionStrengths,
    required this.coreTraits,
    required this.strengths,
    required this.developmentAreas,
    required this.idealCareers,
    required this.relationshipStyle,
    required this.stressManagement,
    required this.learningStyle,
    required this.personalGrowthAdvice,
    required this.datingInsights,
  });
}

class ProfessionalMBTIQuestion {
  final String question;
  final List<String> options;
  final Map<String, int> scoring; // 維度 -> 分數
  final String category;
  final String scenario;

  ProfessionalMBTIQuestion({
    required this.question,
    required this.options,
    required this.scoring,
    required this.category,
    this.scenario = '',
  });
}

class ProfessionalMBTITestNotifier extends StateNotifier<ProfessionalMBTIState> {
  ProfessionalMBTITestNotifier() : super(ProfessionalMBTIState());

  final List<List<ProfessionalMBTIQuestion>> testPhases = [
    // 第一階段：情境判斷題 (20題)
    [
      ProfessionalMBTIQuestion(
        question: "在一個重要的團隊會議中，當討論進入僵局時，你最可能採取什麼行動？",
        options: [
          "主動提出新的想法來打破僵局",
          "仔細聆聽各方觀點，尋找共同點", 
          "私下與關鍵人物溝通，了解真實想法",
          "建議暫停會議，讓大家冷靜思考"
        ],
        scoring: {'E': 3, 'I': 0, 'T': 2, 'F': 1},
        category: "工作情境",
        scenario: "團隊協作場景"
      ),
      ProfessionalMBTIQuestion(
        question: "面對一個復雜的專案截止日期，你會如何安排工作？",
        options: [
          "立即制定詳細的時間表並嚴格執行",
          "先了解項目全貌，再靈活調整計劃",
          "與團隊成員密切合作，分工協作",
          "專注於最重要的核心任務"
        ],
        scoring: {'J': 3, 'N': 1, 'E': 2, 'T': 1},
        category: "工作壓力",
        scenario: "時間管理"
      ),
      ProfessionalMBTIQuestion(
        question: "當你需要做一個影響他人的決定時，你最重視什麼？",
        options: [
          "決定的邏輯性和客觀效果",
          "決定對每個人感受的影響",
          "決定是否符合長遠利益",
          "決定的實際可執行性"
        ],
        scoring: {'T': 3, 'F': 0, 'N': 2, 'S': 1},
        category: "決策過程",
        scenario: "領導決策"
      ),
      ProfessionalMBTIQuestion(
        question: "在學習新技能或知識時，你傾向於？",
        options: [
          "從實際案例開始，逐步理解",
          "先掌握理論框架，再應用實踐",
          "與他人討論交流來加深理解",
          "獨自研究，按自己的節奏學習"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 2, 'I': 1},
        category: "學習風格",
        scenario: "個人成長"
      ),
      ProfessionalMBTIQuestion(
        question: "當朋友向你尋求建議時，你通常會？",
        options: [
          "提供具體可行的解決方案",
          "幫助他們分析問題的根本原因",
          "給予情感支持和鼓勵",
          "分享類似的經驗和教訓"
        ],
        scoring: {'T': 2, 'N': 2, 'F': 3, 'S': 1},
        category: "人際互動",
        scenario: "朋友諮詢"
      ),
      ProfessionalMBTIQuestion(
        question: "面對突然的計劃變更，你的第一反應是？",
        options: [
          "感到不安，需要時間重新適應",
          "興奮於新的可能性和挑戰",
          "評估變更的合理性和必要性",
          "關心變更對他人的影響"
        ],
        scoring: {'J': 3, 'P': 0, 'T': 2, 'F': 1},
        category: "變化適應",
        scenario: "計劃調整"
      ),
      ProfessionalMBTIQuestion(
        question: "在社交聚會中，你更喜歡？",
        options: [
          "與很多人輕鬆聊天，了解不同觀點",
          "與幾個人深入交談，探討有趣話題",
          "觀察他人互動，適時參與對話",
          "尋找志同道合的人建立連結"
        ],
        scoring: {'E': 3, 'I': 1, 'S': 0, 'N': 2},
        category: "社交模式",
        scenario: "聚會互動"
      ),
      ProfessionalMBTIQuestion(
        question: "當你感到壓力時，你會？",
        options: [
          "尋求他人支持和建議",
          "獨自處理，避免打擾他人",
          "分析壓力來源，制定應對計劃",
          "先調整情緒，再處理問題"
        ],
        scoring: {'E': 3, 'I': 0, 'T': 2, 'F': 1},
        category: "壓力應對",
        scenario: "情緒管理"
      ),
      ProfessionalMBTIQuestion(
        question: "在做重要決定時，你最信任？",
        options: [
          "經過驗證的方法和數據",
          "直覺和第六感",
          "他人的經驗和建議",
          "內心的價值觀和信念"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 1, 'F': 2},
        category: "決策依據",
        scenario: "重要選擇"
      ),
      ProfessionalMBTIQuestion(
        question: "面對批評或負面反饋時，你傾向於？",
        options: [
          "客觀分析反饋的合理性",
          "關注反饋者的感受和動機",
          "立即採取行動改進",
          "深度反思自己的行為"
        ],
        scoring: {'T': 3, 'F': 0, 'J': 1, 'I': 2},
        category: "反饋處理",
        scenario: "建設性批評"
      ),
      ProfessionalMBTIQuestion(
        question: "在規劃週末活動時，你會？",
        options: [
          "提前制定詳細計劃",
          "保持彈性，隨興而為",
          "邀請朋友一起規劃",
          "選擇自己真正感興趣的活動"
        ],
        scoring: {'J': 3, 'P': 0, 'E': 2, 'F': 1},
        category: "休閒規劃",
        scenario: "週末安排"
      ),
      ProfessionalMBTIQuestion(
        question: "當團隊出現分歧時，你會？",
        options: [
          "尋找客觀的評判標準",
          "努力理解各方的立場",
          "推動達成具體的共識",
          "探索創新的解決方案"
        ],
        scoring: {'T': 3, 'F': 1, 'S': 2, 'N': 0},
        category: "衝突解決",
        scenario: "團隊分歧"
      ),
      ProfessionalMBTIQuestion(
        question: "在選擇職業發展方向時，你最看重？",
        options: [
          "工作的穩定性和明確性",
          "工作的創新性和可能性",
          "工作中的人際關係和團隊",
          "工作對個人成長的幫助"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 1, 'I': 2},
        category: "職業選擇",
        scenario: "未來規劃"
      ),
      ProfessionalMBTIQuestion(
        question: "面對複雜的資訊時，你習慣？",
        options: [
          "逐步分析每個細節",
          "尋找整體的模式和趨勢",
          "與他人討論來梳理思路",
          "獨自深度思考分析"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 2, 'I': 1},
        category: "資訊處理",
        scenario: "數據分析"
      ),
      ProfessionalMBTIQuestion(
        question: "在做計劃時，你更重視？",
        options: [
          "計劃的可行性和實用性",
          "計劃的創新性和靈活性",
          "計劃對他人的積極影響",
          "計劃與個人價值觀的契合"
        ],
        scoring: {'S': 2, 'N': 2, 'F': 3, 'T': 0},
        category: "規劃重點",
        scenario: "目標設定"
      ),
      ProfessionalMBTIQuestion(
        question: "當需要解決問題時，你首先會？",
        options: [
          "收集相關的具體資料",
          "思考問題的本質和根源",
          "尋求他人的協助和建議",
          "依靠過往經驗和直覺"
        ],
        scoring: {'S': 3, 'N': 1, 'E': 2, 'I': 0},
        category: "問題解決",
        scenario: "困難挑戰"
      ),
      ProfessionalMBTIQuestion(
        question: "在表達觀點時，你傾向於？",
        options: [
          "用事實和邏輯來支撐",
          "考慮聽眾的感受和接受度",
          "在群體中公開分享",
          "選擇合適的時機私下溝通"
        ],
        scoring: {'T': 3, 'F': 0, 'E': 2, 'I': 1},
        category: "溝通方式",
        scenario: "觀點表達"
      ),
      ProfessionalMBTIQuestion(
        question: "面對新環境時，你會？",
        options: [
          "主動探索和建立聯繫",
          "觀察適應，慢慢融入",
          "關注具體的環境細節",
          "思考環境的發展潛力"
        ],
        scoring: {'E': 3, 'I': 0, 'S': 2, 'N': 1},
        category: "適應能力",
        scenario: "環境變化"
      ),
      ProfessionalMBTIQuestion(
        question: "在做決策時，如果時間有限，你會？",
        options: [
          "基於現有資訊快速決定",
          "尋求更多時間深度思考",
          "諮詢他人意見再決定",
          "相信直覺做出選擇"
        ],
        scoring: {'J': 2, 'P': 1, 'E': 2, 'N': 2},
        category: "時間壓力",
        scenario: "緊急決策"
      ),
      ProfessionalMBTIQuestion(
        question: "當獨處時，你最喜歡？",
        options: [
          "處理具體的工作或任務",
          "思考抽象的概念和想法",
          "很少獨處，更喜歡與人互動",
          "反思自己的內心世界"
        ],
        scoring: {'S': 2, 'N': 2, 'E': 0, 'I': 3},
        category: "獨處偏好",
        scenario: "個人時間"
      ),
    ],
    // 第二階段：價值觀探索 (20題)
    [
      ProfessionalMBTIQuestion(
        question: "當面臨一個重要的人生決定時，什麼因素對你最重要？",
        options: [
          "這個決定是否符合邏輯和理性分析",
          "這個決定如何影響我關心的人",
          "這個決定是否與我的核心價值觀一致", 
          "這個決定能帶來什麼實際的成果"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "價值觀",
        scenario: "人生抉擇"
      ),
      ProfessionalMBTIQuestion(
        question: "對你來說，什麼樣的工作最有意義？",
        options: [
          "能發揮專業技能，獲得認可的工作",
          "能幫助他人，產生積極影響的工作",
          "能實現個人理想和價值的工作",
          "能帶來穩定收入和安全感的工作"
        ],
        scoring: {'T': 2, 'F': 3, 'N': 2, 'S': 1},
        category: "工作意義",
        scenario: "職業價值"
      ),
      ProfessionalMBTIQuestion(
        question: "在人際關係中，你最重視什麼？",
        options: [
          "彼此的理智溝通和mutual respect",
          "深度的情感連結和相互關懷",
          "共同的興趣愛好和價值觀",
          "可靠的支持和長期的穩定性"
        ],
        scoring: {'T': 3, 'F': 2, 'N': 1, 'S': 0},
        category: "關係價值",
        scenario: "人際關係"
      ),
      ProfessionalMBTIQuestion(
        question: "當社會出現不公正現象時，你的反應是？",
        options: [
          "分析問題的根本原因和解決方案",
          "關注受影響人群的感受和需求",
          "思考如何推動系統性的改變",
          "專注於自己能控制的具體行動"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "社會責任",
        scenario: "公義關懷"
      ),
      ProfessionalMBTIQuestion(
        question: "對於金錢和物質，你的態度是？",
        options: [
          "金錢是實現目標的工具",
          "金錢能幫助我照顧關心的人",
          "金錢代表自由和可能性",
          "金錢提供安全感和穩定性"
        ],
        scoring: {'T': 2, 'F': 2, 'N': 3, 'S': 1},
        category: "金錢觀",
        scenario: "物質態度"
      ),
      ProfessionalMBTIQuestion(
        question: "在面對失敗時，你最在意的是？",
        options: [
          "從失敗中學到什麼教訓",
          "失敗對他人造成的影響",
          "失敗背後的深層原因",
          "如何避免類似的失敗再次發生"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "失敗態度",
        scenario: "挫折處理"
      ),
      ProfessionalMBTIQuestion(
        question: "對於傳統和創新，你的看法是？",
        options: [
          "傳統有其價值，但需要理性評估",
          "重視傳統中的人文關懷和智慧",
          "創新和變革才能帶來進步",
          "傳統提供穩定的基礎和指導"
        ],
        scoring: {'T': 2, 'F': 1, 'N': 3, 'S': 0},
        category: "創新傳統",
        scenario: "變革態度"
      ),
      ProfessionalMBTIQuestion(
        question: "當你需要做出犧牲時，最難放棄的是？",
        options: [
          "個人的邏輯原則和標準",
          "與他人的和諧關係",
          "未來的無限可能性",
          "已有的穩定和確定性"
        ],
        scoring: {'T': 3, 'F': 2, 'N': 1, 'S': 0},
        category: "犧牲選擇",
        scenario: "價值衝突"
      ),
      ProfessionalMBTIQuestion(
        question: "對於成功，你的定義是？",
        options: [
          "達成設定的客觀目標和標準",
          "獲得他人的認可和讚賞",
          "實現個人的潛能和理想",
          "建立穩定和滿足的生活"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "成功定義",
        scenario: "人生目標"
      ),
      ProfessionalMBTIQuestion(
        question: "在教育子女（或將來教育子女）時，你最希望培養他們的？",
        options: [
          "獨立思考和解決問題的能力",
          "同理心和關愛他人的品格",
          "創造力和探索精神",
          "責任感和踏實的態度"
        ],
        scoring: {'T': 3, 'F': 2, 'N': 1, 'S': 0},
        category: "教育價值",
        scenario: "下一代培養"
      ),
      ProfessionalMBTIQuestion(
        question: "面對道德兩難時，你傾向於？",
        options: [
          "尋找最合理和公正的解決方案",
          "選擇傷害最少人的方案",
          "思考更深層的道德原則",
          "參考傳統的道德標準"
        ],
        scoring: {'T': 3, 'F': 2, 'N': 1, 'S': 0},
        category: "道德判斷",
        scenario: "倫理決策"
      ),
      ProfessionalMBTIQuestion(
        question: "對於個人隱私，你的態度是？",
        options: [
          "隱私是個人權利，需要理性保護",
          "隱私的重要性取決於對他人的影響",
          "隱私和開放之間需要平衡",
          "隱私提供安全感和個人空間"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "隱私觀",
        scenario: "個人邊界"
      ),
      ProfessionalMBTIQuestion(
        question: "當看到他人痛苦時，你的第一反應是？",
        options: [
          "分析痛苦的原因，尋找解決方法",
          "感同身受，想要給予安慰",
          "思考痛苦背後的意義",
          "提供實際的幫助和支持"
        ],
        scoring: {'T': 2, 'F': 3, 'N': 1, 'S': 0},
        category: "同理反應",
        scenario: "他人困難"
      ),
      ProfessionalMBTIQuestion(
        question: "對於競爭，你的看法是？",
        options: [
          "競爭能激發最佳表現和創新",
          "競爭可能傷害關係，要謹慎對待",
          "競爭是推動進步的自然機制",
          "適度競爭有益，過度競爭有害"
        ],
        scoring: {'T': 3, 'F': 0, 'N': 2, 'S': 1},
        category: "競爭態度",
        scenario: "競爭環境"
      ),
      ProfessionalMBTIQuestion(
        question: "在做善事時，你認為最重要的是？",
        options: [
          "善行的效果和實際價值",
          "善行對受助者的情感意義",
          "善行背後的道德原則",
          "善行的可持續性和長期影響"
        ],
        scoring: {'T': 2, 'F': 3, 'N': 1, 'S': 0},
        category: "善行動機",
        scenario: "道德行為"
      ),
      ProfessionalMBTIQuestion(
        question: "對於權威，你的態度是？",
        options: [
          "權威需要基於能力和合理性",
          "權威應該關懷和服務他人",
          "權威的合法性來自於價值觀",
          "權威提供秩序和穩定性"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "權威觀",
        scenario: "社會結構"
      ),
      ProfessionalMBTIQuestion(
        question: "當面臨環境保護與經濟發展的衝突時，你傾向於？",
        options: [
          "尋找技術解決方案，實現雙贏",
          "優先考慮未來世代的福祉",
          "探索全新的發展模式",
          "在現實約束下尋求平衡"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "環境價值",
        scenario: "可持續發展"
      ),
      ProfessionalMBTIQuestion(
        question: "對於藝術和文化，你的看法是？",
        options: [
          "藝術應該有其技巧和標準",
          "藝術的價值在於情感共鳴",
          "藝術代表創新和可能性",
          "藝術是文化傳承的載體"
        ],
        scoring: {'T': 2, 'F': 3, 'N': 1, 'S': 0},
        category: "文化價值",
        scenario: "藝術態度"
      ),
      ProfessionalMBTIQuestion(
        question: "在選擇居住地時，你最看重？",
        options: [
          "交通便利和基礎設施完善",
          "社區氛圍和鄰里關係",
          "發展潛力和未來前景",
          "安全穩定和熟悉感"
        ],
        scoring: {'T': 1, 'F': 2, 'N': 3, 'S': 0},
        category: "居住選擇",
        scenario: "生活環境"
      ),
      ProfessionalMBTIQuestion(
        question: "對於人生的意義，你認為主要來自於？",
        options: [
          "通過理性思考找到真理",
          "與他人建立深刻的連結",
          "探索未知和實現可能",
          "承擔責任和履行義務"
        ],
        scoring: {'T': 2, 'F': 2, 'N': 3, 'S': 1},
        category: "人生意義",
        scenario: "存在目的"
      ),
    ],
    // 第三階段：行為模式分析 (20題)
    [
      ProfessionalMBTIQuestion(
        question: "在學習新技能時，你的自然傾向是什麼？",
        options: [
          "先了解理論框架，再進行實踐",
          "直接動手嘗試，從錯誤中學習",
          "尋找導師或同伴一起學習",
          "制定詳細的學習計劃並嚴格執行"
        ],
        scoring: {'N': 3, 'S': 0, 'E': 2, 'J': 1},
        category: "學習模式",
        scenario: "個人發展"
      ),
      ProfessionalMBTIQuestion(
        question: "當你感到創意靈感湧現時，你會？",
        options: [
          "立即記錄下來，避免遺忘",
          "讓想法自然發展，不急於捕捉",
          "與他人分享，獲得反饋",
          "獨自深度思考，完善想法"
        ],
        scoring: {'J': 2, 'P': 2, 'E': 3, 'I': 0},
        category: "創意處理",
        scenario: "靈感管理"
      ),
      ProfessionalMBTIQuestion(
        question: "面對複雜的任務時，你習慣？",
        options: [
          "將任務分解為具體的步驟",
          "尋找任務背後的模式和規律",
          "與團隊成員協作完成",
          "獨立專注地逐一解決"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 2, 'I': 1},
        category: "任務處理",
        scenario: "複雜工作"
      ),
      ProfessionalMBTIQuestion(
        question: "在做決定前，你通常會？",
        options: [
          "收集所有相關資訊和數據",
          "思考各種可能的後果",
          "諮詢信任的人的意見",
          "相信自己的直覺和感覺"
        ],
        scoring: {'S': 2, 'N': 2, 'E': 2, 'F': 2},
        category: "決策準備",
        scenario: "選擇過程"
      ),
      ProfessionalMBTIQuestion(
        question: "當計劃被打亂時，你的反應是？",
        options: [
          "感到焦慮，努力恢復原計劃",
          "將此視為新機會的開始",
          "尋求他人幫助重新安排",
          "靈活調整，適應新情況"
        ],
        scoring: {'J': 3, 'N': 1, 'E': 2, 'P': 0},
        category: "應變能力",
        scenario: "計劃變更"
      ),
      ProfessionalMBTIQuestion(
        question: "在團隊中，你自然傾向於擔任什麼角色？",
        options: [
          "分析師，提供客觀的分析",
          "協調者，維護團隊和諧",
          "創新者，提出新想法",
          "執行者，確保任務完成"
        ],
        scoring: {'T': 3, 'F': 1, 'N': 2, 'S': 0},
        category: "團隊角色",
        scenario: "協作環境"
      ),
      ProfessionalMBTIQuestion(
        question: "處理日常雜務時，你會？",
        options: [
          "制定清單，系統性完成",
          "根據心情和興趣來安排",
          "與他人一起處理，增加樂趣",
          "儘快處理完畢，專注重要事務"
        ],
        scoring: {'J': 3, 'P': 0, 'E': 2, 'I': 1},
        category: "日常管理",
        scenario: "例行公事"
      ),
      ProfessionalMBTIQuestion(
        question: "面對批評時，你的內心過程是？",
        options: [
          "理性分析批評的有效性",
          "感受到情緒衝擊，需要時間處理",
          "想要立即澄清或回應",
          "內化思考，自我反省"
        ],
        scoring: {'T': 3, 'F': 0, 'E': 2, 'I': 1},
        category: "反饋接收",
        scenario: "建設性意見"
      ),
      ProfessionalMBTIQuestion(
        question: "在解決衝突時，你的方法是？",
        options: [
          "找出客觀的事實和規則",
          "理解各方的感受和需求",
          "推動面對面的開放討論",
          "給各方時間冷靜思考"
        ],
        scoring: {'T': 3, 'F': 1, 'E': 2, 'I': 0},
        category: "衝突管理",
        scenario: "人際矛盾"
      ),
      ProfessionalMBTIQuestion(
        question: "當獨自工作時，你最容易？",
        options: [
          "專注於具體的任務執行",
          "思考創新的解決方案",
          "感到孤單，想要找人交流",
          "進入深度專注的狀態"
        ],
        scoring: {'S': 2, 'N': 2, 'E': 0, 'I': 3},
        category: "獨立工作",
        scenario: "個人效率"
      ),
      ProfessionalMBTIQuestion(
        question: "面對模糊的指示時，你會？",
        options: [
          "要求更具體和明確的說明",
          "根據理解自由發揮",
          "與同事討論以確認理解",
          "按照自己的判斷行動"
        ],
        scoring: {'S': 3, 'N': 1, 'E': 2, 'I': 0},
        category: "模糊處理",
        scenario: "不確定性"
      ),
      ProfessionalMBTIQuestion(
        question: "在時間管理上，你的習慣是？",
        options: [
          "使用詳細的日程表和提醒",
          "保持彈性，根據狀況調整",
          "與他人協調共同的時間",
          "依據內在的節奏安排"
        ],
        scoring: {'J': 3, 'P': 0, 'E': 2, 'I': 1},
        category: "時間管理",
        scenario: "效率優化"
      ),
      ProfessionalMBTIQuestion(
        question: "學習新概念時，你更容易透過？",
        options: [
          "具體的例子和實際應用",
          "抽象的理論和概念框架",
          "與他人的討論和辯論",
          "安靜的個人思考"
        ],
        scoring: {'S': 3, 'N': 0, 'E': 2, 'I': 1},
        category: "學習渠道",
        scenario: "知識吸收"
      ),
      ProfessionalMBTIQuestion(
        question: "面對創新機會時，你的反應是？",
        options: [
          "評估創新的實際可行性",
          "興奮於無限的可能性",
          "與團隊一起探索機會",
          "深度思考創新的意義"
        ],
        scoring: {'S': 2, 'N': 3, 'E': 2, 'I': 1},
        category: "創新態度",
        scenario: "機會把握"
      ),
      ProfessionalMBTIQuestion(
        question: "處理情緒問題時，你傾向於？",
        options: [
          "理性分析情緒的原因",
          "完全接納和體驗情緒",
          "向他人尋求支持和理解",
          "獨自處理和消化情緒"
        ],
        scoring: {'T': 3, 'F': 1, 'E': 2, 'I': 0},
        category: "情緒處理",
        scenario: "心理調適"
      ),
      ProfessionalMBTIQuestion(
        question: "在做重要簡報時，你會？",
        options: [
          "準備詳細的數據和邏輯論證",
          "注重與聽眾的情感連結",
          "鼓勵互動和即時反饋",
          "專注於核心訊息的傳達"
        ],
        scoring: {'T': 3, 'F': 1, 'E': 2, 'I': 0},
        category: "簡報風格",
        scenario: "公開表達"
      ),
      ProfessionalMBTIQuestion(
        question: "面對重複性工作時，你會？",
        options: [
          "尋找提高效率的方法",
          "試圖在工作中找到新的角度",
          "與同事一起讓工作更有趣",
          "專注完成，避免分心"
        ],
        scoring: {'S': 2, 'N': 2, 'E': 2, 'I': 2},
        category: "重複工作",
        scenario: "例行任務"
      ),
      ProfessionalMBTIQuestion(
        question: "在做長期規劃時，你重視？",
        options: [
          "具體的里程碑和時間表",
          "願景和大方向的設定",
          "計劃對他人的影響",
          "個人價值觀的實現"
        ],
        scoring: {'S': 2, 'N': 3, 'F': 2, 'T': 1},
        category: "長期規劃",
        scenario: "未來設計"
      ),
      ProfessionalMBTIQuestion(
        question: "當需要給他人反饋時，你會？",
        options: [
          "直接指出問題和改進方向",
          "注重方式，避免傷害感情",
          "在合適的公開場合給出建議",
          "選擇私下一對一的方式"
        ],
        scoring: {'T': 3, 'F': 1, 'E': 2, 'I': 0},
        category: "反饋給予",
        scenario: "他人指導"
      ),
      ProfessionalMBTIQuestion(
        question: "面對資訊過載時，你的策略是？",
        options: [
          "系統性整理和分類資訊",
          "尋找關鍵趨勢和模式",
          "與他人討論篩選重點",
          "依直覺選擇重要資訊"
        ],
        scoring: {'S': 3, 'N': 1, 'E': 2, 'I': 0},
        category: "資訊管理",
        scenario: "資訊過載"
      ),
    ]
  ];

  void answerQuestion(int optionIndex) {
    final currentPhaseQuestions = testPhases[state.currentPhase];
    final currentQ = currentPhaseQuestions[state.currentQuestion];
    
    // 記錄答案
    final newAnswers = [...state.answers, currentQ.options[optionIndex]];
    
    // 更新分數 - 簡化邏輯
    final newScores = Map<String, List<int>>.from(state.dimensionScores);
    
    // 確保所有維度都有列表
    for (String dimension in ['E', 'I', 'S', 'N', 'T', 'F', 'J', 'P']) {
      if (newScores[dimension] == null) {
        newScores[dimension] = [];
      }
    }
    
    // 添加分數到對應維度
    currentQ.scoring.forEach((dimension, score) {
      newScores[dimension]!.add(score);
    });

    print('Debug: Current phase: ${state.currentPhase}, Question: ${state.currentQuestion}');
    print('Debug: Phase questions length: ${currentPhaseQuestions.length}');
    print('Debug: Option selected: $optionIndex');

    // 檢查是否完成當前階段
    if (state.currentQuestion + 1 >= currentPhaseQuestions.length) {
      // 進入下一階段或完成測試
      if (state.currentPhase + 1 >= testPhases.length) {
        // 完成測試，計算結果
        print('Debug: Test completed!');
        final result = _calculateProfessionalResult(newScores, newAnswers);
        state = state.copyWith(
          answers: newAnswers,
          dimensionScores: newScores,
          isCompleted: true,
          result: result,
        );
      } else {
        // 進入下一階段
        print('Debug: Moving to next phase');
        state = state.copyWith(
          currentPhase: state.currentPhase + 1,
          currentQuestion: 0,
          answers: newAnswers,
          dimensionScores: newScores,
        );
      }
    } else {
      // 下一題
      print('Debug: Moving to next question');
      state = state.copyWith(
        currentQuestion: state.currentQuestion + 1,
        answers: newAnswers,
        dimensionScores: newScores,
      );
    }
    
    print('Debug: New state - Phase: ${state.currentPhase}, Question: ${state.currentQuestion}');
  }

  MBTIPersonalityProfile _calculateProfessionalResult(
    Map<String, List<int>> scores, 
    List<String> answers
  ) {
    // 計算各維度傾向
    final eScore = scores['E']?.fold(0, (a, b) => a + b) ?? 0;
    final iScore = scores['I']?.fold(0, (a, b) => a + b) ?? 0;
    final sScore = scores['S']?.fold(0, (a, b) => a + b) ?? 0;
    final nScore = scores['N']?.fold(0, (a, b) => a + b) ?? 0;
    final tScore = scores['T']?.fold(0, (a, b) => a + b) ?? 0;
    final fScore = scores['F']?.fold(0, (a, b) => a + b) ?? 0;
    final jScore = scores['J']?.fold(0, (a, b) => a + b) ?? 0;
    final pScore = scores['P']?.fold(0, (a, b) => a + b) ?? 0;

    // 決定類型
    final e_i = eScore > iScore ? 'E' : 'I';
    final s_n = sScore > nScore ? 'S' : 'N';
    final t_f = tScore > fScore ? 'T' : 'F';
    final j_p = jScore > pScore ? 'J' : 'P';
    
    final type = e_i + s_n + t_f + j_p;
    
    // 計算維度強度
    final dimensionStrengths = {
      'E/I': e_i == 'E' ? eScore / (eScore + iScore) : iScore / (eScore + iScore),
      'S/N': s_n == 'S' ? sScore / (sScore + nScore) : nScore / (sScore + nScore),
      'T/F': t_f == 'T' ? tScore / (tScore + fScore) : fScore / (tScore + fScore),
      'J/P': j_p == 'J' ? jScore / (jScore + pScore) : pScore / (jScore + pScore),
    };

    return _generateDetailedProfile(type, dimensionStrengths, answers);
  }

  MBTIPersonalityProfile _generateDetailedProfile(
    String type, 
    Map<String, double> strengths,
    List<String> answers
  ) {
    // 根據類型生成詳細檔案
    final profiles = _getDetailedProfiles();
    final baseProfile = profiles[type]!;
    
    // 個性化建議（基於答案模式分析）
    final personalizedAdvice = _generatePersonalizedAdvice(type, answers, strengths);
    final datingInsights = _generateDatingInsights(type, strengths);
    
    return MBTIPersonalityProfile(
      type: type,
      title: baseProfile['title']!,
      archetype: baseProfile['archetype']!,
      dimensionStrengths: strengths,
      coreTraits: List<String>.from(baseProfile['coreTraits']!),
      strengths: List<String>.from(baseProfile['strengths']!),
      developmentAreas: List<String>.from(baseProfile['developmentAreas']!),
      idealCareers: List<String>.from(baseProfile['idealCareers']!),
      relationshipStyle: List<String>.from(baseProfile['relationshipStyle']!),
      stressManagement: List<String>.from(baseProfile['stressManagement']!),
      learningStyle: List<String>.from(baseProfile['learningStyle']!),
      personalGrowthAdvice: personalizedAdvice,
      datingInsights: datingInsights,
    );
  }

  String _generatePersonalizedAdvice(String type, List<String> answers, Map<String, double> strengths) {
    // 基於MBTI類型和維度強度生成個性化建議
    final baseAdvice = {
      'INTJ': '作為建築師類型，您擁有卓越的戰略思維和獨立性。建議在人際關係中學會表達內心的關懷，並給予伴侶足夠的成長空間。您的長遠規劃能力可以為關係帶來穩定，但記得也要享受當下的浪漫時刻。',
      'INTP': '您的邏輯思維和創新能力令人印象深刻。在感情中，嘗試更多地分享您的想法和感受，讓伴侶了解您內心豐富的世界。雖然您重視獨立，但適度的情感表達能加深彼此的連結。',
      'ENTJ': '作為天生的領導者，您在關係中展現出強大的決心和目標感。建議在規劃共同未來的同時，也要學會傾聽伴侶的想法和感受。您的執行力可以讓關係不斷進步，但記得給彼此一些輕鬆的時光。',
      'ENTP': '您的創新思維和充沛活力為關係帶來無限可能。建議在享受新鮮體驗的同時，也要學會在重要時刻展現專注和承諾。您的辦論技巧很棒，但記得在衝突中多一些耐心和理解。',
      'INFJ': '您深刻的洞察力和同理心是關係中的珍貴禮物。建議設定健康的個人界限，不要過度犧牲自己來滿足他人。您對意義的追求可以為關係帶來深度，記得也要關注實際的生活細節。',
      'INFP': '您的真誠和創造力為關係增添美好色彩。建議在保持真實自我的同時，也要學會更直接地表達需求和想法。您的價值觀很重要，但也要學會在小事上妥協和包容。',
      'ENFJ': '您天生的關懷能力和領導魅力讓人著迷。建議在照顧他人的同時，也要記得關愛自己。您善於激勵他人成長，但記得給伴侶自主選擇的空間，不要過度主導關係的發展。',
      'ENFP': '您的熱情和創意為關係帶來歡樂和驚喜。建議在追求新鮮感的同時，也要學會在平凡中發現美好。您的社交能力很強，但要確保給伴侶足夠的專注和安全感。',
      'ISTJ': '您的可靠和穩定是關係的堅實基礎。建議在維持傳統價值的同時，也要開放心態嘗試新的體驗。您的責任感很強，但記得也要表達情感和創造浪漫時刻。',
      'ISFJ': '您溫暖的關懷和無私奉獻令人感動。建議學會表達自己的需求，不要總是默默承受。您很會照顧他人，但記得也要為自己設定界限，保護自己的能量。',
      'ESTJ': '您的組織能力和執行力為關係提供穩定方向。建議在追求效率的同時，也要留出時間享受浪漫和情感交流。您的決策能力很強，但記得多聽取伴侶的意見。',
      'ESFJ': '您的溫暖和體貼讓關係充滿和諧。建議在關心他人的同時，也要學會獨立思考和表達不同意見。您很善於營造溫馨氛圍，但也要確保關係中有足夠的深度討論。',
      'ISTP': '您的冷靜和實用技能在關係中很有價值。建議學會更多地分享內心想法和情感。您重視個人空間，但也要記得主動表達關愛和承諾。',
      'ISFP': '您的溫和和藝術氣質為關係增添美感。建議在保持和諧的同時，也要學會處理衝突和表達不同意見。您的創造力很棒，可以為關係帶來更多驚喜和美好回憶。',
      'ESTP': '您的活力和適應性為關係帶來動力。建議在享受當下的同時，也要學會做長期規劃和深度溝通。您的行動力很強，但記得也要耐心傾聽伴侶的想法。',
      'ESFP': '您的熱情和樂觀為關係帶來歡樂。建議在享受生活的同時，也要學會處理困難時刻和深層情感。您很會營造氣氛，但也要確保關係有足夠的深度和承諾。',
    };
    
    var advice = baseAdvice[type] ?? '您有獨特的性格特質，建議在關係中保持真實自我，同時也要學會適應和成長。';
    
    // 根據維度強度調整建議
    strengths.forEach((dimension, strength) {
      if (strength > 0.7) {
        switch (dimension) {
          case 'E/I':
            if (dimension.startsWith('E')) {
              advice += '您的外向特質很強，記得也要給伴侶獨處和深度思考的空間。';
            } else {
              advice += '您的內向特質明顯，建議適度主動分享想法和參與社交活動。';
            }
            break;
          case 'S/N':
            if (dimension.startsWith('S')) {
              advice += '您重視實際細節，可以為關係帶來穩定，但也要開放心態探索新可能性。';
            } else {
              advice += '您富有想像力和遠見，但也要注意現實需求和實際執行。';
            }
            break;
          case 'T/F':
            if (dimension.startsWith('T')) {
              advice += '您的理性分析很有價值，但記得也要表達和回應情感需求。';
            } else {
              advice += '您的同理心很強，但也要學會客觀分析和做理性決定。';
            }
            break;
          case 'J/P':
            if (dimension.startsWith('J')) {
              advice += '您的計劃性和組織能力很好，但也要學會靈活應變和享受自然發展。';
            } else {
              advice += '您的靈活性很棒，但在重要事情上要學會做承諾和堅持執行。';
            }
            break;
        }
      }
    });
    
    return advice;
  }

  String _generateDatingInsights(String type, Map<String, double> strengths) {
    final datingInsights = {
      'INTJ': '在約會中，您喜歡深度有意義的對話勝過表面的閒聊。建議選擇能激發智慧討論的約會場所，如博物館、書店或安靜的咖啡廳。您重視效率，所以直接而誠實的溝通方式最適合您。記住，適度的神秘感和逐步分享內心世界會增加吸引力。在約會規劃上發揮您的戰略思維，但也要留出自然發展的空間。',
      'INTP': '您在約會中展現出獨特的思維魅力和學識深度。建議選擇能刺激思考的活動，如科學館、辯論會或主題討論。您需要時間來處理情感，所以不用急於表達，慢慢分享您的想法即可。您的好奇心和分析能力很吸引人，可以通過詢問深層問題來展現這個特質。記住，偶爾的情感表達會讓對方感受到您的真心。',
      'ENTJ': '您在約會中展現出自信的領導魅力和明確的目標感。建議選擇稍有挑戰性的活動，如戶外運動、商業活動或文化展覽。您天生的組織能力讓約會規劃變得高效且有趣。在對話中，分享您的抱負和成就，但也要詢問對方的目標和夢想。記住，即使您習慣主導，也要給對方表達意見和做決定的機會。',
      'ENTP': '您在約會中充滿創意和驚喜，總能讓氣氛變得輕鬆有趣。建議選擇新奇或富有變化的活動，如主題餐廳、即興表演或城市探索。您的幽默感和辯論技巧很有魅力，但要注意不要過度展現，給對方表達的空間。您善於發現新的可能性，可以在約會中提出有趣的"假設性問題"來增加互動。記住，專注聆聽對方說話會讓他們感受到被重視。',
      'INFJ': '您在約會中帶來深度的情感連結和意義感。建議選擇能促進深度交流的環境，如安靜的餐廳、藝術展覽或自然環境。您的洞察力很強，能敏銳感知對方的情緒，但要小心不要過度分析。分享您對生活意義的思考會很吸引人，但也要聆聽對方的價值觀。記住，適度的神秘感和逐步開放會增加您的魅力，不用急於完全敞開心扉。',
      'INFP': '您在約會中展現出真誠的個人魅力和豐富的內心世界。建議選擇能激發創意和個人表達的活動，如藝術工作坊、音樂會或文學咖啡。您的真實性很珍貴，但在早期約會中可以逐步分享深層想法。您對美好事物的敏感度很高，可以通過欣賞藝術、自然或音樂來展現這個特質。記住，雖然您重視和諧，但表達真實想法會讓關係更加深入。',
      'ENFJ': '您在約會中展現出溫暖的關懷和天然的魅力。建議選擇能幫助您了解對方的活動，如志願服務、文化活動或社交聚會。您天生善於讓他人感到舒適和被重視，這是很大的吸引力。在對話中，您的鼓勵和支持會讓對方感到特別。記住，雖然您喜歡照顧他人，但也要分享自己的需求和想法，讓對方有機會關心您。',
      'ENFP': '您在約會中充滿感染力的熱情和創意想法。建議選擇充滿樂趣和新鮮感的活動，如節慶活動、冒險體驗或創意工作坊。您的社交能力和正能量很有魅力，能讓約會變得輕鬆愉快。您善於發現他人的潛力，可以通過真誠的讚美和鼓勵來表達興趣。記住，在享受熱鬧的同時，也要創造一些一對一的深度交流時間。',
      'ISTJ': '您在約會中展現出可靠的品格和傳統的魅力。建議選擇經典而有品質的活動，如高級餐廳、歷史博物館或音樂會。您的可靠性和責任感很吸引人，可以通過準時、禮貌和周到的安排來展現。您重視傳統價值，可以分享家庭、事業和人生規劃來表達認真的態度。記住，適度的幽默和輕鬆感會讓您更加平易近人。',
      'ISFJ': '您在約會中展現出溫柔的關懷和體貼的細心。建議選擇溫馨舒適的環境，如家庭式餐廳、花園咖啡或手工活動。您天生的細心和關懷很有魅力，會讓對方感到被珍惜。您善於創造舒適的氛圍，可以通過小小的貼心舉動來表達關心。記住，雖然您習慣照顧他人，但也要表達自己的喜好和需求，讓對方了解真實的您。',
      'ESTJ': '您在約會中展現出自信的領導力和明確的人生方向。建議選擇有組織性的活動，如商務聚餐、體育賽事或文化展覽。您的決斷力和組織能力很有魅力，會讓對方感到安全感。您可以分享事業成就和人生規劃來展現穩重。記住，在展現能力的同時，也要詢問對方的想法和感受，展現您重視他們意見的一面。',
      'ESFJ': '您在約會中展現出溫暖的社交魅力和關懷他人的特質。建議選擇社交性的活動，如聚餐、社區活動或團體體驗。您天生的親和力和溝通技巧很有魅力，能讓約會氛圍變得愉快和諧。您善於營造溫馨氣氛，可以通過關心對方的日常生活來表達興趣。記住，在關注他人的同時，也要分享自己的想法和經歷，讓對方更了解您。',
      'ISTP': '您在約會中展現出冷靜的魅力和實用的技能。建議選擇動手或戶外的活動，如烹飪課程、戶外運動或技術展示。您的實用技能和冷靜應對很有吸引力，可以在需要時展現您的能力。您不善言辭但行動力強，可以通過實際行動來表達關心。記住，雖然您重視個人空間，但適度的情感分享會讓關係更加親密。',
      'ISFP': '您在約會中展現出溫和的藝術氣質和真誠的個性。建議選擇能激發美感的活動，如藝術展覽、音樂會或自然景點。您的創造力和美感很有魅力，可以通過分享藝術作品或美好體驗來表達情感。您的溫和和善解人意讓人感到舒適。記住，雖然您避免衝突，但表達真實想法會讓關係更加深入和真誠。',
      'ESTP': '您在約會中充滿活力和冒險精神，總能帶來刺激和樂趣。建議選擇動態和互動性強的活動，如運動體驗、遊樂園或即興活動。您的幽默感和適應能力很有魅力，能讓約會變得輕鬆有趣。您善於把握當下，可以創造難忘的體驗和回憶。記住，在享受當下的同時，也要表達對未來的想法和承諾。',
      'ESFP': '您在約會中展現出感染力的熱情和自然的魅力。建議選擇熱鬧有趣的活動，如聚會、表演或節慶活動。您的樂觀和社交能力很有吸引力，能讓約會充滿歡笑和正能量。您善於營造愉快氣氛，可以通過分享有趣經歷來增加互動。記住，在享受歡樂的同時，也要創造一些深度交流的時刻，讓對方了解您內心的想法。',
    };
    
    return datingInsights[type] ?? '在約會中保持真實的自我，同時也要學會了解和適應對方的特質。良好的溝通和相互尊重是建立深度關係的基礎。';
  }

  Map<String, Map<String, dynamic>> _getDetailedProfiles() {
    return {
      'INTJ': {
        'title': '建築師 - 策略大師',
        'archetype': '理性的完美主義者',
        'coreTraits': ['獨立思考', '長遠規劃', '系統性分析', '追求卓越', '內在動機強'],
        'strengths': ['戰略思維', '獨立自主', '堅持不懈', '創新能力', '深度洞察'],
        'developmentAreas': ['表達情感', '團隊協作', '靈活應變', '社交技巧', '耐心溝通'],
        'idealCareers': ['戰略顧問', '系統架構師', '研究科學家', '企業家', '管理顧問'],
        'relationshipStyle': ['深度連結', '忠誠專一', '成長導向', '理性溝通', '長期承諾'],
        'stressManagement': ['獨處思考', '系統分析', '長期規劃', '目標重設', '理性梳理'],
        'learningStyle': ['理論框架', '獨立研究', '深度思考', '實踐應用', '概念整合'],
      },
      'INTP': {
        'title': '思想家 - 邏輯探索者',
        'archetype': '好奇的理論家',
        'coreTraits': ['邏輯思維', '理論探索', '創新思考', '獨立性強', '求知慾旺'],
        'strengths': ['分析能力', '創意思維', '客觀判斷', '學習能力', '問題解決'],
        'developmentAreas': ['實際執行', '情感表達', '社交互動', '時間管理', '決策果斷'],
        'idealCareers': ['研究員', '軟體工程師', '哲學家', '數學家', '發明家'],
        'relationshipStyle': ['智慧共鳴', '尊重獨立', '理性討論', '成長空間', '深度理解'],
        'stressManagement': ['獨立思考', '理論研究', '創意表達', '問題分析', '知識學習'],
        'learningStyle': ['概念理解', '邏輯推理', '自主探索', '實驗驗證', '理論建構'],
      },
      'ENTJ': {
        'title': '指揮官 - 天生領袖',
        'archetype': '魅力十足的領導者',
        'coreTraits': ['領導能力', '戰略思維', '決策果斷', '目標導向', '影響他人'],
        'strengths': ['組織能力', '遠見卓識', '執行力強', '溝通技巧', '團隊建設'],
        'developmentAreas': ['耐心聆聽', '情感關懷', '細節注意', '壓力管理', '同理心'],
        'idealCareers': ['CEO', '管理顧問', '律師', '政治家', '企業家'],
        'relationshipStyle': ['伙伴關係', '共同成長', '目標一致', '相互挑戰', '支持事業'],
        'stressManagement': ['制定計劃', '運動健身', '團隊討論', '目標調整', '效率提升'],
        'learningStyle': ['實戰演練', '案例分析', '團隊討論', '目標導向', '快速應用'],
      },
      'ENTP': {
        'title': '辯論家 - 創新啟發者',
        'archetype': '充滿活力的創新者',
        'coreTraits': ['創新思維', '靈活變通', '熱情洋溢', '辯論技巧', '可能性思考'],
        'strengths': ['創意無限', '適應能力', '溝通魅力', '學習快速', '激勵他人'],
        'developmentAreas': ['專注持續', '細節執行', '情感穩定', '承諾堅持', '耐心等待'],
        'idealCareers': ['創意總監', '市場行銷', '創業家', '記者', '培訓師'],
        'relationshipStyle': ['智慧火花', '自由空間', '冒險體驗', '思想碰撞', '成長刺激'],
        'stressManagement': ['創意表達', '社交互動', '新鮮體驗', '思維跳躍', '變化環境'],
        'learningStyle': ['頭腦風暴', '互動討論', '實驗嘗試', '快速概覽', '跨域學習'],
      },
      'INFJ': {
        'title': '倡導者 - 理想主義的指導者',
        'archetype': '有洞察力的理想主義者',
        'coreTraits': ['直覺敏銳', '價值驅動', '關懷他人', '內在豐富', '追求意義'],
        'strengths': ['同理心強', '洞察人心', '創造力', '專注力', '啟發他人'],
        'developmentAreas': ['自我關懷', '界限設定', '實際行動', '衝突處理', '壓力釋放'],
        'idealCareers': ['心理諮詢師', '作家', '非營利組織', '教育工作者', '藝術家'],
        'relationshipStyle': ['深度連結', '精神契合', '相互理解', '成長支持', '價值共鳴'],
        'stressManagement': ['獨處反思', '創意表達', '自然環境', '冥想靜心', '意義尋找'],
        'learningStyle': ['整體理解', '個人化學習', '價值連結', '反思內化', '創意應用'],
      },
      'INFP': {
        'title': '調停者 - 理想主義的夢想家',
        'archetype': '富有同情心的理想主義者',
        'coreTraits': ['價值導向', '創意豐富', '同理心強', '個人化', '真實性'],
        'strengths': ['創造力', '適應力', '理解他人', '價值堅持', '獨特視角'],
        'developmentAreas': ['自信表達', '決策果斷', '衝突面對', '實際執行', '自我推銷'],
        'idealCareers': ['作家', '心理師', '社工', '藝術家', '人力資源'],
        'relationshipStyle': ['真誠相待', '深度理解', '成長陪伴', '價值認同', '個人空間'],
        'stressManagement': ['創意表達', '獨處時間', '自然環境', '音樂藝術', '價值確認'],
        'learningStyle': ['個人興趣', '價值連結', '創意方式', '自主步調', '實踐體驗'],
      },
      'ENFJ': {
        'title': '主人公 - 魅力四射的領袖',
        'archetype': '充滿魅力的啟發者',
        'coreTraits': ['人際敏感', '激勵他人', '組織能力', '價值驅動', '溝通高手'],
        'strengths': ['領導魅力', '團隊建設', '溝通技巧', '同理心', '成長促進'],
        'developmentAreas': ['自我關懷', '界限設定', '客觀分析', '壓力管理', '個人時間'],
        'idealCareers': ['人力資源', '教師', '培訓師', '政治家', '諮詢師'],
        'relationshipStyle': ['相互成長', '深度支持', '共同理想', '情感連結', '激勵伙伴'],
        'stressManagement': ['社交連結', '幫助他人', '運動健身', '團隊活動', '意義工作'],
        'learningStyle': ['互動學習', '團隊討論', '實際應用', '人際連結', '價值導向'],
      },
      'ENFP': {
        'title': '競選者 - 熱情的激勵者',
        'archetype': '充滿熱情的啟發者',
        'coreTraits': ['熱情洋溢', '創意思維', '人際魅力', '可能性思考', '價值驅動'],
        'strengths': ['創新能力', '人際關係', '適應力強', '溝通技巧', '激勵他人'],
        'developmentAreas': ['專注持續', '細節管理', '時間規劃', '現實評估', '決策堅持'],
        'idealCareers': ['市場行銷', '公關', '心理師', '記者', '演員'],
        'relationshipStyle': ['熱情投入', '成長冒險', '深度連結', '自由空間', '共同探索'],
        'stressManagement': ['社交互動', '創意表達', '新鮮體驗', '運動活動', '正向思考'],
        'learningStyle': ['互動參與', '實驗嘗試', '團隊合作', '創意方法', '多樣化學習'],
      },
      'ISTJ': {
        'title': '物流師 - 可靠的管理者',
        'archetype': '務實可靠的守護者',
        'coreTraits': ['責任感強', '細心謹慎', '傳統價值', '計劃性強', '忠誠可靠'],
        'strengths': ['組織能力', '責任心', '注重細節', '執行力', '穩定可靠'],
        'developmentAreas': ['創新思維', '靈活應變', '情感表達', '風險承擔', '開放態度'],
        'idealCareers': ['會計師', '銀行家', '法官', '醫生', '工程師'],
        'relationshipStyle': ['穩定承諾', '忠誠可靠', '傳統價值', '實際支持', '長期關係'],
        'stressManagement': ['規律作息', '詳細計劃', '傳統活動', '獨處時間', '穩定環境'],
        'learningStyle': ['結構化學習', '步驟清晰', '實際應用', '重複練習', '傳統方法'],
      },
      'ISFJ': {
        'title': '守護者 - 溫暖的保護者',
        'archetype': '溫暖貼心的守護者',
        'coreTraits': ['關懷他人', '細心體貼', '責任感強', '傳統價值', '服務精神'],
        'strengths': ['同理心', '支持他人', '注重細節', '忠誠度高', '實用技能'],
        'developmentAreas': ['自我主張', '界限設定', '創新思維', '壓力管理', '自我關懷'],
        'idealCareers': ['護士', '教師', '社工', '人力資源', '諮詢師'],
        'relationshipStyle': ['無私奉獻', '細心關懷', '穩定支持', '傳統價值', '家庭導向'],
        'stressManagement': ['幫助他人', '規律生活', '獨處休息', '傳統活動', '和諧環境'],
        'learningStyle': ['實際應用', '循序漸進', '他人支持', '服務學習', '傳統方法'],
      },
      'ESTJ': {
        'title': '總經理 - 高效的管理者',
        'archetype': '高效務實的領導者',
        'coreTraits': ['組織能力', '執行力強', '目標導向', '責任感', '現實務實'],
        'strengths': ['領導才能', '組織管理', '執行效率', '決策能力', '團隊協調'],
        'developmentAreas': ['靈活思維', '情感理解', '創新意識', '耐心傾聽', '壓力釋放'],
        'idealCareers': ['管理者', '律師', '軍官', '銀行家', '項目經理'],
        'relationshipStyle': ['穩定承諾', '實際支持', '共同目標', '傳統價值', '責任分擔'],
        'stressManagement': ['運動健身', '目標達成', '組織活動', '效率提升', '制定計劃'],
        'learningStyle': ['實戰練習', '結構化學習', '團隊合作', '目標導向', '即時應用'],
      },
      'ESFJ': {
        'title': '執政官 - 關懷的支持者',
        'archetype': '熱心助人的協調者',
        'coreTraits': ['關懷他人', '和諧協調', '責任心強', '傳統價值', '社交活躍'],
        'strengths': ['人際關係', '團隊合作', '支持他人', '組織協調', '實用技能'],
        'developmentAreas': ['獨立思考', '衝突處理', '創新意識', '自我關懷', '批判思維'],
        'idealCareers': ['教師', '護士', '銷售', '公關', '活動策劃'],
        'relationshipStyle': ['關懷支持', '和諧相處', '傳統價值', '家庭重視', '社交活躍'],
        'stressManagement': ['社交互動', '幫助他人', '傳統活動', '和諧環境', '團隊支持'],
        'learningStyle': ['互動學習', '團隊合作', '實際應用', '他人鼓勵', '傳統方法'],
      },
      'ISTP': {
        'title': '巧匠 - 實用的問題解決者',
        'archetype': '冷靜務實的工匠',
        'coreTraits': ['實用技能', '獨立自主', '冷靜理性', '適應力強', '動手能力'],
        'strengths': ['問題解決', '技術能力', '獨立性', '適應力', '冷靜分析'],
        'developmentAreas': ['情感表達', '長期規劃', '人際溝通', '承諾堅持', '理論學習'],
        'idealCareers': ['工程師', '技師', '飛行員', '運動員', '程式設計師'],
        'relationshipStyle': ['實際行動', '個人空間', '低調支持', '冒險共享', '簡單直接'],
        'stressManagement': ['獨處時間', '動手操作', '戶外活動', '技能練習', '實際問題'],
        'learningStyle': ['動手實作', '實際操作', '個人步調', '問題導向', '技能培養'],
      },
      'ISFP': {
        'title': '探險家 - 靈活的藝術家',
        'archetype': '溫和的創意探索者',
        'coreTraits': ['藝術天分', '價值導向', '靈活適應', '個人化', '和諧追求'],
        'strengths': ['創造力', '適應性', '同理心', '美感', '個人風格'],
        'developmentAreas': ['自信表達', '長期規劃', '決策果斷', '衝突處理', '組織能力'],
        'idealCareers': ['藝術家', '設計師', '心理師', '音樂家', '攝影師'],
        'relationshipStyle': ['溫和支持', '深度理解', '個人空間', '美感共享', '價值認同'],
        'stressManagement': ['藝術創作', '自然環境', '獨處時間', '美感體驗', '靈活安排'],
        'learningStyle': ['體驗學習', '個人化方式', '創意方法', '實際操作', '自主步調'],
      },
      'ESTP': {
        'title': '企業家 - 精力充沛的推動者',
        'archetype': '活力四射的行動者',
        'coreTraits': ['行動導向', '社交活躍', '現實務實', '適應力強', '享受當下'],
        'strengths': ['執行能力', '人際魅力', '適應性', '實用技能', '危機處理'],
        'developmentAreas': ['長期規劃', '深度思考', '情感理解', '耐心等待', '理論學習'],
        'idealCareers': ['銷售', '創業家', '演員', '警察', '運動員'],
        'relationshipStyle': ['熱情活躍', '當下享受', '冒險體驗', '社交豐富', '實際支持'],
        'stressManagement': ['社交活動', '運動健身', '新鮮體驗', '實際行動', '團隊互動'],
        'learningStyle': ['實戰演練', '互動學習', '即時反饋', '實際應用', '活動導向'],
      },
      'ESFP': {
        'title': '娛樂家 - 自由奔放的表演者',
        'archetype': '熱情洋溢的表演者',
        'coreTraits': ['熱情開朗', '社交天才', '創意表達', '享受生活', '人際和諧'],
        'strengths': ['人際魅力', '創造力', '適應性', '溝通技巧', '正能量'],
        'developmentAreas': ['長期規劃', '深度分析', '衝突處理', '細節管理', '批判思維'],
        'idealCareers': ['演員', '銷售', '公關', '教師', '活動策劃'],
        'relationshipStyle': ['熱情投入', '樂趣分享', '社交豐富', '情感表達', '當下珍惜'],
        'stressManagement': ['社交互動', '娛樂活動', '創意表達', '正面思考', '人際支持'],
        'learningStyle': ['互動參與', '實際體驗', '團隊學習', '娛樂方式', '即時應用'],
      },
    };
  }

  void resetTest() {
    state = ProfessionalMBTIState();
  }

  void goBack() {
    if (state.currentQuestion > 0) {
      state = state.copyWith(currentQuestion: state.currentQuestion - 1);
    } else if (state.currentPhase > 0) {
      final prevPhaseLength = testPhases[state.currentPhase - 1].length;
      state = state.copyWith(
        currentPhase: state.currentPhase - 1,
        currentQuestion: prevPhaseLength - 1,
      );
    }
  }
}

class ProfessionalMBTITestPage extends ConsumerWidget {
  const ProfessionalMBTITestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(professionalTestProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('專業 MBTI 性格深度分析'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        centerTitle: true,
      ),
      body: testState.isCompleted 
        ? _buildResultPage(context, ref, testState.result!)
        : _buildTestPage(context, ref, testState),
    );
  }

  Widget _buildTestPage(BuildContext context, WidgetRef ref, ProfessionalMBTIState testState) {
    final notifier = ref.read(professionalTestProvider.notifier);
    final currentPhaseQuestions = notifier.testPhases[testState.currentPhase];
    final currentQuestion = currentPhaseQuestions[testState.currentQuestion];
    
    final totalQuestions = notifier.testPhases.fold(0, (sum, phase) => sum + phase.length);
    final currentQuestionNumber = notifier.testPhases
        .take(testState.currentPhase)
        .fold(0, (sum, phase) => sum + phase.length) + testState.currentQuestion + 1;
    
    final progress = currentQuestionNumber / totalQuestions;
    
    return Column(
      children: [
        // 進度指示器
        _buildProgressIndicator(testState.currentPhase + 1, progress, currentQuestionNumber, totalQuestions),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 階段標題
                _buildPhaseHeader(testState.currentPhase),
                
                const SizedBox(height: 30),
                
                // 問題卡片
                _buildQuestionCard(currentQuestion),
                
                const SizedBox(height: 30),
                
                // 選項
                ...currentQuestion.options.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildOptionButton(
                      context, 
                      ref, 
                      entry.value, 
                      entry.key,
                    ),
                  );
                }).toList(),
                
                const Spacer(),
                
                // 控制按鈕
                _buildControlButtons(context, ref, testState),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int phase, double progress, int current, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 $phase 階段',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '$current / $total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(Colors.blue, Colors.purple, progress) ?? Colors.blue,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseHeader(int phase) {
    final phaseInfo = [
      {'title': '情境判斷', 'subtitle': '了解您在不同情境下的自然反應'},
      {'title': '價值觀探索', 'subtitle': '探索您的核心價值觀和信念'},
      {'title': '行為模式', 'subtitle': '分析您的行為模式和偏好'},
    ];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phaseInfo[phase]['title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            phaseInfo[phase]['subtitle']!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ProfessionalMBTIQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.scenario.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.scenario,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, WidgetRef ref, String text, int index) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
    ];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ref.read(professionalTestProvider.notifier).answerQuestion(index);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors[index],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, WidgetRef ref, ProfessionalMBTIState testState) {
    return Row(
      children: [
        if (testState.currentQuestion > 0 || testState.currentPhase > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(professionalTestProvider.notifier).goBack();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('上一題'),
            ),
          ),
        const SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: () {
              ref.read(professionalTestProvider.notifier).resetTest();
              Navigator.pop(context);
            },
            child: const Text('暫停測試'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultPage(BuildContext context, WidgetRef ref, MBTIPersonalityProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 結果標題卡片
          _buildResultHeader(profile),
          
          const SizedBox(height: 25),
          
          // 維度強度分析
          _buildDimensionAnalysis(profile),
          
          const SizedBox(height: 25),
          
          // 詳細分析部分
          _buildDetailedAnalysis(profile),
          
          const SizedBox(height: 30),
          
          // 行動按鈕
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildResultHeader(MBTIPersonalityProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            profile.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.archetype,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionAnalysis(MBTIPersonalityProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性格維度分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          ...profile.dimensionStrengths.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildDimensionBar(entry.key, entry.value),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDimensionBar(String dimension, double strength) {
    final dimensionLabels = {
      'E/I': ['外向 (E)', '內向 (I)'],
      'S/N': ['感覺 (S)', '直覺 (N)'],
      'T/F': ['思考 (T)', '情感 (F)'],
      'J/P': ['判斷 (J)', '知覺 (P)'],
    };
    
    final labels = dimensionLabels[dimension]!;
    final isFirst = strength > 0.5;
    final displayStrength = isFirst ? strength : 1 - strength;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFirst ? labels[0] : labels[1],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              '${(displayStrength * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: displayStrength,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            isFirst ? Colors.blue.shade400 : Colors.green.shade400,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis(MBTIPersonalityProfile profile) {
    return Column(
      children: [
        _buildAnalysisSection('核心特質', profile.coreTraits, Icons.psychology, Colors.purple),
        const SizedBox(height: 20),
        _buildAnalysisSection('天賦優勢', profile.strengths, Icons.star, Colors.amber),
        const SizedBox(height: 20),
        _buildAnalysisSection('發展領域', profile.developmentAreas, Icons.trending_up, Colors.orange),
        const SizedBox(height: 20),
        _buildAnalysisSection('理想職業', profile.idealCareers, Icons.work, Colors.blue),
        const SizedBox(height: 20),
        _buildAnalysisSection('關係風格', profile.relationshipStyle, Icons.favorite, Colors.pink),
        const SizedBox(height: 20),
        _buildInsightCard('約會洞察', profile.datingInsights, Icons.favorite_border, Colors.red),
        const SizedBox(height: 20),
        _buildInsightCard('成長建議', profile.personalGrowthAdvice, Icons.lightbulb, Colors.green),
      ],
    );
  }

  Widget _buildAnalysisSection(String title, List<String> items, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 保存結果
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('結果已保存到您的個人檔案')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('保存到個人檔案', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(professionalTestProvider.notifier).resetTest();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('重新測試'),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // 分享結果
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.blue.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('分享結果', style: TextStyle(color: Colors.blue.shade400)),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 