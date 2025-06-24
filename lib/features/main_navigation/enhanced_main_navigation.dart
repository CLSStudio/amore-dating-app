import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入所有功能頁面
import '../discovery/enhanced_swipe_page.dart';
import '../chat/chat_list_page.dart';
import '../stories/stories_feature.dart';
import '../video_call/video_call_feature.dart';
import '../premium/premium_subscription.dart';
import '../notifications/push_notification_system.dart';
import '../social_media/social_media_integration.dart';
import '../events/event_recommendation_system.dart';
import '../relationship_tracking/relationship_success_tracking.dart';
import '../profile/enhanced_profile_page.dart';
import '../../core/ui/ui_bug_fixes.dart';

class EnhancedMainNavigation extends ConsumerStatefulWidget {
  const EnhancedMainNavigation({super.key});

  @override
  ConsumerState<EnhancedMainNavigation> createState() => _EnhancedMainNavigationState();
}

class _EnhancedMainNavigationState extends ConsumerState<EnhancedMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.explore,
      activeIcon: Icons.explore,
      label: '探索',
      page: const EnhancedSwipePage(),
    ),
    NavigationItem(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: '配對',
      page: const MatchesPage(),
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: '聊天',
      page: const ChatListPage(),
    ),
    NavigationItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      label: 'Stories',
      page: const StoriesPage(),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '個人',
      page: const EnhancedProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 0,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ..._navigationItems.take(2).map((item) {
                  final index = _navigationItems.indexOf(item);
                  return _buildNavItem(item, index);
                }),
                const SizedBox(width: 60), // Space for FAB
                ..._navigationItems.skip(2).map((item) {
                  final index = _navigationItems.indexOf(item);
                  return _buildNavItem(item, index);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? const Color(0xFFE91E63) : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? const Color(0xFFE91E63) : Colors.grey[600],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: UIBugFixes.safeFloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: const Color(0xFFE91E63),
        elevation: 8,
        heroTag: 'main_nav_fab',
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // 用戶頭像區域
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '用戶名稱',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Premium 會員',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24),
              
              // 功能選單
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                                         _buildDrawerItem(
                       icon: Icons.videocam,
                       title: '視頻通話',
                       onTap: () => _navigateToVideoCallDemo(),
                     ),
                    _buildDrawerItem(
                      icon: Icons.diamond,
                      title: 'Premium 訂閱',
                      onTap: () => _navigateToPage(const PremiumSubscriptionPage()),
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications,
                      title: '通知設置',
                      onTap: () => _navigateToPage(const NotificationsPage()),
                    ),
                    _buildDrawerItem(
                      icon: Icons.share,
                      title: '社交媒體',
                      onTap: () => _navigateToPage(const SocialMediaIntegrationPage()),
                    ),
                    _buildDrawerItem(
                      icon: Icons.event,
                      title: '活動推薦',
                      onTap: () => _navigateToPage(const EventRecommendationPage()),
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics,
                      title: '關係追蹤',
                      onTap: () => _navigateToPage(const RelationshipTrackingPage()),
                    ),
                    const Divider(color: Colors.white24),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: '設置',
                      onTap: () => _navigateToSettings(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.help,
                      title: '幫助中心',
                      onTap: () => _navigateToHelp(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: '登出',
                      onTap: () => _showLogoutDialog(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '快速操作',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionItem(
                    icon: Icons.camera_alt,
                    label: '發布 Story',
                    onTap: () => _navigateToCreateStory(),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.videocam,
                    label: '視頻通話',
                    onTap: () => _navigateToVideoCall(),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.event,
                    label: '尋找活動',
                    onTap: () => _navigateToEvents(),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.favorite,
                    label: '超級喜歡',
                    onTap: () => _useSuperLike(),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.trending_up,
                    label: 'Boost',
                    onTap: () => _useBoost(),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.analytics,
                    label: '關係分析',
                    onTap: () => _navigateToRelationshipAnalysis(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFE91E63),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE91E63),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 導航方法
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateToSettings() {
    // 實現設置頁面導航
  }

  void _navigateToHelp() {
    // 實現幫助中心導航
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 實現登出邏輯
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateStory() {
    // 實現創建 Story 導航
  }

  void _navigateToVideoCall() {
    _navigateToVideoCallDemo();
  }

  void _navigateToVideoCallDemo() {
    // 創建示例通話對象
    final demoCall = VideoCall(
      id: 'demo_call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: 'current_user',
      receiverId: 'demo_user',
      otherUserName: '示例用戶',
      otherUserAvatar: '👤',
      type: CallType.video,
      status: CallStatus.connected,
      startTime: DateTime.now(),
      duration: Duration.zero,
    );
    
    _navigateToPage(VideoCallPage(call: demoCall));
  }

  void _navigateToEvents() {
    _navigateToPage(const EventRecommendationPage());
  }

  void _useSuperLike() {
    // 實現超級喜歡功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('超級喜歡已使用！')),
    );
  }

  void _useBoost() {
    // 實現 Boost 功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Boost 已啟動！')),
    );
  }

  void _navigateToRelationshipAnalysis() {
    _navigateToPage(const RelationshipTrackingPage());
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

// 臨時頁面組件
class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的配對'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('配對頁面 - 待實現'),
      ),
    );
  }
} 