import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 安全服務提供者
final safetyServiceProvider = Provider<SafetyService>((ref) {
  return SafetyService();
});

// 舉報類型枚舉
enum ReportType {
  inappropriateContent,
  harassment,
  spam,
  fakeProfile,
  underage,
  violence,
  other,
}

// 舉報數據模型
class ReportData {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportType type;
  final String description;
  final DateTime createdAt;
  final String? chatId;
  final String? messageId;
  final ReportStatus status;

  ReportData({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.type,
    required this.description,
    required this.createdAt,
    this.chatId,
    this.messageId,
    this.status = ReportStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'type': type.toString().split('.').last,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'chatId': chatId,
      'messageId': messageId,
      'status': status.toString().split('.').last,
    };
  }

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      id: map['id'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ReportType.other,
      ),
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      chatId: map['chatId'],
      messageId: map['messageId'],
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }
}

// 舉報狀態枚舉
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed,
}

// 封鎖數據模型
class BlockData {
  final String id;
  final String blockerId;
  final String blockedUserId;
  final DateTime createdAt;
  final String? reason;

  BlockData({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    required this.createdAt,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'reason': reason,
    };
  }

  factory BlockData.fromMap(Map<String, dynamic> map) {
    return BlockData(
      id: map['id'] ?? '',
      blockerId: map['blockerId'] ?? '',
      blockedUserId: map['blockedUserId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reason: map['reason'],
    );
  }
}

class SafetyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 舉報用戶
  static Future<void> reportUser({
    required String reportedUserId,
    required ReportType type,
    required String description,
    String? chatId,
    String? messageId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      final reportId = DateTime.now().millisecondsSinceEpoch.toString();
      final report = ReportData(
        id: reportId,
        reporterId: currentUser.uid,
        reportedUserId: reportedUserId,
        type: type,
        description: description,
        createdAt: DateTime.now(),
        chatId: chatId,
        messageId: messageId,
      );

      await _firestore
          .collection('reports')
          .doc(reportId)
          .set(report.toMap());

      // 記錄舉報統計
      await _updateReportStatistics(reportedUserId);
    } catch (e) {
      throw Exception('舉報失敗: $e');
    }
  }

  /// 封鎖用戶
  static Future<void> blockUser({
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      final blockId = '${currentUser.uid}_$blockedUserId';
      final block = BlockData(
        id: blockId,
        blockerId: currentUser.uid,
        blockedUserId: blockedUserId,
        createdAt: DateTime.now(),
        reason: reason,
      );

      await _firestore
          .collection('blocks')
          .doc(blockId)
          .set(block.toMap());

      // 從匹配列表中移除
      await _removeFromMatches(currentUser.uid, blockedUserId);
    } catch (e) {
      throw Exception('封鎖失敗: $e');
    }
  }

  /// 解除封鎖用戶
  static Future<void> unblockUser(String blockedUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('用戶未登入');
      }

