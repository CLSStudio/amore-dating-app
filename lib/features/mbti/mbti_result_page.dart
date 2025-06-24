import 'package:flutter/material.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

class MBTIResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const MBTIResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MBTI 測試結果'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '您的性格類型',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    result['type'] ?? 'ENFP',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    result['description'] ?? '外向、直覺、情感、感知型',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: '返回',
              onPressed: () => Navigator.pop(context),
              type: AppButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
} 