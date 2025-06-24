import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'mbti_data_models.dart';

class MBTICompatibilityAnalysisPage extends ConsumerWidget {
  final String userMBTI;
  final MBTIResult resultData;
  
  const MBTICompatibilityAnalysisPage({
    super.key,
    required this.userMBTI,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compatibilityData = _getCompatibilityData();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('兼容性分析'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildUserTypeCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildCompatibilityMatrix(compatibilityData),
            const SizedBox(height: AppSpacing.xl),
            _buildMatchingTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard() {
    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [resultData.primaryColor, resultData.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Column(
              children: [
                Text(
                  userMBTI,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  resultData.title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '您的兼容性分析',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityMatrix(List<CompatibilityInfo> compatibilityData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '與其他類型的兼容性',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...compatibilityData.map((compatibility) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildCompatibilityCard(compatibility),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCompatibilityCard(CompatibilityInfo compatibility) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: compatibility.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Text(
                  compatibility.mbtiType,
                  style: AppTextStyles.h6.copyWith(
                    color: compatibility.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compatibility.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      compatibility.level,
                      style: AppTextStyles.caption.copyWith(
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
                  color: compatibility.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  '${compatibility.score}%',
                  style: AppTextStyles.caption.copyWith(
                    color: compatibility.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: compatibility.score / 100,
            backgroundColor: AppColors.textTertiary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(compatibility.color),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            compatibility.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingTips() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '約會建議',
                style: AppTextStyles.h6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...resultData.relationshipTips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTextStyles.bodySmall,
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

  List<CompatibilityInfo> _getCompatibilityData() {
    // 這是模擬數據，實際應用中會根據MBTI理論計算
    switch (userMBTI) {
      case 'INTJ':
        return [
          CompatibilityInfo(
            mbtiType: 'ENFP',
            title: '競選者',
            level: '完美匹配',
            score: 95,
            color: Colors.green,
            description: '你們互補的特質創造了完美的平衡，ENFP的熱情與INTJ的深度形成絕佳組合。',
          ),
          CompatibilityInfo(
            mbtiType: 'ENTP',
            title: '辯論家',
            level: '很好匹配',
            score: 88,
            color: Colors.blue,
            description: '智力上的刺激和深度對話讓你們彼此著迷，都欣賞對方的創新思維。',
          ),
          CompatibilityInfo(
            mbtiType: 'INFJ',
            title: '提倡者',
            level: '不錯匹配',
            score: 75,
            color: Colors.orange,
            description: '共同的內向特質和理想主義讓你們容易理解彼此的深層需求。',
          ),
        ];
      case 'ENFP':
        return [
          CompatibilityInfo(
            mbtiType: 'INTJ',
            title: '建築師',
            level: '完美匹配',
            score: 95,
            color: Colors.green,
            description: '你的熱情激發了INTJ的創造力，而他們的深度讓你感到安全和被理解。',
          ),
          CompatibilityInfo(
            mbtiType: 'INFJ',
            title: '提倡者',
            level: '很好匹配',
            score: 90,
            color: Colors.blue,
            description: '共同的直覺偏好和對人的關注創造了深度的情感連結。',
          ),
          CompatibilityInfo(
            mbtiType: 'ENFJ',
            title: '主人公',
            level: '不錯匹配',
            score: 78,
            color: Colors.orange,
            description: '都是熱情的外向者，喜歡幫助他人，但需要注意避免過度刺激。',
          ),
        ];
      default:
        return [
          CompatibilityInfo(
            mbtiType: 'ENFP',
            title: '競選者',
            level: '建議匹配',
            score: 80,
            color: Colors.blue,
            description: '開放、熱情的性格能為您帶來新的視角和活力。',
          ),
          CompatibilityInfo(
            mbtiType: 'INFJ',
            title: '提倡者',
            level: '建議匹配',
            score: 75,
            color: Colors.green,
            description: '深度和同理心的結合能創造穩定而有意義的關係。',
          ),
        ];
    }
  }
}

class CompatibilityInfo {
  final String mbtiType;
  final String title;
  final String level;
  final int score;
  final Color color;
  final String description;

  CompatibilityInfo({
    required this.mbtiType,
    required this.title,
    required this.level,
    required this.score,
    required this.color,
    required this.description,
  });
} 