import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'user_service.dart';
import '../firebase_config.dart';

/// 認證服務
/// 處理用戶註冊、登錄、登出等認證相關功能
class AuthService {
  FirebaseAuth? get _auth => FirebaseConfig.auth;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // 初始化 GoogleSignIn（僅移動平台）
    _googleSignIn = GoogleSignIn();
  }

  /// 當前用戶
  User? get currentUser => _auth?.currentUser;

  /// 是否已登錄
  bool get isLoggedIn => currentUser != null;

  /// 認證狀態變化流
  Stream<User?> get authStateChanges => 
      _auth?.authStateChanges() ?? Stream.value(null);

  /// 電子郵件註冊
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String location,
  }) async {
    try {
      // 創建 Firebase 用戶
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 更新用戶顯示名稱
      await credential.user?.updateDisplayName(name);

      // 創建用戶檔案
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          age: age,
          gender: gender,
          location: location,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await UserService.createUserProfile(userModel);

        // 記錄分析事件
        await FirebaseConfig.logEvent('user_registration', {
          'method': 'email',
          'user_id': credential.user!.uid,
          'age': age,
          'gender': gender,
          'location': location,
        });
      }

      print('✅ 電子郵件註冊成功: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ 電子郵件註冊失敗: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ 註冊過程中發生錯誤: $e');
      throw Exception('註冊失敗，請稍後再試');
    }
  }

  /// 電子郵件登入
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 更新最後活躍時間
      if (credential.user != null) {
        await UserService.updateUserProfile(
          credential.user!.uid,
          {'lastActive': DateTime.now()},
        );

        // 記錄分析事件
        await FirebaseConfig.logEvent('user_login', {
          'method': 'email',
          'user_id': credential.user!.uid,
        });
      }

      print('✅ 電子郵件登入成功: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ 電子郵件登入失敗: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ 登入過程中發生錯誤: $e');
      throw Exception('登入失敗，請稍後再試');
    }
  }

  /// Google 登入（移動平台專用）
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 觸發 Google 登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google 登入已取消');
      }

      // 獲取認證詳情
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 創建 Firebase 認證憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用憑證登入 Firebase
      final userCredential = await _auth!.signInWithCredential(credential);

      // 檢查是否為新用戶
      if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
        // 創建用戶檔案（使用 Google 提供的基本信息）
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'Google 用戶',
          email: userCredential.user!.email ?? '',
          age: 25, // 默認年齡，稍後需要用戶補充
          gender: '', // 需要用戶補充
          location: '', // 需要用戶補充
          photoUrls: userCredential.user!.photoURL != null 
              ? [userCredential.user!.photoURL!] 
              : [],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await UserService.createUserProfile(userModel);

        // 記錄分析事件
        await FirebaseConfig.logEvent('user_registration', {
          'method': 'google',
          'user_id': userCredential.user!.uid,
        });
      } else if (userCredential.user != null) {
        // 更新最後活躍時間
        await UserService.updateUserProfile(
          userCredential.user!.uid,
          {'lastActive': DateTime.now()},
        );

        // 記錄分析事件
        await FirebaseConfig.logEvent('user_login', {
          'method': 'google',
          'user_id': userCredential.user!.uid,
        });
      }

      print('✅ Google 登入成功: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Google 登入失敗: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Google 登入過程中發生錯誤: $e');
      throw Exception('Google 登入失敗，請稍後再試');
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      // 記錄分析事件
      if (currentUser != null) {
        await FirebaseConfig.logEvent('user_logout', {
          'user_id': currentUser!.uid,
        });
      }

      // 登出 Google
      await _googleSignIn.signOut();
      
      // 登出 Firebase
      await _auth!.signOut();

      print('✅ 用戶登出成功');
    } catch (e) {
      print('❌ 登出失敗: $e');
      throw Exception('登出失敗，請稍後再試');
    }
  }

  /// 重設密碼
  Future<void> resetPassword(String email) async {
    try {
      await _auth!.sendPasswordResetEmail(email: email);

      // 記錄分析事件
      await FirebaseConfig.logEvent('password_reset_requested', {
        'email': email,
      });

      print('✅ 密碼重設郵件已發送');
    } on FirebaseAuthException catch (e) {
      print('❌ 發送密碼重設郵件失敗: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ 密碼重設過程中發生錯誤: $e');
      throw Exception('發送密碼重設郵件失敗，請稍後再試');
    }
  }

  /// 處理 Firebase 認證異常
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('密碼強度不足，請使用至少 6 個字符');
      case 'email-already-in-use':
        return Exception('此電子郵件已被註冊');
      case 'invalid-email':
        return Exception('電子郵件格式無效');
      case 'user-not-found':
        return Exception('找不到此用戶');
      case 'wrong-password':
        return Exception('密碼錯誤');
      case 'user-disabled':
        return Exception('此帳戶已被停用');
      case 'too-many-requests':
        return Exception('請求過於頻繁，請稍後再試');
      case 'operation-not-allowed':
        return Exception('此操作不被允許');
      case 'requires-recent-login':
        return Exception('此操作需要重新登入');
      default:
        return Exception('認證失敗: ${e.message}');
    }
  }

  /// 檢查用戶是否已完成個人檔案設置
  Future<bool> isProfileComplete() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userProfile = await UserService.getUserProfile(user.uid);
      if (userProfile == null) return false;

      // 檢查必要字段是否已填寫
      return userProfile.name.isNotEmpty &&
             userProfile.age > 0 &&
             userProfile.gender.isNotEmpty &&
             userProfile.location.isNotEmpty &&
             userProfile.photoUrls.isNotEmpty;
    } catch (e) {
      print('❌ 檢查個人檔案完整性失敗: $e');
      return false;
    }
  }
}

// 認證狀態提供者
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseConfig.auth!.authStateChanges();
});

// 認證服務提供者
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
}); 