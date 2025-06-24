import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static const String _adminEmail = 'admin@amore.hk';
  static const String _adminPassword = 'AmoreAdmin2024!';
  static const String _adminUserId = 'admin_user_001';
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 管理員快速登入
  static Future<bool> adminQuickLogin() async {
    try {
      // 創建管理員用戶（如果不存在）
      await _createAdminUserIfNotExists();
      
      // 使用管理員憑證登入
      final credential = await _auth.signInWithEmailAndPassword(
        email: _adminEmail,
        password: _adminPassword,
      );
      
      if (credential.user != null) {
        print('✅ 管理員登入成功');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ 管理員登入失敗: $e');
      
      // 如果登入失敗，嘗試創建管理員帳戶
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: _adminEmail,
          password: _adminPassword,
        );
        
        if (credential.user != null) {
          await _setupAdminProfile(credential.user!);
          print('✅ 管理員帳戶創建並登入成功');
          return true;
        }
      } catch (createError) {
        print('❌ 創建管理員帳戶失敗: $createError');
      }
      
      return false;
    }
  }
  
  // 檢查當前用戶是否為管理員
  static bool isCurrentUserAdmin() {
    final currentUser = _auth.currentUser;
    return currentUser?.email == _adminEmail;
  }
  
  // 創建管理員用戶（如果不存在）
  static Future<void> _createAdminUserIfNotExists() async {
    try {
      // 檢查管理員檔案是否存在
      final adminDoc = await _firestore.collection('users').doc(_adminUserId).get();
      
      if (!adminDoc.exists) {
        await _firestore.collection('users').doc(_adminUserId).set({
          'id': _adminUserId,
          'email': _adminEmail,
          'name': 'Admin',
          'age': 30,
          'mbtiType': 'INTJ',
          'interests': ['管理', '分析', '技術'],
          'bio': 'Amore 系統管理員',
          'isAdmin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
          'photos': [],
          'location': '香港',
          'gender': 'other',
          'lookingFor': 'other',
          'maxDistance': 50,
          'ageRange': {'min': 18, 'max': 50},
        });
        
        print('✅ 管理員檔案創建成功');
      }
    } catch (e) {
      print('❌ 創建管理員檔案失敗: $e');
    }
  }
  
  // 設置管理員檔案
  static Future<void> _setupAdminProfile(User user) async {
    try {
      await user.updateDisplayName('Admin');
      
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': _adminEmail,
        'name': 'Admin',
        'age': 30,
        'mbtiType': 'INTJ',
        'interests': ['管理', '分析', '技術'],
        'bio': 'Amore 系統管理員',
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': true,
        'photos': [],
        'location': '香港',
        'gender': 'other',
        'lookingFor': 'other',
        'maxDistance': 50,
        'ageRange': {'min': 18, 'max': 50},
      });
      
      print('✅ 管理員檔案設置完成');
    } catch (e) {
      print('❌ 設置管理員檔案失敗: $e');
    }
  }
  
  // 管理員功能：重置用戶密碼
  static Future<bool> resetUserPassword(String email) async {
    if (!isCurrentUserAdmin()) {
      print('❌ 權限不足：非管理員用戶');
      return false;
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ 密碼重置郵件已發送到: $email');
      return true;
    } catch (e) {
      print('❌ 發送密碼重置郵件失敗: $e');
      return false;
    }
  }
  
  // 管理員功能：獲取用戶統計
  static Future<Map<String, dynamic>> getUserStats() async {
    if (!isCurrentUserAdmin()) {
      print('❌ 權限不足：非管理員用戶');
      return {};
    }
    
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final messagesSnapshot = await _firestore.collection('messages').get();
      final analysisSnapshot = await _firestore.collection('conversation_analysis').get();
      
      final stats = {
        'totalUsers': usersSnapshot.docs.length,
        'totalMessages': messagesSnapshot.docs.length,
        'totalAnalysis': analysisSnapshot.docs.length,
        'activeUsers': usersSnapshot.docs.where((doc) {
          final data = doc.data();
          final lastActive = data['lastActive'] as Timestamp?;
          if (lastActive == null) return false;
          
          final daysSinceActive = DateTime.now().difference(lastActive.toDate()).inDays;
          return daysSinceActive <= 7;
        }).length,
      };
      
      print('✅ 用戶統計獲取成功: $stats');
      return stats;
    } catch (e) {
      print('❌ 獲取用戶統計失敗: $e');
      return {};
    }
  }
  
  // 管理員功能：清理測試數據
  static Future<bool> cleanupTestData() async {
    if (!isCurrentUserAdmin()) {
      print('❌ 權限不足：非管理員用戶');
      return false;
    }
    
    try {
      // 刪除測試消息
      final testMessages = await _firestore
          .collection('messages')
          .where('content', isEqualTo: 'test')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in testMessages.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      print('✅ 測試數據清理完成');
      return true;
    } catch (e) {
      print('❌ 清理測試數據失敗: $e');
      return false;
    }
  }
  
  // 管理員功能：創建測試用戶
  static Future<bool> createTestUsers() async {
    if (!isCurrentUserAdmin()) {
      print('❌ 權限不足：非管理員用戶');
      return false;
    }
    
    try {
      final testUsers = [
        {
          'name': 'Test Sarah',
          'age': 25,
          'mbtiType': 'ENFP',
          'email': 'test.sarah@amore.hk',
          'bio': '測試用戶 - Sarah',
        },
        {
          'name': 'Test Emma',
          'age': 28,
          'mbtiType': 'INFJ',
          'email': 'test.emma@amore.hk',
          'bio': '測試用戶 - Emma',
        },
        {
          'name': 'Test Lily',
          'age': 26,
          'mbtiType': 'ISFP',
          'email': 'test.lily@amore.hk',
          'bio': '測試用戶 - Lily',
        },
      ];
      
      for (final userData in testUsers) {
        final userName = userData['name'] as String;
        final userId = 'test_${userName.toLowerCase().replaceAll(' ', '_')}';
        
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'name': userData['name'],
          'age': userData['age'],
          'mbtiType': userData['mbtiType'],
          'email': userData['email'],
          'bio': userData['bio'],
          'isTestUser': true,
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
          'photos': [],
          'interests': ['測試', '開發'],
          'location': '香港',
          'gender': 'female',
          'lookingFor': 'male',
          'maxDistance': 50,
          'ageRange': {'min': 20, 'max': 35},
        });
      }
      
      print('✅ 測試用戶創建完成');
      return true;
    } catch (e) {
      print('❌ 創建測試用戶失敗: $e');
      return false;
    }
  }
  
  // 管理員功能：生成測試聊天記錄
  static Future<bool> generateTestChatData() async {
    if (!isCurrentUserAdmin()) {
      print('❌ 權限不足：非管理員用戶');
      return false;
    }
    
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;
      
      final testMessages = [
        {
          'chatId': 'chat_${currentUserId}_test_sarah',
          'senderId': 'test_sarah',
          'receiverId': currentUserId,
          'content': '你好！很高興認識你 😊',
          'type': 'text',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        },
        {
          'chatId': 'chat_${currentUserId}_test_sarah',
          'senderId': currentUserId,
          'receiverId': 'test_sarah',
          'content': '你好！我也很高興認識你',
          'type': 'text',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1, minutes: 50))),
        },
        {
          'chatId': 'chat_${currentUserId}_test_sarah',
          'senderId': 'test_sarah',
          'receiverId': currentUserId,
          'content': '你平時喜歡做什麼呢？我很喜歡旅行和攝影',
          'type': 'text',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
        },
        {
          'chatId': 'chat_${currentUserId}_test_emma',
          'senderId': 'test_emma',
          'receiverId': currentUserId,
          'content': '嗨，看到你的檔案覺得我們有很多共同點',
          'type': 'text',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
        },
        {
          'chatId': 'chat_${currentUserId}_test_emma',
          'senderId': currentUserId,
          'receiverId': 'test_emma',
          'content': '真的嗎？我也這麼覺得！',
          'type': 'text',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2, minutes: 45))),
        },
      ];
      
      final batch = _firestore.batch();
      for (final messageData in testMessages) {
        final messageRef = _firestore.collection('messages').doc();
        batch.set(messageRef, messageData);
      }
      
      await batch.commit();
      
      print('✅ 測試聊天記錄生成完成');
      return true;
    } catch (e) {
      print('❌ 生成測試聊天記錄失敗: $e');
      return false;
    }
  }
} 