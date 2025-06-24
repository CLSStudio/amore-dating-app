import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

// 核心主題和組件
import 'lib/core/theme/app_design_system.dart';
import 'lib/shared/widgets/app_components.dart';

// 主導航
import 'lib/features/main_navigation/main_navigation.dart';

// 認證系統
import 'lib/features/auth/auth_page.dart';
import 'lib/features/auth/enhanced_auth_page.dart';

// 引導流程
import 'lib/features/onboarding/onboarding_page.dart';

// 個人檔案系統
import 'lib/features/profile/enhanced_profile_page.dart';
import 'lib/features/profile/photo_management_widget.dart';

// Discovery和配對
import 'lib/features/discovery/enhanced_swipe_experience.dart';
import 'lib/features/discovery/enhanced_swipe_page.dart';
import 'lib/features/discovery/swipe_page.dart';

// 配對管理
import 'lib/features/matches/enhanced_matches_page.dart';
import 'lib/features/matches/match_celebration_page.dart';

// 聊天系統
import 'lib/features/chat/real_time_chat_page.dart';
import 'lib/features/chat/enhanced_chat_list_page.dart';
import 'lib/features/chat/ai_chat_assistant.dart';

// Stories功能
import 'lib/features/stories/enhanced_stories_viewer.dart';
import 'lib/features/stories/story_creator.dart';

// AI系統
import 'lib/features/ai/enhanced_ai_consultant.dart';
import 'lib/features/ai/ai_love_consultant_page.dart';
import 'lib/features/ai/ai_personalization_engine.dart';
import 'lib/features/ai/revolutionary_ai_features.dart';

// MBTI系統
import 'lib/features/mbti/enhanced_mbti_test_page.dart';
import 'lib/features/mbti/mbti_results_page.dart';
import 'lib/features/mbti/romantic_mbti_test.dart';
import 'lib/features/mbti/compatibility_analysis_page.dart';

// 約會模式
import 'lib/features/dating/dating_mode_selection_page.dart';

// Premium系統
import 'lib/features/premium/premium_subscription.dart';

// 視頻通話
import 'lib/features/video_call/video_call_page.dart';

// 其他功能
import 'lib/features/notifications/notification_center.dart';
import 'lib/features/safety/safety_center.dart';
import 'lib/features/analytics/user_analytics_dashboard.dart';
import 'lib/features/gamification/achievements_page.dart';
import 'lib/features/events/event_discovery_page.dart';

void main() {
  runApp(const ProviderScope(child: AmoreFullTestApp()));
}

class AmoreFullTestApp extends StatelessWidget {
  const AmoreFullTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore 完整版測試',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AmoreFeatureExplorer(),
    );
  }
}

class AmoreFeatureExplorer extends StatefulWidget {
  const AmoreFeatureExplorer({super.key});

  @override
  State<AmoreFeatureExplorer> createState() => _AmoreFeatureExplorerState();
}

