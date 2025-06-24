import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 增強版 MBTI 測試狀態管理
final enhancedCurrentQuestionProvider = StateProvider<int>((ref) => 0);
final enhancedAnswersProvider = StateProvider<Map<int, bool>>((ref) => {});
final enhancedTestResultProvider = StateProvider<String?>((ref) => null);
final testModeProvider = StateProvider<String>((ref) => 'simple'); // 'simple' or 'professional'

// MBTI 問題數據模型
class EnhancedMBTIQuestion {
  final String question;
  final String trueAnswer;
  final String falseAnswer;
  final String dimension;
  final String emoji;
  final String scenario;

  EnhancedMBTIQuestion({
    required this.question,
    required this.trueAnswer,
    required this.falseAnswer,
    required this.dimension,
    required this.emoji,
    required this.scenario,
  });
}

// 簡化版 MBTI 問題（針對 Gen Z）
final simpleMBTIQuestions = [
  EnhancedMBTIQuestion(
    question: "週末聚會時，你更喜歡...",
    trueAnswer: "和一大群朋友一起狂歡 🎉",
    falseAnswer: "和幾個好友安靜聊天 ☕",
    dimension: "E/I",
    emoji: "🎭",
    scenario: "想像你在一個朋友的生日派對上",
  ),
  EnhancedMBTIQuestion(
    question: "選擇約會地點時，你會...",
    trueAnswer: "去網紅打卡的新餐廳 📸",
    falseAnswer: "去熟悉舒適的老地方 🏠",
    dimension: "S/N",
    emoji: "💕",
    scenario: "你正在計劃一次浪漫約會",
  ),
  EnhancedMBTIQuestion(
    question: "朋友向你抱怨時，你會...",
    trueAnswer: "分析問題並給出解決方案 🧠",
    falseAnswer: "給予情感支持和安慰 🤗",
    dimension: "T/F",
    emoji: "👥",
    scenario: "你的好友遇到了感情問題",
  ),
  EnhancedMBTIQuestion(
    question: "規劃旅行時，你傾向於...",
    trueAnswer: "提前訂好所有行程 📋",
    falseAnswer: "保持彈性，隨興探索 🗺️",
    dimension: "J/P",
    emoji: "✈️",
    scenario: "你正在計劃一次夢想之旅",
  ),
  EnhancedMBTIQuestion(
    question: "在社交媒體上，你更喜歡...",
    trueAnswer: "分享生活動態和想法 📱",
    falseAnswer: "默默瀏覽，很少發文 👀",
    dimension: "E/I",
    emoji: "📲",
    scenario: "你剛經歷了美好的一天",
  ),
  EnhancedMBTIQuestion(
    question: "學習新技能時，你喜歡...",
    trueAnswer: "跟著教程一步步學習 📚",
    falseAnswer: "先了解原理再實踐 💡",
    dimension: "S/N",
    emoji: "🎯",
    scenario: "你想學習一項新的興趣愛好",
  ),
  EnhancedMBTIQuestion(
    question: "做重要決定時，你依靠...",
    trueAnswer: "理性分析利弊得失 ⚖️",
    falseAnswer: "內心感受和直覺 💖",
    dimension: "T/F",
    emoji: "🤔",
    scenario: "你面臨一個重要的人生選擇",
  ),
  EnhancedMBTIQuestion(
    question: "工作方式上，你更喜歡...",
    trueAnswer: "有明確的計劃和截止日期 ⏰",
    falseAnswer: "靈活的時間和創意空間 🎨",
    dimension: "J/P",
    emoji: "💼",
    scenario: "你正在開始一個新項目",
  ),
];

// 專業版 MBTI 問題（針對 30-40 歲群體）
final professionalMBTIQuestions = [
  EnhancedMBTIQuestion(
    question: "在職場會議中，你通常...",
    trueAnswer: "主動發言並分享想法",
    falseAnswer: "仔細聆聽後再表達觀點",
    dimension: "E/I",
    emoji: "💼",
    scenario: "重要的團隊會議正在進行",
  ),
  EnhancedMBTIQuestion(
    question: "制定人生規劃時，你更重視...",
    trueAnswer: "具體可行的短期目標",
    falseAnswer: "長遠的願景和可能性",
    dimension: "S/N",
    emoji: "🎯",
    scenario: "你正在規劃未來五年的發展",
  ),
  EnhancedMBTIQuestion(
    question: "在親密關係中，你更看重...",
    trueAnswer: "理性溝通和問題解決",
    falseAnswer: "情感連結和相互理解",
    dimension: "T/F",
    emoji: "💑",
    scenario: "你和伴侶討論重要的關係問題",
  ),
  EnhancedMBTIQuestion(
    question: "管理家庭事務時，你傾向於...",
    trueAnswer: "制定詳細計劃並嚴格執行",
    falseAnswer: "保持彈性，根據情況調整",
    dimension: "J/P",
    emoji: "🏡",
    scenario: "你正在安排家庭的日常生活",
  ),
  // 添加更多專業版問題...
];

