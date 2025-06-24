import 'package:flutter/material.dart';

/// 應用程式顏色配置
class AppColors {
  // 主要品牌顏色
  static const Color primary = Color(0xFFE91E63); // 粉紅色，代表愛情
  static const Color primaryLight = Color(0xFFF8BBD9);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // 次要顏色
  static const Color secondary = Color(0xFF9C27B0); // 紫色，代表神秘和浪漫
  static const Color secondaryLight = Color(0xFFE1BEE7);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // 背景顏色（亮色主題）
  static const Color background = Color(0xFFFFFBFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // 背景顏色（暗色主題）
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  
  // 文字顏色
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);
  static const Color textDisabled = Color(0xFFCAC4D0);
  
  // 暗色主題文字顏色
  static const Color darkTextPrimary = Color(0xFFE6E1E5);
  static const Color darkTextSecondary = Color(0xFFCAC4D0);
  static const Color darkTextTertiary = Color(0xFF938F99);
  static const Color darkTextDisabled = Color(0xFF49454F);
  
  // 狀態顏色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // 邊框和分隔線
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkDivider = Color(0xFF3A3A3A);
  
  // 輸入框背景
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color darkInputBackground = Color(0xFF2A2A2A);
  
  // 陰影
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color darkShadow = Color(0x3A000000);
  
  // 特殊功能顏色
  static const Color like = Color(0xFF4CAF50); // 喜歡按鈕
  static const Color pass = Color(0xFFFF5722); // 跳過按鈕
  static const Color superLike = Color(0xFF2196F3); // 超級喜歡
  static const Color boost = Color(0xFF9C27B0); // 加速功能
  
  // Gen Z 現代化色彩
  static const Color neonPink = Color(0xFFFF1493);
  static const Color vibrantRed = Color(0xFFFF2D55);
  static const Color softPeach = Color(0xFFFFB3BA);
  static const Color modernGray = Color(0xFF8E8E93);
  static const Color electricBlue = Color(0xFF007AFF);
  static const Color mintGreen = Color(0xFF30D158);
  
  // 現代化漸變色組合
  static const LinearGradient modernPinkGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFE91E63), Color(0xFFAD1457)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF9A8B), Color(0xFFA890FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 在線狀態
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFF9800);
  
  // 聊天氣泡
  static const Color myMessageBubble = Color(0xFFE91E63);
  static const Color otherMessageBubble = Color(0xFFF5F5F5);
  static const Color darkMyMessageBubble = Color(0xFFE91E63);
  static const Color darkOtherMessageBubble = Color(0xFF2A2A2A);
  
  // 漸變色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 透明度變體
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
  static Color errorWithOpacity(double opacity) => error.withOpacity(opacity);
  static Color successWithOpacity(double opacity) => success.withOpacity(opacity);
  
  // 防止實例化
  AppColors._();
} 