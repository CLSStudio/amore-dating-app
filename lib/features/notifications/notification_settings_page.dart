import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 通知設置狀態管理
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettings {
  final bool matchNotifications;
  final bool messageNotifications;
  final bool likeNotifications;
  final bool superLikeNotifications;
  final bool aiRecommendations;
  final bool weeklyInsights;
  final bool promotionalOffers;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool quietHoursEnabled;

  NotificationSettings({
    this.matchNotifications = true,
    this.messageNotifications = true,
    this.likeNotifications = true,
    this.superLikeNotifications = true,
    this.aiRecommendations = true,
    this.weeklyInsights = false,
    this.promotionalOffers = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.quietHoursEnabled = false,
  });

  NotificationSettings copyWith({
    bool? matchNotifications,
    bool? messageNotifications,
    bool? likeNotifications,
    bool? superLikeNotifications,
    bool? aiRecommendations,
    bool? weeklyInsights,
    bool? promotionalOffers,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
  }) {
    return NotificationSettings(
      matchNotifications: matchNotifications ?? this.matchNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      superLikeNotifications: superLikeNotifications ?? this.superLikeNotifications,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings());

  void updateMatchNotifications(bool value) {
    state = state.copyWith(matchNotifications: value);
  }

  void updateMessageNotifications(bool value) {
    state = state.copyWith(messageNotifications: value);
  }

  void updateLikeNotifications(bool value) {
    state = state.copyWith(likeNotifications: value);
  }

  void updateSuperLikeNotifications(bool value) {
    state = state.copyWith(superLikeNotifications: value);
  }

  void updateAiRecommendations(bool value) {
    state = state.copyWith(aiRecommendations: value);
  }

  void updateWeeklyInsights(bool value) {
    state = state.copyWith(weeklyInsights: value);
  }

  void updatePromotionalOffers(bool value) {
    state = state.copyWith(promotionalOffers: value);
  }

  void updateSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void updateVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
  }

  void updateQuietHours(String start, String end, bool enabled) {
    state = state.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
      quietHoursEnabled: enabled,
    );
  }
}

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('通知設置'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // 保存設置
              _saveSettings();
            },
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主要通知設置
            _buildSectionCard(
              title: '主要通知',
              icon: Icons.notifications_active,
              children: [
                _buildNotificationTile(
                  title: '新配對通知',
                  subtitle: '當有人與你配對成功時通知',
                  value: settings.matchNotifications,
                  onChanged: notifier.updateMatchNotifications,
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
                _buildNotificationTile(
                  title: '新消息通知',
                  subtitle: '收到新聊天消息時通知',
                  value: settings.messageNotifications,
                  onChanged: notifier.updateMessageNotifications,
                  icon: Icons.chat_bubble,
                  color: Colors.blue,
                ),
                _buildNotificationTile(
                  title: '喜歡通知',
                  subtitle: '有人喜歡你的檔案時通知',
                  value: settings.likeNotifications,
                  onChanged: notifier.updateLikeNotifications,
                  icon: Icons.thumb_up,
                  color: Colors.green,
                ),
                _buildNotificationTile(
                  title: '超級喜歡通知',
                  subtitle: '收到超級喜歡時通知',
                  value: settings.superLikeNotifications,
                  onChanged: notifier.updateSuperLikeNotifications,
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI 和洞察通知
            _buildSectionCard(
              title: 'AI 智能通知',
              icon: Icons.psychology,
              children: [
                _buildNotificationTile(
                  title: 'AI 推薦通知',
                  subtitle: '收到個性化推薦和建議時通知',
                  value: settings.aiRecommendations,
                  onChanged: notifier.updateAiRecommendations,
                  icon: Icons.lightbulb,
                  color: Colors.orange,
                ),
                _buildNotificationTile(
                  title: '週報洞察',
                  subtitle: '每週收到使用統計和洞察報告',
                  value: settings.weeklyInsights,
                  onChanged: notifier.updateWeeklyInsights,
                  icon: Icons.analytics,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 推廣通知
            _buildSectionCard(
              title: '推廣和優惠',
              icon: Icons.local_offer,
              children: [
                _buildNotificationTile(
                  title: '優惠活動通知',
                  subtitle: '接收 Premium 優惠和特別活動通知',
                  value: settings.promotionalOffers,
                  onChanged: notifier.updatePromotionalOffers,
                  icon: Icons.card_giftcard,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 通知方式設置
            _buildSectionCard(
              title: '通知方式',
              icon: Icons.volume_up,
              children: [
                _buildNotificationTile(
                  title: '聲音提醒',
                  subtitle: '通知時播放提示音',
                  value: settings.soundEnabled,
                  onChanged: notifier.updateSoundEnabled,
                  icon: Icons.volume_up,
                  color: Colors.indigo,
                ),
                _buildNotificationTile(
                  title: '震動提醒',
                  subtitle: '通知時震動手機',
                  value: settings.vibrationEnabled,
                  onChanged: notifier.updateVibrationEnabled,
                  icon: Icons.vibration,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 免打擾時間
            _buildQuietHoursCard(settings, notifier),

            const SizedBox(height: 32),

            // 快速設置按鈕
            _buildQuickSettingsButtons(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFE91E63),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursCard(NotificationSettings settings, NotificationSettingsNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bedtime,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '免打擾時間',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: settings.quietHoursEnabled,
                  onChanged: (value) {
                    notifier.updateQuietHours(
                      settings.quietHoursStart,
                      settings.quietHoursEnd,
                      value,
                    );
                  },
                  activeColor: const Color(0xFFE91E63),
                ),
              ],
            ),
          ),
          if (settings.quietHoursEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      label: '開始時間',
                      time: settings.quietHoursStart,
                      onTimeSelected: (time) {
                        notifier.updateQuietHours(
                          time,
                          settings.quietHoursEnd,
                          settings.quietHoursEnabled,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(
                      label: '結束時間',
                      time: settings.quietHoursEnd,
                      onTimeSelected: (time) {
                        notifier.updateQuietHours(
                          settings.quietHoursStart,
                          time,
                          settings.quietHoursEnabled,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required Function(String) onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1]),
          ),
        );
        
        if (selectedTime != null) {
          final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
          onTimeSelected(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingsButtons(NotificationSettingsNotifier notifier) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 全部開啟
                  _enableAllNotifications(notifier);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('全部開啟'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // 全部關閉
                  _disableAllNotifications(notifier);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E63),
                  side: const BorderSide(color: Color(0xFFE91E63)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('全部關閉'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // 重置為默認設置
              _resetToDefaults(notifier);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('重置為默認設置'),
          ),
        ),
      ],
    );
  }

  void _enableAllNotifications(NotificationSettingsNotifier notifier) {
    notifier.updateMatchNotifications(true);
    notifier.updateMessageNotifications(true);
    notifier.updateLikeNotifications(true);
    notifier.updateSuperLikeNotifications(true);
    notifier.updateAiRecommendations(true);
    notifier.updateWeeklyInsights(true);
    notifier.updateSoundEnabled(true);
    notifier.updateVibrationEnabled(true);
  }

  void _disableAllNotifications(NotificationSettingsNotifier notifier) {
    notifier.updateMatchNotifications(false);
    notifier.updateMessageNotifications(false);
    notifier.updateLikeNotifications(false);
    notifier.updateSuperLikeNotifications(false);
    notifier.updateAiRecommendations(false);
    notifier.updateWeeklyInsights(false);
    notifier.updatePromotionalOffers(false);
  }

  void _resetToDefaults(NotificationSettingsNotifier notifier) {
    notifier.updateMatchNotifications(true);
    notifier.updateMessageNotifications(true);
    notifier.updateLikeNotifications(true);
    notifier.updateSuperLikeNotifications(true);
    notifier.updateAiRecommendations(true);
    notifier.updateWeeklyInsights(false);
    notifier.updatePromotionalOffers(false);
    notifier.updateSoundEnabled(true);
    notifier.updateVibrationEnabled(true);
    notifier.updateQuietHours('22:00', '08:00', false);
  }

  void _saveSettings() {
    // 這裡實現保存設置到 Firebase 或本地存儲
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('通知設置已保存'),
        backgroundColor: const Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 