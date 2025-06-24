import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase_config.dart';

/// Amore 視頻通話服務
/// 專為 Android 和 iOS 移動平台設計
/// 使用 Agora RTC 引擎提供高質量視頻通話體驗

// 視頻通話服務提供者
final videoCallServiceProvider = Provider<VideoCallService>((ref) {
  return VideoCallService();
});

// 通話狀態枚舉
enum CallStatus {
  idle,           // 空閒
  calling,        // 撥打中
  ringing,        // 響鈴中
  connecting,     // 連接中
  connected,      // 已連接
  ended,          // 已結束
  declined,       // 已拒絕
  missed,         // 未接聽
  failed,         // 失敗
}

// 通話類型枚舉
enum CallType {
  video,          // 視頻通話
  audio,          // 語音通話
}

// 通話記錄模型
class CallRecord {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? channelName;
  final Map<String, dynamic> metadata;

  CallRecord({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.channelName,
    this.metadata = const {},
  });

  factory CallRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallRecord(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.toString() == 'CallType.${data['type']}',
        orElse: () => CallType.video,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == 'CallStatus.${data['status']}',
        orElse: () => CallStatus.idle,
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      duration: data['duration'] != null 
          ? Duration(seconds: data['duration'] as int)
          : null,
      channelName: data['channelName'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration?.inSeconds,
      'channelName': channelName,
      'metadata': metadata,
    };
  }
}

// 通話邀請模型
class CallInvitation {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerPhoto;
  final String receiverId;
  final CallType type;
  final String channelName;
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;

  CallInvitation({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerPhoto,
    required this.receiverId,
    required this.type,
    required this.channelName,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
  });

  factory CallInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallInvitation(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      callerPhoto: data['callerPhoto'],
      receiverId: data['receiverId'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.toString() == 'CallType.${data['type']}',
        orElse: () => CallType.video,
      ),
      channelName: data['channelName'] ?? '',
      token: data['token'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'channelName': channelName,
      'token': token,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}

class VideoCallService {
  // 簡化的視頻通話服務，用於演示
  
  void Function(CallRecord)? onCallStatusChanged;
  void Function(int, bool)? onUserJoined;
  void Function(int)? onUserLeft;
  
  Future<void> initiateCall({
    required String receiverId,
    required CallType type,
  }) async {
    // 模擬發起通話
    await Future.delayed(const Duration(seconds: 1));
    print('發起通話給: $receiverId, 類型: $type');
  }
  
  Future<void> acceptCall(CallInvitation invitation) async {
    // 模擬接聽通話
    await Future.delayed(const Duration(milliseconds: 500));
    print('接聽通話');
  }
  
  Future<void> declineCall(CallInvitation invitation) async {
    // 模擬拒絕通話
    await Future.delayed(const Duration(milliseconds: 500));
    print('拒絕通話');
  }
  
  Future<void> endCall() async {
    // 模擬結束通話
    await Future.delayed(const Duration(milliseconds: 500));
    print('結束通話');
  }
  
  Future<void> toggleMute() async {
    // 模擬切換靜音
    print('切換靜音');
  }
  
  Future<void> toggleVideo() async {
    // 模擬切換視頻
    print('切換視頻');
  }
  
  Future<void> toggleSpeaker() async {
    // 模擬切換揚聲器
    print('切換揚聲器');
  }
  
  Future<void> switchCamera() async {
    // 模擬切換攝像頭
    print('切換攝像頭');
  }
  
  Widget createRemoteVideoView(int uid) {
    // 模擬遠程視頻視圖
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget createLocalVideoView() {
    // 模擬本地視頻視圖
    return Container(
      color: Colors.grey.shade700,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

// 監聽來電
Stream<CallInvitation?> listenForIncomingCalls() {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return Stream.value(null);

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('call_invitations')
      .where('receiverId', isEqualTo: currentUserId)
      .where('expiresAt', isGreaterThan: DateTime.now())
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return CallInvitation.fromFirestore(snapshot.docs.first);
    }
    return null;
  });
}

// 獲取通話記錄
Stream<List<CallRecord>> getCallHistory() {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('call_records')
      .where('participants', arrayContains: currentUserId)
      .orderBy('startTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CallRecord.fromFirestore(doc))
          .toList());
}

// 獲取通話統計
Future<Map<String, dynamic>> getCallStats() async {
  // 這裡可以獲取通話質量統計信息
  return {
    'isInCall': false,
    'channelName': null,
    'callDuration': 0,
  };
}

// 檢查通話權限
Future<bool> checkCallPermissions() async {
  final cameraStatus = await Permission.camera.status;
  final microphoneStatus = await Permission.microphone.status;
  
  return cameraStatus.isGranted && microphoneStatus.isGranted;
}

// 測試網絡質量
Future<void> startNetworkTest() async {
  // 這裡可以啟動網絡質量測試
}

Future<void> stopNetworkTest() async {
  // 這裡可以停止網絡質量測試
}

// 設置音頻配置
Future<void> setAudioProfile({
  // AudioProfileType profile = AudioProfileType.audioProfileDefault,
  // AudioScenarioType scenario = AudioScenarioType.audioScenarioDefault,
  String profile = 'default',
  String scenario = 'default',
}) async {
  // 這裡可以設置音頻配置
}

// 設置視頻配置
Future<void> setVideoProfile({
  int width = 640,
  int height = 480,
  int frameRate = 15,
  int bitrate = 0,
}) async {
  // 這裡可以設置視頻配置
}

// 啟用/禁用美顏
Future<void> setBeautyEffect({
  bool enabled = true,
  double lighteningLevel = 0.7,
  double smoothnessLevel = 0.5,
  double rednessLevel = 0.1,
}) async {
  // 這裡可以啟用或禁用美顏效果
}

// 清理資源
Future<void> dispose() async {
  // 這裡可以清理視頻通話服務的資源
}

// Getter 方法
bool get isInitialized => false;
bool get isInCall => false;
CallRecord? get currentCall => null;
String? get currentChannelName => null;