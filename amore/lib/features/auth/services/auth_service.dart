import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../../../core/services/firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 當前用戶流
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // 當前用戶
  User? get currentUser => _auth.currentUser;

  // 當前用戶模型流
  Stream<UserModel?> get currentUserModel {
    return authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return await getUserModel(user.uid);
    });
  }

  /// Email 註冊
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // 創建 Firebase 用戶
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 更新顯示名稱
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        // 發送驗證郵件
        await credential.user!.sendEmailVerification();

        // 創建用戶文檔
        await _createUserDocument(
          credential.user!,
          additionalData: {
            'firstName': firstName,
            'lastName': lastName,
          },
        );

        // 記錄事件
        await FirebaseService.logEvent(
          name: 'user_register',
          parameters: {
            'method': 'email',
            'user_id': credential.user!.uid,
          },
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'email_register'},
      );
      rethrow;
    }
  }

  /// Email 登入
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 記錄事件
      await FirebaseService.logEvent(
        name: 'user_login',
        parameters: {
          'method': 'email',
          'user_id': credential.user?.uid,
        },
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'email_login'},
      );
      rethrow;
    }
  }

  /// Google 登入
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 觸發 Google 登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google 登入被取消');
      }

      // 獲取認證詳情
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 創建新的認證憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用憑證登入
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // 檢查是否為新用戶
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          await _createUserDocument(
            userCredential.user!,
            additionalData: {
              'connectedAccounts': ['google'],
            },
          );
        } else {
          // 更新連接的帳戶
          await _updateConnectedAccounts(userCredential.user!.uid, 'google');
        }

        // 記錄事件
        await FirebaseService.logEvent(
          name: isNewUser ? 'user_register' : 'user_login',
          parameters: {
            'method': 'google',
            'user_id': userCredential.user!.uid,
          },
        );
      }

      return userCredential;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'google_login'},
      );
      rethrow;
    }
  }

  /// Facebook 登入
  Future<UserCredential> signInWithFacebook() async {
    try {
      // 觸發 Facebook 登入流程
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        // 創建 Facebook 認證憑證
        final OAuthCredential facebookAuthCredential = 
            FacebookAuthProvider.credential(result.accessToken!.token);

        // 使用憑證登入
        final userCredential = await _auth.signInWithCredential(facebookAuthCredential);

        if (userCredential.user != null) {
          // 檢查是否為新用戶
          final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
          
          if (isNewUser) {
            await _createUserDocument(
              userCredential.user!,
              additionalData: {
                'connectedAccounts': ['facebook'],
              },
            );
          } else {
            // 更新連接的帳戶
            await _updateConnectedAccounts(userCredential.user!.uid, 'facebook');
          }

          // 記錄事件
          await FirebaseService.logEvent(
            name: isNewUser ? 'user_register' : 'user_login',
            parameters: {
              'method': 'facebook',
              'user_id': userCredential.user!.uid,
            },
          );
        }

        return userCredential;
      } else {
        throw Exception('Facebook 登入失敗: ${result.status}');
      }
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'facebook_login'},
      );
      rethrow;
    }
  }

  /// 發送密碼重設郵件
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      await FirebaseService.logEvent(
        name: 'password_reset_sent',
        parameters: {'email': email},
      );
    } on FirebaseAuthException catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'password_reset'},
      );
      rethrow;
    }
  }

  /// 發送郵件驗證
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        
        await FirebaseService.logEvent(
          name: 'email_verification_sent',
          parameters: {'user_id': user.uid},
        );
      }
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'email_verification'},
      );
      rethrow;
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      // 記錄登出事件
      if (currentUser != null) {
        await FirebaseService.logEvent(
          name: 'user_logout',
          parameters: {'user_id': currentUser!.uid},
        );
      }

      // 登出所有服務
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'logout'},
      );
      rethrow;
    }
  }

  /// 刪除帳戶
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 刪除用戶文檔
        await _firestore.collection('users').doc(user.uid).delete();
        
        // 記錄事件
        await FirebaseService.logEvent(
          name: 'user_delete_account',
          parameters: {'user_id': user.uid},
        );

        // 刪除 Firebase 用戶
        await user.delete();
      }
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'delete_account'},
      );
      rethrow;
    }
  }

  /// 獲取用戶模型
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'get_user_model', 'uid': uid},
      );
      return null;
    }
  }

  /// 更新用戶模型
  Future<void> updateUserModel(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toFirestore());
      
      await FirebaseService.logEvent(
        name: 'user_profile_updated',
        parameters: {'user_id': user.id},
      );
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'update_user_model'},
      );
      rethrow;
    }
  }

  /// 創建用戶文檔
  Future<void> _createUserDocument(
    User user, {
    Map<String, dynamic>? additionalData,
  }) async {
    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      createdAt: now,
      updatedAt: now,
      isEmailVerified: user.emailVerified,
      connectedAccounts: additionalData?['connectedAccounts'] ?? [],
      profile: additionalData != null ? UserProfile(
        firstName: additionalData['firstName'],
        lastName: additionalData['lastName'],
      ) : null,
      preferences: const UserPreferences(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  /// 更新連接的帳戶
  Future<void> _updateConnectedAccounts(String uid, String provider) async {
    await _firestore.collection('users').doc(uid).update({
      'connectedAccounts': FieldValue.arrayUnion([provider]),
      'updatedAt': Timestamp.now(),
    });
  }
}

// Riverpod 提供者
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserModel;
}); 