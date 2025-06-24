import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../firebase_config.dart';
import '../models/user_model.dart';

/// 用戶服務
/// 處理用戶檔案的 CRUD 操作
class UserService {
  static FirebaseFirestore? get _firestore => FirebaseConfig.firestore;
  static CollectionReference? get _usersCollection => FirebaseConfig.usersCollection;
  static FirebaseStorage? get _storage => FirebaseConfig.storage;

  /// 創建用戶檔案
  static Future<void> createUserProfile(UserModel user) async {
    try {
      if (_usersCollection == null) {
        print('⚠️ Firebase 未初始化，用戶檔案將保存到本地');
        return;
      }

      await _usersCollection!.doc(user.uid).set(user.toJson());
      
      // 記錄分析事件
      await FirebaseConfig.logEvent('user_profile_created', {
        'user_id': user.uid,
        'age': user.age,
        'gender': user.gender,
        'location': user.location,
      });
      
      print('✅ 用戶檔案創建成功: ${user.uid}');
    } catch (e) {
      print('❌ 創建用戶檔案失敗: $e');
      // 不拋出錯誤，讓應用繼續運行
    }
  }

  /// 獲取用戶檔案
  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      if (_usersCollection == null) {
        print('⚠️ Firebase 未初始化，返回空用戶檔案');
        return null;
      }

