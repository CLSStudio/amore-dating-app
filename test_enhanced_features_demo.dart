import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入新功能
import 'lib/features/stories/enhanced_stories_viewer.dart';
import 'lib/features/stories/story_creator.dart';
import 'lib/features/ai/enhanced_ai_consultant.dart';
import 'lib/features/premium/premium_subscription.dart';
import 'lib/core/theme/app_design_system.dart';
import 'lib/shared/widgets/app_components.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedFeaturesDemo()));
}

class EnhancedFeaturesDemo extends StatelessWidget {
  const EnhancedFeaturesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore Enhanced Features Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const FeaturesSelectionPage(),
    );
  }
}

class FeaturesSelectionPage extends StatelessWidget {
  const FeaturesSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              
              // 標題區域
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                  boxShadow: AppShadows.floating,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Amore 增強功能',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '體驗全新的Stories、AI助手和Premium功能',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 功能列表
              _buildFeatureCard(
                context,
                icon: Icons.auto_stories,
                title: 'Stories 功能視覺化',
                subtitle: '24小時限時動態，多媒體內容，互動反應',
                features: [
                  '✨ 24小時自動消失動態',
                  '📸 多媒體內容支持（文字、圖片、視頻、投票）',
                  '❤️ 互動反應動畫效果',
                  '🎨 豐富的創建和編輯工具',
                ],
                color: const Color(0xFFE91E63),
                onViewerTap: () => _navigateToStoriesViewer(context),
                onCreatorTap: () => _navigateToStoryCreator(context),
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildFeatureCard(
                context,
                icon: Icons.psychology,
                title: 'AI 助手體驗提升',
                subtitle: '專業諮詢界面，個性化建議，香港本地化',
                features: [
                  '🤖 專業愛情顧問對話界面',
                  '💡 個性化建議卡片系統',
                  '🏙️ 基於香港地點的約會建議',
                  '📊 智能分析和信心度評估',
                ],
                color: const Color(0xFF9C27B0),
                onViewerTap: () => _navigateToAIConsultant(context),
                onCreatorTap: null,
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildFeatureCard(
                context,
                icon: Icons.diamond,
                title: 'Premium 會員訂閱系統',
                subtitle: '吸引人的訂閱頁面，會員專屬功能展示',
                features: [
                  '💎 精美的訂閱頁面設計',
                  '📋 清晰的功能對比表格',
                  '💳 用戶友好的付費流程',
                  '🎁 會員專屬功能視覺化',
                ],
                color: const Color(0xFFFF9800),
                onViewerTap: () => _navigateToPremium(context),
                onCreatorTap: null,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 技術亮點
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  boxShadow: AppShadows.medium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.engineering,
                          color: AppColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '技術亮點',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    ...[
                      '🎯 Flutter + Riverpod 響應式狀態管理',
                      '🎨 Material Design 3 設計規範',
                      '⚡ 流暢的動畫和過場效果',
                      '📱 完整的移動端適配',
                      '🔧 模組化代碼架構',
                      '🌟 統一的設計系統',
                    ].map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.substring(0, 2),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              feature.substring(2),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> features,
    required Color color,
    required VoidCallback? onViewerTap,
    required VoidCallback? onCreatorTap,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題區域
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 功能列表
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.substring(0, 2),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    feature.substring(2),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          )).toList(),

          const SizedBox(height: AppSpacing.lg),

          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: onCreatorTap != null ? '創建/編輯' : '體驗功能',
                  onPressed: onViewerTap,
                  type: AppButtonType.primary,
                ),
              ),
              if (onCreatorTap != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: '查看器',
                    onPressed: onCreatorTap,
                    type: AppButtonType.outline,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToStoriesViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedStoriesViewer(
          userId: 'demo_user',
          initialIndex: 0,
        ),
      ),
    );
  }

  void _navigateToStoryCreator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StoryCreator(),
      ),
    );
  }

  void _navigateToAIConsultant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedAIConsultant(),
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumSubscriptionPage(),
      ),
    );
  }
} 