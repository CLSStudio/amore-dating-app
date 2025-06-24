import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/firebase_config.dart';

// Firebase 認證狀態提供者
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  final auth = FirebaseConfig.auth;
  if (auth == null) return Stream.value(null);
  return auth.authStateChanges();
});

// Firebase 認證服務提供者
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  String? _verificationId;

  // 當前用戶
  User? get currentUser => _auth.currentUser;
  
  // 是否已登入
  bool get isSignedIn => currentUser != null;

  // 發送手機驗證碼
  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 自動驗證完成（Android）
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('驗證失敗: ${e.message}');
          throw Exception('驗證失敗: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print('驗證碼已發送到: $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('發送驗證碼失敗: $e');
      throw Exception('發送驗證碼失敗: $e');
    }
  }

  // 使用手機號碼和驗證碼登入
  Future<UserCredential> signInWithPhone(String phoneNumber, String verificationCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('請先發送驗證碼');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: verificationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // 創建或更新用戶檔案
      await _createOrUpdateUserProfile(userCredential.user!, phoneNumber: phoneNumber);
      
      return userCredential;
    } catch (e) {
      print('手機號碼登入失敗: $e');
      throw Exception('驗證碼錯誤或已過期');
    }
  }

  // Google 登入
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
      final userCredential = await _auth.signInWithCredential(credential);
      
      // 創建或更新用戶檔案
      await _createOrUpdateUserProfile(
        userCredential.user!,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoURL: googleUser.photoUrl,
      );
      
      return userCredential;
    } catch (e) {
      print('Google 登入失敗: $e');
      throw Exception('Google 登入失敗: $e');
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('登出失敗: $e');
      throw Exception('登出失敗: $e');
    }
  }

  // 創建或更新用戶檔案
  Future<void> _createOrUpdateUserProfile(
    User user, {
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (FirebaseConfig.usersCollection == null) return;
      final userDoc = FirebaseConfig.usersCollection!.doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      final now = DateTime.now();
      
      if (!docSnapshot.exists) {
        // 創建新用戶檔案
        await userDoc.set({
          'uid': user.uid,
          'email': email ?? user.email,
          'phoneNumber': phoneNumber ?? user.phoneNumber,
          'displayName': displayName ?? user.displayName,
          'photoURL': photoURL ?? user.photoURL,
          'createdAt': now,
          'lastActive': now,
          'profileCompleted': false,
          'isVerified': false,
        });
        
        print('新用戶檔案已創建: ${user.uid}');
      } else {
        // 更新現有用戶的最後活躍時間
        await userDoc.update({
          'lastActive': now,
        });
        
        print('用戶檔案已更新: ${user.uid}');
      }
    } catch (e) {
      print('創建/更新用戶檔案失敗: $e');
      // 不拋出錯誤，因為認證已經成功
    }
  }

  // 檢查用戶是否完成個人檔案設置
  Future<bool> isProfileCompleted() async {
    try {
      if (currentUser == null) return false;
      if (FirebaseConfig.usersCollection == null) return false;
      
      final userDoc = await FirebaseConfig.usersCollection!.doc(currentUser!.uid).get();
      
      if (!userDoc.exists) return false;
      
      final data = userDoc.data() as Map<String, dynamic>?;
      return data?['profileCompleted'] ?? false;
    } catch (e) {
      print('檢查檔案完成狀態失敗: $e');
      return false;
    }
  }

  // 標記個人檔案為已完成
  Future<void> markProfileAsCompleted() async {
    try {
      if (currentUser == null) return;
      if (FirebaseConfig.usersCollection == null) return;
      
      await FirebaseConfig.usersCollection!.doc(currentUser!.uid).update({
        'profileCompleted': true,
        'lastActive': DateTime.now(),
      });
      
      print('個人檔案已標記為完成');
    } catch (e) {
      print('標記檔案完成失敗: $e');
      throw Exception('更新檔案狀態失敗');
    }
  }

  // 獲取用戶檔案數據
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      if (FirebaseConfig.usersCollection == null) return null;
      
      final userDoc = await FirebaseConfig.usersCollection!.doc(currentUser!.uid).get();
      
      if (!userDoc.exists) return null;
      
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('獲取用戶檔案失敗: $e');
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    final auth = FirebaseConfig.auth;
    if (auth == null) return Stream.value(null);
    return auth.authStateChanges();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = FirebaseConfig.auth;
    if (auth == null) throw Exception('Firebase Auth 未初始化');
    
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = FirebaseConfig.auth;
    if (auth == null) throw Exception('Firebase Auth 未初始化');
    
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final auth = FirebaseConfig.auth;
    if (auth == null) throw Exception('Firebase Auth 未初始化');
    
    await auth.sendPasswordResetEmail(email: email);
  }
} 