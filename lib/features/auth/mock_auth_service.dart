import 'package:flutter_riverpod/flutter_riverpod.dart';

// 模擬用戶類
class MockUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
  });
}

// 模擬認證狀態提供者
final mockAuthStateProvider = StateNotifierProvider<MockAuthNotifier, MockUser?>((ref) {
  return MockAuthNotifier();
});

class MockAuthNotifier extends StateNotifier<MockUser?> {
  MockAuthNotifier() : super(null);

  // 模擬手機號碼登入
  Future<void> signInWithPhone(String phoneNumber, String verificationCode) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(seconds: 1));
    
    // 簡單驗證：任何6位數字都視為有效
    if (verificationCode.length == 6 && RegExp(r'^\d{6}$').hasMatch(verificationCode)) {
      state = MockUser(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        displayName: '測試用戶',
      );
    } else {
      throw Exception('驗證碼錯誤');
    }
  }

  // 模擬 Google 登入
  Future<void> signInWithGoogle() async {
    // 模擬網路延遲
    await Future.delayed(const Duration(seconds: 1));
    
    state = MockUser(
      uid: 'mock_google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'test@gmail.com',
      displayName: 'Google 測試用戶',
    );
  }

  // 模擬發送驗證碼
  Future<void> sendVerificationCode(String phoneNumber) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(seconds: 1));
    
    // 在實際應用中，這裡會調用 Firebase Auth
    print('模擬發送驗證碼到: $phoneNumber');
    print('模擬驗證碼: 123456');
  }

  // 登出
  Future<void> signOut() async {
    state = null;
  }

  // 檢查是否已登入
  bool get isSignedIn => state != null;
}

// 模擬認證服務提供者
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService(ref);
});

class MockAuthService {
  final Ref _ref;

  MockAuthService(this._ref);

  MockAuthNotifier get _authNotifier => _ref.read(mockAuthStateProvider.notifier);

  Future<void> signInWithPhone(String phoneNumber, String verificationCode) async {
    await _authNotifier.signInWithPhone(phoneNumber, verificationCode);
  }

  Future<void> signInWithGoogle() async {
    await _authNotifier.signInWithGoogle();
  }

  Future<void> sendVerificationCode(String phoneNumber) async {
    await _authNotifier.sendVerificationCode(phoneNumber);
  }

  Future<void> signOut() async {
    await _authNotifier.signOut();
  }

  MockUser? get currentUser => _ref.read(mockAuthStateProvider);
  
  bool get isSignedIn => _authNotifier.isSignedIn;
} 