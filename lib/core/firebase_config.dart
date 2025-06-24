import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;

  // Firebase 初始化 - 移動平台專用
  static Future<void> initialize() async {
    try {
      print('正在初始化 Firebase...');
      
      // 使用 DefaultFirebaseOptions 進行平台特定配置
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 初始化核心服務
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // 配置 Firestore 設置（移動平台優化）
      await _configureFirestore();
      
      print('✅ Firebase 初始化成功');
    } catch (e) {
      print('⚠️ Firebase 初始化失敗: $e');
      print('📱 應用將在離線模式下運行');
      // 不拋出錯誤，讓應用繼續運行
    }
  }

  // 配置 Firestore（移動平台優化）
  static Future<void> _configureFirestore() async {
    if (_firestore != null) {
      try {
        _firestore!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        print('配置 Firestore 失敗: $e');
      }
    }
  }

  // Getter 方法 - 安全版本
  static FirebaseAuth? get auth => _auth;
  static FirebaseFirestore? get firestore => _firestore;
  static FirebaseStorage? get storage => _storage;

  // 數據庫集合引用 - 安全版本
  static CollectionReference? get usersCollection => 
      _firestore?.collection('users');
  
  static CollectionReference? get matchesCollection => 
      _firestore?.collection('matches');
  
  static CollectionReference? get chatsCollection => 
      _firestore?.collection('chats');
  
  static CollectionReference? get messagesCollection => 
      _firestore?.collection('messages');

  // 分析事件記錄 - 簡化版本
  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      print('📊 事件記錄: $name');
      // 在生產環境中，這裡會記錄到 Firebase Analytics
    } catch (e) {
      print('記錄分析事件失敗: $e');
    }
  }

  // 檢查 Firebase 是否可用
  static bool get isAvailable => _auth != null && _firestore != null;
} 