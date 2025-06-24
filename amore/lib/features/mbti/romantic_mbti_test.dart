import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 戀愛MBTI測試狀態管理
final romanticMBTICurrentQuestionProvider = StateProvider<int>((ref) => 0);
final romanticMBTIAnswersProvider = StateProvider<Map<int, int>>((ref) => {});
final romanticMBTIResultProvider = StateProvider<RomanticMBTIResult?>((ref) => null);
final romanticMBTIProgressProvider = StateProvider<double>((ref) => 0.0);

// 戀愛MBTI結果模型
class RomanticMBTIResult {
  final String type;
  final String loveStyle;
  final String description;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> idealPartnerTraits;
  final List<String> datingTips;
  final Color themeColor;
  final String emoji;

  RomanticMBTIResult({
    required this.type,
    required this.loveStyle,
    required this.description,
    required this.strengths,
    required this.challenges,
    required this.idealPartnerTraits,
    required this.datingTips,
    required this.themeColor,
    required this.emoji,
  });
}

// 戀愛MBTI問題模型
class RomanticMBTIQuestion {
  final String question;
  final List<String> options;
  final String dimension; // E/I, S/N, T/F, J/P
  final List<int> scores; // 對應每個選項的分數

  RomanticMBTIQuestion({
    required this.question,
    required this.options,
    required this.dimension,
    required this.scores,
  });
}

