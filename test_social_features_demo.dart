import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/social_feed/pages/social_feed_page.dart';
import 'lib/features/social_feed/pages/topics_page.dart';
import 'lib/core/constants/app_colors.dart';

void main() {
  runApp(const ProviderScope(child: SocialFeaturesDemo()));
}

class SocialFeaturesDemo extends StatelessWidget {
  const SocialFeaturesDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore 社交功能展示',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: AppColors.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PingFang SC',
      ),
      home: const SocialFeaturesHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SocialFeaturesHomePage extends StatefulWidget {
  const SocialFeaturesHomePage({Key? key}) : super(key: key);

  @override
  State<SocialFeaturesHomePage> createState() => _SocialFeaturesHomePageState();
}

class _SocialFeaturesHomePageState extends State<SocialFeaturesHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const SocialFeedPage(),
    const TopicsPage(),
    const FeaturesOverviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: '動態',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '話題',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '功能說明',
          ),
        ],
      ),
    );
  }
}

class FeaturesOverviewPage extends StatelessWidget {
  const FeaturesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Amore 社交功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildFeatureSection(
              '📱 社交動態功能',
              '類似朋友圈/Instagram的動態分享',
              [
                '✅ 發布照片、視頻和文字動態',
                '✅ 關注其他用戶，查看關注動態',
                '✅ 熱門動態推薦',
                '✅ 點讚、瀏覽統計',
                '✅ 標籤和位置功能',
                '✅ 只能關注，不能評論或私信',
                '✅ 提升熱度排行榜分數',
              ],
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              '💬 話題討論功能',
              '創建和參與各種話題討論',
              [
                '✅ 創建自定義話題',
                '✅ 12個分類：約會、生活、興趣等',
                '✅ 話題內發帖討論',
                '✅ 熱門話題推薦',
                '✅ 搜索和篩選功能',
                '✅ 置頂和精選話題',
                '✅ 參與討論提升熱度分數',
              ],
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              '🔥 熱度排行榜整合',
              '社交活動直接影響用戶熱度',
              [
                '📈 發布動態：+5分',
                '❤️ 獲得點讚：+5分',
                '👁️ 動態被瀏覽：+1分',
                '🏷️ 創建話題：+10分',
                '💬 話題發帖：+3分',
                '👍 話題帖子被讚：+3分',
                '📊 實時更新排行榜',
              ],
            ),
            const SizedBox(height: 24),
            _buildTechnicalDetails(),
            const SizedBox(height: 24),
            _buildCompetitiveAdvantage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎉 全新社交功能',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '讓 Amore 不只是約會應用，更是社交平台',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '提升用戶參與度 • 增加平台黏性 • 豐富社交體驗',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(String title, String subtitle, List<String> features) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '技術實現',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🔧 Flutter + Riverpod 狀態管理\n'
            '🔥 Firebase Firestore 實時數據庫\n'
            '📁 Firebase Storage 媒體存儲\n'
            '🔐 Firebase Auth 用戶認證\n'
            '📱 響應式 UI 設計\n'
            '⚡ 實時數據同步\n'
            '🎨 Material Design 3 設計語言',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitiveAdvantage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '競爭優勢',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🎯 與熱度排行榜深度整合\n'
            '🚫 無評論功能，避免負面互動\n'
            '👥 關注機制，建立社交網絡\n'
            '🏷️ 話題分類，精準內容定位\n'
            '📊 數據驅動的用戶參與度\n'
            '💡 獨特的約會應用社交模式\n'
            '🔒 安全可控的社交環境',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
} 