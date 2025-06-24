import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase_config.dart';

// 聊天服務提供者
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// 消息數據模型
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}

// 消息類型枚舉
enum MessageType {
  text,
  image,
  icebreaker,
  dateIdea,
  system,
}

// 聊天室數據模型
class ChatRoom {
  final String id;
  final List<String> participants;
  final ChatMessage? lastMessage;
  final DateTime createdAt;
  final DateTime lastActivity;
  final Map<String, int> unreadCounts;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    required this.lastActivity,
    required this.unreadCounts,
    this.isActive = true,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }
}

// AI 破冰話題模型
class IcebreakerSuggestion {
  final String id;
  final String content;
  final String category;
  final List<String> tags;
  final double relevanceScore;

  IcebreakerSuggestion({
    required this.id,
    required this.content,
    required this.category,
    required this.tags,
    required this.relevanceScore,
  });
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 獲取或創建聊天室
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final chatId = _generateChatId(currentUserId, otherUserId);
      final chatRef = _firestore.collection('chats').doc(chatId);
      
      final chatDoc = await chatRef.get();
      
      if (!chatDoc.exists) {
        // 創建新聊天室
        await chatRef.set({
          'participants': [currentUserId, otherUserId],
          'createdAt': DateTime.now(),
          'lastActivity': DateTime.now(),
          'unreadCounts': {
            currentUserId: 0,
            otherUserId: 0,
          },
          'isActive': true,
        });
        
        print('新聊天室已創建: $chatId');
      }
      
