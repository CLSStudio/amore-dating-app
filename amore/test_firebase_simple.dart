import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  print('🔥 開始測試 Firebase 配置...');
  
  try {
    // 測試 Firebase 初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Core 初始化成功');
    print('📱 項目 ID: ${Firebase.app().options.projectId}');
    print('🏪 Storage Bucket: ${Firebase.app().options.storageBucket}');
    print('📧 Messaging Sender ID: ${Firebase.app().options.messagingSenderId}');
    
    print('🎉 Firebase 配置測試完成！所有服務正常運行。');
    
  } catch (e, stackTrace) {
    print('❌ Firebase 配置測試失敗: $e');
    print('Stack trace: $stackTrace');
  }
} 