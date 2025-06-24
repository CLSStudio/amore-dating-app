import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 隱私設定狀態管理
final privacySettingsProvider = StateNotifierProvider<PrivacySettingsNotifier, PrivacySettings>((ref) {
  return PrivacySettingsNotifier();
});

class PrivacySettings {
  final bool showOnline;
  final bool allowLocationSharing;
  final bool hideFromFacebook;
  final bool hideAge;
  final bool hideDistance;
  final bool allowProfileViewing;
  final bool allowMessageFromMatches;
  final bool allowMessageFromVerifiedUsers;
  final String profileVisibility;
  final bool allowDataAnalytics;
  final bool allowAdvertisingData;
  final bool hideReadReceipts;
  final bool allowVoiceMessages;
  final bool allowVideoMessages;

  PrivacySettings({
    this.showOnline = true,
    this.allowLocationSharing = true,
    this.hideFromFacebook = false,
    this.hideAge = false,
    this.hideDistance = false,
    this.allowProfileViewing = true,
    this.allowMessageFromMatches = true,
    this.allowMessageFromVerifiedUsers = true,
    this.profileVisibility = 'everyone',
    this.allowDataAnalytics = true,
    this.allowAdvertisingData = false,
    this.hideReadReceipts = false,
    this.allowVoiceMessages = true,
    this.allowVideoMessages = true,
  });

  PrivacySettings copyWith({
    bool? showOnline,
    bool? allowLocationSharing,
    bool? hideFromFacebook,
    bool? hideAge,
    bool? hideDistance,
    bool? allowProfileViewing,
    bool? allowMessageFromMatches,
    bool? allowMessageFromVerifiedUsers,
    String? profileVisibility,
    bool? allowDataAnalytics,
    bool? allowAdvertisingData,
    bool? hideReadReceipts,
    bool? allowVoiceMessages,
    bool? allowVideoMessages,
  }) {
    return PrivacySettings(
      showOnline: showOnline ?? this.showOnline,
      allowLocationSharing: allowLocationSharing ?? this.allowLocationSharing,
      hideFromFacebook: hideFromFacebook ?? this.hideFromFacebook,
      hideAge: hideAge ?? this.hideAge,
      hideDistance: hideDistance ?? this.hideDistance,
      allowProfileViewing: allowProfileViewing ?? this.allowProfileViewing,
      allowMessageFromMatches: allowMessageFromMatches ?? this.allowMessageFromMatches,
      allowMessageFromVerifiedUsers: allowMessageFromVerifiedUsers ?? this.allowMessageFromVerifiedUsers,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      allowDataAnalytics: allowDataAnalytics ?? this.allowDataAnalytics,
      allowAdvertisingData: allowAdvertisingData ?? this.allowAdvertisingData,
      hideReadReceipts: hideReadReceipts ?? this.hideReadReceipts,
      allowVoiceMessages: allowVoiceMessages ?? this.allowVoiceMessages,
      allowVideoMessages: allowVideoMessages ?? this.allowVideoMessages,
    );
  }
}

class PrivacySettingsNotifier extends StateNotifier<PrivacySettings> {
  PrivacySettingsNotifier() : super(PrivacySettings());

  void updateShowOnline(bool value) {
    state = state.copyWith(showOnline: value);
  }

  void updateLocationSharing(bool value) {
    state = state.copyWith(allowLocationSharing: value);
  }

  void updateHideFromFacebook(bool value) {
    state = state.copyWith(hideFromFacebook: value);
  }

  void updateHideAge(bool value) {
    state = state.copyWith(hideAge: value);
  }

  void updateHideDistance(bool value) {
    state = state.copyWith(hideDistance: value);
  }

  void updateProfileViewing(bool value) {
    state = state.copyWith(allowProfileViewing: value);
  }

  void updateMessageFromMatches(bool value) {
    state = state.copyWith(allowMessageFromMatches: value);
  }

  void updateMessageFromVerifiedUsers(bool value) {
    state = state.copyWith(allowMessageFromVerifiedUsers: value);
  }

  void updateProfileVisibility(String value) {
    state = state.copyWith(profileVisibility: value);
  }

  void updateDataAnalytics(bool value) {
    state = state.copyWith(allowDataAnalytics: value);
  }

  void updateAdvertisingData(bool value) {
    state = state.copyWith(allowAdvertisingData: value);
  }

  void updateReadReceipts(bool value) {
    state = state.copyWith(hideReadReceipts: value);
  }

  void updateVoiceMessages(bool value) {
    state = state.copyWith(allowVoiceMessages: value);
  }

