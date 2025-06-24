import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// MBTI 測試狀態管理
final currentQuestionProvider = StateProvider<int>((ref) => 0);
final answersProvider = StateProvider<Map<int, bool>>((ref) => {});
final testResultProvider = StateProvider<String?>((ref) => null);

// MBTI 問題數據模型
class MBTIQuestion {
  final String question;
  final String trueAnswer;  // True 時的傾向
  final String falseAnswer; // False 時的傾向
  final String dimension;   // E/I, S/N, T/F, J/P

  MBTIQuestion({
    required this.question,
    required this.trueAnswer,
    required this.falseAnswer,
    required this.dimension,
  });
}

// MBTI 測試問題庫
final mbtiQuestions = [
  // 外向 (E) vs 內向 (I)
  MBTIQuestion(
    question: "在聚會中，我通常...",
    trueAnswer: "主動與陌生人交談，享受熱鬧的氣氛",
    falseAnswer: "更喜歡與少數熟悉的朋友深入交談",
    dimension: "E/I",
  ),
  MBTIQuestion(
    question: "當我需要恢復精力時，我會...",
    trueAnswer: "和朋友出去或參加社交活動",
    falseAnswer: "獨自一人安靜地休息",
    dimension: "E/I",
  ),
  MBTIQuestion(
    question: "在工作場所，我傾向於...",
    trueAnswer: "在開放的環境中與團隊協作",
    falseAnswer: "在安靜的環境中專注工作",
    dimension: "E/I",
  ),
  MBTIQuestion(
    question: "我在決策時通常...",
    trueAnswer: "喜歡與他人討論來獲得不同觀點",
    falseAnswer: "喜歡獨自思考後再做決定",
    dimension: "E/I",
  ),

  // 感覺 (S) vs 直覺 (N)
  MBTIQuestion(
    question: "我更信任...",
    trueAnswer: "具體的事實和經驗",
    falseAnswer: "直覺和可能性",
    dimension: "S/N",
  ),
  MBTIQuestion(
    question: "在學習新事物時，我喜歡...",
    trueAnswer: "從實際例子和步驟開始",
    falseAnswer: "先了解整體概念和理論",
    dimension: "S/N",
  ),
  MBTIQuestion(
    question: "我對細節的態度是...",
    trueAnswer: "注重準確性和具體細節",
    falseAnswer: "關注大局，細節可以後續完善",
    dimension: "S/N",
  ),
  MBTIQuestion(
    question: "在解決問題時，我依賴...",
    trueAnswer: "過往的經驗和已證實的方法",
    falseAnswer: "創新的想法和未來的可能性",
    dimension: "S/N",
  ),

  // 思考 (T) vs 情感 (F)
  MBTIQuestion(
    question: "做決定時，我更重視...",
    trueAnswer: "邏輯分析和客觀標準",
    falseAnswer: "個人價值觀和他人感受",
    dimension: "T/F",
  ),
  MBTIQuestion(
    question: "在衝突中，我傾向於...",
    trueAnswer: "分析問題並尋找合理解決方案",
    falseAnswer: "考慮所有人的感受並尋求和諧",
    dimension: "T/F",
  ),
  MBTIQuestion(
    question: "我更容易被什麼說服？",
    trueAnswer: "邏輯論證和數據證據",
    falseAnswer: "情感共鳴和個人故事",
    dimension: "T/F",
  ),
  MBTIQuestion(
    question: "給他人建議時，我會...",
    trueAnswer: "提供客觀分析和實用建議",
    falseAnswer: "提供情感支持和理解",
    dimension: "T/F",
  ),

  // 判斷 (J) vs 知覺 (P)
  MBTIQuestion(
    question: "我的工作風格是...",
    trueAnswer: "有計劃、有截止日期，提前完成",
    falseAnswer: "靈活應變，在壓力下迸發創意",
    dimension: "J/P",
  ),
  MBTIQuestion(
    question: "對於計劃，我...",
    trueAnswer: "喜歡制定詳細計劃並嚴格執行",
    falseAnswer: "喜歡保持選擇的開放性",
    dimension: "J/P",
  ),
  MBTIQuestion(
    question: "在旅行時，我傾向於...",
    trueAnswer: "提前預訂並制定詳細行程",
    falseAnswer: "保持彈性，隨興探索",
    dimension: "J/P",
  ),
  MBTIQuestion(
    question: "我對變化的態度是...",
    trueAnswer: "需要時間適應，喜歡穩定性",
    falseAnswer: "享受新變化帶來的刺激",
    dimension: "J/P",
  ),
];

