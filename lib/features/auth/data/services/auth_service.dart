import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart' as app_user;
import '../../../../core/utils/logger.dart';

/// 認證服務類
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final FirebaseFirestore _firestore;

  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// 獲取當前用戶
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// 用戶狀態流
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Email 註冊
  Future<app_user.User?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      Logger.info('開始 Email 註冊: $email');
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 更新顯示名稱
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        // 發送驗證郵件
        await credential.user!.sendEmailVerification();
        
        // 創建用戶檔案
        final user = await _createUserProfile(
          credential.user!,
          firstName: firstName,
          lastName: lastName,
        );
        
        Logger.info('✅ Email 註冊成功: ${credential.user!.uid}');
        return user;
      }
      
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('❌ Email 註冊失敗', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      Logger.error('❌ Email 註冊未知錯誤', error: e);
      throw Exception('註冊失敗，請稍後再試');
    }
  }

  /// Email 登入
  Future<app_user.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('開始 Email 登入: $email');
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = await _getUserProfile(credential.user!.uid);
        
        // 更新最後登入時間
        await _updateLastLoginTime(credential.user!.uid);
        
        Logger.info('✅ Email 登入成功: ${credential.user!.uid}');
        return user;
      }
      
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('❌ Email 登入失敗', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      Logger.error('❌ Email 登入未知錯誤', error: e);
      throw Exception('登入失敗，請稍後再試');
    }
  }

  /// Google 登入
  Future<app_user.User?> signInWithGoogle() async {
    try {
      Logger.info('開始 Google 登入');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Logger.info('用戶取消 Google 登入');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final user = await _createOrUpdateUserProfile(userCredential.user!);
        Logger.info('✅ Google 登入成功: ${userCredential.user!.uid}');
        return user;
      }
      
      return null;
    } catch (e) {
      Logger.error('❌ Google 登入失敗', error: e);
      throw Exception('Google 登入失敗，請稍後再試');
    }
  }

  /// Facebook 登入
  Future<app_user.User?> signInWithFacebook() async {
    try {
      Logger.info('開始 Facebook 登入');
      
      final LoginResult result = await _facebookAuth.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final credential = firebase_auth.FacebookAuthProvider.credential(accessToken.token);
        
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          final user = await _createOrUpdateUserProfile(userCredential.user!);
          Logger.info('✅ Facebook 登入成功: ${userCredential.user!.uid}');
          return user;
        }
      } else {
        Logger.info('用戶取消 Facebook 登入');
      }
      
      return null;
    } catch (e) {
      Logger.error('❌ Facebook 登入失敗', error: e);
      throw Exception('Facebook 登入失敗，請稍後再試');
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      Logger.info('開始登出');
      
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      
      Logger.info('✅ 登出成功');
    } catch (e) {
      Logger.error('❌ 登出失敗', error: e);
      throw Exception('登出失敗，請稍後再試');
    }
  }

  /// 重設密碼
  Future<void> resetPassword(String email) async {
    try {
      Logger.info('發送密碼重設郵件: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Logger.info('✅ 密碼重設郵件已發送');
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('❌ 密碼重設失敗', error: e);
      throw _handleAuthException(e);
    }
  }

  /// 重新發送驗證郵件
  Future<void> resendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Logger.info('✅ 驗證郵件已重新發送');
      }
    } catch (e) {
      Logger.error('❌ 重新發送驗證郵件失敗', error: e);
      throw Exception('發送驗證郵件失敗，請稍後再試');
    }
  }

  /// 創建用戶檔案
  Future<app_user.User> _createUserProfile(
    firebase_auth.User firebaseUser, {
    String? firstName,
    String? lastName,
  }) async {
    final now = DateTime.now();
    final user = app_user.User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      createdAt: now,
      lastLoginAt: now,
      firstName: firstName,
      lastName: lastName,
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());
    return user;
  }

  /// 創建或更新用戶檔案
  Future<app_user.User> _createOrUpdateUserProfile(firebase_auth.User firebaseUser) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    
    if (doc.exists) {
      // 更新現有用戶
      final user = app_user.User.fromJson(doc.data()!);
      final updatedUser = user.copyWith(
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        emailVerified: firebaseUser.emailVerified,
        lastLoginAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(firebaseUser.uid).update(updatedUser.toJson());
      return updatedUser;
    } else {
      // 創建新用戶
      return await _createUserProfile(firebaseUser);
    }
  }

  /// 獲取用戶檔案
  Future<app_user.User?> _getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('❌ 獲取用戶檔案失敗', error: e);
      return null;
    }
  }

  /// 更新最後登入時間
  Future<void> _updateLastLoginTime(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.error('❌ 更新最後登入時間失敗', error: e);
    }
  }

  /// 處理認證異常
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('密碼強度不足，請使用至少 6 個字符');
      case 'email-already-in-use':
        return Exception('此電子郵件已被註冊');
      case 'invalid-email':
        return Exception('電子郵件格式不正確');
      case 'user-not-found':
        return Exception('找不到此用戶');
      case 'wrong-password':
        return Exception('密碼錯誤');
      case 'user-disabled':
        return Exception('此帳戶已被停用');
      case 'too-many-requests':
        return Exception('請求過於頻繁，請稍後再試');
      case 'operation-not-allowed':
        return Exception('此登入方式未啟用');
      default:
        return Exception('認證失敗：${e.message}');
    }
  }
} 