import 'package:flutter/material.dart';

// 導入完整的 Amore 移動平台版本
import 'main_mobile_complete.dart' as mobile_app;

/// Amore - 香港約會應用程式
/// 完整功能版本，支援 Android 和 iOS
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Amore 約會應用程式啟動中...');
  print('📱 支援平台: Android & iOS');
  print('🌏 目標市場: 香港');
  print('💕 核心功能: 25個完整功能');
  print('🎯 特色: 三大交友模式系統');
  
  // 運行完整的移動平台應用程式
  mobile_app.main();
} 