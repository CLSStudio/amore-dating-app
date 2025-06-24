import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔥 開始測試 Firebase 配置...');
  
  try {
    // 測試 Firebase 初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Core 初始化成功');
    
    // 測試 Firebase 服務
    await FirebaseService.initialize();
    print('✅ Firebase 服務初始化成功');
    
    print('🎉 Firebase 配置測試完成！所有服務正常運行。');
    
  } catch (e, stackTrace) {
    print('❌ Firebase 配置測試失敗: $e');
    print('Stack trace: $stackTrace');
  }
} 