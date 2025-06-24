import 'package:flutter/material.dart';
import '../../features/dating/modes/dating_mode_system.dart';

/// 🎨 Amore 交友模式主題管理器
/// 為三大核心模式提供差異化的視覺體驗
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  /// 🎯 認真交往模式主題
  static const seriousTheme = {
    'primary': Color(0xFF1565C0),      // 深藍色 - 穩重可靠
    'secondary': Color(0xFF0277BD),    // 中藍色
    'accent': Color(0xFF81C784),       // 溫和綠色
    'background': Color(0xFFF8F9FA),   // 純淨白色
    'surface': Color(0xFFFFFFFF),      // 白色
    'error': Color(0xFFE57373),        // 溫和紅色
    'onPrimary': Color(0xFFFFFFFF),    // 白色文字
    'onSecondary': Color(0xFFFFFFFF),  // 白色文字
    'onBackground': Color(0xFF212121), // 深灰文字
    'onSurface': Color(0xFF424242),    // 灰色文字
    'keywords': ['真誠', '穩定', '承諾', '未來', '深度']
  };

  /// 🌟 探索模式主題
  static const exploreTheme = {
    'primary': Color(0xFFFF7043),      // 活潑橘色
    'secondary': Color(0xFFFFB74D),    // 暖橘色
    'accent': Color(0xFF7986CB),       // 輕快紫色
    'background': Color(0xFFFFF8E1),   // 溫暖奶色
    'surface': Color(0xFFFFFFFF),      // 白色
    'error': Color(0xFFFF5722),        // 橘紅色
    'onPrimary': Color(0xFFFFFFFF),    // 白色文字
    'onSecondary': Color(0xFF424242),  // 深灰文字
    'onBackground': Color(0xFF3E2723), // 棕色文字
    'onSurface': Color(0xFF5D4037),    // 棕灰文字
    'keywords': ['有趣', '輕鬆', '活動', '探索', '朋友']
  };

  /// 🔥 激情模式主題
  static const passionTheme = {
    'primary': Color(0xFFE91E63),      // 激情粉紅
    'secondary': Color(0xFFAD1457),    // 深粉紅
    'accent': Color(0xFFFF4081),       // 亮粉紅
    'background': Color(0xFF1A1A1A),   // 深色背景
    'surface': Color(0xFF2D2D2D),      // 深灰表面
    'error': Color(0xFFFF1744),        // 紅色
    'onPrimary': Color(0xFFFFFFFF),    // 白色文字
    'onSecondary': Color(0xFFFFFFFF),  // 白色文字
    'onBackground': Color(0xFFFFFFFF), // 白色文字
    'onSurface': Color(0xFFE0E0E0),    // 淺灰文字
    'keywords': ['激情', '即時', '直接', '魅力', '連結']
  };

  /// 🎨 獲取模式主題
  ThemeData getThemeForMode(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return _createSeriousTheme();
      case DatingMode.explore:
        return _createExploreTheme();
      case DatingMode.passion:
        return _createPassionTheme();
    }
  }

  /// 🎯 創建認真交往主題
  ThemeData _createSeriousTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        primary: const Color(0xFF1565C0),
        secondary: const Color(0xFF0277BD),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 🌟 創建探索模式主題
  ThemeData _createExploreTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        primary: Colors.orange,
        secondary: Colors.amber,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 🔥 創建激情模式主題
  ThemeData _createPassionTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E63),
        brightness: Brightness.dark,
        primary: const Color(0xFFE91E63),
        secondary: const Color(0xFFAD1457),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 🎨 獲取模式專屬顏色
  Map<String, Color> getColorsForMode(DatingMode mode) {
    Map<String, dynamic> theme;
    switch (mode) {
      case DatingMode.serious:
        theme = seriousTheme;
        break;
      case DatingMode.explore:
        theme = exploreTheme;
        break;
      case DatingMode.passion:
        theme = passionTheme;
        break;
    }
    
    // 過濾出只有 Color 類型的項目
    final Map<String, Color> colors = {};
    theme.forEach((key, value) {
      if (value is Color) {
        colors[key] = value;
      }
    });
    
    return colors;
  }

  /// 🏷️ 獲取模式關鍵詞
  List<String> getKeywordsForMode(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return seriousTheme['keywords'] as List<String>;
      case DatingMode.explore:
        return exploreTheme['keywords'] as List<String>;
      case DatingMode.passion:
        return passionTheme['keywords'] as List<String>;
    }
  }

  /// 🎯 獲取模式圖標
  IconData getIconForMode(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return Icons.favorite; // 心形 - 代表真愛
      case DatingMode.explore:
        return Icons.explore; // 探索圖標
      case DatingMode.passion:
        return Icons.whatshot; // 火焰圖標
    }
  }

  /// 🌈 創建漸變背景
  LinearGradient getGradientForMode(DatingMode mode) {
    final colors = getColorsForMode(mode);
    
    switch (mode) {
      case DatingMode.serious:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['primary']!,
            colors['secondary']!,
          ],
        );
      case DatingMode.explore:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors['primary']!,
            colors['secondary']!,
            colors['accent']!,
          ],
        );
      case DatingMode.passion:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['background']!,
            colors['surface']!,
            colors['primary']!,
          ],
        );
    }
  }
} 