      return chatId;
    } catch (e) {
      print('創建聊天室失敗: $e');
      throw Exception('創建聊天室失敗: $e');
    }
  }

  // 發送消息
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final messageRef = _firestore.collection('messages').doc();
      final message = ChatMessage(
        id: messageRef.id,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      // 保存消息
      await messageRef.set(message.toMap());

      // 更新聊天室信息
      await _updateChatRoom(chatId, message);

      print('消息已發送: ${message.id}');
    } catch (e) {
      print('發送消息失敗: $e');
      throw Exception('發送消息失敗: $e');
    }
  }

  // 更新聊天室信息
  Future<void> _updateChatRoom(String chatId, ChatMessage message) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      
      await _firestore.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);
        
        if (chatDoc.exists) {
          final data = chatDoc.data() as Map<String, dynamic>;
          final unreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});
          
          // 增加接收者的未讀計數
          unreadCounts[message.receiverId] = (unreadCounts[message.receiverId] ?? 0) + 1;
          
          transaction.update(chatRef, {
            'lastActivity': message.timestamp,
            'unreadCounts': unreadCounts,
          });
        }
      });
    } catch (e) {
      print('更新聊天室失敗: $e');
    }
  }

  // 獲取聊天消息流
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // 獲取用戶聊天室列表
  Stream<List<ChatRoom>> getUserChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc))
            .toList());
  }

  // 標記消息為已讀
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // 更新聊天室的未讀計數
      final chatRef = _firestore.collection('chats').doc(chatId);
      await chatRef.update({
        'unreadCounts.$currentUserId': 0,
      });

      // 標記消息為已讀
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('消息已標記為已讀');
    } catch (e) {
      print('標記已讀失敗: $e');
    }
  }

  // 生成 AI 破冰話題
  Future<List<IcebreakerSuggestion>> generateIcebreakers({
    required String otherUserId,
    int limit = 3,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      // 獲取雙方用戶資料
      if (FirebaseConfig.usersCollection == null) throw Exception('Firebase 未初始化');
      final currentUserDoc = await FirebaseConfig.usersCollection!.doc(currentUserId).get();
      final otherUserDoc = await FirebaseConfig.usersCollection!.doc(otherUserId).get();

      if (!currentUserDoc.exists || !otherUserDoc.exists) {
        throw Exception('用戶資料不存在');
      }

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final otherUserData = otherUserDoc.data() as Map<String, dynamic>;

      // 分析共同興趣和特徵
      final suggestions = await _generatePersonalizedIcebreakers(
        currentUserData,
        otherUserData,
        limit,
      );

      return suggestions;
    } catch (e) {
      print('生成破冰話題失敗: $e');
      return _getDefaultIcebreakers(limit);
    }
  }

  // 生成個性化破冰話題
  Future<List<IcebreakerSuggestion>> _generatePersonalizedIcebreakers(
    Map<String, dynamic> currentUser,
    Map<String, dynamic> otherUser,
    int limit,
  ) async {
    final suggestions = <IcebreakerSuggestion>[];
    
    // 分析共同興趣
    final currentInterests = List<String>.from(currentUser['interests'] ?? []);
    final otherInterests = List<String>.from(otherUser['interests'] ?? []);
    final commonInterests = currentInterests.where((interest) => 
        otherInterests.contains(interest)).toList();

    // 基於共同興趣生成話題
    for (final interest in commonInterests.take(2)) {
      final suggestion = _createInterestBasedIcebreaker(interest);
      if (suggestion != null) suggestions.add(suggestion);
    }

    // 基於 MBTI 類型生成話題
    final currentMBTI = currentUser['mbtiType'] as String?;
    final otherMBTI = otherUser['mbtiType'] as String?;
    if (currentMBTI != null && otherMBTI != null) {
      final mbtiSuggestion = _createMBTIBasedIcebreaker(currentMBTI, otherMBTI);
      if (mbtiSuggestion != null) suggestions.add(mbtiSuggestion);
    }

    // 基於職業生成話題
    final otherProfession = otherUser['profession'] as String?;
    if (otherProfession != null && otherProfession.isNotEmpty) {
      final professionSuggestion = _createProfessionBasedIcebreaker(otherProfession);
      if (professionSuggestion != null) suggestions.add(professionSuggestion);
    }

    // 如果建議不足，添加通用話題
    while (suggestions.length < limit) {
      final defaultSuggestions = _getDefaultIcebreakers(limit - suggestions.length);
      suggestions.addAll(defaultSuggestions);
      break;
    }

    return suggestions.take(limit).toList();
  }

  // 基於興趣創建破冰話題
  IcebreakerSuggestion? _createInterestBasedIcebreaker(String interest) {
    final interestQuestions = {
      '旅行': [
        '你最想去哪個國家旅行？為什麼？',
        '你有什麼難忘的旅行經歷嗎？',
        '你喜歡自由行還是跟團旅行？',
      ],
      '攝影': [
        '你最喜歡拍攝什麼類型的照片？',
        '你有什麼攝影技巧可以分享嗎？',
        '你用什麼相機或手機拍照？',
      ],
      '音樂': [
        '你最近在聽什麼音樂？',
        '你有最喜歡的歌手或樂團嗎？',
        '你會演奏任何樂器嗎？',
      ],
      '運動': [
        '你最喜歡什麼運動？',
        '你有定期運動的習慣嗎？',
        '你有參加過什麼體育比賽嗎？',
      ],
      '美食': [
        '你最喜歡什麼料理？',
        '你會做菜嗎？有什麼拿手菜？',
        '你有什麼推薦的餐廳嗎？',
      ],
    };

    final questions = interestQuestions[interest];
    if (questions == null || questions.isEmpty) return null;

    final randomQuestion = questions[DateTime.now().millisecond % questions.length];
    
    return IcebreakerSuggestion(
      id: 'interest_${interest}_${DateTime.now().millisecondsSinceEpoch}',
      content: randomQuestion,
      category: '共同興趣',
      tags: [interest],
      relevanceScore: 0.9,
    );
  }

  // 基於 MBTI 創建破冰話題
  IcebreakerSuggestion? _createMBTIBasedIcebreaker(String currentMBTI, String otherMBTI) {
    final mbtiQuestions = {
      'ENFP': '你是那種喜歡計劃還是隨性的人？',
      'INTJ': '你對未來有什麼長期規劃嗎？',
      'INFJ': '你覺得什麼事情最能激發你的熱情？',
      'ESTP': '你喜歡什麼刺激的活動？',
      'ISFJ': '你覺得什麼是生活中最重要的？',
    };

    final question = mbtiQuestions[otherMBTI] ?? '你覺得自己是什麼樣的人？';
    
    return IcebreakerSuggestion(
      id: 'mbti_${otherMBTI}_${DateTime.now().millisecondsSinceEpoch}',
      content: question,
      category: '性格探索',
      tags: ['MBTI', otherMBTI],
      relevanceScore: 0.8,
    );
  }

  // 基於職業創建破冰話題
  IcebreakerSuggestion? _createProfessionBasedIcebreaker(String profession) {
    final question = '你是怎麼選擇$profession這個職業的？喜歡這份工作嗎？';
    
    return IcebreakerSuggestion(
      id: 'profession_${profession}_${DateTime.now().millisecondsSinceEpoch}',
      content: question,
      category: '職業生活',
      tags: ['職業', profession],
      relevanceScore: 0.7,
    );
  }

  // 獲取默認破冰話題
  List<IcebreakerSuggestion> _getDefaultIcebreakers(int limit) {
    final defaultQuestions = [
      '你最近有看什麼好看的電影或劇集嗎？',
      '你週末通常喜歡做什麼？',
      '你有什麼特別的興趣愛好嗎？',
      '你最喜歡香港的哪個地方？',
      '你是貓派還是狗派？',
      '你最近學了什麼新技能嗎？',
      '你有什麼想要實現的夢想嗎？',
      '你覺得什麼樣的人最有魅力？',
      '你最珍惜的是什麼？',
      '你有什麼讓你開心的小事嗎？',
    ];

    return defaultQuestions.take(limit).map((question) => IcebreakerSuggestion(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      content: question,
      category: '通用話題',
      tags: ['通用'],
      relevanceScore: 0.5,
    )).toList();
  }

  // 生成約會建議
  Future<List<String>> generateDateIdeas({
    required String otherUserId,
    String? location = '香港',
    int limit = 3,
  }) async {
    try {
      // 獲取雙方興趣
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      if (FirebaseConfig.usersCollection == null) throw Exception('Firebase 未初始化');
      final currentUserDoc = await FirebaseConfig.usersCollection!.doc(currentUserId).get();
      final otherUserDoc = await FirebaseConfig.usersCollection!.doc(otherUserId).get();

             final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
       final otherUserData = otherUserDoc.data() as Map<String, dynamic>?;
       
       final currentInterests = List<String>.from(currentUserData?['interests'] ?? []);
       final otherInterests = List<String>.from(otherUserData?['interests'] ?? []);

      final commonInterests = currentInterests.where((interest) => 
          otherInterests.contains(interest)).toList();

      return _generateLocationBasedDateIdeas(commonInterests, location, limit);
    } catch (e) {
      print('生成約會建議失敗: $e');
      return _getDefaultDateIdeas(limit);
    }
  }

  // 基於位置和興趣生成約會建議
  List<String> _generateLocationBasedDateIdeas(
    List<String> commonInterests,
    String? location,
    int limit,
  ) {
    final dateIdeas = <String>[];

    // 基於共同興趣的約會建議
    for (final interest in commonInterests.take(2)) {
      final idea = _getInterestBasedDateIdea(interest, location);
      if (idea != null) dateIdeas.add(idea);
    }

    // 添加香港特色約會建議
    if (location == '香港') {
      dateIdeas.addAll([
        '到太平山頂看夜景，然後在山頂餐廳享用晚餐',
        '在中環海濱長廊散步，欣賞維港景色',
        '到星光大道看幻彩詠香江燈光秀',
        '在蘭桂坊體驗香港夜生活',
        '到赤柱市集逛街，然後在海邊咖啡廳聊天',
      ]);
    }

    // 如果建議不足，添加通用建議
    while (dateIdeas.length < limit) {
      dateIdeas.addAll(_getDefaultDateIdeas(limit - dateIdeas.length));
      break;
    }

    return dateIdeas.take(limit).toList();
  }

  // 基於興趣的約會建議
  String? _getInterestBasedDateIdea(String interest, String? location) {
    final interestDateIdeas = {
      '攝影': '一起到${location ?? '城市'}的特色景點拍照，分享攝影技巧',
      '音樂': '去聽現場音樂表演或者一起去KTV',
      '美食': '探索${location ?? '當地'}的特色餐廳，品嚐不同料理',
      '運動': '一起去健身房運動或者戶外活動',
      '藝術': '參觀藝術展覽或者一起畫畫',
      '旅行': '計劃一個短途旅行或者探索${location ?? '城市'}的新地方',
    };

    return interestDateIdeas[interest];
  }

  // 默認約會建議
  List<String> _getDefaultDateIdeas(int limit) {
    final defaultIdeas = [
      '在咖啡廳聊天，享受悠閒時光',
      '看一場電影，然後討論劇情',
      '到公園散步，享受自然風光',
      '一起做料理，體驗合作的樂趣',
      '參觀博物館，增長知識',
      '去遊樂園玩，重拾童心',
    ];

    return defaultIdeas.take(limit).toList();
  }

  // 生成聊天 ID
  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // 刪除聊天室
  Future<void> deleteChatRoom(String chatId) async {
    try {
      // 軟刪除：標記為不活躍
      await _firestore.collection('chats').doc(chatId).update({
        'isActive': false,
        'deletedAt': DateTime.now(),
      });

      print('聊天室已刪除: $chatId');
    } catch (e) {
      print('刪除聊天室失敗: $e');
      throw Exception('刪除聊天室失敗: $e');
    }
  }

  // 舉報聊天室或消息
  Future<void> reportChat({
    required String chatId,
    String? messageId,
    required String reason,
    String? description,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      await _firestore.collection('reports').add({
        'reporterId': currentUserId,
        'type': 'chat',
        'chatId': chatId,
        'messageId': messageId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': DateTime.now(),
      });

      print('舉報已提交');
    } catch (e) {
      print('提交舉報失敗: $e');
      throw Exception('提交舉報失敗: $e');
    }
  }
} 