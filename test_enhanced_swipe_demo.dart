import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/discovery/enhanced_swipe_experience.dart';
import 'lib/features/matches/match_celebration_page.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedSwipeDemoApp()));
}

class EnhancedSwipeDemoApp extends StatelessWidget {
  const EnhancedSwipeDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore Enhanced Swipe Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: const SwipeDemoHomePage(),
      routes: {
        '/enhanced_swipe': (context) => const EnhancedSwipeExperience(),
        '/match_celebration': (context) => const MatchCelebrationPage(
              matchedUserName: 'Sarah Chen',
              matchedUserImage: 'https://picsum.photos/400/600?random=1',
              currentUserImage: 'https://picsum.photos/400/600?random=10',
              compatibilityScore: 92,
            ),
      },
    );
  }
}

class SwipeDemoHomePage extends StatelessWidget {
  const SwipeDemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Amore Enhanced Features'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // 標題
            const Text(
              '✨ 全新增強功能預覽',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Amore 為您帶來前所未有的約會體驗',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),
            
            // 功能卡片
            _buildFeatureCard(
              context,
              icon: Icons.swipe,
              title: '增強滑動體驗',
              description: '流暢動畫、兼容性分析、智能匹配\n讓每次滑動都充滿驚喜',
              onTap: () => Navigator.pushNamed(context, '/enhanced_swipe'),
              color: Colors.blue,
            ),
            
            const SizedBox(height: 24),
            
            _buildFeatureCard(
              context,
              icon: Icons.favorite,
              title: '配對慶祝動畫',
              description: '精美的配對成功慶祝\n彩紙飛舞、兼容性分析展示',
              onTap: () => Navigator.pushNamed(context, '/match_celebration'),
              color: Colors.pink,
            ),
            
            const SizedBox(height: 60),
            
            // 特色說明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '新功能亮點',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Column(
                    children: [
                      _buildFeatureHighlight('🎨', '視覺設計升級', '現代化UI設計，流暢動畫效果'),
                      const SizedBox(height: 12),
                      _buildFeatureHighlight('🧠', 'AI智能匹配', 'MBTI分析，性格兼容性評估'),
                      const SizedBox(height: 12),
                      _buildFeatureHighlight('💫', '互動體驗', '觸覺反饋，慶祝動畫，沉浸體驗'),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 底部說明
            Text(
              '這些功能展示了 Amore 的核心體驗\n更多精彩功能正在開發中...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(String emoji, String title, String description) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 