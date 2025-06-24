import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_model.g.dart';

/// 配對模型
@JsonSerializable()
class MatchModel {
  final String id;
  final String userId1;
  final String userId2;
  final double compatibilityScore;
  final Map<String, double> scoreBreakdown;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? matchedAt;
  final String? note;

  MatchModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.compatibilityScore,
    required this.scoreBreakdown,
    this.status = MatchStatus.pending,
    required this.createdAt,
    this.matchedAt,
    this.note,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchModelToJson(this);

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'matchedAt': (data['matchedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    
    if (json['createdAt'] != null) {
      json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    }
    if (json['matchedAt'] != null) {
      json['matchedAt'] = Timestamp.fromDate(DateTime.parse(json['matchedAt']));
    }
    
    return json;
  }
}

/// 配對狀態
enum MatchStatus {
  pending,    // 等待中
  matched,    // 已配對
  rejected,   // 已拒絕
  expired,    // 已過期
}

/// 配對候選人模型
@JsonSerializable()
class MatchCandidate {
  final String userId;
  final double compatibilityScore;
  final double distance;
  final DateTime lastActive;
  final Map<String, double> scoreDetails;
  final List<String> commonInterests;
  final String compatibilityReason;

  MatchCandidate({
    required this.userId,
    required this.compatibilityScore,
    required this.distance,
    required this.lastActive,
    required this.scoreDetails,
    required this.commonInterests,
    required this.compatibilityReason,
  });

  factory MatchCandidate.fromJson(Map<String, dynamic> json) =>
      _$MatchCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$MatchCandidateToJson(this);
}

/// MBTI 兼容性映射
class MBTICompatibility {
  static const Map<String, Map<String, double>> compatibilityMatrix = {
    'INTJ': {
      'ENFP': 0.9, 'ENTP': 0.8, 'INFJ': 0.8, 'INFP': 0.7,
      'INTJ': 0.6, 'INTP': 0.7, 'ENTJ': 0.7, 'ENFJ': 0.6,
      'ISFP': 0.5, 'ISTP': 0.5, 'SFTP': 0.4, 'ISFJ': 0.4,
      'ESTJ': 0.4, 'ESFJ': 0.3, 'ESTP': 0.3, 'ESFP': 0.3,
    },
    'INTP': {
      'ENFJ': 0.9, 'ENTJ': 0.8, 'INFJ': 0.8, 'INTJ': 0.7,
      'INTP': 0.6, 'ENFP': 0.7, 'ENTP': 0.7, 'INFP': 0.6,
      'ISFP': 0.5, 'ISTP': 0.5, 'ISFJ': 0.4, 'ISTJ': 0.4,
      'ESTJ': 0.4, 'ESFJ': 0.3, 'ESTP': 0.3, 'ESFP': 0.3,
    },
    // ... 其他 MBTI 類型的兼容性映射
  };

  static double getCompatibilityScore(String type1, String type2) {
    return compatibilityMatrix[type1]?[type2] ?? 0.5;
  }
} 