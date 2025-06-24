import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 創建或獲取聊天室
  Future<String> createOrGetChat(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    // 檢查是否已存在聊天室
    final existingChat = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in existingChat.docs) {
      final chat = Chat.fromJson(doc.data());
      if (chat.participantIds.contains(otherUserId)) {
        return chat.id;
      }
    }

    // 創建新聊天室
    final chatId = _firestore.collection('chats').doc().id;
    final chat = Chat(
      id: chatId,
      participantIds: [currentUserId, otherUserId],
      lastActivity: DateTime.now(),
      unreadCounts: {currentUserId: 0, otherUserId: 0},
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toJson());
    return chatId;
  }

  // 發送消息
  Future<void> sendMessage({
    required String chatId,
    required String content,
    required String receiverId,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
    Map<String, dynamic>? metadata,
    bool isAiGenerated = false,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('用戶未登入');

    final messageId = _firestore.collection('messages').doc().id;
    final message = Message(
      id: messageId,
      chatId: chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      metadata: metadata,
      isAiGenerated: isAiGenerated,
    );

    try {
      // 保存消息
      await _firestore.collection('messages').doc(messageId).set(message.toJson());
      
      // 更新聊天室最後活動
      await _updateChatLastActivity(chatId, message, receiverId);
      
      // 更新消息狀態為已發送
      await _firestore.collection('messages').doc(messageId).update({
        'status': MessageStatus.sent.toString().split('.').last,
      });

    } catch (e) {
      // 更新消息狀態為失敗
      await _firestore.collection('messages').doc(messageId).update({
        'status': MessageStatus.failed.toString().split('.').last,
      });
      throw Exception('發送消息失敗: $e');
    }
  }

  // 更新聊天室最後活動
  Future<void> _updateChatLastActivity(String chatId, Message message, String receiverId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.toJson(),
      'lastActivity': Timestamp.fromDate(DateTime.now()),
      'unreadCounts.$receiverId': FieldValue.increment(1),
    });
  }

  // 獲取聊天室消息流
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  // 獲取用戶聊天室列表
  Stream<List<Chat>> getUserChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromJson(doc.data()))
            .toList());
  }

  // 標記消息為已讀
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // 更新聊天室未讀計數
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$currentUserId': 0,
    });

    // 更新消息狀態為已讀
    final unreadMessages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', whereIn: [
          MessageStatus.sent.toString().split('.').last,
          MessageStatus.delivered.toString().split('.').last,
        ])
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'status': MessageStatus.read.toString().split('.').last,
      });
    }
    await batch.commit();
  }

  // 獲取破冰話題
  Future<List<IcebreakerTopic>> getIcebreakerTopics({
    String? category,
    int? difficulty,
    bool personalizedOnly = false,
  }) async {
    Query query = _firestore.collection('icebreaker_topics');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }
    if (personalizedOnly) {
      query = query.where('isPersonalized', isEqualTo: true);
    }

    final snapshot = await query.limit(20).get();
    return snapshot.docs
        .map((doc) => IcebreakerTopic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 基於 MBTI 生成個性化破冰話題
  Future<List<IcebreakerTopic>> getPersonalizedIcebreakers(
    String userMbtiType,
    String partnerMbtiType,
  ) async {
    // 根據 MBTI 類型組合生成個性化話題
    final personalizedTopics = _generateMBTIBasedTopics(userMbtiType, partnerMbtiType);
    
    // 從數據庫獲取通用話題
    final generalTopics = await getIcebreakerTopics(difficulty: 2);
    
    // 合併並返回
    return [...personalizedTopics, ...generalTopics.take(5)];
  }

  // 生成基於 MBTI 的話題
  List<IcebreakerTopic> _generateMBTIBasedTopics(String userType, String partnerType) {
    final topics = <IcebreakerTopic>[];
    
    // 基於 MBTI 維度生成話題
    if (_isIntuitive(userType) && _isIntuitive(partnerType)) {
      topics.add(IcebreakerTopic(
        id: 'mbti_intuitive_${DateTime.now().millisecondsSinceEpoch}',
        question: '如果你可以創造一個全新的節日，它會是什麼樣的？',
        category: '創意想像',
        suggestedResponses: [
          '我會創造一個「夢想分享日」',
          '一個專門慶祝小確幸的節日',
          '讓所有人都能表達創意的藝術節',
        ],
        difficulty: 3,
        tags: ['創意', '想像力', '直覺'],
        isPersonalized: true,
      ));
    }

    if (_isFeeling(userType) && _isFeeling(partnerType)) {
      topics.add(IcebreakerTopic(
        id: 'mbti_feeling_${DateTime.now().millisecondsSinceEpoch}',
        question: '什麼樣的小舉動最能讓你感到被關愛？',
        category: '情感連結',
        suggestedResponses: [
          '記住我提過的小細節',
          '在我需要時給我一個擁抱',
          '為我準備我喜歡的食物',
        ],
        difficulty: 4,
        tags: ['情感', '關愛', '連結'],
        isPersonalized: true,
      ));
    }

    if (_isExtraverted(userType) || _isExtraverted(partnerType)) {
      topics.add(IcebreakerTopic(
        id: 'mbti_extraverted_${DateTime.now().millisecondsSinceEpoch}',
        question: '你最喜歡的社交活動是什麼？為什麼？',
        category: '社交生活',
        suggestedResponses: [
          '和朋友一起探索新餐廳',
          '參加音樂節或演唱會',
          '組織聚會讓大家認識',
        ],
        difficulty: 2,
        tags: ['社交', '外向', '活動'],
        isPersonalized: true,
      ));
    }

    return topics;
  }

  // MBTI 類型判斷輔助方法
  bool _isExtraverted(String type) => type.startsWith('E');
  bool _isIntuitive(String type) => type.contains('N');
  bool _isFeeling(String type) => type.contains('F');
  bool _isJudging(String type) => type.endsWith('J');

  // 發送破冰話題
  Future<void> sendIcebreakerTopic({
    required String chatId,
    required String receiverId,
    required IcebreakerTopic topic,
  }) async {
    await sendMessage(
      chatId: chatId,
      content: topic.question,
      receiverId: receiverId,
      type: MessageType.icebreaker,
      metadata: {
        'topicId': topic.id,
        'category': topic.category,
        'difficulty': topic.difficulty,
        'suggestedResponses': topic.suggestedResponses,
        'isPersonalized': topic.isPersonalized,
      },
      isAiGenerated: true,
    );
  }

  // 生成約會建議
  Future<void> generateDateIdea({
    required String chatId,
    required String receiverId,
    required String userMbtiType,
    required String partnerMbtiType,
    String? location,
    String? budget,
  }) async {
    final dateIdea = _generateDateIdea(userMbtiType, partnerMbtiType, location, budget);
    
    await sendMessage(
      chatId: chatId,
      content: '💡 為你們推薦一個約會想法：\n\n${dateIdea['title']}\n\n${dateIdea['description']}\n\n📍 地點：${dateIdea['location']}\n💰 預算：${dateIdea['budget']}\n⏰ 時長：${dateIdea['duration']}',
      receiverId: receiverId,
      type: MessageType.dateIdea,
      metadata: dateIdea,
      isAiGenerated: true,
    );
  }

  // 生成約會建議邏輯
  Map<String, dynamic> _generateDateIdea(
    String userType,
    String partnerType,
    String? location,
    String? budget,
  ) {
    final ideas = <Map<String, dynamic>>[];

    // 基於 MBTI 類型生成約會建議
    if (_isIntuitive(userType) && _isIntuitive(partnerType)) {
      ideas.addAll([
        {
          'title': '藝術館探索之旅',
          'description': '一起參觀當代藝術展覽，分享對作品的不同見解，在咖啡廳討論藝術與生活的連結。',
          'location': location ?? '香港藝術館',
          'budget': budget ?? 'HK\$200-400',
          'duration': '3-4小時',
          'tags': ['藝術', '文化', '深度對話'],
        },
        {
          'title': '創意工作坊體驗',
          'description': '參加陶藝、繪畫或手工藝工作坊，一起創作獨特的作品作為紀念。',
          'location': location ?? '創意工作室',
          'budget': budget ?? 'HK\$300-600',
          'duration': '2-3小時',
          'tags': ['創意', '手作', '紀念品'],
        },
      ]);
    }

    if (_isExtraverted(userType) || _isExtraverted(partnerType)) {
      ideas.addAll([
        {
          'title': '夜市美食探險',
          'description': '一起逛夜市，嘗試各種街頭小食，體驗香港地道文化。',
          'location': location ?? '廟街夜市',
          'budget': budget ?? 'HK\$150-300',
          'duration': '2-3小時',
          'tags': ['美食', '文化', '熱鬧'],
        },
        {
          'title': '卡拉OK歡唱夜',
          'description': '在KTV包廂裡盡情歌唱，分享彼此喜愛的音樂，放鬆心情。',
          'location': location ?? 'KTV包廂',
          'budget': budget ?? 'HK\$200-500',
          'duration': '2-4小時',
          'tags': ['音樂', '娛樂', '放鬆'],
        },
      ]);
    }

    if (_isFeeling(userType) && _isFeeling(partnerType)) {
      ideas.addAll([
        {
          'title': '海邊日落漫步',
          'description': '在海邊散步，欣賞日落美景，分享內心深處的想法和感受。',
          'location': location ?? '淺水灣海灘',
          'budget': budget ?? 'HK\$50-150',
          'duration': '2-3小時',
          'tags': ['浪漫', '自然', '深度交流'],
        },
        {
          'title': '溫馨家庭式料理',
          'description': '一起到市場買菜，回家烹飪一頓溫馨的晚餐，享受居家時光。',
          'location': location ?? '家中廚房',
          'budget': budget ?? 'HK\$100-300',
          'duration': '3-4小時',
          'tags': ['溫馨', '料理', '居家'],
        },
      ]);
    }

    // 隨機選擇一個建議
    if (ideas.isEmpty) {
      return {
        'title': '咖啡廳聊天',
        'description': '在舒適的咖啡廳裡，享受悠閒的下午時光，深入了解彼此。',
        'location': location ?? '特色咖啡廳',
        'budget': budget ?? 'HK\$100-200',
        'duration': '1-2小時',
        'tags': ['輕鬆', '對話', '咖啡'],
      };
    }

    ideas.shuffle();
    return ideas.first;
  }

  // 刪除聊天室
  Future<void> deleteChat(String chatId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // 刪除聊天室中的所有消息
    final messages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // 刪除聊天室
    batch.delete(_firestore.collection('chats').doc(chatId));
    await batch.commit();
  }
} 