  void updateVideoMessages(bool value) {
    state = state.copyWith(allowVideoMessages: value);
  }
}

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '隱私與安全設定',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _saveSettings(context),
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
            // 檔案可見度設定
            _buildSectionCard(
              title: '檔案可見度',
              icon: Icons.visibility,
              children: [
                _buildVisibilityDropdown(
                  title: '誰可以看到我的檔案',
                  value: settings.profileVisibility,
                  onChanged: notifier.updateProfileVisibility,
                ),
                _buildSwitchTile(
                  title: '允許檔案瀏覽',
                  subtitle: '其他用戶可以瀏覽你的完整檔案',
                  value: settings.allowProfileViewing,
                  onChanged: notifier.updateProfileViewing,
                  icon: Icons.person_search,
                  color: Colors.blue,
                ),
                _buildSwitchTile(
                  title: '顯示在線狀態',
                  subtitle: '讓其他用戶知道你目前在線',
                  value: settings.showOnline,
                  onChanged: notifier.updateShowOnline,
                  icon: Icons.online_prediction,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 資料隱私設定
            _buildSectionCard(
              title: '資料隱私',
              icon: Icons.lock,
              children: [
                _buildSwitchTile(
                  title: '隱藏年齡',
                  subtitle: '在你的檔案中不顯示確切年齡',
                  value: settings.hideAge,
                  onChanged: notifier.updateHideAge,
                  icon: Icons.cake,
                  color: Colors.orange,
                ),
                _buildSwitchTile(
                  title: '隱藏距離',
                  subtitle: '不顯示與其他用戶的距離',
                  value: settings.hideDistance,
                  onChanged: notifier.updateHideDistance,
                  icon: Icons.location_off,
                  color: Colors.red,
                ),
                _buildSwitchTile(
                  title: '允許位置分享',
                  subtitle: '顯示大概位置給其他用戶',
                  value: settings.allowLocationSharing,
                  onChanged: notifier.updateLocationSharing,
                  icon: Icons.location_on,
                  color: Colors.blue,
                ),
                _buildSwitchTile(
                  title: '避免 Facebook 朋友',
                  subtitle: '不向 Facebook 朋友顯示你的檔案',
                  value: settings.hideFromFacebook,
                  onChanged: notifier.updateHideFromFacebook,
                  icon: Icons.people_outline,
                  color: Colors.indigo,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 訊息與溝通設定
            _buildSectionCard(
              title: '訊息與溝通',
              icon: Icons.chat,
              children: [
                _buildSwitchTile(
                  title: '允許配對用戶傳訊',
                  subtitle: '配對成功的用戶可以向你發送訊息',
                  value: settings.allowMessageFromMatches,
                  onChanged: notifier.updateMessageFromMatches,
                  icon: Icons.chat_bubble,
                  color: Colors.green,
                ),
                _buildSwitchTile(
                  title: '允許已驗證用戶傳訊',
                  subtitle: '已通過身份驗證的用戶可以發送訊息',
                  value: settings.allowMessageFromVerifiedUsers,
                  onChanged: notifier.updateMessageFromVerifiedUsers,
                  icon: Icons.verified_user,
                  color: Colors.purple,
                ),
                _buildSwitchTile(
                  title: '隱藏已讀狀態',
                  subtitle: '不讓對方知道你已讀取訊息',
                  value: settings.hideReadReceipts,
                  onChanged: notifier.updateReadReceipts,
                  icon: Icons.mark_chat_read,
                  color: Colors.grey,
                ),
                _buildSwitchTile(
                  title: '允許語音訊息',
                  subtitle: '其他用戶可以向你發送語音訊息',
                  value: settings.allowVoiceMessages,
                  onChanged: notifier.updateVoiceMessages,
                  icon: Icons.mic,
                  color: Colors.teal,
                ),
                _buildSwitchTile(
                  title: '允許視頻訊息',
                  subtitle: '其他用戶可以向你發送視頻訊息',
                  value: settings.allowVideoMessages,
                  onChanged: notifier.updateVideoMessages,
                  icon: Icons.videocam,
                  color: Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 資料使用設定
            _buildSectionCard(
              title: '資料使用',
              icon: Icons.analytics,
              children: [
                _buildSwitchTile(
                  title: '允許資料分析',
                  subtitle: '幫助改善 Amore 的配對算法',
                  value: settings.allowDataAnalytics,
                  onChanged: notifier.updateDataAnalytics,
                  icon: Icons.analytics,
                  color: Colors.blue,
                ),
                _buildSwitchTile(
                  title: '允許廣告資料使用',
                  subtitle: '用於個性化廣告內容',
                  value: settings.allowAdvertisingData,
                  onChanged: notifier.updateAdvertisingData,
                  icon: Icons.ads_click,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 隱私說明
            _buildPrivacyNotice(),

            const SizedBox(height: 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFE91E63), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                    color: Color(0xFF2D3748),
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

  Widget _buildVisibilityDropdown({
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: 'everyone',
                    child: Row(
                      children: [
                        Icon(Icons.public, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        const Text('所有人'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'verified_only',
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text('僅已驗證用戶'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'premium_only',
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        const Text('僅 Premium 用戶'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'matches_only',
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        const Text('僅配對用戶'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                '隱私保護說明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Amore 致力於保護您的隱私和個人資料。您的設定將即時生效，您可以隨時修改這些偏好設定。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 打開隱私政策
            },
            child: Text(
              '查看完整隱私政策 →',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // TODO: 保存隱私設定到後端
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('隱私設定已保存'),
        backgroundColor: Color(0xFF38A169),
      ),
    );
    Navigator.pop(context);
  }
} 