// MBTI 類型的詳細描述（針對戀愛關係）
final romanticMBTIDescriptions = {
  'INTJ': {
    'title': '建築師 - 深度思考者',
    'subtitle': '理性而獨立的策略家',
    'description': '在愛情中，你是一個深度思考者，重視精神層面的連結。你不會輕易開始一段關係，但一旦投入就會非常專一。你欣賞能夠進行深度對話的伴侶，並且希望關係能夠不斷成長和發展。',
    'loveStyle': '深度連結型',
    'idealPartner': '能夠理解你的獨立性，同時願意進行深度交流的人',
    'relationshipTips': [
      '學會表達情感，不要只依賴行動',
      '給伴侶足夠的個人空間',
      '主動分享你的想法和計劃',
      '耐心培養關係的親密度'
    ],
    'compatibility': {
      'high': ['ENFP', 'ENTP', 'INFJ'],
      'medium': ['INTJ', 'INFP', 'ENTJ'],
      'low': ['ESFJ', 'ISFJ', 'ESFP']
    },
    'traits': ['獨立', '理性', '有遠見', '忠誠'],
    'color': Colors.purple,
    'gradient': [Colors.purple.shade400, Colors.purple.shade600],
  },
  'ENFP': {
    'title': '競選者 - 熱情探索者',
    'subtitle': '熱情而富有創造力的自由精神',
    'description': '在愛情中，你是一個充滿熱情的探索者，總是能為關係帶來新鮮感和活力。你重視情感的真實性，希望和伴侶一起成長和探索人生的各種可能性。你的愛是溫暖而包容的。',
    'loveStyle': '熱情探索型',
    'idealPartner': '能夠欣賞你的創意和熱情，同時給你成長空間的人',
    'relationshipTips': [
      '學會在關係中保持專注',
      '平衡理想與現實的期待',
      '給予伴侶足夠的關注',
      '培養深度的情感連結'
    ],
    'compatibility': {
      'high': ['INTJ', 'INFJ', 'ENFJ'],
      'medium': ['ENFP', 'ENTP', 'INFP'],
      'low': ['ISTJ', 'ISFJ', 'ESTJ']
    },
    'traits': ['熱情', '創意', '樂觀', '靈活'],
    'color': Colors.orange,
    'gradient': [Colors.orange.shade400, Colors.orange.shade600],
  },
  // 添加其他 MBTI 類型的描述...
};

class EnhancedMBTITestPage extends ConsumerWidget {
  const EnhancedMBTITestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testMode = ref.watch(testModeProvider);
    final currentQuestion = ref.watch(enhancedCurrentQuestionProvider);
    final answers = ref.watch(enhancedAnswersProvider);
    final testResult = ref.watch(enhancedTestResultProvider);

