import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

enum ReportType {
  inappropriateContent,
  harassment,
  spam,
  fakeProfile,
  underage,
  violence,
  other,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class PhotoVerification {
  final String id;
  final String userId;
  final String photoUrl;
  final String? referencePhotoUrl; // 用於比對的參考照片
  final VerificationStatus status;
  final double confidenceScore; // AI 驗證信心度 0.0-1.0
  final Map<String, dynamic> analysisResult; // AI 分析結果
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final String? verifiedBy; // 驗證者 ID (AI 或人工)
  final Map<String, dynamic>? metadata;

  const PhotoVerification({
    required this.id,
    required this.userId,
    required this.photoUrl,
    this.referencePhotoUrl,
    required this.status,
    required this.confidenceScore,
    required this.analysisResult,
    required this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.verifiedBy,
    this.metadata,
  });

  factory PhotoVerification.fromJson(Map<String, dynamic> json) {
    return PhotoVerification(
      id: json['id'],
      userId: json['userId'],
      photoUrl: json['photoUrl'],
      referencePhotoUrl: json['referencePhotoUrl'],
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${json['status']}',
        orElse: () => VerificationStatus.pending,
      ),
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      analysisResult: Map<String, dynamic>.from(json['analysisResult']),
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
      verifiedAt: json['verifiedAt'] != null 
          ? (json['verifiedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: json['rejectionReason'],
      verifiedBy: json['verifiedBy'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'photoUrl': photoUrl,
      'referencePhotoUrl': referencePhotoUrl,
      'status': status.toString().split('.').last,
      'confidenceScore': confidenceScore,
      'analysisResult': analysisResult,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'rejectionReason': rejectionReason,
      'verifiedBy': verifiedBy,
      'metadata': metadata,
    };
  }
}

class UserReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportType type;
  final String description;
  final List<String> evidenceUrls; // 證據照片/截圖
  final DateTime createdAt;
  final String status; // pending, investigating, resolved, dismissed
  final String? resolution; // 處理結果
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final Map<String, dynamic>? metadata;

  const UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.type,
    required this.description,
    required this.evidenceUrls,
    required this.createdAt,
    this.status = 'pending',
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'],
      reporterId: json['reporterId'],
      reportedUserId: json['reportedUserId'],
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${json['type']}',
        orElse: () => ReportType.other,
      ),
      description: json['description'],
      evidenceUrls: List<String>.from(json['evidenceUrls']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      resolution: json['resolution'],
      resolvedAt: json['resolvedAt'] != null 
          ? (json['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: json['resolvedBy'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'type': type.toString().split('.').last,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'resolution': resolution,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
      'metadata': metadata,
    };
  }
}

class BehaviorAnalysis {
  final String userId;
  final RiskLevel riskLevel;
  final double riskScore; // 0.0-1.0
  final Map<String, dynamic> behaviorMetrics; // 行為指標
  final List<String> riskFactors; // 風險因素
  final List<String> positiveFactors; // 正面因素
  final DateTime lastAnalyzed;
  final Map<String, dynamic> communicationAnalysis; // 溝通分析
  final Map<String, dynamic> activityPattern; // 活動模式
  final bool requiresReview; // 是否需要人工審核

  const BehaviorAnalysis({
    required this.userId,
    required this.riskLevel,
    required this.riskScore,
    required this.behaviorMetrics,
    required this.riskFactors,
    required this.positiveFactors,
    required this.lastAnalyzed,
    required this.communicationAnalysis,
    required this.activityPattern,
    this.requiresReview = false,
  });

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorAnalysis(
      userId: json['userId'],
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == 'RiskLevel.${json['riskLevel']}',
        orElse: () => RiskLevel.low,
      ),
      riskScore: json['riskScore']?.toDouble() ?? 0.0,
      behaviorMetrics: Map<String, dynamic>.from(json['behaviorMetrics']),
      riskFactors: List<String>.from(json['riskFactors']),
      positiveFactors: List<String>.from(json['positiveFactors']),
      lastAnalyzed: (json['lastAnalyzed'] as Timestamp).toDate(),
      communicationAnalysis: Map<String, dynamic>.from(json['communicationAnalysis']),
      activityPattern: Map<String, dynamic>.from(json['activityPattern']),
      requiresReview: json['requiresReview'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'riskLevel': riskLevel.toString().split('.').last,
      'riskScore': riskScore,
      'behaviorMetrics': behaviorMetrics,
      'riskFactors': riskFactors,
      'positiveFactors': positiveFactors,
      'lastAnalyzed': Timestamp.fromDate(lastAnalyzed),
      'communicationAnalysis': communicationAnalysis,
      'activityPattern': activityPattern,
      'requiresReview': requiresReview,
    };
  }
}

class SafetyAlert {
  final String id;
  final String userId;
  final String alertType; // suspicious_behavior, inappropriate_content, safety_concern
  final String title;
  final String description;
  final RiskLevel severity;
  final Map<String, dynamic> alertData;
  final DateTime createdAt;
  final bool isRead;
  final bool isResolved;
  final String? actionTaken;
  final DateTime? resolvedAt;

