class Match {
  final String id;
  final String userId1;
  final String userId2;
  final double compatibilityScore;
  final Map<String, double> scoreBreakdown;
  final DateTime createdAt;
  final MatchStatus status;
  final String? lastMessageId;
  final DateTime? lastMessageAt;

  const Match({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.compatibilityScore,
    required this.scoreBreakdown,
    required this.createdAt,
    required this.status,
    this.lastMessageId,
    this.lastMessageAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      userId1: json['userId1'],
      userId2: json['userId2'],
      compatibilityScore: json['compatibilityScore'].toDouble(),
      scoreBreakdown: Map<String, double>.from(json['scoreBreakdown']),
      createdAt: DateTime.parse(json['createdAt']),
      status: MatchStatus.values.firstWhere(
        (e) => e.toString() == 'MatchStatus.${json['status']}',
      ),
      lastMessageId: json['lastMessageId'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'compatibilityScore': compatibilityScore,
      'scoreBreakdown': scoreBreakdown,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
    };
  }
}

enum MatchStatus {
  pending,    // 等待對方回應
  matched,    // 雙方都喜歡
  rejected,   // 被拒絕
  expired,    // 過期
}

class CompatibilityAnalysis {
  final double mbtiScore;
  final double interestScore;
  final double ageScore;
  final double locationScore;
  final double overallScore;
  final List<String> strengths;
  final List<String> considerations;

  const CompatibilityAnalysis({
    required this.mbtiScore,
    required this.interestScore,
    required this.ageScore,
    required this.locationScore,
    required this.overallScore,
    required this.strengths,
    required this.considerations,
  });

  factory CompatibilityAnalysis.fromJson(Map<String, dynamic> json) {
    return CompatibilityAnalysis(
      mbtiScore: json['mbtiScore'].toDouble(),
      interestScore: json['interestScore'].toDouble(),
      ageScore: json['ageScore'].toDouble(),
      locationScore: json['locationScore'].toDouble(),
      overallScore: json['overallScore'].toDouble(),
      strengths: List<String>.from(json['strengths']),
      considerations: List<String>.from(json['considerations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mbtiScore': mbtiScore,
      'interestScore': interestScore,
      'ageScore': ageScore,
      'locationScore': locationScore,
      'overallScore': overallScore,
      'strengths': strengths,
      'considerations': considerations,
    };
  }
}

class UserAction {
  final String userId;
  final String targetUserId;
  final ActionType action;
  final DateTime timestamp;

  const UserAction({
    required this.userId,
    required this.targetUserId,
    required this.action,
    required this.timestamp,
  });

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      userId: json['userId'],
      targetUserId: json['targetUserId'],
      action: ActionType.values.firstWhere(
        (e) => e.toString() == 'ActionType.${json['action']}',
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetUserId': targetUserId,
      'action': action.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ActionType {
  like,     // 喜歡
  pass,     // 跳過
  superLike, // 超級喜歡
  block,    // 封鎖
} 