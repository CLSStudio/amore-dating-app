import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// 用戶實體
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  // Amore 特定屬性
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final String? bio;
  final List<String> profileImages;
  final String? mbtiType;
  final bool profileCompleted;
  final bool onboardingCompleted;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.emailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.bio,
    this.profileImages = const [],
    this.mbtiType,
    this.profileCompleted = false,
    this.onboardingCompleted = false,
  });

  /// 從 JSON 創建用戶實例
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// 轉換為 JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// 創建用戶副本
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? location,
    String? bio,
    List<String>? profileImages,
    String? mbtiType,
    bool? profileCompleted,
    bool? onboardingCompleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      profileImages: profileImages ?? this.profileImages,
      mbtiType: mbtiType ?? this.mbtiType,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  /// 獲取完整姓名
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email.split('@').first;
  }

  /// 獲取年齡
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// 檢查檔案是否完整
  bool get isProfileComplete {
    return firstName != null &&
           lastName != null &&
           dateOfBirth != null &&
           gender != null &&
           location != null &&
           bio != null &&
           profileImages.isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName}';
  }
} 