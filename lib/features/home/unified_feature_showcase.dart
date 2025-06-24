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

class UnifiedFeatureShowcase extends ConsumerWidget {
  const UnifiedFeatureShowcase({super.key});

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
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('🎯 核心功能'),
                  const SizedBox(height: AppSpacing.md),
                  _buildCoreFeatures(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('💎 Premium 功能'),
                  const SizedBox(height: AppSpacing.md),
                  _buildPremiumFeatures(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('🔧 工具與設置'),
                  const SizedBox(height: AppSpacing.md),
                  _buildToolsAndSettings(context),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return AppCard(
      backgroundColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💕',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '歡迎來到 Amore',
            style: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '探索我們的智能約會功能，找到你的完美配對',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.whiteWithOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppChip(
            label: '9 個核心功能已完成 ✨',
            backgroundColor: AppColors.whiteWithOpacity(0.2),
            textColor: AppColors.textOnPrimary,
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

  Widget _buildCoreFeatures(BuildContext context) {
    final coreFeatures = [
      FeatureItem(
        icon: Icons.explore,
        title: '智能滑動',
        description: '多維度匹配算法，找到最適合的人',
        color: AppColors.info,
        onTap: () => _showFeatureInfo(context, '智能滑動', '基於 MBTI、興趣、價值觀等多維度的智能匹配算法'),
      ),
      FeatureItem(
        icon: Icons.chat_bubble,
        title: 'AI 聊天助手',
        description: '智能破冰話題和約會建議',
        color: AppColors.success,
        onTap: () => _showFeatureInfo(context, 'AI 聊天助手', '提供個性化的對話建議、破冰話題和約會規劃'),
      ),
      FeatureItem(
        icon: Icons.auto_stories,
        title: 'Stories 功能',
        description: '分享真實生活瞬間',
        color: AppColors.secondary,
        onTap: () => _showFeatureInfo(context, 'Stories 功能', '24小時限時動態，展示真實的你'),
      ),
      FeatureItem(
        icon: Icons.videocam,
        title: '視頻通話',
        description: '安全的線上見面功能',
        color: AppColors.warning,
        onTap: () => _showFeatureInfo(context, '視頻通話', '內建視頻通話功能，安全便捷的線上交流'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
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
        color: AppColors.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumSubscriptionPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.event,
        title: '活動推薦',
        description: '基於興趣的個性化活動推薦',
        color: AppColors.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventRecommendationPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.analytics,
        title: '關係追蹤',
        description: '完整的關係生命週期管理',
        color: AppColors.success,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RelationshipTrackingPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.share,
        title: '社交媒體',
        description: '連接 Instagram、Spotify 等',
        color: AppColors.primary,
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
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
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
        color: AppColors.error,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        ),
      ),
      FeatureItem(
        icon: Icons.security,
        title: '安全中心',
        description: '隱私保護和安全設置',
        color: AppColors.textSecondary,
        onTap: () => _showFeatureInfo(context, '安全中心', '完善的隱私保護和安全功能'),
      ),
    ];

    return Row(
      children: tools.map((tool) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: tools.indexOf(tool) == tools.length - 1 ? 0 : AppSpacing.sm,
              left: tools.indexOf(tool) == 0 ? 0 : AppSpacing.sm,
            ),
            child: _buildFeatureCard(tool),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return AppCard(
      onTap: feature.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: AppBorderRadius.medium,
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            feature.title,
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              feature.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                '探索',
                style: AppTextStyles.caption.copyWith(
                  color: feature.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: feature.color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeatureInfo(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: Text(
          title,
          style: AppTextStyles.h5,
        ),
        content: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          AppButton(
            text: '了解',
            onPressed: () => Navigator.pop(context),
            type: AppButtonType.primary,
            size: AppButtonSize.small,
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