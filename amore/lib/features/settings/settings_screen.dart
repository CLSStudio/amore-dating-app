import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notification_settings_page.dart';
import 'profile_settings_page.dart';
import 'privacy_settings_page.dart';
import 'matching_preferences_page.dart';
import 'app_settings_page.dart';
import 'security_settings_page.dart';
import 'subscription_settings_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '設定',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 帳戶設定區塊
            _buildSectionHeader('帳戶設定'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSettingTile(
                icon: Icons.person,
                title: '個人檔案設定',
                subtitle: '編輯個人信息、照片和自我介紹',
                onTap: () => _navigateToPage(context, const ProfileSettingsPage()),
                color: const Color(0xFF3182CE),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.favorite,
                title: '配對偏好設定',
                subtitle: '設定年齡範圍、距離和理想對象條件',
                onTap: () => _navigateToPage(context, const MatchingPreferencesPage()),
                color: const Color(0xFFE91E63),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.subscriptions,
                title: '訂閱管理',
                subtitle: '管理 Premium 訂閱和付費功能',
                onTap: () => _navigateToPage(context, const SubscriptionSettingsPage()),
                color: const Color(0xFFD69E2E),
              ),
            ]),

            const SizedBox(height: 24),

            // 隱私與安全區塊
            _buildSectionHeader('隱私與安全'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSettingTile(
                icon: Icons.privacy_tip,
                title: '隱私設定',
                subtitle: '控制誰可以看到你的檔案和信息',
                onTap: () => _navigateToPage(context, const PrivacySettingsPage()),
                color: const Color(0xFF805AD5),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.security,
                title: '安全設定',
                subtitle: '帳戶安全、雙重驗證和登入記錄',
                onTap: () => _navigateToPage(context, const SecuritySettingsPage()),
                color: const Color(0xFF38A169),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.block,
                title: '封鎖與舉報',
                subtitle: '管理封鎖名單和舉報記錄',
                onTap: () => _showBlockAndReportSettings(context),
                color: const Color(0xFFE53E3E),
              ),
            ]),

            const SizedBox(height: 24),

            // 通知與應用設定區塊
            _buildSectionHeader('通知與應用'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSettingTile(
                icon: Icons.notifications,
                title: '通知設定',
                subtitle: '自定義推送通知和提醒偏好',
                onTap: () => _navigateToPage(context, const NotificationSettingsPage()),
                color: const Color(0xFF3182CE),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.settings,
                title: '應用設定',
                subtitle: '語言、主題、字體大小等',
                onTap: () => _navigateToPage(context, const AppSettingsPage()),
                color: const Color(0xFF718096),
              ),
            ]),

            const SizedBox(height: 24),

            // 支援與其他區塊
            _buildSectionHeader('支援與其他'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSettingTile(
                icon: Icons.help,
                title: '幫助與支援',
                subtitle: '常見問題、聯絡客服',
                onTap: () => _showHelpAndSupport(context),
                color: const Color(0xFF3182CE),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.info,
                title: '關於 Amore',
                subtitle: '版本信息、使用條款、隱私政策',
                onTap: () => _showAboutAmore(context),
                color: const Color(0xFF718096),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.logout,
                title: '登出',
                subtitle: '安全登出您的帳戶',
                onTap: () => _showLogoutConfirmation(context),
                color: const Color(0xFFE53E3E),
                showArrow: false,
              ),
            ]),

            const SizedBox(height: 32),

            // 版本信息
            Center(
              child: Column(
                children: [
                  Text(
                    'Amore 版本 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Amore Dating',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 72,
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showBlockAndReportSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFFE53E3E)),
              title: const Text('封鎖名單'),
              subtitle: const Text('管理已封鎖的用戶'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Color(0xFFED8936)),
              title: const Text('舉報記錄'),
              subtitle: const Text('查看舉報歷史'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHelpAndSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Color(0xFF3182CE)),
              title: const Text('常見問題'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF38A169)),
              title: const Text('聯絡客服'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Color(0xFFED8936)),
              title: const Text('意見回饋'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutAmore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('關於 Amore'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本：1.0.0'),
            SizedBox(height: 8),
            Text('Amore 是專為香港用戶設計的智能交友應用，結合 AI 科技提供深度配對和專業戀愛諮詢服務。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 開啟使用條款
            },
            child: const Text('使用條款'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 開啟隱私政策
            },
            child: const Text('隱私政策'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('你確定要登出 Amore 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 執行登出邏輯
              _performLogout(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // TODO: 實現登出邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已安全登出'),
        backgroundColor: Color(0xFF38A169),
      ),
    );
  }
} 