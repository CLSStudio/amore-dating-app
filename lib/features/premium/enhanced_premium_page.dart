import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// Premium 計劃模型
class PremiumPlan {
  final String id;
  final String name;
  final String price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final String? discount;

  PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.discount,
  });
}

// Premium 功能模型
class PremiumFeature {
  final String title;
  final String description;
  final IconData icon;
  final bool isAvailable;

  PremiumFeature({
    required this.title,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });
}

// 模擬 Premium 計劃
final premiumPlans = [
  PremiumPlan(
    id: 'monthly',
    name: '月度會員',
    price: 'HK\$88',
    duration: '每月',
    features: [
      '無限喜歡',
      '5個超級喜歡/天',
      '1個 Boost/月',
      '查看誰喜歡你',
      '高級篩選',
    ],
  ),
  PremiumPlan(
    id: 'quarterly',
    name: '季度會員',
    price: 'HK\$198',
    duration: '每3個月',
    features: [
      '無限喜歡',
      '5個超級喜歡/天',
      '3個 Boost/月',
      '查看誰喜歡你',
      '高級篩選',
      '優先客服支持',
    ],
    isPopular: true,
    discount: '節省25%',
  ),
  PremiumPlan(
    id: 'yearly',
    name: '年度會員',
    price: 'HK\$588',
    duration: '每年',
    features: [
      '無限喜歡',
      '10個超級喜歡/天',
      '12個 Boost/年',
      '查看誰喜歡你',
      '高級篩選',
      '優先客服支持',
      'AI 愛情顧問',
      '專屬徽章',
    ],
    discount: '節省45%',
  ),
];

// Premium 功能列表
final premiumFeatures = [
  PremiumFeature(
    title: '無限喜歡',
    description: '不再受每日喜歡次數限制',
    icon: Icons.favorite,
  ),
  PremiumFeature(
    title: '超級喜歡',
    description: '讓對方優先看到你的個人檔案',
    icon: Icons.star,
  ),
  PremiumFeature(
    title: 'Boost',
    description: '30分鐘內成為該地區最熱門用戶',
    icon: Icons.flash_on,
  ),
  PremiumFeature(
    title: '查看誰喜歡你',
    description: '直接查看喜歡你的用戶列表',
    icon: Icons.visibility,
  ),
  PremiumFeature(
    title: '高級篩選',
    description: '按年齡、距離、興趣等條件篩選',
    icon: Icons.filter_list,
  ),
  PremiumFeature(
    title: 'AI 愛情顧問',
    description: '專業的關係建議和指導',
    icon: Icons.psychology,
  ),
];

class EnhancedPremiumPage extends ConsumerWidget {
  const EnhancedPremiumPage({super.key});

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
                  _buildBenefitsSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPlansSection(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFeaturesSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTestimonialsSection(),
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
            AppColors.warning,
            AppColors.primary,
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
                    Icons.diamond,
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
                        'Amore Premium',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        '解鎖所有高級功能',
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
                    '提升3倍配對成功率',
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

  Widget _buildBenefitsSection() {
    return AppCard(
      backgroundColor: AppColors.warning.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.warning,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '為什麼選擇 Premium？',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      '數據顯示 Premium 用戶的配對成功率提升3倍',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildBenefitItem(
                  '3x',
                  '配對成功率',
                  Icons.favorite,
                ),
              ),
              Expanded(
                child: _buildBenefitItem(
                  '5x',
                  '個人檔案瀏覽量',
                  Icons.visibility,
                ),
              ),
              Expanded(
                child: _buildBenefitItem(
                  '10x',
                  '超級喜歡效果',
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String number, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.warning,
          size: 24,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          number,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlansSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💎 選擇你的計劃',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        ...premiumPlans.map((plan) => _buildPlanCard(context, plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, PremiumPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        backgroundColor: plan.isPopular 
            ? AppColors.warning.withOpacity(0.05)
            : null,
        onTap: () => _selectPlan(context, plan),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.h6,
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: AppSpacing.sm),
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
                                '最受歡迎',
                                style: AppTextStyles.overline.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan.duration,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.discount != null)
                      Text(
                        plan.discount!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 功能列表
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: AppSpacing.md),
            
            AppButton(
              text: '選擇此計劃',
              onPressed: () => _selectPlan(context, plan),
              isFullWidth: true,
              type: plan.isPopular 
                  ? AppButtonType.primary 
                  : AppButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨ Premium 功能',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
          ),
          itemCount: premiumFeatures.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(premiumFeatures[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.warning,
              size: 24,
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
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💬 用戶評價',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTestimonialCard(
          '小雅',
          '👩‍🦰',
          'Premium 真的很值得！我在一週內就找到了理想的配對對象。',
          5,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTestimonialCard(
          '志明',
          '👨‍💻',
          'AI 愛情顧問給了我很多有用的建議，幫助我改善了溝通技巧。',
          5,
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(String name, String avatar, String review, int rating) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h6,
                    ),
                    Row(
                      children: List.generate(rating, (index) => Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            review,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, PremiumPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              '確認購買',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            AppCard(
              backgroundColor: AppColors.warning.withOpacity(0.05),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.diamond,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: AppTextStyles.h6,
                            ),
                            Text(
                              plan.duration,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        plan.price,
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (plan.discount != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            plan.discount!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '取消',
                    onPressed: () => Navigator.pop(context),
                    type: AppButtonType.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: '確認購買',
                    onPressed: () {
                      Navigator.pop(context);
                      _processPurchase(context, plan);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPurchase(BuildContext context, PremiumPlan plan) {
    // 模擬購買流程
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '正在處理購買...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );

    // 模擬處理時間
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // 關閉載入對話框
      _showPurchaseSuccess(context, plan);
    });
  }

  void _showPurchaseSuccess(BuildContext context, PremiumPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '購買成功！',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '歡迎成為 Amore Premium 會員！\n所有高級功能已為你解鎖。',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          AppButton(
            text: '開始體驗',
            onPressed: () => Navigator.pop(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
} 