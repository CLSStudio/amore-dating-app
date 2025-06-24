import 'package:flutter/material.dart';

/// Amore 應用設計系統
/// 統一的顏色、字體、間距、組件規範
class AppDesignSystem {
  // 私有構造函數，防止實例化
  AppDesignSystem._();

  /// 顏色系統
  static const AppColors colors = AppColors._();
  
  /// 字體系統
  static const AppTextStyles textStyles = AppTextStyles._();
  
  /// 間距系統
  static const AppSpacing spacing = AppSpacing._();
  
  /// 圓角系統
  static const AppBorderRadius borderRadius = AppBorderRadius._();
  
  /// 陰影系統
  static const AppShadows shadows = AppShadows._();
  
  /// 動畫系統
  static const AppAnimations animations = AppAnimations._();
}

/// 顏色系統
class AppColors {
  const AppColors._();
  
  // 主色調 - 浪漫粉紅
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFAD1457);
  static const Color primaryLight = Color(0xFFF8BBD9);
  
  // 輔助色調
  static const Color secondary = Color(0xFF673AB7);
  static const Color secondaryDark = Color(0xFF4527A0);
  static const Color secondaryLight = Color(0xFFD1C4E9);
  
  // 功能性顏色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 中性色調
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF424242);
  
  // 文字顏色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textTertiary = Color(0xFFBDBDBD);
  
  // 邊框和分隔線
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // 功能色彩
  static const Color like = Color(0xFF48BB78);
  static const Color superLike = Color(0xFF4299E1);
  static const Color nope = Color(0xFFF56565);
  static const Color boost = Color(0xFFED8936);
  
  // 透明度變體
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withOpacity(opacity);
  
  // 漸變色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );
}

/// 字體系統
class AppTextStyles {
  const AppTextStyles._();
  
  // 標題樣式
  static const TextStyle h1 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle h5 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle h6 = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // 正文樣式
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // 按鈕樣式
  static const TextStyle button = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  
  // 輔助樣式
  static const TextStyle caption = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: 'NotoSansHK',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
    height: 1.6,
  );
}

/// 間距系統
class AppSpacing {
  const AppSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // 頁面邊距
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageVerticalPadding = EdgeInsets.symmetric(vertical: md);
  
  // 卡片邊距
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);
  
  // 列表項邊距
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
}

/// 圓角系統
class AppBorderRadius {
  const AppBorderRadius._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double circular = 50.0;
  
  // 常用圓角
  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(xl));
  
  // 特殊圓角
  static const BorderRadius topOnly = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  
  static const BorderRadius bottomOnly = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
}

/// 陰影系統
class AppShadows {
  const AppShadows._();
  
  static final List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.blackWithOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.blackWithOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.blackWithOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.blackWithOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.primaryWithOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// 動畫系統
class AppAnimations {
  const AppAnimations._();
  
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
}

/// 統一的主題配置
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      
      // AppBar 主題
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimary,
        ),
      ),
      
      // 卡片主題
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        color: AppColors.surface,
        shadowColor: AppColors.blackWithOpacity(0.1),
      ),
      
      // 按鈕主題
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      
      // 輸入框主題
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.textTertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.textTertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: AppSpacing.cardPadding,
      ),
      
      // 字體主題
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineLarge: AppTextStyles.h4,
        headlineMedium: AppTextStyles.h5,
        headlineSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
        labelSmall: AppTextStyles.buttonSmall,
      ),
    );
  }
} 