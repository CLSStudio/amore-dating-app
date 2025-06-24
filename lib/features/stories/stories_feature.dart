import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Story 類型
enum StoryType {
  photo,
  video,
  text,
  poll,
  question,
  music,
  location,
}

// Story 模型
class Story {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final StoryType type;
  final String content;
  final String? mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final List<StoryReaction> reactions;
  final Map<String, dynamic>? metadata;
  final bool isHighlight;
  final String? highlightCategory;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.reactions = const [],
    this.metadata,
    this.isHighlight = false,
    this.highlightCategory,
  });

  Story copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    StoryType? type,
    String? content,
    String? mediaUrl,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
    List<StoryReaction>? reactions,
    Map<String, dynamic>? metadata,
    bool? isHighlight,
    String? highlightCategory,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
      isHighlight: isHighlight ?? this.isHighlight,
      highlightCategory: highlightCategory ?? this.highlightCategory,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasViewed => viewedBy.isNotEmpty;
  int get viewCount => viewedBy.length;
  int get reactionCount => reactions.length;
}

// Story 反應模型
class StoryReaction {
  final String userId;
  final String userName;
  final String reactionType; // 'like', 'love', 'laugh', 'wow', 'sad', 'angry'
  final DateTime timestamp;

  StoryReaction({
    required this.userId,
    required this.userName,
    required this.reactionType,
    required this.timestamp,
  });
}

// Story 集合模型（用戶的所有 Stories）
class StoryCollection {
  final String userId;
  final String userName;
  final String userAvatar;
  final List<Story> stories;
  final bool hasUnviewed;

  StoryCollection({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.stories,
    required this.hasUnviewed,
  });

  Story? get latestStory => stories.isNotEmpty ? stories.last : null;
  List<Story> get activeStories => stories.where((s) => !s.isExpired).toList();
  int get unviewedCount => activeStories.where((s) => !s.hasViewed).length;
}

// Stories 狀態管理
final storiesProvider = StateNotifierProvider<StoriesNotifier, List<StoryCollection>>((ref) {
  return StoriesNotifier();
});

final currentStoryProvider = StateProvider<Story?>((ref) => null);
final storyViewerIndexProvider = StateProvider<int>((ref) => 0);

class StoriesNotifier extends StateNotifier<List<StoryCollection>> {
  StoriesNotifier() : super([]) {
    _loadSampleStories();
  }

  void _loadSampleStories() {
    final now = DateTime.now();
    final sampleStories = [
      StoryCollection(
        userId: '1',
        userName: '小雅',
        userAvatar: '👩‍🦰',
        hasUnviewed: true,
        stories: [
          Story(
            id: 's1',
            userId: '1',
            userName: '小雅',
            userAvatar: '👩‍🦰',
            type: StoryType.photo,
            content: '今天的咖啡拉花 ☕️',
            mediaUrl: '☕',
            caption: '學會了新的拉花技巧！',
            createdAt: now.subtract(const Duration(hours: 2)),
            expiresAt: now.add(const Duration(hours: 22)),
            viewedBy: [],
            reactions: [],
          ),
          Story(
            id: 's2',
            userId: '1',
            userName: '小雅',
            userAvatar: '👩‍🦰',
            type: StoryType.text,
            content: '今天心情特別好！陽光很棒 ☀️',
            createdAt: now.subtract(const Duration(hours: 1)),
            expiresAt: now.add(const Duration(hours: 23)),
            viewedBy: [],
            reactions: [],
          ),
        ],
      ),
      StoryCollection(
        userId: '2',
        userName: '志明',
        userAvatar: '👨‍💻',
        hasUnviewed: true,
        stories: [
          Story(
            id: 's3',
            userId: '2',
            userName: '志明',
            userAvatar: '👨‍💻',
            type: StoryType.photo,
            content: '新項目上線了！',
            mediaUrl: '💻',
            caption: '經過三個月的努力，終於完成了',
            createdAt: now.subtract(const Duration(hours: 4)),
            expiresAt: now.add(const Duration(hours: 20)),
            viewedBy: [],
            reactions: [],
          ),
        ],
      ),
      StoryCollection(
        userId: '3',
        userName: '美玲',
        userAvatar: '🧘‍♀️',
        hasUnviewed: false,
        stories: [
          Story(
            id: 's4',
            userId: '3',
            userName: '美玲',
            userAvatar: '🧘‍♀️',
            type: StoryType.video,
            content: '晨間瑜伽',
            mediaUrl: '🧘‍♀️',
            caption: '每天的晨間瑜伽讓我充滿活力',
            createdAt: now.subtract(const Duration(hours: 6)),
            expiresAt: now.add(const Duration(hours: 18)),
            viewedBy: ['current_user'],
            reactions: [
              StoryReaction(
                userId: 'current_user',
                userName: '我',
                reactionType: 'love',
                timestamp: now.subtract(const Duration(hours: 5)),
              ),
            ],
          ),
        ],
      ),
    ];
    
    state = sampleStories;
  }

