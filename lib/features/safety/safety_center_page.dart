import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 安全狀態管理
final safetyStatusProvider = StateNotifierProvider<SafetyStatusNotifier, SafetyStatus>((ref) {
  return SafetyStatusNotifier();
});

class SafetyStatus {
  final bool photoVerified;
  final bool voiceVerified;
  final bool phoneVerified;
  final bool emailVerified;
  final int reportCount;
  final int blockCount;
  final DateTime? lastSecurityCheck;
  final bool twoFactorEnabled;
  final bool locationSharingEnabled;

  SafetyStatus({
    this.photoVerified = false,
    this.voiceVerified = false,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.reportCount = 0,
    this.blockCount = 0,
    this.lastSecurityCheck,
    this.twoFactorEnabled = false,
    this.locationSharingEnabled = false,
  });

  SafetyStatus copyWith({
    bool? photoVerified,
    bool? voiceVerified,
    bool? phoneVerified,
    bool? emailVerified,
    int? reportCount,
    int? blockCount,
    DateTime? lastSecurityCheck,
    bool? twoFactorEnabled,
    bool? locationSharingEnabled,
  }) {
    return SafetyStatus(
      photoVerified: photoVerified ?? this.photoVerified,
      voiceVerified: voiceVerified ?? this.voiceVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      reportCount: reportCount ?? this.reportCount,
      blockCount: blockCount ?? this.blockCount,
      lastSecurityCheck: lastSecurityCheck ?? this.lastSecurityCheck,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
    );
  }

  double get verificationScore {
    int score = 0;
    if (photoVerified) score += 25;
    if (voiceVerified) score += 20;
    if (phoneVerified) score += 25;
    if (emailVerified) score += 15;
    if (twoFactorEnabled) score += 15;
    return score.toDouble();
  }

  String get safetyLevel {
    final score = verificationScore;
    if (score >= 80) return '高';
    if (score >= 50) return '中';
    return '低';
  }

