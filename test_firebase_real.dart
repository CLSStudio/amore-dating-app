import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('🔥 開始測試 Firebase 連接...');
  
  try {
    // 初始化 Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase 初始化成功！');
    print('📱 項目 ID: ${Firebase.app().options.projectId}');
    print('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 10)}...');
    print('🌐 Auth Domain: ${Firebase.app().options.authDomain}');
    print('📦 Storage Bucket: ${Firebase.app().options.storageBucket}');
    
    // 檢查配置是否為真實值
    if (Firebase.app().options.apiKey.contains('your-')) {
      print('⚠️  警告：API 密鑰仍然是佔位符，需要真實的 Firebase 配置');
    } else {
      print('🎉 恭喜！已連接到真實的 Firebase 項目');
    }
    
  } catch (e) {
    print('❌ Firebase 初始化失敗: $e');
    print('💡 請確保：');
    print('   1. Firebase 項目已創建');
    print('   2. firebase_options.dart 包含真實配置');
    print('   3. 網絡連接正常');
  }
} 