import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/database_service.dart';
import '../../auth/models/user_model.dart';
import '../models/chat_models.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return ChatService(databaseService);
});

class ChatService {
  final DatabaseService _databaseService;
  final Uuid _uuid = const Uuid();

  ChatService(this._databaseService);

  /// 創建或獲取聊天室
  Future<ChatRoom> getOrCreateChatRoom(String userId1, String userId2) async {
    try {
      // 嘗試找到現有聊天室
      final existingRooms = await _databaseService.getUserChatRooms(userId1);
      final existingRoom = existingRooms.firstWhere(
        (room) => room.participants.contains(userId2),
        orElse: () => throw StateError('No existing room'),
      );

      return existingRoom;
    
      // 創建新聊天室
      final chatRoom = ChatRoom(
        id: _generateChatRoomId(userId1, userId2),
        participants: [userId1, userId2],
        type: ChatRoomType.match,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
      );

      await _databaseService.createChatRoom(chatRoom);
      return chatRoom;
    } catch (e) {
      throw ChatException('創建聊天室失敗: $e');
    }
  }

  /// 發送消息
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: content,
        type: type,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _databaseService.sendMessage(message);

      // 如果是第一條消息，發送破冰話題建議
      final messages = await getRecentMessages(chatRoomId, limit: 2);
      if (messages.length == 1) {
        await _sendIcebreakerSuggestions(chatRoomId, senderId);
      }
    } catch (e) {
      throw ChatException('發送消息失敗: $e');
    }
  }

  /// 發送破冰話題建議
  Future<void> _sendIcebreakerSuggestions(String chatRoomId, String senderId) async {
    try {
      // 獲取聊天室參與者信息
      final chatRoom = await _databaseService.getChatRoom(chatRoomId);
      if (chatRoom == null) return;

      final otherUserId = chatRoom.participants.firstWhere((id) => id != senderId);
      final currentUser = await _databaseService.getUserProfile(senderId);
      final otherUser = await _databaseService.getUserProfile(otherUserId);

      if (currentUser == null || otherUser == null) return;

      // 生成個性化破冰話題
      final icebreakers = await _generateIcebreakers(currentUser, otherUser);

      // 發送系統消息
      final systemMessage = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: 'system',
        content: '為你們推薦一些聊天話題：',
        type: MessageType.system,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: {
          'icebreakers': icebreakers,
          'type': 'icebreaker_suggestions',
        },
      );

      await _databaseService.sendMessage(systemMessage);
    } catch (e) {
      // 破冰話題發送失敗不應影響正常聊天
      print('發送破冰話題失敗: $e');
    }
  }

  /// 生成個性化破冰話題
  Future<List<IceBreaker>> _generateIcebreakers(UserModel user1, UserModel user2) async {
    final icebreakers = <IceBreaker>[];

    // 基於共同興趣的話題
    final commonInterests = user1.profile?.interests
        .where((interest) => user2.profile?.interests.contains(interest) ?? false)
        .toList() ?? [];

    if (commonInterests.isNotEmpty) {
      final interest = commonInterests.first;
      icebreakers.add(IceBreaker(
        id: _uuid.v4(),
        question: '我看到你也喜歡$interest！你最喜歡的$interest體驗是什麼？',
        category: 'interests',
        tags: [interest],
      ));
    }

    // 基於 MBTI 的話題
    final mbti1 = await _databaseService.getMBTIResult(user1.id);
    final mbti2 = await _databaseService.getMBTIResult(user2.id);

    if (mbti1 != null && mbti2 != null) {
      icebreakers.add(IceBreaker(
        id: _uuid.v4(),
        question: _generateMBTIQuestion(mbti1.personalityType, mbti2.personalityType),
        category: 'personality',
        tags: [mbti1.personalityType, mbti2.personalityType],
      ));
    }

    // 基於生活方式的話題
    final lifestyle1 = user1.profile?.lifestyleAnswers ?? {};
    final lifestyle2 = user2.profile?.lifestyleAnswers ?? {};

    if (lifestyle1.isNotEmpty && lifestyle2.isNotEmpty) {
      icebreakers.add(_generateLifestyleQuestion(lifestyle1, lifestyle2));
    }

    // 通用話題
    icebreakers.addAll(_getGeneralIcebreakers());

    // 隨機選擇 3-5 個話題
    icebreakers.shuffle();
    return icebreakers.take(4).toList();
  }

  /// 生成基於 MBTI 的問題
  String _generateMBTIQuestion(String type1, String type2) {
    final questions = {
      'INTJ': '作為建築師型人格，你最喜歡規劃什麼類型的項目？',
      'INFP': '作為調停者型人格，什麼事情最能激發你的熱情？',
      'ENFP': '作為競選者型人格，你最近有什麼新的想法或計劃嗎？',
      'ISTJ': '作為物流師型人格，你覺得什麼樣的傳統最值得保持？',
      // 可以添加更多類型的問題
    };

    return questions[type1] ?? questions[type2] ?? '你覺得人格測試準確嗎？為什麼？';
  }

  /// 生成基於生活方式的問題
  IceBreaker _generateLifestyleQuestion(Map<String, dynamic> lifestyle1, Map<String, dynamic> lifestyle2) {
    final weekendActivities1 = lifestyle1['weekend_activities'] as List<String>? ?? [];
    final weekendActivities2 = lifestyle2['weekend_activities'] as List<String>? ?? [];

    final commonActivities = weekendActivities1
        .where((activity) => weekendActivities2.contains(activity))
        .toList();

    if (commonActivities.isNotEmpty) {
      final activity = commonActivities.first;
      return IceBreaker(
        id: _uuid.v4(),
        question: '我們都喜歡$activity！你通常在什麼時候做這個？',
        category: 'lifestyle',
        tags: [activity],
      );
    }

    return IceBreaker(
      id: _uuid.v4(),
      question: '你理想的週末是怎樣度過的？',
      category: 'lifestyle',
      tags: ['weekend'],
    );
  }

  /// 獲取通用破冰話題
  List<IceBreaker> _getGeneralIcebreakers() {
    return [
      IceBreaker(
        id: _uuid.v4(),
        question: '如果可以和任何人共進晚餐，你會選擇誰？',
        category: 'general',
        tags: ['dinner', 'celebrity'],
      ),
      IceBreaker(
        id: _uuid.v4(),
        question: '你最近看過最有趣的電影或書是什麼？',
        category: 'general',
        tags: ['movies', 'books'],
      ),
      IceBreaker(
        id: _uuid.v4(),
        question: '你有什麼特別的才能或技能嗎？',
        category: 'general',
        tags: ['talents', 'skills'],
      ),
      IceBreaker(
        id: _uuid.v4(),
        question: '如果可以瞬間學會一項技能，你會選擇什麼？',
        category: 'general',
        tags: ['learning', 'skills'],
      ),
    ];
  }

  /// 獲取聊天室列表
  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _databaseService.watchUserChatRooms(userId);
  }

  /// 獲取聊天消息
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _databaseService.watchChatMessages(chatRoomId);
  }

  /// 獲取最近消息
  Future<List<ChatMessage>> getRecentMessages(String chatRoomId, {int limit = 20}) async {
    try {
      // 這裡需要實現獲取最近消息的邏輯
      // 暫時返回空列表，實際實現需要查詢數據庫
      return [];
    } catch (e) {
      throw ChatException('獲取最近消息失敗: $e');
    }
  }

  /// 標記消息為已讀
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      await _databaseService.markMessagesAsRead(chatRoomId, userId);
    } catch (e) {
      throw ChatException('標記消息已讀失敗: $e');
    }
  }

  /// 發送約會邀請
  Future<void> sendDateInvitation({
    required String chatRoomId,
    required String senderId,
    required String title,
    required String description,
    required DateTime proposedDate,
    required String location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final invitation = DateInvitation(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: senderId,
        title: title,
        description: description,
        proposedDate: proposedDate,
        location: location,
        status: DateInvitationStatus.pending,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // 發送約會邀請消息
      final message = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: '發送了一個約會邀請',
        type: MessageType.dateInvitation,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: {
          'dateInvitation': invitation.toJson(),
        },
      );

      await _databaseService.sendMessage(message);
    } catch (e) {
      throw ChatException('發送約會邀請失敗: $e');
    }
  }

  /// 回應約會邀請
  Future<void> respondToDateInvitation({
    required String invitationId,
    required String chatRoomId,
    required String userId,
    required DateInvitationStatus status,
    String? message,
  }) async {
    try {
      // 發送回應消息
      final responseMessage = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: userId,
        content: message ?? _getDefaultResponseMessage(status),
        type: MessageType.dateResponse,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: {
          'invitationId': invitationId,
          'responseStatus': status.toString().split('.').last,
        },
      );

      await _databaseService.sendMessage(responseMessage);
    } catch (e) {
      throw ChatException('回應約會邀請失敗: $e');
    }
  }

  /// 獲取默認回應消息
  String _getDefaultResponseMessage(DateInvitationStatus status) {
    switch (status) {
      case DateInvitationStatus.accepted:
        return '接受了約會邀請 ✨';
      case DateInvitationStatus.declined:
        return '婉拒了約會邀請';
      case DateInvitationStatus.pending:
        return '正在考慮約會邀請';
      case DateInvitationStatus.cancelled:
        return '取消了約會邀請';
    }
  }

  /// 發送語音消息
  Future<void> sendVoiceMessage({
    required String chatRoomId,
    required String senderId,
    required String audioPath,
    required int duration,
  }) async {
    try {
      // TODO: 上傳音頻文件到 Firebase Storage
      // final audioUrl = await _uploadAudioFile(audioPath);

      final message = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: '發送了語音消息',
        type: MessageType.voice,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: {
          'audioPath': audioPath, // 實際應用中應該是 audioUrl
          'duration': duration,
        },
      );

      await _databaseService.sendMessage(message);
    } catch (e) {
      throw ChatException('發送語音消息失敗: $e');
    }
  }

  /// 發送圖片消息
  Future<void> sendImageMessage({
    required String chatRoomId,
    required String senderId,
    required String imagePath,
    String? caption,
  }) async {
    try {
      // TODO: 上傳圖片到 Firebase Storage
      // final imageUrl = await _uploadImageFile(imagePath);

      final message = ChatMessage(
        id: _uuid.v4(),
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: caption ?? '發送了圖片',
        type: MessageType.image,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        metadata: {
          'imagePath': imagePath, // 實際應用中應該是 imageUrl
          'caption': caption,
        },
      );

      await _databaseService.sendMessage(message);
    } catch (e) {
      throw ChatException('發送圖片消息失敗: $e');
    }
  }

  /// 獲取聊天統計
  Future<ChatStats> getChatStats(String userId) async {
    try {
      final chatRooms = await _databaseService.getUserChatRooms(userId);
      
      int totalChats = chatRooms.length;
      int activeChats = chatRooms.where((room) => 
          room.lastMessageAt != null && 
          room.lastMessageAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length;
      
      // TODO: 計算更詳細的統計信息
      
      return ChatStats(
        totalChats: totalChats,
        activeChats: activeChats,
        totalMessages: 0, // 需要實現
        averageResponseTime: 0, // 需要實現
      );
    } catch (e) {
      throw ChatException('獲取聊天統計失敗: $e');
    }
  }

  /// 搜索聊天記錄
  Future<List<ChatMessage>> searchMessages({
    required String chatRoomId,
    required String query,
    int limit = 50,
  }) async {
    try {
      // TODO: 實現消息搜索功能
      // 這需要在 Firebase 中建立適當的索引
      return [];
    } catch (e) {
      throw ChatException('搜索消息失敗: $e');
    }
  }

  /// 生成聊天室 ID
  String _generateChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 獲取聊天室參與者信息
  Future<List<UserModel>> getChatRoomParticipants(String chatRoomId) async {
    try {
      final chatRoom = await _databaseService.getChatRoom(chatRoomId);
      if (chatRoom == null) {
        throw ChatException('找不到聊天室');
      }

      final participants = <UserModel>[];
      for (final userId in chatRoom.participants) {
        final user = await _databaseService.getUserProfile(userId);
        if (user != null) {
          participants.add(user);
        }
      }

      return participants;
    } catch (e) {
      throw ChatException('獲取參與者信息失敗: $e');
    }
  }

  /// 檢查用戶是否在線
  Future<bool> isUserOnline(String userId) async {
    try {
      // TODO: 實現在線狀態檢查
      // 這需要實現實時在線狀態追蹤
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 設置用戶在線狀態
  Future<void> setUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _databaseService.updateUserField(userId, 'isOnline', isOnline);
      await _databaseService.updateUserField(userId, 'lastSeen', DateTime.now());
    } catch (e) {
      throw ChatException('設置在線狀態失敗: $e');
    }
  }
}

/// 聊天統計
class ChatStats {
  final int totalChats;
  final int activeChats;
  final int totalMessages;
  final double averageResponseTime; // 分鐘

  ChatStats({
    required this.totalChats,
    required this.activeChats,
    required this.totalMessages,
    required this.averageResponseTime,
  });
}

/// 聊天異常類
class ChatException implements Exception {
  final String message;
  
  ChatException(this.message);
  
  @override
  String toString() => 'ChatException: $message';
} 