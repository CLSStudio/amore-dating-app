import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'stories_feature.dart';

// 挑戰類型
enum ChallengeType {
  question,          // 問答挑戰
  poll,             // 投票挑戰  
  thisOrThat,       // 選擇題挑戰
  story,            // 故事挑戰
  photo,            // 照片挑戰
  video,            // 視頻挑戰
  music,            // 音樂挑戰
  location,         // 位置挑戰
}

// 挑戰難度
enum ChallengeLevel {
  easy,             // 簡單
  medium,           // 中等
  hard,             // 困難
  expert,           // 專家級
}

// 挑戰模型
class ProfileChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeLevel level;
  final Map<String, dynamic> config;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int participantCount;
  final bool isActive;
  final String? creatorId;

  ProfileChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.level,
    required this.config,
    this.tags = const [],
    required this.createdAt,
    this.expiresAt,
    this.participantCount = 0,
    this.isActive = true,
    this.creatorId,
  });

  String get levelText {
    switch (level) {
      case ChallengeLevel.easy:
        return '簡單';
      case ChallengeLevel.medium:
        return '中等';
      case ChallengeLevel.hard:
        return '困難';
      case ChallengeLevel.expert:
        return '專家級';
    }
  }

  Color get levelColor {
    switch (level) {
      case ChallengeLevel.easy:
        return AppColors.success;
      case ChallengeLevel.medium:
        return AppColors.warning;
      case ChallengeLevel.hard:
        return AppColors.error;
      case ChallengeLevel.expert:
        return AppColors.secondary;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ChallengeType.question:
        return Icons.help_outline;
      case ChallengeType.poll:
        return Icons.poll;
      case ChallengeType.thisOrThat:
        return Icons.compare_arrows;
      case ChallengeType.story:
        return Icons.auto_stories;
      case ChallengeType.photo:
        return Icons.photo_camera;
      case ChallengeType.video:
        return Icons.videocam;
      case ChallengeType.music:
        return Icons.music_note;
      case ChallengeType.location:
        return Icons.location_on;
    }
  }
}

// 挑戰回應模型
class ChallengeResponse {
  final String id;
  final String challengeId;
  final String userId;
  final String userName;
  final String userAvatar;
  final Map<String, dynamic> response;
  final DateTime submittedAt;
  final List<String> likedBy;
  final List<ChallengeComment> comments;

  ChallengeResponse({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.response,
    required this.submittedAt,
    this.likedBy = const [],
    this.comments = const [],
  });

  int get likeCount => likedBy.length;
  int get commentCount => comments.length;
}

// 挑戰評論模型
class ChallengeComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;

  ChallengeComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
  });
}

// 挑戰狀態管理
final challengesProvider = StateNotifierProvider<ChallengesNotifier, List<ProfileChallenge>>((ref) {
  return ChallengesNotifier();
});

final challengeResponsesProvider = StateNotifierProvider<ChallengeResponsesNotifier, Map<String, List<ChallengeResponse>>>((ref) {
  return ChallengeResponsesNotifier();
});

class ChallengesNotifier extends StateNotifier<List<ProfileChallenge>> {
  ChallengesNotifier() : super([]) {
    _loadSampleChallenges();
  }

  void _loadSampleChallenges() {
    final challenges = [
      ProfileChallenge(
        id: '1',
        title: '你的理想約會是什麼？',
        description: '分享你心目中最完美的約會場景',
        type: ChallengeType.question,
        level: ChallengeLevel.easy,
        config: {
          'maxLength': 200,
          'allowPhoto': true,
        },
        tags: ['約會', '浪漫', '理想'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        participantCount: 45,
      ),
      ProfileChallenge(
        id: '2',
        title: '咖啡 vs 茶？',
        description: '你更偏愛咖啡還是茶？說說原因',
        type: ChallengeType.thisOrThat,
        level: ChallengeLevel.easy,
        config: {
          'optionA': '咖啡☕',
          'optionB': '茶🍵',
          'allowReason': true,
        },
        tags: ['飲料', '偏好', '日常'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        participantCount: 128,
      ),
      ProfileChallenge(
        id: '3',
        title: '最難忘的旅行回憶',
        description: '用一張照片和一段文字分享你最難忘的旅行經歷',
        type: ChallengeType.photo,
        level: ChallengeLevel.medium,
        config: {
          'requirePhoto': true,
          'maxLength': 150,
          'allowLocation': true,
        },
        tags: ['旅行', '回憶', '分享'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        participantCount: 67,
      ),
      ProfileChallenge(
        id: '4',
        title: '你的人生座右銘',
        description: '分享一句激勵你的話或者你的人生哲學',
        type: ChallengeType.story,
        level: ChallengeLevel.medium,
        config: {
          'maxLength': 100,
          'inspirationalTheme': true,
        },
        tags: ['哲學', '座右銘', '激勵'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        participantCount: 234,
      ),
      ProfileChallenge(
        id: '5',
        title: '最愛的歌曲投票',
        description: '選出你認為最適合約會時聽的歌曲類型',
        type: ChallengeType.poll,
        level: ChallengeLevel.easy,
        config: {
          'options': ['流行音樂', '爵士樂', '古典音樂', '搖滾樂', '民謠', '電子音樂'],
          'multipleChoice': false,
        },
        tags: ['音樂', '約會', '投票'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        participantCount: 189,
      ),
    ];
    
    state = challenges;
  }

  void addChallenge(ProfileChallenge challenge) {
    state = [challenge, ...state];
  }

  void updateParticipantCount(String challengeId, int count) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        return ProfileChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          level: challenge.level,
          config: challenge.config,
          tags: challenge.tags,
          createdAt: challenge.createdAt,
          expiresAt: challenge.expiresAt,
          participantCount: count,
          isActive: challenge.isActive,
          creatorId: challenge.creatorId,
        );
      }
      return challenge;
    }).toList();
  }
}