// 戀愛導向的MBTI問題庫
final romanticMBTIQuestions = [
  // 外向(E) vs 內向(I) - 戀愛社交篇
  RomanticMBTIQuestion(
    question: "在約會時，你更傾向於...",
    options: [
      "去熱鬧的地方，如音樂會、派對或人多的餐廳",
      "選擇安靜私密的環境，如小咖啡廳或在家看電影",
      "根據心情決定，有時喜歡熱鬧有時喜歡安靜",
      "先了解對方的喜好再決定約會地點"
    ],
    dimension: "E/I",
    scores: [3, -3, 0, 1],
  ),

  RomanticMBTIQuestion(
    question: "當你喜歡上某人時，你會...",
    options: [
      "主動表達興趣，直接告訴對方或朋友",
      "默默觀察，等待合適的時機或對方先表示",
      "通過行動暗示，但不會直接說出來",
      "先確定對方的感受再決定是否表白"
    ],
    dimension: "E/I",
    scores: [3, -3, -1, 0],
  ),

  RomanticMBTIQuestion(
    question: "在戀愛關係中，你如何處理衝突？",
    options: [
      "立即討論問題，希望快速解決",
      "需要時間冷靜思考，之後再談",
      "嘗試避免衝突，希望問題自然解決",
      "分析問題根源，制定解決方案"
    ],
    dimension: "E/I",
    scores: [2, -2, -1, 1],
  ),

  RomanticMBTIQuestion(
    question: "你理想的週末約會是...",
    options: [
      "和朋友們一起聚會，介紹伴侶給大家認識",
      "兩人獨處，深入交流彼此的想法和感受",
      "參加有趣的活動，如展覽、工作坊或戶外運動",
      "在家一起做喜歡的事，如烹飪、看書或玩遊戲"
    ],
    dimension: "E/I",
    scores: [3, -2, 1, -1],
  ),

  // 感覺(S) vs 直覺(N) - 戀愛認知篇
  RomanticMBTIQuestion(
    question: "你被什麼樣的人吸引？",
    options: [
      "實際可靠，有穩定工作和明確人生規劃的人",
      "有創意和想像力，充滿夢想和可能性的人",
      "溫暖體貼，關注細節和日常生活的人",
      "聰明有趣，能帶來新觀點和啟發的人"
    ],
    dimension: "S/N",
    scores: [2, -2, 3, -3],
  ),

  RomanticMBTIQuestion(
    question: "在選擇伴侶時，你更重視...",
    options: [
      "對方的實際條件，如工作、收入、家庭背景",
      "彼此的精神契合度和共同的人生理想",
      "日常相處的舒適度和生活習慣的匹配",
      "對方的潛力和未來發展的可能性"
    ],
    dimension: "S/N",
    scores: [3, -2, 2, -3],
  ),

  RomanticMBTIQuestion(
    question: "你如何表達愛意？",
    options: [
      "通過實際行動，如準備禮物、做家務、照顧對方",
      "寫情書、詩歌或創作，表達內心深層的感受",
      "記住對方喜歡的小事，在細節上體現關愛",
      "分享夢想和未來計劃，一起想像美好的可能"
    ],
    dimension: "S/N",
    scores: [2, -2, 3, -3],
  ),

  RomanticMBTIQuestion(
    question: "你對戀愛的期待是...",
    options: [
      "穩定長久的關係，能一起建立家庭和未來",
      "充滿激情和創意的愛情，不斷探索新的可能",
      "溫馨舒適的日常，彼此陪伴度過平凡時光",
      "靈魂伴侶的連結，在精神層面完全理解彼此"
    ],
    dimension: "S/N",
    scores: [2, -2, 3, -3],
  ),

  // 思考(T) vs 情感(F) - 戀愛決策篇
  RomanticMBTIQuestion(
    question: "當面臨感情問題時，你會...",
    options: [
      "理性分析利弊，考慮最實際的解決方案",
      "優先考慮所有人的感受，尋求和諧的解決方式",
      "依據邏輯和事實做出客觀判斷",
      "跟隨內心的感受和價值觀做決定"
    ],
    dimension: "T/F",
    scores: [3, -2, 2, -3],
  ),

  RomanticMBTIQuestion(
    question: "你希望伴侶如何支持你？",
    options: [
      "提供客觀的建議和實用的解決方案",
      "給予情感支持和理解，陪伴度過難關",
      "幫助分析問題，一起制定行動計劃",
      "無條件的愛和接納，相信你的選擇"
    ],
    dimension: "T/F",
    scores: [2, -2, 3, -3],
  ),

  RomanticMBTIQuestion(
    question: "在戀愛中，你最看重...",
    options: [
      "彼此的能力匹配和共同成長",
      "情感連結的深度和相互理解",
      "關係的效率和實際益處",
      "愛的純粹和情感的真誠"
    ],
    dimension: "T/F",
    scores: [2, -2, 3, -3],
  ),

  RomanticMBTIQuestion(
    question: "你如何處理伴侶的情緒？",
    options: [
      "嘗試找出問題的根源並提供解決建議",
      "耐心傾聽，提供情感支持和安慰",
      "保持冷靜，幫助對方理性看待問題",
      "感同身受，用愛和溫暖包圍對方"
    ],
    dimension: "T/F",
    scores: [2, -2, 3, -3],
  ),

  // 判斷(J) vs 知覺(P) - 戀愛生活篇
  RomanticMBTIQuestion(
    question: "你理想的戀愛節奏是...",
    options: [
      "有明確的關係發展階段和時間規劃",
      "順其自然，讓關係自由發展",
      "穩定有序，按部就班地深入了解",
      "保持彈性，根據感覺調整關係進度"
    ],
    dimension: "J/P",
    scores: [3, -2, 2, -3],
  ),

  RomanticMBTIQuestion(
    question: "對於未來的規劃，你希望...",
    options: [
      "和伴侶一起制定詳細的人生計劃",
      "保持開放，讓未來充滿驚喜和可能性",
      "有基本的方向，但允許適度的調整",
      "享受當下，不過度擔心未來的事"
    ],
    dimension: "J/P",
    scores: [3, -3, 1, -2],
  ),

  RomanticMBTIQuestion(
    question: "你喜歡什麼樣的約會方式？",
    options: [
      "提前計劃好的精心安排，每個細節都考慮到",
      "隨興的探索，看到什麼有趣就去嘗試",
      "有基本安排但留有彈性空間",
      "完全即興，跟著感覺走"
    ],
    dimension: "J/P",
    scores: [3, -2, 1, -3],
  ),

  RomanticMBTIQuestion(
    question: "在戀愛關係中，你對承諾的態度是...",
    options: [
      "喜歡明確的承諾和穩定的關係狀態",
      "認為承諾會限制關係的自然發展",
      "重視承諾，但也需要一定的自由空間",
      "更願意用行動證明愛，而非言語承諾"
    ],
    dimension: "J/P",
    scores: [3, -3, 1, -1],
  ),
];

