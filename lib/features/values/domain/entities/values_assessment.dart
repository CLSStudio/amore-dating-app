import 'package:json_annotation/json_annotation.dart';

part 'values_assessment.g.dart';

/// 價值觀評估實體
@JsonSerializable()
class ValuesAssessment {
  final String id;
  final String userId;
  final Map<ValueCategory, int> scores;
  final Map<String, String> answers;
  final DateTime completedAt;
  final DateTime createdAt;

  const ValuesAssessment({
    required this.id,
    required this.userId,
    required this.scores,
    required this.answers,
    required this.completedAt,
    required this.createdAt,
  });

  factory ValuesAssessment.fromJson(Map<String, dynamic> json) => 
      _$ValuesAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$ValuesAssessmentToJson(this);

  /// 獲取主要價值觀（分數最高的前3個）
  List<ValueCategory> get topValues {
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).map((e) => e.key).toList();
  }

  /// 獲取價值觀相容性評分（與另一個評估結果比較）
  double getCompatibilityScore(ValuesAssessment other) {
    double totalScore = 0;
    int comparisons = 0;

    for (final category in ValueCategory.values) {
      final myScore = scores[category] ?? 0;
      final otherScore = other.scores[category] ?? 0;
      
      // 計算相似度（分數差異越小，相容性越高）
      final difference = (myScore - otherScore).abs();
      final similarity = 1.0 - (difference / 100.0);
      totalScore += similarity;
      comparisons++;
    }

    return comparisons > 0 ? totalScore / comparisons : 0.0;
  }

  /// 創建副本
  ValuesAssessment copyWith({
    String? id,
    String? userId,
    Map<ValueCategory, int>? scores,
    Map<String, String>? answers,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ValuesAssessment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scores: scores ?? this.scores,
      answers: answers ?? this.answers,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 價值觀問題實體
@JsonSerializable()
class ValuesQuestion {
  final String id;
  final String question;
  final String description;
  final ValueCategory category;
  final List<ValuesOption> options;
  final int order;

  const ValuesQuestion({
    required this.id,
    required this.question,
    required this.description,
    required this.category,
    required this.options,
    required this.order,
  });

  factory ValuesQuestion.fromJson(Map<String, dynamic> json) => 
      _$ValuesQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ValuesQuestionToJson(this);
}

/// 價值觀選項
@JsonSerializable()
class ValuesOption {
  final String id;
  final String text;
  final int score;

  const ValuesOption({
    required this.id,
    required this.text,
    required this.score,
  });

  factory ValuesOption.fromJson(Map<String, dynamic> json) => 
      _$ValuesOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ValuesOptionToJson(this);
}

/// 價值觀類別
enum ValueCategory {
  @JsonValue('family')
  family, // 家庭
  
  @JsonValue('career')
  career, // 事業
  
  @JsonValue('adventure')
  adventure, // 冒險
  
  @JsonValue('stability')
  stability, // 穩定
  
  @JsonValue('creativity')
  creativity, // 創造力
  
  @JsonValue('spirituality')
  spirituality, // 精神信仰
  
  @JsonValue('health')
  health, // 健康
  
  @JsonValue('wealth')
  wealth, // 財富
  
  @JsonValue('freedom')
  freedom, // 自由
  
  @JsonValue('social_impact')
  socialImpact, // 社會影響
  
  @JsonValue('personal_growth')
  personalGrowth, // 個人成長
  
  @JsonValue('relationships')
  relationships, // 人際關係
}

/// 價值觀類別擴展
extension ValueCategoryExtension on ValueCategory {
  String get displayName {
    switch (this) {
      case ValueCategory.family:
        return '家庭';
      case ValueCategory.career:
        return '事業';
      case ValueCategory.adventure:
        return '冒險';
      case ValueCategory.stability:
        return '穩定';
      case ValueCategory.creativity:
        return '創造力';
      case ValueCategory.spirituality:
        return '精神信仰';
      case ValueCategory.health:
        return '健康';
      case ValueCategory.wealth:
        return '財富';
      case ValueCategory.freedom:
        return '自由';
      case ValueCategory.socialImpact:
        return '社會影響';
      case ValueCategory.personalGrowth:
        return '個人成長';
      case ValueCategory.relationships:
        return '人際關係';
    }
  }

  String get description {
    switch (this) {
      case ValueCategory.family:
        return '重視家庭關係、親情和家庭責任';
      case ValueCategory.career:
        return '追求職業成就、專業發展和工作成功';
      case ValueCategory.adventure:
        return '喜歡新體驗、挑戰和探索未知';
      case ValueCategory.stability:
        return '重視安全感、可預測性和穩定的生活';
      case ValueCategory.creativity:
        return '追求創新、藝術表達和原創性';
      case ValueCategory.spirituality:
        return '重視精神成長、信仰和內在平靜';
      case ValueCategory.health:
        return '關注身心健康、運動和健康生活方式';
      case ValueCategory.wealth:
        return '追求財務成功、物質豐富和經濟安全';
      case ValueCategory.freedom:
        return '重視獨立、自主和不受約束的生活';
      case ValueCategory.socialImpact:
        return '希望對社會產生正面影響、幫助他人';
      case ValueCategory.personalGrowth:
        return '追求自我提升、學習和個人發展';
      case ValueCategory.relationships:
        return '重視友誼、愛情和社交連結';
    }
  }

  String get icon {
    switch (this) {
      case ValueCategory.family:
        return '👨‍👩‍👧‍👦';
      case ValueCategory.career:
        return '💼';
      case ValueCategory.adventure:
        return '🗺️';
      case ValueCategory.stability:
        return '🏠';
      case ValueCategory.creativity:
        return '🎨';
      case ValueCategory.spirituality:
        return '🧘';
      case ValueCategory.health:
        return '💪';
      case ValueCategory.wealth:
        return '💰';
      case ValueCategory.freedom:
        return '🕊️';
      case ValueCategory.socialImpact:
        return '🌍';
      case ValueCategory.personalGrowth:
        return '📈';
      case ValueCategory.relationships:
        return '💕';
    }
  }
} 