import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MBTIProgressIndicator extends StatelessWidget {
  final Animation<double> animation;
  final int currentQuestion;
  final int totalQuestions;

  const MBTIProgressIndicator({
    super.key,
    required this.animation,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 進度文字
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進度',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(animation.value * 100).round()}%',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 進度條
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // 背景進度條
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  // 活動進度條
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 進度點
                  Positioned(
                    left: (MediaQuery.of(context).size.width - 40) * animation.value - 6,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // 問題計數器
        Row(
          children: List.generate(totalQuestions, (index) {
            final isCompleted = index < currentQuestion - 1;
            final isCurrent = index == currentQuestion - 1;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < totalQuestions - 1 ? 4 : 0,
                ),
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent 
                      ? AppColors.primary 
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
} 