import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// Story 數據模型
class StoryItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final StoryType type;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<StoryReaction> reactions;
  final List<String> viewers;
  final bool isViewed;

  StoryItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.expiresAt,
    this.reactions = const [],
    this.viewers = const [],
    this.isViewed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  String get timeRemainingText {
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

enum StoryType {
  text,
  image,
  video,
  poll,
  question,
  music,
  location,
}

class StoryReaction {
  final String userId;
  final String userName;
  final String emoji;
  final DateTime timestamp;

  StoryReaction({
    required this.userId,
    required this.userName,
    required this.emoji,
    required this.timestamp,
  });
}

// Stories 狀態管理
final storiesViewerProvider = StateNotifierProvider<StoriesViewerNotifier, StoriesViewerState>((ref) {
  return StoriesViewerNotifier();
});

class StoriesViewerState {
  final List<StoryItem> stories;
  final int currentIndex;
  final bool isPlaying;
  final bool showReactions;
  final List<String> availableReactions;

  StoriesViewerState({
    this.stories = const [],
    this.currentIndex = 0,
    this.isPlaying = true,
    this.showReactions = false,
    this.availableReactions = const ['❤️', '😍', '😂', '😮', '😢', '👏'],
  });

  StoriesViewerState copyWith({
    List<StoryItem>? stories,
    int? currentIndex,
    bool? isPlaying,
    bool? showReactions,
    List<String>? availableReactions,
  }) {
    return StoriesViewerState(
      stories: stories ?? this.stories,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      showReactions: showReactions ?? this.showReactions,
      availableReactions: availableReactions ?? this.availableReactions,
    );
  }
}

class StoriesViewerNotifier extends StateNotifier<StoriesViewerState> {
  StoriesViewerNotifier() : super(StoriesViewerState()) {
    _loadSampleStories();
  }

  void _loadSampleStories() {
    final now = DateTime.now();
    final sampleStories = [
      StoryItem(
        id: 's1',
        userId: 'user1',
        userName: '小雅',
        userAvatar: '👩‍🦰',
        type: StoryType.text,
        content: '今天心情特別好！陽光很棒 ☀️\n\n準備去中環喝咖啡，有人要一起嗎？',
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 22)),
        reactions: [
          StoryReaction(userId: 'u1', userName: '志明', emoji: '❤️', timestamp: now.subtract(const Duration(hours: 1))),
          StoryReaction(userId: 'u2', userName: '美玲', emoji: '😍', timestamp: now.subtract(const Duration(minutes: 30))),
        ],
        viewers: ['u1', 'u2', 'u3'],
      ),
      StoryItem(
        id: 's2',
        userId: 'user1',
        userName: '小雅',
        userAvatar: '👩‍🦰',
        type: StoryType.image,
        content: '今天的咖啡拉花 ☕️',
        mediaUrl: '☕',
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 23)),
        reactions: [
          StoryReaction(userId: 'u1', userName: '志明', emoji: '👏', timestamp: now.subtract(const Duration(minutes: 45))),
        ],
        viewers: ['u1', 'u2'],
      ),
      StoryItem(
        id: 's3',
        userId: 'user1',
        userName: '小雅',
        userAvatar: '👩‍🦰',
        type: StoryType.poll,
        content: '今晚想看什麼電影？',
        createdAt: now.subtract(const Duration(minutes: 30)),
        expiresAt: now.add(const Duration(hours: 23, minutes: 30)),
        viewers: ['u1'],
      ),
    ];

    state = state.copyWith(stories: sampleStories);
  }

  void nextStory() {
    if (state.currentIndex < state.stories.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousStory() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void showReactions() {
    state = state.copyWith(showReactions: true);
  }

  void hideReactions() {
    state = state.copyWith(showReactions: false);
  }

  void addReaction(String emoji) {
    final currentStory = state.stories[state.currentIndex];
    final newReaction = StoryReaction(
      userId: 'current_user',
      userName: '我',
      emoji: emoji,
      timestamp: DateTime.now(),
    );

    final updatedStories = List<StoryItem>.from(state.stories);
    final updatedReactions = List<StoryReaction>.from(currentStory.reactions);
    
    // 移除之前的反應（如果有）
    updatedReactions.removeWhere((r) => r.userId == 'current_user');
    updatedReactions.add(newReaction);

    updatedStories[state.currentIndex] = StoryItem(
      id: currentStory.id,
      userId: currentStory.userId,
      userName: currentStory.userName,
      userAvatar: currentStory.userAvatar,
      type: currentStory.type,
      content: currentStory.content,
      mediaUrl: currentStory.mediaUrl,
      createdAt: currentStory.createdAt,
      expiresAt: currentStory.expiresAt,
      reactions: updatedReactions,
      viewers: currentStory.viewers,
      isViewed: currentStory.isViewed,
    );

    state = state.copyWith(
      stories: updatedStories,
      showReactions: false,
    );
  }
}

// Stories 查看器主頁面
class EnhancedStoriesViewer extends ConsumerStatefulWidget {
  final String userId;
  final int initialIndex;

  const EnhancedStoriesViewer({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<EnhancedStoriesViewer> createState() => _EnhancedStoriesViewerState();
}

class _EnhancedStoriesViewerState extends ConsumerState<EnhancedStoriesViewer>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _reactionController;
  late AnimationController _heartController;
  
  late Animation<double> _reactionScaleAnimation;
  late Animation<double> _heartAnimation;
  late Animation<Offset> _heartSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _startStoryTimer();
  }

  void _setupControllers() {
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _reactionController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _setupAnimations() {
    _reactionScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.elasticOut),
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );

    _heartSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, -1.0),
    ).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
  }

  void _startStoryTimer() {
    _progressController.reset();
    _progressController.forward().then((_) {
      if (mounted) {
        _nextStory();
      }
    });
  }

  void _nextStory() {
    final state = ref.read(storiesViewerProvider);
    if (state.currentIndex < state.stories.length - 1) {
      ref.read(storiesViewerProvider.notifier).nextStory();
      _pageController.nextPage(
        duration: AppAnimations.fast,
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    final state = ref.read(storiesViewerProvider);
    if (state.currentIndex > 0) {
      ref.read(storiesViewerProvider.notifier).previousStory();
      _pageController.previousPage(
        duration: AppAnimations.fast,
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _reactionController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storiesViewerProvider);
    
    if (state.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousStory();
          } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
            _nextStory();
          } else {
            ref.read(storiesViewerProvider.notifier).togglePlayback();
          }
        },
        onLongPressStart: (_) {
          _progressController.stop();
          ref.read(storiesViewerProvider.notifier).showReactions();
          _reactionController.forward();
        },
        onLongPressEnd: (_) {
          if (state.isPlaying) {
            _progressController.forward();
          }
          ref.read(storiesViewerProvider.notifier).hideReactions();
          _reactionController.reverse();
        },
        child: Stack(
          children: [
            // Stories 內容
            PageView.builder(
              controller: _pageController,
              itemCount: state.stories.length,
              onPageChanged: (index) {
                ref.read(storiesViewerProvider.notifier).state = 
                    state.copyWith(currentIndex: index);
                _startStoryTimer();
              },
              itemBuilder: (context, index) {
                return _buildStoryContent(state.stories[index]);
              },
            ),
            
            // 頂部進度條
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: _buildProgressBars(state),
            ),
            
            // 頂部用戶信息
            Positioned(
              top: MediaQuery.of(context).padding.top + 40,
              left: 16,
              right: 16,
              child: _buildUserInfo(state.stories[state.currentIndex]),
            ),
            
            // 底部操作區
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 16,
              right: 16,
              child: _buildBottomActions(state.stories[state.currentIndex]),
            ),
            
            // 反應選擇器
            if (state.showReactions)
              Positioned(
                bottom: MediaQuery.of(context).size.height / 2 - 50,
                left: 0,
                right: 0,
                child: _buildReactionSelector(state),
              ),
            
            // 飛舞的愛心動畫
            ..._buildFloatingHearts(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryItem story) {
    switch (story.type) {
      case StoryType.text:
        return _buildTextStory(story);
      case StoryType.image:
        return _buildImageStory(story);
      case StoryType.video:
        return _buildVideoStory(story);
      case StoryType.poll:
        return _buildPollStory(story);
      case StoryType.question:
        return _buildQuestionStory(story);
      default:
        return _buildTextStory(story);
    }
  }

  Widget _buildTextStory(StoryItem story) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            story.content,
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildImageStory(StoryItem story) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black87],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  boxShadow: AppShadows.floating,
                ),
                child: Center(
                  child: Text(
                    story.mediaUrl ?? '📸',
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          if (story.content.isNotEmpty)
            Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                story.content,
                style: AppTextStyles.h5.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoStory(StoryItem story) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.black54],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              story.content,
              style: AppTextStyles.h5.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollStory(StoryItem story) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
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
                story.content,
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // 投票選項
              _buildPollOption('動作片', 65, true),
              const SizedBox(height: AppSpacing.md),
              _buildPollOption('愛情片', 35, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollOption(String option, int percentage, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // 處理投票邏輯
      },
      child: Container(
        width: double.infinity,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isSelected ? 0.3 : 0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.8 : 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // 進度背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: [percentage / 100, percentage / 100],
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
            ),
            
            // 選項內容
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionStory(StoryItem story) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFFF6B6B),
            const Color(0xFF4ECDC4),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                story.content,
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '點擊回答問題...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildProgressBars(StoriesViewerState state) {
    return Row(
      children: List.generate(state.stories.length, (index) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(
              right: index < state.stories.length - 1 ? 4 : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                double progress = 0.0;
                if (index < state.currentIndex) {
                  progress = 1.0;
                } else if (index == state.currentIndex) {
                  progress = _progressController.value;
                }
                
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(1.5),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserInfo(StoryItem story) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              story.userAvatar,
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
                story.userName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                story.timeRemainingText,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showStoryOptions(story),
        ),
      ],
    );
  }

  Widget _buildBottomActions(StoryItem story) {
    return Column(
      children: [
        // 反應顯示
        if (story.reactions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                ...story.reactions.take(3).map((reaction) => 
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Text(
                      reaction.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                if (story.reactions.length > 3)
                  Text(
                    '+${story.reactions.length - 3}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                const Spacer(),
                Text(
                  '${story.viewers.length} 次查看',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        
        // 回覆輸入框
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '回覆 ${story.userName}...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => _showReplyDialog(story),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSelector(StoriesViewerState state) {
    return AnimatedBuilder(
      animation: _reactionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _reactionScaleAnimation.value,
          child: Container(
            margin: AppSpacing.pagePadding,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: state.availableReactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(storiesViewerProvider.notifier).addReaction(emoji);
                    _triggerHeartAnimation();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingHearts() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _heartController,
        builder: (context, child) {
          if (_heartController.value == 0) return const SizedBox();
          
          return Positioned(
            bottom: MediaQuery.of(context).size.height / 2 + (index * 20),
            right: 50 + (index * 30),
            child: SlideTransition(
              position: _heartSlideAnimation,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
                ),
                child: Transform.scale(
                  scale: _heartAnimation.value,
                  child: const Text(
                    '❤️',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _triggerHeartAnimation() {
    _heartController.reset();
    _heartController.forward();
  }

  void _showStoryOptions(StoryItem story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享 Story'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('舉報'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('封鎖用戶'),
              onTap: () => Navigator.pop(context),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(StoryItem story) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '回覆 ${story.userName}',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '輸入你的回覆...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('回覆已發送'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        '發送',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 