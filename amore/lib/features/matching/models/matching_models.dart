import 'package:json_annotation/json_annotation.dart';
import '../../auth/models/user_model.dart';

part 'matching_models.g.dart';

/// 匹配建議
@JsonSerializable()
class MatchSuggestion {
  final String userId;
  final UserModel user;
  final MatchScore matchScore;
  final List<String> reasons;
  final DateTime createdAt;

  MatchSuggestion({
    required this.userId,
    required this.user,
    required this.matchScore,
    required this.reasons,
    required this.createdAt,
  });

  factory MatchSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MatchSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$MatchSuggestionToJson(this);
}

/// 匹配分數
@JsonSerializable()
class MatchScore {
  final double totalScore;
  final double mbtiCompatibility;
  final double interestSimilarity;
  final double lifestyleCompatibility;
  final double basicCompatibility;
  final double locationCompatibility;

  MatchScore({
    required this.totalScore,
    required this.mbtiCompatibility,
    required this.interestSimilarity,
    required this.lifestyleCompatibility,
    required this.basicCompatibility,
    required this.locationCompatibility,
  });

  factory MatchScore.fromJson(Map<String, dynamic> json) =>
      _$MatchScoreFromJson(json);

  Map<String, dynamic> toJson() => _$MatchScoreToJson(this);

  /// 獲取匹配等級
  MatchLevel get level {
    if (totalScore >= 0.8) return MatchLevel.excellent;
    if (totalScore >= 0.6) return MatchLevel.good;
    if (totalScore >= 0.4) return MatchLevel.fair;
    return MatchLevel.poor;
  }

  /// 獲取匹配等級描述
  String get levelDescription {
    switch (level) {
      case MatchLevel.excellent:
        return '極佳匹配';
      case MatchLevel.good:
        return '良好匹配';
      case MatchLevel.fair:
        return '一般匹配';
      case MatchLevel.poor:
        return '較低匹配';
    }
  }

  /// 獲取匹配百分比
  int get percentage => (totalScore * 100).round();
}

/// 匹配等級
enum MatchLevel {
  excellent,
  good,
  fair,
  poor,
}

/// 匹配統計
@JsonSerializable()
class MatchingStats {
  final int totalMatches;
  final int mutualMatches;
  final int likes;
  final int passes;
  final double successRate;

  MatchingStats({
    required this.totalMatches,
    required this.mutualMatches,
    required this.likes,
    required this.passes,
    required this.successRate,
  });

  factory MatchingStats.fromJson(Map<String, dynamic> json) =>
      _$MatchingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MatchingStatsToJson(this);

  /// 獲取成功率百分比
  int get successPercentage => (successRate * 100).round();
}

/// 匹配篩選條件
@JsonSerializable()
class MatchFilters {
  final int? minAge;
  final int? maxAge;
  final String? location;
  final List<String>? mbtiTypes;
  final List<String>? interests;
  final String? education;
  final String? occupation;
  final double? minHeight;
  final double? maxHeight;
  final int? maxDistance; // 公里

  MatchFilters({
    this.minAge,
    this.maxAge,
    this.location,
    this.mbtiTypes,
    this.interests,
    this.education,
    this.occupation,
    this.minHeight,
    this.maxHeight,
    this.maxDistance,
  });

  factory MatchFilters.fromJson(Map<String, dynamic> json) =>
      _$MatchFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$MatchFiltersToJson(this);

  /// 創建默認篩選條件
  factory MatchFilters.defaultFilters() {
    return MatchFilters(
      minAge: 18,
      maxAge: 50,
      maxDistance: 50,
    );
  }

