import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入個人檔案增強功能
import 'lib/features/profile/enhanced_profile_page.dart';
import 'lib/core/theme/app_design_system.dart';
import 'lib/shared/widgets/app_components.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedProfileDemo()));
}

class EnhancedProfileDemo extends StatelessWidget {
  const EnhancedProfileDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Profile Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ProfileDemoSelectionPage(),
    );
  }
}

class ProfileDemoSelectionPage extends StatelessWidget {
  const ProfileDemoSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
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
                      Icons.person_pin,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '個人檔案增強',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '展示重新設計的個人檔案功能',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 功能亮點
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ 主要功能亮點',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    _buildFeatureCard(
                      icon: Icons.photo_library,
                      title: '重新設計的照片管理',
                      subtitle: '拖拽排序、主要照片設置、照片編輯',
                      color: AppColors.primary,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    _buildFeatureCard(
                      icon: Icons.favorite,
                      title: '興趣標籤視覺化系統',
                      subtitle: '分類選擇、搜索功能、MBTI推薦',
                      color: AppColors.secondary,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    _buildFeatureCard(
                      icon: Icons.auto_stories,
                      title: 'Stories 功能整合',
                      subtitle: '動態發布、預覽展示、統計分析',
                      color: const Color(0xFFE91E63),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    _buildFeatureCard(
                      icon: Icons.psychology,
                      title: 'MBTI 和約會模式展示',
                      subtitle: '優化的個性展示和配對信息',
                      color: const Color(0xFF9C27B0),
                    ),
                    
                    const Spacer(),
                    
                    // 演示按鈕
                    Column(
                      children: [
                        AppButton(
                          text: '查看我的檔案（編輯模式）',
                          onPressed: () => _navigateToProfile(context, true),
                          type: AppButtonType.primary,
                          icon: Icons.edit,
                          isFullWidth: true,
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        AppButton(
                          text: '查看他人檔案（瀏覽模式）',
                          onPressed: () => _navigateToProfile(context, false),
                          type: AppButtonType.outline,
                          icon: Icons.visibility,
                          isFullWidth: true,
                        ),
                      ],
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, bool isOwnProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedProfilePage(
          isOwnProfile: isOwnProfile,
          userId: isOwnProfile ? null : 'demo_user',
        ),
      ),
    );
  }
} 