import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 應用程式文字樣式配置
class AppTextStyles {
  // 基礎字體
  static const String fontFamily = 'NotoSansTC';
  
  // 標題樣式
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  // 為了兼容性保留舊名稱
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle headline5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );
  
  static const TextStyle headline6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );
  
  // 副標題樣式
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  // 正文樣式
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  // 按鈕樣式
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // 標籤樣式
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // 特殊樣式
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
  );
  
  static const TextStyle logo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  // 聊天相關樣式
  static const TextStyle chatMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static const TextStyle chatTime = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  // 表單樣式
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  // 亮色主題文字主題
  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: display.copyWith(color: AppColors.textPrimary),
      displayMedium: headline1.copyWith(color: AppColors.textPrimary),
      displaySmall: headline2.copyWith(color: AppColors.textPrimary),
      headlineLarge: headline3.copyWith(color: AppColors.textPrimary),
      headlineMedium: headline4.copyWith(color: AppColors.textPrimary),
      headlineSmall: headline5.copyWith(color: AppColors.textPrimary),
      titleLarge: headline6.copyWith(color: AppColors.textPrimary),
      titleMedium: subtitle1.copyWith(color: AppColors.textPrimary),
      titleSmall: subtitle2.copyWith(color: AppColors.textSecondary),
      bodyLarge: body1.copyWith(color: AppColors.textPrimary),
      bodyMedium: body2.copyWith(color: AppColors.textSecondary),
      bodySmall: caption.copyWith(color: AppColors.textTertiary),
      labelLarge: button.copyWith(color: AppColors.onPrimary),
      labelMedium: inputLabel.copyWith(color: AppColors.textSecondary),
      labelSmall: overline.copyWith(color: AppColors.textTertiary),
    );
  }
  
  // 暗色主題文字主題
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: display.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: headline1.copyWith(color: AppColors.darkTextPrimary),
      displaySmall: headline2.copyWith(color: AppColors.darkTextPrimary),
      headlineLarge: headline3.copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: headline4.copyWith(color: AppColors.darkTextPrimary),
      headlineSmall: headline5.copyWith(color: AppColors.darkTextPrimary),
      titleLarge: headline6.copyWith(color: AppColors.darkTextPrimary),
      titleMedium: subtitle1.copyWith(color: AppColors.darkTextPrimary),
      titleSmall: subtitle2.copyWith(color: AppColors.darkTextSecondary),
      bodyLarge: body1.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: body2.copyWith(color: AppColors.darkTextSecondary),
      bodySmall: caption.copyWith(color: AppColors.darkTextTertiary),
      labelLarge: button.copyWith(color: AppColors.onPrimary),
      labelMedium: inputLabel.copyWith(color: AppColors.darkTextSecondary),
      labelSmall: overline.copyWith(color: AppColors.darkTextTertiary),
    );
  }
  
  // 防止實例化
  AppTextStyles._();
} 