import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/dating/modes/dating_mode_system.dart';

/// 🎯 模式專屬檔案抽象基類
abstract class ModeProfile {
  final String userId;
  final bool active;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final DatingMode mode;

  const ModeProfile({
    required this.userId,
    required this.active,
    required this.joinedAt,
    this.lastActiveAt,
    required this.mode,
  });

  Map<String, dynamic> toMap();
  
  static ModeProfile fromMap(Map<String, dynamic> map, DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return SeriousDatingProfile.fromMap(map);
      case DatingMode.explore:
        return ExploreProfile.fromMap(map);
      case DatingMode.passion:
        return PassionProfile.fromMap(map);
    }
  }
}

/// 🎯 認真交往模式檔案
class SeriousDatingProfile extends ModeProfile {
  final String occupation;
  final String education;
  final String relationshipGoals;
  final String mbtiType;
  final List<String> interests;
  final List<String> coreValues;
  final String? location;
  final String? familyPlanning;

  const SeriousDatingProfile({
    required super.userId,
    required super.active,
    required super.joinedAt,
    super.lastActiveAt,
    required this.occupation,
    required this.education,
    required this.relationshipGoals,
    required this.mbtiType,
    required this.interests,
    this.coreValues = const [],
    this.location,
    this.familyPlanning,
  }) : super(mode: DatingMode.serious);

  /// 從UserModel創建SeriousDatingProfile
  factory SeriousDatingProfile.fromUserModel(dynamic userModel) {
    return SeriousDatingProfile(
      userId: userModel.uid ?? '',
      active: true,
      joinedAt: DateTime.now(),
      occupation: userModel.profession ?? '',
      education: userModel.education ?? '',
      relationshipGoals: '長期關係',
      mbtiType: userModel.mbtiType ?? '',
      interests: userModel.interests ?? [],
      coreValues: ['誠實守信', '責任感'],
      location: userModel.location,
      familyPlanning: '開放討論',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'active': active,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'mode': mode.toString().split('.').last,
      'occupation': occupation,
      'education': education,
      'relationshipGoals': relationshipGoals,
      'mbtiType': mbtiType,
      'interests': interests,
      'coreValues': coreValues,
      'location': location,
      'familyPlanning': familyPlanning,
    };
  }

  factory SeriousDatingProfile.fromMap(Map<String, dynamic> map) {
    return SeriousDatingProfile(
      userId: map['userId'] ?? '',
      active: map['active'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
      occupation: map['occupation'] ?? '',
      education: map['education'] ?? '',
      relationshipGoals: map['relationshipGoals'] ?? '',
      mbtiType: map['mbtiType'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      coreValues: List<String>.from(map['coreValues'] ?? []),
      location: map['location'],
      familyPlanning: map['familyPlanning'],
    );
  }
}

/// 🌟 探索模式檔案
class ExploreProfile extends ModeProfile {
  final List<String> interests;
  final List<String> languages;
  final String activityLevel;

  const ExploreProfile({
    required super.userId,
    required super.active,
    required super.joinedAt,
    super.lastActiveAt,
    required this.interests,
    required this.languages,
    required this.activityLevel,
  }) : super(mode: DatingMode.explore);

  /// 從UserModel創建ExploreProfile
  factory ExploreProfile.fromUserModel(dynamic userModel) {
    return ExploreProfile(
      userId: userModel.uid ?? '',
      active: true,
      joinedAt: DateTime.now(),
      interests: userModel.interests ?? [],
      languages: ['中文', '英文'],
      activityLevel: '平衡適中',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'active': active,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'mode': mode.toString().split('.').last,
      'interests': interests,
      'languages': languages,
      'activityLevel': activityLevel,
    };
  }

  factory ExploreProfile.fromMap(Map<String, dynamic> map) {
    return ExploreProfile(
      userId: map['userId'] ?? '',
      active: map['active'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
      interests: List<String>.from(map['interests'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      activityLevel: map['activityLevel'] ?? 'moderate',
    );
  }
}

/// 🔥 激情模式檔案
class PassionProfile extends ModeProfile {
  final GeoPoint? currentLocation;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? availableUntil;
  final String? lookingFor;

  const PassionProfile({
    required super.userId,
    required super.active,
    required super.joinedAt,
    super.lastActiveAt,
    this.currentLocation,
    required this.isOnline,
    this.lastSeen,
    this.availableUntil,
    this.lookingFor,
  }) : super(mode: DatingMode.passion);

  /// 從UserModel創建PassionProfile
  factory PassionProfile.fromUserModel(dynamic userModel) {
    return PassionProfile(
      userId: userModel.uid ?? '',
      active: true,
      joinedAt: DateTime.now(),
      currentLocation: null, // 需要實際位置API
      isOnline: true,
      lastSeen: DateTime.now(),
      availableUntil: DateTime.now().add(Duration(hours: 2)),
      lookingFor: '即時約會',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'active': active,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'mode': mode.toString().split('.').last,
      'currentLocation': currentLocation,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'availableUntil': availableUntil != null ? Timestamp.fromDate(availableUntil!) : null,
      'lookingFor': lookingFor,
    };
  }

  factory PassionProfile.fromMap(Map<String, dynamic> map) {
    return PassionProfile(
      userId: map['userId'] ?? '',
      active: map['active'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
      currentLocation: map['currentLocation'] as GeoPoint?,
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      availableUntil: (map['availableUntil'] as Timestamp?)?.toDate(),
      lookingFor: map['lookingFor'],
    );
  }
} 