import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/profile/presentation/pages/profile_setup_page.dart';
import '../../features/mbti/presentation/pages/mbti_test_page.dart';
import '../../features/mbti/presentation/pages/mbti_result_page.dart';
import '../../features/home/presentation/pages/main_page.dart';
import '../../features/discovery/presentation/pages/discovery_page.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// 路由路徑常量
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String mbtiTest = '/mbti-test';
  static const String main = '/main';
  static const String chat = '/chat';
  static const String settings = '/settings';
}

/// 應用程式路由配置提供者
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    routes: [
      // 歡迎和認證路由
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // 個人檔案設置路由
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      
      // MBTI 測試路由
      GoRoute(
        path: '/mbti-test',
        name: 'mbti-test',
        builder: (context, state) => const MBTITestPage(),
      ),
      GoRoute(
        path: '/mbti-result',
        name: 'mbti-result',
        builder: (context, state) {
          final mbtiType = state.extra as String?;
          return MBTIResultPage(mbtiType: mbtiType ?? 'ENFP');
        },
      ),
      
      // 主應用路由
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainPage(),
        routes: [
          GoRoute(
            path: '/discovery',
            name: 'discovery',
            builder: (context, state) => const DiscoveryPage(),
          ),
          GoRoute(
            path: '/matches',
            name: 'matches',
            builder: (context, state) => const MatchesPage(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
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
              '頁面未找到',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '路徑: ${state.uri.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('返回首頁'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// 啟動頁面
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 模擬初始化過程
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // 檢查用戶狀態並導航到適當的頁面
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Amore',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '深度連結的約會體驗',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 佔位頁面（用於開發階段）
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '此頁面正在開發中',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('返回首頁'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 錯誤頁面
class ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('錯誤'),
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
            const Text(
              '頁面載入失敗',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '未知錯誤',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('返回首頁'),
            ),
          ],
        ),
      ),
    );
  }
} 