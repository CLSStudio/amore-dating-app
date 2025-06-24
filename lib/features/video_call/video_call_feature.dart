import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// 通話狀態
enum CallStatus {
  idle,
  calling,
  ringing,
  connected,
  ended,
  declined,
  missed,
  busy,
}

// 通話類型
enum CallType {
  video,
  audio,
}

// 通話模型
class VideoCall {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final bool isIncoming;
  final Map<String, dynamic>? metadata;

  VideoCall({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.isIncoming,
    this.metadata,
  });

  VideoCall copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    CallType? type,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    bool? isIncoming,
    Map<String, dynamic>? metadata,
  }) {
    return VideoCall(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isIncoming: isIncoming ?? this.isIncoming,
      metadata: metadata ?? this.metadata,
    );
  }

  String get otherUserName => isIncoming ? callerName : receiverName;
  String get otherUserAvatar => isIncoming ? callerAvatar : receiverAvatar;
  String get otherUserId => isIncoming ? callerId : receiverId;
}

// 通話設置
class CallSettings {
  final bool videoEnabled;
  final bool audioEnabled;
  final bool speakerEnabled;
  final bool frontCameraEnabled;
  final double volume;

  CallSettings({
    this.videoEnabled = true,
    this.audioEnabled = true,
    this.speakerEnabled = false,
    this.frontCameraEnabled = true,
    this.volume = 1.0,
  });

  CallSettings copyWith({
    bool? videoEnabled,
    bool? audioEnabled,
    bool? speakerEnabled,
    bool? frontCameraEnabled,
    double? volume,
  }) {
    return CallSettings(
      videoEnabled: videoEnabled ?? this.videoEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      speakerEnabled: speakerEnabled ?? this.speakerEnabled,
      frontCameraEnabled: frontCameraEnabled ?? this.frontCameraEnabled,
      volume: volume ?? this.volume,
    );
  }
}

// 通話狀態管理
final currentCallProvider = StateProvider<VideoCall?>((ref) => null);
final callSettingsProvider = StateProvider<CallSettings>((ref) => CallSettings());
final callHistoryProvider = StateNotifierProvider<CallHistoryNotifier, List<VideoCall>>((ref) {
  return CallHistoryNotifier();
});

class CallHistoryNotifier extends StateNotifier<List<VideoCall>> {
  CallHistoryNotifier() : super([]) {
    _loadSampleCallHistory();
  }

  void _loadSampleCallHistory() {
    final now = DateTime.now();
    final sampleCalls = [
      VideoCall(
        id: 'call_1',
        callerId: 'current_user',
        callerName: '我',
        callerAvatar: '😊',
        receiverId: '1',
        receiverName: '小雅',
        receiverAvatar: '👩‍🦰',
        type: CallType.video,
        status: CallStatus.ended,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -15)),
        duration: const Duration(minutes: 15),
        isIncoming: false,
      ),
      VideoCall(
        id: 'call_2',
        callerId: '2',
        callerName: '志明',
        callerAvatar: '👨‍💻',
        receiverId: 'current_user',
        receiverName: '我',
        receiverAvatar: '😊',
        type: CallType.video,
        status: CallStatus.missed,
        startTime: now.subtract(const Duration(hours: 5)),
        isIncoming: true,
      ),
      VideoCall(
        id: 'call_3',
        callerId: 'current_user',
        callerName: '我',
        callerAvatar: '😊',
        receiverId: '3',
        receiverName: '美玲',
        receiverAvatar: '🧘‍♀️',
        type: CallType.audio,
        status: CallStatus.ended,
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, minutes: -8)),
        duration: const Duration(minutes: 8),
        isIncoming: false,
      ),
    ];
    
    state = sampleCalls;
  }

  void addCall(VideoCall call) {
    state = [call, ...state];
  }

  void updateCall(VideoCall updatedCall) {
    state = state.map((call) {
      return call.id == updatedCall.id ? updatedCall : call;
    }).toList();
  }

  void removeCall(String callId) {
    state = state.where((call) => call.id != callId).toList();
  }
}

