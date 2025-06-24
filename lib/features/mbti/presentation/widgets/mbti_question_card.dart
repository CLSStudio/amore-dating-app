import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/mbti_question.dart';

/// MBTI 問題卡片
class MbtiQuestionCard extends StatelessWidget {
  final MbtiQuestion question;
  final String? selectedOptionId;
  final Function(String) onOptionSelected;

  const MbtiQuestionCard({
    super.key,
    required this.question,
    this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 問題編號
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '第 ${question.order} 題',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 問題文字
            Text(
              question.question,
              style: AppTextStyles.headline5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 選項列表
            ...question.options.map((option) => _buildOption(option)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(MbtiOption option) {
    final isSelected = selectedOptionId == option.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onOptionSelected(option.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 選項圓圈
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primary
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // 選項文字
              Expanded(
                child: Text(
                  option.text,
                  style: AppTextStyles.body1.copyWith(
                    color: isSelected 
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 