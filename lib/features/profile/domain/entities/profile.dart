import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// 個人檔案實體
@JsonSerializable()
class Profile {
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String location;
  final String bio;
  final List<String> profileImages;
  final List<Interest> interests;
  final List<String> languages;
  final Education? education;
  final String? occupation;
  final String? company;
  final int? height; // 身高（厘米）
  final String? religion;
  final String? zodiacSign;
  final List<String> hobbies;
  final LifestylePreferences lifestylePreferences;
  final RelationshipGoals relationshipGoals;
  final String? mbtiType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.bio,
    required this.profileImages,
    required this.interests,
    required this.languages,
    this.education,
    this.occupation,
    this.company,
    this.height,
    this.religion,
    this.zodiacSign,
    required this.hobbies,
    required this.lifestylePreferences,
    required this.relationshipGoals,
    this.mbtiType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  /// 獲取年齡
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// 獲取完整姓名
  String get fullName => '$firstName $lastName';

  /// 檢查檔案完整度
  double get completionPercentage {
    int completed = 0;
    int total = 12;

    if (firstName.isNotEmpty) completed++;
    if (lastName.isNotEmpty) completed++;
    if (bio.isNotEmpty) completed++;
    if (profileImages.isNotEmpty) completed++;
    if (interests.isNotEmpty) completed++;
    if (languages.isNotEmpty) completed++;
    if (education != null) completed++;
    if (occupation != null && occupation!.isNotEmpty) completed++;
    if (height != null) completed++;
    if (hobbies.isNotEmpty) completed++;
    if (mbtiType != null) completed++;
    if (relationshipGoals.intent != RelationshipIntent.unknown) completed++;

    return completed / total;
  }

  /// 創建副本
  Profile copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? location,
    String? bio,
    List<String>? profileImages,
    List<Interest>? interests,
    List<String>? languages,
    Education? education,
    String? occupation,
    String? company,
    int? height,
    String? religion,
    String? zodiacSign,
    List<String>? hobbies,
    LifestylePreferences? lifestylePreferences,
    RelationshipGoals? relationshipGoals,
    String? mbtiType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      profileImages: profileImages ?? this.profileImages,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      height: height ?? this.height,
      religion: religion ?? this.religion,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      hobbies: hobbies ?? this.hobbies,
      lifestylePreferences: lifestylePreferences ?? this.lifestylePreferences,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      mbtiType: mbtiType ?? this.mbtiType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// 性別枚舉
enum Gender {
  @JsonValue('male')
  male,
  
  @JsonValue('female')
  female,
  
  @JsonValue('non_binary')
  nonBinary,
  
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

/// 興趣類別
@JsonSerializable()
class Interest {
  final String id;
  final String name;
  final String category;
  final String? icon;

  const Interest({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
  });

  factory Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);
  Map<String, dynamic> toJson() => _$InterestToJson(this);
}

/// 教育程度
@JsonSerializable()
class Education {
  final EducationLevel level;
  final String? school;
  final String? field;
  final int? graduationYear;

  const Education({
    required this.level,
    this.school,
    this.field,
    this.graduationYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

/// 教育程度枚舉
enum EducationLevel {
  @JsonValue('high_school')
  highSchool,
  
  @JsonValue('associate')
  associate,
  
  @JsonValue('bachelor')
  bachelor,
  
  @JsonValue('master')
  master,
  
  @JsonValue('phd')
  phd,
  
  @JsonValue('other')
  other,
}

/// 生活方式偏好
@JsonSerializable()
class LifestylePreferences {
  final SmokingHabit smoking;
  final DrinkingHabit drinking;
  final ExerciseFrequency exercise;
  final DietType diet;
  final PetPreference pets;
  final bool wantsChildren;
  final bool hasChildren;

  const LifestylePreferences({
    required this.smoking,
    required this.drinking,
    required this.exercise,
    required this.diet,
    required this.pets,
    required this.wantsChildren,
    required this.hasChildren,
  });

  factory LifestylePreferences.fromJson(Map<String, dynamic> json) => 
      _$LifestylePreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$LifestylePreferencesToJson(this);
}

/// 吸煙習慣
enum SmokingHabit {
  @JsonValue('never')
  never,
  
  @JsonValue('occasionally')
  occasionally,
  
  @JsonValue('regularly')
  regularly,
  
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

/// 飲酒習慣
enum DrinkingHabit {
  @JsonValue('never')
  never,
  
  @JsonValue('occasionally')
  occasionally,
  
  @JsonValue('socially')
  socially,
  
  @JsonValue('regularly')
  regularly,
  
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

/// 運動頻率
enum ExerciseFrequency {
  @JsonValue('never')
  never,
  
  @JsonValue('rarely')
  rarely,
  
  @JsonValue('sometimes')
  sometimes,
  
  @JsonValue('often')
  often,
  
  @JsonValue('daily')
  daily,
}

/// 飲食類型
enum DietType {
  @JsonValue('omnivore')
  omnivore,
  
  @JsonValue('vegetarian')
  vegetarian,
  
  @JsonValue('vegan')
  vegan,
  
  @JsonValue('pescatarian')
  pescatarian,
  
  @JsonValue('keto')
  keto,
  
  @JsonValue('other')
  other,
}

/// 寵物偏好
enum PetPreference {
  @JsonValue('love_pets')
  lovePets,
  
  @JsonValue('like_pets')
  likePets,
  
  @JsonValue('allergic')
  allergic,
  
  @JsonValue('dislike_pets')
  dislikePets,
  
  @JsonValue('no_preference')
  noPreference,
}

/// 關係目標
@JsonSerializable()
class RelationshipGoals {
  final RelationshipIntent intent;
  final bool openToLongDistance;
  final int? preferredAgeMin;
  final int? preferredAgeMax;
  final double? preferredDistanceMax; // 公里

  const RelationshipGoals({
    required this.intent,
    required this.openToLongDistance,
    this.preferredAgeMin,
    this.preferredAgeMax,
    this.preferredDistanceMax,
  });

  factory RelationshipGoals.fromJson(Map<String, dynamic> json) => 
      _$RelationshipGoalsFromJson(json);
  Map<String, dynamic> toJson() => _$RelationshipGoalsToJson(this);
}

/// 關係意圖
enum RelationshipIntent {
  @JsonValue('unknown')
  unknown,
  
  @JsonValue('casual_dating')
  casualDating,
  
  @JsonValue('serious_relationship')
  seriousRelationship,
  
  @JsonValue('marriage')
  marriage,
  
  @JsonValue('friendship')
  friendship,
  
  @JsonValue('networking')
  networking,
} 