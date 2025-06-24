import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

// 關係追蹤服務提供者
final relationshipTrackingServiceProvider = Provider<RelationshipTrackingService>((ref) {
  return RelationshipTrackingService();
});

// 關係狀態枚舉
enum RelationshipStatus {
  matched,        // 剛配對
  chatting,       // 聊天中
  dating,         // 約會中
  exclusive,      // 專一關係
  serious,        // 認真交往
  engaged,        // 訂婚
  married,        // 結婚
  separated,      // 分居
  broken,         // 分手
}

// 里程碑類型
enum MilestoneType {
  firstMessage,     // 第一條消息
  firstCall,        // 第一次通話
  firstDate,        // 第一次約會
  firstKiss,        // 第一次親吻
  exclusive,        // 確定關係
  meetFamily,       // 見家長
  moveInTogether,   // 同居
  engagement,       // 訂婚
  marriage,         // 結婚
  anniversary,      // 週年紀念
  custom,           // 自定義
}

// 關係健康度指標
enum HealthIndicator {
  communication,    // 溝通質量
  trust,           // 信任度
  intimacy,        // 親密度
  compatibility,   // 兼容性
  support,         // 支持度
  growth,          // 成長性
  conflict,        // 衝突處理
  future,          // 未來規劃
}

// 關係記錄模型
class RelationshipRecord {
  final String id;
  final String userId;
  final String partnerId;
  final String partnerName;
  final RelationshipStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<RelationshipMilestone> milestones;
  final List<HealthAssessment> healthAssessments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RelationshipRecord({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.partnerName,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.milestones,
    required this.healthAssessments,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RelationshipRecord.fromJson(Map<String, dynamic> json) {
    return RelationshipRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      partnerId: json['partnerId'] ?? '',
      partnerName: json['partnerName'] ?? '',
      status: RelationshipStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RelationshipStatus.matched,
      ),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null 
          ? (json['endDate'] as Timestamp).toDate() 
          : null,
      milestones: (json['milestones'] as List<dynamic>? ?? [])
          .map((m) => RelationshipMilestone.fromJson(m as Map<String, dynamic>))
          .toList(),
      healthAssessments: (json['healthAssessments'] as List<dynamic>? ?? [])
          .map((h) => HealthAssessment.fromJson(h as Map<String, dynamic>))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'status': status.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'healthAssessments': healthAssessments.map((h) => h.toJson()).toList(),
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RelationshipRecord copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? partnerName,
    RelationshipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<RelationshipMilestone>? milestones,
    List<HealthAssessment>? healthAssessments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RelationshipRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      milestones: milestones ?? this.milestones,
      healthAssessments: healthAssessments ?? this.healthAssessments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 計算關係持續時間
  Duration get duration {
    final endTime = endDate ?? DateTime.now();
    return endTime.difference(startDate);
  }

  // 獲取最新健康評估
  HealthAssessment? get latestHealthAssessment {
    if (healthAssessments.isEmpty) return null;
    return healthAssessments.reduce((a, b) => 
        a.assessmentDate.isAfter(b.assessmentDate) ? a : b);
  }

  // 計算里程碑完成率
  double get milestoneCompletionRate {
    if (milestones.isEmpty) return 0.0;
    final completedCount = milestones.where((m) => m.isCompleted).length;
    return completedCount / milestones.length;
  }
}

// 關係里程碑模型
class RelationshipMilestone {
  final String id;
  final MilestoneType type;
  final String title;
  final String description;
  final DateTime? targetDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final bool isCustom;
  final double importance; // 0.0-1.0
  final Map<String, dynamic> metadata;

  const RelationshipMilestone({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.targetDate,
    this.completedDate,
    required this.isCompleted,
    required this.isCustom,
    required this.importance,
    required this.metadata,
  });

  factory RelationshipMilestone.fromJson(Map<String, dynamic> json) {
    return RelationshipMilestone(
      id: json['id'] ?? '',
      type: MilestoneType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MilestoneType.custom,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetDate: json['targetDate'] != null 
          ? (json['targetDate'] as Timestamp).toDate() 
          : null,
      completedDate: json['completedDate'] != null 
          ? (json['completedDate'] as Timestamp).toDate() 
          : null,
      isCompleted: json['isCompleted'] ?? false,
      isCustom: json['isCustom'] ?? false,
      importance: json['importance']?.toDouble() ?? 0.5,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'isCompleted': isCompleted,
      'isCustom': isCustom,
      'importance': importance,
      'metadata': metadata,
    };
  }

  RelationshipMilestone copyWith({
    String? id,
    MilestoneType? type,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? completedDate,
    bool? isCompleted,
    bool? isCustom,
    double? importance,
    Map<String, dynamic>? metadata,
  }) {
    return RelationshipMilestone(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isCustom: isCustom ?? this.isCustom,
      importance: importance ?? this.importance,
      metadata: metadata ?? this.metadata,
    );
  }
}

// 健康評估模型
class HealthAssessment {
  final String id;
  final DateTime assessmentDate;
  final Map<HealthIndicator, double> scores; // 0.0-10.0
  final double overallScore;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;
  final String? notes;
  final Map<String, dynamic> metadata;

  const HealthAssessment({
    required this.id,
    required this.assessmentDate,
    required this.scores,
    required this.overallScore,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    this.notes,
    required this.metadata,
  });

  factory HealthAssessment.fromJson(Map<String, dynamic> json) {
    final scoresMap = <HealthIndicator, double>{};
    final scoresJson = json['scores'] as Map<String, dynamic>? ?? {};
    
    for (final entry in scoresJson.entries) {
      final indicator = HealthIndicator.values.firstWhere(
        (e) => e.toString().split('.').last == entry.key,
        orElse: () => HealthIndicator.communication,
      );
      scoresMap[indicator] = entry.value?.toDouble() ?? 0.0;
    }

    return HealthAssessment(
      id: json['id'] ?? '',
      assessmentDate: (json['assessmentDate'] as Timestamp).toDate(),
      scores: scoresMap,
      overallScore: json['overallScore']?.toDouble() ?? 0.0,
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      notes: json['notes'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    final scoresJson = <String, double>{};
    for (final entry in scores.entries) {
      scoresJson[entry.key.toString().split('.').last] = entry.value;
    }

    return {
      'id': id,
      'assessmentDate': Timestamp.fromDate(assessmentDate),
      'scores': scoresJson,
      'overallScore': overallScore,
      'strengths': strengths,
      'improvements': improvements,
      'recommendations': recommendations,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

// 成功故事模型
class SuccessStory {
  final String id;
  final String userId;
  final String partnerId;
  final String title;
  final String story;
  final List<String> photos;
  final DateTime relationshipStart;
  final DateTime? relationshipEnd;
  final RelationshipStatus finalStatus;
  final List<String> tags;
  final bool isPublic;
  final int likes;
  final List<String> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SuccessStory({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.title,
    required this.story,
    required this.photos,
    required this.relationshipStart,
    this.relationshipEnd,
    required this.finalStatus,
    required this.tags,
    required this.isPublic,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SuccessStory.fromJson(Map<String, dynamic> json) {
    return SuccessStory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      partnerId: json['partnerId'] ?? '',
      title: json['title'] ?? '',
      story: json['story'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      relationshipStart: (json['relationshipStart'] as Timestamp).toDate(),
      relationshipEnd: json['relationshipEnd'] != null 
          ? (json['relationshipEnd'] as Timestamp).toDate() 
          : null,
      finalStatus: RelationshipStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['finalStatus'],
        orElse: () => RelationshipStatus.serious,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? false,
      likes: json['likes'] ?? 0,
      comments: List<String>.from(json['comments'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'title': title,
      'story': story,
      'photos': photos,
      'relationshipStart': Timestamp.fromDate(relationshipStart),
      'relationshipEnd': relationshipEnd != null ? Timestamp.fromDate(relationshipEnd!) : null,
      'finalStatus': finalStatus.toString().split('.').last,
      'tags': tags,
      'isPublic': isPublic,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

// 關係統計模型
class RelationshipStats {
  final int totalRelationships;
  final int activeRelationships;
  final int successfulRelationships;
  final double averageRelationshipDuration; // 天數
  final double successRate;
  final Map<RelationshipStatus, int> statusDistribution;
  final Map<MilestoneType, int> milestoneAchievements;
  final double averageHealthScore;
  final List<String> topStrengths;
  final List<String> commonChallenges;

  const RelationshipStats({
    required this.totalRelationships,
    required this.activeRelationships,
    required this.successfulRelationships,
    required this.averageRelationshipDuration,
    required this.successRate,
    required this.statusDistribution,
    required this.milestoneAchievements,
    required this.averageHealthScore,
    required this.topStrengths,
    required this.commonChallenges,
  });
}

// 關係追蹤服務
class RelationshipTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 創建新的關係記錄
  Future<RelationshipRecord> createRelationshipRecord({
    required String partnerId,
    required String partnerName,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final recordId = '${currentUserId}_$partnerId';
      final now = DateTime.now();

      // 創建初始里程碑
      final initialMilestones = _createInitialMilestones();

      final record = RelationshipRecord(
        id: recordId,
        userId: currentUserId,
        partnerId: partnerId,
        partnerName: partnerName,
        status: RelationshipStatus.matched,
        startDate: now,
        milestones: initialMilestones,
        healthAssessments: [],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('relationship_records')
          .doc(recordId)
          .set(record.toJson());

      print('關係記錄創建成功');
      return record;
    } catch (e) {
      print('創建關係記錄失敗: $e');
      throw Exception('創建關係記錄失敗: $e');
    }
  }

  // 更新關係狀態
  Future<void> updateRelationshipStatus(
    String relationshipId,
    RelationshipStatus newStatus,
  ) async {
    try {
      await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .update({
        'status': newStatus.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 如果關係結束，設置結束日期
      if (newStatus == RelationshipStatus.broken || 
          newStatus == RelationshipStatus.separated) {
        await _firestore
            .collection('relationship_records')
            .doc(relationshipId)
            .update({
          'endDate': Timestamp.fromDate(DateTime.now()),
        });
      }

      print('關係狀態更新成功');
    } catch (e) {
      print('更新關係狀態失敗: $e');
      throw Exception('更新關係狀態失敗: $e');
    }
  }

  // 添加里程碑
  Future<void> addMilestone(
    String relationshipId,
    RelationshipMilestone milestone,
  ) async {
    try {
      final recordDoc = await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .get();

      if (!recordDoc.exists) {
        throw Exception('關係記錄不存在');
      }

      final record = RelationshipRecord.fromJson(recordDoc.data()!);
      final updatedMilestones = [...record.milestones, milestone];

      await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .update({
        'milestones': updatedMilestones.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('里程碑添加成功');
    } catch (e) {
      print('添加里程碑失敗: $e');
      throw Exception('添加里程碑失敗: $e');
    }
  }

  // 完成里程碑
  Future<void> completeMilestone(
    String relationshipId,
    String milestoneId,
  ) async {
    try {
      final recordDoc = await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .get();

      if (!recordDoc.exists) {
        throw Exception('關係記錄不存在');
      }

      final record = RelationshipRecord.fromJson(recordDoc.data()!);
      final updatedMilestones = record.milestones.map((milestone) {
        if (milestone.id == milestoneId) {
          return milestone.copyWith(
            isCompleted: true,
            completedDate: DateTime.now(),
          );
        }
        return milestone;
      }).toList();

      await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .update({
        'milestones': updatedMilestones.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('里程碑完成成功');
    } catch (e) {
      print('完成里程碑失敗: $e');
      throw Exception('完成里程碑失敗: $e');
    }
  }

  // 添加健康評估
  Future<void> addHealthAssessment(
    String relationshipId,
    HealthAssessment assessment,
  ) async {
    try {
      final recordDoc = await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .get();

      if (!recordDoc.exists) {
        throw Exception('關係記錄不存在');
      }

      final record = RelationshipRecord.fromJson(recordDoc.data()!);
      final updatedAssessments = [...record.healthAssessments, assessment];

      await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .update({
        'healthAssessments': updatedAssessments.map((a) => a.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('健康評估添加成功');
    } catch (e) {
      print('添加健康評估失敗: $e');
      throw Exception('添加健康評估失敗: $e');
    }
  }

  // 獲取用戶的關係記錄
  Future<List<RelationshipRecord>> getUserRelationshipRecords({
    RelationshipStatus? status,
    int limit = 20,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      Query query = _firestore
          .collection('relationship_records')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RelationshipRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('獲取關係記錄失敗: $e');
      throw Exception('獲取關係記錄失敗: $e');
    }
  }

  // 創建成功故事
  Future<void> createSuccessStory(SuccessStory story) async {
    try {
      await _firestore
          .collection('success_stories')
          .doc(story.id)
          .set(story.toJson());

      print('成功故事創建成功');
    } catch (e) {
      print('創建成功故事失敗: $e');
      throw Exception('創建成功故事失敗: $e');
    }
  }

  // 獲取公開的成功故事
  Future<List<SuccessStory>> getPublicSuccessStories({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('success_stories')
          .where('isPublic', isEqualTo: true)
          .orderBy('likes', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SuccessStory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('獲取成功故事失敗: $e');
      throw Exception('獲取成功故事失敗: $e');
    }
  }

  // 計算關係統計
  Future<RelationshipStats> calculateRelationshipStats() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final records = await getUserRelationshipRecords(limit: 100);

      final totalRelationships = records.length;
      final activeRelationships = records
          .where((r) => r.status != RelationshipStatus.broken && 
                       r.status != RelationshipStatus.separated)
          .length;
      
      final successfulRelationships = records
          .where((r) => r.status == RelationshipStatus.married || 
                       r.status == RelationshipStatus.engaged ||
                       r.status == RelationshipStatus.serious)
          .length;

      final successRate = totalRelationships > 0 
          ? successfulRelationships / totalRelationships 
          : 0.0;

      // 計算平均關係持續時間
      final durations = records.map((r) => r.duration.inDays).toList();
      final averageDuration = durations.isNotEmpty 
          ? durations.reduce((a, b) => a + b) / durations.length 
          : 0.0;

      // 狀態分佈
      final statusDistribution = <RelationshipStatus, int>{};
      for (final status in RelationshipStatus.values) {
        statusDistribution[status] = records
            .where((r) => r.status == status)
            .length;
      }

      // 里程碑成就統計
      final milestoneAchievements = <MilestoneType, int>{};
      for (final type in MilestoneType.values) {
        milestoneAchievements[type] = records
            .expand((r) => r.milestones)
            .where((m) => m.type == type && m.isCompleted)
            .length;
      }

      // 平均健康分數
      final allHealthScores = records
          .expand((r) => r.healthAssessments)
          .map((a) => a.overallScore)
          .toList();
      final averageHealthScore = allHealthScores.isNotEmpty 
          ? allHealthScores.reduce((a, b) => a + b) / allHealthScores.length 
          : 0.0;

      // 常見優勢和挑戰
      final allStrengths = records
          .expand((r) => r.healthAssessments)
          .expand((a) => a.strengths)
          .toList();
      final allImprovements = records
          .expand((r) => r.healthAssessments)
          .expand((a) => a.improvements)
          .toList();

      final topStrengths = _getTopItems(allStrengths, 5);
      final commonChallenges = _getTopItems(allImprovements, 5);

      return RelationshipStats(
        totalRelationships: totalRelationships,
        activeRelationships: activeRelationships,
        successfulRelationships: successfulRelationships,
        averageRelationshipDuration: averageDuration,
        successRate: successRate,
        statusDistribution: statusDistribution,
        milestoneAchievements: milestoneAchievements,
        averageHealthScore: averageHealthScore,
        topStrengths: topStrengths,
        commonChallenges: commonChallenges,
      );
    } catch (e) {
      print('計算關係統計失敗: $e');
      throw Exception('計算關係統計失敗: $e');
    }
  }

  // 生成關係建議
  Future<List<String>> generateRelationshipAdvice(String relationshipId) async {
    try {
      final recordDoc = await _firestore
          .collection('relationship_records')
          .doc(relationshipId)
          .get();

      if (!recordDoc.exists) {
        throw Exception('關係記錄不存在');
      }

      final record = RelationshipRecord.fromJson(recordDoc.data()!);
      final advice = <String>[];

      // 基於關係狀態的建議
      switch (record.status) {
        case RelationshipStatus.matched:
        case RelationshipStatus.chatting:
          advice.addAll([
            '保持積極的溝通，分享日常生活',
            '安排第一次見面，選擇安全的公共場所',
            '保持真實的自己，不要過度包裝',
          ]);
          break;
        case RelationshipStatus.dating:
          advice.addAll([
            '嘗試不同類型的約會活動，增進了解',
            '開始討論彼此的價值觀和未來規劃',
            '建立更深層的情感連結',
          ]);
          break;
        case RelationshipStatus.exclusive:
        case RelationshipStatus.serious:
          advice.addAll([
            '定期進行關係健康檢查',
            '學習有效的衝突解決技巧',
            '規劃共同的未來目標',
          ]);
          break;
        default:
          advice.add('繼續努力維護這段美好的關係');
      }

      // 基於健康評估的建議
      final latestAssessment = record.latestHealthAssessment;
      if (latestAssessment != null) {
        // 找出分數較低的領域
        final lowScoreAreas = latestAssessment.scores.entries
            .where((entry) => entry.value < 6.0)
            .map((entry) => entry.key)
            .toList();

        for (final area in lowScoreAreas) {
          advice.add(_getImprovementAdvice(area));
        }
      }

      // 基於里程碑進度的建議
      final completionRate = record.milestoneCompletionRate;
      if (completionRate < 0.5) {
        advice.add('考慮設定一些關係目標，讓感情更有方向');
      }

      return advice.take(5).toList(); // 限制建議數量
    } catch (e) {
      print('生成關係建議失敗: $e');
      return ['繼續保持良好的溝通和理解'];
    }
  }

  // 創建初始里程碑
  List<RelationshipMilestone> _createInitialMilestones() {
    final now = DateTime.now();
    
    return [
      RelationshipMilestone(
        id: 'first_message_${now.millisecondsSinceEpoch}',
        type: MilestoneType.firstMessage,
        title: '第一條消息',
        description: '發送第一條消息，開始對話',
        targetDate: now.add(const Duration(hours: 1)),
        isCompleted: false,
        isCustom: false,
        importance: 0.8,
        metadata: {},
      ),
      RelationshipMilestone(
        id: 'first_call_${now.millisecondsSinceEpoch + 1}',
        type: MilestoneType.firstCall,
        title: '第一次通話',
        description: '進行第一次語音或視頻通話',
        targetDate: now.add(const Duration(days: 3)),
        isCompleted: false,
        isCustom: false,
        importance: 0.7,
        metadata: {},
      ),
      RelationshipMilestone(
        id: 'first_date_${now.millisecondsSinceEpoch + 2}',
        type: MilestoneType.firstDate,
        title: '第一次約會',
        description: '安排第一次線下見面',
        targetDate: now.add(const Duration(days: 7)),
        isCompleted: false,
        isCustom: false,
        importance: 0.9,
        metadata: {},
      ),
    ];
  }

  // 獲取最常見的項目
  List<String> _getTopItems(List<String> items, int count) {
    final frequency = <String, int>{};
    for (final item in items) {
      frequency[item] = (frequency[item] ?? 0) + 1;
    }

    final sortedItems = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedItems
        .take(count)
        .map((entry) => entry.key)
        .toList();
  }

  // 獲取改進建議
  String _getImprovementAdvice(HealthIndicator indicator) {
    switch (indicator) {
      case HealthIndicator.communication:
        return '加強溝通技巧，多傾聽對方的想法';
      case HealthIndicator.trust:
        return '建立更多信任，保持誠實和透明';
      case HealthIndicator.intimacy:
        return '增進親密關係，多表達愛意和關懷';
      case HealthIndicator.compatibility:
        return '尋找更多共同點，尊重彼此差異';
      case HealthIndicator.support:
        return '在困難時期互相支持，成為彼此的依靠';
      case HealthIndicator.growth:
        return '一起成長學習，設定共同目標';
      case HealthIndicator.conflict:
        return '學習健康的衝突解決方式';
      case HealthIndicator.future:
        return '討論未來規劃，確保目標一致';
    }
  }
}

// 關係追蹤頁面
class RelationshipTrackingPage extends ConsumerStatefulWidget {
  const RelationshipTrackingPage({super.key});

  @override
  ConsumerState<RelationshipTrackingPage> createState() => _RelationshipTrackingPageState();
}

class _RelationshipTrackingPageState extends ConsumerState<RelationshipTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RelationshipRecord> _relationships = [];
  List<SuccessStory> _successStories = [];
  RelationshipStats? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(relationshipTrackingServiceProvider);
      
      final relationships = await service.getUserRelationshipRecords();
      final successStories = await service.getPublicSuccessStories();
      final stats = await service.calculateRelationshipStats();

      setState(() {
        _relationships = relationships;
        _successStories = successStories;
        _stats = stats;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入數據失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '關係追蹤',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: '我的關係'),
            Tab(text: '里程碑'),
            Tab(text: '成功故事'),
            Tab(text: '統計分析'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRelationshipsTab(),
                _buildMilestonesTab(),
                _buildSuccessStoriesTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }

  Widget _buildRelationshipsTab() {
    if (_relationships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '還沒有關係記錄',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '開始配對來建立你的第一段關係',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE91E63),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _relationships.length,
        itemBuilder: (context, index) {
          final relationship = _relationships[index];
          return _buildRelationshipCard(relationship);
        },
      ),
    );
  }

  Widget _buildRelationshipCard(RelationshipRecord relationship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 關係標題和狀態
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(relationship.status),
                  child: Icon(
                    _getStatusIcon(relationship.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relationship.partnerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        _getStatusText(relationship.status),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(relationship.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${relationship.duration.inDays} 天',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 里程碑進度
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '里程碑進度',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(relationship.milestoneCompletionRate * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            LinearProgressIndicator(
              value: relationship.milestoneCompletionRate,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
            
            const SizedBox(height: 16),
            
            // 健康分數
            if (relationship.latestHealthAssessment != null) ...[
              Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '關係健康度',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${relationship.latestHealthAssessment!.overallScore.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getHealthScoreColor(relationship.latestHealthAssessment!.overallScore),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRelationshipDetails(relationship),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('查看詳情'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE91E63),
                      side: const BorderSide(color: Color(0xFFE91E63)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showHealthAssessment(relationship),
                    icon: const Icon(Icons.health_and_safety, size: 16),
                    label: const Text('健康檢查'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesTab() {
    if (_relationships.isEmpty) {
      return Center(
        child: Text(
          '沒有關係記錄',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    // 收集所有里程碑
    final allMilestones = _relationships
        .expand((r) => r.milestones.map((m) => MapEntry(r, m)))
        .toList();

    // 按完成狀態和重要性排序
    allMilestones.sort((a, b) {
      if (a.value.isCompleted != b.value.isCompleted) {
        return a.value.isCompleted ? 1 : -1; // 未完成的在前
      }
      return b.value.importance.compareTo(a.value.importance);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allMilestones.length,
      itemBuilder: (context, index) {
        final entry = allMilestones[index];
        final relationship = entry.key;
        final milestone = entry.value;
        
        return _buildMilestoneCard(relationship, milestone);
      },
    );
  }

  Widget _buildMilestoneCard(RelationshipRecord relationship, RelationshipMilestone milestone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: milestone.isCompleted ? Colors.green : Colors.orange,
          child: Icon(
            milestone.isCompleted ? Icons.check : Icons.schedule,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          milestone.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '與 ${relationship.partnerName}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              milestone.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (milestone.targetDate != null) ...[
              const SizedBox(height: 4),
              Text(
                milestone.isCompleted 
                    ? '完成於: ${_formatDate(milestone.completedDate!)}'
                    : '目標: ${_formatDate(milestone.targetDate!)}',
                style: TextStyle(
                  color: milestone.isCompleted ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: !milestone.isCompleted
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _completeMilestone(relationship.id, milestone.id),
              )
            : null,
      ),
    );
  }

  Widget _buildSuccessStoriesTab() {
    if (_successStories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '還沒有成功故事',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '分享你的愛情故事來激勵其他人',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showCreateStoryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('分享故事'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE91E63),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _successStories.length,
        itemBuilder: (context, index) {
          final story = _successStories[index];
          return _buildSuccessStoryCard(story);
        },
      ),
    );
  }

  Widget _buildSuccessStoryCard(SuccessStory story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 故事標題
            Text(
              story.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 關係狀態和持續時間
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(story.finalStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(story.finalStatus),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(story.finalStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_calculateDuration(story.relationshipStart, story.relationshipEnd)} 天',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 故事內容
            Text(
              story.story,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // 標籤
            if (story.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: story.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // 互動統計
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                const SizedBox(width: 4),
                Text(
                  '${story.likes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${story.comments.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(story.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 總覽統計
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '關係統計總覽',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '總關係數',
                          _stats!.totalRelationships.toString(),
                          Icons.favorite,
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '活躍關係',
                          _stats!.activeRelationships.toString(),
                          Icons.favorite_border,
                          Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '成功關係',
                          _stats!.successfulRelationships.toString(),
                          Icons.celebration,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '成功率',
                          '${(_stats!.successRate * 100).round()}%',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 平均持續時間和健康分數
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 32,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_stats!.averageRelationshipDuration.round()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                        Text(
                          '平均天數',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          size: 32,
                          color: Colors.purple[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stats!.averageHealthScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[600],
                          ),
                        ),
                        Text(
                          '健康分數',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 優勢和挑戰
          if (_stats!.topStrengths.isNotEmpty || _stats!.commonChallenges.isNotEmpty) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '關係洞察',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_stats!.topStrengths.isNotEmpty) ...[
                      Text(
                        '你的優勢',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_stats!.topStrengths.take(3).map((strength) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strength,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_stats!.commonChallenges.isNotEmpty) ...[
                      Text(
                        '改進空間',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_stats!.commonChallenges.take(3).map((challenge) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb, size: 16, color: Colors.orange[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  challenge,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.matched:
        return Colors.blue;
      case RelationshipStatus.chatting:
        return Colors.cyan;
      case RelationshipStatus.dating:
        return Colors.orange;
      case RelationshipStatus.exclusive:
        return Colors.purple;
      case RelationshipStatus.serious:
        return Colors.pink;
      case RelationshipStatus.engaged:
        return Colors.amber;
      case RelationshipStatus.married:
        return Colors.green;
      case RelationshipStatus.separated:
        return Colors.grey;
      case RelationshipStatus.broken:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.matched:
        return Icons.favorite_border;
      case RelationshipStatus.chatting:
        return Icons.chat;
      case RelationshipStatus.dating:
        return Icons.restaurant;
      case RelationshipStatus.exclusive:
        return Icons.favorite;
             case RelationshipStatus.serious:
         return Icons.home;
      case RelationshipStatus.engaged:
        return Icons.diamond;
      case RelationshipStatus.married:
        return Icons.celebration;
      case RelationshipStatus.separated:
        return Icons.pause;
      case RelationshipStatus.broken:
        return Icons.heart_broken;
    }
  }

  String _getStatusText(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.matched:
        return '剛配對';
      case RelationshipStatus.chatting:
        return '聊天中';
      case RelationshipStatus.dating:
        return '約會中';
      case RelationshipStatus.exclusive:
        return '專一關係';
      case RelationshipStatus.serious:
        return '認真交往';
      case RelationshipStatus.engaged:
        return '訂婚';
      case RelationshipStatus.married:
        return '結婚';
      case RelationshipStatus.separated:
        return '分居';
      case RelationshipStatus.broken:
        return '分手';
    }
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  int _calculateDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    return endTime.difference(start).inDays;
  }

  void _showRelationshipDetails(RelationshipRecord relationship) {
    // 實現關係詳情對話框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('與 ${relationship.partnerName} 的關係'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('狀態: ${_getStatusText(relationship.status)}'),
            Text('開始時間: ${_formatDate(relationship.startDate)}'),
            Text('持續時間: ${relationship.duration.inDays} 天'),
            Text('里程碑完成: ${(relationship.milestoneCompletionRate * 100).round()}%'),
            if (relationship.latestHealthAssessment != null)
              Text('健康分數: ${relationship.latestHealthAssessment!.overallScore.toStringAsFixed(1)}/10'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _showHealthAssessment(RelationshipRecord relationship) {
    // 實現健康評估對話框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('關係健康檢查'),
        content: const Text('這裡將實現健康評估功能'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 實現健康評估邏輯
            },
            child: const Text('開始評估'),
          ),
        ],
      ),
    );
  }

  void _showCreateStoryDialog() {
    // 實現創建成功故事對話框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享成功故事'),
        content: const Text('這裡將實現成功故事創建功能'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 實現故事創建邏輯
            },
            child: const Text('分享'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeMilestone(String relationshipId, String milestoneId) async {
    try {
      final service = ref.read(relationshipTrackingServiceProvider);
      await service.completeMilestone(relationshipId, milestoneId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('里程碑完成！'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadData(); // 重新載入數據
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('完成里程碑失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 