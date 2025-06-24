import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/features/social_feed/pages/enhanced_social_feed_page.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase 初始化失敗: $e');
  }
  
  runApp(SafeInteractionDemoApp());
}

class SafeInteractionDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore - 約會社交應用',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
      home: DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  @override
  _DemoHomePageState createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    EnhancedSocialFeedPage(),
    DemoSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}

// 演示設定頁面
class DemoSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '設定',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingCard(
              icon: Icons.person,
              title: '個人檔案',
              subtitle: '編輯您的個人信息',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.favorite,
              title: '配對偏好',
              subtitle: '設定您的理想對象',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.privacy_tip,
              title: '隱私設定',
              subtitle: '管理您的隱私偏好',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications,
              title: '通知設定',
              subtitle: '自定義通知偏好',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.security,
              title: '安全中心',
              subtitle: '查看安全報告和設定',
              onTap: () => _showSafetyInfo(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.block,
              title: '封鎖列表',
              subtitle: '管理被封鎖的用戶',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.help,
              title: '幫助與支援',
              subtitle: '獲取幫助和聯絡客服',
              onTap: () => _showComingSoon(context),
            ),
            SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.info,
              title: '關於 Amore',
              subtitle: '版本信息和服務條款',
              onTap: () => _showAbout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade900,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade400],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey.shade900,
        title: Text('即將推出', style: TextStyle(color: Colors.white)),
        content: Text(
          '此功能正在開發中，敬請期待！',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(color: Colors.pink.shade400)),
          ),
        ],
      ),
    );
  }

  void _showSafetyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.pink.shade400),
            SizedBox(width: 8),
            Text('安全機制', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amore 的三階段安全互動機制：',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              _buildSafetyPoint('1. 公開互動', '點讚、留言等安全的初步接觸'),
              _buildSafetyPoint('2. 聊天邀請', '需要雙方同意才能進入私聊'),
              _buildSafetyPoint('3. 私人聊天', '安全的一對一對話空間'),
              SizedBox(height: 12),
              Text(
                '保護措施：',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              _buildSafetyPoint('每日邀請限制', '防止垃圾邀請騷擾'),
              _buildSafetyPoint('邀請過期機制', '72小時自動過期'),
              _buildSafetyPoint('拒絕冷卻期', '24小時內不能重複邀請'),
              _buildSafetyPoint('舉報機制', '支持舉報不當行為'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('了解', style: TextStyle(color: Colors.pink.shade400)),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPoint(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: Colors.pink.shade400,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('關於 Amore', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amore - 安全約會社交應用',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text('版本：1.0.0 (測試版)', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              '致力於為用戶提供安全、真實的約會體驗',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('© 2024 Amore 團隊', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(color: Colors.pink.shade400)),
          ),
        ],
      ),
    );
  }
} 