class _AmoreFeatureExplorerState extends State<AmoreFeatureExplorer>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 25個核心功能清單
  final List<FeatureItem> _allFeatures = [
    // 1. 認證系統 (2個功能)
    FeatureItem('認證登入', '用戶註冊登入系統', Icons.login, () => const AuthPage()),
    FeatureItem('增強認證', '完整認證流程', Icons.security, () => const EnhancedAuthPage()),
    
    // 2. 引導系統 (1個功能)
    FeatureItem('用戶引導', '新用戶引導流程', Icons.assistant, () => const OnboardingPage()),
    
    // 3. 主導航 (1個功能)
    FeatureItem('主導航', '完整應用導航', Icons.navigation, () => const MainNavigation()),
    
    // 4. 個人檔案 (2個功能)
    FeatureItem('個人檔案', '完整檔案管理', Icons.person, () => const EnhancedProfilePage()),
    FeatureItem('照片管理', '照片上傳編輯', Icons.photo_library, () => PhotoManagementWidget(photos: const ['demo1', 'demo2'], isEditable: true, onPhotosChanged: (_) {})),
    
    // 5. Discovery配對 (3個功能)
    FeatureItem('滑動配對', '基本滑動功能', Icons.swipe, () => const SwipePage()),
    FeatureItem('增強滑動', '完整滑動體驗', Icons.touch_app, () => const EnhancedSwipePage()),
    FeatureItem('智能配對', 'AI增強配對', Icons.auto_awesome, () => const EnhancedSwipeExperience()),
    
    // 6. 配對管理 (2個功能)
    FeatureItem('配對列表', '配對管理頁面', Icons.favorite, () => const EnhancedMatchesPage()),
    FeatureItem('配對慶祝', '配對成功動畫', Icons.celebration, () => MatchCelebrationPage(matchedUser: _getDemoUser())),
    
    // 7. 聊天系統 (3個功能)
    FeatureItem('聊天列表', '所有對話列表', Icons.chat, () => const EnhancedChatListPage()),
    FeatureItem('即時聊天', '實時對話功能', Icons.message, () => RealTimeChatPage(chatId: 'demo_chat', recipientName: '小雅', recipientAvatar: '👩‍🦰')),
    FeatureItem('AI聊天助手', '智能聊天輔助', Icons.smart_toy, () => const AIChatAssistant()),
    
    // 8. Stories功能 (2個功能)
    FeatureItem('Stories查看', '24小時動態查看', Icons.auto_stories, () => const EnhancedStoriesViewer(userId: 'demo_user')),
    FeatureItem('Stories創建', '動態內容創建', Icons.add_circle, () => const StoryCreator()),
    
    // 9. AI系統 (4個功能)
    FeatureItem('AI諮詢師', '專業愛情顧問', Icons.psychology, () => const EnhancedAIConsultant()),
    FeatureItem('AI愛情助手', 'AI約會指導', Icons.favorite_border, () => const AILoveConsultantPage()),
    FeatureItem('個性化引擎', 'AI個性化推薦', Icons.tune, () => const AIPersonalizationEngine()),
    FeatureItem('革命性AI', '前沿AI功能', Icons.rocket_launch, () => const RevolutionaryAIFeatures()),
    
    // 10. MBTI系統 (4個功能)
    FeatureItem('MBTI測試', '性格類型測試', Icons.quiz, () => const EnhancedMBTITestPage()),
    FeatureItem('MBTI結果', '測試結果頁面', Icons.analytics, () => const MBTIResultsPage()),
    FeatureItem('浪漫MBTI', '愛情取向測試', Icons.favorite_border, () => const RomanticMBTITest()),
    FeatureItem('兼容性分析', 'MBTI配對分析', Icons.people, () => const CompatibilityAnalysisPage()),
    
    // 11. 約會模式 (1個功能)
    FeatureItem('約會模式', '6種約會模式', Icons.mode_edit, () => const DatingModeSelectionPage()),
    
    // 12. Premium系統 (1個功能)
    FeatureItem('Premium會員', '訂閱付費系統', Icons.diamond, () => const PremiumSubscriptionPage()),
    
    // 13. 視頻通話 (1個功能)
    FeatureItem('視頻通話', '一對一視頻', Icons.video_call, () => VideoCallPage(callId: 'demo_call', recipientName: '小雅', recipientAvatar: '👩‍🦰')),
    
    // 14. 其他核心功能 (3個功能)
    FeatureItem('通知中心', '消息通知管理', Icons.notifications, () => const NotificationCenter()),
    FeatureItem('安全中心', '用戶安全保護', Icons.shield, () => const SafetyCenter()),
    FeatureItem('數據分析', '用戶行為分析', Icons.bar_chart, () => const UserAnalyticsDashboard()),
    FeatureItem('成就系統', '遊戲化元素', Icons.emoji_events, () => const AchievementsPage()),
    FeatureItem('活動發現', '本地活動推薦', Icons.event, () => const EventDiscoveryPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllFeatures(),
                  _buildCoreFeatures(),
                  _buildAIFeatures(),
                  _buildSocialFeatures(),
                  _buildPremiumFeatures(),
                  _buildAnalyticsFeatures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amore 完整版測試',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '25個核心功能 • 100%功能覆蓋',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Row(
              children: [
                _buildStatCard('核心功能', '25', Icons.apps),
                _buildStatCard('模組數量', '30+', Icons.widgets),
                _buildStatCard('代碼行數', '50K+', Icons.code),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '全部功能', icon: Icon(Icons.apps, size: 20)),
          Tab(text: '核心', icon: Icon(Icons.star, size: 20)),
          Tab(text: 'AI', icon: Icon(Icons.psychology, size: 20)),
          Tab(text: '社交', icon: Icon(Icons.people, size: 20)),
          Tab(text: 'Premium', icon: Icon(Icons.diamond, size: 20)),
          Tab(text: '分析', icon: Icon(Icons.analytics, size: 20)),
        ],
      ),
    );
  }

  Widget _buildAllFeatures() {
    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _allFeatures.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(_allFeatures[index], index + 1);
      },
    );
  }

  Widget _buildCoreFeatures() {
    final coreFeatures = _allFeatures.where((f) => 
      f.title.contains('導航') || 
      f.title.contains('檔案') || 
      f.title.contains('配對') || 
      f.title.contains('聊天')
    ).toList();
    
    return _buildFeatureGrid(coreFeatures);
  }

  Widget _buildAIFeatures() {
    final aiFeatures = _allFeatures.where((f) => 
      f.title.contains('AI') || 
      f.title.contains('MBTI') || 
      f.title.contains('智能')
    ).toList();
    
    return _buildFeatureGrid(aiFeatures);
  }

  Widget _buildSocialFeatures() {
    final socialFeatures = _allFeatures.where((f) => 
      f.title.contains('Stories') || 
      f.title.contains('聊天') || 
      f.title.contains('視頻') || 
      f.title.contains('活動')
    ).toList();
    
    return _buildFeatureGrid(socialFeatures);
  }

  Widget _buildPremiumFeatures() {
    final premiumFeatures = _allFeatures.where((f) => 
      f.title.contains('Premium') || 
      f.title.contains('增強') || 
      f.title.contains('革命性')
    ).toList();
    
    return _buildFeatureGrid(premiumFeatures);
  }

  Widget _buildAnalyticsFeatures() {
    final analyticsFeatures = _allFeatures.where((f) => 
      f.title.contains('分析') || 
      f.title.contains('通知') || 
      f.title.contains('安全') || 
      f.title.contains('成就')
    ).toList();
    
    return _buildFeatureGrid(analyticsFeatures);
  }

  Widget _buildFeatureGrid(List<FeatureItem> features) {
    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final globalIndex = _allFeatures.indexOf(features[index]) + 1;
        return _buildFeatureCard(features[index], globalIndex);
      },
    );
  }

  Widget _buildFeatureCard(FeatureItem feature, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => feature.page()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          boxShadow: AppShadows.medium,
        ),
        child: Column(
          children: [
            // 功能編號
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.xl),
                  topRight: Radius.circular(AppBorderRadius.xl),
                ),
              ),
              child: Text(
                '功能 #$index',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      child: Icon(
                        feature.icon,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    Text(
                      feature.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      feature.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 示例用戶數據
  static Map<String, dynamic> _getDemoUser() {
    return {
      'name': '小雅',
      'age': 26,
      'avatar': '👩‍🦰',
      'bio': '喜歡旅行和攝影的女生',
      'mbtiType': 'ENFP',
      'compatibility': 89,
    };
  }
}

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() page;

  FeatureItem(this.title, this.subtitle, this.icon, this.page);
} 