// 視頻通話服務
class VideoCallService {
  static Future<VideoCall> initiateCall({
    required String receiverId,
    required String receiverName,
    required String receiverAvatar,
    required CallType type,
  }) async {
    final call = VideoCall(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: 'current_user',
      callerName: '我',
      callerAvatar: '😊',
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatar: receiverAvatar,
      type: type,
      status: CallStatus.calling,
      startTime: DateTime.now(),
      isIncoming: false,
    );

    // 模擬網絡延遲
    await Future.delayed(const Duration(seconds: 1));
    
    return call;
  }

  static Future<void> answerCall(VideoCall call) async {
    // 模擬接聽通話
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> declineCall(VideoCall call) async {
    // 模擬拒絕通話
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> endCall(VideoCall call) async {
    // 模擬結束通話
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<bool> checkCallPermissions() async {
    // 檢查相機和麥克風權限
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // 模擬權限已授予
  }
}

// 通話邀請頁面
class CallInvitePage extends ConsumerStatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  final CallType callType;

  const CallInvitePage({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    required this.callType,
  });

  @override
  ConsumerState<CallInvitePage> createState() => _CallInvitePageState();
}

class _CallInvitePageState extends ConsumerState<CallInvitePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  VideoCall? _currentCall;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initiateCall();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initiateCall() async {
    try {
      final call = await VideoCallService.initiateCall(
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        receiverAvatar: widget.receiverAvatar,
        type: widget.callType,
      );

      setState(() {
        _currentCall = call;
      });

      ref.read(currentCallProvider.notifier).state = call;
      ref.read(callHistoryProvider.notifier).addCall(call);

      // 模擬對方響應
      _simulateCallResponse();
    } catch (e) {
      _showErrorAndExit('無法發起通話');
    }
  }

  Future<void> _simulateCallResponse() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted || _currentCall == null) return;

    // 隨機決定對方是否接聽
    final random = math.Random();
    final willAnswer = random.nextBool();

    if (willAnswer) {
      _connectCall();
    } else {
      _declineCall();
    }
  }

  void _connectCall() {
    if (_currentCall == null) return;

    final connectedCall = _currentCall!.copyWith(
      status: CallStatus.connected,
    );

    setState(() {
      _currentCall = connectedCall;
      _isConnecting = true;
    });

    ref.read(currentCallProvider.notifier).state = connectedCall;
    ref.read(callHistoryProvider.notifier).updateCall(connectedCall);

    // 進入通話界面
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallPage(call: connectedCall),
          ),
        );
      }
    });
  }

  void _declineCall() {
    if (_currentCall == null) return;

    final declinedCall = _currentCall!.copyWith(
      status: CallStatus.declined,
      endTime: DateTime.now(),
    );

    ref.read(currentCallProvider.notifier).state = null;
    ref.read(callHistoryProvider.notifier).updateCall(declinedCall);

    _showMessageAndExit('對方拒絕了通話');
  }

  void _endCall() {
    if (_currentCall == null) return;

    final endedCall = _currentCall!.copyWith(
      status: CallStatus.ended,
      endTime: DateTime.now(),
    );

    ref.read(currentCallProvider.notifier).state = null;
    ref.read(callHistoryProvider.notifier).updateCall(endedCall);

    Navigator.pop(context);
  }

  void _showErrorAndExit(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  void _showMessageAndExit(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildCallContent()),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _endCall,
          ),
          Expanded(
            child: Text(
              _getCallStatusText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showCallOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildCallContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 用戶頭像
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isConnecting ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 76,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    widget.receiverAvatar,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // 用戶名稱
        Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 通話狀態
        Text(
          _getCallStatusText(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        
        if (_isConnecting) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 靜音按鈕
          _buildActionButton(
            icon: Icons.mic_off,
            color: Colors.grey[700]!,
            onPressed: () => _toggleMute(),
          ),
          
          // 結束通話按鈕
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            size: 64,
            onPressed: _endCall,
          ),
          
          // 切換攝像頭按鈕（僅視頻通話）
          if (widget.callType == CallType.video)
            _buildActionButton(
              icon: Icons.flip_camera_ios,
              color: Colors.grey[700]!,
              onPressed: () => _switchCamera(),
            )
          else
            _buildActionButton(
              icon: Icons.volume_up,
              color: Colors.grey[700]!,
              onPressed: () => _toggleSpeaker(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  String _getCallStatusText() {
    if (_isConnecting) return '正在連接...';
    
    switch (_currentCall?.status) {
      case CallStatus.calling:
        return '正在呼叫...';
      case CallStatus.ringing:
        return '響鈴中...';
      case CallStatus.connected:
        return '已連接';
      case CallStatus.declined:
        return '通話被拒絕';
      case CallStatus.ended:
        return '通話已結束';
      default:
        return widget.callType == CallType.video ? '視頻通話' : '語音通話';
    }
  }

  void _toggleMute() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      audioEnabled: !settings.audioEnabled,
    );
  }

  void _switchCamera() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      frontCameraEnabled: !settings.frontCameraEnabled,
    );
  }

  void _toggleSpeaker() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      speakerEnabled: !settings.speakerEnabled,
    );
  }

  void _showCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CallOptionsSheet(call: _currentCall),
    );
  }
}