// 戀愛MBTI類型描述
final romanticMBTIProfiles = {
  'INTJ': RomanticMBTIResult(
    type: 'INTJ',
    loveStyle: '深謀遠慮的戀人',
    description: '你在愛情中是一個深思熟慮的策略家。你尋求深層的精神連結，重視伴侶的智慧和獨立性。你的愛情是持久而專一的，一旦確定關係就會全心投入。',
    strengths: ['忠誠專一', '深度思考', '長遠規劃', '獨立自主'],
    challenges: ['表達情感', '過度理性', '完美主義', '社交需求'],
    idealPartnerTraits: ['智慧獨立', '理解支持', '共同目標', '給予空間'],
    datingTips: ['多表達內心感受', '嘗試浪漫驚喜', '耐心建立信任', '平衡工作與愛情'],
    themeColor: Colors.deepPurple,
    emoji: '🧠💜',
  ),
  
  'INTP': RomanticMBTIResult(
    type: 'INTP',
    loveStyle: '理性探索的戀人',
    description: '你以好奇和開放的心態對待愛情。你重視智力上的刺激和精神層面的交流，需要一個能理解你複雜思維的伴侶。',
    strengths: ['開放包容', '智慧幽默', '創新思維', '尊重獨立'],
    challenges: ['情感表達', '日常關懷', '承諾恐懼', '實際行動'],
    idealPartnerTraits: ['智慧有趣', '獨立思考', '耐心理解', '共同探索'],
    datingTips: ['學習表達關愛', '關注伴侶需求', '建立日常習慣', '勇於承諾'],
    themeColor: Colors.teal,
    emoji: '🤔💙',
  ),

  'ENTJ': RomanticMBTIResult(
    type: 'ENTJ',
    loveStyle: '領導型的戀人',
    description: '你在愛情中展現出強烈的領導力和決心。你尋求一個能與你並肩作戰的伴侶，共同創造美好的未來。',
    strengths: ['目標明確', '積極主動', '保護欲強', '未來導向'],
    challenges: ['控制欲強', '工作優先', '情感忽視', '過度理性'],
    idealPartnerTraits: ['獨立能幹', '支持理解', '共同抱負', '情感智慧'],
    datingTips: ['平衡工作愛情', '傾聽伴侶想法', '表達溫柔一面', '共同制定目標'],
    themeColor: Colors.red,
    emoji: '👑❤️',
  ),

  'ENTP': RomanticMBTIResult(
    type: 'ENTP',
    loveStyle: '創新冒險的戀人',
    description: '你為愛情帶來無限的創意和活力。你喜歡探索新的可能性，需要一個能跟上你思維節奏的伴侶。',
    strengths: ['創意無限', '熱情活力', '適應性強', '樂觀開朗'],
    challenges: ['注意力分散', '承諾困難', '情緒波動', '缺乏耐心'],
    idealPartnerTraits: ['開放包容', '智慧幽默', '冒險精神', '情感穩定'],
    datingTips: ['專注當下關係', '學習深度交流', '保持新鮮感', '承諾的重要性'],
    themeColor: Colors.orange,
    emoji: '🚀💛',
  ),

  'INFJ': RomanticMBTIResult(
    type: 'INFJ',
    loveStyle: '理想主義的戀人',
    description: '你尋求靈魂層面的深度連結。你的愛情充滿理想色彩，渴望找到真正理解你內心世界的靈魂伴侶。',
    strengths: ['深度理解', '忠誠專一', '直覺敏銳', '關懷體貼'],
    challenges: ['過度理想化', '情感負擔', '社交疲勞', '完美主義'],
    idealPartnerTraits: ['真誠理解', '情感深度', '共同價值觀', '給予空間'],
    datingTips: ['接受不完美', '表達真實需求', '平衡付出接受', '保持現實感'],
    themeColor: Colors.indigo,
    emoji: '🌟💜',
  ),

  'INFP': RomanticMBTIResult(
    type: 'INFP',
    loveStyle: '浪漫詩意的戀人',
    description: '你的愛情充滿詩意和浪漫。你重視真實的情感連結，尋求一個能欣賞你獨特性格的伴侶。',
    strengths: ['真誠浪漫', '創意表達', '深度同理', '價值觀堅定'],
    challenges: ['過度敏感', '衝突迴避', '情緒化', '現實逃避'],
    idealPartnerTraits: ['溫柔理解', '欣賞獨特', '情感支持', '共同夢想'],
    datingTips: ['勇敢表達想法', '面對現實問題', '學習溝通技巧', '建立安全感'],
    themeColor: Colors.pink,
    emoji: '🌸💕',
  ),

  'ENFJ': RomanticMBTIResult(
    type: 'ENFJ',
    loveStyle: '奉獻型的戀人',
    description: '你是天生的關係建造者，總是將伴侶的需求放在首位。你的愛情充滿溫暖和奉獻精神。',
    strengths: ['關懷體貼', '溝通能力強', '激勵他人', '情感豐富'],
    challenges: ['過度付出', '忽視自己', '控制傾向', '情感負擔'],
    idealPartnerTraits: ['懂得感恩', '獨立自主', '情感回應', '支持成長'],
    datingTips: ['關注自己需求', '設定健康界限', '接受伴侶獨立', '平衡付出接受'],
    themeColor: Colors.green,
    emoji: '🤗💚',
  ),

  'ENFP': RomanticMBTIResult(
    type: 'ENFP',
    loveStyle: '熱情自由的戀人',
    description: '你為愛情帶來無限的熱情和可能性。你重視情感的真實性，尋求一個能與你共同成長的伴侶。',
    strengths: ['熱情洋溢', '創意豐富', '樂觀積極', '適應性強'],
    challenges: ['注意力分散', '情緒波動', '承諾恐懼', '現實逃避'],
    idealPartnerTraits: ['理解包容', '穩定支持', '共同冒險', '情感深度'],
    datingTips: ['學習專注投入', '面對現實挑戰', '建立穩定習慣', '深化情感連結'],
    themeColor: Colors.amber,
    emoji: '🌈💛',
  ),

  'ISTJ': RomanticMBTIResult(
    type: 'ISTJ',
    loveStyle: '穩定可靠的戀人',
    description: '你是愛情中的堅實支柱，提供安全感和穩定性。你重視傳統價值觀，尋求長久穩定的關係。',
    strengths: ['忠誠可靠', '責任感強', '實際務實', '傳統價值'],
    challenges: ['表達困難', '變化適應', '浪漫缺乏', '情感保守'],
    idealPartnerTraits: ['理解支持', '欣賞穩定', '共同價值觀', '耐心溝通'],
    datingTips: ['學習浪漫表達', '嘗試新體驗', '開放情感交流', '創造驚喜'],
    themeColor: Colors.brown,
    emoji: '🏠💙',
  ),

  'ISFJ': RomanticMBTIResult(
    type: 'ISFJ',
    loveStyle: '溫暖守護的戀人',
    description: '你是愛情中的溫暖守護者，總是細心照顧伴侶的需求。你的愛情充滿溫柔和奉獻。',
    strengths: ['溫暖體貼', '細心照顧', '忠誠專一', '和諧維護'],
    challenges: ['過度犧牲', '衝突迴避', '自我忽視', '變化困難'],
    idealPartnerTraits: ['懂得珍惜', '溫柔回應', '保護關愛', '穩定可靠'],
    datingTips: ['表達自己需求', '學習說不', '接受伴侶獨立', '建立自信'],
    themeColor: Colors.lightBlue,
    emoji: '🤱💙',
  ),

  'ESTJ': RomanticMBTIResult(
    type: 'ESTJ',
    loveStyle: '實幹型的戀人',
    description: '你在愛情中展現出強烈的責任感和行動力。你重視實際的承諾，尋求一個能共同建設未來的伴侶。',
    strengths: ['責任感強', '行動力強', '目標明確', '保護欲強'],
    challenges: ['情感表達', '控制傾向', '工作優先', '固執己見'],
    idealPartnerTraits: ['支持理解', '共同目標', '欣賞努力', '情感智慧'],
    datingTips: ['學習情感表達', '傾聽伴侶想法', '平衡工作愛情', '展現溫柔'],
    themeColor: Colors.blue,
    emoji: '💼💙',
  ),

  'ESFJ': RomanticMBTIResult(
    type: 'ESFJ',
    loveStyle: '和諧關愛的戀人',
    description: '你是愛情中的和諧創造者，總是努力維護關係的美好。你的愛情充滿關懷和溫暖。',
    strengths: ['關懷體貼', '和諧維護', '社交能力強', '傳統價值'],
    challenges: ['過度取悅', '衝突迴避', '自我犧牲', '批評敏感'],
    idealPartnerTraits: ['懂得感恩', '溫柔回應', '穩定可靠', '共同價值觀'],
    datingTips: ['關注自己需求', '學習健康衝突', '建立界限', '接受不完美'],
    themeColor: Colors.cyan,
    emoji: '🤝💚',
  ),

  'ISTP': RomanticMBTIResult(
    type: 'ISTP',
    loveStyle: '自由獨立的戀人',
    description: '你在愛情中保持著獨特的自由精神。你重視個人空間，尋求一個能理解你獨立性格的伴侶。',
    strengths: ['獨立自主', '實際務實', '冷靜理性', '適應性強'],
    challenges: ['情感表達', '承諾恐懼', '距離感', '溝通困難'],
    idealPartnerTraits: ['理解獨立', '不過度依賴', '共同興趣', '給予空間'],
    datingTips: ['學習情感表達', '主動分享想法', '建立親密感', '承諾的價值'],
    themeColor: Colors.grey,
    emoji: '🔧💙',
  ),

  'ISFP': RomanticMBTIResult(
    type: 'ISFP',
    loveStyle: '藝術感性的戀人',
    description: '你的愛情充滿藝術氣息和感性色彩。你重視真實的情感體驗，尋求一個能欣賞你內在美的伴侶。',
    strengths: ['真誠感性', '藝術氣質', '溫柔體貼', '價值觀堅定'],
    challenges: ['過度敏感', '衝突迴避', '自我懷疑', '表達困難'],
    idealPartnerTraits: ['溫柔理解', '欣賞獨特', '情感支持', '藝術共鳴'],
    datingTips: ['勇敢表達感受', '建立自信', '面對衝突', '分享內心世界'],
    themeColor: Colors.lightGreen,
    emoji: '🎨💚',
  ),

  'ESTP': RomanticMBTIResult(
    type: 'ESTP',
    loveStyle: '活力冒險的戀人',
    description: '你為愛情帶來無限的活力和冒險精神。你享受當下的快樂，尋求一個能與你共同探索世界的伴侶。',
    strengths: ['活力充沛', '樂觀開朗', '適應性強', '行動力強'],
    challenges: ['承諾困難', '深度不足', '衝動行為', '未來規劃'],
    idealPartnerTraits: ['冒險精神', '樂觀積極', '理解包容', '穩定支持'],
    datingTips: ['學習深度交流', '考慮長遠關係', '控制衝動', '建立穩定感'],
    themeColor: Colors.deepOrange,
    emoji: '🏃‍♂️🧡',
  ),

  'ESFP': RomanticMBTIResult(
    type: 'ESFP',
    loveStyle: '陽光溫暖的戀人',
    description: '你是愛情中的陽光，總是為關係帶來歡樂和溫暖。你重視情感的真實表達，尋求一個能與你分享快樂的伴侶。',
    strengths: ['熱情溫暖', '樂觀積極', '情感豐富', '社交能力強'],
    challenges: ['情緒化', '計劃困難', '衝突迴避', '注意力分散'],
    idealPartnerTraits: ['穩定支持', '欣賞熱情', '情感回應', '共同快樂'],
    datingTips: ['學習情緒管理', '制定未來計劃', '面對現實問題', '深化關係'],
    themeColor: Colors.deepPurple,
    emoji: '☀️💜',
  ),
};

