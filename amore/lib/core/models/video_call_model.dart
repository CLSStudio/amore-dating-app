import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_call_model.g.dart';

/// 視頻通話模型
@JsonSerializable()
class VideoCallModel {
  final String id;
  final String callerId;
  final String receiverId;
  final String channelName;
  final String? agoraToken;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? duration; // 通話時長（秒）
  final String? endReason;

  VideoCallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.channelName,
    this.agoraToken,
    this.type = CallType.video,
    this.status = CallStatus.calling,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.duration,
    this.endReason,
  });

  factory VideoCallModel.fromJson(Map<String, dynamic> json) =>
      _$VideoCallModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCallModelToJson(this);

  factory VideoCallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoCallModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'startedAt': (data['startedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'endedAt': (data['endedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    
    if (json['createdAt'] != null) {
      json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    }
    if (json['startedAt'] != null) {
      json['startedAt'] = Timestamp.fromDate(DateTime.parse(json['startedAt']));
    }
    if (json['endedAt'] != null) {
      json['endedAt'] = Timestamp.fromDate(DateTime.parse(json['endedAt']));
    }
    
    return json;
  }

  /// 是否為語音通話
  bool get isAudioCall => type == CallType.audio;

  /// 是否為視頻通話
  bool get isVideoCall => type == CallType.video;

  /// 是否正在通話中
  bool get isOngoing => status == CallStatus.ongoing;

  /// 是否已結束
  bool get isEnded => status == CallStatus.ended;

  /// 獲取通話時長字符串
  String get durationString {
    if (duration == null) return '00:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 通話類型
enum CallType {
  audio,  // 語音通話
  video,  // 視頻通話
}

/// 通話狀態
enum CallStatus {
  calling,    // 撥打中
  ringing,    // 響鈴中
  ongoing,    // 進行中
  ended,      // 已結束
  missed,     // 未接通
  declined,   // 已拒絕
  failed,     // 失敗
}

/// 通話事件模型
@JsonSerializable()
class CallEvent {
  final String callId;
  final String userId;
  final CallEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  CallEvent({
    required this.callId,
    required this.userId,
    required this.type,
    required this.timestamp,
    this.data,
  });

  factory CallEvent.fromJson(Map<String, dynamic> json) =>
      _$CallEventFromJson(json);

  Map<String, dynamic> toJson() => _$CallEventToJson(this);
}

/// 通話事件類型
enum CallEventType {
  initiated,      // 發起通話
  answered,       // 接聽
  declined,       // 拒絕
  ended,          // 結束
  muted,          // 靜音
  unmuted,        // 取消靜音
  videoEnabled,   // 開啟視頻
  videoDisabled,  // 關閉視頻
  networkIssue,   // 網絡問題
} 