import 'package:cloud_firestore/cloud_firestore.dart';

// ================== 社交動態數據模型 ==================

/// 📱 動態帖子模型
class FeedPost {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userAvatarUrl;
  final String? textContent;
  final List<MediaContent> mediaContent;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String> viewedBy;
  final int shareCount;
  final bool isVisible;
  final List<String> tags;
  final String? location;
  final PostType type;
  final Map<String, dynamic> metadata;

  FeedPost({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatarUrl,
    this.textContent,
    required this.mediaContent,
    required this.createdAt,
    required this.likedBy,
    required this.viewedBy,
    this.shareCount = 0,
    this.isVisible = true,
    required this.tags,
    this.location,
    required this.type,
    required this.metadata,
  });

  factory FeedPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      textContent: data['textContent'],
      mediaContent: (data['mediaContent'] as List<dynamic>?)
          ?.map((item) => MediaContent.fromMap(item))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      shareCount: data['shareCount'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
      location: data['location'],
      type: PostType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => PostType.photo,
      ),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'textContent': textContent,
      'mediaContent': mediaContent.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'viewedBy': viewedBy,
      'shareCount': shareCount,
      'isVisible': isVisible,
      'tags': tags,
      'location': location,
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  int get likeCount => likedBy.length;
  int get viewCount => viewedBy.length;
  
  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isViewedBy(String userId) => viewedBy.contains(userId);
}

/// 📷 媒體內容模型
class MediaContent {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final double? aspectRatio;
  final int? duration; // 視頻時長（秒）
  final int? size; // 文件大小（字節）
  final Map<String, dynamic> metadata;

  MediaContent({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.aspectRatio,
    this.duration,
    this.size,
    required this.metadata,
  });

  factory MediaContent.fromMap(Map<String, dynamic> map) {
    return MediaContent(
      id: map['id'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MediaType.photo,
      ),
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      aspectRatio: map['aspectRatio']?.toDouble(),
      duration: map['duration'],
      size: map['size'],
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'aspectRatio': aspectRatio,
      'duration': duration,
      'size': size,
      'metadata': metadata,
    };
  }
}

/// 👥 關注關係模型
class FollowRelationship {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;
  final bool isActive;
  final FollowType type;

  FollowRelationship({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.isActive = true,
    required this.type,
  });

  factory FollowRelationship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FollowRelationship(
      id: doc.id,
      followerId: data['followerId'] ?? '',
      followingId: data['followingId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      type: FollowType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => FollowType.normal,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'type': type.toString(),
    };
  }
}

/// 🏷️ 話題模型
class Topic {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorDisplayName;
  final String creatorAvatarUrl;
  final DateTime createdAt;
  final List<String> tags;
  final int participantCount;
  final int postCount;
  final DateTime lastActivityAt;
  final bool isActive;
  final bool isFeatured;
  final TopicCategory category;
  final Map<String, dynamic> metadata;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorDisplayName,
    required this.creatorAvatarUrl,
    required this.createdAt,
    required this.tags,
    this.participantCount = 0,
    this.postCount = 0,
    required this.lastActivityAt,
    this.isActive = true,
    this.isFeatured = false,
    required this.category,
    required this.metadata,
  });

  factory Topic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Topic(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorDisplayName: data['creatorDisplayName'] ?? '',
      creatorAvatarUrl: data['creatorAvatarUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      participantCount: data['participantCount'] ?? 0,
      postCount: data['postCount'] ?? 0,
      lastActivityAt: (data['lastActivityAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      category: TopicCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => TopicCategory.general,
      ),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorDisplayName': creatorDisplayName,
      'creatorAvatarUrl': creatorAvatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'participantCount': participantCount,
      'postCount': postCount,
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'category': category.toString(),
      'metadata': metadata,
    };
  }
}

/// 💬 話題帖子模型
class TopicPost {
  final String id;
  final String topicId;
  final String userId;
  final String userDisplayName;
  final String userAvatarUrl;
  final String content;
  final List<MediaContent> mediaContent;
  final DateTime createdAt;
  final List<String> likedBy;
  final int replyCount;
  final bool isVisible;
  final bool isPinned;
  final Map<String, dynamic> metadata;

  TopicPost({
    required this.id,
    required this.topicId,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatarUrl,
    required this.content,
    required this.mediaContent,
    required this.createdAt,
    required this.likedBy,
    this.replyCount = 0,
    this.isVisible = true,
    this.isPinned = false,
    required this.metadata,
  });

  factory TopicPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopicPost(
      id: doc.id,
      topicId: data['topicId'] ?? '',
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      content: data['content'] ?? '',
      mediaContent: (data['mediaContent'] as List<dynamic>?)
          ?.map((item) => MediaContent.fromMap(item))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      replyCount: data['replyCount'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      isPinned: data['isPinned'] ?? false,
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topicId': topicId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'mediaContent': mediaContent.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'replyCount': replyCount,
      'isVisible': isVisible,
      'isPinned': isPinned,
      'metadata': metadata,
    };
  }

  int get likeCount => likedBy.length;
  bool isLikedBy(String userId) => likedBy.contains(userId);
}

// ================== 枚舉類型 ==================

enum PostType {
  photo,
  video,
  text,
  mixed,
}

enum MediaType {
  photo,
  video,
}

enum FollowType {
  normal,
  close,
  muted,
}

enum TopicCategory {
  general,
  dating,
  lifestyle,
  hobbies,
  career,
  travel,
  food,
  fitness,
  entertainment,
  relationships,
  mbti,
  hongkong,
}

// ================== 擴展方法 ==================

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.photo:
        return '照片';
      case PostType.video:
        return '視頻';
      case PostType.text:
        return '文字';
      case PostType.mixed:
        return '混合';
    }
  }

  String get icon {
    switch (this) {
      case PostType.photo:
        return '📷';
      case PostType.video:
        return '🎥';
      case PostType.text:
        return '📝';
      case PostType.mixed:
        return '🎨';
    }
  }
}

extension TopicCategoryExtension on TopicCategory {
  String get displayName {
    switch (this) {
      case TopicCategory.general:
        return '一般討論';
      case TopicCategory.dating:
        return '約會交友';
      case TopicCategory.lifestyle:
        return '生活方式';
      case TopicCategory.hobbies:
        return '興趣愛好';
      case TopicCategory.career:
        return '職業發展';
      case TopicCategory.travel:
        return '旅行分享';
      case TopicCategory.food:
        return '美食推薦';
      case TopicCategory.fitness:
        return '健身運動';
      case TopicCategory.entertainment:
        return '娛樂休閒';
      case TopicCategory.relationships:
        return '感情關係';
      case TopicCategory.mbti:
        return 'MBTI 討論';
      case TopicCategory.hongkong:
        return '香港生活';
    }
  }

  String get icon {
    switch (this) {
      case TopicCategory.general:
        return '💬';
      case TopicCategory.dating:
        return '💕';
      case TopicCategory.lifestyle:
        return '🌟';
      case TopicCategory.hobbies:
        return '🎨';
      case TopicCategory.career:
        return '💼';
      case TopicCategory.travel:
        return '✈️';
      case TopicCategory.food:
        return '🍽️';
      case TopicCategory.fitness:
        return '💪';
      case TopicCategory.entertainment:
        return '🎭';
      case TopicCategory.relationships:
        return '💝';
      case TopicCategory.mbti:
        return '🧠';
      case TopicCategory.hongkong:
        return '🏙️';
    }
  }
} 