  void addStory(Story story) {
    final existingCollectionIndex = state.indexWhere((c) => c.userId == story.userId);
    
    if (existingCollectionIndex != -1) {
      final existingCollection = state[existingCollectionIndex];
      final updatedStories = [...existingCollection.stories, story];
      final updatedCollection = StoryCollection(
        userId: existingCollection.userId,
        userName: existingCollection.userName,
        userAvatar: existingCollection.userAvatar,
        stories: updatedStories,
        hasUnviewed: true,
      );
      
      state = [
        ...state.sublist(0, existingCollectionIndex),
        updatedCollection,
        ...state.sublist(existingCollectionIndex + 1),
      ];
    } else {
      final newCollection = StoryCollection(
        userId: story.userId,
        userName: story.userName,
        userAvatar: story.userAvatar,
        stories: [story],
        hasUnviewed: true,
      );
      state = [newCollection, ...state];
    }
  }

  void markAsViewed(String storyId, String viewerId) {
    state = state.map((collection) {
      final updatedStories = collection.stories.map((story) {
        if (story.id == storyId && !story.viewedBy.contains(viewerId)) {
          return story.copyWith(
            viewedBy: [...story.viewedBy, viewerId],
          );
        }
        return story;
      }).toList();

      return StoryCollection(
        userId: collection.userId,
        userName: collection.userName,
        userAvatar: collection.userAvatar,
        stories: updatedStories,
        hasUnviewed: updatedStories.any((s) => !s.viewedBy.contains(viewerId)),
      );
    }).toList();
  }

  void addReaction(String storyId, StoryReaction reaction) {
    state = state.map((collection) {
      final updatedStories = collection.stories.map((story) {
        if (story.id == storyId) {
          final existingReactionIndex = story.reactions.indexWhere(
            (r) => r.userId == reaction.userId,
          );
          
          List<StoryReaction> updatedReactions;
          if (existingReactionIndex != -1) {
            updatedReactions = [...story.reactions];
            updatedReactions[existingReactionIndex] = reaction;
          } else {
            updatedReactions = [...story.reactions, reaction];
          }
          
          return story.copyWith(reactions: updatedReactions);
        }
        return story;
      }).toList();

      return StoryCollection(
        userId: collection.userId,
        userName: collection.userName,
        userAvatar: collection.userAvatar,
        stories: updatedStories,
        hasUnviewed: collection.hasUnviewed,
      );
    }).toList();
  }

  void deleteStory(String storyId) {
    state = state.map((collection) {
      final updatedStories = collection.stories.where((s) => s.id != storyId).toList();
      
      if (updatedStories.isEmpty) {
        return null;
      }
      
      return StoryCollection(
        userId: collection.userId,
        userName: collection.userName,
        userAvatar: collection.userAvatar,
        stories: updatedStories,
        hasUnviewed: collection.hasUnviewed,
      );
    }).where((c) => c != null).cast<StoryCollection>().toList();
  }
}

