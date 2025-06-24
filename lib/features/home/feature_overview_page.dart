import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

class FeatureOverviewPage extends ConsumerWidget {
  const FeatureOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _buildWelcomeCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('🔥 核心功能'),
                  const SizedBox(height: AppSpacing.md),
                  _buildCoreFeatures(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('✨ 高級功能'),
                  const SizedBox(height: AppSpacing.md),
                  _buildPremiumFeatures(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('🎯 專業服務'),
                  const SizedBox(height: AppSpacing.md),
                  _buildProfessionalServices(context),
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
        gradient: AppColors.primaryGradient,
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
                    Icons.apps,
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
                        'Amore 功能總覽',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        '探索所有強大功能',
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
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '25+ 項專業功能',
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

  Widget _buildWelcomeCard() {
    return AppCard(
      backgroundColor: AppColors.info.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: AppColors.info,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '歡迎來到 Amore',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '超越傳統約會應用的全新體驗，AI 驅動的智能配對，專業的愛情顧問服務',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
        title: '智能探索',
        description: '基於 AI 算法的精準配對',
        color: AppColors.primary,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '智能探索', '使用先進的機器學習算法，根據你的偏好、行為模式和兼容性指標，為你推薦最合適的配對對象。'),
      ),
      FeatureItem(
        icon: Icons.favorite,
        title: '配對管理',
        description: '管理你的所有配對',
        color: AppColors.error,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '配對管理', '查看新配對、管理現有配對、分析配對度，一站式管理你的所有約會對象。'),
      ),
      FeatureItem(
        icon: Icons.chat,
        title: '即時聊天',
        description: '安全的端到端加密聊天',
        color: AppColors.success,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '即時聊天', '支持文字、圖片、語音消息，內置 AI 聊天助手，幫你找到完美的話題。'),
      ),
      FeatureItem(
        icon: Icons.videocam,
        title: '視頻通話',
        description: '高清視頻和語音通話',
        color: AppColors.info,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '視頻通話', '安全的端到端加密視頻通話，支持美顏濾鏡、虛擬背景等功能。'),
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
        icon: Icons.psychology,
        title: 'AI 愛情顧問',
        description: '專業的關係建議和指導',
        color: AppColors.secondary,
        status: FeatureStatus.available,
        isPremium: true,
        onTap: () => _showFeatureDetail(context, 'AI 愛情顧問', '基於心理學和大數據的專業愛情建議，幫你建立更好的關係。'),
      ),
      FeatureItem(
        icon: Icons.auto_stories,
        title: 'Stories 動態',
        description: '分享你的生活瞬間',
        color: AppColors.warning,
        status: FeatureStatus.comingSoon,
        onTap: () => _showFeatureDetail(context, 'Stories 動態', '類似 Instagram Stories 的功能，讓配對對象更了解真實的你。'),
      ),
      FeatureItem(
        icon: Icons.event,
        title: '活動推薦',
        description: '個性化約會活動建議',
        color: AppColors.info,
        status: FeatureStatus.comingSoon,
        onTap: () => _showFeatureDetail(context, '活動推薦', '基於你們的共同興趣和位置，推薦完美的約會活動和地點。'),
      ),
      FeatureItem(
        icon: Icons.diamond,
        title: 'Premium 會員',
        description: '解鎖所有高級功能',
        color: AppColors.warning,
        status: FeatureStatus.available,
        isPremium: true,
        onTap: () => _showFeatureDetail(context, 'Premium 會員', '無限喜歡、超級喜歡、Boost、高級篩選等專屬功能。'),
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

  Widget _buildProfessionalServices(BuildContext context) {
    final services = [
      FeatureItem(
        icon: Icons.analytics,
        title: '關係分析',
        description: '深度分析你的約會模式',
        color: AppColors.info,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '關係分析', '分析你的聊天模式、配對成功率、約會偏好等，提供個性化改進建議。'),
      ),
      FeatureItem(
        icon: Icons.security,
        title: '安全保護',
        description: '多重安全驗證機制',
        color: AppColors.success,
        status: FeatureStatus.available,
        onTap: () => _showFeatureDetail(context, '安全保護', '照片驗證、身份認證、行為監控、舉報系統等多重保護機制。'),
      ),
    ];

    return Row(
      children: services.map((service) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: services.indexOf(service) == services.length - 1 
                  ? 0 : AppSpacing.sm,
              left: services.indexOf(service) == 0 
                  ? 0 : AppSpacing.sm,
            ),
            child: _buildFeatureCard(service),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  feature.icon,
                  color: feature.color,
                  size: 28,
                ),
              ),
              const Spacer(),
              if (feature.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(feature.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  _getStatusText(feature.status),
                  style: AppTextStyles.overline.copyWith(
                    color: _getStatusColor(feature.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
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

  Color _getStatusColor(FeatureStatus status) {
    switch (status) {
      case FeatureStatus.available:
        return AppColors.success;
      case FeatureStatus.comingSoon:
        return AppColors.warning;
      case FeatureStatus.beta:
        return AppColors.info;
    }
  }

  String _getStatusText(FeatureStatus status) {
    switch (status) {
      case FeatureStatus.available:
        return '可用';
      case FeatureStatus.comingSoon:
        return '即將推出';
      case FeatureStatus.beta:
        return '測試版';
    }
  }

  void _showFeatureDetail(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: Text(title),
        content: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
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
}

enum FeatureStatus {
  available,
  comingSoon,
  beta,
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final FeatureStatus status;
  final bool isPremium;
  final VoidCallback onTap;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.status,
    this.isPremium = false,
    required this.onTap,
  });
} 