import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firebase_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 等待最少 2 秒以顯示啟動畫面
      await Future.delayed(const Duration(seconds: 2));
      
      // 檢查用戶登錄狀態
      await _checkAuthStatus();
      
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print('應用初始化失敗: $e');
      }
      // 發生錯誤時仍然導航到引導頁面
      _navigateToOnboarding();
    }
  }

  Future<void> _checkAuthStatus() async {
    if (mounted) {
      if (FirebaseService.isUserLoggedIn) {
        // 用戶已登錄，直接進入主應用
        context.go(AppConstants.homeRoute);
      } else {
        // 檢查是否是首次啟動
        _navigateToOnboarding();
      }
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      context.go(AppConstants.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo 容器
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .scale(begin: const Offset(0.5, 0.5), duration: 800.ms, delay: 200.ms)
                .then()
                .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
              
              const SizedBox(height: 32),
              
              // 應用名稱
              const Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontFamily: AppTheme.secondaryFontFamily,
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideY(begin: 0.3, duration: 800.ms, delay: 600.ms),
              
              const SizedBox(height: 16),
              
              // 標語
              Text(
                '智能配對，真摯連結',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1,
                  fontFamily: AppTheme.primaryFontFamily,
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 1000.ms)
                .slideY(begin: 0.3, duration: 800.ms, delay: 1000.ms),
              
              const SizedBox(height: 80),
              
              // 加載指示器
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  strokeWidth: 3,
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 1400.ms)
                .scale(begin: const Offset(0.5, 0.5), duration: 800.ms, delay: 1400.ms),
              
              const SizedBox(height: 24),
              
              // 版本信息
              Text(
                'v${AppConfig.appVersion}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontFamily: AppTheme.primaryFontFamily,
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 1800.ms),
            ],
          ),
        ),
      ),
    );
  }
} 