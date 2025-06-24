import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 導入 AI 功能頁面
import 'ai_love_consultant_page.dart';
import 'pages/conversation_analysis_page.dart';

class AIHubPage extends ConsumerWidget {
  const AIHubPage({super.key});

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
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('🤖 AI 助手'),
                  const SizedBox(height: AppSpacing.md),
                  _buildAIAssistants(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('📊 AI 分析'),
                  const SizedBox(height: AppSpacing.md),
                  _buildAIAnalysis(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('💡 AI 建議'),
                  const SizedBox(height: AppSpacing.md),
                  _buildAISuggestions(context),
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
            AppColors.primary,
            AppColors.secondary,
            const Color(0xFF6A1B9A),
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
                    Icons.psychology,
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
                        'AI 愛情顧問',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        '智能分析，專業建議',
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
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'AI 驅動的約會體驗',
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
              Icons.lightbulb,
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
                  '歡迎使用 AI 功能',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '讓人工智能幫助你找到真愛，分析關係，提供專業建議',
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

  Widget _buildAIAssistants(BuildContext context) {
    final assistants = [
      AIFeature(
        icon: Icons.psychology,
        title: 'AI 愛情顧問',
        description: '專業的關係建議和指導',
        color: AppColors.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AILoveConsultantPage(),
          ),
        ),
      ),
      AIFeature(
        icon: Icons.chat_bubble_outline,
        title: '聊天助手',
        description: '智能破冰話題和回覆建議',
        color: AppColors.success,
        onTap: () => _showComingSoon(context, '聊天助手'),
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
      itemCount: assistants.length,
      itemBuilder: (context, index) {
        return _buildAIFeatureCard(assistants[index]);
      },
    );
  }

  Widget _buildAIAnalysis(BuildContext context) {
    final analysisFeatures = [
      AIFeature(
        icon: Icons.analytics,
        title: '對話分析',
        description: '深度分析聊天內容和真心度',
        color: AppColors.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConversationAnalysisPage(),
          ),
        ),
      ),
      AIFeature(
        icon: Icons.favorite_border,
        title: '兼容性分析',
        description: '評估你們的匹配程度',
        color: AppColors.warning,
        onTap: () => _showComingSoon(context, '兼容性分析'),
      ),
      AIFeature(
        icon: Icons.trending_up,
        title: '關係預測',
        description: '預測關係發展趨勢',
        color: AppColors.secondary,
        onTap: () => _showComingSoon(context, '關係預測'),
      ),
      AIFeature(
        icon: Icons.compare,
        title: '對象比較',
        description: '智能比較不同配對對象',
        color: AppColors.success,
        onTap: () => _showComingSoon(context, '對象比較'),
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
      itemCount: analysisFeatures.length,
      itemBuilder: (context, index) {
        return _buildAIFeatureCard(analysisFeatures[index]);
      },
    );
  }

  Widget _buildAISuggestions(BuildContext context) {
    final suggestions = [
      AIFeature(
        icon: Icons.restaurant,
        title: '約會規劃',
        description: '個性化約會地點和活動建議',
        color: AppColors.warning,
        onTap: () => _showComingSoon(context, '約會規劃'),
      ),
      AIFeature(
        icon: Icons.message,
        title: '消息建議',
        description: '智能回覆和話題推薦',
        color: AppColors.info,
        onTap: () => _showComingSoon(context, '消息建議'),
      ),
    ];

    return Row(
      children: suggestions.map((suggestion) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: suggestions.indexOf(suggestion) == suggestions.length - 1 
                  ? 0 : AppSpacing.sm,
              left: suggestions.indexOf(suggestion) == 0 
                  ? 0 : AppSpacing.sm,
            ),
            child: _buildAIFeatureCard(suggestion),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAIFeatureCard(AIFeature feature) {
    return AppCard(
      onTap: feature.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                '體驗',
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

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('即將推出'),
          ],
        ),
        content: Text(
          '$featureName 功能正在開發中，敬請期待！',
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

class AIFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  AIFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
} 