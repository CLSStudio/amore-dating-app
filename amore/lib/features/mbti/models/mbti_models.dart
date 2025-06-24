import 'package:json_annotation/json_annotation.dart';

part 'mbti_models.g.dart';

@JsonSerializable()
class MBTIQuestion {
  final String id;
  final String question;
  final String category; // E/I, S/N, T/F, J/P
  final List<MBTIAnswer> answers;
  final int order;

  const MBTIQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.answers,
    required this.order,
  });

  factory MBTIQuestion.fromJson(Map<String, dynamic> json) => _$MBTIQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$MBTIQuestionToJson(this);
}

@JsonSerializable()
class MBTIAnswer {
  final String id;
  final String text;
  final String type; // E, I, S, N, T, F, J, P
  final int score;

  const MBTIAnswer({
    required this.id,
    required this.text,
    required this.type,
    required this.score,
  });

  factory MBTIAnswer.fromJson(Map<String, dynamic> json) => _$MBTIAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$MBTIAnswerToJson(this);
}

@JsonSerializable()
class MBTIResult {
  final String userId;
  final String type; // 例如: ENFP, INTJ 等
  final Map<String, int> scores; // E/I, S/N, T/F, J/P 的分數
  final Map<String, double> percentages; // 各維度的百分比
  final DateTime completedAt;
  final List<String> answeredQuestions;
  final MBTIPersonality personality;

  const MBTIResult({
    required this.userId,
    required this.type,
    required this.scores,
    required this.percentages,
    required this.completedAt,
    required this.answeredQuestions,
    required this.personality,
  });

  factory MBTIResult.fromJson(Map<String, dynamic> json) => _$MBTIResultFromJson(json);
  Map<String, dynamic> toJson() => _$MBTIResultToJson(this);

  // 計算 MBTI 類型
  static String calculateType(Map<String, int> scores) {
    final ei = scores['E']! > scores['I']! ? 'E' : 'I';
    final sn = scores['S']! > scores['N']! ? 'S' : 'N';
    final tf = scores['T']! > scores['F']! ? 'T' : 'F';
    final jp = scores['J']! > scores['P']! ? 'J' : 'P';
    return '$ei$sn$tf$jp';
  }

  // 計算百分比
  static Map<String, double> calculatePercentages(Map<String, int> scores) {
    return {
      'E': scores['E']! / (scores['E']! + scores['I']!) * 100,
      'I': scores['I']! / (scores['E']! + scores['I']!) * 100,
      'S': scores['S']! / (scores['S']! + scores['N']!) * 100,
      'N': scores['N']! / (scores['S']! + scores['N']!) * 100,
      'T': scores['T']! / (scores['T']! + scores['F']!) * 100,
      'F': scores['F']! / (scores['T']! + scores['F']!) * 100,
      'J': scores['J']! / (scores['J']! + scores['P']!) * 100,
      'P': scores['P']! / (scores['J']! + scores['P']!) * 100,
    };
  }
}

@JsonSerializable()
class MBTIPersonality {
  final String type;
  final String title;
  final String description;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> compatibleTypes;
  final List<String> challengingTypes;
  final String loveStyle;
  final String communicationStyle;
  final List<String> idealDateIdeas;

  const MBTIPersonality({
    required this.type,
    required this.title,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.compatibleTypes,
    required this.challengingTypes,
    required this.loveStyle,
    required this.communicationStyle,
    required this.idealDateIdeas,
  });

  factory MBTIPersonality.fromJson(Map<String, dynamic> json) => _$MBTIPersonalityFromJson(json);
  Map<String, dynamic> toJson() => _$MBTIPersonalityToJson(this);
}

@JsonSerializable()
class MBTITestSession {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, String> answers; // questionId -> answerId
  final Map<String, int> currentScores;
  final int currentQuestionIndex;
  final bool isCompleted;

