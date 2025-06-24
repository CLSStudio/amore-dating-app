import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase_config.dart';
import '../chat_service.dart';

// 真實聊天服務提供者
final realChatServiceProvider = Provider<RealChatService>((ref) {
  return RealChatService();
});

class RealChatService {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final FirebaseAuth _auth = FirebaseConfig.auth;

  // 獲取當前用戶的聊天室列表
  Stream<List<ChatRoom>> getUserChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatRoom(
          id: doc.id,
          participants: List<String>.from(data['participants'] ?? []),
          lastMessage: data['lastMessage'] != null
              ? _parseLastMessage(data['lastMessage'])
              : null,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
          unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    });
  }

  // 獲取特定聊天室的消息流
  Stream<List<ChatMessage>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          chatId: chatId,
          senderId: data['senderId'] ?? '',
          receiverId: data['receiverId'] ?? '',
          content: data['content'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          type: MessageType.values.firstWhere(
            (type) => type.toString().split('.').last == data['type'],
            orElse: () => MessageType.text,
          ),
          isRead: data['isRead'] ?? false,
          metadata: data['metadata'],
        );
      }).toList();
    });
  }

  // 發送消息
  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('用戶未登入');
      }

      final messageData = {
        'senderId': currentUserId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type.toString().split('.').last,
        'isRead': false,
        'metadata': metadata,
      };

      // 添加消息到聊天室
      final messageRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // 更新聊天室的最後消息和活動時間
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': {
          'id': messageRef.id,
          'senderId': currentUserId,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'type': type.toString().split('.').last,
        },
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // 更新未讀計數
      await _updateUnreadCounts(chatId, currentUserId);

      // 記錄分析事件
      await FirebaseConfig.logEvent('message_sent', {
        'chat_id': chatId,
        'sender_id': currentUserId,
        'message_type': type.toString().split('.').last,
      });

      print('✅ 消息發送成功: $chatId');
    } catch (e) {
      print('❌ 發送消息失敗: $e');
      throw Exception('發送消息失敗: $e');
    }
  }

  // 標記消息為已讀
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final messageRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId);
        
        batch.update(messageRef, {'isRead': true});
      }

      await batch.commit();

      // 重置當前用戶的未讀計數
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCounts.$currentUserId': 0,
      });

      print('✅ 消息標記為已讀: ${messageIds.length} 條消息');
    } catch (e) {
      print('❌ 標記消息已讀失敗: $e');
    }
  }

  // 創建新聊天室
  Future<String> createChatRoom(List<String> participants) async {
    try {
      final chatData = {
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCounts': {
          for (final participant in participants) participant: 0,
        },
        'isActive': true,
        'lastMessage': null,
      };

      final chatRef = await _firestore.collection('chats').add(chatData);

      // 記錄分析事件
      await FirebaseConfig.logEvent('chat_created', {
        'chat_id': chatRef.id,
        'participants_count': participants.length,
      });

      print('✅ 聊天室創建成功: ${chatRef.id}');
      return chatRef.id;
    } catch (e) {
      print('❌ 創建聊天室失敗: $e');
      throw Exception('創建聊天室失敗: $e');
    }
  }

  // 獲取或創建聊天室
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('用戶未登入');
      }

      // 檢查是否已存在聊天室
      final existingChats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in existingChats.docs) {
        final participants = List<String>.from(doc.data()['participants'] ?? []);
        if (participants.contains(otherUserId) && participants.length == 2) {
          return doc.id;
        }
      }

      // 如果不存在，創建新聊天室
      return await createChatRoom([currentUserId, otherUserId]);
    } catch (e) {
      print('❌ 獲取或創建聊天室失敗: $e');
      throw Exception('獲取或創建聊天室失敗: $e');
    }
  }

  // 刪除聊天室
  Future<void> deleteChatRoom(String chatId) async {
    try {
      // 軟刪除：標記為不活躍
      await _firestore.collection('chats').doc(chatId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // 記錄分析事件
      await FirebaseConfig.logEvent('chat_deleted', {
        'chat_id': chatId,
      });

      print('✅ 聊天室刪除成功: $chatId');
    } catch (e) {
      print('❌ 刪除聊天室失敗: $e');
      throw Exception('刪除聊天室失敗: $e');
    }
  }

  // 生成 AI 破冰話題
  Future<List<String>> generateIcebreakers({
    required String otherUserId,
    String? mbtiType,
    List<String>? commonInterests,
  }) async {
    try {
      // 模擬 AI 生成的破冰話題
      // 在實際應用中，這裡會調用 AI 服務
      final icebreakers = <String>[];

      // 基於 MBTI 類型的話題
      if (mbtiType != null) {
        icebreakers.addAll(_getMBTIIcebreakers(mbtiType));
      }

      // 基於共同興趣的話題
      if (commonInterests != null && commonInterests.isNotEmpty) {
        icebreakers.addAll(_getInterestIcebreakers(commonInterests));
      }

      // 通用破冰話題
      icebreakers.addAll(_getGeneralIcebreakers());

      // 隨機選擇 5 個話題
      icebreakers.shuffle();
      final selectedIcebreakers = icebreakers.take(5).toList();

             // 記錄分析事件
       await FirebaseConfig.logEvent('icebreakers_generated', {
         'other_user_id': otherUserId,
         'mbti_type': mbtiType ?? '',
         'common_interests_count': commonInterests?.length ?? 0,
       });

      print('✅ AI 破冰話題生成成功: ${selectedIcebreakers.length} 個話題');
      return selectedIcebreakers;
    } catch (e) {
      print('❌ 生成破冰話題失敗: $e');
      throw Exception('生成破冰話題失敗: $e');
    }
  }

  // 更新未讀計數
  Future<void> _updateUnreadCounts(String chatId, String senderId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return;

      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final currentUnreadCounts = Map<String, int>.from(chatDoc.data()?['unreadCounts'] ?? {});

      // 為除發送者外的所有參與者增加未讀計數
      for (final participant in participants) {
        if (participant != senderId) {
          currentUnreadCounts[participant] = (currentUnreadCounts[participant] ?? 0) + 1;
        }
      }

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCounts': currentUnreadCounts,
      });
    } catch (e) {
      print('❌ 更新未讀計數失敗: $e');
    }
  }

  // 獲取基於 MBTI 的破冰話題
  List<String> _getMBTIIcebreakers(String mbtiType) {
    final mbtiIcebreakers = {
      'ENFP': [
        '你最近有什麼新的創意想法嗎？',
        '如果可以和任何人共進晚餐，你會選擇誰？',
        '你覺得什麼事情最能激發你的熱情？',
      ],
      'INTJ': [
        '你對未來有什麼長期規劃？',
        '最近讀了什麼有趣的書或文章嗎？',
        '你認為什麼是解決問題的最佳方法？',
      ],
      'ESFP': [
        '你最喜歡的週末活動是什麼？',
        '有什麼讓你感到特別開心的小事嗎？',
        '你最難忘的旅行經歷是什麼？',
      ],
      'ISTJ': [
        '你有什麼堅持已久的習慣嗎？',
        '你覺得什麼傳統或價值觀最重要？',
        '你是如何保持生活井然有序的？',
      ],
    };

    return mbtiIcebreakers[mbtiType] ?? [];
  }

  // 獲取基於興趣的破冰話題
  List<String> _getInterestIcebreakers(List<String> interests) {
    final interestIcebreakers = <String>[];

    for (final interest in interests) {
      switch (interest.toLowerCase()) {
        case '音樂':
          interestIcebreakers.add('你最近在聽什麼音樂？');
          interestIcebreakers.add('有沒有想一起去的演唱會？');
          break;
        case '電影':
          interestIcebreakers.add('最近看了什麼好電影嗎？');
          interestIcebreakers.add('你最喜歡的電影類型是什麼？');
          break;
        case '旅行':
          interestIcebreakers.add('你的夢想旅行目的地是哪裡？');
          interestIcebreakers.add('最難忘的旅行經歷是什麼？');
          break;
        case '美食':
          interestIcebreakers.add('你最喜歡的料理是什麼？');
          interestIcebreakers.add('有沒有想一起嘗試的餐廳？');
          break;
        case '運動':
          interestIcebreakers.add('你最喜歡的運動是什麼？');
          interestIcebreakers.add('有沒有想一起做的運動？');
          break;
      }
    }

    return interestIcebreakers;
  }

  // 獲取通用破冰話題
  List<String> _getGeneralIcebreakers() {
    return [
      '你今天過得怎麼樣？',
      '有什麼讓你感到興奮的計劃嗎？',
      '你最喜歡的放鬆方式是什麼？',
      '如果有一天假期，你會怎麼度過？',
      '你最近學到了什麼新東西？',
      '有什麼讓你感到自豪的成就嗎？',
      '你覺得什麼是生活中最重要的事？',
      '有沒有什麼特別的愛好或技能？',
      '你最喜歡的季節是什麼？為什麼？',
      '如果可以擁有一項超能力，你會選擇什麼？',
    ];
  }

  // 解析最後消息
  ChatMessage _parseLastMessage(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      chatId: '',
      senderId: data['senderId'] ?? '',
      receiverId: '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (type) => type.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }
} 