import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 導入功能頁面
import '../premium/premium_subscription.dart';
import '../notifications/push_notification_system.dart';
import '../social_media/social_media_integration.dart';
import '../events/event_recommendation_system.dart';
import '../relationship_tracking/relationship_success_tracking.dart';

class FeatureShowcasePage extends ConsumerWidget {
  const FeatureShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppPageHeader(
            title: 'Amore 功能中心',
            subtitle: '探索我們的智能約會功能',
            showBackButton: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('🎯 核心功能'),
                  const SizedBox(height: 16),
                  _buildCoreFeatures(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('💎 Premium 功能'),
                  const SizedBox(height: 16),
                  _buildPremiumFeatures(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('🔧 工具與設置'),
                  const SizedBox(height: 16),
                  _buildToolsAndSettings(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63),
            Color(0xFF9C27B0),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💕',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            '歡迎來到 Amore',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '探索我們的智能約會功能，找到你的完美配對',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '9 個核心功能已完成 ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildCoreFeatures(BuildContext context) {
    final coreFeatures = [
      FeatureItem(
        icon: Icons.explore,
        title: '智能滑動',
        description: '多維度匹配算法，找到最適合的人',
        color: Colors.blue,
        onTap: () => _showFeatureInfo(context, '智能滑動', '基於 MBTI、興趣、價值觀等多維度的智能匹配算法'),
      ),
      FeatureItem(
        icon: Icons.chat_bubble,
        title: 'AI 聊天助手',
        description: '智能破冰話題和約會建議',
        color: Colors.green,
        onTap: () => _showFeatureInfo(context, 'AI 聊天助手', '提供個性化的對話建議、破冰話題和約會規劃'),
      ),
      FeatureItem(
        icon: Icons.auto_stories,
        title: 'Stories 功能',
        description: '分享真實生活瞬間',
        color: Colors.purple,
        onTap: () => _showFeatureInfo(context, 'Stories 功能', '24小時限時動態，展示真實的你'),
      ),
      FeatureItem(
        icon: Icons.videocam,
        title: '視頻通話',
        description: '安全的線上見面功能',
        color: Colors.orange,
        onTap: () => _showFeatureInfo(context, '視頻通話', '內建視頻通話功能，安全便捷的線上交流'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: coreFeatures.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(coreFeatures[index]);
      },
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    final premiumFeatures = [
      FeatureItem(
        icon: Icons.diamond,
        title: 'Premium 訂閱',
        description: '解鎖高級功能和專屬服務',
        color: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumSubscriptionPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.event,
        title: '活動推薦',
        description: '基於興趣的個性化活動推薦',
        color: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventRecommendationPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.analytics,
        title: '關係追蹤',
        description: '完整的關係生命週期管理',
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RelationshipTrackingPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.share,
        title: '社交媒體',
        description: '連接 Instagram、Spotify 等',
        color: Colors.pink,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SocialMediaIntegrationPage()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: premiumFeatures.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(premiumFeatures[index]);
      },
    );
  }

  Widget _buildToolsAndSettings(BuildContext context) {
    final tools = [
      FeatureItem(
        icon: Icons.notifications,
        title: '通知設置',
        description: '個性化通知管理',
        color: Colors.red,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.security,
        title: '安全中心',
        description: '隱私保護和安全設置',
        color: Colors.grey,
        onTap: () => _showFeatureInfo(context, '安全中心', '完善的隱私保護和安全功能'),
      ),
    ];

    return Row(
      children: tools.map((tool) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: tools.indexOf(tool) == tools.length - 1 ? 0 : 8,
              left: tools.indexOf(tool) == 0 ? 0 : 8,
            ),
            child: _buildFeatureCard(tool),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: feature.color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feature.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                feature.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '探索',
                  style: TextStyle(
                    fontSize: 12,
                    color: feature.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: feature.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureInfo(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '了解',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
} 