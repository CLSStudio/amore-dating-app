import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

/// 對話模型
@JsonSerializable()
class ConversationModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, int> unreadCounts;
  final Map<String, DateTime> lastReadTimes;
  final ConversationType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? matchId;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.unreadCounts = const {},
    this.lastReadTimes = const {},
    this.type = ConversationType.match,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.matchId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'lastMessageTime': (data['lastMessageTime'] as Timestamp?)?.toDate().toIso8601String(),
      'lastReadTimes': (data['lastReadTimes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as Timestamp).toDate().toIso8601String()),
      ) ?? {},
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    
    if (json['createdAt'] != null) {
      json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    }
    if (json['updatedAt'] != null) {
      json['updatedAt'] = Timestamp.fromDate(DateTime.parse(json['updatedAt']));
    }
    if (json['lastMessageTime'] != null) {
      json['lastMessageTime'] = Timestamp.fromDate(DateTime.parse(json['lastMessageTime']));
    }
    if (json['lastReadTimes'] != null) {
      final lastReadTimes = json['lastReadTimes'] as Map<String, dynamic>;
      json['lastReadTimes'] = lastReadTimes.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(DateTime.parse(value))),
      );
    }
    
    return json;
  }

  /// 獲取對方用戶ID
  String getOtherParticipant(String currentUserId) {
    return participants.firstWhere((id) => id != currentUserId);
  }

  /// 獲取未讀消息數量
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}

/// 對話類型
enum ConversationType {
  match,      // 配對聊天
  group,      // 群組聊天 (未來功能)
  support,    // 客服支持
}

/// 消息模型
@JsonSerializable()
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.metadata,
    this.replyToMessageId,
    this.isEdited = false,
    this.editedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson({
      'id': doc.id,
      ...data,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      'editedAt': (data['editedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    
    if (json['timestamp'] != null) {
      json['timestamp'] = Timestamp.fromDate(DateTime.parse(json['timestamp']));
    }
    if (json['editedAt'] != null) {
      json['editedAt'] = Timestamp.fromDate(DateTime.parse(json['editedAt']));
    }
    
    return json;
  }

  /// 是否為媒體消息
  bool get isMedia => type != MessageType.text;

  /// 是否為圖片
  bool get isImage => type == MessageType.image;

  /// 是否為語音
  bool get isAudio => type == MessageType.audio;
}

/// 消息類型
enum MessageType {
  text,       // 文字消息
  image,      // 圖片
  audio,      // 語音
  video,      // 視頻
  file,       // 文件
  location,   // 位置
  sticker,    // 貼圖
  system,     // 系統消息
}

/// 消息狀態
enum MessageStatus {
  sending,    // 發送中
  sent,       // 已發送
  delivered,  // 已送達
  read,       // 已讀
  failed,     // 發送失敗
}

/// 輸入狀態模型
@JsonSerializable()
class TypingStatus {
  final String userId;
  final bool isTyping;
  final DateTime timestamp;

  TypingStatus({
    required this.userId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingStatus.fromJson(Map<String, dynamic> json) =>
      _$TypingStatusFromJson(json);

  Map<String, dynamic> toJson() => _$TypingStatusToJson(this);
} 