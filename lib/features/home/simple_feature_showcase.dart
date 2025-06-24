import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

class SimpleFeatureShowcase extends ConsumerWidget {
  const SimpleFeatureShowcase({super.key});

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
                  _buildSimpleFeatureGrid(),
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

  Widget _buildSimpleFeatureGrid() {
    final features = [
      _FeatureData(
        icon: Icons.explore,
        title: '智能滑動',
        description: '多維度匹配算法',
        color: AppColors.info,
      ),
      _FeatureData(
        icon: Icons.chat_bubble,
        title: 'AI 聊天助手',
        description: '智能破冰話題',
        color: AppColors.success,
      ),
      _FeatureData(
        icon: Icons.auto_stories,
        title: 'Stories 功能',
        description: '分享真實生活',
        color: AppColors.secondary,
      ),
      _FeatureData(
        icon: Icons.videocam,
        title: '視頻通話',
        description: '安全線上見面',
        color: AppColors.warning,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return AppCard(
          onTap: () => _showFeatureInfo(context, feature.title, feature.description),
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
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
      },
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

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
} 