import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import '../main_navigation/main_navigation.dart';
import '../onboarding/complete_onboarding_flow.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 如果正在載入
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE91E63),
              ),
            ),
          );
        }
        
        // 如果用戶已登入
        if (snapshot.hasData) {
          return _buildAuthenticatedView(snapshot.data!);
        }
        
        // 如果用戶未登入
        return const WelcomeScreen();
      },
    );
  }

  Widget _buildAuthenticatedView(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 如果正在載入用戶數據
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE91E63),
              ),
            ),
          );
        }

        // 如果用戶文檔不存在，創建基本文檔並進入入門流程
        if (!snapshot.hasData || !snapshot.data!.exists) {
          _createUserDocument(user);
          return const CompleteOnboardingFlow();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        
        // 檢查是否完成入門流程
        final onboardingCompleted = userData?['onboardingCompleted'] ?? false;
        final profileComplete = userData?['profileComplete'] ?? false;

        if (!onboardingCompleted || !profileComplete) {
          return const CompleteOnboardingFlow();
        }

        // 用戶已完成所有設置，進入主應用
        return const MainNavigation();
      },
    );
  }

  Future<void> _createUserDocument(User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
        'profileComplete': false,
        'isActive': true,
      });
    } catch (e) {
      print('創建用戶文檔失敗: $e');
    }
  }
} 