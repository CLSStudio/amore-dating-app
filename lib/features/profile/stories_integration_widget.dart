import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import '../stories/enhanced_stories_page.dart';

class StoriesIntegrationWidget extends StatefulWidget {
  final List<String> stories;
  final bool isOwnProfile;
  final Function(List<String>) onStoriesChanged;

  const StoriesIntegrationWidget({
    super.key,
    required this.stories,
    required this.isOwnProfile,
    required this.onStoriesChanged,
  });

  @override
  State<StoriesIntegrationWidget> createState() => _StoriesIntegrationWidgetState();
}

class _StoriesIntegrationWidgetState extends State<StoriesIntegrationWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _storiesAnimationController;
  late AnimationController _createButtonAnimationController;
  
  late Animation<double> _storiesScaleAnimation;
  late Animation<double> _createButtonPulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _storiesAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _createButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _storiesScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _storiesAnimationController, curve: Curves.elasticOut),
    );

    _createButtonPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _createButtonAnimationController, curve: Curves.easeInOut),
    );

    _storiesAnimationController.forward();
    
    // 創建按鈕的脈衝動畫
    if (widget.isOwnProfile && widget.stories.isEmpty) {
      _createButtonAnimationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _storiesAnimationController.dispose();
    _createButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: AppSpacing.lg),
          if (widget.stories.isEmpty) 
            _buildEmptyStoriesState()
          else 
            _buildStoriesGrid(),
          const SizedBox(height: AppSpacing.lg),
          if (widget.isOwnProfile) _buildStoriesActions(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE91E63),
                const Color(0xFF9C27B0),
              ],
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: const Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stories 動態',
                style: AppTextStyles.h4,
              ),
              Text(
                widget.stories.isEmpty 
                    ? '暫無動態' 
                    : '${widget.stories.length} 個動態',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.isOwnProfile)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '可編輯',
              style: AppTextStyles.overline.copyWith(
                color: const Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyStoriesState() {
    return AnimatedBuilder(
      animation: _storiesAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _storiesScaleAnimation.value,
          child: AppCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE91E63).withOpacity(0.1),
                        const Color(0xFF9C27B0).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    size: 40,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.isOwnProfile ? '創建你的第一個 Story' : '暫無 Stories',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.isOwnProfile 
                      ? '分享你的精彩瞬間，讓其他人更了解你'
                      : '這個用戶還沒有發布任何 Stories',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.isOwnProfile) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AnimatedBuilder(
                    animation: _createButtonAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _createButtonPulseAnimation.value,
                        child: AppButton(
                          text: '創建 Story',
                          onPressed: _createFirstStory,
                          icon: Icons.add_circle,
                          type: AppButtonType.primary,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoriesGrid() {
    return AnimatedBuilder(
      animation: _storiesAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _storiesScaleAnimation.value,
          child: Column(
            children: [
              // 最新 Stories 預覽
              _buildLatestStoriesPreview(),
              const SizedBox(height: AppSpacing.lg),
              
              // Stories 統計卡片
              _buildStoriesStats(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLatestStoriesPreview() {
    final recentStories = widget.stories.take(3).toList();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '最新動態',
                style: AppTextStyles.h6,
              ),
              const Spacer(),
              TextButton(
                onPressed: _viewAllStories,
                child: Text(
                  '查看全部',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentStories.length,
              itemBuilder: (context, index) {
                return _buildStoryPreviewCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreviewCard(int index) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(
        right: index < widget.stories.length - 1 ? AppSpacing.md : 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE91E63).withOpacity(0.8),
            const Color(0xFF9C27B0).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Stack(
        children: [
          // 背景圖案
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Story 內容預覽
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 時間標記
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    '${index + 1}h',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Story 類型圖標
                Icon(
                  _getStoryTypeIcon(index),
                  color: Colors.white,
                  size: 24,
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Story 預覽文字
                Text(
                  _getStoryPreviewText(index),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 點擊遮罩
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                onTap: () => _viewStory(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.visibility,
            title: '總瀏覽',
            value: '${widget.stories.length * 15}',
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite,
            title: '獲讚',
            value: '${widget.stories.length * 8}',
            color: const Color(0xFFE91E63),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.reply,
            title: '回覆',
            value: '${widget.stories.length * 3}',
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return AppCard(
      backgroundColor: color.withOpacity(0.05),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stories 管理',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '創建 Story',
                  onPressed: _createStory,
                  icon: Icons.add_circle,
                  type: AppButtonType.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  text: '查看全部',
                  onPressed: _viewAllStories,
                  icon: Icons.auto_stories,
                  type: AppButtonType.outline,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFE91E63),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Stories 會在 24 小時後自動消失',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStoryTypeIcon(int index) {
    final icons = [
      Icons.photo_camera,
      Icons.videocam,
      Icons.text_fields,
      Icons.location_on,
      Icons.music_note,
    ];
    return icons[index % icons.length];
  }

  String _getStoryPreviewText(int index) {
    final previews = [
      '今天的咖啡☕',
      '美好的一天',
      '分享心情',
      '在中環',
      '喜歡的音樂',
    ];
    return previews[index % previews.length];
  }

  void _createFirstStory() {
    HapticFeedback.mediumImpact();
    _createButtonAnimationController.stop();
    _createStory();
  }

  void _createStory() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: const CreateStoryPage(),
      ),
    );
  }

  void _viewStory(int index) {
    HapticFeedback.lightImpact();
    // 查看特定 Story
  }

  void _viewAllStories() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedStoriesPage(),
      ),
    );
  }
}

// 創建 Story 頁面
class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedStoryType = 'text';
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 頂部指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // 標題
          Text(
            '創建 Story',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Story 類型選擇
          _buildStoryTypeSelector(),
          const SizedBox(height: AppSpacing.xl),
          
          // 內容輸入
          Expanded(
            child: _buildContentInput(),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 發布按鈕
          AppButton(
            text: '發布 Story',
            onPressed: _publishStory,
            icon: Icons.send,
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTypeSelector() {
    final storyTypes = [
      {'type': 'text', 'icon': Icons.text_fields, 'title': '文字'},
      {'type': 'photo', 'icon': Icons.photo_camera, 'title': '照片'},
      {'type': 'video', 'icon': Icons.videocam, 'title': '視頻'},
    ];

    return Row(
      children: storyTypes.map((type) {
        final isSelected = _selectedStoryType == type['type'];
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedStoryType = type['type'] as String);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [const Color(0xFFE91E63), const Color(0xFF9C27B0)],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.textTertiary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    type['title'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColors.textTertiary.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: '分享你的想法...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _publishStory() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('請輸入內容'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Story 發布成功！'),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 