class RomanticMBTITestPage extends ConsumerWidget {
  final bool isRegistration;
  final VoidCallback? onComplete;

  const RomanticMBTITestPage({
    super.key,
    this.isRegistration = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuestion = ref.watch(romanticMBTICurrentQuestionProvider);
    final answers = ref.watch(romanticMBTIAnswersProvider);
    final result = ref.watch(romanticMBTIResultProvider);
    final progress = ref.watch(romanticMBTIProgressProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isRegistration ? '戀愛性格測試' : 'MBTI 戀愛測試'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: result == null ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentQuestion > 0) {
              ref.read(romanticMBTICurrentQuestionProvider.notifier).state = currentQuestion - 1;
              ref.read(romanticMBTIProgressProvider.notifier).state = currentQuestion / romanticMBTIQuestions.length;
            } else {
              Navigator.pop(context);
            }
          },
        ) : null,
      ),
      body: result != null
          ? _buildResultPage(context, ref, result)
          : _buildTestPage(context, ref, currentQuestion, answers, progress),
    );
  }

  Widget _buildTestPage(BuildContext context, WidgetRef ref, int currentQuestion, Map<int, int> answers, double progress) {
    if (currentQuestion >= romanticMBTIQuestions.length) {
      // 計算結果
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = _calculateRomanticMBTIResult(answers);
        ref.read(romanticMBTIResultProvider.notifier).state = result;
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('正在分析您的戀愛性格...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    final question = romanticMBTIQuestions[currentQuestion];

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
                    '問題 ${currentQuestion + 1}/${romanticMBTIQuestions.length}',
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 40,
                        color: Colors.pink.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 選項按鈕
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildOptionButton(
                      context,
                      ref,
                      option,
                      index,
                      currentQuestion,
                    ),
                  );
                }),

                const SizedBox(height: 20),
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
    int optionIndex,
    int questionIndex,
  ) {
    final colors = [
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
    ];
    
    final color = colors[optionIndex % colors.length];

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
        onPressed: () => _answerQuestion(ref, questionIndex, optionIndex),
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

  void _answerQuestion(WidgetRef ref, int questionIndex, int optionIndex) {
    final answers = ref.read(romanticMBTIAnswersProvider);
    ref.read(romanticMBTIAnswersProvider.notifier).state = {
      ...answers,
      questionIndex: optionIndex,
    };
    
    final nextQuestion = questionIndex + 1;
    ref.read(romanticMBTICurrentQuestionProvider.notifier).state = nextQuestion;
    ref.read(romanticMBTIProgressProvider.notifier).state = nextQuestion / romanticMBTIQuestions.length;
  }

  RomanticMBTIResult _calculateRomanticMBTIResult(Map<int, int> answers) {
    Map<String, int> scores = {
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    for (int i = 0; i < romanticMBTIQuestions.length; i++) {
      final question = romanticMBTIQuestions[i];
      final answerIndex = answers[i] ?? 0;
      final score = question.scores[answerIndex];

      switch (question.dimension) {
        case 'E/I':
          if (score > 0) {
            scores['E'] = scores['E']! + score;
          } else {
            scores['I'] = scores['I']! + score.abs();
          }
          break;
        case 'S/N':
          if (score > 0) {
            scores['S'] = scores['S']! + score;
          } else {
            scores['N'] = scores['N']! + score.abs();
          }
          break;
        case 'T/F':
          if (score > 0) {
            scores['T'] = scores['T']! + score;
          } else {
            scores['F'] = scores['F']! + score.abs();
          }
          break;
        case 'J/P':
          if (score > 0) {
            scores['J'] = scores['J']! + score;
          } else {
            scores['P'] = scores['P']! + score.abs();
          }
          break;
      }
    }

    String result = '';
    result += scores['E']! > scores['I']! ? 'E' : 'I';
    result += scores['S']! > scores['N']! ? 'S' : 'N';
    result += scores['T']! > scores['F']! ? 'T' : 'F';
    result += scores['J']! > scores['P']! ? 'J' : 'P';

    return romanticMBTIProfiles[result]!;
  }

  Widget _buildResultPage(BuildContext context, WidgetRef ref, RomanticMBTIResult result) {
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
                  result.themeColor,
                  result.themeColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: result.themeColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  result.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 20),
                Text(
                  result.type,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.loveStyle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 描述卡片
          _buildInfoCard('💕 你的戀愛風格', result.description, result.themeColor),
          
          const SizedBox(height: 20),
          
          // 優勢卡片
          _buildListCard('✨ 戀愛優勢', result.strengths, Colors.green),
          
          const SizedBox(height: 20),
          
          // 挑戰卡片
          _buildListCard('⚠️ 需要注意', result.challenges, Colors.orange),
          
          const SizedBox(height: 20),
          
          // 理想伴侶卡片
          _buildListCard('💖 理想伴侶特質', result.idealPartnerTraits, Colors.pink),
          
          const SizedBox(height: 20),
          
          // 約會建議卡片
          _buildListCard('💡 戀愛建議', result.datingTips, Colors.blue),

          const SizedBox(height: 30),

          // 操作按鈕
          if (isRegistration) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('完成測試'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: result.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
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
                      backgroundColor: result.themeColor,
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
                child: const Text('返回'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Container(
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
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _retakeTest(WidgetRef ref) {
    ref.read(romanticMBTICurrentQuestionProvider.notifier).state = 0;
    ref.read(romanticMBTIAnswersProvider.notifier).state = {};
    ref.read(romanticMBTIResultProvider.notifier).state = null;
    ref.read(romanticMBTIProgressProvider.notifier).state = 0.0;
  }

  void _saveResult(BuildContext context, RomanticMBTIResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('戀愛性格測試結果 (${result.type}) 已保存！'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: '查看配對',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
} 