class ChallengeResponsesNotifier extends StateNotifier<Map<String, List<ChallengeResponse>>> {
  ChallengeResponsesNotifier() : super({});

  void addResponse(String challengeId, ChallengeResponse response) {
    final currentResponses = state[challengeId] ?? [];
    state = {
      ...state,
      challengeId: [response, ...currentResponses],
    };
  }

  void likeResponse(String challengeId, String responseId, String userId) {
    final responses = state[challengeId] ?? [];
    final updatedResponses = responses.map((response) {
      if (response.id == responseId) {
        final likedBy = List<String>.from(response.likedBy);
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        return ChallengeResponse(
          id: response.id,
          challengeId: response.challengeId,
          userId: response.userId,
          userName: response.userName,
          userAvatar: response.userAvatar,
          response: response.response,
          submittedAt: response.submittedAt,
          likedBy: likedBy,
          comments: response.comments,
        );
      }
      return response;
    }).toList();
    
    state = {
      ...state,
      challengeId: updatedResponses,
    };
  }
}

// 互動挑戰主頁面
class InteractiveProfileChallengesPage extends ConsumerStatefulWidget {
  const InteractiveProfileChallengesPage({super.key});

  @override
  ConsumerState<InteractiveProfileChallengesPage> createState() => _InteractiveProfileChallengesPageState();
}

