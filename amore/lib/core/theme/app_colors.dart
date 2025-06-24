import 'package:flutter/material.dart';

class AppColors {
  // 主色調 - 紅色系
  static const Color primary = Color(0xFFE91E63); // 活力粉紅紅
  static const Color primaryDark = Color(0xFFC2185B); // 深粉紅紅
  static const Color primaryLight = Color(0xFFF8BBD9); // 淺粉紅
  
  // 漸變色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B9D), // 亮粉紅
      Color(0xFFE91E63), // 主紅色
      Color(0xFFAD1457), // 深紅色
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF0F5), // 極淺粉
      Color(0xFFFCE4EC), // 淺粉背景
    ],
  );
  
  // 輔助色
  static const Color secondary = Color(0xFF9C27B0); // 紫色
  static const Color accent = Color(0xFFFF4081); // 亮粉紅
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 背景色
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // 文字色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // 邊框和分割線
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // 陰影色
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // 特殊效果色
  static const Color shimmer = Color(0xFFF0F0F0);
  static const Color overlay = Color(0x80000000);
  
  // 狀態色
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFF9800);
  
  // 匹配相關色彩
  static const Color like = Color(0xFF4CAF50);
  static const Color pass = Color(0xFF757575);
  static const Color superLike = Color(0xFF2196F3);
  
  // Gen Z 特色色彩
  static const Color neonPink = Color(0xFFFF1493);
  static const Color vibrantRed = Color(0xFFFF2D55);
  static const Color softPeach = Color(0xFFFFB3BA);
  static const Color modernGray = Color(0xFF8E8E93);
  
  // 卡片和按鈕漸變
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B9D),
      Color(0xFFE91E63),
    ],
  );
  
  static const LinearGradient likeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4CAF50),
      Color(0xFF8BC34A),
    ],
  );
  
  static const LinearGradient passGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF757575),
      Color(0xFF9E9E9E),
    ],
  );
  
  // 深色模式支援
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
} 