import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_config.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/matching/screens/swipe_screen.dart';
import '../../features/matching/screens/matches_screen.dart';
import '../../features/chat/screens/conversation_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/premium/premium_screen.dart';

// 路由配置提供者
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: AppConfig.enableDebugLogs,
    initialLocation: AppConstants.splashRoute,
    
    routes: [
      // 啟動畫面
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 引導畫面
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // 認證相關路由
      GoRoute(
        path: AppConstants.authRoute,
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      
      // 主要應用區域
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // 首頁
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // 配對相關
          GoRoute(
            path: AppConstants.matchingRoute,
            name: 'matching',
            builder: (context, state) => const SwipeScreen(),
            routes: [
              GoRoute(
                path: 'matches',
                name: 'matches',
                builder: (context, state) => const MatchesScreen(),
              ),
            ],
          ),
          
          // 聊天相關
          GoRoute(
            path: AppConstants.chatRoute,
            name: 'chat',
            builder: (context, state) => const ConversationListScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                name: 'chat_detail',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatScreen(conversationId: conversationId);
                },
              ),
            ],
          ),
          
          // 個人檔案相關
          GoRoute(
            path: AppConstants.profileRoute,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit_profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'view/:userId',
                name: 'view_profile',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return ProfileScreen(userId: userId);
                },
              ),
            ],
          ),
          
          // 設定
          GoRoute(
            path: AppConstants.settingsRoute,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          
          // 付費功能
          GoRoute(
            path: AppConstants.premiumRoute,
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
        ],
      ),
    ],
    
    // 錯誤處理
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    
    // 重定向邏輯
    redirect: (context, state) {
      // 這裡可以添加認證檢查邏輯
      // 例如檢查用戶是否已登錄，是否需要引導等
      return null;
    },
  );
});

// 主要應用殼層，包含底部導航
class MainShell extends StatelessWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNavigation(),
    );
  }
}

// 底部導航組件
class MainBottomNavigation extends ConsumerWidget {
  const MainBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final currentRoute = router.routerDelegate.currentConfiguration.last.matchedLocation;
    
    int currentIndex = 0;
    switch (currentRoute) {
      case '/home':
        currentIndex = 0;
        break;
      case '/matching':
        currentIndex = 1;
        break;
      case '/chat':
        currentIndex = 2;
        break;
      case '/profile':
        currentIndex = 3;
        break;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            router.go('/home');
            break;
          case 1:
            router.go('/matching');
            break;
          case 2:
            router.go('/chat');
            break;
          case 3:
            router.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '首頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: '配對',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: '聊天',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }
}

// 錯誤畫面
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('發生錯誤'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '抱歉，發生了錯誤',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '未知錯誤',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首頁'),
            ),
          ],
        ),
      ),
    );
  }
} 