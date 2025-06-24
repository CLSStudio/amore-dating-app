import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 字體家族
  static const String primaryFont = 'SF Pro Display';
  static const String secondaryFont = 'SF Pro Text';
  
  // 標題樣式
  static const TextStyle heading1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  // 正文樣式
  static const TextStyle body1 = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle body3 = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
    color: AppColors.textSecondary,
  );
  
  // 按鈕樣式
  static const TextStyle button = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );
  
  // 標籤和提示樣式
  static const TextStyle label = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
    color: AppColors.textHint,
  );
  
  // 特殊樣式
  static const TextStyle display = TextStyle(
    fontFamily: primaryFont,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.primary,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  
  // 輸入框樣式
  static const TextStyle input = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle inputLabel = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textHint,
  );
  
  // 聊天相關樣式
  static const TextStyle chatMessage = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle chatTime = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textHint,
  );
  
  // 匹配卡片樣式
  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle cardInfo = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.textOnPrimary,
  );
  
  // MBTI 相關樣式
  static const TextStyle mbtiType = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.0,
    height: 1.2,
    color: AppColors.primary,
  );
  
  static const TextStyle mbtiTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  // 錯誤和成功樣式
  static const TextStyle error = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.error,
  );
  
  static const TextStyle success = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.success,
  );
  
  // 導航樣式
  static const TextStyle navLabel = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle navLabelActive = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.primary,
  );
} 