class _InteractiveProfileChallengesPageState extends ConsumerState<InteractiveProfileChallengesPage>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveChallenges(),
                  _buildMyChallenges(),
                  _buildCreateChallenge(),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, color: Colors.white, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '熱門',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '🎮 互動檔案挑戰',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '參與有趣的挑戰，展示你的個性，發現更多有趣的人',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '熱門挑戰'),
          Tab(text: '我的參與'),
          Tab(text: '創建挑戰'),
        ],
      ),
    );
  }

  Widget _buildActiveChallenges() {
    final challenges = ref.watch(challengesProvider);
    
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          
          // 統計卡片
          _buildStatsCard(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 挑戰篩選
          _buildFilterButtons(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 挑戰列表
          ...challenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              title: '參與挑戰',
              value: '12',
              color: AppColors.warning,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.favorite,
              title: '獲得讚數',
              value: '48',
              color: AppColors.error,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_up,
              title: '人氣排名',
              value: '#15',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    final filters = [
      {'title': '全部', 'icon': Icons.apps},
      {'title': '問答', 'icon': Icons.help_outline},
      {'title': '投票', 'icon': Icons.poll},
      {'title': '照片', 'icon': Icons.photo_camera},
      {'title': '選擇', 'icon': Icons.compare_arrows},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = index == 0; // 模擬選中狀態
          
          return Container(
            margin: EdgeInsets.only(
              right: index < filters.length - 1 ? AppSpacing.md : 0,
            ),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                // Handle filter selection
              },
              avatar: Icon(
                filter['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              label: Text(
                filter['title'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(ProfileChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        onTap: () => _openChallenge(challenge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 挑戰頭部
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Icon(
                    challenge.typeIcon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: challenge.levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                            ),
                            child: Text(
                              challenge.levelText,
                              style: AppTextStyles.overline.copyWith(
                                color: challenge.levelColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${challenge.participantCount} 人參與',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 挑戰描述
            Text(
              challenge.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 標籤
            if (challenge.tags.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                children: challenge.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 底部操作
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(challenge.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openChallenge(challenge),
                  icon: Icon(
                    Icons.play_arrow,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    '參與挑戰',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMyChallenges() {
    return const Center(
      child: Text('我的挑戰功能即將推出'),
    );
  }

  Widget _buildCreateChallenge() {
    return const Center(
      child: Text('創建挑戰功能即將推出'),
    );
  }

  void _openChallenge(ProfileChallenge challenge) {
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailPage(challenge: challenge),
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

// 挑戰詳情頁面
class ChallengeDetailPage extends ConsumerStatefulWidget {
  final ProfileChallenge challenge;

  const ChallengeDetailPage({
    super.key,
    required this.challenge,
  });

  @override
  ConsumerState<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends ConsumerState<ChallengeDetailPage> {
  final TextEditingController _responseController = TextEditingController();
  String? _selectedOption;
  
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildDetailHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  _buildChallengeInfo(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildResponseForm(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildParticipantResponses(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.challenge.typeIcon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.challenge.levelText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.challenge.title,
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.challenge.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '挑戰資訊',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.people,
                  title: '參與人數',
                  value: '${widget.challenge.participantCount}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time,
                  title: '發佈時間',
                  value: _formatTimeAgo(widget.challenge.createdAt),
                ),
              ),
            ],
          ),
          
          if (widget.challenge.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '標籤',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: widget.challenge.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildResponseForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '參與挑戰',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppSpacing.md),
          
          if (widget.challenge.type == ChallengeType.thisOrThat)
            _buildThisOrThatForm()
          else if (widget.challenge.type == ChallengeType.poll)
            _buildPollForm()
          else
            _buildTextResponseForm(),
          
          const SizedBox(height: AppSpacing.lg),
          
          AppButton(
            text: '提交回應',
            onPressed: _submitResponse,
            type: AppButtonType.primary,
            icon: Icons.send,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildThisOrThatForm() {
    final optionA = widget.challenge.config['optionA'] as String;
    final optionB = widget.challenge.config['optionB'] as String;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedOption = optionA),
                child: Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: _selectedOption == optionA 
                        ? AppColors.primary.withOpacity(0.1) 
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(
                      color: _selectedOption == optionA 
                          ? AppColors.primary 
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    optionA,
                    style: AppTextStyles.h6.copyWith(
                      color: _selectedOption == optionA 
                          ? AppColors.primary 
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'VS',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedOption = optionB),
                child: Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: _selectedOption == optionB 
                        ? AppColors.primary.withOpacity(0.1) 
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(
                      color: _selectedOption == optionB 
                          ? AppColors.primary 
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    optionB,
                    style: AppTextStyles.h6.copyWith(
                      color: _selectedOption == optionB 
                          ? AppColors.primary 
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (widget.challenge.config['allowReason'] == true) ...[
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _responseController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '說說你的理由...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPollForm() {
    final options = widget.challenge.config['options'] as List<String>;
    
    return Column(
      children: options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: RadioListTile<String>(
            value: option,
            groupValue: _selectedOption,
            onChanged: (value) => setState(() => _selectedOption = value),
            title: Text(option),
            activeColor: AppColors.primary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextResponseForm() {
    final maxLength = widget.challenge.config['maxLength'] as int? ?? 200;
    
    return TextField(
      controller: _responseController,
      maxLines: 4,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: '分享你的想法...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  Widget _buildParticipantResponses() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '其他參與者的回應',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppSpacing.md),
          
          // 這裡可以顯示其他用戶的回應
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Text(
              '其他用戶的精彩回應即將顯示...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _submitResponse() {
    HapticFeedback.mediumImpact();
    
    String responseText = '';
    if (widget.challenge.type == ChallengeType.thisOrThat) {
      if (_selectedOption == null) {
        _showError('請選擇一個選項');
        return;
      }
      responseText = _selectedOption!;
      if (widget.challenge.config['allowReason'] == true && _responseController.text.isNotEmpty) {
        responseText += ': ${_responseController.text}';
      }
    } else if (widget.challenge.type == ChallengeType.poll) {
      if (_selectedOption == null) {
        _showError('請選擇一個選項');
        return;
      }
      responseText = _selectedOption!;
    } else {
      responseText = _responseController.text.trim();
      if (responseText.isEmpty) {
        _showError('請輸入回應內容');
        return;
      }
    }

    // 提交回應
    final response = ChallengeResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      challengeId: widget.challenge.id,
      userId: 'current_user',
      userName: '我',
      userAvatar: '😊',
      response: {'content': responseText},
      submittedAt: DateTime.now(),
    );

    ref.read(challengeResponsesProvider.notifier).addResponse(
      widget.challenge.id,
      response,
    );

    // 更新參與人數
    ref.read(challengesProvider.notifier).updateParticipantCount(
      widget.challenge.id,
      widget.challenge.participantCount + 1,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('回應提交成功！'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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