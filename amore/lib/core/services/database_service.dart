import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../features/auth/models/user_model.dart';
import '../../features/mbti/models/mbti_models.dart';
import '../../features/chat/models/chat_models.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 集合引用
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _mbtiResultsCollection => _firestore.collection('mbti_results');
  CollectionReference get _matchesCollection => _firestore.collection('matches');
  CollectionReference get _chatRoomsCollection => _firestore.collection('chat_rooms');
  CollectionReference get _messagesCollection => _firestore.collection('messages');

  // ==================== 用戶數據管理 ====================

  /// 創建或更新用戶檔案
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('保存用戶檔案失敗: $e');
    }
  }

  /// 獲取用戶檔案
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('獲取用戶檔案失敗: $e');
    }
  }

  /// 監聽用戶檔案變化
  Stream<UserModel?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// 更新用戶檔案字段
  Future<void> updateUserField(String userId, String field, dynamic value) async {
    try {
      await _usersCollection.doc(userId).update({field: value});
    } catch (e) {
      throw DatabaseException('更新用戶字段失敗: $e');
    }
  }

  /// 上傳用戶照片
  Future<String> uploadUserPhoto(String userId, File imageFile, {bool isMainPhoto = false}) async {
    try {
      final fileName = isMainPhoto 
          ? 'main_photo.jpg' 
          : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final ref = _storage.ref().child('users/$userId/photos/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw DatabaseException('上傳照片失敗: $e');
    }
  }

  /// 刪除用戶照片
  Future<void> deleteUserPhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw DatabaseException('刪除照片失敗: $e');
    }
  }

  // ==================== MBTI 數據管理 ====================

  /// 保存 MBTI 測試結果
  Future<void> saveMBTIResult(String userId, MBTIResult result) async {
    try {
      await _mbtiResultsCollection.doc(userId).set(result.toJson(), SetOptions(merge: true));
      
      // 同時更新用戶檔案中的 MBTI 類型
      await updateUserField(userId, 'mbtiType', result.personalityType);
    } catch (e) {
      throw DatabaseException('保存 MBTI 結果失敗: $e');
    }
  }

  /// 獲取 MBTI 測試結果
  Future<MBTIResult?> getMBTIResult(String userId) async {
    try {
      final doc = await _mbtiResultsCollection.doc(userId).get();
      if (doc.exists) {
        return MBTIResult.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('獲取 MBTI 結果失敗: $e');
    }
  }

  /// 保存 MBTI 測試會話
  Future<void> saveMBTITestSession(MBTITestSession session) async {
    try {
      await _firestore
          .collection('mbti_sessions')
          .doc(session.id)
          .set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('保存測試會話失敗: $e');
    }
  }

  // ==================== 匹配數據管理 ====================

  /// 創建匹配記錄
  Future<void> createMatch(Match match) async {
    try {
      await _matchesCollection.doc(match.id).set(match.toJson());
    } catch (e) {
      throw DatabaseException('創建匹配失敗: $e');
    }
  }

  /// 獲取用戶的匹配列表
  Future<List<Match>> getUserMatches(String userId) async {
    try {
      final query = await _matchesCollection
          .where('participants', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => Match.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('獲取匹配列表失敗: $e');
    }
  }

  /// 監聽用戶匹配
  Stream<List<Match>> watchUserMatches(String userId) {
    return _matchesCollection
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Match.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// 更新匹配狀態
  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    try {
      await _matchesCollection.doc(matchId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('更新匹配狀態失敗: $e');
    }
  }

  // ==================== 聊天數據管理 ====================

  /// 創建聊天室
  Future<void> createChatRoom(ChatRoom chatRoom) async {
    try {
      await _chatRoomsCollection.doc(chatRoom.id).set(chatRoom.toJson());
    } catch (e) {
      throw DatabaseException('創建聊天室失敗: $e');
    }
  }

  /// 獲取聊天室
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      final doc = await _chatRoomsCollection.doc(chatRoomId).get();
      if (doc.exists) {
        return ChatRoom.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('獲取聊天室失敗: $e');
    }
  }

  /// 獲取用戶的聊天室列表
  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    try {
      final query = await _chatRoomsCollection
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => ChatRoom.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('獲取聊天室列表失敗: $e');
    }
  }

  /// 監聽用戶聊天室
  Stream<List<ChatRoom>> watchUserChatRooms(String userId) {
    return _chatRoomsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// 發送消息
  Future<void> sendMessage(ChatMessage message) async {
    try {
      // 添加消息到消息集合
      await _messagesCollection.add(message.toJson());
      
      // 更新聊天室的最後消息信息
      await _chatRoomsCollection.doc(message.chatRoomId).update({
        'lastMessage': message.content,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': message.senderId,
      });
    } catch (e) {
      throw DatabaseException('發送消息失敗: $e');
    }
  }

  /// 獲取聊天室消息
  Stream<List<ChatMessage>> watchChatMessages(String chatRoomId) {
    return _messagesCollection
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// 標記消息為已讀
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      final unreadMessages = await _messagesCollection
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('senderId', isNotEqualTo: userId)
          .where('status', isEqualTo: MessageStatus.sent.toString().split('.').last)
          .get();
      
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString().split('.').last,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('標記消息已讀失敗: $e');
    }
  }

  // ==================== 搜索和推薦 ====================

  /// 根據條件搜索用戶
  Future<List<UserModel>> searchUsers({
    String? mbtiType,
    int? minAge,
    int? maxAge,
    String? location,
    List<String>? interests,
    int limit = 20,
  }) async {
    try {
      Query query = _usersCollection.where('isActive', isEqualTo: true);
      
      if (mbtiType != null) {
        query = query.where('mbtiType', isEqualTo: mbtiType);
      }
      
      if (minAge != null) {
        final maxBirthDate = DateTime.now().subtract(Duration(days: minAge * 365));
        query = query.where('birthDate', isLessThanOrEqualTo: Timestamp.fromDate(maxBirthDate));
      }
      
      if (maxAge != null) {
        final minBirthDate = DateTime.now().subtract(Duration(days: maxAge * 365));
        query = query.where('birthDate', isGreaterThanOrEqualTo: Timestamp.fromDate(minBirthDate));
      }
      
      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }
      
      final result = await query.limit(limit).get();
      
      List<UserModel> users = result.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // 如果有興趣篩選，在客戶端進行過濾
      if (interests != null && interests.isNotEmpty) {
        users = users.where((user) {
          return interests.any((interest) => user.profile?.interests.contains(interest) ?? false);
        }).toList();
      }
      
      return users;
    } catch (e) {
      throw DatabaseException('搜索用戶失敗: $e');
    }
  }

  /// 獲取推薦用戶
  Future<List<UserModel>> getRecommendedUsers(String userId, {int limit = 10}) async {
    try {
      final currentUser = await getUserProfile(userId);
      if (currentUser == null) {
        throw DatabaseException('找不到當前用戶');
      }
      
      // 獲取已匹配的用戶ID
      final matches = await getUserMatches(userId);
      final matchedUserIds = matches
          .expand((match) => match.participants)
          .where((id) => id != userId)
          .toSet();
      
      // 基於 MBTI 類型推薦
      final compatibleTypes = _getCompatibleMBTITypes(currentUser.mbtiType);
      
      Query query = _usersCollection
          .where('isActive', isEqualTo: true)
          .where('id', isNotEqualTo: userId);
      
      if (compatibleTypes.isNotEmpty) {
        query = query.where('mbtiType', whereIn: compatibleTypes);
      }
      
      final result = await query.limit(limit * 2).get(); // 獲取更多以便過濾
      
      List<UserModel> users = result.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) => !matchedUserIds.contains(user.id))
          .take(limit)
          .toList();
      
      return users;
    } catch (e) {
      throw DatabaseException('獲取推薦用戶失敗: $e');
    }
  }

  /// 獲取兼容的 MBTI 類型
  List<String> _getCompatibleMBTITypes(String? mbtiType) {
    if (mbtiType == null) return [];
    
    // 簡化的兼容性邏輯
    final compatibilityMap = {
      'INTJ': ['ENFP', 'ENTP', 'INFJ', 'INFP'],
      'INTP': ['ENFJ', 'ENTJ', 'INFJ', 'INFP'],
      'ENTJ': ['INFP', 'INTP', 'ENFP', 'ENTP'],
      'ENTP': ['INFJ', 'INTJ', 'ENFJ', 'ENTJ'],
      'INFJ': ['ENFP', 'ENTP', 'INFP', 'INTP'],
      'INFP': ['ENFJ', 'ENTJ', 'INFJ', 'INTJ'],
      'ENFJ': ['INFP', 'INTP', 'ENFP', 'ENTP'],
      'ENFP': ['INFJ', 'INTJ', 'ENFJ', 'ENTJ'],
      'ISTJ': ['ESFP', 'ESTP', 'ISFJ', 'ISFP'],
      'ISFJ': ['ESFP', 'ESTP', 'ISTJ', 'ISTP'],
      'ESTJ': ['ISFP', 'ISTP', 'ESFJ', 'ESFP'],
      'ESFJ': ['ISFP', 'ISTP', 'ESTJ', 'ESTP'],
      'ISTP': ['ESFJ', 'ESTJ', 'ISFJ', 'ISFP'],
      'ISFP': ['ESFJ', 'ESTJ', 'ISTP', 'ISTJ'],
      'ESTP': ['ISFJ', 'ISTJ', 'ESFJ', 'ESFP'],
      'ESFP': ['ISFJ', 'ISTJ', 'ESTP', 'ESTJ'],
    };
    
    return compatibilityMap[mbtiType] ?? [];
  }

  // ==================== 數據統計 ====================

  /// 獲取用戶統計信息
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final matches = await getUserMatches(userId);
      final chatRooms = await getUserChatRooms(userId);
      
      return {
        'totalMatches': matches.length,
        'activeChats': chatRooms.where((room) => room.lastMessageAt != null).length,
        'mbtiTestCompleted': await getMBTIResult(userId) != null,
        'profileCompleteness': await _calculateProfileCompleteness(userId),
      };
    } catch (e) {
      throw DatabaseException('獲取用戶統計失敗: $e');
    }
  }

  /// 計算檔案完整度
  Future<double> _calculateProfileCompleteness(String userId) async {
    final user = await getUserProfile(userId);
    if (user == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 10;
    
    if (user.profile?.firstName.isNotEmpty == true) completedFields++;
    if (user.profile?.lastName.isNotEmpty == true) completedFields++;
    if (user.profile?.bio.isNotEmpty == true) completedFields++;
    if (user.profile?.photos.isNotEmpty == true) completedFields++;
    if (user.profile?.interests.isNotEmpty == true) completedFields++;
    if (user.profile?.occupation.isNotEmpty == true) completedFields++;
    if (user.profile?.education.isNotEmpty == true) completedFields++;
    if (user.profile?.height != null) completedFields++;
    if (user.profile?.location.isNotEmpty == true) completedFields++;
    if (user.mbtiType?.isNotEmpty == true) completedFields++;
    
    return completedFields / totalFields;
  }

  // ==================== 批量操作 ====================

  /// 批量更新用戶數據
  Future<void> batchUpdateUsers(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();
      
      for (final update in updates) {
        final userId = update['userId'] as String;
        final data = update['data'] as Map<String, dynamic>;
        batch.update(_usersCollection.doc(userId), data);
      }
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('批量更新失敗: $e');
    }
  }

  /// 清理過期數據
  Future<void> cleanupExpiredData() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // 清理過期的測試會話
      final expiredSessions = await _firestore
          .collection('mbti_sessions')
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      
      final batch = _firestore.batch();
      for (final doc in expiredSessions.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('清理過期數據失敗: $e');
    }
  }
}

/// 數據庫異常類
class DatabaseException implements Exception {
  final String message;
  
  DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
} 