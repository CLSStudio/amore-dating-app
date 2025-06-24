import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  icebreaker,
  dateIdea,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? imageUrl;
  final String? audioUrl;
  final Map<String, dynamic>? metadata; // 用於破冰話題、約會建議等額外數據
  final bool isAiGenerated;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.imageUrl,
    this.audioUrl,
    this.metadata,
    this.isAiGenerated = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      metadata: json['metadata'],
      isAiGenerated: json['isAiGenerated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'metadata': metadata,
      'isAiGenerated': isAiGenerated,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? imageUrl,
    String? audioUrl,
    Map<String, dynamic>? metadata,
    bool? isAiGenerated,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      metadata: metadata ?? this.metadata,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }
}

class Chat {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final DateTime lastActivity;
  final Map<String, int> unreadCounts; // userId -> unread count
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const Chat({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.lastActivity,
    required this.unreadCounts,
    this.isActive = true,
    this.metadata,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage'])
          : null,
      lastActivity: (json['lastActivity'] as Timestamp).toDate(),
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': Timestamp.fromDate(lastActivity),
      'unreadCounts': unreadCounts,
      'isActive': isActive,
      'metadata': metadata,
    };
  }
}

class IcebreakerTopic {
  final String id;
  final String question;
  final String category;
  final List<String> suggestedResponses;
  final int difficulty; // 1-5, 1 = 輕鬆, 5 = 深度
  final List<String> tags;
  final bool isPersonalized; // 是否基於用戶 MBTI 個性化

  const IcebreakerTopic({
    required this.id,
    required this.question,
    required this.category,
    required this.suggestedResponses,
    required this.difficulty,
    required this.tags,
    this.isPersonalized = false,
  });

  factory IcebreakerTopic.fromJson(Map<String, dynamic> json) {
    return IcebreakerTopic(
      id: json['id'],
      question: json['question'],
      category: json['category'],
      suggestedResponses: List<String>.from(json['suggestedResponses']),
      difficulty: json['difficulty'],
      tags: List<String>.from(json['tags']),
      isPersonalized: json['isPersonalized'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'suggestedResponses': suggestedResponses,
      'difficulty': difficulty,
      'tags': tags,
      'isPersonalized': isPersonalized,
    };
  }
} 