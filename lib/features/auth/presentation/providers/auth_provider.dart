import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../data/services/auth_service.dart';
import '../../domain/entities/user.dart';

/// 認證服務提供者
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 認證狀態提供者
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// 當前用戶提供者
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // 這裡可以從 Firestore 獲取完整的用戶資料
      // 暫時返回基本用戶信息
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        emailVerified: firebaseUser.emailVerified,
        createdAt: DateTime.now(), // 實際應該從 Firestore 獲取
      );
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

/// 認證控制器
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncValue.loading());

  /// Email 註冊
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Email 登入
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Google 登入
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Facebook 登入
  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.signInWithFacebook();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 重設密碼
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  /// 重新發送驗證郵件
  Future<void> resendEmailVerification() async {
    try {
      await _authService.resendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }
}

/// 認證控制器提供者
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
}); 