import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/discovery/presentation/pages/enhanced_discovery_page.dart';
import 'lib/features/profile/presentation/pages/enhanced_profile_setup_page.dart';
import 'lib/features/mbti/presentation/pages/mbti_test_page.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedUITestApp()));
}

class EnhancedUITestApp extends StatelessWidget {
  const EnhancedUITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore Enhanced UI Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UITestHomePage(),
      routes: {
        '/discovery': (context) => const EnhancedDiscoveryPage(),
        '/profile-setup': (context) => const EnhancedProfileSetupPage(),
        '/mbti-test': (context) => const MBTITestPage(),
      },
    );
  }
}

class UITestHomePage extends StatelessWidget {
  const UITestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Amore UI 測試',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎨 新的 UI 組件測試',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '測試我們為 Amore 應用開發的新界面組件',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 32),
            
            // 測試按鈕列表
            Expanded(
              child: ListView(
                children: [
                  _buildTestCard(
                    context,
                    title: '滑動配對界面',
                    description: '測試新的滑動配對功能，包含流暢動畫和美觀卡片',
                    icon: Icons.favorite,
                    color: const Color(0xFFE91E63),
                    route: '/discovery',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTestCard(
                    context,
                    title: '個人檔案設置',
                    description: '測試引導式的個人檔案設置流程',
                    icon: Icons.person_add,
                    color: const Color(0xFF2196F3),
                    route: '/profile-setup',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTestCard(
                    context,
                    title: 'MBTI 人格測試',
                    description: '測試 MBTI 測試界面和結果展示',
                    icon: Icons.psychology,
                    color: const Color(0xFF9C27B0),
                    route: '/mbti-test',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 功能狀態卡片
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF0284C7),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '開發狀態',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatusItem('✅ 滑動配對界面', '已完成'),
                        _buildStatusItem('✅ 個人檔案設置', '已完成'),
                        _buildStatusItem('✅ MBTI 測試系統', '已完成'),
                        _buildStatusItem('🔄 聊天系統', '開發中'),
                        _buildStatusItem('🔄 AI 愛情顧問', '開發中'),
                        _buildStatusItem('⏳ 安全功能', '計劃中'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 技術信息
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.code,
                              color: Color(0xFFDC2626),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '技術棧',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Flutter 3.32.0 - 跨平台開發框架\n'
                          '• Riverpod - 狀態管理\n'
                          '• Firebase - 後端服務\n'
                          '• Material Design 3 - UI 設計系統\n'
                          '• 自定義動畫和過渡效果',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB91C1C),
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF718096),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String feature, String status) {
    Color statusColor;
    switch (status) {
      case '已完成':
        statusColor = const Color(0xFF059669);
        break;
      case '開發中':
        statusColor = const Color(0xFFD97706);
        break;
      case '計劃中':
        statusColor = const Color(0xFF6B7280);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0369A1),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 