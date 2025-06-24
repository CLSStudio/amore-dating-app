import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final UserProfile? profile;
  final UserPreferences? preferences;
  final List<String> connectedAccounts;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.profile,
    this.preferences,
    this.connectedAccounts = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    return json;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    UserProfile? profile,
    UserPreferences? preferences,
    List<String>? connectedAccounts,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
    );
  }
}

@JsonSerializable()
class UserProfile {
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? gender;
  final String? location;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final String? occupation;
  final String? education;
  final int? height;
  final String? relationshipGoal;
  final Map<String, dynamic>? mbtiResult;
  final Map<String, dynamic>? valuesAssessment;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.birthDate,
    this.gender,
    this.location,
    this.bio,
    this.photos = const [],
    this.interests = const [],
    this.occupation,
    this.education,
    this.height,
    this.relationshipGoal,
    this.mbtiResult,
    this.valuesAssessment,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
    String? location,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    String? occupation,
    String? education,
    int? height,
    String? relationshipGoal,
    Map<String, dynamic>? mbtiResult,
    Map<String, dynamic>? valuesAssessment,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      height: height ?? this.height,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      mbtiResult: mbtiResult ?? this.mbtiResult,
      valuesAssessment: valuesAssessment ?? this.valuesAssessment,
    );
  }
}

@JsonSerializable()
class UserPreferences {
  final int? minAge;
  final int? maxAge;
  final int? maxDistance;
  final List<String> preferredGenders;
  final bool showMeOnAmore;
  final bool enableNotifications;
  final bool enableLocationServices;
  final Map<String, bool> notificationSettings;

  const UserPreferences({
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.preferredGenders = const [],
    this.showMeOnAmore = true,
    this.enableNotifications = true,
    this.enableLocationServices = true,
    this.notificationSettings = const {},
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    int? minAge,
    int? maxAge,
    int? maxDistance,
    List<String>? preferredGenders,
    bool? showMeOnAmore,
    bool? enableNotifications,
    bool? enableLocationServices,
    Map<String, bool>? notificationSettings,
  }) {
    return UserPreferences(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      showMeOnAmore: showMeOnAmore ?? this.showMeOnAmore,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableLocationServices: enableLocationServices ?? this.enableLocationServices,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
} 