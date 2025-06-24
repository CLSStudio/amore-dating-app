import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用戶模型
/// 包含用戶的基本信息和約會偏好
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> photos;
  final String? bio;
  final DateTime? birthDate;
  final String? gender;
  final String? interestedIn;
  final String? occupation;
  final String? education;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> interests;
  final List<String> languages;
  final UserSettings settings;
  final UserPreferences preferences;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? lastSeen;
  final bool isOnline;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final bool isVerified;
  final bool isPremium;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.photos = const [],
    this.bio,
    this.birthDate,
    this.gender,
    this.interestedIn,
    this.occupation,
    this.education,
    this.location,
    this.latitude,
    this.longitude,
    this.interests = const [],
    this.languages = const [],
    UserSettings? settings,
    UserPreferences? preferences,
    UserStats? stats,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.lastSeen,
    this.isOnline = false,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.isVerified = false,
    this.isPremium = false,
    this.fcmToken,
  })  : settings = settings ?? UserSettings(),
        preferences = preferences ?? UserPreferences(),
        stats = stats ?? UserStats();

  /// 從 JSON 創建
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// 轉換為 JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 從 Firestore 文檔創建
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
      // 處理 Timestamp 轉換
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'lastLoginAt': (data['lastLoginAt'] as Timestamp?)?.toDate().toIso8601String(),
      'lastSeen': (data['lastSeen'] as Timestamp?)?.toDate().toIso8601String(),
      'birthDate': (data['birthDate'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  /// 轉換為 Firestore 格式
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // 移除 id，因為它是文檔 ID
    json.remove('id');
    
    // 將 DateTime 轉換為 Timestamp
    if (json['createdAt'] != null) {
      json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    }
    if (json['updatedAt'] != null) {
      json['updatedAt'] = Timestamp.fromDate(DateTime.parse(json['updatedAt']));
    }
    if (json['lastLoginAt'] != null) {
      json['lastLoginAt'] = Timestamp.fromDate(DateTime.parse(json['lastLoginAt']));
    }
    if (json['lastSeen'] != null) {
      json['lastSeen'] = Timestamp.fromDate(DateTime.parse(json['lastSeen']));
    }
    if (json['birthDate'] != null) {
      json['birthDate'] = Timestamp.fromDate(DateTime.parse(json['birthDate']));
    }
    
    return json;
  }

  /// 計算年齡
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// 獲取主要照片
  String? get primaryPhoto => photos.isNotEmpty ? photos.first : photoUrl;

  /// 複製並更新
  UserModel copyWith({
    String? name,
    String? photoUrl,
    List<String>? photos,
    String? bio,
    DateTime? birthDate,
    String? gender,
    String? interestedIn,
    String? occupation,
    String? education,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? interests,
    List<String>? languages,
    UserSettings? settings,
    UserPreferences? preferences,
    UserStats? stats,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    bool? isVerified,
    bool? isPremium,
    String? fcmToken,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      settings: settings ?? this.settings,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

/// 用戶設置
@JsonSerializable()
class UserSettings {
  final bool showOnline;
  final bool allowNotifications;
  final bool allowLocationSharing;
  final bool allowAnalytics;
  final int maxDistance;
  final int minAge;
  final int maxAge;
  final String language;
  final String theme;

  UserSettings({
    this.showOnline = true,
    this.allowNotifications = true,
    this.allowLocationSharing = true,
    this.allowAnalytics = true,
    this.maxDistance = 50,
    this.minAge = 18,
    this.maxAge = 99,
    this.language = 'zh-TW',
    this.theme = 'system',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettings copyWith({
    bool? showOnline,
    bool? allowNotifications,
    bool? allowLocationSharing,
    bool? allowAnalytics,
    int? maxDistance,
    int? minAge,
    int? maxAge,
    String? language,
    String? theme,
  }) {
    return UserSettings(
      showOnline: showOnline ?? this.showOnline,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      allowLocationSharing: allowLocationSharing ?? this.allowLocationSharing,
      allowAnalytics: allowAnalytics ?? this.allowAnalytics,
      maxDistance: maxDistance ?? this.maxDistance,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}

/// 用戶偏好
@JsonSerializable()
class UserPreferences {
  final List<String> dealBreakers;
  final List<String> mustHaves;
  final List<String> preferredLocations;
  final List<String> relationshipGoals;
  final String? mbtiType;
  final bool preferVerifiedUsers;
  final bool hideFromFacebook;
  final bool hideAge;
  final bool hideDistance;

  UserPreferences({
    this.dealBreakers = const [],
    this.mustHaves = const [],
    this.preferredLocations = const [],
    this.relationshipGoals = const [],
    this.mbtiType,
    this.preferVerifiedUsers = false,
    this.hideFromFacebook = false,
    this.hideAge = false,
    this.hideDistance = false,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    List<String>? dealBreakers,
    List<String>? mustHaves,
    List<String>? preferredLocations,
    List<String>? relationshipGoals,
    String? mbtiType,
    bool? preferVerifiedUsers,
    bool? hideFromFacebook,
    bool? hideAge,
    bool? hideDistance,
  }) {
    return UserPreferences(
      dealBreakers: dealBreakers ?? this.dealBreakers,
      mustHaves: mustHaves ?? this.mustHaves,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      mbtiType: mbtiType ?? this.mbtiType,
      preferVerifiedUsers: preferVerifiedUsers ?? this.preferVerifiedUsers,
      hideFromFacebook: hideFromFacebook ?? this.hideFromFacebook,
      hideAge: hideAge ?? this.hideAge,
      hideDistance: hideDistance ?? this.hideDistance,
    );
  }
}

/// 用戶統計
@JsonSerializable()
class UserStats {
  final int profileViews;
  final int likes;
  final int matches;
  final int superLikes;
  final int messages;
  final double avgResponseTime;
  final int loginStreak;
  final DateTime? lastActive;

  UserStats({
    this.profileViews = 0,
    this.likes = 0,
    this.matches = 0,
    this.superLikes = 0,
    this.messages = 0,
    this.avgResponseTime = 0.0,
    this.loginStreak = 0,
    this.lastActive,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    int? profileViews,
    int? likes,
    int? matches,
    int? superLikes,
    int? messages,
    double? avgResponseTime,
    int? loginStreak,
    DateTime? lastActive,
  }) {
    return UserStats(
      profileViews: profileViews ?? this.profileViews,
      likes: likes ?? this.likes,
      matches: matches ?? this.matches,
      superLikes: superLikes ?? this.superLikes,
      messages: messages ?? this.messages,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      loginStreak: loginStreak ?? this.loginStreak,
      lastActive: lastActive ?? this.lastActive,
    );
  }
} 