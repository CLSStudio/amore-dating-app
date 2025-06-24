import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/interaction_models.dart';

class SafeInteractionService {
  static final SafeInteractionService _instance = SafeInteractionService._internal();
  factory SafeInteractionService() => _instance;
  SafeInteractionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 常數設定
  static const int maxDailyInvitations = 10;
  static const int cooldownHours = 24;
  static const int invitationExpiryHours = 72;

  // ==================== 階段1: 公開互動 ====================

  /// 發送點讚
  Future<bool> sendLike({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
    required String toUserId,
    required String postId,
  }) async {
    try {
      final interaction = InteractionRecord(
        id: _generateId(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserAvatar: fromUserAvatar,
        toUserId: toUserId,
        postId: postId,
        type: InteractionType.like,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('interactions')
          .doc(interaction.id)
          .set(interaction.toJson());

      // 更新貼文的點讚計數
      await _updatePostLikeCount(postId, increment: true);

      return true;
    } catch (e) {
      debugPrint('發送點讚失敗: $e');
      return false;
    }
  }

  /// 取消點讚
  Future<bool> removeLike({
    required String fromUserId,
    required String postId,
  }) async {
    try {
      // 查找並刪除點讚記錄
      final query = await _firestore
          .collection('interactions')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('postId', isEqualTo: postId)
          .where('type', isEqualTo: 'like')
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      // 更新貼文的點讚計數
      await _updatePostLikeCount(postId, increment: false);

      return true;
    } catch (e) {
      debugPrint('取消點讚失敗: $e');
      return false;
    }
  }

  /// 發送評論
  Future<bool> sendComment({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
    required String toUserId,
    required String postId,
    required String content,
  }) async {
    try {
      final interaction = InteractionRecord(
        id: _generateId(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserAvatar: fromUserAvatar,
        toUserId: toUserId,
        postId: postId,
        type: InteractionType.comment,
        content: content,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('interactions')
          .doc(interaction.id)
          .set(interaction.toJson());

      // 更新貼文的評論計數
      await _updatePostCommentCount(postId, increment: true);

      return true;
    } catch (e) {
      debugPrint('發送評論失敗: $e');
      return false;
    }
  }

  /// 發送表情符號反應
  Future<bool> sendEmojiReaction({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
    required String toUserId,
    required String postId,
    required String emoji,
  }) async {
    try {
      final interaction = InteractionRecord(
        id: _generateId(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserAvatar: fromUserAvatar,
        toUserId: toUserId,
        postId: postId,
        type: InteractionType.emoji,
        content: emoji,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('interactions')
          .doc(interaction.id)
          .set(interaction.toJson());

      return true;
    } catch (e) {
      debugPrint('發送表情符號失敗: $e');
      return false;
    }
  }

  // ==================== 階段2: 聊天邀請 ====================

  /// 檢查用戶是否可以發送聊天邀請
  Future<Map<String, dynamic>> checkChatInvitationEligibility({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      // 檢查用戶統計
      final stats = await getUserInteractionStats(fromUserId);
      
      // 檢查每日限制
      if (stats.hasReachedDailyLimit) {
        return {
          'canInvite': false,
          'reason': 'daily_limit_reached',
          'message': '今日聊天邀請已達上限（${maxDailyInvitations}次），請明天再試',
        };
      }

      // 檢查冷卻期
      if (stats.isInCooldown(toUserId)) {
        return {
          'canInvite': false,
          'reason': 'cooldown_period',
          'message': '該用戶最近拒絕了您的邀請，請24小時後再試',
        };
      }

      // 檢查是否已有待處理的邀請
      final existingInvitation = await _getExistingInvitation(fromUserId, toUserId);
      if (existingInvitation != null && existingInvitation.isActive) {
        return {
          'canInvite': false,
          'reason': 'existing_invitation',
          'message': '您已向該用戶發送過邀請，請等待回應',
        };
      }

      return {
        'canInvite': true,
        'reason': 'eligible',
        'message': '可以發送聊天邀請',
      };
    } catch (e) {
      debugPrint('檢查邀請資格失敗: $e');
      return {
        'canInvite': false,
        'reason': 'error',
        'message': '檢查失敗，請稍後再試',
      };
    }
  }

  /// 發送聊天邀請
  Future<bool> sendChatInvitation({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
    required String toUserId,
    required String reason,
    String? message,
    String? relatedPostId,
  }) async {
    try {
      // 檢查資格
      final eligibility = await checkChatInvitationEligibility(
        fromUserId: fromUserId,
        toUserId: toUserId,
      );

      if (!eligibility['canInvite']) {
        return false;
      }

      final invitation = ChatInvitation(
        id: _generateId(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserAvatar: fromUserAvatar,
        toUserId: toUserId,
        message: message,
        reason: reason,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: invitationExpiryHours)),
        status: ChatInvitationStatus.pending,
        relatedPostId: relatedPostId,
      );

      await _firestore
          .collection('chat_invitations')
          .doc(invitation.id)
          .set(invitation.toJson());

      // 更新發送者統計
      await _updateUserStats(fromUserId, inviteSent: true);

      // 發送通知
      await _sendInvitationNotification(invitation);

      return true;
    } catch (e) {
      debugPrint('發送聊天邀請失敗: $e');
      return false;
    }
  }

  /// 回應聊天邀請
  Future<bool> respondToChatInvitation({
    required String invitationId,
    required bool accept,
    String? responseMessage,
  }) async {
    try {
      final doc = await _firestore
          .collection('chat_invitations')
          .doc(invitationId)
          .get();

      if (!doc.exists) return false;

      final invitation = ChatInvitation.fromJson(doc.data()!);
      
      // 檢查邀請是否仍然有效
      if (!invitation.isActive) return false;

      final newStatus = accept 
          ? ChatInvitationStatus.accepted 
          : ChatInvitationStatus.declined;

      await doc.reference.update({
        'status': newStatus.toString().split('.').last,
        'responseMessage': responseMessage,
        'respondedAt': DateTime.now().toIso8601String(),
      });

      if (accept) {
        // 接受邀請，創建聊天室
        await _createChatRoom(invitation);
      } else {
        // 拒絕邀請，添加到發送者的冷卻列表
        await _addToCooldownList(invitation.fromUserId, invitation.toUserId);
      }

      // 發送回應通知
      await _sendResponseNotification(invitation, accept, responseMessage);

      return true;
    } catch (e) {
      debugPrint('回應聊天邀請失敗: $e');
      return false;
    }
  }

  // ==================== 階段3: 私人聊天 ====================

  /// 檢查用戶是否可以私聊
  Future<bool> canPrivateChat(String userId1, String userId2) async {
    try {
      // 檢查是否有已接受的聊天邀請
      final query = await _firestore
          .collection('chat_invitations')
          .where('status', isEqualTo: 'accepted')
          .get();

      for (var doc in query.docs) {
        final invitation = ChatInvitation.fromJson(doc.data());
        if ((invitation.fromUserId == userId1 && invitation.toUserId == userId2) ||
            (invitation.fromUserId == userId2 && invitation.toUserId == userId1)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('檢查私聊權限失敗: $e');
      return false;
    }
  }

  /// 創建聊天室
  Future<String?> _createChatRoom(ChatInvitation invitation) async {
    try {
      final chatRoomId = _generateChatRoomId(invitation.fromUserId, invitation.toUserId);
      
      await _firestore.collection('chat_rooms').doc(chatRoomId).set({
        'id': chatRoomId,
        'participants': [invitation.fromUserId, invitation.toUserId],
        'createdAt': DateTime.now().toIso8601String(),
        'lastActivity': DateTime.now().toIso8601String(),
        'invitationId': invitation.id,
        'isActive': true,
      });

      return chatRoomId;
    } catch (e) {
      debugPrint('創建聊天室失敗: $e');
      return null;
    }
  }

  // ==================== 輔助方法 ====================

  /// 獲取用戶互動統計
  Future<UserInteractionStats> getUserInteractionStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_interaction_stats')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserInteractionStats.fromJson(doc.data()!);
      } else {
        // 創建默認統計
        final stats = UserInteractionStats(
          userId: userId,
          dailyInvitesSent: 0,
          dailyInvitesReceived: 0,
          lastInviteSent: DateTime.now().subtract(Duration(days: 1)),
          recentDeclinedUsers: [],
          totalInteractions: 0,
          responseRate: 0.0,
        );

        await _firestore
            .collection('user_interaction_stats')
            .doc(userId)
            .set(stats.toJson());

        return stats;
      }
    } catch (e) {
      debugPrint('獲取用戶統計失敗: $e');
      return UserInteractionStats(
        userId: userId,
        dailyInvitesSent: 0,
        dailyInvitesReceived: 0,
        lastInviteSent: DateTime.now().subtract(Duration(days: 1)),
        recentDeclinedUsers: [],
        totalInteractions: 0,
        responseRate: 0.0,
      );
    }
  }

  /// 獲取現有邀請
  Future<ChatInvitation?> _getExistingInvitation(String fromUserId, String toUserId) async {
    try {
      final query = await _firestore
          .collection('chat_invitations')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ChatInvitation.fromJson(query.docs.first.data());
      }

      return null;
    } catch (e) {
      debugPrint('獲取現有邀請失敗: $e');
      return null;
    }
  }

  /// 更新用戶統計
  Future<void> _updateUserStats(String userId, {bool inviteSent = false}) async {
    try {
      final doc = await _firestore
          .collection('user_interaction_stats')
          .doc(userId)
          .get();

      if (doc.exists) {
        final stats = UserInteractionStats.fromJson(doc.data()!);
        
        // 檢查是否是新的一天
        final now = DateTime.now();
        final lastInvite = stats.lastInviteSent;
        final isNewDay = now.day != lastInvite.day || 
                        now.month != lastInvite.month || 
                        now.year != lastInvite.year;

        await doc.reference.update({
          'dailyInvitesSent': isNewDay ? 1 : stats.dailyInvitesSent + 1,
          'lastInviteSent': now.toIso8601String(),
          'totalInteractions': stats.totalInteractions + 1,
        });
      }
    } catch (e) {
      debugPrint('更新用戶統計失敗: $e');
    }
  }

  /// 添加到冷卻列表
  Future<void> _addToCooldownList(String fromUserId, String toUserId) async {
    try {
      final doc = await _firestore
          .collection('user_interaction_stats')
          .doc(fromUserId)
          .get();

      if (doc.exists) {
        final stats = UserInteractionStats.fromJson(doc.data()!);
        final updatedDeclinedUsers = List<String>.from(stats.recentDeclinedUsers);
        
        if (!updatedDeclinedUsers.contains(toUserId)) {
          updatedDeclinedUsers.add(toUserId);
          
          // 限制列表大小
          if (updatedDeclinedUsers.length > 50) {
            updatedDeclinedUsers.removeAt(0);
          }
        }

        await doc.reference.update({
          'recentDeclinedUsers': updatedDeclinedUsers,
        });

        // 24小時後自動移除
        Future.delayed(Duration(hours: cooldownHours), () async {
          try {
            final latestDoc = await _firestore
                .collection('user_interaction_stats')
                .doc(fromUserId)
                .get();
            
            if (latestDoc.exists) {
              final latestStats = UserInteractionStats.fromJson(latestDoc.data()!);
              final filteredList = latestStats.recentDeclinedUsers
                  .where((id) => id != toUserId)
                  .toList();
              
              await latestDoc.reference.update({
                'recentDeclinedUsers': filteredList,
              });
            }
          } catch (e) {
            debugPrint('移除冷卻用戶失敗: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('添加冷卻用戶失敗: $e');
    }
  }

  /// 更新貼文點讚計數
  Future<void> _updatePostLikeCount(String postId, {required bool increment}) async {
    try {
      await _firestore.collection('social_posts').doc(postId).update({
        'likeCount': FieldValue.increment(increment ? 1 : -1),
      });
    } catch (e) {
      debugPrint('更新點讚計數失敗: $e');
    }
  }

  /// 更新貼文評論計數
  Future<void> _updatePostCommentCount(String postId, {required bool increment}) async {
    try {
      await _firestore.collection('social_posts').doc(postId).update({
        'commentCount': FieldValue.increment(increment ? 1 : -1),
      });
    } catch (e) {
      debugPrint('更新評論計數失敗: $e');
    }
  }

  /// 發送邀請通知
  Future<void> _sendInvitationNotification(ChatInvitation invitation) async {
    // TODO: 實現推送通知
    debugPrint('發送邀請通知: ${invitation.fromUserName} -> ${invitation.toUserId}');
  }

  /// 發送回應通知
  Future<void> _sendResponseNotification(
    ChatInvitation invitation, 
    bool accepted, 
    String? responseMessage
  ) async {
    // TODO: 實現推送通知
    debugPrint('發送回應通知: ${accepted ? "接受" : "拒絕"} -> ${invitation.fromUserId}');
  }

  /// 生成唯一ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  /// 生成聊天室ID
  String _generateChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  // ==================== 查詢方法 ====================

  /// 獲取用戶的聊天邀請列表
  Future<List<ChatInvitation>> getChatInvitations(String userId) async {
    try {
      final query = await _firestore
          .collection('chat_invitations')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => ChatInvitation.fromJson(doc.data()))
          .where((invitation) => invitation.isActive)
          .toList();
    } catch (e) {
      debugPrint('獲取聊天邀請失敗: $e');
      return [];
    }
  }

  /// 獲取貼文的互動記錄
  Future<List<InteractionRecord>> getPostInteractions(String postId) async {
    try {
      final query = await _firestore
          .collection('interactions')
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => InteractionRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('獲取貼文互動失敗: $e');
      return [];
    }
  }

  /// 檢查用戶是否已點讚貼文
  Future<bool> hasUserLikedPost(String userId, String postId) async {
    try {
      final query = await _firestore
          .collection('interactions')
          .where('fromUserId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .where('type', isEqualTo: 'like')
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('檢查點讚狀態失敗: $e');
      return false;
    }
  }
} 