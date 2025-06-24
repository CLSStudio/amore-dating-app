import 'package:flutter/material.dart';
import '../models/interaction_models.dart';
import '../services/safe_interaction_service.dart';

// 聊天邀請按鈕
class ChatInviteButton extends StatelessWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatar;
  final String targetUserId;
  final String? relatedPostId;
  final VoidCallback? onInviteSent;

  const ChatInviteButton({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.targetUserId,
    this.relatedPostId,
    this.onInviteSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showInviteDialog(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message_outlined, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  '聊天邀請',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChatInviteDialog(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
        targetUserId: targetUserId,
        relatedPostId: relatedPostId,
        onInviteSent: onInviteSent,
      ),
    );
  }
}

// 聊天邀請對話框
class ChatInviteDialog extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatar;
  final String targetUserId;
  final String? relatedPostId;
  final VoidCallback? onInviteSent;

  const ChatInviteDialog({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.targetUserId,
    this.relatedPostId,
    this.onInviteSent,
  }) : super(key: key);

  @override
  _ChatInviteDialogState createState() => _ChatInviteDialogState();
}

class _ChatInviteDialogState extends State<ChatInviteDialog> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedReason = '對你的貼文很感興趣';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _inviteReasons = [
    '對你的貼文很感興趣',
    '想進一步認識你',
    '有共同興趣愛好',
    '覺得你很有趣',
    '想和你聊聊',
    '其他原因',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.message, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '發送聊天邀請',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '向對方說明您想聊天的原因',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 邀請原因選擇
            Text(
              '邀請原因',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReason = newValue!;
                    });
                  },
                  items: _inviteReasons.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 個人訊息
            Text(
              '個人訊息（選填）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: '說點什麼來打破僵局吧...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 8),

            // 提示信息
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '邀請將在72小時後過期，每日最多可發送10個邀請',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 錯誤訊息
            if (_errorMessage != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24),

            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.purple.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendInvitation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              '發送邀請',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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

  Future<void> _sendInvitation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = SafeInteractionService();
      
      // 檢查邀請資格
      final eligibility = await service.checkChatInvitationEligibility(
        fromUserId: widget.currentUserId,
        toUserId: widget.targetUserId,
      );

      if (!eligibility['canInvite']) {
        setState(() {
          _errorMessage = eligibility['message'];
          _isLoading = false;
        });
        return;
      }

      // 發送邀請
      final success = await service.sendChatInvitation(
        fromUserId: widget.currentUserId,
        fromUserName: widget.currentUserName,
        fromUserAvatar: widget.currentUserAvatar,
        toUserId: widget.targetUserId,
        reason: _selectedReason,
        message: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
        relatedPostId: widget.relatedPostId,
      );

      if (success) {
        Navigator.of(context).pop();
        widget.onInviteSent?.call();
        _showSuccessMessage(context);
      } else {
        setState(() {
          _errorMessage = '發送失敗，請稍後再試';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '發送失敗，請檢查網路連接';
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('聊天邀請發送成功！'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// 聊天邀請通知卡片
class ChatInvitationCard extends StatefulWidget {
  final ChatInvitation invitation;
  final VoidCallback? onResponse;

  const ChatInvitationCard({
    Key? key,
    required this.invitation,
    this.onResponse,
  }) : super(key: key);

  @override
  _ChatInvitationCardState createState() => _ChatInvitationCardState();
}

class _ChatInvitationCardState extends State<ChatInvitationCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final timeLeft = widget.invitation.expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頭部信息
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.invitation.fromUserAvatar),
                    radius: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.invitation.fromUserName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '想和你聊天',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hoursLeft <= 24 
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hoursLeft <= 1 
                          ? '即將過期'
                          : '${hoursLeft}小時後過期',
                      style: TextStyle(
                        fontSize: 12,
                        color: hoursLeft <= 24 
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 邀請原因
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_outline, 
                             color: Colors.pink.shade400, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '邀請原因',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.invitation.reason,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // 個人訊息
              if (widget.invitation.message != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.message_outlined, 
                               color: Colors.blue.shade600, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '個人訊息',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        widget.invitation.message!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16),

              // 回應按鈕
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.pink.shade400,
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _respondToInvitation(false),
                        icon: Icon(Icons.close, size: 18),
                        label: Text('委婉拒絕'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _respondToInvitation(true),
                          icon: Icon(Icons.check, size: 18),
                          label: Text('接受邀請'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _respondToInvitation(bool accept) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = SafeInteractionService();
      final success = await service.respondToChatInvitation(
        invitationId: widget.invitation.id,
        accept: accept,
      );

      if (success) {
        widget.onResponse?.call();
        _showResponseMessage(context, accept);
      } else {
        _showErrorMessage(context, '回應失敗，請稍後再試');
      }
    } catch (e) {
      _showErrorMessage(context, '回應失敗，請檢查網路連接');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResponseMessage(BuildContext context, bool accepted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(accepted ? '已接受聊天邀請！' : '已拒絕聊天邀請'),
          ],
        ),
        backgroundColor: accepted ? Colors.green.shade600 : Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
} 