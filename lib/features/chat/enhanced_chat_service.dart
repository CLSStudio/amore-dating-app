import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../profile/file_manager_service.dart';
import '../security/security_service.dart';
import '../../core/ai/ai_service.dart';

/// 增強聊天服務
class EnhancedChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 發送安全文本消息
  Future<String> sendSecureTextMessage({
    required String chatId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('用戶未登入');
      }

      // 內容安全檢查
      if (!_isContentSafe(content)) {
        throw Exception('消息包含不適當內容');
      }

      // 創建消息
      final messageData = {
        'chatId': chatId,
        'senderId': currentUserId,
        'content': content,
        'type': 'text',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
        'replyToId': replyToId,
        'isRead': false,
        'safetyChecked': true,
      };

      // 保存消息
      final messageRef = await _firestore
          .collection('messages')
          .add(messageData);

      // 更新聊天室最後活動
      await _updateChatLastActivity(chatId, messageRef.id, content);

      print('✅ 安全消息發送成功: ${messageRef.id}');
      return messageRef.id;
    } catch (e) {
      print('❌ 發送安全消息失敗: $e');
      throw Exception('發送消息失敗: $e');
    }
  }

  /// 發送媒體消息
  Future<String> sendMediaMessage({
    required String chatId,
    required String mediaUrl,
    required String mediaType, // 'image', 'video', 'audio'
    String? caption,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('用戶未登入');
      }

      // 媒體安全檢查
      if (!await _isMediaSafe(mediaUrl, mediaType)) {
        throw Exception('媒體內容不符合安全標準');
      }

      // 創建媒體消息
      final messageData = {
        'chatId': chatId,
        'senderId': currentUserId,
        'content': caption ?? '發送了${_getMediaTypeName(mediaType)}',
        'type': mediaType,
        'mediaUrl': mediaUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
        'isRead': false,
        'safetyChecked': true,
      };

      // 保存消息
      final messageRef = await _firestore
          .collection('messages')
          .add(messageData);

      // 更新聊天室最後活動
      await _updateChatLastActivity(chatId, messageRef.id, messageData['content'] as String);

      print('✅ 媒體消息發送成功: ${messageRef.id}');
      return messageRef.id;
    } catch (e) {
      print('❌ 發送媒體消息失敗: $e');
      throw Exception('發送媒體消息失敗: $e');
    }
  }

  /// 獲取聊天消息流
  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  /// 標記消息為已讀
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final batch = _firestore.batch();
      
      // 獲取未讀消息
      final unreadMessages = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('isRead', isEqualTo: false)
          .get();

      // 批量標記為已讀
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ 消息標記為已讀: ${unreadMessages.docs.length} 條');
    } catch (e) {
      print('❌ 標記消息已讀失敗: $e');
    }
  }

  /// 設置打字狀態
  Future<void> setTypingStatus({
    required String chatId,
    required bool isTyping,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore
          .collection('chat_typing')
          .doc('${chatId}_$currentUserId')
          .set({
        'chatId': chatId,
        'userId': currentUserId,
        'isTyping': isTyping,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ 設置打字狀態失敗: $e');
    }
  }

  /// 獲取打字狀態流
  Stream<List<String>> getTypingUsersStream(String chatId) {
    return _firestore
        .collection('chat_typing')
        .where('chatId', isEqualTo: chatId)
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toList();
    });
  }

  /// 舉報消息
  Future<void> reportMessage({
    required String messageId,
    required String reason,
    String? details,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('message_reports').add({
        'messageId': messageId,
        'reporterId': currentUserId,
        'reason': reason,
        'details': details,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ 消息舉報成功');
    } catch (e) {
      print('❌ 舉報消息失敗: $e');
    }
  }

  /// 封鎖用戶
  Future<void> blockUser(String blockedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('user_blocks').add({
        'blockerId': currentUserId,
        'blockedUserId': blockedUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ 用戶封鎖成功');
    } catch (e) {
      print('❌ 封鎖用戶失敗: $e');
    }
  }

  /// 生成AI破冰話題
  Future<List<String>> generateIcebreakerTopics(String otherUserId) async {
    try {
      // 模擬AI生成破冰話題
      final topics = [
        '你最喜歡的休閒活動是什麼？',
        '分享一個讓你開心的回憶吧！',
        '你對什麼類型的音樂有興趣？',
        '週末你通常會做什麼？',
        '你最想去的旅行目的地是哪裡？',
      ];

      // 隨機選擇3個話題
      topics.shuffle();
      return topics.take(3).toList();
    } catch (e) {
      print('❌ 生成破冰話題失敗: $e');
      return ['你好！很高興認識你！'];
    }
  }

  /// 創建或獲取聊天室
  Future<String> createOrGetChatRoom(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('用戶未登入');
      }

      // 檢查是否已存在聊天室
      final existingChatQuery = await _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (final doc in existingChatQuery.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId) && participants.length == 2) {
          return doc.id;
        }
      }

      // 創建新聊天室
      final chatRoomRef = await _firestore.collection('chat_rooms').add({
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'unreadCounts': {
          currentUserId: 0,
          otherUserId: 0,
        },
      });

      print('✅ 聊天室創建成功: ${chatRoomRef.id}');
      return chatRoomRef.id;
    } catch (e) {
      print('❌ 創建聊天室失敗: $e');
      throw Exception('創建聊天室失敗: $e');
    }
  }

  /// 獲取用戶聊天室列表
  Future<List<Map<String, dynamic>>> getUserChatRooms() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      final chatRoomsQuery = await _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastActivity', descending: true)
          .get();

      return chatRoomsQuery.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('❌ 獲取聊天室列表失敗: $e');
      return [];
    }
  }

  /// 刪除消息
  Future<void> deleteMessage(String messageId, {bool forEveryone = false}) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      if (forEveryone) {
        // 完全刪除消息
        await _firestore.collection('messages').doc(messageId).delete();
      } else {
        // 只為當前用戶隱藏
        await _firestore.collection('messages').doc(messageId).update({
          'deletedFor': FieldValue.arrayUnion([currentUserId]),
        });
      }

      print('✅ 消息刪除成功');
    } catch (e) {
      print('❌ 刪除消息失敗: $e');
    }
  }

  /// 私有輔助方法

  bool _isContentSafe(String content) {
    // 基本內容安全檢查
    final unsafeWords = ['騙', '詐騙', '轉帳', '匯款', '色情'];
    final lowerContent = content.toLowerCase();
    
    for (final word in unsafeWords) {
      if (lowerContent.contains(word)) {
        return false;
      }
    }
    
    return true;
  }

  Future<bool> _isMediaSafe(String mediaUrl, String mediaType) async {
    // 模擬媒體安全檢查
    try {
      // 在實際應用中，這裡會調用AI視覺檢測API
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getMediaTypeName(String mediaType) {
    switch (mediaType) {
      case 'image':
        return '圖片';
      case 'video':
        return '影片';
      case 'audio':
        return '語音';
      default:
        return '媒體檔案';
    }
  }

  Future<void> _updateChatLastActivity(String chatId, String messageId, String content) async {
    try {
      await _firestore.collection('chat_rooms').doc(chatId).update({
        'lastMessage': content,
        'lastMessageId': messageId,
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ 更新聊天室活動失敗: $e');
    }
  }
}

/// 增強聊天服務提供者
final enhancedChatServiceProvider = Provider<EnhancedChatService>((ref) {
  return EnhancedChatService();
});

// 消息類型枚舉
enum MessageType {
  text,
  image,
  voice,
  video,
  file,
  sticker,
  location,
  contact,
  icebreaker,
  dateInvitation,
  safetyReport,
}

// 消息狀態枚舉
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
  blocked,
}

// 聊天室狀態枚舉
enum ChatRoomStatus {
  active,
  archived,
  blocked,
  reported,
  deleted,
}

// 增強消息模型
class EnhancedMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;
  final String? replyToMessageId;
  final List<String> reactions;
  final bool isAiGenerated;
  final double? safetyScore;

  EnhancedMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.readAt,
    this.metadata = const {},
    this.replyToMessageId,
    this.reactions = const [],
    this.isAiGenerated = false,
    this.safetyScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString(),
      'status': status.toString(),
      'timestamp': timestamp,
      'readAt': readAt,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'reactions': reactions,
      'isAiGenerated': isAiGenerated,
      'safetyScore': safetyScore,
    };
  }

  factory EnhancedMessage.fromJson(Map<String, dynamic> json) {
    return EnhancedMessage(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      readAt: json['readAt'] != null ? (json['readAt'] as Timestamp).toDate() : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      replyToMessageId: json['replyToMessageId'],
      reactions: List<String>.from(json['reactions'] ?? []),
      isAiGenerated: json['isAiGenerated'] ?? false,
      safetyScore: json['safetyScore']?.toDouble(),
    );
  }
}

