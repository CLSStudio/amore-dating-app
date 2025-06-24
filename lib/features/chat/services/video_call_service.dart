import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/config/app_config.dart';

/// 視頻通話服務
class VideoCallService {
  static RtcEngine? _engine;

  /// 初始化 Agora 引擎
  static Future<void> initialize(String appId) async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 Agora 引擎初始化成功');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ Agora 引擎初始化失敗: $e');
      }
      rethrow;
    }
  }

  /// 設置 Agora 引擎事件處理器
  static void setAgoraEventHandlers({
    Function(RtcConnection connection, int remoteUid, int elapsed)? onUserJoined,
    Function(RtcConnection connection, int remoteUid, UserOfflineReasonType reason)? onUserOffline,
    Function(RtcConnection connection, RtcStats stats)? onRtcStats,
    Function(ErrorCodeType err, String msg)? onError,
  }) {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (AppConfig.enableDebugLogs) {
            print('🎥 成功加入視頻通話頻道: ${connection.channelId}');
          }
        },
        onUserJoined: onUserJoined,
        onUserOffline: onUserOffline,
        onRtcStats: onRtcStats,
        onError: onError,
        onConnectionStateChanged: (RtcConnection connection, 
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          if (AppConfig.enableDebugLogs) {
            print('🔗 連接狀態變化: $state, 原因: $reason');
          }
        },
      ),
    );
  }

  /// 加入頻道
  static Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    try {
      await _engine?.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(),
      );
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 嘗試加入頻道: $channelName');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 加入頻道失敗: $e');
      }
      rethrow;
    }
  }

  /// 離開頻道
  static Future<void> leaveChannel() async {
    try {
      await _engine?.leaveChannel();
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 已離開視頻通話頻道');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 離開頻道失敗: $e');
      }
      rethrow;
    }
  }

  /// 開啟/關閉本地視頻
  static Future<void> enableLocalVideo(bool enabled) async {
    try {
      await _engine?.enableLocalVideo(enabled);
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 本地視頻${enabled ? '開啟' : '關閉'}');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 設置本地視頻失敗: $e');
      }
      rethrow;
    }
  }

  /// 開啟/關閉本地音頻
  static Future<void> enableLocalAudio(bool enabled) async {
    try {
      await _engine?.enableLocalAudio(enabled);
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 本地音頻${enabled ? '開啟' : '關閉'}');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 設置本地音頻失敗: $e');
      }
      rethrow;
    }
  }

  /// 切換攝像頭
  static Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 切換攝像頭');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 切換攝像頭失敗: $e');
      }
      rethrow;
    }
  }

  /// 釋放資源
  static Future<void> dispose() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
      
      if (AppConfig.enableDebugLogs) {
        print('🎥 Agora 引擎資源已釋放');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('❌ 釋放 Agora 引擎資源失敗: $e');
      }
    }
  }

  /// 獲取引擎實例
  static RtcEngine? get engine => _engine;
} 