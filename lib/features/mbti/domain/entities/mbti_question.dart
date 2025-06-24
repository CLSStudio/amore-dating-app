import 'package:json_annotation/json_annotation.dart';

part 'mbti_question.g.dart';

/// MBTI 問題實體
@JsonSerializable()
class MbtiQuestion {
  final String id;
  final String question;
  final List<MbtiOption> options;
  final MbtiDimension dimension;
  final int order;

  const MbtiQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.dimension,
    required this.order,
  });

  factory MbtiQuestion.fromJson(Map<String, dynamic> json) => _$MbtiQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$MbtiQuestionToJson(this);
}

/// MBTI 選項
@JsonSerializable()
class MbtiOption {
  final String id;
  final String text;
  final MbtiType type;
  final int score;

  const MbtiOption({
    required this.id,
    required this.text,
    required this.type,
    required this.score,
  });

  factory MbtiOption.fromJson(Map<String, dynamic> json) => _$MbtiOptionFromJson(json);
  Map<String, dynamic> toJson() => _$MbtiOptionToJson(this);
}

/// MBTI 維度
enum MbtiDimension {
  @JsonValue('EI')
  extraversionIntroversion, // 外向-內向
  
  @JsonValue('SN')
  sensingIntuition, // 感覺-直覺
  
  @JsonValue('TF')
  thinkingFeeling, // 思考-情感
  
  @JsonValue('JP')
  judgingPerceiving, // 判斷-知覺
}

/// MBTI 類型
enum MbtiType {
  // 外向-內向
  @JsonValue('E')
  extraversion, // 外向
  
  @JsonValue('I')
  introversion, // 內向
  
  // 感覺-直覺
  @JsonValue('S')
  sensing, // 感覺
  
  @JsonValue('N')
  intuition, // 直覺
  
  // 思考-情感
  @JsonValue('T')
  thinking, // 思考
  
  @JsonValue('F')
  feeling, // 情感
  
  // 判斷-知覺
  @JsonValue('J')
  judging, // 判斷
  
  @JsonValue('P')
  perceiving, // 知覺
}

/// MBTI 結果
@JsonSerializable()
class MbtiResult {
  final String type; // 例如: "ENFP"
  final Map<MbtiDimension, int> scores;
  final DateTime completedAt;
  final String userId;

  const MbtiResult({
    required this.type,
    required this.scores,
    required this.completedAt,
    required this.userId,
  });

  factory MbtiResult.fromJson(Map<String, dynamic> json) => _$MbtiResultFromJson(json);
  Map<String, dynamic> toJson() => _$MbtiResultToJson(this);

  /// 獲取維度偏好強度（百分比）
  double getDimensionStrength(MbtiDimension dimension) {
    final score = scores[dimension] ?? 0;
    return (score / 100.0).clamp(0.0, 1.0);
  }

  /// 獲取類型描述
  String get typeDescription {
    switch (type) {
      case 'ENFP':
        return '競選者 - 熱情、創造性和社交性強，總是能找到微笑的理由';
      case 'ENFJ':
        return '主人公 - 有魅力和鼓舞人心的領導者，能夠迷住聽眾';
      case 'ENTP':
        return '辯論家 - 聰明好奇的思想家，不能抗拒智力挑戰';
      case 'ENTJ':
        return '指揮官 - 大膽、富有想象力、意志強烈的領導者';
      case 'ESFP':
        return '娛樂家 - 自發性、精力充沛和熱情的人，生活永遠不會無聊';
      case 'ESFJ':
        return '執政官 - 非常關心他人感受的人，受歡迎且有責任心';
      case 'ESTP':
        return '企業家 - 聰明、精力充沛和善於感知的人，真正享受生活';
      case 'ESTJ':
        return '總經理 - 優秀的管理者，在管理事物或人員方面無與倫比';
      case 'INFP':
        return '調停者 - 詩意、善良和利他主義，總是渴望幫助好的事業';
      case 'INFJ':
        return '提倡者 - 創造性和洞察力強，鼓舞人心且不屈不撓的理想主義者';
      case 'INTP':
        return '邏輯學家 - 創新的發明家，對知識有著不可遏制的渴望';
      case 'INTJ':
        return '建築師 - 富有想象力和戰略性的思想家，一切皆在計劃之中';
      case 'ISFP':
        return '冒險家 - 靈活、迷人的藝術家，時刻準備探索新的可能性';
      case 'ISFJ':
        return '守護者 - 非常專注、溫暖的保護者，時刻準備保衛愛的人';
      case 'ISTP':
        return '鑑賞家 - 大膽而實際的實驗者，擅長使用各種工具';
      case 'ISTJ':
        return '物流師 - 實際和注重事實的人，可靠性不容懷疑';
      default:
        return '未知類型';
    }
  }

  /// 獲取相容性評分（與另一個 MBTI 類型）
  double getCompatibilityScore(String otherType) {
    // 這裡可以實現更複雜的相容性算法
    // 暫時使用簡單的匹配邏輯
    if (type == otherType) return 1.0;
    
    // 檢查互補性
    final complementaryPairs = {
      'ENFP': ['INTJ', 'INFJ'],
      'ENFJ': ['INTP', 'INFP'],
      'ENTP': ['INTJ', 'INFJ'],
      'ENTJ': ['INTP', 'INFP'],
      'ESFP': ['ISTJ', 'ISFJ'],
      'ESFJ': ['ISTP', 'ISFP'],
      'ESTP': ['ISTJ', 'ISFJ'],
      'ESTJ': ['ISTP', 'ISFP'],
      'INFP': ['ENTJ', 'ENFJ'],
      'INFJ': ['ENTP', 'ENFP'],
      'INTP': ['ENTJ', 'ENFJ'],
      'INTJ': ['ENTP', 'ENFP'],
      'ISFP': ['ESTJ', 'ESFJ'],
      'ISFJ': ['ESTP', 'ESFP'],
      'ISTP': ['ESTJ', 'ESFJ'],
      'ISTJ': ['ESTP', 'ESFP'],
    };
    
    final compatibleTypes = complementaryPairs[type] ?? [];
    if (compatibleTypes.contains(otherType)) {
      return 0.9;
    }
    
    // 檢查相似性
    int similarities = 0;
    for (int i = 0; i < 4; i++) {
      if (type[i] == otherType[i]) {
        similarities++;
      }
    }
    
    return similarities / 4.0;
  }
} 