    // 根據模式選擇問題集
    final questions = testMode == 'simple' ? simpleMBTIQuestions : professionalMBTIQuestions;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: testResult != null
          ? _buildResultPage(context, ref, testResult)
          : currentQuestion == -1
              ? _buildModeSelectionPage(context, ref)
              : _buildTestPage(context, ref, currentQuestion, answers, questions),
    );
  }

  Widget _buildModeSelectionPage(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 頂部導航
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'MBTI 性格測試',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // 平衡佈局
              ],
            ),

            const SizedBox(height: 40),

            // 標題
            const Text(
              '選擇測試模式',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              '選擇最適合你的測試方式，\n讓我們更好地了解你的性格',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            // 簡單模式卡片
            _buildModeCard(
              context,
              ref,
              title: '輕鬆模式 ✨',
              subtitle: '適合 Gen Z',
              description: '8 個有趣的情境問題\n輕鬆了解你的性格特質',
              duration: '約 3 分鐘',
              color: Colors.pink,
              mode: 'simple',
              icon: '🎯',
            ),

            const SizedBox(height: 24),

            // 專業模式卡片
            _buildModeCard(
              context,
              ref,
              title: '深度模式 🧠',
              subtitle: '適合成熟人士',
              description: '16 個深入的性格分析問題\n全面了解你的內在特質',
              duration: '約 6 分鐘',
              color: Colors.indigo,
              mode: 'professional',
              icon: '🎓',
            ),

            const Spacer(),

            // 底部說明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '測試結果將用於智能配對，幫助你找到更合適的伴侶',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required String description,
    required String duration,
    required Color color,
    required String mode,
    required String icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            ref.read(testModeProvider.notifier).state = mode;
            ref.read(enhancedCurrentQuestionProvider.notifier).state = 0;
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestPage(
    BuildContext context,
    WidgetRef ref,
    int currentQuestion,
    Map<int, bool> answers,
    List<EnhancedMBTIQuestion> questions,
  ) {
    if (currentQuestion >= questions.length) {
      // 計算結果
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = _calculateMBTIResult(answers, questions);
        ref.read(enhancedTestResultProvider.notifier).state = result;
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('正在分析你的性格特質...'),
          ],
        ),
      );
    }

    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return SafeArea(
      child: Column(
        children: [
          // 頂部進度區域
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (currentQuestion > 0) {
                          ref.read(enhancedCurrentQuestionProvider.notifier).state = currentQuestion - 1;
                        } else {
                          ref.read(enhancedCurrentQuestionProvider.notifier).state = -1;
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '問題 ${currentQuestion + 1}/${questions.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // 平衡佈局
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 情境描述
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          question.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.scenario,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 問題卡片
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 選項按鈕
                  _buildEnhancedOptionButton(
                    context,
                    ref,
                    question.trueAnswer,
                    true,
                    currentQuestion,
                    Colors.pink.shade400,
                    questions,
                  ),

                  const SizedBox(height: 20),

                  _buildEnhancedOptionButton(
                    context,
                    ref,
                    question.falseAnswer,
                    false,
                    currentQuestion,
                    Colors.indigo.shade400,
                    questions,
                  ),

                  const Spacer(),

                  // 底部提示
                  Text(
                    '選擇最符合你真實想法的選項',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOptionButton(
    BuildContext context,
    WidgetRef ref,
    String text,
    bool value,
    int questionIndex,
    Color color,
    List<EnhancedMBTIQuestion> questions,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _answerQuestion(ref, questionIndex, value, questions),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _answerQuestion(WidgetRef ref, int questionIndex, bool answer, List<EnhancedMBTIQuestion> questions) {
    final answers = ref.read(enhancedAnswersProvider);
    ref.read(enhancedAnswersProvider.notifier).state = {
      ...answers,
      questionIndex: answer,
    };
    
    ref.read(enhancedCurrentQuestionProvider.notifier).state = questionIndex + 1;
  }

  String _calculateMBTIResult(Map<int, bool> answers, List<EnhancedMBTIQuestion> questions) {
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
    final description = romanticMBTIDescriptions[result] ?? romanticMBTIDescriptions['INTJ']!;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 頂部導航
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    '測試結果',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // 分享功能
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 結果卡片
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: description['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (description['color'] as Color).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description['title'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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
            ),

            const SizedBox(height: 30),

            // 愛情風格
            _buildInfoCard(
              '你的愛情風格',
              description['loveStyle'] as String,
              Icons.favorite,
              Colors.pink,
            ),

            const SizedBox(height: 16),

            // 性格描述
            _buildInfoCard(
              '性格特質',
              description['description'] as String,
              Icons.psychology,
              Colors.purple,
            ),

            const SizedBox(height: 16),

            // 理想伴侶
            _buildInfoCard(
              '理想伴侶',
              description['idealPartner'] as String,
              Icons.people,
              Colors.blue,
            ),

            const SizedBox(height: 30),

            // 關係建議
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
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '關係建議',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(description['relationshipTips'] as List<String>).map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 底部按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 重新測試
                      ref.read(enhancedCurrentQuestionProvider.notifier).state = -1;
                      ref.read(enhancedAnswersProvider.notifier).state = {};
                      ref.read(enhancedTestResultProvider.notifier).state = null;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('重新測試'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 導航到配對頁面
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('開始配對'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
} 