// 視頻通話頁面
class VideoCallPage extends ConsumerStatefulWidget {
  final VideoCall call;

  const VideoCallPage({
    super.key,
    required this.call,
  });

  @override
  ConsumerState<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends ConsumerState<VideoCallPage> {
  late DateTime _callStartTime;
  bool _isControlsVisible = true;
  
  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _hideControlsAfterDelay();
    }
  }

  void _endCall() {
    final endedCall = widget.call.copyWith(
      status: CallStatus.ended,
      endTime: DateTime.now(),
      duration: DateTime.now().difference(_callStartTime),
    );

    ref.read(currentCallProvider.notifier).state = null;
    ref.read(callHistoryProvider.notifier).updateCall(endedCall);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(callSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 主視頻區域
            _buildMainVideoArea(),
            
            // 小窗口（自己的視頻）
            if (widget.call.type == CallType.video)
              _buildPictureInPicture(),
            
            // 控制層
            if (_isControlsVisible)
              _buildControlsOverlay(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVideoArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      child: widget.call.type == CallType.video
          ? _buildVideoContent()
          : _buildAudioCallContent(),
    );
  }

  Widget _buildVideoContent() {
    return Stack(
      children: [
        // 模擬對方視頻
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[800],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.call.otherUserAvatar,
                  style: const TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 16),
                const Text(
                  '視頻通話中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 57,
              backgroundColor: Colors.grey[800],
              child: Text(
                widget.call.otherUserAvatar,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.call.otherUserName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final duration = DateTime.now().difference(_callStartTime);
              return Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPictureInPicture() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[800],
                child: const Center(
                  child: Text(
                    '😊',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(CallSettings settings) {
    return Column(
      children: [
        // 頂部信息
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.call.otherUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final duration = DateTime.now().difference(_callStartTime);
                  return Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // 底部控制按鈕
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 靜音按鈕
              _buildControlButton(
                icon: settings.audioEnabled ? Icons.mic : Icons.mic_off,
                isActive: settings.audioEnabled,
                onPressed: _toggleMute,
              ),
              
              // 視頻開關（僅視頻通話）
              if (widget.call.type == CallType.video)
                _buildControlButton(
                  icon: settings.videoEnabled ? Icons.videocam : Icons.videocam_off,
                  isActive: settings.videoEnabled,
                  onPressed: _toggleVideo,
                ),
              
              // 結束通話
              _buildControlButton(
                icon: Icons.call_end,
                color: Colors.red,
                size: 64,
                onPressed: _endCall,
              ),
              
              // 揚聲器
              _buildControlButton(
                icon: settings.speakerEnabled ? Icons.volume_up : Icons.volume_down,
                isActive: settings.speakerEnabled,
                onPressed: _toggleSpeaker,
              ),
              
              // 切換攝像頭（僅視頻通話）
              if (widget.call.type == CallType.video)
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: _switchCamera,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    bool isActive = true,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? (isActive ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.8)),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  void _toggleMute() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      audioEnabled: !settings.audioEnabled,
    );
  }

  void _toggleVideo() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      videoEnabled: !settings.videoEnabled,
    );
  }

  void _toggleSpeaker() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      speakerEnabled: !settings.speakerEnabled,
    );
  }

  void _switchCamera() {
    final settings = ref.read(callSettingsProvider);
    ref.read(callSettingsProvider.notifier).state = settings.copyWith(
      frontCameraEnabled: !settings.frontCameraEnabled,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

// 通話選項表單
class CallOptionsSheet extends StatelessWidget {
  final VideoCall? call;

  const CallOptionsSheet({
    super.key,
    this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '通話選項',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionTile(
            icon: Icons.report,
            title: '舉報用戶',
            subtitle: '舉報不當行為',
            onTap: () => _reportUser(context),
          ),
          _buildOptionTile(
            icon: Icons.block,
            title: '封鎖用戶',
            subtitle: '封鎖此用戶',
            onTap: () => _blockUser(context),
          ),
          _buildOptionTile(
            icon: Icons.settings,
            title: '通話設置',
            subtitle: '調整通話設置',
            onTap: () => _openCallSettings(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  void _reportUser(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('舉報已提交')),
    );
  }

  void _blockUser(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用戶已被封鎖')),
    );
  }

  void _openCallSettings(BuildContext context) {
    Navigator.pop(context);
    // 打開通話設置頁面
  }
}

// 通話歷史頁面
class CallHistoryPage extends ConsumerWidget {
  const CallHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callHistory = ref.watch(callHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('通話記錄'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: callHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: callHistory.length,
              itemBuilder: (context, index) {
                final call = callHistory[index];
                return _buildCallHistoryItem(context, ref, call);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '還沒有通話記錄',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallHistoryItem(BuildContext context, WidgetRef ref, VideoCall call) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Text(
              call.otherUserAvatar,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getCallStatusColor(call.status),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getCallStatusIcon(call),
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        call.otherUserName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _getCallSubtitle(call),
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            call.type == CallType.video ? Icons.videocam : Icons.call,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatCallTime(call.startTime),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () => _showCallDetails(context, call),
    );
  }

  Color _getCallStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.ended:
        return Colors.green;
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.declined:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCallStatusIcon(VideoCall call) {
    if (call.isIncoming) {
      switch (call.status) {
        case CallStatus.ended:
          return Icons.call_received;
        case CallStatus.missed:
          return Icons.call_received;
        case CallStatus.declined:
          return Icons.call_received;
        default:
          return Icons.call_received;
      }
    } else {
      return Icons.call_made;
    }
  }

  String _getCallSubtitle(VideoCall call) {
    String statusText;
    switch (call.status) {
      case CallStatus.ended:
        statusText = call.duration != null 
            ? '通話時長 ${_formatDuration(call.duration!)}'
            : '已結束';
        break;
      case CallStatus.missed:
        statusText = '未接聽';
        break;
      case CallStatus.declined:
        statusText = '已拒絕';
        break;
      default:
        statusText = call.status.toString();
    }
    
    return '${call.type == CallType.video ? '視頻' : '語音'}通話 • $statusText';
  }

  String _formatCallTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showCallDetails(BuildContext context, VideoCall call) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CallDetailsSheet(call: call),
    );
  }
}

// 通話詳情表單
class CallDetailsSheet extends StatelessWidget {
  final VideoCall call;

  const CallDetailsSheet({
    super.key,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: Text(
              call.otherUserAvatar,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            call.otherUserName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${call.type == CallType.video ? '視頻' : '語音'}通話',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('時間', _formatDateTime(call.startTime)),
          if (call.duration != null)
            _buildDetailRow('通話時長', _formatDuration(call.duration!)),
          _buildDetailRow('狀態', _getStatusText(call.status)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callBack(context),
                  icon: Icon(call.type == CallType.video ? Icons.videocam : Icons.call),
                  label: const Text('回撥'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendMessage(context),
                  icon: const Icon(Icons.message),
                  label: const Text('發消息'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes分$seconds秒';
  }

  String _getStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.ended:
        return '已結束';
      case CallStatus.missed:
        return '未接聽';
      case CallStatus.declined:
        return '已拒絕';
      default:
        return status.toString();
    }
  }

  void _callBack(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallInvitePage(
          receiverId: call.otherUserId,
          receiverName: call.otherUserName,
          receiverAvatar: call.otherUserAvatar,
          callType: call.type,
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    Navigator.pop(context);
    // 導航到聊天頁面
  }
} 