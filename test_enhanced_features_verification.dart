import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入升級後的核心功能
import 'lib/features/main_navigation/main_navigation.dart';
import 'lib/features/discovery/enhanced_swipe_experience.dart';
import 'lib/features/matches/enhanced_matches_page.dart';
import 'lib/features/matches/match_celebration_page.dart';
import 'lib/features/chat/enhanced_chat_list_page.dart';
import 'lib/features/chat/real_time_chat_page.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedFeaturesVerificationApp()));
}

class EnhancedFeaturesVerificationApp extends StatelessWidget {
  const EnhancedFeaturesVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore Enhanced Features Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'NotoSansTC',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
      ),
      home: const VerificationHomePage(),
    );
  }
}

class VerificationHomePage extends StatelessWidget {
  const VerificationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '🚀 Enhanced Features 驗證',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 升級摘要卡片
            _buildUpgradeSummaryCard(),
            const SizedBox(height: 20),
            
            // 核心功能測試區
            _buildSectionTitle('✅ 已升級的核心功能'),
            _buildTestCard(
              '滑動配對體驗',
              'Enhanced Swipe Experience',
              '流暢動畫、MBTI兼容性、約會模式標識',
              Icons.swipe,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnhancedSwipeExperience()),
              ),
            ),
            _buildTestCard(
              '配對管理頁面',
              'Enhanced Matches Page',
              '新配對、所有配對、統計面板、搜索篩選',
              Icons.favorite,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnhancedMatchesPage()),
              ),
            ),
            _buildTestCard(
              '聊天列表頁面',
              'Enhanced Chat List Page',
              'AI分析功能、實時聊天、未讀提醒、在線狀態',
              Icons.chat_bubble_outline,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnhancedChatListPage()),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 配對到聊天流程測試
            _buildSectionTitle('🔄 完善的配對到聊天流程'),
            _buildTestCard(
              '配對慶祝頁面',
              'Match Celebration → Real-time Chat',
              '彩紙動畫、兼容性分析、直接跳轉聊天',
              Icons.celebration,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchCelebrationPage(
                    matchedUserName: '小雅',
                    matchedUserImage: 'https://picsum.photos/400/400?random=1',
                    currentUserImage: 'https://picsum.photos/400/400?random=2',
                    compatibilityScore: 92,
                  ),
                ),
              ),
            ),
            _buildTestCard(
              '實時聊天頁面',
              'Real-time Chat Page',
              'AI分析、破冰話題、消息發送、觸覺反饋',
              Icons.chat,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RealTimeChatPage(
                    chatId: 'demo_chat',
                    otherUserId: 'demo_user',
                    otherUserName: '小雅',
                    otherUserPhoto: 'https://picsum.photos/400/400?random=1',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 主應用測試
            _buildSectionTitle('🏠 完整應用體驗'),
            _buildTestCard(
              '主導航應用',
              'Main Navigation with All Enhanced Features',
              '包含所有升級功能的完整應用體驗',
              Icons.apps,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 技術升級說明
            _buildTechnicalUpgradeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.rocket_launch,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            '升級完成！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '所有核心功能已升級為Enhanced版本',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUpgradeStatItem('3', '頁面升級'),
              _buildUpgradeStatItem('1', '流程完善'),
              _buildUpgradeStatItem('100%', '功能整合'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildTestCard(
    String title,
    String subtitle,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE91E63),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTechnicalUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.engineering,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '技術升級摘要',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTechItem('✅ 聊天系統', '從基本版ChatListPage升級到EnhancedChatListPage'),
          _buildTechItem('✅ 配對管理', '從基本版MatchesPage升級到EnhancedMatchesPage'),
          _buildTechItem('✅ 配對流程', '配對慶祝頁面直接跳轉到實時聊天'),
          _buildTechItem('✅ 統一設計', '所有頁面使用AppDesignSystem統一設計語言'),
          _buildTechItem('✅ 狀態管理', '使用Riverpod進行響應式狀態管理'),
          _buildTechItem('✅ 觸覺反饋', '配對和聊天操作增加HapticFeedback'),
        ],
      ),
    );
  }

  Widget _buildTechItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 