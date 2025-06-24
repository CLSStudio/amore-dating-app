import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_config.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '智能配對',
      subtitle: '基於 MBTI 和價值觀的深度匹配',
      description: '我們的 AI 算法會分析您的性格類型和人生價值觀，為您推薦真正契合的靈魂伴侶。',
      icon: Icons.psychology_outlined,
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: '安全認證',
      subtitle: '真實身份，可靠保障',
      description: '通過 AI 照片驗證和多重安全機制，確保每一次配對都是與真實的人連結。',
      icon: Icons.verified_user_outlined,
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      title: '專業諮詢',
      subtitle: 'AI 愛情顧問隨時陪伴',
      description: '獲得個性化的約會建議和關係指導，讓每一次互動都更有意義。',
      icon: Icons.favorite_outline,
      color: AppTheme.accentColor,
    ),
    OnboardingPage(
      title: '視頻通話',
      subtitle: '面對面，心連心',
      description: '安全的應用內視頻通話功能，讓你在見面前就能感受真實的化學反應。',
      icon: Icons.video_call_outlined,
      color: AppTheme.primaryColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppConstants.authRoute);
    }
  }

  void _skipToAuth() {
    context.go(AppConstants.authRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 頂部跳過按鈕
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipToAuth,
                    child: const Text(
                      '跳過',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 頁面內容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // 底部導航
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 頁面指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 下一步按鈕
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? '開始體驗' : '下一步',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圖標
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5), duration: 600.ms)
            .then()
            .shimmer(duration: 2000.ms, color: page.color.withOpacity(0.3)),
          
          const SizedBox(height: 48),
          
          // 標題
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // 副標題
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
          
          const SizedBox(height: 24),
          
          // 描述
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? _pages[_currentPage].color 
            : AppTheme.textDisabledColor,
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate()
      .scale(
        duration: 200.ms,
        curve: Curves.easeInOut,
      );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
} 