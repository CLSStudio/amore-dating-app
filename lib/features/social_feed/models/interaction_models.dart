// 三階段安全互動機制的資料模型

// 互動階段枚舉
enum InteractionStage {
  public,        // 階段1: 公開互動
  invitation,    // 階段2: 聊天邀請
  private        // 階段3: 私人聊天
}

// 互動類型
enum InteractionType {
  like,          // 點讚
  comment,       // 留言
  emoji,         // 表情符號
  share,         // 分享
  chatInvite,    // 聊天邀請
  privateChat    // 私人聊天
}

// 聊天邀請狀態
enum ChatInvitationStatus {
  pending,       // 待回應
  accepted,      // 已接受
  declined,      // 已拒絕
  expired        // 已過期
}

// 互動記錄模型
class InteractionRecord {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserAvatar;
  final String toUserId;
  final String postId;
  final InteractionType type;
  final String? content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  InteractionRecord({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.toUserId,
    required this.postId,
    required this.type,
    this.content,
    required this.timestamp,
    this.metadata,
  });

  factory InteractionRecord.fromJson(Map<String, dynamic> json) {
    return InteractionRecord(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      fromUserAvatar: json['fromUserAvatar'],
      toUserId: json['toUserId'],
      postId: json['postId'],
      type: InteractionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'toUserId': toUserId,
      'postId': postId,
      'type': type.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

// 聊天邀請模型
class ChatInvitation {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserAvatar;
  final String toUserId;
  final String? message;
  final String reason;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ChatInvitationStatus status;
  final String? relatedPostId;

  ChatInvitation({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.toUserId,
    this.message,
    required this.reason,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.relatedPostId,
  });

  factory ChatInvitation.fromJson(Map<String, dynamic> json) {
    return ChatInvitation(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      fromUserAvatar: json['fromUserAvatar'],
      toUserId: json['toUserId'],
      message: json['message'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      status: ChatInvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      relatedPostId: json['relatedPostId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'toUserId': toUserId,
      'message': message,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'relatedPostId': relatedPostId,
    };
  }

  // 檢查邀請是否過期
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  // 檢查邀請是否活躍
  bool get isActive => status == ChatInvitationStatus.pending && !isExpired;
}

// 用戶互動統計
class UserInteractionStats {
  final String userId;
  final int dailyInvitesSent;
  final int dailyInvitesReceived;
  final DateTime lastInviteSent;
  final List<String> recentDeclinedUsers;
  final int totalInteractions;
  final double responseRate;

  UserInteractionStats({
    required this.userId,
    required this.dailyInvitesSent,
    required this.dailyInvitesReceived,
    required this.lastInviteSent,
    required this.recentDeclinedUsers,
    required this.totalInteractions,
    required this.responseRate,
  });

  factory UserInteractionStats.fromJson(Map<String, dynamic> json) {
    return UserInteractionStats(
      userId: json['userId'],
      dailyInvitesSent: json['dailyInvitesSent'],
      dailyInvitesReceived: json['dailyInvitesReceived'],
      lastInviteSent: DateTime.parse(json['lastInviteSent']),
      recentDeclinedUsers: List<String>.from(json['recentDeclinedUsers']),
      totalInteractions: json['totalInteractions'],
      responseRate: json['responseRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dailyInvitesSent': dailyInvitesSent,
      'dailyInvitesReceived': dailyInvitesReceived,
      'lastInviteSent': lastInviteSent.toIso8601String(),
      'recentDeclinedUsers': recentDeclinedUsers,
      'totalInteractions': totalInteractions,
      'responseRate': responseRate,
    };
  }

  // 檢查是否達到每日邀請限制
  bool get hasReachedDailyLimit => dailyInvitesSent >= 10;
  
  // 檢查是否在冷卻期（被拒絕後24小時內不能再次邀請同一用戶）
  bool isInCooldown(String targetUserId) {
    return recentDeclinedUsers.contains(targetUserId);
  }
}

// 互動權限設定
class InteractionPermissions {
  final bool allowPublicInteractions;
  final bool allowChatInvitations;
  final bool autoAcceptFromMatches;
  final int maxDailyInvitations;
  final bool requireMutualLikes;

  InteractionPermissions({
    this.allowPublicInteractions = true,
    this.allowChatInvitations = true,
    this.autoAcceptFromMatches = false,
    this.maxDailyInvitations = 10,
    this.requireMutualLikes = false,
  });

  factory InteractionPermissions.fromJson(Map<String, dynamic> json) {
    return InteractionPermissions(
      allowPublicInteractions: json['allowPublicInteractions'] ?? true,
      allowChatInvitations: json['allowChatInvitations'] ?? true,
      autoAcceptFromMatches: json['autoAcceptFromMatches'] ?? false,
      maxDailyInvitations: json['maxDailyInvitations'] ?? 10,
      requireMutualLikes: json['requireMutualLikes'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowPublicInteractions': allowPublicInteractions,
      'allowChatInvitations': allowChatInvitations,
      'autoAcceptFromMatches': autoAcceptFromMatches,
      'maxDailyInvitations': maxDailyInvitations,
      'requireMutualLikes': requireMutualLikes,
    };
  }
} 