      final blockId = '${currentUser.uid}_$blockedUserId';
      await _firestore
          .collection('blocks')
          .doc(blockId)
          .delete();
    } catch (e) {
      throw Exception('解除封鎖失敗: $e');
    }
  }

  /// 檢查是否已封鎖用戶
  static Future<bool> isUserBlocked(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final blockId = '${currentUser.uid}_$userId';
      final doc = await _firestore
          .collection('blocks')
          .doc(blockId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// 檢查是否被用戶封鎖
  static Future<bool> isBlockedByUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final blockId = '${userId}_${currentUser.uid}';
      final doc = await _firestore
          .collection('blocks')
          .doc(blockId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// 獲取封鎖列表
  static Future<List<String>> getBlockedUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs
          .map((doc) => BlockData.fromMap(doc.data()).blockedUserId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 檢查消息內容安全性
  static Future<bool> isMessageSafe(String content) async {
    try {
      // 基本關鍵詞過濾
      final inappropriateWords = [
        // 這裡可以添加不當詞彙列表
        '騙子', '詐騙', '轉帳', '匯款', '借錢',
      ];

      final lowerContent = content.toLowerCase();
      for (final word in inappropriateWords) {
        if (lowerContent.contains(word.toLowerCase())) {
          return false;
        }
      }

      // TODO: 集成 AI 內容審核服務
      // - 檢測不當語言
      // - 檢測詐騙內容
      // - 檢測騷擾內容

      return true;
    } catch (e) {
      // 如果檢查失敗，默認允許
      return true;
    }
  }

  /// 檢查照片安全性
  static Future<bool> isPhotoSafe(String photoUrl) async {
    try {
      // TODO: 集成 AI 圖片審核服務
      // - 檢測不當圖片
      // - 檢測暴力內容
      // - 檢測虛假圖片

      return true;
    } catch (e) {
      // 如果檢查失敗，默認允許
      return true;
    }
  }

  /// 獲取用戶安全評分
  static Future<double> getUserSafetyScore(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_safety')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['safetyScore'] ?? 1.0).toDouble();
      }

      return 1.0; // 默認安全評分
    } catch (e) {
      return 1.0;
    }
  }

  /// 記錄可疑行為
  static Future<void> logSuspiciousActivity({
    required String userId,
    required String activityType,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _firestore
          .collection('suspicious_activities')
          .add({
        'userId': userId,
        'activityType': activityType,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 更新用戶安全評分
      await _updateUserSafetyScore(userId, activityType);
    } catch (e) {
      // 記錄失敗不影響主要功能
    }
  }

  /// 獲取舉報類型的中文描述
  static String getReportTypeDescription(ReportType type) {
    switch (type) {
      case ReportType.inappropriateContent:
        return '不當內容';
      case ReportType.harassment:
        return '騷擾行為';
      case ReportType.spam:
        return '垃圾信息';
      case ReportType.fakeProfile:
        return '虛假檔案';
      case ReportType.underage:
        return '未成年用戶';
      case ReportType.violence:
        return '暴力威脅';
      case ReportType.other:
        return '其他';
    }
  }

  /// 獲取所有舉報類型
  static List<ReportType> getAllReportTypes() {
    return ReportType.values;
  }

  /// 更新舉報統計
  static Future<void> _updateReportStatistics(String reportedUserId) async {
    try {
      final statsRef = _firestore
          .collection('user_safety')
          .doc(reportedUserId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(statsRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final reportCount = (data['reportCount'] ?? 0) + 1;
          final safetyScore = _calculateSafetyScore(reportCount);
          
          transaction.update(statsRef, {
            'reportCount': reportCount,
            'safetyScore': safetyScore,
            'lastReportedAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(statsRef, {
            'reportCount': 1,
            'safetyScore': 0.9,
            'lastReportedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      // 統計更新失敗不影響主要功能
    }
  }

  /// 計算安全評分
  static double _calculateSafetyScore(int reportCount) {
    if (reportCount == 0) return 1.0;
    if (reportCount <= 2) return 0.9;
    if (reportCount <= 5) return 0.7;
    if (reportCount <= 10) return 0.5;
    return 0.3;
  }

  /// 從匹配列表中移除
  static Future<void> _removeFromMatches(String userId1, String userId2) async {
    try {
      // 移除雙向匹配
      final batch = _firestore.batch();
      
      final match1Ref = _firestore
          .collection('matches')
          .doc('${userId1}_$userId2');
      
      final match2Ref = _firestore
          .collection('matches')
          .doc('${userId2}_$userId1');
      
      batch.delete(match1Ref);
      batch.delete(match2Ref);
      
      await batch.commit();
    } catch (e) {
      // 移除匹配失敗不影響封鎖功能
    }
  }

  /// 更新用戶安全評分
  static Future<void> _updateUserSafetyScore(String userId, String activityType) async {
    try {
      final statsRef = _firestore
          .collection('user_safety')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(statsRef);
        
        double currentScore = 1.0;
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          currentScore = (data['safetyScore'] ?? 1.0).toDouble();
        }

        // 根據活動類型調整評分
        double adjustment = 0.0;
        switch (activityType) {
          case 'rapid_messaging':
            adjustment = -0.05;
            break;
          case 'inappropriate_language':
            adjustment = -0.1;
            break;
          case 'suspicious_photo':
            adjustment = -0.15;
            break;
          default:
            adjustment = -0.02;
        }

        final newScore = (currentScore + adjustment).clamp(0.0, 1.0);
        
        transaction.set(statsRef, {
          'safetyScore': newScore,
          'lastActivityAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      // 評分更新失敗不影響主要功能
    }
  }
}

/// 安全服務異常
class SafetyException implements Exception {
  final String message;
  final String? code;

  SafetyException(this.message, {this.code});

  @override
  String toString() => 'SafetyException: $message';
} 