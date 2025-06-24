import 'dart:async';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'auth_service.dart';
import '../../features/matching/services/matching_service.dart';
import '../../features/chat/services/chat_service.dart';
import '../../features/chat/services/video_call_service.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/chat_model.dart';
import '../models/video_call_model.dart';
import '../app_config.dart';

/// 應用服務管理器
/// 統一管理所有核心服務，提供高級 API
class AppServiceManager {
  static AppServiceManager? _instance;
  static AppServiceManager get instance => _instance ??= AppServiceManager._();
  
  AppServiceManager._();

  bool _initialized = false;
  StreamSubscription? _authSubscription;
  StreamSubscription? _incomingCallSubscription;

  /// 初始化服務管理器
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 監聽用戶認證狀態變化
      _authSubscription = AuthService.authStateChanges.listen((user) {
        if (user != null) {
          _setupUserServices(user.uid);
        } else {
          _cleanupUserServices();
        }
      });

      // 初始化視頻通話服務
      await VideoCallService.initializeAgora();

      _initialized = true;
      
      if (AppConfig.enableDebugLogs) {
        print('✅ 應用服務管理器初始化完成');
      }
    } catch (e, stackTrace) {
      await FirebaseService.recordError(
        exception: e,
        stackTrace: stackTrace,
        additionalData: {'method': 'AppServiceManager.initialize'},
      );
    }
  }

  /// 設置用戶相關服務
  void _setupUserServices(String userId) {
    // 監聽來電
    _incomingCallSubscription = VideoCallService
        .listenForIncomingCalls(userId)
        .listen((call) {
      if (call != null) {
        _handleIncomingCall(call);
      }
    });

    if (AppConfig.enableDebugLogs) {
      print('📱 用戶服務已設置: $userId');
    }
  }

  /// 清理用戶服務
  void _cleanupUserServices() {
    _incomingCallSubscription?.cancel();
    
    if (AppConfig.enableDebugLogs) {
      print('🧹 用戶服務已清理');
    }
  }

  /// 處理來電
  void _handleIncomingCall(VideoCallModel call) {
    // 這裡可以顯示來電界面或發送本地通知
    // 實際實現時會與 UI 層集成
    if (AppConfig.enableDebugLogs) {
      print('📞 收到來電: ${call.callerId}');
    }
  }

  // === 配對相關 API ===

  /// 獲取配對候選人
  Future<List<MatchCandidate>> getMatchCandidates({
    required String userId,
    int limit = 20,
  }) async {
    return MatchingService.getMatchCandidates(userId: userId, limit: limit);
  }

  /// 處理滑卡動作
  Future<MatchModel?> handleSwipe({
    required String userId,
    required String targetUserId,
    required bool isLike,
  }) async {
    final match = await MatchingService.handleSwipeAction(
      userId: userId,
      targetUserId: targetUserId,
      isLike: isLike,
    );

    // 如果是配對成功，自動創建對話
    if (match != null) {
      await ChatService.createOrGetConversation(
        userId1: userId,
        userId2: targetUserId,
        matchId: match.id,
      );
      
      // 發送配對成功的系統消息
      final conversationId = _generateConversationId(userId, targetUserId);
      await ChatService.sendTextMessage(
        conversationId: conversationId,
        senderId: 'system',
        content: '🎉 恭喜！你們成功配對了！現在可以開始聊天了。',
      );
    }

    return match;
  }

  /// 獲取用戶配對列表
  Future<List<MatchModel>> getUserMatches(String userId) async {
    return MatchingService.getUserMatches(userId);
  }

  // === 聊天相關 API ===

  /// 獲取對話列表
  Stream<List<ConversationModel>> getUserConversations(String userId) {
    return ChatService.getUserConversations(userId);
  }

  /// 創建或獲取對話
  Future<ConversationModel?> createOrGetConversation({
    required String userId1,
    required String userId2,
    String? matchId,
  }) async {
    return ChatService.createOrGetConversation(
      userId1: userId1,
      userId2: userId2,
      matchId: matchId,
    );
  }

  /// 發送文字消息
  Future<MessageModel?> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? replyToMessageId,
  }) async {
    return ChatService.sendTextMessage(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      replyToMessageId: replyToMessageId,
    );
  }

  /// 獲取對話消息
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return ChatService.getMessages(conversationId);
  }

  /// 標記消息為已讀
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    return ChatService.markMessagesAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  /// 設置輸入狀態
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    return ChatService.setTypingStatus(
      conversationId: conversationId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  /// 獲取輸入狀態
  Stream<List<TypingStatus>> getTypingStatus(String conversationId) {
    return ChatService.getTypingStatus(conversationId);
  }

  // === 視頻通話相關 API ===

  /// 發起視頻通話
  Future<VideoCallModel?> startVideoCall({
    required String callerId,
    required String receiverId,
    CallType type = CallType.video,
  }) async {
    return VideoCallService.startVideoCall(
      callerId: callerId,
      receiverId: receiverId,
      type: type,
    );
  }

  /// 接聽通話
  Future<bool> acceptCall(String callId) async {
    return VideoCallService.acceptCall(callId);
  }

  /// 拒絕通話
  Future<bool> declineCall(String callId, {String reason = 'declined'}) async {
    return VideoCallService.declineCall(callId, reason);
  }

  /// 結束通話
  Future<bool> endCall(String callId, {String reason = 'ended_by_user'}) async {
    return VideoCallService.endCall(callId, reason);
  }

  /// 監聽通話狀態
  Stream<VideoCallModel?> watchCall(String callId) {
    return VideoCallService.watchCall(callId);
  }

  /// 獲取通話歷史
  Future<List<VideoCallModel>> getCallHistory(String userId) async {
    return VideoCallService.getCallHistory(userId);
  }

  /// 檢查視頻通話支持
  Future<bool> isVideoCallSupported() async {
    return VideoCallService.isVideoCallSupported();
  }

  // === 用戶管理 API ===

  /// 獲取用戶檔案
  Future<UserModel?> getUserProfile(String userId) async {
    return AuthService.getUserProfile(userId);
  }

  /// 更新用戶在線狀態
  Future<void> updateUserPresence(bool isOnline) async {
    return FirebaseService.updateUserPresence(isOnline);
  }

  /// 封鎖用戶
  Future<bool> blockUser({
    required String userId,
    required String blockedUserId,
    required String conversationId,
  }) async {
    return ChatService.blockUser(
      userId: userId,
      blockedUserId: blockedUserId,
      conversationId: conversationId,
    );
  }

  // === 數據分析 API ===

  /// 記錄用戶行為事件
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    return FirebaseService.logEvent(name: name, parameters: parameters);
  }

  /// 記錄錯誤
  Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    return FirebaseService.recordError(
      exception: exception,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }

  // === 應用配置 API ===

  /// 獲取遠程配置值
  T getRemoteConfigValue<T>(String key, T defaultValue) {
    return FirebaseService.getRemoteConfigValue(key, defaultValue);
  }

  /// 檢查功能是否啟用
  bool isFeatureEnabled(String featureName) {
    switch (featureName) {
      case 'video_call':
        return AppConfig.enableVideoCall && 
               getRemoteConfigValue('feature_video_call_enabled', true);
      case 'voice_call':
        return AppConfig.enableVoiceCall && 
               getRemoteConfigValue('feature_voice_call_enabled', true);
      default:
        return false;
    }
  }

  /// 獲取當前用戶
  UserModel? get currentUser {
    final firebaseUser = AuthService.currentUser;
    if (firebaseUser == null) return null;
    
    // 這裡可以返回緩存的用戶信息
    // 實際實現時可能需要從本地存儲獲取
    return null;
  }

  /// 是否已登錄
  bool get isLoggedIn => AuthService.isLoggedIn;

  /// 釋放資源
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _incomingCallSubscription?.cancel();
    await VideoCallService.dispose();
    _initialized = false;
    
    if (AppConfig.enableDebugLogs) {
      print('🔌 應用服務管理器已清理');
    }
  }

  /// 生成對話ID
  String _generateConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
} 