  const SafetyAlert({
    required this.id,
    required this.userId,
    required this.alertType,
    required this.title,
    required this.description,
    required this.severity,
    required this.alertData,
    required this.createdAt,
    this.isRead = false,
    this.isResolved = false,
    this.actionTaken,
    this.resolvedAt,
  });

  factory SafetyAlert.fromJson(Map<String, dynamic> json) {
    return SafetyAlert(
      id: json['id'],
      userId: json['userId'],
      alertType: json['alertType'],
      title: json['title'],
      description: json['description'],
      severity: RiskLevel.values.firstWhere(
        (e) => e.toString() == 'RiskLevel.${json['severity']}',
        orElse: () => RiskLevel.low,
      ),
      alertData: Map<String, dynamic>.from(json['alertData']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
      isResolved: json['isResolved'] ?? false,
      actionTaken: json['actionTaken'],
      resolvedAt: json['resolvedAt'] != null 
          ? (json['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'alertType': alertType,
      'title': title,
      'description': description,
      'severity': severity.toString().split('.').last,
      'alertData': alertData,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'isResolved': isResolved,
      'actionTaken': actionTaken,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}

class BlockedUser {
  final String id;
  final String blockerId;
  final String blockedUserId;
  final String reason;
  final DateTime blockedAt;
  final bool isActive;

  const BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    required this.reason,
    required this.blockedAt,
    this.isActive = true,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      blockerId: json['blockerId'],
      blockedUserId: json['blockedUserId'],
      reason: json['reason'],
      blockedAt: (json['blockedAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'reason': reason,
      'blockedAt': Timestamp.fromDate(blockedAt),
      'isActive': isActive,
    };
  }
}

class SafetySettings {
  final String userId;
  final bool photoVerificationRequired;
  final bool behaviorAnalysisEnabled;
  final bool autoBlockSuspiciousUsers;
  final List<String> blockedKeywords;
  final Map<String, bool> privacySettings;
  final Map<String, bool> notificationSettings;
  final DateTime lastUpdated;

  const SafetySettings({
    required this.userId,
    this.photoVerificationRequired = true,
    this.behaviorAnalysisEnabled = true,
    this.autoBlockSuspiciousUsers = false,
    this.blockedKeywords = const [],
    this.privacySettings = const {},
    this.notificationSettings = const {},
    required this.lastUpdated,
  });

  factory SafetySettings.fromJson(Map<String, dynamic> json) {
    return SafetySettings(
      userId: json['userId'],
      photoVerificationRequired: json['photoVerificationRequired'] ?? true,
      behaviorAnalysisEnabled: json['behaviorAnalysisEnabled'] ?? true,
      autoBlockSuspiciousUsers: json['autoBlockSuspiciousUsers'] ?? false,
      blockedKeywords: List<String>.from(json['blockedKeywords'] ?? []),
      privacySettings: Map<String, bool>.from(json['privacySettings'] ?? {}),
      notificationSettings: Map<String, bool>.from(json['notificationSettings'] ?? {}),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'photoVerificationRequired': photoVerificationRequired,
      'behaviorAnalysisEnabled': behaviorAnalysisEnabled,
      'autoBlockSuspiciousUsers': autoBlockSuspiciousUsers,
      'blockedKeywords': blockedKeywords,
      'privacySettings': privacySettings,
      'notificationSettings': notificationSettings,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
} 