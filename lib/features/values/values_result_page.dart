import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'domain/entities/values_assessment.dart';
import 'data/datasources/values_questions_data.dart';

class ValuesResultPage extends ConsumerStatefulWidget {
  final ValuesAssessment assessment;
  final Map<String, dynamic> lifeStageAnswers;

  const ValuesResultPage({
    super.key,
    required this.assessment,
    required this.lifeStageAnswers,
  });

  @override
  ConsumerState<ValuesResultPage> createState() => _ValuesResultPageState();
}

class _ValuesResultPageState extends ConsumerState<ValuesResultPage>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildResultSummary(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildValuesChart(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildTopValues(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLifeStageInsights(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCompatibilityInsights(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildActionButtons(),
                  ],
                ),
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
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
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
                      const Icon(Icons.check_circle, color: Colors.white, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '測評完成',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '🎯 您的價值觀分析結果',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '基於您的回答，我們分析了您的核心價值觀和人生階段',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary() {
    final topValues = widget.assessment.topValues;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '您的核心價值觀',
                      style: AppTextStyles.h4,
                    ),
                    Text(
                      '最重要的前三項價值觀',
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
          
          ...topValues.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final score = widget.assessment.scores[value] ?? 0;
            
            return Container(
              margin: EdgeInsets.only(bottom: index < 2 ? AppSpacing.md : 0),
              child: _buildValueItem(value, score, index + 1),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildValueItem(ValueCategory category, int score, int rank) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
    ];
    final color = colors[(rank - 1) % colors.length];
    
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName,
                  style: AppTextStyles.h6.copyWith(
                    color: color,
                  ),
                ),
                Text(
                  category.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '$score%',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesChart() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 價值觀分佈圖',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '您在各個價值觀維度的得分分佈',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Column(
                children: widget.assessment.scores.entries.map((entry) {
                  return _buildChartBar(entry.key, entry.value);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(ValueCategory category, int score) {
    final progress = (score / 100.0) * _chartAnimation.value;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
    ];
    final color = colors[category.index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$score%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopValues() {
    final suggestions = ValuesQuestionsData.getValuesSuggestions(widget.assessment);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 個性化建議',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '基於您的價值觀，為您提供約會和配對建議',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          ...suggestions.take(5).map((suggestion) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLifeStageInsights() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 人生階段分析',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '基於您的人生階段回答的深度洞察',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          ...widget.lifeStageAnswers.entries.map((entry) {
            return _buildLifeStageItem(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLifeStageItem(String key, dynamic value) {
    String title = '';
    String content = '';
    
    switch (key) {
      case 'current_life_stage':
        title = '目前人生階段';
        content = value.toString();
        break;
      case 'relationship_goals':
        title = '感情關係期望';
        if (value is List<String>) {
          content = value.join('、');
        } else {
          content = value.toString();
        }
        break;
      case 'family_planning':
        title = '家庭規劃';
        content = value.toString();
        break;
      case 'career_priorities':
        title = '事業重點';
        if (value is List<String>) {
          content = value.join('、');
        } else {
          content = value.toString();
        }
        break;
      case 'life_goals':
        title = '人生目標排序';
        if (value is List<String>) {
          content = value.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
        } else {
          content = value.toString();
        }
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityInsights() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💕 配對洞察',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '我們會根據這些結果為您尋找價值觀相容的伴侶',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '提升配對成功率',
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '基於您的價值觀和人生階段，我們的AI將為您推薦最相容的伴侶，提升長期關係的成功率。',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        AppButton(
          text: '開始尋找配對',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          type: AppButtonType.primary,
          icon: Icons.favorite,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          text: '查看配對建議',
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to matching suggestions
          },
          type: AppButtonType.outline,
          icon: Icons.insights,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          text: '分享結果',
          onPressed: () {
            HapticFeedback.lightImpact();
            _shareResults();
          },
          type: AppButtonType.outline,
          icon: Icons.share,
          isFullWidth: true,
        ),
      ],
    );
  }

  void _shareResults() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('分享功能即將推出'),
        backgroundColor: AppColors.info,
      ),
    );
  }
} 