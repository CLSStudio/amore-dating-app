import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../constants/app_constants.dart';

/// Amore 主應用程式
class AmoreApp extends ConsumerWidget {
  const AmoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 主題配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // 路由配置
      routerConfig: router,
      
      // 本地化配置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'HK'), // 繁體中文（香港）
        Locale('zh', 'TW'), // 繁體中文（台灣）
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'HK'),
      
      // 構建器
      builder: (context, child) {
        return MediaQuery(
          // 禁用系統字體縮放
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 主題模式提供者
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
}); 