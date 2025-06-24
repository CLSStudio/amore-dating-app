import 'package:json_annotation/json_annotation.dart';

part 'match.g.dart';

/// 匹配實體
@JsonSerializable()
class Match {
  final String id;
  final String user1Id;
  final String user2Id;
  final double compatibilityScore;
  final MatchDetails details;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? matchedAt;

  const Match({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.compatibilityScore,
    required this.details,
    required this.status,
    required this.createdAt,
    this.matchedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  /// 獲取匹配對象的用戶ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  /// 創建副本
  Match copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    double? compatibilityScore,
    MatchDetails? details,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? matchedAt,
  }) {
    return Match(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }
}

/// 匹配詳情
@JsonSerializable()
class MatchDetails {
  final double mbtiCompatibility;
  final double valuesCompatibility;
  final double interestsCompatibility;
  final double lifestyleCompatibility;
  final double locationCompatibility;
  final List<String> commonInterests;
  final List<String> compatibilityReasons;

  const MatchDetails({
    required this.mbtiCompatibility,
    required this.valuesCompatibility,
    required this.interestsCompatibility,
    required this.lifestyleCompatibility,
    required this.locationCompatibility,
    required this.commonInterests,
    required this.compatibilityReasons,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) => 
      _$MatchDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$MatchDetailsToJson(this);
}

/// 匹配狀態
enum MatchStatus {
  @JsonValue('potential')
  potential, // 潛在匹配
  
  @JsonValue('liked')
  liked, // 單方面喜歡
  
  @JsonValue('matched')
  matched, // 雙方匹配
  
  @JsonValue('passed')
  passed, // 跳過
  
  @JsonValue('blocked')
  blocked, // 封鎖
}

/// 用戶偏好設置
@JsonSerializable()
class MatchingPreferences {
  final String userId;
  final int minAge;
  final int maxAge;
  final double maxDistance; // 公里
  final List<String> preferredGenders;
  final List<String> dealBreakers;
  final bool showMeOnAmore;
  final bool onlyShowVerified;
  final DateTime updatedAt;

  const MatchingPreferences({
    required this.userId,
    required this.minAge,
    required this.maxAge,
    required this.maxDistance,
    required this.preferredGenders,
    required this.dealBreakers,
    required this.showMeOnAmore,
    required this.onlyShowVerified,
    required this.updatedAt,
  });

  factory MatchingPreferences.fromJson(Map<String, dynamic> json) => 
      _$MatchingPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$MatchingPreferencesToJson(this);

  /// 創建副本
  MatchingPreferences copyWith({
    String? userId,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    List<String>? preferredGenders,
    List<String>? dealBreakers,
    bool? showMeOnAmore,
    bool? onlyShowVerified,
    DateTime? updatedAt,
  }) {
    return MatchingPreferences(
      userId: userId ?? this.userId,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      dealBreakers: dealBreakers ?? this.dealBreakers,
      showMeOnAmore: showMeOnAmore ?? this.showMeOnAmore,
      onlyShowVerified: onlyShowVerified ?? this.onlyShowVerified,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// 滑動動作
@JsonSerializable()
class SwipeAction {
  final String id;
  final String userId;
  final String targetUserId;
  final SwipeType type;
  final DateTime createdAt;

  const SwipeAction({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.type,
    required this.createdAt,
  });

  factory SwipeAction.fromJson(Map<String, dynamic> json) => 
      _$SwipeActionFromJson(json);
  Map<String, dynamic> toJson() => _$SwipeActionToJson(this);
}

/// 滑動類型
enum SwipeType {
  @JsonValue('like')
  like, // 喜歡
  
  @JsonValue('pass')
  pass, // 跳過
  
  @JsonValue('super_like')
  superLike, // 超級喜歡
  
  @JsonValue('boost')
  boost, // 推廣
} 