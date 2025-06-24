import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/feed_models.dart';

// ================== 社交動態服務 ==================

final feedServiceProvider = Provider<FeedService>((ref) => FeedService());

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ================== 動態發布功能 ==================

  /// 📱 發布新動態
  Future<String> createPost({
    String? textContent,
    List<File>? mediaFiles,
    List<String>? tags,
    String? location,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      // 獲取用戶資料
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) throw Exception('用戶資料不存在');
      
      final userData = userDoc.data()!;

      // 上傳媒體文件
      List<MediaContent> mediaContent = [];
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        mediaContent = await _uploadMediaFiles(mediaFiles);
      }

      // 確定帖子類型
      PostType postType;
      if (mediaContent.isEmpty) {
        postType = PostType.text;
      } else if (mediaContent.length == 1) {
        postType = mediaContent.first.type == MediaType.photo 
            ? PostType.photo 
            : PostType.video;
      } else {
        postType = PostType.mixed;
      }

      // 創建動態帖子
      final post = FeedPost(
        id: '',
        userId: currentUser.uid,
        userDisplayName: userData['displayName'] ?? '匿名用戶',
        userAvatarUrl: userData['avatarUrl'] ?? '',
        textContent: textContent,
        mediaContent: mediaContent,
        createdAt: DateTime.now(),
        likedBy: [],
        viewedBy: [],
        tags: tags ?? [],
        location: location,
        type: postType,
        metadata: {
          'deviceInfo': 'mobile',
          'version': '1.0.0',
        },
      );

      // 保存到 Firestore
      final docRef = await _firestore
          .collection('feed_posts')
          .add(post.toFirestore());

      // 更新用戶統計
      await _updateUserPostStats(currentUser.uid);

      return docRef.id;
    } catch (e) {
      throw Exception('發布動態失敗: $e');
    }
  }

  /// 📷 上傳媒體文件
  Future<List<MediaContent>> _uploadMediaFiles(List<File> files) async {
    List<MediaContent> mediaContent = [];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = 'feed_media_${DateTime.now().millisecondsSinceEpoch}_$i';
      final isVideo = file.path.toLowerCase().endsWith('.mp4') || 
                     file.path.toLowerCase().endsWith('.mov');
      
      final storageRef = _storage.ref().child(
        isVideo ? 'feed_videos/$fileName' : 'feed_photos/$fileName'
      );
      
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      mediaContent.add(MediaContent(
        id: fileName,
        type: isVideo ? MediaType.video : MediaType.photo,
        url: downloadUrl,
        aspectRatio: 1.0, // 可以後續計算實際比例
        metadata: {
          'originalName': file.path.split('/').last,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      ));
    }
    
    return mediaContent;
  }

  // ================== 動態瀏覽功能 ==================

  /// 📱 獲取關注用戶的動態
  Stream<List<FeedPost>> getFollowingFeed(String userId) async* {
    final followingUserIds = await _getFollowingUserIds(userId);
    
    yield* _firestore
        .collection('feed_posts')
        .where('userId', whereIn: followingUserIds)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc))
            .toList());
  }

  /// 🔥 獲取熱門動態
  Stream<List<FeedPost>> getTrendingFeed() {
    return _firestore
        .collection('feed_posts')
        .where('isVisible', isEqualTo: true)
        .orderBy('likedBy', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc))
            .toList());
  }

  /// 👤 獲取用戶個人動態
  Stream<List<FeedPost>> getUserFeed(String userId) {
    return _firestore
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc))
            .toList());
  }

  // ================== 互動功能 ==================

  /// ❤️ 點讚/取消點讚動態
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('feed_posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw Exception('動態不存在');
        
        final post = FeedPost.fromFirestore(postDoc);
        List<String> likedBy = List.from(post.likedBy);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        transaction.update(postRef, {'likedBy': likedBy});
      });

      // 更新熱度排行榜分數
      await _updateHotRankingScore(postId, 'like');
    } catch (e) {
      throw Exception('點讚操作失敗: $e');
    }
  }

  /// 👁️ 記錄動態瀏覽
  Future<void> recordView(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('feed_posts').doc(postId);
      
      await postRef.update({
        'viewedBy': FieldValue.arrayUnion([userId])
      });

      // 更新熱度排行榜分數
      await _updateHotRankingScore(postId, 'view');
    } catch (e) {
      // 靜默處理瀏覽記錄錯誤
    }
  }

  // ================== 關注功能 ==================

  /// 👥 關注用戶
  Future<void> followUser(String followingId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');
      
      if (currentUser.uid == followingId) {
        throw Exception('不能關注自己');
      }

      final relationship = FollowRelationship(
        id: '',
        followerId: currentUser.uid,
        followingId: followingId,
        createdAt: DateTime.now(),
        type: FollowType.normal,
      );

      await _firestore
          .collection('follow_relationships')
          .add(relationship.toFirestore());

      // 更新關注統計
      await _updateFollowStats(currentUser.uid, followingId);
    } catch (e) {
      throw Exception('關注失敗: $e');
    }
  }

  /// 👥 取消關注用戶
  Future<void> unfollowUser(String followingId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      final querySnapshot = await _firestore
          .collection('follow_relationships')
          .where('followerId', isEqualTo: currentUser.uid)
          .where('followingId', isEqualTo: followingId)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'isActive': false});
      }

      // 更新關注統計
      await _updateUnfollowStats(currentUser.uid, followingId);
    } catch (e) {
      throw Exception('取消關注失敗: $e');
    }
  }

  /// 📊 檢查是否已關注
  Future<bool> isFollowing(String userId, String targetUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection('follow_relationships')
          .where('followerId', isEqualTo: userId)
          .where('followingId', isEqualTo: targetUserId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 📊 獲取關注列表
  Future<List<String>> getFollowingList(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('follow_relationships')
          .where('followerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 📊 獲取粉絲列表
  Future<List<String>> getFollowersList(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('follow_relationships')
          .where('followingId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['followerId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ================== 私有輔助方法 ==================

  /// 獲取關注用戶ID列表
  Future<List<String>> _getFollowingUserIds(String userId) async {
    final followingList = await getFollowingList(userId);
    followingList.add(userId); // 包含自己的動態
    return followingList;
  }

  /// 更新用戶發帖統計
  Future<void> _updateUserPostStats(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'postCount': FieldValue.increment(1),
        'lastPostTime': Timestamp.now(),
      });
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新關注統計
  Future<void> _updateFollowStats(String followerId, String followingId) async {
    try {
      final batch = _firestore.batch();
      
      // 更新關注者的關注數
      final followerRef = _firestore.collection('users').doc(followerId);
      batch.update(followerRef, {
        'followingCount': FieldValue.increment(1),
      });
      
      // 更新被關注者的粉絲數
      final followingRef = _firestore.collection('users').doc(followingId);
      batch.update(followingRef, {
        'followersCount': FieldValue.increment(1),
      });
      
      await batch.commit();
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新取消關注統計
  Future<void> _updateUnfollowStats(String followerId, String followingId) async {
    try {
      final batch = _firestore.batch();
      
      // 更新關注者的關注數
      final followerRef = _firestore.collection('users').doc(followerId);
      batch.update(followerRef, {
        'followingCount': FieldValue.increment(-1),
      });
      
      // 更新被關注者的粉絲數
      final followingRef = _firestore.collection('users').doc(followingId);
      batch.update(followingRef, {
        'followersCount': FieldValue.increment(-1),
      });
      
      await batch.commit();
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新熱度排行榜分數
  Future<void> _updateHotRankingScore(String postId, String action) async {
    try {
      // 獲取帖子作者
      final postDoc = await _firestore.collection('feed_posts').doc(postId).get();
      if (!postDoc.exists) return;
      
      final post = FeedPost.fromFirestore(postDoc);
      final userId = post.userId;
      
      // 計算分數增量
      int scoreIncrement = 0;
      switch (action) {
        case 'like':
          scoreIncrement = 5; // 點讚 +5 分
          break;
        case 'view':
          scoreIncrement = 1; // 瀏覽 +1 分
          break;
        case 'share':
          scoreIncrement = 10; // 分享 +10 分
          break;
      }
      
      // 更新用戶熱度分數
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'hotScore': FieldValue.increment(scoreIncrement),
        'lastActivityTime': Timestamp.now(),
      });
    } catch (e) {
      // 靜默處理分數更新錯誤
    }
  }

  // ================== 刪除功能 ==================

  /// 🗑️ 刪除動態
  Future<void> deletePost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      final postDoc = await _firestore.collection('feed_posts').doc(postId).get();
      if (!postDoc.exists) throw Exception('動態不存在');
      
      final post = FeedPost.fromFirestore(postDoc);
      if (post.userId != currentUser.uid) {
        throw Exception('只能刪除自己的動態');
      }

      // 軟刪除（設為不可見）
      await _firestore.collection('feed_posts').doc(postId).update({
        'isVisible': false,
        'deletedAt': Timestamp.now(),
      });

      // 更新用戶統計
      await _firestore.collection('users').doc(currentUser.uid).update({
        'postCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('刪除動態失敗: $e');
    }
  }
} 