  const MBTITestSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.answers = const {},
    this.currentScores = const {},
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
  });

  factory MBTITestSession.fromJson(Map<String, dynamic> json) => _$MBTITestSessionFromJson(json);
  Map<String, dynamic> toJson() => _$MBTITestSessionToJson(this);

  MBTITestSession copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, String>? answers,
    Map<String, int>? currentScores,
    int? currentQuestionIndex,
    bool? isCompleted,
  }) {
    return MBTITestSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? this.answers,
      currentScores: currentScores ?? this.currentScores,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// MBTI 兼容性計算
class MBTICompatibility {
  static const Map<String, List<String>> _compatibilityMatrix = {
    'ENFP': ['INTJ', 'INFJ', 'ENFJ', 'ENTP'],
    'ENFJ': ['INFP', 'ISFP', 'ENFP', 'INTJ'],
    'ENTP': ['INTJ', 'INFJ', 'ENFP', 'ENTJ'],
    'ENTJ': ['INTP', 'INFP', 'ENTP', 'INTJ'],
    'ESFP': ['ISFJ', 'ISTJ', 'ESFJ', 'ESTP'],
    'ESFJ': ['ISFP', 'ISTP', 'ESFP', 'ESTJ'],
    'ESTP': ['ISFJ', 'ISTJ', 'ESFJ', 'ESFP'],
    'ESTJ': ['ISFP', 'ISTP', 'ESFJ', 'ESTP'],
    'INFP': ['ENFJ', 'ENTJ', 'INFJ', 'ENFP'],
    'INFJ': ['ENFP', 'ENTP', 'INFP', 'ENFJ'],
    'INTP': ['ENTJ', 'ENFJ', 'INTJ', 'ENTP'],
    'INTJ': ['ENFP', 'ENTP', 'INFJ', 'ENTJ'],
    'ISFP': ['ENFJ', 'ESFJ', 'ESTJ', 'ISFJ'],
    'ISFJ': ['ESFP', 'ESTP', 'ISFP', 'ESFJ'],
    'ISTP': ['ESFJ', 'ESTJ', 'ISFJ', 'ESTP'],
    'ISTJ': ['ESFP', 'ESTP', 'ISFJ', 'ESTJ'],
  };

  static double calculateCompatibility(String type1, String type2) {
    final compatibleTypes = _compatibilityMatrix[type1] ?? [];
    
    if (compatibleTypes.contains(type2)) {
      final index = compatibleTypes.indexOf(type2);
      // 最高兼容性為 95%，依次遞減
      return 95.0 - (index * 10.0);
    }
    
    // 計算基於維度的兼容性
    return _calculateDimensionalCompatibility(type1, type2);
  }

  static double _calculateDimensionalCompatibility(String type1, String type2) {
    double compatibility = 50.0; // 基礎兼容性
    
    // E/I 維度
    if (type1[0] != type2[0]) compatibility += 15.0; // 互補
    
    // S/N 維度
    if (type1[1] == type2[1]) compatibility += 20.0; // 相同更好
    
    // T/F 維度
    if (type1[2] != type2[2]) compatibility += 10.0; // 互補
    
    // J/P 維度
    if (type1[3] != type2[3]) compatibility += 5.0; // 輕微互補
    
    return compatibility.clamp(0.0, 100.0);
  }

  static List<String> getCompatibilityReasons(String type1, String type2) {
    final reasons = <String>[];
    
    // E/I 分析
    if (type1[0] != type2[0]) {
      reasons.add('你們在外向/內向上互補，能平衡彼此的社交需求');
    } else {
      reasons.add('你們有相似的社交偏好，容易理解彼此');
    }
    
    // S/N 分析
    if (type1[1] == type2[1]) {
      reasons.add('你們有相同的信息處理方式，溝通更順暢');
    } else {
      reasons.add('你們在實用性和創意性上可以互相學習');
    }
    
    // T/F 分析
    if (type1[2] != type2[2]) {
      reasons.add('你們在邏輯和情感上互補，決策更全面');
    } else {
      reasons.add('你們有相似的決策方式，價值觀更一致');
    }
    
    // J/P 分析
    if (type1[3] != type2[3]) {
      reasons.add('你們在計劃性和靈活性上互補，生活更有趣');
    } else {
      reasons.add('你們有相似的生活節奏，相處更和諧');
    }
    
    return reasons;
  }
} 