// 增強聊天室模型
class EnhancedChatRoom {
  final String id;
  final List<String> participantIds;
  final String? lastMessageId;
  final String? lastMessage;
  final DateTime? lastActivity;
  final Map<String, int> unreadCounts;
  final ChatRoomStatus status;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final bool isGroupChat;
  final String? groupName;
  final String? groupAvatar;

  EnhancedChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessageId,
    this.lastMessage,
    this.lastActivity,
    this.unreadCounts = const {},
    this.status = ChatRoomStatus.active,
    this.settings = const {},
    required this.createdAt,
    this.isGroupChat = false,
    this.groupName,
    this.groupAvatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastActivity': lastActivity,
      'unreadCounts': unreadCounts,
      'status': status.toString(),
      'settings': settings,
      'createdAt': createdAt,
      'isGroupChat': isGroupChat,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
    };
  }

  factory EnhancedChatRoom.fromJson(Map<String, dynamic> json) {
    return EnhancedChatRoom(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      lastMessageId: json['lastMessageId'],
      lastMessage: json['lastMessage'],
      lastActivity: json['lastActivity'] != null 
          ? (json['lastActivity'] as Timestamp).toDate() 
          : null,
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      status: ChatRoomStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ChatRoomStatus.active,
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isGroupChat: json['isGroupChat'] ?? false,
      groupName: json['groupName'],
      groupAvatar: json['groupAvatar'],
    );
  }
}

// 破冰話題模型
class IcebreakerTopic {
  final String id;
  final String question;
  final String category;
  final List<String> tags;
  final int popularityScore;
  final bool isPremium;

  IcebreakerTopic({
    required this.id,
    required this.question,
    required this.category,
    required this.tags,
    required this.popularityScore,
    required this.isPremium,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'tags': tags,
      'popularityScore': popularityScore,
      'isPremium': isPremium,
    };
  }

  factory IcebreakerTopic.fromJson(Map<String, dynamic> json) {
    return IcebreakerTopic(
      id: json['id'],
      question: json['question'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      popularityScore: json['popularityScore'],
      isPremium: json['isPremium'] ?? false,
    );
  }
}

// 消息擴展方法
extension EnhancedMessageExtension on EnhancedMessage {
  EnhancedMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    List<String>? reactions,
    bool? isAiGenerated,
    double? safetyScore,
  }) {
    return EnhancedMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      reactions: reactions ?? this.reactions,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      safetyScore: safetyScore ?? this.safetyScore,
    );
  }
} 