// MBTI 類型描述
final mbtiDescriptions = {
  'INTJ': {
    'title': '建築師',
    'subtitle': '理性而獨立的策略家',
    'description': '具有強烈的直覺和創造力，善於規劃和實現長遠目標。獨立思考，追求知識和能力的提升。',
    'traits': ['獨立', '理性', '有遠見', '堅定'],
    'color': Colors.purple,
  },
  'INTP': {
    'title': '思想家',
    'subtitle': '創新而好奇的思想家',
    'description': '熱愛理論和抽象概念，享受探索新想法的過程。靈活、寬容，對感興趣的領域有強烈的專注力。',
    'traits': ['好奇', '邏輯', '創新', '靈活'],
    'color': Colors.blue,
  },
  'ENTJ': {
    'title': '指揮官',
    'subtitle': '大膽而富有想像力的領導者',
    'description': '天生的領導者，善於組織人力和資源實現目標。自信、堅決，總是能找到改進的方法。',
    'traits': ['領導力', '決斷', '自信', '效率'],
    'color': Colors.red,
  },
  'ENTP': {
    'title': '辯論家',
    'subtitle': '聰明而好奇的思想家',
    'description': '充滿創意和靈活性，擅長即興發揮。喜歡智力挑戰，能夠激發他人的潛能。',
    'traits': ['創意', '機智', '靈活', '樂觀'],
    'color': Colors.orange,
  },
  'INFJ': {
    'title': '提倡者',
    'subtitle': '安靜而神秘的啟發者',
    'description': '理想主義且有原則，關心他人的成長和發展。有強烈的直覺，能洞察他人的動機。',
    'traits': ['理想主義', '富有同情心', '有原則', '有創意'],
    'color': Colors.teal,
  },
  'INFP': {
    'title': '調停者',
    'subtitle': '詩意而善良的理想主義者',
    'description': '忠於自己的價值觀，希望讓世界變得更美好。善於理解他人，富有創造力和想像力。',
    'traits': ['理想主義', '善良', '創意', '適應性'],
    'color': Colors.green,
  },
  'ENFJ': {
    'title': '主人公',
    'subtitle': '魅力四射的天生領導者',
    'description': '充滿熱情和魅力，善於激勵他人實現潛能。關心他人的成長，是天生的導師。',
    'traits': ['魅力', '同理心', '鼓舞人心', '利他主義'],
    'color': Colors.pink,
  },
  'ENFP': {
    'title': '競選者',
    'subtitle': '熱情而富有創造力的自由精神',
    'description': '充滿熱情和創意，善於看到事物之間的聯繫。樂觀向上，能夠激發他人的熱情。',
    'traits': ['熱情', '創意', '樂觀', '靈活'],
    'color': Colors.amber,
  },
  'ISTJ': {
    'title': '物流師',
    'subtitle': '實用而注重事實的可靠工作者',
    'description': '負責任、可靠，重視傳統和忠誠。系統性地處理任務，是組織的中堅力量。',
    'traits': ['負責任', '可靠', '實用', '有條理'],
    'color': Colors.brown,
  },
  'ISFJ': {
    'title': '守護者',
    'subtitle': '非常獻身和溫暖的保護者',
    'description': '善良、可靠，總是願意幫助他人。注重和諧，善於記住他人的喜好和需求。',
    'traits': ['善良', '可靠', '耐心', '支持性'],
    'color': Colors.lightBlue,
  },
  'ESTJ': {
    'title': '總經理',
    'subtitle': '出色的管理者',
    'description': '實用、注重事實，善於管理人員和項目。重視傳統、秩序和安全感。',
    'traits': ['管理能力', '實用', '有條理', '專注'],
    'color': Colors.indigo,
  },
  'ESFJ': {
    'title': '執政官',
    'subtitle': '極有同情心、受歡迎的天生伙伴',
    'description': '關心他人的感受和需求，善於在團隊中創造和諧的氛圍。忠誠、關懷、合作。',
    'traits': ['關懷', '合作', '忠誠', '負責任'],
    'color': Colors.cyan,
  },
  'ISTP': {
    'title': '鑑賞家',
    'subtitle': '大膽而實際的實驗家',
    'description': '善於用手和工具探索和體驗。靈活、寬容，對機械和運動有天賦。',
    'traits': ['實用', '靈活', '寬容', '冷靜'],
    'color': Colors.grey,
  },
  'ISFP': {
    'title': '探險家',
    'subtitle': '靈活而迷人的藝術家',
    'description': '安靜、友善，敏感而富有同情心。珍視個人空間，忠於自己的價值觀。',
    'traits': ['友善', '敏感', '平和', '靈活'],
    'color': Colors.lightGreen,
  },
  'ESTP': {
    'title': '企業家',
    'subtitle': '聰明、精力充沛的感知者',
    'description': '自發、精力充沛，善於適應環境。喜歡與他人合作解決問題，享受當下的樂趣。',
    'traits': ['自發', '實用', '接受', '友善'],
    'color': Colors.deepOrange,
  },
  'ESFP': {
    'title': '娛樂家',
    'subtitle': '自發的、熱情的表演者',
    'description': '友善、開朗，喜歡與他人分享新體驗。善於與他人建立聯繫，享受生活的美好。',
    'traits': ['友善', '開朗', '自發', '合作'],
    'color': Colors.deepPurple,
  },
};

