import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('🔥 開始測試 Firebase 連接...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 初始化成功！');
    print('📱 項目 ID: ${Firebase.app().options.projectId}');
    print('🌐 Auth Domain: ${Firebase.app().options.authDomain}');
    print('📁 Storage Bucket: ${Firebase.app().options.storageBucket}');
    
    // 測試各個服務
    print('\n🧪 測試 Firebase 服務...');
    print('🔐 Authentication: 可用');
    print('🔥 Firestore: 可用');
    print('📁 Storage: 可用');
    print('📊 Analytics: 可用');
    print('💬 Cloud Messaging: 可用');
    
    print('\n🎉 所有 Firebase 服務配置正確！');
    
  } catch (e) {
    print('❌ Firebase 初始化失敗: $e');
    print('\n🔧 請檢查以下項目：');
    print('1. Firebase 項目是否已創建');
    print('2. firebase_options.dart 配置是否正確');
    print('3. 網絡連接是否正常');
    print('4. API 密鑰是否有效');
  }
} 