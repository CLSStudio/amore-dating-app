class UserProfile {
  final String userId;
  final String name;
  final int age;
  final String gender; // male, female, other
  final String bio;
  final List<String> photos;
  final String? profilePhotoUrl;
  final List<String> interests;
  final String? occupation;
  final String? education;
  final String? location;
  final int? height; // in cm
  final String? mbtiType;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.photos,
    this.profilePhotoUrl,
    required this.interests,
    this.occupation,
    this.education,
    this.location,
    this.height,
    this.mbtiType,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      bio: json['bio'],
      photos: List<String>.from(json['photos'] ?? []),
      profilePhotoUrl: json['profilePhotoUrl'],
      interests: List<String>.from(json['interests'] ?? []),
      occupation: json['occupation'],
      education: json['education'],
      location: json['location'],
      height: json['height'],
      mbtiType: json['mbtiType'],
      isProfileComplete: json['isProfileComplete'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'bio': bio,
      'photos': photos,
      'profilePhotoUrl': profilePhotoUrl,
      'interests': interests,
      'occupation': occupation,
      'education': education,
      'location': location,
      'height': height,
      'mbtiType': mbtiType,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    int? age,
    String? gender,
    String? bio,
    List<String>? photos,
    String? profilePhotoUrl,
    List<String>? interests,
    String? occupation,
    String? education,
    String? location,
    int? height,
    String? mbtiType,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      interests: interests ?? this.interests,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      location: location ?? this.location,
      height: height ?? this.height,
      mbtiType: mbtiType ?? this.mbtiType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 計算檔案完成度
  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 10; // 總共需要填寫的重要字段數

    if (name.isNotEmpty) completedFields++;
    if (age > 0) completedFields++;
    if (bio.isNotEmpty) completedFields++;
    if (photos.isNotEmpty) completedFields++;
    if (interests.isNotEmpty) completedFields++;
    if (occupation != null && occupation!.isNotEmpty) completedFields++;
    if (education != null && education!.isNotEmpty) completedFields++;
    if (location != null && location!.isNotEmpty) completedFields++;
    if (height != null && height! > 0) completedFields++;
    if (mbtiType != null && mbtiType!.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }
}

class Interest {
  final String id;
  final String name;
  final String category;
  final String icon;

  const Interest({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
    };
  }
} 