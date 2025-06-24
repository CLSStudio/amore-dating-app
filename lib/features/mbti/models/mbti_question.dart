class MBTIQuestion {
  final String id;
  final String question;
  final String category; // E/I, S/N, T/F, J/P
  final List<MBTIAnswer> answers;
  final String? imageUrl;
  final TestMode mode; // 新增：測試模式
  final int priority; // 新增：問題優先級 (1-5, 5最重要)

  const MBTIQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.answers,
    this.imageUrl,
    required this.mode,
    required this.priority,
  });

  factory MBTIQuestion.fromJson(Map<String, dynamic> json) {
    return MBTIQuestion(
      id: json['id'],
      question: json['question'],
      category: json['category'],
      answers: (json['answers'] as List)
          .map((answer) => MBTIAnswer.fromJson(answer))
          .toList(),
      imageUrl: json['imageUrl'],
      mode: TestMode.values.firstWhere(
        (e) => e.toString() == 'TestMode.${json['mode']}',
        orElse: () => TestMode.both,
      ),
      priority: json['priority'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'imageUrl': imageUrl,
      'mode': mode.toString().split('.').last,
      'priority': priority,
    };
  }
}

// 新增：測試模式枚舉
enum TestMode {
  simple,     // 簡單模式 (20題)
  professional, // 專業模式 (60題)
  both,       // 兩種模式都包含
}

class MBTIAnswer {
  final String id;
  final String text;
  final String type; // E, I, S, N, T, F, J, P
  final int weight; // 1-3, 權重

  const MBTIAnswer({
    required this.id,
    required this.text,
    required this.type,
    required this.weight,
  });

  factory MBTIAnswer.fromJson(Map<String, dynamic> json) {
    return MBTIAnswer(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'weight': weight,
    };
  }
}

class MBTIResult {
  final String userId;
  final String type; // ENFP, INTJ, etc.
  final Map<String, int> scores; // E:15, I:5, S:10, N:10, etc.
  final DateTime completedAt;
  final List<String> traits;
  final String description;
  final TestMode testMode; // 新增：記錄使用的測試模式
  final double confidence; // 新增：結果信心度 (0.0-1.0)

  const MBTIResult({
    required this.userId,
    required this.type,
    required this.scores,
    required this.completedAt,
    required this.traits,
    required this.description,
    required this.testMode,
    required this.confidence,
  });

  factory MBTIResult.fromJson(Map<String, dynamic> json) {
    return MBTIResult(
      userId: json['userId'],
      type: json['type'],
      scores: Map<String, int>.from(json['scores']),
      completedAt: DateTime.parse(json['completedAt']),
      traits: List<String>.from(json['traits']),
      description: json['description'],
      testMode: TestMode.values.firstWhere(
        (e) => e.toString() == 'TestMode.${json['testMode']}',
        orElse: () => TestMode.simple,
      ),
      confidence: json['confidence']?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'scores': scores,
      'completedAt': completedAt.toIso8601String(),
      'traits': traits,
      'description': description,
      'testMode': testMode.toString().split('.').last,
      'confidence': confidence,
    };
  }
} 