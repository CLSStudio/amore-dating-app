import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/feed_models.dart';

// ================== 話題討論服務 ==================

final topicServiceProvider = Provider<TopicService>((ref) => TopicService());

class TopicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ================== 話題管理功能 ==================

  /// 🏷️ 創建新話題
  Future<String> createTopic({
    required String title,
    required String description,
    required TopicCategory category,
    List<String>? tags,
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

      // 檢查話題標題是否重複
      final existingTopic = await _firestore
          .collection('topics')
          .where('title', isEqualTo: title)
          .where('isActive', isEqualTo: true)
          .get();
      
      if (existingTopic.docs.isNotEmpty) {
        throw Exception('話題標題已存在，請選擇其他標題');
      }

      // 創建話題
      final topic = Topic(
        id: '',
        title: title,
        description: description,
        creatorId: currentUser.uid,
        creatorDisplayName: userData['displayName'] ?? '匿名用戶',
        creatorAvatarUrl: userData['avatarUrl'] ?? '',
        createdAt: DateTime.now(),
        tags: tags ?? [],
        lastActivityAt: DateTime.now(),
        category: category,
        metadata: {
          'deviceInfo': 'mobile',
          'version': '1.0.0',
        },
      );

      // 保存到 Firestore
      final docRef = await _firestore
          .collection('topics')
          .add(topic.toFirestore());

      // 更新用戶統計
      await _updateUserTopicStats(currentUser.uid);

      return docRef.id;
    } catch (e) {
      throw Exception('創建話題失敗: $e');
    }
  }

  /// 📝 在話題中發帖
  Future<String> createTopicPost({
    required String topicId,
    required String content,
    List<File>? mediaFiles,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      // 檢查話題是否存在
      final topicDoc = await _firestore.collection('topics').doc(topicId).get();
      if (!topicDoc.exists) throw Exception('話題不存在');
      
      final topic = Topic.fromFirestore(topicDoc);
      if (!topic.isActive) throw Exception('話題已關閉');

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
        mediaContent = await _uploadTopicMediaFiles(mediaFiles);
      }

      // 創建話題帖子
      final post = TopicPost(
        id: '',
        topicId: topicId,
        userId: currentUser.uid,
        userDisplayName: userData['displayName'] ?? '匿名用戶',
        userAvatarUrl: userData['avatarUrl'] ?? '',
        content: content,
        mediaContent: mediaContent,
        createdAt: DateTime.now(),
        likedBy: [],
        metadata: {
          'deviceInfo': 'mobile',
          'version': '1.0.0',
        },
      );

      // 保存到 Firestore
      final docRef = await _firestore
          .collection('topic_posts')
          .add(post.toFirestore());

      // 更新話題統計
      await _updateTopicStats(topicId);

      // 更新用戶統計
      await _updateUserTopicPostStats(currentUser.uid);

      return docRef.id;
    } catch (e) {
      throw Exception('發帖失敗: $e');
    }
  }

  /// 📷 上傳話題媒體文件
  Future<List<MediaContent>> _uploadTopicMediaFiles(List<File> files) async {
    List<MediaContent> mediaContent = [];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = 'topic_media_${DateTime.now().millisecondsSinceEpoch}_$i';
      final isVideo = file.path.toLowerCase().endsWith('.mp4') || 
                     file.path.toLowerCase().endsWith('.mov');
      
      final storageRef = _storage.ref().child(
        isVideo ? 'topic_videos/$fileName' : 'topic_photos/$fileName'
      );
      
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      mediaContent.add(MediaContent(
        id: fileName,
        type: isVideo ? MediaType.video : MediaType.photo,
        url: downloadUrl,
        aspectRatio: 1.0,
        metadata: {
          'originalName': file.path.split('/').last,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      ));
    }
    
    return mediaContent;
  }

  // ================== 話題瀏覽功能 ==================

  /// 🔥 獲取熱門話題
  Stream<List<Topic>> getTrendingTopics() {
    return _firestore
        .collection('topics')
        .where('isActive', isEqualTo: true)
        .orderBy('participantCount', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Topic.fromFirestore(doc))
            .toList());
  }

  /// 🆕 獲取最新話題
  Stream<List<Topic>> getLatestTopics() {
    return _firestore
        .collection('topics')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Topic.fromFirestore(doc))
            .toList());
  }

  /// 📂 按分類獲取話題
  Stream<List<Topic>> getTopicsByCategory(TopicCategory category) {
    return _firestore
        .collection('topics')
        .where('category', isEqualTo: category.toString())
        .where('isActive', isEqualTo: true)
        .orderBy('lastActivityAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Topic.fromFirestore(doc))
            .toList());
  }

  /// 🔍 搜索話題
  Future<List<Topic>> searchTopics(String query) async {
    try {
      // 簡單的標題搜索（實際應用中可以使用更複雜的搜索）
      final querySnapshot = await _firestore
          .collection('topics')
          .where('isActive', isEqualTo: true)
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => Topic.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 💬 獲取話題中的帖子
  Stream<List<TopicPost>> getTopicPosts(String topicId) {
    return _firestore
        .collection('topic_posts')
        .where('topicId', isEqualTo: topicId)
        .where('isVisible', isEqualTo: true)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TopicPost.fromFirestore(doc))
            .toList());
  }

  // ================== 互動功能 ==================

  /// ❤️ 點讚/取消點讚話題帖子
  Future<void> toggleTopicPostLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('topic_posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw Exception('帖子不存在');
        
        final post = TopicPost.fromFirestore(postDoc);
        List<String> likedBy = List.from(post.likedBy);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        transaction.update(postRef, {'likedBy': likedBy});
      });

      // 更新熱度排行榜分數
      await _updateTopicHotRankingScore(postId, 'like');
    } catch (e) {
      throw Exception('點讚操作失敗: $e');
    }
  }

  /// 📌 置頂/取消置頂帖子（僅話題創建者可操作）
  Future<void> toggleTopicPostPin(String topicId, String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      // 檢查是否為話題創建者
      final topicDoc = await _firestore.collection('topics').doc(topicId).get();
      if (!topicDoc.exists) throw Exception('話題不存在');
      
      final topic = Topic.fromFirestore(topicDoc);
      if (topic.creatorId != currentUser.uid) {
        throw Exception('只有話題創建者可以置頂帖子');
      }

      // 切換置頂狀態
      final postDoc = await _firestore.collection('topic_posts').doc(postId).get();
      if (!postDoc.exists) throw Exception('帖子不存在');
      
      final post = TopicPost.fromFirestore(postDoc);
      await _firestore.collection('topic_posts').doc(postId).update({
        'isPinned': !post.isPinned,
      });
    } catch (e) {
      throw Exception('置頂操作失敗: $e');
    }
  }

  // ================== 統計更新功能 ==================

  /// 更新話題統計
  Future<void> _updateTopicStats(String topicId) async {
    try {
      final topicRef = _firestore.collection('topics').doc(topicId);
      
      // 計算參與人數（發帖的不重複用戶數）
      final postsSnapshot = await _firestore
          .collection('topic_posts')
          .where('topicId', isEqualTo: topicId)
          .where('isVisible', isEqualTo: true)
          .get();
      
      final uniqueUsers = <String>{};
      for (final doc in postsSnapshot.docs) {
        final post = TopicPost.fromFirestore(doc);
        uniqueUsers.add(post.userId);
      }
      
      await topicRef.update({
        'participantCount': uniqueUsers.length,
        'postCount': postsSnapshot.docs.length,
        'lastActivityAt': Timestamp.now(),
      });
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新用戶話題統計
  Future<void> _updateUserTopicStats(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'topicsCreated': FieldValue.increment(1),
      });
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新用戶話題發帖統計
  Future<void> _updateUserTopicPostStats(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'topicPostCount': FieldValue.increment(1),
        'lastTopicPostTime': Timestamp.now(),
      });
    } catch (e) {
      // 靜默處理統計更新錯誤
    }
  }

  /// 更新話題熱度排行榜分數
  Future<void> _updateTopicHotRankingScore(String postId, String action) async {
    try {
      // 獲取帖子作者
      final postDoc = await _firestore.collection('topic_posts').doc(postId).get();
      if (!postDoc.exists) return;
      
      final post = TopicPost.fromFirestore(postDoc);
      final userId = post.userId;
      
      // 計算分數增量
      int scoreIncrement = 0;
      switch (action) {
        case 'like':
          scoreIncrement = 3; // 話題帖子點讚 +3 分
          break;
        case 'reply':
          scoreIncrement = 5; // 話題帖子回覆 +5 分
          break;
        case 'create':
          scoreIncrement = 10; // 創建話題 +10 分
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

  // ================== 管理功能 ==================

  /// 🗑️ 刪除話題帖子
  Future<void> deleteTopicPost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      final postDoc = await _firestore.collection('topic_posts').doc(postId).get();
      if (!postDoc.exists) throw Exception('帖子不存在');
      
      final post = TopicPost.fromFirestore(postDoc);
      if (post.userId != currentUser.uid) {
        throw Exception('只能刪除自己的帖子');
      }

      // 軟刪除（設為不可見）
      await _firestore.collection('topic_posts').doc(postId).update({
        'isVisible': false,
        'deletedAt': Timestamp.now(),
      });

      // 更新話題統計
      await _updateTopicStats(post.topicId);

      // 更新用戶統計
      await _firestore.collection('users').doc(currentUser.uid).update({
        'topicPostCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('刪除帖子失敗: $e');
    }
  }

  /// 🔒 關閉話題（僅話題創建者可操作）
  Future<void> closeTopic(String topicId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      final topicDoc = await _firestore.collection('topics').doc(topicId).get();
      if (!topicDoc.exists) throw Exception('話題不存在');
      
      final topic = Topic.fromFirestore(topicDoc);
      if (topic.creatorId != currentUser.uid) {
        throw Exception('只有話題創建者可以關閉話題');
      }

      await _firestore.collection('topics').doc(topicId).update({
        'isActive': false,
        'closedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('關閉話題失敗: $e');
    }
  }

  /// ⭐ 設置精選話題（管理員功能）
  Future<void> setTopicFeatured(String topicId, bool isFeatured) async {
    try {
      await _firestore.collection('topics').doc(topicId).update({
        'isFeatured': isFeatured,
        'featuredAt': isFeatured ? Timestamp.now() : null,
      });
    } catch (e) {
      throw Exception('設置精選失敗: $e');
    }
  }

  // ================== 獲取話題詳情 ==================

  /// 📖 獲取話題詳情
  Future<Topic?> getTopicDetails(String topicId) async {
    try {
      final topicDoc = await _firestore.collection('topics').doc(topicId).get();
      if (!topicDoc.exists) return null;
      
      return Topic.fromFirestore(topicDoc);
    } catch (e) {
      return null;
    }
  }

  /// 👤 獲取用戶創建的話題
  Stream<List<Topic>> getUserCreatedTopics(String userId) {
    return _firestore
        .collection('topics')
        .where('creatorId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Topic.fromFirestore(doc))
            .toList());
  }

  /// 💬 獲取用戶參與的話題
  Future<List<Topic>> getUserParticipatedTopics(String userId) async {
    try {
      // 獲取用戶發帖的話題ID
      final postsSnapshot = await _firestore
          .collection('topic_posts')
          .where('userId', isEqualTo: userId)
          .where('isVisible', isEqualTo: true)
          .get();
      
      final topicIds = <String>{};
      for (final doc in postsSnapshot.docs) {
        final post = TopicPost.fromFirestore(doc);
        topicIds.add(post.topicId);
      }
      
      if (topicIds.isEmpty) return [];
      
      // 獲取話題詳情
      final topicsSnapshot = await _firestore
          .collection('topics')
          .where(FieldPath.documentId, whereIn: topicIds.toList())
          .where('isActive', isEqualTo: true)
          .get();
      
      return topicsSnapshot.docs
          .map((doc) => Topic.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
} 