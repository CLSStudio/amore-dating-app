import 'package:flutter/material.dart';
import '../models/interaction_models.dart';
import '../services/safe_interaction_service.dart';
import '../widgets/chat_invitation_widgets.dart';

class ChatInvitationsPage extends StatefulWidget {
  final String currentUserId;

  const ChatInvitationsPage({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatInvitationsPageState createState() => _ChatInvitationsPageState();
}

class _ChatInvitationsPageState extends State<ChatInvitationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChatInvitation> _receivedInvitations = [];
  List<ChatInvitation> _sentInvitations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvitations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = SafeInteractionService();
      
      // 載入收到的邀請
      final received = await service.getChatInvitations(widget.currentUserId);
      
      // 載入發送的邀請（需要修改service方法）
      final sent = await _getSentInvitations();

      setState(() {
        _receivedInvitations = received;
        _sentInvitations = sent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '載入邀請失敗，請稍後再試';
        _isLoading = false;
      });
    }
  }

  Future<List<ChatInvitation>> _getSentInvitations() async {
    // 這裡需要實現獲取發送的邀請的邏輯
    // 暫時返回空列表
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '聊天邀請',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInvitations,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              text: '收到的邀請',
              icon: Badge(
                label: Text('${_receivedInvitations.length}'),
                child: Icon(Icons.inbox),
              ),
            ),
            Tab(
              text: '發送的邀請',
              icon: Badge(
                label: Text('${_sentInvitations.length}'),
                child: Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.pink.shade400,
            ),
            SizedBox(height: 16),
            Text(
              '載入中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReceivedInvitations(),
        _buildSentInvitations(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInvitations,
            icon: Icon(Icons.refresh),
            label: Text('重新載入'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedInvitations() {
    if (_receivedInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: '暫無收到的邀請',
        subtitle: '當有人想和您聊天時，邀請會出現在這裡',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: Colors.pink.shade400,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _receivedInvitations.length,
        itemBuilder: (context, index) {
          final invitation = _receivedInvitations[index];
          return ChatInvitationCard(
            invitation: invitation,
            onResponse: () {
              _loadInvitations(); // 重新載入列表
            },
          );
        },
      ),
    );
  }

  Widget _buildSentInvitations() {
    if (_sentInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: '暫無發送的邀請',
        subtitle: '您發送的聊天邀請會出現在這裡',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: Colors.pink.shade400,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _sentInvitations.length,
        itemBuilder: (context, index) {
          final invitation = _sentInvitations[index];
          return _buildSentInvitationCard(invitation);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // 可以導航到社交動態頁面
              },
              icon: Icon(Icons.explore, color: Colors.white),
              label: Text(
                '探索動態',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentInvitationCard(ChatInvitation invitation) {
    final timeLeft = invitation.expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (invitation.status) {
      case ChatInvitationStatus.pending:
        statusColor = Colors.orange.shade600;
        statusText = '等待回應';
        statusIcon = Icons.hourglass_empty;
        break;
      case ChatInvitationStatus.accepted:
        statusColor = Colors.green.shade600;
        statusText = '已接受';
        statusIcon = Icons.check_circle;
        break;
      case ChatInvitationStatus.declined:
        statusColor = Colors.red.shade600;
        statusText = '已拒絕';
        statusIcon = Icons.cancel;
        break;
      case ChatInvitationStatus.expired:
        statusColor = Colors.grey.shade600;
        statusText = '已過期';
        statusIcon = Icons.access_time;
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 狀態和時間
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (invitation.status == ChatInvitationStatus.pending)
                    Text(
                      hoursLeft <= 1 ? '即將過期' : '${hoursLeft}小時後過期',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),

              // 邀請信息
              Text(
                '邀請給：用戶${invitation.toUserId}', // 這裡應該顯示實際用戶名
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '原因：${invitation.reason}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (invitation.message != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    invitation.message!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 12),
              Text(
                '發送時間：${_formatDateTime(invitation.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),

              // 操作按鈕（僅對已接受的邀請顯示）
              if (invitation.status == ChatInvitationStatus.accepted) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 導航到聊天頁面
                      _navigateToChat(invitation);
                    },
                    icon: Icon(Icons.chat, color: Colors.white),
                    label: Text(
                      '開始聊天',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }

  void _navigateToChat(ChatInvitation invitation) {
    // TODO: 實現導航到聊天頁面
    debugPrint('導航到聊天頁面: ${invitation.id}');
  }
} 