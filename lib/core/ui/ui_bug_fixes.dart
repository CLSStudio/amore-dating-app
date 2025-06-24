import 'package:flutter/material.dart';

/// UI Bug 修復和優化工具類
class UIBugFixes {
  /// 修復 RenderFlex 溢出問題的 SafeColumn
  static Widget safeColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    List<Widget> children = const <Widget>[],
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }

  /// 修復 RenderFlex 溢出問題的 SafeRow
  static Widget safeRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    List<Widget> children = const <Widget>[],
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }

  /// 安全的響應式容器，避免溢出
  static Widget responsiveContainer({
    Key? key,
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BoxDecoration? decoration,
    AlignmentGeometry? alignment,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 確保尺寸不超過可用空間
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        
        final safeWidth = width?.clamp(0.0, maxWidth);
        final safeHeight = height?.clamp(0.0, maxHeight);

        return Container(
          key: key,
          width: safeWidth,
          height: safeHeight,
          padding: padding,
          margin: margin,
          decoration: decoration,
          alignment: alignment,
          child: child,
        );
      },
    );
  }

  /// 安全的文本，避免溢出
  static Widget safeText(
    String text, {
    Key? key,
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
    double? fontSize,
  }) {
    return Text(
      text,
      key: key,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: true,
    );
  }

  /// 修復 Hero 標籤衝突的唯一 Hero
  static Widget uniqueHero({
    required Widget child,
    String? tag,
    Key? key,
  }) {
    // 生成唯一標籤
    final uniqueTag = tag ?? 'hero_${DateTime.now().millisecondsSinceEpoch}_${child.hashCode}';
    
    return Hero(
      key: key,
      tag: uniqueTag,
      child: child,
    );
  }

  /// 安全的 Flex 佈局
  static Widget safeFlex({
    required List<Widget> children,
    Axis direction = Axis.vertical,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool preventOverflow = true,
  }) {
    Widget flex = Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    if (preventOverflow) {
      return SingleChildScrollView(
        scrollDirection: direction,
        child: flex,
      );
    }

    return flex;
  }

  /// 安全的 Padding，避免負值
  static EdgeInsets safePadding({
    double top = 0.0,
    double bottom = 0.0,
    double left = 0.0,
    double right = 0.0,
  }) {
    return EdgeInsets.only(
      top: top.clamp(0.0, double.infinity),
      bottom: bottom.clamp(0.0, double.infinity),
      left: left.clamp(0.0, double.infinity),
      right: right.clamp(0.0, double.infinity),
    );
  }

  /// 安全的 Margin，避免負值
  static EdgeInsets safeMargin({
    double top = 0.0,
    double bottom = 0.0,
    double left = 0.0,
    double right = 0.0,
  }) {
    return EdgeInsets.only(
      top: top.clamp(0.0, double.infinity),
      bottom: bottom.clamp(0.0, double.infinity),
      left: left.clamp(0.0, double.infinity),
      right: right.clamp(0.0, double.infinity),
    );
  }

  /// 修復佈局問題的包裝器
  static Widget layoutFixer({
    required Widget child,
    bool preventOverflow = true,
    bool useSafeArea = true,
    EdgeInsets? padding,
  }) {
    Widget wrappedChild = child;

    // 添加安全區域
    if (useSafeArea) {
      wrappedChild = SafeArea(child: wrappedChild);
    }

    // 添加 padding
    if (padding != null) {
      wrappedChild = Padding(
        padding: padding,
        child: wrappedChild,
      );
    }

    // 防止溢出
    if (preventOverflow) {
      wrappedChild = ClipRect(child: wrappedChild);
    }

    return wrappedChild;
  }

  /// 響應式字體大小
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // 基準寬度 375px
    return (baseFontSize * scaleFactor).clamp(12.0, 30.0);
  }

  /// 響應式間距
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return (baseSpacing * scaleFactor).clamp(4.0, 40.0);
  }

  /// 修復 FloatingActionButton Hero 標籤衝突
  static Widget safeFloatingActionButton({
    required VoidCallback? onPressed,
    Widget? child,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    String? heroTag,
    double? elevation,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag ?? 'fab_${DateTime.now().millisecondsSinceEpoch}',
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      child: child,
    );
  }

  /// 設備適配邊距
  static EdgeInsets deviceAdaptivePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    
    // 根據螢幕大小調整邊距
    double horizontal = screenWidth * 0.04; // 4% 的螢幕寬度
    double vertical = screenHeight * 0.02;  // 2% 的螢幕高度
    
    return EdgeInsets.symmetric(
      horizontal: horizontal.clamp(8.0, 24.0),
      vertical: vertical.clamp(4.0, 16.0),
    );
  }

  /// 修復網絡圖片載入錯誤
  static Widget safeNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? 
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
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
              ),
            );
      },
    );
  }
}

/// 佈局調試助手
class LayoutDebugHelper {
  /// 顯示溢出信息
  static void showOverflowInfo(BuildContext context, RenderBox renderBox) {
    if (renderBox.hasSize) {
      final size = renderBox.size;
      final constraints = renderBox.constraints;
      
      debugPrint('=== 佈局調試信息 ===');
      debugPrint('組件大小: ${size.width} x ${size.height}');
      debugPrint('約束條件: $constraints');
      debugPrint('是否溢出: ${size.width > constraints.maxWidth || size.height > constraints.maxHeight}');
    }
  }

  /// 檢查 Hero 標籤唯一性
  static void checkHeroTagUniqueness(BuildContext context) {
    final heroTags = <Object>{};
    
    void visitor(Element element) {
      if (element.widget is Hero) {
        final heroWidget = element.widget as Hero;
        final tag = heroWidget.tag;
        
        if (heroTags.contains(tag)) {
          debugPrint('⚠️ 發現重複的 Hero 標籤: $tag');
        } else {
          heroTags.add(tag);
        }
      }
      element.visitChildren(visitor);
    }
    
    context.visitChildElements(visitor);
    debugPrint('✅ Hero 標籤檢查完成，找到 ${heroTags.length} 個唯一標籤');
  }
}

/// Hero 標籤管理器 - 防止衝突
class HeroTagManager {
  static final Map<String, int> _tagCounters = {};
  
  /// 生成唯一的 Hero 標籤
  static String generateUniqueTag(String baseName) {
    final counter = _tagCounters[baseName] ?? 0;
    _tagCounters[baseName] = counter + 1;
    return '${baseName}_${DateTime.now().millisecondsSinceEpoch}_$counter';
  }
  
  /// 為 FloatingActionButton 生成唯一標籤
  static String fabTag(String identifier) {
    return generateUniqueTag('fab_$identifier');
  }
  
  /// 為 Hero 動畫生成唯一標籤
  static String heroTag(String identifier) {
    return generateUniqueTag('hero_$identifier');
  }
  
  /// 清除計數器（可選，用於測試）
  static void clearCounters() {
    _tagCounters.clear();
  }
} 