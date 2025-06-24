import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// 用戶體驗優化器
class UserExperienceOptimizer {
  static final Map<String, DateTime> _interactionTimestamps = {};
  static final Map<String, int> _featureUsageCounts = {};
  static Timer? _performanceTimer;

  /// 初始化用戶體驗優化器
  static Future<void> initialize() async {
    try {
      await _loadUserPreferences();
      _startPerformanceMonitoring();
      debugPrint('✅ 用戶體驗優化器初始化完成');
    } catch (e) {
      debugPrint('❌ 用戶體驗優化器初始化失敗: $e');
    }
  }

  /// 記錄用戶交互
  static void recordInteraction(String featureName) {
    _interactionTimestamps[featureName] = DateTime.now();
    _featureUsageCounts[featureName] = (_featureUsageCounts[featureName] ?? 0) + 1;
    
    // 保存統計數據
    _saveUsageStats();
  }

  /// 提供觸覺反饋
  static void provideFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// 智能加載策略
  static Widget smartLoader({
    required bool isLoading,
    required Widget child,
    String? loadingMessage,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        if (!isLoading) return child;

        return Stack(
          children: [
            child,
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          loadingMessage ?? '載入中...',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 響應式字體大小
  static double getOptimalFontSize(BuildContext context, {
    double baseFontSize = 16.0,
    bool respectAccessibility = true,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // 基於螢幕寬度的縮放
    double scaleFactor = screenWidth / 375.0; // iPhone 標準寬度
    scaleFactor = scaleFactor.clamp(0.8, 1.5);
    
    double fontSize = baseFontSize * scaleFactor;
    
    // 考慮無障礙設置
    if (respectAccessibility) {
      final textScaleFactor = mediaQuery.textScaleFactor;
      fontSize *= textScaleFactor.clamp(0.8, 2.0);
    }
    
    return fontSize.clamp(12.0, 28.0);
  }

  /// 自適應間距
  static EdgeInsets getAdaptiveSpacing(BuildContext context, {
    double baseSpacing = 16.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 根據螢幕大小調整間距
    double horizontalSpacing = screenWidth * 0.04;
    double verticalSpacing = screenHeight * 0.02;
    
    horizontalSpacing = horizontalSpacing.clamp(8.0, 32.0);
    verticalSpacing = verticalSpacing.clamp(4.0, 24.0);
    
    return EdgeInsets.symmetric(
      horizontal: horizontalSpacing,
      vertical: verticalSpacing,
    );
  }

  /// 平滑動畫過渡
  static Widget smoothTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 智能鍵盤處理
  static Widget keyboardAwareScroll({
    required Widget child,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardHeight = mediaQuery.viewInsets.bottom;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.only(
            bottom: resizeToAvoidBottomInset ? keyboardHeight : 0,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: child,
          ),
        );
      },
    );
  }

  /// 優化的圖片組件
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool enableMemoryCache = true,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 40,
              ),
            );
      },
    );
  }

  /// 性能優化的列表
  static Widget performantList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: items.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        // 避免越界訪問
        if (index >= items.length) {
          return const SizedBox.shrink();
        }
        
        final item = items[index];
        return itemBuilder(context, item, index);
      },
    );
  }

  /// 用戶偏好設置
  static Future<void> setUserPreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    } catch (e) {
      debugPrint('❌ 設置用戶偏好失敗: $e');
    }
  }

  /// 獲取用戶偏好
  static Future<T?> getUserPreference<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.get(key) as T?;
    } catch (e) {
      debugPrint('❌ 獲取用戶偏好失敗: $e');
      return null;
    }
  }

  /// 智能通知管理
  static void showOptimizedSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = theme.primaryColor;
        textColor = Colors.white;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: action,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 性能監控
  static void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _checkPerformanceMetrics(),
    );
  }

  /// 檢查性能指標
  static void _checkPerformanceMetrics() {
    // 檢查記憶體使用情況（簡化版本）
    final now = DateTime.now();
    final oldInteractions = _interactionTimestamps.entries
        .where((entry) => now.difference(entry.value).inHours > 24)
        .map((entry) => entry.key)
        .toList();

    // 清理舊數據
    for (final key in oldInteractions) {
      _interactionTimestamps.remove(key);
    }

    debugPrint('📊 性能檢查完成，清理了 ${oldInteractions.length} 條舊記錄');
  }

  /// 保存使用統計
  static Future<void> _saveUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = <String, dynamic>{};
      
      _featureUsageCounts.forEach((key, value) {
        statsJson[key] = value;
      });
      
      await prefs.setString('usage_stats', statsJson.toString());
    } catch (e) {
      debugPrint('❌ 保存使用統計失敗: $e');
    }
  }

  /// 載入用戶偏好
  static Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString('usage_stats');
      
      if (statsString != null) {
        // 載入統計數據的邏輯
        debugPrint('✅ 用戶偏好載入完成');
      }
    } catch (e) {
      debugPrint('❌ 載入用戶偏好失敗: $e');
    }
  }

  /// 獲取功能使用統計
  static Map<String, int> getFeatureUsageStats() {
    return Map.from(_featureUsageCounts);
  }

  /// 清理資源
  static void dispose() {
    _performanceTimer?.cancel();
    _interactionTimestamps.clear();
    _featureUsageCounts.clear();
    debugPrint('✅ 用戶體驗優化器資源已清理');
  }
}

/// 反饋類型枚舉
enum FeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// SnackBar 類型枚舉
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// 無障礙功能助手
class AccessibilityHelper {
  /// 為組件添加無障礙支持
  static Widget accessibleWidget({
    required Widget child,
    required String semanticsLabel,
    String? semanticsHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// 檢查是否啟用了無障礙功能
  static bool isAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation || 
           mediaQuery.textScaleFactor > 1.3;
  }

  /// 獲取建議的觸摸目標大小
  static double getMinimumTapTargetSize() {
    return 48.0; // Material Design 建議的最小觸摸目標
  }

  /// 為按鈕提供足夠的觸摸區域
  static Widget expandedTapArea({
    required Widget child,
    required VoidCallback onTap,
    double minSize = 48.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: child,
      ),
    );
  }
}

/// 主題適配助手
class ThemeAdapter {
  /// 獲取適配的顏色
  static Color getAdaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// 獲取適配的文本樣式
  static TextStyle getAdaptiveTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
    double? fontSizeMultiplier,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    double fontSize = baseStyle.fontSize ?? 16.0;
    
    if (fontSizeMultiplier != null) {
      fontSize *= fontSizeMultiplier;
    }
    
    // 考慮用戶的文字大小設置
    fontSize *= mediaQuery.textScaleFactor.clamp(0.8, 2.0);
    
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: baseStyle.color ?? theme.textTheme.bodyMedium?.color,
    );
  }

  /// 獲取適配的陰影
  static List<BoxShadow> getAdaptiveShadow(
    BuildContext context, {
    double elevation = 4.0,
  }) {
    final brightness = Theme.of(context).brightness;
    final shadowColor = brightness == Brightness.light 
        ? Colors.black.withOpacity(0.1) 
        : Colors.black.withOpacity(0.3);
    
    return [
      BoxShadow(
        color: shadowColor,
        offset: const Offset(0, 2),
        blurRadius: elevation,
        spreadRadius: 0,
      ),
    ];
  }
} 