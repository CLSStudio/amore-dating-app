import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

class SimpleAIHubPage extends ConsumerWidget {
  const SimpleAIHubPage({super.key});

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
        onTap: () => _showAIConsultantDemo(context),
      ),
      AIFeature(
        icon: Icons.chat_bubble_outline,
        title: '聊天助手',
        description: '智能破冰話題和回覆建議',
        color: AppColors.success,
        onTap: () => _showChatAssistantDemo(context),
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
        onTap: () => _showConversationAnalysisDemo(context),
      ),
      AIFeature(
        icon: Icons.favorite_border,
        title: '兼容性分析',
        description: '評估你們的匹配程度',
        color: AppColors.warning,
        onTap: () => _showCompatibilityAnalysisDemo(context),
      ),
      AIFeature(
        icon: Icons.trending_up,
        title: '關係預測',
        description: '預測關係發展趨勢',
        color: AppColors.secondary,
        onTap: () => _showRelationshipPredictionDemo(context),
      ),
      AIFeature(
        icon: Icons.compare,
        title: '對象比較',
        description: '智能比較不同配對對象',
        color: AppColors.success,
        onTap: () => _showObjectComparisonDemo(context),
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
        onTap: () => _showDatePlanningDemo(context),
      ),
      AIFeature(
        icon: Icons.message,
        title: '消息建議',
        description: '智能回覆和話題推薦',
        color: AppColors.info,
        onTap: () => _showMessageSuggestionsDemo(context),
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
          Text(
            feature.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  // 演示功能方法
  void _showAIConsultantDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '🤖 AI 愛情顧問',
      '基於你的個人資料和聊天記錄，AI 為你提供個性化的關係建議：\n\n'
      '• 分析你的溝通風格\n'
      '• 提供約會建議\n'
      '• 關係發展指導\n'
      '• 衝突解決方案',
      AppColors.primary,
    );
  }

  void _showChatAssistantDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '💬 聊天助手',
      'AI 幫助你更好地與配對對象溝通：\n\n'
      '• 智能破冰話題\n'
      '• 回覆建議\n'
      '• 對話節奏把控\n'
      '• 興趣話題推薦',
      AppColors.success,
    );
  }

  void _showConversationAnalysisDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '📊 對話分析',
      'AI 深度分析你們的聊天內容：\n\n'
      '• 真心度評估：85%\n'
      '• 興趣匹配度：92%\n'
      '• 溝通頻率：良好\n'
      '• 話題豐富度：高',
      AppColors.info,
    );
  }

  void _showCompatibilityAnalysisDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '💕 兼容性分析',
      '基於 MBTI 和價值觀的深度匹配分析：\n\n'
      '• 性格匹配度：88%\n'
      '• 生活方式：相似\n'
      '• 價值觀：高度一致\n'
      '• 長期潛力：優秀',
      AppColors.warning,
    );
  }

  void _showRelationshipPredictionDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '🔮 關係預測',
      'AI 預測你們關係的發展趨勢：\n\n'
      '• 短期發展：積極\n'
      '• 穩定性指數：高\n'
      '• 潛在挑戰：溝通差異\n'
      '• 建議行動：增加面對面交流',
      AppColors.secondary,
    );
  }

  void _showObjectComparisonDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '⚖️ 對象比較',
      '智能比較不同配對對象的優勢：\n\n'
      '小雅：興趣匹配度高，性格互補\n'
      '美玲：價值觀一致，生活節奏相似\n'
      '詩婷：溝通順暢，共同目標明確\n\n'
      '推薦：根據你的偏好，美玲最適合',
      AppColors.success,
    );
  }

  void _showDatePlanningDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '📅 約會規劃',
      '基於你們的共同興趣和位置推薦：\n\n'
      '🎨 藝術約會：香港藝術館\n'
      '🍽️ 美食體驗：中環米其林餐廳\n'
      '🌅 浪漫散步：維多利亞港\n'
      '🎬 電影之夜：太古城電影院',
      AppColors.warning,
    );
  }

  void _showMessageSuggestionsDemo(BuildContext context) {
    _showDemoDialog(
      context,
      '💌 消息建議',
      '根據對方的回覆風格，AI 建議：\n\n'
      '破冰話題：\n'
      '"我看到你喜歡攝影，有什麼推薦的拍攝地點嗎？"\n\n'
      '回覆建議：\n'
      '"哇，你的作品真的很有創意！我也想學習攝影技巧"',
      AppColors.info,
    );
  }

  void _showDemoDialog(
    BuildContext context,
    String title,
    String content,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(
          content,
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