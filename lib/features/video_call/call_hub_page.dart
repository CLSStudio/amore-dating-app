import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 導入通話功能
import 'video_call_feature.dart';

class CallHubPage extends ConsumerWidget {
  const CallHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callHistory = ref.watch(callHistoryProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('📞 通話記錄'),
                  const SizedBox(height: AppSpacing.md),
                  _buildCallHistory(context, callHistory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info,
            AppColors.primary,
          ],
        ),
        borderRadius: AppBorderRadius.bottomOnly,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '視頻通話',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        '與配對對象面對面聊天',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '安全加密通話',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📱 快速通話',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.videocam,
                title: '視頻通話',
                subtitle: '面對面聊天',
                color: AppColors.info,
                onTap: () => _showContactSelector(context, CallType.video),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionCard(
                icon: Icons.call,
                title: '語音通話',
                subtitle: '純語音聊天',
                color: AppColors.success,
                onTap: () => _showContactSelector(context, CallType.audio),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          backgroundColor: AppColors.warning.withOpacity(0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '預約通話',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      '安排特定時間進行通話',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                text: '預約',
                onPressed: () => _showScheduleCall(context),
                size: AppButtonSize.small,
                type: AppButtonType.outline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.h6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4,
    );
  }

  Widget _buildCallHistory(BuildContext context, List<VideoCall> callHistory) {
    if (callHistory.isEmpty) {
      return const AppEmptyState(
        icon: Icons.call,
        title: '暫無通話記錄',
        subtitle: '開始你的第一次視頻通話吧！',
        actionText: '發起通話',
      );
    }

    return Column(
      children: callHistory.map((call) => _buildCallHistoryItem(context, call)).toList(),
    );
  }

  Widget _buildCallHistoryItem(BuildContext context, VideoCall call) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _showCallDetails(context, call),
      child: Row(
        children: [
          // 通話類型圖標
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _getCallStatusColor(call.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              call.type == CallType.video ? Icons.videocam : Icons.call,
              color: _getCallStatusColor(call.status),
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // 通話信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      call.otherUserName,
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      call.isIncoming ? Icons.call_received : Icons.call_made,
                      size: 16,
                      color: call.isIncoming ? AppColors.success : AppColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      _getCallStatusText(call.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getCallStatusColor(call.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (call.duration != null) ...[
                      Text(
                        ' • ${_formatDuration(call.duration!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatCallTime(call.startTime),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          
          // 操作按鈕
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  call.type == CallType.video ? Icons.videocam : Icons.call,
                  color: AppColors.primary,
                ),
                onPressed: () => _initiateCall(context, call.otherUserId, call.otherUserName, call.otherUserAvatar, call.type),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _showCallOptions(context, call),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCallStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.ended:
        return AppColors.success;
      case CallStatus.missed:
        return AppColors.error;
      case CallStatus.declined:
        return AppColors.warning;
      case CallStatus.busy:
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String _getCallStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.ended:
        return '已結束';
      case CallStatus.missed:
        return '未接聽';
      case CallStatus.declined:
        return '已拒絕';
      case CallStatus.busy:
        return '忙線';
      case CallStatus.calling:
        return '撥號中';
      case CallStatus.ringing:
        return '響鈴中';
      case CallStatus.connected:
        return '通話中';
      default:
        return '未知';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatCallTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else {
      return '${difference.inDays} 天前';
    }
  }

  void _showContactSelector(BuildContext context, CallType callType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              callType == CallType.video ? '選擇視頻通話對象' : '選擇語音通話對象',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // 模擬聯繫人列表
                         ..._getSampleContacts().map((contact) => ListTile(
               leading: CircleAvatar(
                 backgroundColor: AppColors.primary.withOpacity(0.1),
                 child: Text(contact['avatar'] ?? ''),
               ),
               title: Text(contact['name'] ?? ''),
               subtitle: Text(contact['status'] ?? ''),
               trailing: Icon(
                 callType == CallType.video ? Icons.videocam : Icons.call,
                 color: AppColors.primary,
               ),
               onTap: () {
                 Navigator.pop(context);
                 _initiateCall(context, contact['id'] ?? '', contact['name'] ?? '', contact['avatar'] ?? '', callType);
               },
             )).toList(),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getSampleContacts() {
    return [
      {'id': '1', 'name': '小雅', 'avatar': '👩‍🦰', 'status': '在線'},
      {'id': '2', 'name': '志明', 'avatar': '👨‍💻', 'status': '5分鐘前在線'},
      {'id': '3', 'name': '美玲', 'avatar': '🧘‍♀️', 'status': '在線'},
      {'id': '4', 'name': '建華', 'avatar': '👨‍🍳', 'status': '1小時前在線'},
    ];
  }

  void _initiateCall(BuildContext context, String userId, String userName, String userAvatar, CallType callType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallInvitePage(
          receiverId: userId,
          receiverName: userName,
          receiverAvatar: userAvatar,
          callType: callType,
        ),
      ),
    );
  }

  void _showScheduleCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('預約通話'),
          ],
        ),
        content: const Text('預約通話功能即將推出！\n\n你可以安排特定時間與配對對象進行通話，系統會提前提醒雙方。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          AppButton(
            text: '了解更多',
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _showCallDetails(BuildContext context, VideoCall call) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              '通話詳情',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    call.otherUserAvatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call.otherUserName,
                        style: AppTextStyles.h6,
                      ),
                      Text(
                        call.type == CallType.video ? '視頻通話' : '語音通話',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            _buildDetailRow('狀態', _getCallStatusText(call.status)),
            _buildDetailRow('時間', _formatCallTime(call.startTime)),
            if (call.duration != null)
              _buildDetailRow('通話時長', _formatDuration(call.duration!)),
            _buildDetailRow('類型', call.isIncoming ? '來電' : '撥出'),
            
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '重新撥打',
                    onPressed: () {
                      Navigator.pop(context);
                      _initiateCall(context, call.otherUserId, call.otherUserName, call.otherUserAvatar, call.type);
                    },
                    icon: call.type == CallType.video ? Icons.videocam : Icons.call,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  text: '刪除',
                  onPressed: () => Navigator.pop(context),
                  type: AppButtonType.outline,
                  icon: Icons.delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showCallOptions(BuildContext context, VideoCall call) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                call.type == CallType.video ? Icons.videocam : Icons.call,
                color: AppColors.primary,
              ),
              title: const Text('重新撥打'),
              onTap: () {
                Navigator.pop(context);
                _initiateCall(context, call.otherUserId, call.otherUserName, call.otherUserAvatar, call.type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('查看詳情'),
              onTap: () {
                Navigator.pop(context);
                _showCallDetails(context, call);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('刪除記錄', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
} 