class MBTITestPage extends ConsumerWidget {
  final bool isProfessional;
  
  const MBTITestPage({super.key, this.isProfessional = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuestion = ref.watch(currentQuestionProvider);
    final answers = ref.watch(answersProvider);
    final testResult = ref.watch(testResultProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('MBTI 性格測試'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: testResult != null
          ? _buildResultPage(context, ref, testResult)
          : _buildTestPage(context, ref, currentQuestion, answers),
    );
  }

  Widget _buildTestPage(BuildContext context, WidgetRef ref, int currentQuestion, Map<int, bool> answers) {
    final questions = _getQuestions();
    
    if (currentQuestion >= questions.length) {
      // 計算結果
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = _calculateMBTIResult(answers, questions);
        ref.read(testResultProvider.notifier).state = result;
      });
      return const Center(child: CircularProgressIndicator());
    }

    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Column(
      children: [
        // 進度條
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '問題 ${currentQuestion + 1}/${questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
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
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // 問題卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // 選項按鈕
                _buildOptionButton(
                  context,
                  ref,
                  question.trueAnswer,
                  true,
                  currentQuestion,
                  Colors.purple.shade400,
                ),

                const SizedBox(height: 20),

                _buildOptionButton(
                  context,
                  ref,
                  question.falseAnswer,
                  false,
                  currentQuestion,
                  Colors.blue.shade400,
                ),

                const Spacer(),

                // 後退按鈕
                if (currentQuestion > 0)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        ref.read(currentQuestionProvider.notifier).state = currentQuestion - 1;
                      },
                      child: const Text('上一題'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    WidgetRef ref,
    String text,
    bool value,
    int questionIndex,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _answerQuestion(ref, questionIndex, value),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _answerQuestion(WidgetRef ref, int questionIndex, bool answer) {
    final answers = ref.read(answersProvider);
    ref.read(answersProvider.notifier).state = {
      ...answers,
      questionIndex: answer,
    };
    
    ref.read(currentQuestionProvider.notifier).state = questionIndex + 1;
  }

  List<MBTIQuestion> _getQuestions() {
    if (isProfessional) {
      // 專業版：60題（每個維度15題）
      return _getProfessionalQuestions();
    } else {
      // 簡易版：15題（每個維度約4題）
      return _getSimpleQuestions();
    }
  }
  
  List<MBTIQuestion> _getProfessionalQuestions() {
    // 專業版60題 - 每個維度15題
    return [
      // E/I 維度 - 15題
      ...mbtiQuestions.where((q) => q.dimension == 'E/I').take(4),
      ..._getAdditionalEIQuestions(),
      
      // S/N 維度 - 15題  
      ...mbtiQuestions.where((q) => q.dimension == 'S/N').take(4),
      ..._getAdditionalSNQuestions(),
      
      // T/F 維度 - 15題
      ...mbtiQuestions.where((q) => q.dimension == 'T/F').take(4),
      ..._getAdditionalTFQuestions(),
      
      // J/P 維度 - 15題
      ...mbtiQuestions.where((q) => q.dimension == 'J/P').take(4),
      ..._getAdditionalJPQuestions(),
    ];
  }
  
  List<MBTIQuestion> _getSimpleQuestions() {
    // 簡易版15題 - 每個維度約4題
    return [
      // E/I 維度 - 4題
      ...mbtiQuestions.where((q) => q.dimension == 'E/I').take(4),
      
      // S/N 維度 - 4題
      ...mbtiQuestions.where((q) => q.dimension == 'S/N').take(4),
      
      // T/F 維度 - 4題
      ...mbtiQuestions.where((q) => q.dimension == 'T/F').take(4),
      
      // J/P 維度 - 3題
      ...mbtiQuestions.where((q) => q.dimension == 'J/P').take(3),
    ];
  }
  
  List<MBTIQuestion> _getAdditionalEIQuestions() {
    return [
      MBTIQuestion(
        question: "在團隊會議中，我通常...",
        trueAnswer: "積極發言，分享我的想法",
        falseAnswer: "仔細聆聽，深思熟慮後才發言",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "週末時，我更喜歡...",
        trueAnswer: "參加聚會或戶外活動",
        falseAnswer: "在家閱讀或做自己的興趣愛好",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "學習新技能時，我傾向於...",
        trueAnswer: "參加課程或小組學習",
        falseAnswer: "自學或一對一指導",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "在壓力下，我會...",
        trueAnswer: "尋求他人的支持和建議",
        falseAnswer: "獨自處理，避免打擾他人",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "我的能量來源主要是...",
        trueAnswer: "與他人互動和外部刺激",
        falseAnswer: "內在思考和獨處時光",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "在新環境中，我會...",
        trueAnswer: "主動探索並與人交流",
        falseAnswer: "觀察環境，慢慢適應",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "表達想法時，我習慣...",
        trueAnswer: "邊想邊說，通過交流整理思路",
        falseAnswer: "先整理好思路再表達",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "在社交場合，我感到...",
        trueAnswer: "興奮和充滿活力",
        falseAnswer: "需要適應時間，有時會感到疲憊",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "我的朋友圈通常是...",
        trueAnswer: "廣泛的，有很多不同類型的朋友",
        falseAnswer: "較小但深入的，幾個親密朋友",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "工作時，我喜歡...",
        trueAnswer: "開放式辦公環境，可以隨時交流",
        falseAnswer: "安靜的個人空間，減少干擾",
        dimension: "E/I",
      ),
      MBTIQuestion(
        question: "慶祝成功時，我傾向於...",
        trueAnswer: "與大家分享喜悅",
        falseAnswer: "私下享受成就感",
        dimension: "E/I",
      ),
    ];
  }
  
  List<MBTIQuestion> _getAdditionalSNQuestions() {
    return [
      MBTIQuestion(
        question: "閱讀時，我更喜歡...",
        trueAnswer: "實用指南和具體案例",
        falseAnswer: "理論探討和抽象概念",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "記憶信息時，我依賴...",
        trueAnswer: "具體的細節和事實",
        falseAnswer: "整體印象和關聯性",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "做計劃時，我注重...",
        trueAnswer: "具體的步驟和時間安排",
        falseAnswer: "大方向和靈活性",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "我對變化的反應是...",
        trueAnswer: "需要具體了解變化的內容",
        falseAnswer: "對新可能性感到興奮",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "解釋概念時，我會...",
        trueAnswer: "使用具體例子和類比",
        falseAnswer: "從理論框架開始",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "我的注意力通常集中在...",
        trueAnswer: "當前的現實情況",
        falseAnswer: "未來的可能性",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "學習歷史時，我更感興趣的是...",
        trueAnswer: "具體的事件和人物",
        falseAnswer: "歷史趨勢和模式",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "我傾向於相信...",
        trueAnswer: "親身經歷和實證",
        falseAnswer: "直覺和預感",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "在創意工作中，我...",
        trueAnswer: "從現有元素中改進",
        falseAnswer: "追求全新的概念",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "我的思維方式是...",
        trueAnswer: "循序漸進，一步一步",
        falseAnswer: "跳躍式，看到整體聯繫",
        dimension: "S/N",
      ),
      MBTIQuestion(
        question: "面對複雜問題時，我會...",
        trueAnswer: "分解成具體的小問題",
        falseAnswer: "尋找創新的解決方案",
        dimension: "S/N",
      ),
    ];
  }
  
  List<MBTIQuestion> _getAdditionalTFQuestions() {
    return [
      MBTIQuestion(
        question: "評價他人時，我更看重...",
        trueAnswer: "能力和成就",
        falseAnswer: "品格和動機",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "在團隊中，我的角色通常是...",
        trueAnswer: "分析問題，提供解決方案",
        falseAnswer: "協調關係，維護團隊和諧",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "面對批評時，我會...",
        trueAnswer: "客觀分析批評的合理性",
        falseAnswer: "關注批評者的情感和動機",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "做重要決定時，我會...",
        trueAnswer: "列出利弊，理性分析",
        falseAnswer: "考慮對相關人員的影響",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "我更容易注意到...",
        trueAnswer: "邏輯漏洞和不一致之處",
        falseAnswer: "他人的情緒變化",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "在辯論中，我傾向於...",
        trueAnswer: "堅持邏輯和事實",
        falseAnswer: "尋求共識和理解",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "我的決策標準主要是...",
        trueAnswer: "效率和結果",
        falseAnswer: "公平和和諧",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "處理衝突時，我會...",
        trueAnswer: "直接指出問題所在",
        falseAnswer: "先安撫情緒，再解決問題",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "我更重視...",
        trueAnswer: "客觀標準和原則",
        falseAnswer: "個人價值觀和情感",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "給予反饋時，我會...",
        trueAnswer: "直接指出需要改進的地方",
        falseAnswer: "先肯定優點，再提出建議",
        dimension: "T/F",
      ),
      MBTIQuestion(
        question: "我的溝通風格是...",
        trueAnswer: "直接、簡潔、重點明確",
        falseAnswer: "溫和、考慮他人感受",
        dimension: "T/F",
      ),
    ];
  }
  
  List<MBTIQuestion> _getAdditionalJPQuestions() {
    return [
      MBTIQuestion(
        question: "我的工作桌通常是...",
        trueAnswer: "整潔有序，物品分類擺放",
        falseAnswer: "看起來雜亂，但我知道東西在哪",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "面對截止日期，我會...",
        trueAnswer: "提前完成，避免最後時刻的壓力",
        falseAnswer: "在壓力下工作效率更高",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我喜歡的生活節奏是...",
        trueAnswer: "有規律、可預測的",
        falseAnswer: "靈活、充滿變化的",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "做決定時，我傾向於...",
        trueAnswer: "快速決定，然後執行",
        falseAnswer: "保持選擇開放，直到必須決定",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我對規則的態度是...",
        trueAnswer: "規則提供必要的結構",
        falseAnswer: "規則可以靈活解釋",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "購物時，我通常...",
        trueAnswer: "列清單，按計劃購買",
        falseAnswer: "隨興瀏覽，看到喜歡的就買",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我的時間管理方式是...",
        trueAnswer: "嚴格按照日程安排",
        falseAnswer: "根據當時的心情和優先級",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "面對未完成的任務，我會...",
        trueAnswer: "感到不安，想要盡快完成",
        falseAnswer: "可以暫時擱置，處理其他事情",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我的決策風格是...",
        trueAnswer: "一旦決定就堅持執行",
        falseAnswer: "根據新信息隨時調整",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我對意外情況的反應是...",
        trueAnswer: "感到困擾，需要重新規劃",
        falseAnswer: "視為新機會，靈活應對",
        dimension: "J/P",
      ),
      MBTIQuestion(
        question: "我的工作方式是...",
        trueAnswer: "按部就班，完成一項再開始下一項",
        falseAnswer: "同時處理多項任務",
        dimension: "J/P",
      ),
    ];
  }

  String _calculateMBTIResult(Map<int, bool> answers, List<MBTIQuestion> questions) {
    Map<String, int> scores = {
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final answer = answers[i] ?? false;

      switch (question.dimension) {
        case 'E/I':
          if (answer) {
            scores['E'] = scores['E']! + 1;
          } else {
            scores['I'] = scores['I']! + 1;
          }
          break;
        case 'S/N':
          if (answer) {
            scores['S'] = scores['S']! + 1;
          } else {
            scores['N'] = scores['N']! + 1;
          }
          break;
        case 'T/F':
          if (answer) {
            scores['T'] = scores['T']! + 1;
          } else {
            scores['F'] = scores['F']! + 1;
          }
          break;
        case 'J/P':
          if (answer) {
            scores['J'] = scores['J']! + 1;
          } else {
            scores['P'] = scores['P']! + 1;
          }
          break;
      }
    }

    String result = '';
    result += scores['E']! > scores['I']! ? 'E' : 'I';
    result += scores['S']! > scores['N']! ? 'S' : 'N';
    result += scores['T']! > scores['F']! ? 'T' : 'F';
    result += scores['J']! > scores['P']! ? 'J' : 'P';

    return result;
  }

  Widget _buildResultPage(BuildContext context, WidgetRef ref, String result) {
    final description = mbtiDescriptions[result]!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 結果卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  description['color'] as Color,
                  (description['color'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: (description['color'] as Color).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description['title'] as String,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 描述卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '你的性格特點',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description['description'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '主要特質',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (description['traits'] as List<String>).map((trait) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: (description['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (description['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        trait,
                        style: TextStyle(
                          color: description['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _retakeTest(ref);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新測試'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _saveResult(context, result);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('保存結果'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: description['color'] as Color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回主頁'),
            ),
          ),
        ],
      ),
    );
  }

  void _retakeTest(WidgetRef ref) {
    ref.read(currentQuestionProvider.notifier).state = 0;
    ref.read(answersProvider.notifier).state = {};
    ref.read(testResultProvider.notifier).state = null;
  }

  void _saveResult(BuildContext context, String result) {
    // 返回結果給調用頁面
    Navigator.pop(context, result);
  }
} 