      final doc = await _usersCollection!.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ 獲取用戶檔案失敗: $e');
      return null;
    }
  }

  /// 更新用戶檔案
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      if (_usersCollection == null) {
        print('⚠️ Firebase 未初始化，用戶檔案更新將保存到本地');
        return;
      }

      await _usersCollection!.doc(uid).update(data);
      
      // 記錄分析事件
      await FirebaseConfig.logEvent('user_profile_updated', {
        'user_id': uid,
        'fields_updated': data.keys.toList(),
      });
      
      print('✅ 用戶檔案更新成功: $uid');
    } catch (e) {
      print('❌ 更新用戶檔案失敗: $e');
      // 不拋出錯誤，讓應用繼續運行
    }
  }

  /// 檢查 Firebase 是否可用
  static bool get isFirebaseAvailable => FirebaseConfig.isAvailable;

  // 上傳用戶照片
  static Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      if (_storage == null) {
        throw Exception('Firebase Storage 未初始化');
      }
      
      final ref = _storage!.ref().child('profile_photos').child(uid).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // 更新用戶檔案中的照片 URL
      await updateUserProfile(uid, {'photoUrls': FieldValue.arrayUnion([downloadUrl])});
      
      // 記錄分析事件
      await FirebaseConfig.logEvent('profile_photo_uploaded', {
        'user_id': uid,
      });
      
      print('✅ 照片上傳成功: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ 照片上傳失敗: $e');
      throw Exception('照片上傳失敗: $e');
    }
  }

  // 刪除用戶照片
  static Future<void> deleteProfilePhoto(String uid, String photoUrl) async {
    try {
      if (_storage == null) {
        throw Exception('Firebase Storage 未初始化');
      }
      
      // 從 Storage 刪除照片
      final ref = _storage!.refFromURL(photoUrl);
      await ref.delete();
      
      // 從用戶檔案中移除照片 URL
      await updateUserProfile(uid, {'photoUrls': FieldValue.arrayRemove([photoUrl])});
      
      print('✅ 照片刪除成功: $photoUrl');
    } catch (e) {
      print('❌ 照片刪除失敗: $e');
      throw Exception('照片刪除失敗: $e');
    }
  }

  // 獲取推薦用戶（用於配對）
  static Future<List<UserModel>> getRecommendedUsers({
    required String currentUserId,
    int limit = 10,
    String? lastUserId,
  }) async {
    try {
      final currentUser = await getUserProfile(currentUserId);
      if (currentUser == null) {
        throw Exception('當前用戶不存在');
      }

      Query query = _firestore!.collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .where('isActive', isEqualTo: true)
          .limit(limit);

      // 基於年齡範圍篩選
      if (currentUser.ageRange != null) {
        query = query
            .where('age', isGreaterThanOrEqualTo: currentUser.ageRange!['min'])
            .where('age', isLessThanOrEqualTo: currentUser.ageRange!['max']);
      }

      // 基於性別偏好篩選
      if (currentUser.genderPreference != null && currentUser.genderPreference != 'all') {
        query = query.where('gender', isEqualTo: currentUser.genderPreference);
      }

      // 分頁處理
      if (lastUserId != null) {
        final lastDoc = await _firestore!.collection('users').doc(lastUserId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // 基於 MBTI 兼容性排序
      if (currentUser.mbtiType != null) {
        users.sort((a, b) {
          final compatibilityA = _calculateMBTICompatibility(currentUser.mbtiType!, a.mbtiType);
          final compatibilityB = _calculateMBTICompatibility(currentUser.mbtiType!, b.mbtiType);
          return compatibilityB.compareTo(compatibilityA);
        });
      }

      print('✅ 獲取推薦用戶成功: ${users.length} 個用戶');
      return users;
    } catch (e) {
      print('❌ 獲取推薦用戶失敗: $e');
      throw Exception('獲取推薦用戶失敗: $e');
    }
  }

  // 計算 MBTI 兼容性
  static double _calculateMBTICompatibility(String type1, String? type2) {
    if (type2 == null) return 0.5;
    if (type1 == type2) return 1.0;

    // 簡化的 MBTI 兼容性算法
    final compatibilityMatrix = {
      'ENFP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7, 'ENTP': 0.8},
      'ENFJ': {'INFP': 0.9, 'ISFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.7},
      'ENTP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFP': 0.8, 'INTP': 0.7},
      'ENTJ': {'INTP': 0.9, 'INFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.8},
      'INFP': {'ENFJ': 0.9, 'ENTJ': 0.8, 'INFJ': 0.8, 'ENFP': 0.7},
      'INFJ': {'ENTP': 0.8, 'ENFP': 0.8, 'INTJ': 0.7, 'INFP': 0.8},
      'INTP': {'ENTJ': 0.9, 'ENFJ': 0.7, 'ENTP': 0.7, 'INTJ': 0.8},
      'INTJ': {'ENFP': 0.9, 'ENTP': 0.9, 'INFJ': 0.7, 'INTP': 0.8},
      'ISFP': {'ENFJ': 0.8, 'ESFJ': 0.7, 'ISFJ': 0.7, 'ENFP': 0.7},
      'ISFJ': {'ESFP': 0.8, 'ENFP': 0.7, 'ISFP': 0.7, 'ESFJ': 0.8},
      'ISTP': {'ESFJ': 0.7, 'ENFJ': 0.6, 'ESTJ': 0.6, 'ENTJ': 0.6},
      'ISTJ': {'ESFP': 0.7, 'ISFP': 0.6, 'ESFJ': 0.8, 'ISFJ': 0.7},
      'ESFP': {'ISTJ': 0.7, 'ISFJ': 0.8, 'ISTP': 0.7, 'ESTP': 0.6},
      'ESFJ': {'ISFP': 0.7, 'ISTP': 0.7, 'ISTJ': 0.8, 'ISFJ': 0.8},
      'ESTP': {'ISFJ': 0.7, 'ESFJ': 0.6, 'ISTJ': 0.6, 'ESTJ': 0.7},
      'ESTJ': {'ISTP': 0.6, 'ISFP': 0.5, 'ESTP': 0.7, 'ESFP': 0.6},
    };

    return compatibilityMatrix[type1]?[type2] ?? 0.5;
  }

  // 記錄用戶互動（喜歡/不喜歡）
  static Future<void> recordUserInteraction({
    required String currentUserId,
    required String targetUserId,
    required bool isLike,
  }) async {
    try {
      final interactionData = {
        'currentUserId': currentUserId,
        'targetUserId': targetUserId,
        'isLike': isLike,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore!.collection('user_interactions').add(interactionData);

      // 檢查是否互相喜歡（配對成功）
      if (isLike) {
        final reverseInteraction = await _firestore!.collection('user_interactions')
            .where('currentUserId', isEqualTo: targetUserId)
            .where('targetUserId', isEqualTo: currentUserId)
            .where('isLike', isEqualTo: true)
            .get();

        if (reverseInteraction.docs.isNotEmpty) {
          // 創建配對
          await _createMatch(currentUserId, targetUserId);
        }
      }

      // 記錄分析事件
      await FirebaseConfig.logEvent('user_interaction', {
        'user_id': currentUserId,
        'target_user_id': targetUserId,
        'action': isLike ? 'like' : 'pass',
      });

      print('✅ 用戶互動記錄成功');
    } catch (e) {
      print('❌ 記錄用戶互動失敗: $e');
      throw Exception('記錄用戶互動失敗: $e');
    }
  }

  // 創建配對
  static Future<void> _createMatch(String user1Id, String user2Id) async {
    try {
      final matchData = {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'chatId': null, // 將在創建聊天時設置
      };

      final matchRef = await _firestore!.collection('matches').add(matchData);

      // 創建聊天室
      final chatData = {
        'participants': [user1Id, user2Id],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCounts': {
          user1Id: 0,
          user2Id: 0,
        },
        'isActive': true,
      };

      final chatRef = await _firestore!.collection('chats').add(chatData);

      // 更新配對記錄中的聊天 ID
      await matchRef.update({'chatId': chatRef.id});

      // 記錄分析事件
      await FirebaseConfig.logEvent('match_created', {
        'user1_id': user1Id,
        'user2_id': user2Id,
        'match_id': matchRef.id,
        'chat_id': chatRef.id,
      });

      print('✅ 配對創建成功: ${matchRef.id}');
    } catch (e) {
      print('❌ 創建配對失敗: $e');
      throw Exception('創建配對失敗: $e');
    }
  }

  // 獲取用戶的配對列表
  static Future<List<Map<String, dynamic>>> getUserMatches(String userId) async {
    try {
      final snapshot = await _firestore!.collection('matches')
          .where('user1Id', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final snapshot2 = await _firestore!.collection('matches')
          .where('user2Id', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final matches = <Map<String, dynamic>>[];
      
      for (final doc in [...snapshot.docs, ...snapshot2.docs]) {
        final data = doc.data();
        final otherUserId = data['user1Id'] == userId ? data['user2Id'] : data['user1Id'];
        final otherUser = await getUserProfile(otherUserId);
        
        if (otherUser != null) {
          matches.add({
            'matchId': doc.id,
            'chatId': data['chatId'],
            'otherUser': otherUser,
            'createdAt': data['createdAt'],
          });
        }
      }

      // 按創建時間排序
      matches.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      print('✅ 獲取用戶配對成功: ${matches.length} 個配對');
      return matches;
    } catch (e) {
      print('❌ 獲取用戶配對失敗: $e');
      throw Exception('獲取用戶配對失敗: $e');
    }
  }

  // 搜尋用戶
  static Future<List<UserModel>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
  }) async {
    try {
      // 基於名稱搜尋
      final nameQuery = _firestore!.collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .where('isActive', isEqualTo: true)
          .limit(limit);

      final snapshot = await nameQuery.get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) => user.uid != currentUserId)
          .toList();

      print('✅ 搜尋用戶成功: ${users.length} 個結果');
      return users;
    } catch (e) {
      print('❌ 搜尋用戶失敗: $e');
      throw Exception('搜尋用戶失敗: $e');
    }
  }

  // 舉報用戶
  static Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final reportData = {
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      await _firestore!.collection('reports').add(reportData);

      // 記錄分析事件
      await FirebaseConfig.logEvent('user_reported', {
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reason': reason,
      });

      print('✅ 用戶舉報提交成功');
    } catch (e) {
      print('❌ 提交用戶舉報失敗: $e');
      throw Exception('提交用戶舉報失敗: $e');
    }
  }

  // 封鎖用戶
  static Future<void> blockUser(String currentUserId, String blockedUserId) async {
    try {
      await _firestore!.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId])
      });

      // 記錄分析事件
      await FirebaseConfig.logEvent('user_blocked', {
        'user_id': currentUserId,
        'blocked_user_id': blockedUserId,
      });

      print('✅ 用戶封鎖成功');
    } catch (e) {
      print('❌ 封鎖用戶失敗: $e');
      throw Exception('封鎖用戶失敗: $e');
    }
  }

  // 解除封鎖用戶
  static Future<void> unblockUser(String currentUserId, String unblockedUserId) async {
    try {
      await _firestore!.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([unblockedUserId])
      });

      print('✅ 解除封鎖成功');
    } catch (e) {
      print('❌ 解除封鎖失敗: $e');
      throw Exception('解除封鎖失敗: $e');
    }
  }
} 