// Stories 主頁面
class StoriesPage extends ConsumerWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyCollections = ref.watch(storiesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: storyCollections.isEmpty
                  ? _buildEmptyState()
                  : _buildStoriesGrid(context, ref, storyCollections),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCreateStoryButton(context, ref),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Stories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showStoriesSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '還沒有 Stories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '分享你的日常生活瞬間',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesGrid(BuildContext context, WidgetRef ref, List<StoryCollection> collections) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _buildStoryCollectionCard(context, ref, collection);
      },
    );
  }

  Widget _buildStoryCollectionCard(BuildContext context, WidgetRef ref, StoryCollection collection) {
    final latestStory = collection.latestStory;
    if (latestStory == null) return const SizedBox();

    return GestureDetector(
      onTap: () => _openStoryViewer(context, ref, collection),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: collection.hasUnviewed ? Colors.pink : Colors.grey,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              // 背景內容
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.8),
                      Colors.pink.withOpacity(0.8),
                    ],
                  ),
                ),
                child: _buildStoryPreview(latestStory),
              ),
              
              // 用戶信息覆蓋層
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          collection.userAvatar,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        collection.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部信息
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (latestStory.caption != null)
                      Text(
                        latestStory.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeAgo(latestStory.createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 未讀指示器
              if (collection.hasUnviewed)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryPreview(Story story) {
    switch (story.type) {
      case StoryType.photo:
        return Center(
          child: Text(
            story.mediaUrl ?? '📷',
            style: const TextStyle(fontSize: 60),
          ),
        );
      case StoryType.video:
        return Stack(
          children: [
            Center(
              child: Text(
                story.mediaUrl ?? '🎥',
                style: const TextStyle(fontSize: 60),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        );
      case StoryType.text:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              story.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      default:
        return const Center(
          child: Icon(
            Icons.photo,
            color: Colors.white,
            size: 40,
          ),
        );
    }
  }

  Widget _buildCreateStoryButton(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showCreateStoryOptions(context, ref),
      backgroundColor: Colors.pink,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _openStoryViewer(BuildContext context, WidgetRef ref, StoryCollection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(collection: collection),
      ),
    );
  }

  void _showCreateStoryOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateStoryOptionsSheet(ref: ref),
    );
  }

  void _showStoriesSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const StoriesSettingsSheet(),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}

// Story 查看器
class StoryViewerPage extends ConsumerStatefulWidget {
  final StoryCollection collection;

  const StoryViewerPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends ConsumerState<StoryViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _startStoryTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _progressController.reset();
    _progressController.forward().then((_) {
      _nextStory();
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.collection.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.collection.activeStories;
    if (stories.isEmpty) {
      Navigator.pop(context);
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story 內容
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startStoryTimer();
              },
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return _buildStoryContent(stories[index]);
              },
            ),
            
            // 頂部進度條
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: _buildProgressBars(stories.length),
            ),
            
            // 頂部用戶信息
            Positioned(
              top: MediaQuery.of(context).padding.top + 40,
              left: 16,
              right: 16,
              child: _buildUserInfo(),
            ),
            
            // 底部操作區
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 16,
              right: 16,
              child: _buildBottomActions(stories[_currentIndex]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars(int storyCount) {
    return Row(
      children: List.generate(storyCount, (index) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index < storyCount - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                double progress = 0.0;
                if (index < _currentIndex) {
                  progress = 1.0;
                } else if (index == _currentIndex) {
                  progress = _progressController.value;
                }
                
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              widget.collection.userAvatar,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.collection.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimeAgo(widget.collection.stories[_currentIndex].createdAt),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildStoryContent(Story story) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.pink.withOpacity(0.8),
          ],
        ),
      ),
      child: _buildStoryTypeContent(story),
    );
  }

  Widget _buildStoryTypeContent(Story story) {
    switch (story.type) {
      case StoryType.photo:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                story.mediaUrl ?? '📷',
                style: const TextStyle(fontSize: 120),
              ),
              if (story.caption != null) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    story.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      case StoryType.video:
        return Stack(
          children: [
            Center(
              child: Text(
                story.mediaUrl ?? '🎥',
                style: const TextStyle(fontSize: 120),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 60,
              ),
            ),
            if (story.caption != null)
              Positioned(
                bottom: 100,
                left: 32,
                right: 32,
                child: Text(
                  story.caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      case StoryType.text:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              story.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      default:
        return const Center(
          child: Icon(
            Icons.photo,
            color: Colors.white,
            size: 80,
          ),
        );
    }
  }

  Widget _buildBottomActions(Story story) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              '發送消息...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildReactionButton(story, '❤️'),
        const SizedBox(width: 8),
        _buildReactionButton(story, '😂'),
        const SizedBox(width: 8),
        _buildReactionButton(story, '😮'),
      ],
    );
  }

  Widget _buildReactionButton(Story story, String emoji) {
    return GestureDetector(
      onTap: () => _addReaction(story, emoji),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _addReaction(Story story, String emoji) {
    final reaction = StoryReaction(
      userId: 'current_user',
      userName: '我',
      reactionType: emoji,
      timestamp: DateTime.now(),
    );
    
    ref.read(storiesProvider.notifier).addReaction(story.id, reaction);
    
    // 顯示反應動畫
    _showReactionAnimation(emoji);
  }

  void _showReactionAnimation(String emoji) {
    // 這裡可以添加反應動畫效果
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已回應 $emoji'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}

// 創建 Story 選項表單
class CreateStoryOptionsSheet extends StatelessWidget {
  final WidgetRef ref;

  const CreateStoryOptionsSheet({
    super.key,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '創建 Story',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionTile(
            context,
            icon: Icons.photo_camera,
            title: '拍照',
            subtitle: '拍攝新照片',
            onTap: () => _createPhotoStory(context),
          ),
          _buildOptionTile(
            context,
            icon: Icons.photo_library,
            title: '從相簿選擇',
            subtitle: '選擇現有照片',
            onTap: () => _selectFromGallery(context),
          ),
          _buildOptionTile(
            context,
            icon: Icons.videocam,
            title: '錄製視頻',
            subtitle: '錄製短視頻',
            onTap: () => _createVideoStory(context),
          ),
          _buildOptionTile(
            context,
            icon: Icons.text_fields,
            title: '文字動態',
            subtitle: '分享想法',
            onTap: () => _createTextStory(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.pink),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  void _createPhotoStory(BuildContext context) {
    Navigator.pop(context);
    // 這裡會打開相機
    _showCreateStoryDialog(context, StoryType.photo);
  }

  void _selectFromGallery(BuildContext context) {
    Navigator.pop(context);
    // 這裡會打開相簿
    _showCreateStoryDialog(context, StoryType.photo);
  }

  void _createVideoStory(BuildContext context) {
    Navigator.pop(context);
    // 這裡會打開視頻錄製
    _showCreateStoryDialog(context, StoryType.video);
  }

  void _createTextStory(BuildContext context) {
    Navigator.pop(context);
    _showCreateStoryDialog(context, StoryType.text);
  }

  void _showCreateStoryDialog(BuildContext context, StoryType type) {
    showDialog(
      context: context,
      builder: (context) => CreateStoryDialog(
        ref: ref,
        storyType: type,
      ),
    );
  }
}

// 創建 Story 對話框
class CreateStoryDialog extends StatefulWidget {
  final WidgetRef ref;
  final StoryType storyType;

  const CreateStoryDialog({
    super.key,
    required this.ref,
    required this.storyType,
  });

  @override
  State<CreateStoryDialog> createState() => _CreateStoryDialogState();
}

class _CreateStoryDialogState extends State<CreateStoryDialog> {
  final _contentController = TextEditingController();
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '創建${_getStoryTypeText()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (widget.storyType == StoryType.text) ...[
              TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '分享你的想法...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.storyType == StoryType.photo
                            ? Icons.photo_camera
                            : Icons.videocam,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.storyType == StoryType.photo
                            ? '點擊拍照或選擇照片'
                            : '點擊錄製視頻',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '添加說明...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '發布',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStoryTypeText() {
    switch (widget.storyType) {
      case StoryType.photo:
        return '照片 Story';
      case StoryType.video:
        return '視頻 Story';
      case StoryType.text:
        return '文字 Story';
      default:
        return 'Story';
    }
  }

  void _createStory() {
    final content = widget.storyType == StoryType.text
        ? _contentController.text
        : _captionController.text;

    if (content.isEmpty && widget.storyType == StoryType.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入內容')),
      );
      return;
    }

    final now = DateTime.now();
    final story = Story(
      id: 'story_${now.millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: '我',
      userAvatar: '😊',
      type: widget.storyType,
      content: content,
      mediaUrl: widget.storyType == StoryType.photo
          ? '📸'
          : widget.storyType == StoryType.video
              ? '🎬'
              : null,
      caption: widget.storyType != StoryType.text ? _captionController.text : null,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    widget.ref.read(storiesProvider.notifier).addStory(story);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story 已發布！'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Stories 設置表單
class StoriesSettingsSheet extends StatelessWidget {
  const StoriesSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Stories 設置',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingTile(
            icon: Icons.visibility,
            title: '誰可以看到我的 Stories',
            subtitle: '所有人',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.reply,
            title: '允許回覆',
            subtitle: '開啟',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.save,
            title: '自動保存到相簿',
            subtitle: '關閉',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.archive,
            title: 'Stories 精選',
            subtitle: '管理精選集',
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
} 