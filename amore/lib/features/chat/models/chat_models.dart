import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable()
class ChatRoom {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? matchId;
  final ChatRoomType type;

  const ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCounts = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.matchId,
    this.type = ChatRoomType.match,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'lastMessageTime': data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    if (lastMessageTime != null) {
      json['lastMessageTime'] = Timestamp.fromDate(lastMessageTime!);
    }
    return json;
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? matchId,
    ChatRoomType? type,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      matchId: matchId ?? this.matchId,
      type: type ?? this.type,
    );
  }
}

enum ChatRoomType {
  @JsonValue('match')
  match,
  @JsonValue('group')
  group,
  @JsonValue('support')
  support,
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final List<String> readBy;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.readBy = const [],
    this.replyToMessageId,
    this.metadata,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromJson({
      'id': doc.id,
      ...data,
      'timestamp': (data['timestamp'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['timestamp'] = Timestamp.fromDate(timestamp);
    return json;
  }

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    List<String>? readBy,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
    );
  }
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('voice')
  voice,
  @JsonValue('video')
  video,
  @JsonValue('location')
  location,
  @JsonValue('date_invitation')
  dateInvitation,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

@JsonSerializable()
class Match {
  final String id;
  final String userId1;
  final String userId2;
  final DateTime matchedAt;
  final double compatibilityScore;
  final List<String> compatibilityReasons;
  final MatchStatus status;
  final String? chatRoomId;
  final DateTime? lastInteractionAt;
  final Map<String, dynamic>? metadata;

  const Match({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.matchedAt,
    required this.compatibilityScore,
    this.compatibilityReasons = const [],
    this.status = MatchStatus.active,
    this.chatRoomId,
    this.lastInteractionAt,
    this.metadata,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match.fromJson({
      'id': doc.id,
      ...data,
      'matchedAt': (data['matchedAt'] as Timestamp).toDate().toIso8601String(),
      'lastInteractionAt': data['lastInteractionAt'] != null
          ? (data['lastInteractionAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['matchedAt'] = Timestamp.fromDate(matchedAt);
    if (lastInteractionAt != null) {
      json['lastInteractionAt'] = Timestamp.fromDate(lastInteractionAt!);
    }
    return json;
  }

  Match copyWith({
    String? id,
    String? userId1,
    String? userId2,
    DateTime? matchedAt,
    double? compatibilityScore,
    List<String>? compatibilityReasons,
    MatchStatus? status,
    String? chatRoomId,
    DateTime? lastInteractionAt,
    Map<String, dynamic>? metadata,
  }) {
    return Match(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      matchedAt: matchedAt ?? this.matchedAt,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      compatibilityReasons: compatibilityReasons ?? this.compatibilityReasons,
      status: status ?? this.status,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // 獲取對方用戶 ID
  String getOtherUserId(String currentUserId) {
    return userId1 == currentUserId ? userId2 : userId1;
  }
}

enum MatchStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('blocked')
  blocked,
  @JsonValue('unmatched')
  unmatched,
}

@JsonSerializable()
class DateInvitation {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String chatRoomId;
  final String title;
  final String description;
  final DateTime proposedDate;
  final String location;
  final DateInvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseMessage;
  final Map<String, dynamic>? metadata;

  const DateInvitation({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.chatRoomId,
    required this.title,
    required this.description,
    required this.proposedDate,
    required this.location,
    this.status = DateInvitationStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.responseMessage,
    this.metadata,
  });

  factory DateInvitation.fromJson(Map<String, dynamic> json) => _$DateInvitationFromJson(json);
  Map<String, dynamic> toJson() => _$DateInvitationToJson(this);

  factory DateInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DateInvitation.fromJson({
      'id': doc.id,
      ...data,
      'proposedDate': (data['proposedDate'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'respondedAt': data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['proposedDate'] = Timestamp.fromDate(proposedDate);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    if (respondedAt != null) {
      json['respondedAt'] = Timestamp.fromDate(respondedAt!);
    }
    return json;
  }

  DateInvitation copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? chatRoomId,
    String? title,
    String? description,
    DateTime? proposedDate,
    String? location,
    DateInvitationStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? responseMessage,
    Map<String, dynamic>? metadata,
  }) {
    return DateInvitation(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      title: title ?? this.title,
      description: description ?? this.description,
      proposedDate: proposedDate ?? this.proposedDate,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum DateInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

@JsonSerializable()
class IceBreaker {
  final String id;
  final String text;
  final String category;
  final List<String> tags;
  final String? mbtiType;
  final int popularity;
  final bool isActive;

  const IceBreaker({
    required this.id,
    required this.text,
    required this.category,
    this.tags = const [],
    this.mbtiType,
    this.popularity = 0,
    this.isActive = true,
  });

  factory IceBreaker.fromJson(Map<String, dynamic> json) => _$IceBreakerFromJson(json);
  Map<String, dynamic> toJson() => _$IceBreakerToJson(this);
} 