import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import '../../core/ui/ui_bug_fixes.dart';

// Story 數據模型
class Story {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isViewed;
  final int viewCount;
  final List<String> viewers;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.isViewed = false,
    this.viewCount = 0,
    this.viewers = const [],
  });
}

// 模擬 Stories 數據
final sampleStories = [
  Story(
    id: '1',
    userId: '1',
    userName: '小雅',
    userAvatar: '👩‍🦰',
    content: '今天去了很棒的咖啡廳！☕',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    viewCount: 15,
    viewers: ['user1', 'user2', 'user3'],
  ),
  Story(
    id: '2',
    userId: '2',
    userName: '志明',
    userAvatar: '👨‍💻',
    content: '新項目上線了！🚀',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    viewCount: 8,
    viewers: ['user1', 'user4'],
  ),
  Story(
    id: '3',
    userId: '3',
    userName: '美玲',
    userAvatar: '🧘‍♀️',
    content: '晨間瑜伽讓我充滿活力 🧘‍♀️',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    viewCount: 23,
    viewers: ['user1', 'user2', 'user5'],
  ),
];

class EnhancedStoriesPage extends ConsumerWidget {
  const EnhancedStoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMyStorySection(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('📖 朋友動態'),
                  const SizedBox(height: AppSpacing.md),
                  _buildStoriesList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: UIBugFixes.safeFloatingActionButton(
        onPressed: () => _createStory(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        heroTag: 'stories_fab',
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
        borderRadius: AppBorderRadius.bottomOnly,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: const Icon(
                Icons.auto_stories,
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
                    'Stories 動態',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  Text(
                    '分享你的精彩瞬間',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () => _createStory(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyStorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📱 我的動態',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          onTap: () => _createStory(context),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '創建 Story',
                      style: AppTextStyles.h6,
                    ),
                    Text(
                      '分享你的生活瞬間',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4,
    );
  }

  Widget _buildStoriesList(BuildContext context) {
    if (sampleStories.isEmpty) {
      return const AppEmptyState(
        icon: Icons.auto_stories,
        title: '暫無動態',
        subtitle: '你的配對對象還沒有發布動態',
        actionText: '創建第一個 Story',
      );
    }

    return Column(
      children: sampleStories.map((story) => _buildStoryItem(context, story)).toList(),
    );
  }

  Widget _buildStoryItem(BuildContext context, Story story) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _viewStory(context, story),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用戶信息
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: story.isViewed 
                      ? LinearGradient(colors: [Colors.grey, Colors.grey.shade300])
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: story.isViewed ? Colors.grey : AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    story.userAvatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.userName,
                      style: AppTextStyles.h6,
                    ),
                    Text(
                      _formatTime(story.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: AppColors.textSecondary,
                onPressed: () => _showStoryOptions(context, story),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Story 內容
          Text(
            story.content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // 互動信息
          Row(
            children: [
              const Icon(
                Icons.visibility,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${story.viewCount} 次查看',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (!story.isViewed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${difference.inDays} 天前';
    }
  }

  void _createStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Text(
              '創建 Story',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // 內容輸入
            const AppTextField(
              hint: '分享你的想法...',
              maxLines: 5,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 選項
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '添加照片',
                    onPressed: () {},
                    type: AppButtonType.outline,
                    icon: Icons.photo,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: '添加位置',
                    onPressed: () {},
                    type: AppButtonType.outline,
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 隱私設置
            AppCard(
              backgroundColor: AppColors.info.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '誰可以看到',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '所有配對對象',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 發布按鈕
            AppButton(
              text: '發布 Story',
              onPressed: () {
                Navigator.pop(context);
                _showSuccessMessage(context);
              },
              isFullWidth: true,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }

  void _viewStory(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewPage(story: story),
      ),
    );
  }

  void _showStoryOptions(BuildContext context, Story story) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('查看 Story'),
              onTap: () {
                Navigator.pop(context);
                _viewStory(context, story);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('舉報'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Story 發布成功！'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }
}

// Story 查看頁面
class StoryViewPage extends StatefulWidget {
  final Story story;

  const StoryViewPage({super.key, required this.story});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startStoryTimer();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  void _startStoryTimer() {
    _progressController.forward().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            // 左側點擊 - 上一個故事
            Navigator.pop(context);
          } else {
            // 右側點擊 - 下一個故事
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            // 背景內容
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.9),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.story.userAvatar,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        widget.story.content,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 頂部進度條
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
              ),
            ),
            
            // 頂部用戶信息
            Positioned(
              top: MediaQuery.of(context).padding.top + 40,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.story.userAvatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.userName,
                          style: AppTextStyles.h6.copyWith(color: Colors.white),
                        ),
                        Text(
                          _formatTime(widget.story.createdAt),
                          style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 底部操作區
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      ),
                      child: Text(
                        '回覆 ${widget.story.userName}...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        // 點讚功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已點讚！')),
                        );
                      },
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${difference.inDays} 天前';
    }
  }
} 