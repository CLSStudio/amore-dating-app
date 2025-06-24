import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入升級後的功能
import 'lib/features/chat/real_time_chat_page.dart';
import 'lib/features/matches/match_celebration_page.dart';
import 'lib/core/theme/app_design_system.dart';

void main() {
  runApp(const ProviderScope(child: EnhancedChatSystemDemo()));
}

class EnhancedChatSystemDemo extends StatelessWidget {
  const EnhancedChatSystemDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Chat System Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ChatSystemTestPage(),
    );
  }
}

class ChatSystemTestPage extends StatelessWidget {
  const ChatSystemTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '💬 Enhanced Chat System',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surface,
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
            
            // 測試功能區
            _buildSectionTitle('🚀 聊天系統功能測試'),
            _buildTestCard(
              '配對慶祝 → 聊天流程',
              'Match Celebration to Chat Flow',
              '完整的配對到聊天過渡體驗，包含MBTI兼容性信息',
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
              '直接聊天體驗',
              'Direct Chat Experience',
              '現代化聊天界面，MBTI信息，AI破冰話題',
              Icons.chat_bubble_rounded,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealTimeChatPage(
                    chatId: 'demo_chat_${DateTime.now().millisecondsSinceEpoch}',
                    otherUserId: 'demo_user',
                    otherUserName: '小雅',
                    otherUserPhoto: 'https://picsum.photos/400/400?random=1',
                    compatibilityInfo: UserCompatibilityInfo(
                      mbtiType: 'ENFP',
                      compatibilityScore: 92,
                      commonInterests: ['攝影', '旅行', '咖啡', '音樂'],
                      matchReason: '你們都是外向且富有創造力的人，有著相似的價值觀和興趣愛好',
                    ),
                  ),
                ),
              ),
            ),
            _buildTestCard(
              '不同兼容性聊天',
              'Different Compatibility Chat',
              '測試不同兼容性分數的聊天體驗',
              Icons.psychology,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealTimeChatPage(
                    chatId: 'demo_chat_2_${DateTime.now().millisecondsSinceEpoch}',
                    otherUserId: 'demo_user_2',
                    otherUserName: '志明',
                    otherUserPhoto: 'https://picsum.photos/400/400?random=3',
                    compatibilityInfo: UserCompatibilityInfo(
                      mbtiType: 'INTJ',
                      compatibilityScore: 75,
                      commonInterests: ['科技', '閱讀', '電影'],
                      matchReason: '你們在思維方式上有很好的互補性',
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 功能亮點說明
            _buildFeatureHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upgrade,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '聊天系統全面升級',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '統一UI/UX質量標準已實現',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildUpgradeStatItem('✨', '現代化設計'),
              _buildUpgradeStatItem('🧠', 'MBTI整合'),
              _buildUpgradeStatItem('🤖', 'AI破冰話題'),
              _buildUpgradeStatItem('🔄', '流暢過渡'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeStatItem(String icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
          color: AppColors.textPrimary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: AppColors.textTertiary.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.small,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureHighlights() {
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
                Icons.star,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '聊天系統功能亮點',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('🎨 現代化設計', '統一使用AppDesignSystem設計語言'),
          _buildFeatureItem('💬 智能氣泡', '漸變色聊天氣泡，更好的視覺層次'),
          _buildFeatureItem('🧠 MBTI整合', '聊天標題欄顯示兼容性分數和類型'),
          _buildFeatureItem('🤖 AI破冰話題', '個性化破冰話題建議面板'),
          _buildFeatureItem('📱 觸覺反饋', '所有交互都有適當的觸覺反饋'),
          _buildFeatureItem('🔄 流暢過渡', '從配對慶祝到聊天的無縫銜接'),
          _buildFeatureItem('⚡ 性能優化', '使用AnimatedBuilder避免不必要重建'),
          _buildFeatureItem('🎯 用戶體驗', '符合Gen Z和專業人士的使用習慣'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 