# Amore 功能使用指南

## 📖 概述

本指南介紹如何使用 Amore 應用的三個核心功能：智能配對算法、實時聊天和視頻通話服務。

## 🎯 智能配對算法

### 基本使用

```dart
import 'package:amore/core/services/app_service_manager.dart';

class MatchingController {
  final _serviceManager = AppServiceManager.instance;
  
  /// 獲取配對候選人
  Future<List<MatchCandidate>> loadCandidates() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    
    return await _serviceManager.getMatchCandidates(
      userId: userId,
      limit: 20,
    );
  }
  
  /// 處理滑卡動作
  Future<void> handleSwipe(String targetUserId, bool isLike) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    final match = await _serviceManager.handleSwipe(
      userId: userId,
      targetUserId: targetUserId,
      isLike: isLike,
    );
    
    if (match != null) {
      // 配對成功！顯示配對動畫或導航到聊天頁面
      print('🎉 配對成功！兼容性評分: ${match.compatibilityScore}');
    }
  }
}
```

### 配對算法詳細

配對算法基於以下因素計算兼容性評分：

- **MBTI 兼容性** (30%): 基於 16 型人格的匹配度
- **興趣匹配** (25%): 共同興趣和愛好
- **年齡兼容** (15%): 年齡差距和偏好
- **地理位置** (15%): 距離和位置偏好
- **價值觀匹配** (10%): 關係目標和生活方式
- **活躍度** (5%): 用戶活躍程度

### 自定義配對參數

```dart
class CustomMatchingService extends MatchingService {
  /// 自定義 MBTI 兼容性矩陣
  static void updateMBTICompatibility() {
    // 可以根據實際數據分析結果調整兼容性評分
    MBTICompatibility.compatibilityMatrix['INTJ']?['ENFP'] = 0.95;
  }
  
  /// 添加自定義評分因素
  static double calculateCustomScore(UserModel user1, UserModel user2) {
    double score = 0.0;
    
    // 教育程度匹配
    if (user1.education == user2.education) {
      score += 0.1;
    }
    
    // 職業兼容性
    if (_areCompatibleProfessions(user1.occupation, user2.occupation)) {
      score += 0.15;
    }
    
    return score;
  }
}
```

## 💬 實時聊天功能

### 基本聊天實現

```dart
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  
  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.otherUserId,
  }) : super(key: key);
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _serviceManager = AppServiceManager.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天'),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: _startAudioCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _serviceManager.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageWidget(message: messages[index]);
                  },
                );
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '輸入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: _onTyping,
              onSubmitted: _sendMessage,
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () => _sendMessage(_messageController.text),
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return StreamBuilder<List<TypingStatus>>(
      stream: _serviceManager.getTypingStatus(widget.conversationId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }
        
        final typingUsers = snapshot.data!
            .where((status) => status.userId != widget.otherUserId)
            .toList();
            
        if (typingUsers.isEmpty) return SizedBox.shrink();
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '對方正在輸入...',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }
  
  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    await _serviceManager.sendTextMessage(
      conversationId: widget.conversationId,
      senderId: userId,
      content: content.trim(),
    );
    
    _messageController.clear();
    _stopTyping();
  }
  
  void _onTyping(String text) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    _serviceManager.setTypingStatus(
      conversationId: widget.conversationId,
      userId: userId,
      isTyping: text.isNotEmpty,
    );
  }
  
  void _stopTyping() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    _serviceManager.setTypingStatus(
      conversationId: widget.conversationId,
      userId: userId,
      isTyping: false,
    );
  }
  
  void _markMessagesAsRead() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    _serviceManager.markMessagesAsRead(
      conversationId: widget.conversationId,
      userId: userId,
    );
  }
  
  void _startVideoCall() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    final call = await _serviceManager.startVideoCall(
      callerId: userId,
      receiverId: widget.otherUserId,
      type: CallType.video,
    );
    
    if (call != null) {
      // 導航到視頻通話頁面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(callId: call.id),
        ),
      );
    }
  }
  
  void _startAudioCall() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    final call = await _serviceManager.startVideoCall(
      callerId: userId,
      receiverId: widget.otherUserId,
      type: CallType.audio,
    );
    
    if (call != null) {
      // 導航到語音通話頁面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioCallScreen(callId: call.id),
        ),
      );
    }
  }
}
```

### 發送媒體消息

```dart
class MediaMessageService {
  static final _serviceManager = AppServiceManager.instance;
  
  /// 發送圖片消息
  static Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required File imageFile,
    String? caption,
  }) async {
    await ChatService.sendImageMessage(
      conversationId: conversationId,
      senderId: senderId,
      imageFile: imageFile,
      caption: caption,
    );
  }
  
  /// 發送語音消息
  static Future<void> sendAudioMessage({
    required String conversationId,
    required String senderId,
    required File audioFile,
    required Duration duration,
  }) async {
    await ChatService.sendAudioMessage(
      conversationId: conversationId,
      senderId: senderId,
      audioFile: audioFile,
      duration: duration,
    );
  }
}
```

## 🎥 視頻通話功能

### 基本視頻通話實現

```dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  
  const VideoCallScreen({Key? key, required this.callId}) : super(key: key);
  
  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _serviceManager = AppServiceManager.instance;
  RtcEngine? _engine;
  
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isSpeakerEnabled = true;
  int? _remoteUserId;
  VideoCallModel? _currentCall;
  
  @override
  void initState() {
    super.initState();
    _initializeCall();
  }
  
  void _initializeCall() async {
    _engine = VideoCallService.engine;
    
    // 設置事件處理器
    VideoCallService.setAgoraEventHandlers(
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() {
          _remoteUserId = remoteUid;
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() {
          _remoteUserId = null;
        });
      },
      onError: (connection, err) {
        print('Agora 錯誤: $err');
      },
    );
    
    // 監聽通話狀態
    _serviceManager.watchCall(widget.callId).listen((call) {
      if (call != null) {
        setState(() {
          _currentCall = call;
        });
        
        if (call.isEnded) {
          _endCall();
        }
      }
    });
    
    // 加入頻道
    final call = await VideoCallService.getCall(widget.callId);
    if (call != null) {
      await VideoCallService.joinChannel(
        channelName: call.channelName,
        token: call.agoraToken ?? '',
        uid: 0, // 讓 Agora 自動分配 UID
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 遠程視頻視圖
          if (_remoteUserId != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUserId),
                connection: RtcConnection(channelId: _currentCall?.channelName),
              ),
            ),
          
          // 本地視頻視圖
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
          
          // 控制按鈕
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                  onPressed: _toggleAudio,
                  backgroundColor: _isAudioEnabled ? Colors.white : Colors.red,
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: _endCall,
                  backgroundColor: Colors.red,
                ),
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoEnabled ? Colors.white : Colors.red,
                ),
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  onPressed: _switchCamera,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          
          // 通話信息
          Positioned(
            top: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentCall != null) ...[
                  Text(
                    _getCallStatusText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentCall!.isOngoing)
                    Text(
                      _formatDuration(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
  
  void _toggleAudio() async {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    await VideoCallService.toggleMicrophone(_isAudioEnabled);
  }
  
  void _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await VideoCallService.toggleCamera(_isVideoEnabled);
  }
  
  void _switchCamera() async {
    await VideoCallService.switchCamera();
  }
  
  void _endCall() async {
    await _serviceManager.endCall(widget.callId);
    Navigator.of(context).pop();
  }
  
  String _getCallStatusText() {
    if (_currentCall == null) return '連接中...';
    
    switch (_currentCall!.status) {
      case CallStatus.calling:
        return '撥打中...';
      case CallStatus.ringing:
        return '響鈴中...';
      case CallStatus.ongoing:
        return '通話中';
      default:
        return '連接中...';
    }
  }
  
  String _formatDuration() {
    if (_currentCall?.startedAt == null) return '00:00';
    
    final duration = DateTime.now().difference(_currentCall!.startedAt!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    VideoCallService.leaveChannel();
    super.dispose();
  }
}
```

### 來電處理

```dart
class IncomingCallManager {
  static final _serviceManager = AppServiceManager.instance;
  
  /// 設置來電監聽
  static void setupIncomingCallListener(String userId) {
    VideoCallService.listenForIncomingCalls(userId).listen((call) {
      if (call != null) {
        _showIncomingCallDialog(call);
      }
    });
  }
  
  /// 顯示來電對話框
  static void _showIncomingCallDialog(VideoCallModel call) {
    // 顯示全屏來電界面或對話框
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(call: call),
    );
  }
}

class IncomingCallDialog extends StatelessWidget {
  final VideoCallModel call;
  
  const IncomingCallDialog({Key? key, required this.call}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage('USER_AVATAR_URL'),
            ),
            SizedBox(height: 20),
            Text(
              '來電',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              call.isVideoCall ? '視頻通話' : '語音通話',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 拒絕按鈕
                GestureDetector(
                  onTap: () async {
                    await AppServiceManager.instance.declineCall(call.id);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                // 接聽按鈕
                GestureDetector(
                  onTap: () async {
                    await AppServiceManager.instance.acceptCall(call.id);
                    Navigator.of(context).pop();
                    
                    // 導航到通話頁面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(callId: call.id),
                      ),
                    );
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      call.isVideoCall ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🛠️ 配置和設置

### Agora 配置

1. 在 [Agora Console](https://console.agora.io/) 創建項目
2. 獲取 App ID 並更新 `VideoCallService` 中的 `_agoraAppId`
3. 為生產環境配置 Token 服務器

### Firebase 規則設置

```javascript
// Firestore 安全規則示例
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 配對相關
    match /matches/{matchId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid in resource.data.participants);
    }
    
    // 滑卡記錄
    match /swipes/{swipeId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // 視頻通話
    match /video_chats/{callId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.callerId || 
         request.auth.uid == resource.data.receiverId);
    }
  }
}
```

## 📈 性能優化建議

### 配對算法優化

1. **緩存策略**: 緩存用戶檔案和配對結果
2. **分頁加載**: 實現無限滾動加載更多候選人
3. **後台預計算**: 使用 Cloud Functions 預計算兼容性評分

### 聊天性能優化

1. **消息分頁**: 實現消息歷史分頁加載
2. **圖片壓縮**: 上傳前壓縮圖片以節省存儲和帶寬
3. **離線支持**: 實現離線消息緩存

### 視頻通話優化

1. **網絡自適應**: 根據網絡狀況調整視頻質量
2. **回聲消除**: 啟用 Agora 的音頻處理功能
3. **美顏功能**: 集成實時美顏 SDK

## 🚀 部署檢查清單

- [ ] Firebase 項目已配置完成
- [ ] Agora 項目已創建並獲取 App ID
- [ ] 推送通知已配置
- [ ] 安全規則已設置
- [ ] 已生成必要的 JSON 序列化代碼
- [ ] 權限配置已添加到 Android/iOS 項目
- [ ] 測試所有核心功能

## 📞 技術支持

如有任何問題，請參考：

- [Firebase 文檔](https://firebase.google.com/docs)
- [Agora 文檔](https://docs.agora.io/)
- [Flutter 文檔](https://flutter.dev/docs)

或聯繫開發團隊獲取支持。 