  /// 複製並修改篩選條件
  MatchFilters copyWith({
    int? minAge,
    int? maxAge,
    String? location,
    List<String>? mbtiTypes,
    List<String>? interests,
    String? education,
    String? occupation,
    double? minHeight,
    double? maxHeight,
    int? maxDistance,
  }) {
    return MatchFilters(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      location: location ?? this.location,
      mbtiTypes: mbtiTypes ?? this.mbtiTypes,
      interests: interests ?? this.interests,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}

/// 匹配偏好設置
@JsonSerializable()
class MatchPreferences {
  final bool prioritizeMBTI;
  final bool prioritizeInterests;
  final bool prioritizeLocation;
  final bool prioritizeAge;
  final bool showOnlyMutualLikes;
  final bool enableSmartRecommendations;
  final int dailyMatchLimit;

  MatchPreferences({
    this.prioritizeMBTI = true,
    this.prioritizeInterests = true,
    this.prioritizeLocation = false,
    this.prioritizeAge = false,
    this.showOnlyMutualLikes = false,
    this.enableSmartRecommendations = true,
    this.dailyMatchLimit = 20,
  });

  factory MatchPreferences.fromJson(Map<String, dynamic> json) =>
      _$MatchPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$MatchPreferencesToJson(this);

  /// 複製並修改偏好設置
  MatchPreferences copyWith({
    bool? prioritizeMBTI,
    bool? prioritizeInterests,
    bool? prioritizeLocation,
    bool? prioritizeAge,
    bool? showOnlyMutualLikes,
    bool? enableSmartRecommendations,
    int? dailyMatchLimit,
  }) {
    return MatchPreferences(
      prioritizeMBTI: prioritizeMBTI ?? this.prioritizeMBTI,
      prioritizeInterests: prioritizeInterests ?? this.prioritizeInterests,
      prioritizeLocation: prioritizeLocation ?? this.prioritizeLocation,
      prioritizeAge: prioritizeAge ?? this.prioritizeAge,
      showOnlyMutualLikes: showOnlyMutualLikes ?? this.showOnlyMutualLikes,
      enableSmartRecommendations: enableSmartRecommendations ?? this.enableSmartRecommendations,
      dailyMatchLimit: dailyMatchLimit ?? this.dailyMatchLimit,
    );
  }
}

/// 匹配活動記錄
@JsonSerializable()
class MatchActivity {
  final String id;
  final String userId;
  final String targetUserId;
  final MatchActionType action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MatchActivity({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  factory MatchActivity.fromJson(Map<String, dynamic> json) =>
      _$MatchActivityFromJson(json);

  Map<String, dynamic> toJson() => _$MatchActivityToJson(this);
}

/// 匹配操作類型
enum MatchActionType {
  like,
  pass,
  superLike,
  undo,
  block,
  report,
}

/// 匹配洞察
@JsonSerializable()
class MatchInsights {
  final String userId;
  final DateTime generatedAt;
  final List<String> topCompatibleTypes;
  final List<String> popularInterests;
  final Map<String, double> successRateByType;
  final List<String> improvementSuggestions;
  final double profileCompleteness;
  final int weeklyViews;
  final int weeklyLikes;

  MatchInsights({
    required this.userId,
    required this.generatedAt,
    required this.topCompatibleTypes,
    required this.popularInterests,
    required this.successRateByType,
    required this.improvementSuggestions,
    required this.profileCompleteness,
    required this.weeklyViews,
    required this.weeklyLikes,
  });

  factory MatchInsights.fromJson(Map<String, dynamic> json) =>
      _$MatchInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$MatchInsightsToJson(this);
}

/// 匹配算法配置
@JsonSerializable()
class MatchingAlgorithmConfig {
  final double mbtiWeight;
  final double interestWeight;
  final double lifestyleWeight;
  final double basicWeight;
  final double locationWeight;
  final double minimumScore;
  final bool enableComplementaryMatching;
  final bool enableDiversityBoost;

  MatchingAlgorithmConfig({
    this.mbtiWeight = 0.4,
    this.interestWeight = 0.25,
    this.lifestyleWeight = 0.2,
    this.basicWeight = 0.1,
    this.locationWeight = 0.05,
    this.minimumScore = 0.3,
    this.enableComplementaryMatching = true,
    this.enableDiversityBoost = false,
  });

  factory MatchingAlgorithmConfig.fromJson(Map<String, dynamic> json) =>
      _$MatchingAlgorithmConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MatchingAlgorithmConfigToJson(this);

  /// 驗證權重總和
  bool get isValidWeights {
    final total = mbtiWeight + interestWeight + lifestyleWeight + basicWeight + locationWeight;
    return (total - 1.0).abs() < 0.01; // 允許小數點誤差
  }
} 