  Color get safetyLevelColor {
    final score = verificationScore;
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class SafetyStatusNotifier extends StateNotifier<SafetyStatus> {
  SafetyStatusNotifier() : super(SafetyStatus()) {
    _loadSafetyStatus();
  }

  void _loadSafetyStatus() {
    // 模擬載入安全狀態
    state = SafetyStatus(
      photoVerified: true,
      phoneVerified: true,
      emailVerified: true,
      voiceVerified: false,
      reportCount: 0,
      blockCount: 2,
      lastSecurityCheck: DateTime.now().subtract(const Duration(days: 7)),
      twoFactorEnabled: false,
      locationSharingEnabled: true,
    );
  }

  void updatePhotoVerification(bool verified) {
    state = state.copyWith(photoVerified: verified);
  }

  void updateVoiceVerification(bool verified) {
    state = state.copyWith(voiceVerified: verified);
  }

  void updateTwoFactor(bool enabled) {
    state = state.copyWith(twoFactorEnabled: enabled);
  }

  void updateLocationSharing(bool enabled) {
    state = state.copyWith(locationSharingEnabled: enabled);
  }

  void performSecurityCheck() {
    state = state.copyWith(lastSecurityCheck: DateTime.now());
  }
}

class SafetyCenterPage extends ConsumerStatefulWidget {
  const SafetyCenterPage({super.key});

  @override
  ConsumerState<SafetyCenterPage> createState() => _SafetyCenterPageState();
}

class _SafetyCenterPageState extends ConsumerState<SafetyCenterPage> {
  @override
  Widget build(BuildContext context) {
    final safetyStatus = ref.watch(safetyStatusProvider);
    final notifier = ref.read(safetyStatusProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('安全中心'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showSafetyTips();
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 安全等級概覽
            _buildSafetyOverview(safetyStatus),
            
            const SizedBox(height: 24),
            
            // 身份驗證
            _buildVerificationSection(safetyStatus, notifier),
            
            const SizedBox(height: 16),
            
            // 隱私設置
            _buildPrivacySection(safetyStatus, notifier),
            
            const SizedBox(height: 16),
            
            // 安全工具
            _buildSafetyToolsSection(),
            
            const SizedBox(height: 16),
            
            // 舉報和封鎖
            _buildReportingSection(safetyStatus),
            
            const SizedBox(height: 16),
            
            // 緊急功能
            _buildEmergencySection(),
            
            const SizedBox(height: 32),
            
            // 安全檢查按鈕
            _buildSecurityCheckButton(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyOverview(SafetyStatus status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status.safetyLevelColor.withOpacity(0.1),
            status.safetyLevelColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.safetyLevelColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status.safetyLevelColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  color: status.safetyLevelColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '安全等級：${status.safetyLevel}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: status.safetyLevelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '驗證完成度：${status.verificationScore.toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 進度條
          LinearProgressIndicator(
            value: status.verificationScore / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(status.safetyLevelColor),
            minHeight: 8,
          ),
          
          const SizedBox(height: 16),
          
          // 安全提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSafetyTip(status.verificationScore),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(SafetyStatus status, SafetyStatusNotifier notifier) {
    return _buildSectionCard(
      title: '身份驗證',
      icon: Icons.verified_user,
      children: [
        _buildVerificationTile(
          title: '照片驗證',
          subtitle: '確認你的照片是真實的',
          isVerified: status.photoVerified,
          onTap: () => _showPhotoVerification(notifier),
          icon: Icons.camera_alt,
        ),
        _buildVerificationTile(
          title: '語音驗證',
          subtitle: '錄製語音片段進行驗證',
          isVerified: status.voiceVerified,
          onTap: () => _showVoiceVerification(notifier),
          icon: Icons.mic,
        ),
        _buildVerificationTile(
          title: '手機號碼',
          subtitle: '已驗證的手機號碼',
          isVerified: status.phoneVerified,
          onTap: () => _showPhoneVerification(),
          icon: Icons.phone,
        ),
        _buildVerificationTile(
          title: '電子郵件',
          subtitle: '已驗證的電子郵件地址',
          isVerified: status.emailVerified,
          onTap: () => _showEmailVerification(),
          icon: Icons.email,
        ),
      ],
    );
  }

  Widget _buildPrivacySection(SafetyStatus status, SafetyStatusNotifier notifier) {
    return _buildSectionCard(
      title: '隱私設置',
      icon: Icons.privacy_tip,
      children: [
        _buildSwitchTile(
          title: '雙重驗證',
          subtitle: '為你的帳戶添加額外保護',
          value: status.twoFactorEnabled,
          onChanged: notifier.updateTwoFactor,
          icon: Icons.security,
          color: Colors.green,
        ),
        _buildSwitchTile(
          title: '位置分享',
          subtitle: '允許顯示大概位置',
          value: status.locationSharingEnabled,
          onChanged: notifier.updateLocationSharing,
          icon: Icons.location_on,
          color: Colors.blue,
        ),
        _buildActionTile(
          title: '隱私設置',
          subtitle: '管理誰可以看到你的檔案',
          onTap: () => Navigator.pushNamed(context, '/privacy_settings'),
          icon: Icons.visibility,
          color: Colors.purple,
        ),
        _buildActionTile(
          title: '封鎖名單',
          subtitle: '管理已封鎖的用戶',
          onTap: () => Navigator.pushNamed(context, '/blocked_users'),
          icon: Icons.block,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSafetyToolsSection() {
    return _buildSectionCard(
      title: '安全工具',
      icon: Icons.build,
      children: [
        _buildActionTile(
          title: '約會安全指南',
          subtitle: '學習如何安全約會',
          onTap: () => Navigator.pushNamed(context, '/dating_safety_guide'),
          icon: Icons.menu_book,
          color: Colors.teal,
        ),
        _buildActionTile(
          title: '舉報用戶',
          subtitle: '舉報不當行為或虛假檔案',
          onTap: () => Navigator.pushNamed(context, '/report_user'),
          icon: Icons.report,
          color: Colors.orange,
        ),
        _buildActionTile(
          title: '安全檢查清單',
          subtitle: '確保你的帳戶安全',
          onTap: () => _showSafetyChecklist(),
          icon: Icons.checklist,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildReportingSection(SafetyStatus status) {
    return _buildSectionCard(
      title: '舉報和封鎖',
      icon: Icons.shield,
      children: [
        _buildStatTile(
          title: '舉報次數',
          value: '${status.reportCount}',
          subtitle: '你提交的舉報',
          icon: Icons.flag,
          color: Colors.orange,
        ),
        _buildStatTile(
          title: '封鎖用戶',
          value: '${status.blockCount}',
          subtitle: '已封鎖的用戶數量',
          icon: Icons.block,
          color: Colors.red,
        ),
        _buildActionTile(
          title: '舉報歷史',
          subtitle: '查看你的舉報記錄',
          onTap: () => Navigator.pushNamed(context, '/report_history'),
          icon: Icons.history,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
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
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '緊急功能',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildActionTile(
            title: '緊急聯絡人',
            subtitle: '設置緊急情況下的聯絡人',
            onTap: () => Navigator.pushNamed(context, '/emergency_contacts'),
            icon: Icons.contact_emergency,
            color: Colors.red,
          ),
          _buildActionTile(
            title: '安全約會功能',
            subtitle: '與朋友分享約會計劃',
            onTap: () => Navigator.pushNamed(context, '/safe_dating'),
            icon: Icons.share_location,
            color: Colors.red,
          ),
        ],
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

  Widget _buildVerificationTile({
    required String title,
    required String subtitle,
    required bool isVerified,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isVerified ? Colors.green : Colors.grey,
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
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '已驗證',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
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

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCheckButton(SafetyStatusNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          notifier.performSecurityCheck();
          _showSecurityCheckResult();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security),
            SizedBox(width: 8),
            Text(
              '執行安全檢查',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSafetyTip(double score) {
    if (score >= 80) {
      return '你的帳戶安全等級很高！繼續保持良好的安全習慣。';
    } else if (score >= 50) {
      return '考慮完成更多驗證來提高你的安全等級。';
    } else {
      return '建議完成身份驗證來提高帳戶安全性。';
    }
  }

  void _showPhotoVerification(SafetyStatusNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('照片驗證'),
        content: const Text('我們將引導你完成照片驗證流程，確保你的照片是真實的。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.updatePhotoVerification(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('照片驗證已完成')),
              );
            },
            child: const Text('開始驗證'),
          ),
        ],
      ),
    );
  }

  void _showVoiceVerification(SafetyStatusNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('語音驗證'),
        content: const Text('請錄製一段語音來驗證你的身份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.updateVoiceVerification(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('語音驗證已完成')),
              );
            },
            child: const Text('開始錄製'),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('手機號碼已驗證')),
    );
  }

  void _showEmailVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('電子郵件已驗證')),
    );
  }

  void _showSafetyTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安全提示'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• 不要分享個人敏感信息'),
              SizedBox(height: 8),
              Text('• 在公共場所進行第一次約會'),
              SizedBox(height: 8),
              Text('• 告訴朋友你的約會計劃'),
              SizedBox(height: 8),
              Text('• 相信你的直覺'),
              SizedBox(height: 8),
              Text('• 舉報可疑行為'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showSafetyChecklist() {
    Navigator.pushNamed(context, '/safety_checklist');
  }

  void _showSecurityCheckResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安全檢查完成'),
        content: const Text('你的帳戶安全檢查已完成，未發現安全問題。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
} 