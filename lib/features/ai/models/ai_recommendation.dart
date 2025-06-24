import 'package:cloud_firestore/cloud_firestore.dart';

enum RecommendationType {
  userMatch,        // 用戶匹配推薦
  dateIdea,         // 約會建議
  conversation,     // 對話建議
  relationship,     // 關係建議
  gift,            // 禮物推薦
  activity,        // 活動推薦
}

enum ConsultationCategory {
  communication,    // 溝通技巧
  dating,          // 約會指導
  relationship,    // 關係發展
  conflict,        // 衝突解決
  intimacy,        // 親密關係
  longDistance,    // 遠距離戀愛
  breakup,         // 分手處理
  marriage,        // 婚姻準備
}

class AIRecommendation {
  final String id;
  final String userId;
  final RecommendationType type;
  final String title;
  final String description;
  final Map<String, dynamic> content;
  final double confidenceScore; // 0.0-1.0 推薦信心度
  final List<String> reasons; // 推薦理由
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isViewed;
  final bool isAccepted;
  final Map<String, dynamic>? metadata;

  const AIRecommendation({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.content,
    required this.confidenceScore,
    required this.reasons,
    required this.createdAt,
    this.expiresAt,
    this.isViewed = false,
    this.isAccepted = false,
    this.metadata,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'],
      userId: json['userId'],
      type: RecommendationType.values.firstWhere(
        (e) => e.toString() == 'RecommendationType.${json['type']}',
        orElse: () => RecommendationType.userMatch,
      ),
      title: json['title'],
      description: json['description'],
      content: Map<String, dynamic>.from(json['content']),
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      reasons: List<String>.from(json['reasons']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: json['expiresAt'] != null 
          ? (json['expiresAt'] as Timestamp).toDate()
          : null,
      isViewed: json['isViewed'] ?? false,
      isAccepted: json['isAccepted'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'content': content,
      'confidenceScore': confidenceScore,
      'reasons': reasons,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isViewed': isViewed,
      'isAccepted': isAccepted,
      'metadata': metadata,
    };
  }
}

class LoveConsultation {
  final String id;
  final String userId;
  final ConsultationCategory category;
  final String question;
  final String situation; // 詳細情況描述
  final Map<String, dynamic> userContext; // 用戶背景信息
  final String aiResponse;
  final List<String> actionItems; // 具體行動建議
  final List<String> resources; // 相關資源連結
  final double helpfulnessScore; // 用戶評分 0.0-5.0
  final DateTime createdAt;
  final DateTime? followUpAt; // 建議跟進時間
  final bool isAnonymous;
  final Map<String, dynamic>? metadata;

  const LoveConsultation({
    required this.id,
    required this.userId,
    required this.category,
    required this.question,
    required this.situation,
    required this.userContext,
    required this.aiResponse,
    required this.actionItems,
    required this.resources,
    this.helpfulnessScore = 0.0,
    required this.createdAt,
    this.followUpAt,
    this.isAnonymous = false,
    this.metadata,
  });

  factory LoveConsultation.fromJson(Map<String, dynamic> json) {
    return LoveConsultation(
      id: json['id'],
      userId: json['userId'],
      category: ConsultationCategory.values.firstWhere(
        (e) => e.toString() == 'ConsultationCategory.${json['category']}',
        orElse: () => ConsultationCategory.communication,
      ),
      question: json['question'],
      situation: json['situation'],
      userContext: Map<String, dynamic>.from(json['userContext']),
      aiResponse: json['aiResponse'],
      actionItems: List<String>.from(json['actionItems']),
      resources: List<String>.from(json['resources']),
      helpfulnessScore: json['helpfulnessScore']?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      followUpAt: json['followUpAt'] != null 
          ? (json['followUpAt'] as Timestamp).toDate()
          : null,
      isAnonymous: json['isAnonymous'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category.toString().split('.').last,
      'question': question,
      'situation': situation,
      'userContext': userContext,
      'aiResponse': aiResponse,
      'actionItems': actionItems,
      'resources': resources,
      'helpfulnessScore': helpfulnessScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'followUpAt': followUpAt != null ? Timestamp.fromDate(followUpAt!) : null,
      'isAnonymous': isAnonymous,
      'metadata': metadata,
    };
  }
}

class UserBehaviorAnalysis {
  final String userId;
  final Map<String, int> activityCounts; // 各種活動的計數
  final Map<String, double> preferences; // 偏好分析
  final List<String> interests; // 興趣標籤
  final Map<String, dynamic> mbtiInsights; // MBTI 相關洞察
  final DateTime lastUpdated;
  final double engagementScore; // 參與度分數
  final Map<String, dynamic> communicationStyle; // 溝通風格分析

  const UserBehaviorAnalysis({
    required this.userId,
    required this.activityCounts,
    required this.preferences,
    required this.interests,
    required this.mbtiInsights,
    required this.lastUpdated,
    required this.engagementScore,
    required this.communicationStyle,
  });

  factory UserBehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return UserBehaviorAnalysis(
      userId: json['userId'],
      activityCounts: Map<String, int>.from(json['activityCounts']),
      preferences: Map<String, double>.from(json['preferences']),
      interests: List<String>.from(json['interests']),
      mbtiInsights: Map<String, dynamic>.from(json['mbtiInsights']),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
      engagementScore: json['engagementScore']?.toDouble() ?? 0.0,
      communicationStyle: Map<String, dynamic>.from(json['communicationStyle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'activityCounts': activityCounts,
      'preferences': preferences,
      'interests': interests,
      'mbtiInsights': mbtiInsights,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'engagementScore': engagementScore,
      'communicationStyle': communicationStyle,
    };
  }
}

class SmartNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // reminder, suggestion, alert, celebration
  final Map<String, dynamic> actionData; // 點擊後的行動數據
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final bool isRead;
  final int priority; // 1-5, 5最重要

  const SmartNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.actionData,
    required this.scheduledAt,
    this.sentAt,
    this.isRead = false,
    this.priority = 3,
  });

  factory SmartNotification.fromJson(Map<String, dynamic> json) {
    return SmartNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      actionData: Map<String, dynamic>.from(json['actionData']),
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      sentAt: json['sentAt'] != null 
          ? (json['sentAt'] as Timestamp).toDate()
          : null,
      isRead: json['isRead'] ?? false,
      priority: json['priority'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'actionData': actionData,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'isRead': isRead,
      'priority': priority,
    };
  }
} 