import 'package:flutter/material.dart';

class AppSpacing {
  // 基礎間距
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
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);
  
  // 列表項邊距
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  
  // 按鈕邊距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  
  // 輸入框邊距
  static const EdgeInsets inputPadding = EdgeInsets.all(md);
  
  // 對話框邊距
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  
  // 底部導航欄高度
  static const double bottomNavHeight = 60.0;
  
  // 應用欄高度
  static const double appBarHeight = 56.0;
  
  // 標籤欄高度
  static const double tabBarHeight = 48.0;
} 