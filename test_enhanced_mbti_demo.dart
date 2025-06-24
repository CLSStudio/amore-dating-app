import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入升級後的MBTI功能
import 'lib/features/mbti/enhanced_mbti_test_page.dart';
import 'lib/core/theme/app_design_system.dart';
import 'lib/shared/widgets/app_components.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedMBTITestDemo()));
}

class EnhancedMBTITestDemo extends StatelessWidget {
  const EnhancedMBTITestDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced MBTI Test Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MBTITestSelectionPage(),
    );
  }
}

class MBTITestSelectionPage extends StatelessWidget {
  const MBTITestSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              
              // 標題區域
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                  boxShadow: AppShadows.floating,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'MBTI 性格測試',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '發現真實的自己，找到完美匹配',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 測試模式選擇
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '選擇測試模式',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    _buildTestModeCard(
                      context,
                      title: '快速測試',
                      subtitle: '16題 • 5分鐘',
                      description: '快速了解基本性格類型',
                      icon: Icons.flash_on,
                      color: Colors.orange,
                      mode: MBTITestMode.quick,
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    _buildTestModeCard(
                      context,
                      title: '互動式測試',
                      subtitle: '32題 • 12分鐘',
                      description: '深度分析，個性化體驗',
                      icon: Icons.psychology,
                      color: AppColors.primary,
                      mode: MBTITestMode.interactive,
                      isRecommended: true,
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    _buildTestModeCard(
                      context,
                      title: '專業版測試',
                      subtitle: '60題 • 20分鐘',
                      description: '最準確的完整性格分析',
                      icon: Icons.verified,
                      color: Colors.purple,
                      mode: MBTITestMode.professional,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 底部說明
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '所有測試結果均可保存到個人檔案並用於智能配對',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required MBTITestMode mode,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: () => _startTest(context, mode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: isRecommended
              ? Border.all(color: color, width: 2)
              : null,
          boxShadow: AppShadows.medium,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h6.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            // 推薦標籤
            if (isRecommended)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    '推薦',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startTest(BuildContext context, MBTITestMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedMBTITestPage(mode: mode),
      ),
    );
  }
} 