import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'mbti_data_models.dart';

class MBTIProfileIntegration {
  static Future<void> saveToProfile({
    required String mbtiType,
    required MBTIResult resultData,
  }) async {
    // 這裡將來會整合到Firebase或其他後端服務
    await Future.delayed(const Duration(seconds: 1)); // 模擬保存過程
    
    // 實際實現時會保存到用戶個人檔案
    print('MBTI結果已保存: $mbtiType');
  }
}

class MBTIProfileIntegrationPage extends ConsumerWidget {
  final MBTIResult mbtiResult;
  
  const MBTIProfileIntegrationPage({
    super.key,
    required this.mbtiResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('整合到個人檔案'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'MBTI結果已保存！',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '您的${mbtiResult.type}性格類型已整合到個人檔案中',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: '查看個人檔案',
              onPressed: () => Navigator.pop(context),
              type: AppButtonType.primary,
              icon: Icons.person,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
} 