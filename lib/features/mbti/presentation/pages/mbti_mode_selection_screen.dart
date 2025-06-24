import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../onboarding/presentation/widgets/animated_background.dart';

class MBTIModeSelectionScreen extends StatefulWidget {
  const MBTIModeSelectionScreen({super.key});

  @override
  State<MBTIModeSelectionScreen> createState() => _MBTIModeSelectionScreenState();
}

class _MBTIModeSelectionScreenState extends State<MBTIModeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? _selectedMode;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 返回按鈕
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 標題區域
                    _buildHeader(),
                    
                    const SizedBox(height: 48),
                    
                    // 模式選擇卡片
                    Expanded(
                      child: Column(
                        children: [
                          _buildModeCard(
                            mode: 'simple',
                            title: '快速分析',
                            subtitle: '20 道精選問題',
                            duration: '5-8 分鐘',
                            accuracy: '80-85%',
                            description: '適合想要快速了解自己性格類型的用戶',
                            icon: Icons.flash_on,
                            color: AppColors.secondary,
                            features: [
                              '精選核心問題',
                              '快速獲得結果',
                              '基礎性格分析',
                              '匹配建議',
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildModeCard(
                            mode: 'professional',
                            title: '專業分析',
                            subtitle: '60 道深度問題',
                            duration: '15-20 分鐘',
                            accuracy: '90-95%',
                            description: '適合想要深入了解自己性格特質的用戶',
                            icon: Icons.psychology,
                            color: AppColors.primary,
                            features: [
                              '全面性格評估',
                              '詳細特質分析',
                              '深度匹配洞察',
                              '個性化建議',
                            ],
                            isRecommended: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 開始按鈕
                    _buildStartButton(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                 Text(
           '選擇測試模式',
           style: AppTextStyles.headline1.copyWith(
             color: AppColors.textPrimary,
             fontWeight: FontWeight.bold,
           ),
         ),
        const SizedBox(height: 12),
        Text(
          '選擇最適合你的 MBTI 性格測試模式',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                '科學驗證的心理學測試',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String mode,
    required String title,
    required String subtitle,
    required String duration,
    required String accuracy,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> features,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedMode == mode;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頂部區域
            Row(
              children: [
                // 圖標
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 標題和副標題
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                                                     Text(
                             title,
                             style: AppTextStyles.headline3.copyWith(
                               color: AppColors.textPrimary,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '推薦',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.body2.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 選擇指示器
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 描述
            Text(
              description,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 統計信息
            Row(
              children: [
                _buildStatItem('時間', duration, Icons.access_time),
                const SizedBox(width: 24),
                _buildStatItem('準確度', accuracy, Icons.analytics),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 特色功能
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feature,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return ModernButton(
      text: '開始測試',
      icon: Icons.arrow_forward,
      onPressed: _selectedMode != null ? _startTest : null,
      variant: ModernButtonVariant.gradient,
      size: ModernButtonSize.large,
      isFullWidth: true,
      customGradient: _selectedMode != null 
          ? AppColors.modernPinkGradient
          : const LinearGradient(
              colors: [
                AppColors.textDisabled,
                AppColors.textDisabled,
              ],
            ),
    );
  }

  void _startTest() {
    if (_selectedMode == null) return;
    
    // 導航到測試頁面，傳遞選擇的模式
    context.push('/mbti-test?mode=$_selectedMode');
  }
} 