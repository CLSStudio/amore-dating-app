import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String? genderPreference;
  final String location;
  final List<String> photoUrls;
  final String? bio;
  final List<String> interests;
  final String? profession;
  final String? education;
  final String? mbtiType;
  final Map<String, dynamic>? valuesAssessment;
  final Map<String, int>? ageRange;
  final List<String> blockedUsers;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    this.genderPreference,
    required this.location,
    this.photoUrls = const [],
    this.bio,
    this.interests = const [],
    this.profession,
    this.education,
    this.mbtiType,
    this.valuesAssessment,
    this.ageRange,
    this.blockedUsers = const [],
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.lastActive,
  });

  // 從 Map 創建 UserModel (用於 Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel.fromJson(map);
  }

  // 計算檔案完整度
  double get profileCompleteness {
    double completeness = 0.0;
    int totalFields = 10;
    
    if (name.isNotEmpty) completeness += 1;
    if (bio?.isNotEmpty ?? false) completeness += 1;
    if (photoUrls.isNotEmpty) completeness += 1;
    if (interests.isNotEmpty) completeness += 1;
    if (profession?.isNotEmpty ?? false) completeness += 1;
    if (education?.isNotEmpty ?? false) completeness += 1;
    if (mbtiType?.isNotEmpty ?? false) completeness += 1;
    if (valuesAssessment?.isNotEmpty ?? false) completeness += 1;
    if (ageRange != null) completeness += 1;
    if (location.isNotEmpty) completeness += 1;
    
    return (completeness / totalFields) * 100;
  }

  // 從 JSON 創建 UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 18,
      gender: json['gender'] ?? '',
      genderPreference: json['genderPreference'],
      location: json['location'] ?? '',
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      profession: json['profession'],
      education: json['education'],
      mbtiType: json['mbtiType'],
      valuesAssessment: json['valuesAssessment'],
      ageRange: json['ageRange'] != null 
          ? Map<String, int>.from(json['ageRange'])
          : null,
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActive: json['lastActive'] is Timestamp 
          ? (json['lastActive'] as Timestamp).toDate()
          : DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'genderPreference': genderPreference,
      'location': location,
      'photoUrls': photoUrls,
      'bio': bio,
      'interests': interests,
      'profession': profession,
      'education': education,
      'mbtiType': mbtiType,
      'valuesAssessment': valuesAssessment,
      'ageRange': ageRange,
      'blockedUsers': blockedUsers,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  // 複製並更新部分字段
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? genderPreference,
    String? location,
    List<String>? photoUrls,
    String? bio,
    List<String>? interests,
    String? profession,
    String? education,
    String? mbtiType,
    Map<String, dynamic>? valuesAssessment,
    Map<String, int>? ageRange,
    List<String>? blockedUsers,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      genderPreference: genderPreference ?? this.genderPreference,
      location: location ?? this.location,
      photoUrls: photoUrls ?? this.photoUrls,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      profession: profession ?? this.profession,
      education: education ?? this.education,
      mbtiType: mbtiType ?? this.mbtiType,
      valuesAssessment: valuesAssessment ?? this.valuesAssessment,
      ageRange: ageRange ?? this.ageRange,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  /// 創建空的用戶模型
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      name: '',
      email: '',
      age: 18,
      gender: '',
      location: '',
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
  }
} 