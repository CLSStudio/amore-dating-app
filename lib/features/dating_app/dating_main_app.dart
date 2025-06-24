import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// 導入約會應用核心功能
import '../discovery/enhanced_swipe_page.dart';
import '../chat/enhanced_chat_list_page.dart';
import '../matches/enhanced_matches_page.dart';
import '../profile/enhanced_profile_page.dart';
import '../stories/stories_feature.dart';
import '../ai/ai_hub_page.dart';

class DatingMainApp extends ConsumerStatefulWidget {
  const DatingMainApp({super.key});

  @override
  ConsumerState<DatingMainApp> createState() => _DatingMainAppState();
}

class _DatingMainAppState extends ConsumerState<DatingMainApp>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  final List<DatingTab> _tabs = [
    DatingTab(
      icon: Icons.explore,
      activeIcon: Icons.explore,
      label: '探索',
      page: const EnhancedSwipePage(),
    ),
    DatingTab(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: '配對',
      page: const EnhancedMatchesPage(),
    ),
    DatingTab(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: '聊天',
      page: const EnhancedChatListPage(),
    ),
    DatingTab(
      icon: Icons.psychology,
      activeIcon: Icons.psychology,
      label: 'AI',
      page: const AIHubPage(),
    ),
    DatingTab(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '我的',
      page: const EnhancedProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.medium,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.xl),
          topRight: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.xl),
          topRight: Radius.circular(AppBorderRadius.xl),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: _tabs.map((tab) {
            final isActive = _tabs.indexOf(tab) == _currentIndex;
            return BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: AppAnimations.fast,
                child: Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  key: ValueKey(isActive),
                  size: 24,
                ),
              ),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppBorderRadius.circular),
          boxShadow: AppShadows.floating,
        ),
        child: FloatingActionButton(
          onPressed: _showQuickActions,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.bolt,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppAnimations.medium,
      curve: AppAnimations.defaultCurve,
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              '⚡ 快速操作',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // 快速操作按鈕
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: [
                _buildQuickActionItem(
                  icon: Icons.favorite,
                  label: '超級喜歡',
                  color: AppColors.superLike,
                  onTap: () => _useSuperLike(),
                ),
                _buildQuickActionItem(
                  icon: Icons.flash_on,
                  label: 'Boost',
                  color: AppColors.boost,
                  onTap: () => _useBoost(),
                ),
                _buildQuickActionItem(
                  icon: Icons.camera_alt,
                  label: '發布 Story',
                  color: AppColors.secondary,
                  onTap: () => _createStory(),
                ),
                _buildQuickActionItem(
                  icon: Icons.videocam,
                  label: '視頻通話',
                  color: AppColors.info,
                  onTap: () => _startVideoCall(),
                ),
                _buildQuickActionItem(
                  icon: Icons.event,
                  label: '尋找活動',
                  color: AppColors.warning,
                  onTap: () => _findEvents(),
                ),
                _buildQuickActionItem(
                  icon: Icons.analytics,
                  label: '關係分析',
                  color: AppColors.success,
                  onTap: () => _viewAnalytics(),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 快速操作方法
  void _useSuperLike() {
    _showActionFeedback('💙 超級喜歡已使用！');
  }

  void _useBoost() {
    _showActionFeedback('⚡ Boost 已啟動！你的個人檔案將被更多人看到');
  }

  void _createStory() {
    _showActionFeedback('📸 Story 創建功能即將推出！');
  }

  void _startVideoCall() {
    _showActionFeedback('📹 視頻通話功能即將推出！');
  }

  void _findEvents() {
    _showActionFeedback('🎪 活動推薦功能即將推出！');
  }

  void _viewAnalytics() {
    _showActionFeedback('📊 關係分析功能即將推出！');
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: AppSpacing.pagePadding,
      ),
    );
  }
}

class DatingTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  DatingTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
} 