import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'photo_management_widget.dart';
import 'enhanced_interests_widget.dart';
import 'stories_integration_widget.dart';
import '../mbti/mbti_data_models.dart';
import '../dating/modes/dating_mode_system.dart';
import '../chat/real_time_chat_page.dart';

// 個人檔案狀態管理
final userProfileProvider = StateProvider<UserProfile>((ref) {
  return UserProfile.sample(); // 示例數據
});

// 根據用戶ID獲取用戶檔案的 Provider
final userProfileByIdProvider = StateProvider.family<UserProfile, String>((ref, userId) {
  // 根據 userId 返回不同的用戶數據
  return UserProfile.sampleForUser(userId);
});

final profileEditModeProvider = StateProvider<bool>((ref) => false);
final profileSectionProvider = StateProvider<int>((ref) => 0);

// 用戶個人檔案模型
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String location;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String? mbtiType;
  final DatingMode currentDatingMode;
  final String occupation;
  final String education;
  final int height;
  final List<String> languages;
  final List<String> stories;
  final double completionPercentage;
  final DateTime lastActive;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    required this.photos,
    required this.interests,
    this.mbtiType,
    required this.currentDatingMode,
    required this.occupation,
    required this.education,
    required this.height,
    required this.languages,
    required this.stories,
    required this.completionPercentage,
    required this.lastActive,
  });

  factory UserProfile.sample() {
    return UserProfile(
      id: 'user_001',
      name: '小雅',
      age: 26,
      location: '香港中環',
      bio: '喜歡旅行和攝影的女生，正在尋找一個可以一起探索世界的人。平時喜歡看書、喝咖啡，偶爾會畫畫。希望能找到一個有趣的靈魂分享生活的美好。',
      photos: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg', 'photo4.jpg'],
      interests: ['旅行', '攝影', '咖啡', '閱讀', '繪畫', '瑜伽', '電影', '音樂'],
      mbtiType: 'ENFP',
      currentDatingMode: DatingMode.explore,
      occupation: '平面設計師',
      education: '香港理工大學',
      height: 165,
      languages: ['繁體中文', '英語', '日語'],
      stories: ['story1', 'story2', 'story3'],
      completionPercentage: 0.92,
      lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  factory UserProfile.sampleForUser(String userId) {
    // 根據 userId 返回不同的模擬用戶數據
    switch (userId) {
      case '1':
        return UserProfile(
          id: '1',
          name: '小雅',
          age: 25,
          location: '香港中環',
          bio: '熱愛攝影和旅行的設計師，喜歡探索世界的美好。平時愛喝咖啡，週末會去不同的地方拍照。希望找到一個能一起分享生活點滴的人。',
          photos: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
          interests: ['攝影', '旅行', '設計', '咖啡', '藝術', '音樂'],
          mbtiType: 'ENFP',
          currentDatingMode: DatingMode.explore,
          occupation: '平面設計師',
          education: '香港理工大學',
          height: 162,
          languages: ['繁體中文', '英語'],
          stories: ['story1', 'story2'],
          completionPercentage: 0.88,
          lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
        );
      case '2':
        return UserProfile(
          id: '2',
          name: '美玲',
          age: 26,
          location: '香港銅鑼灣',
          bio: '瑜伽教練，追求健康生活方式。相信身心靈的平衡能帶來真正的快樂。喜歡素食、冥想和大自然。',
          photos: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg', 'photo4.jpg'],
          interests: ['瑜伽', '健身', '素食', '冥想', '自然', '閱讀'],
          mbtiType: 'ISFJ',
          currentDatingMode: DatingMode.explore,
          occupation: '瑜伽教練',
          education: '香港大學',
          height: 165,
          languages: ['繁體中文', '英語', '普通話'],
          stories: ['story1', 'story2', 'story3'],
          completionPercentage: 0.95,
          lastActive: DateTime.now().subtract(const Duration(hours: 1)),
        );
      case '3':
        return UserProfile(
          id: '3',
          name: '詩婷',
          age: 24,
          location: '香港尖沙咀',
          bio: '藝術家，喜歡創作和音樂。相信藝術能觸動人心，音樂能治癒靈魂。經常參加展覽和音樂會。',
          photos: ['photo1.jpg', 'photo2.jpg'],
          interests: ['繪畫', '音樂', '展覽', '文學', '電影', '創作'],
          mbtiType: 'INFP',
          currentDatingMode: DatingMode.explore,
          occupation: '藝術家',
          education: '香港藝術學院',
          height: 158,
          languages: ['繁體中文', '英語'],
          stories: ['story1'],
          completionPercentage: 0.82,
          lastActive: DateTime.now().subtract(const Duration(minutes: 45)),
        );
      case '4':
        return UserProfile(
          id: '4',
          name: '志明',
          age: 28,
          location: '香港觀塘',
          bio: '軟件工程師，電影愛好者。熱愛科技和創新，業餘時間喜歡看電影和玩遊戲。正在學習新的編程語言。',
          photos: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg', 'photo4.jpg'],
          interests: ['編程', '電影', '遊戲', '科技', '閱讀', '學習'],
          mbtiType: 'INTJ',
          currentDatingMode: DatingMode.explore,
          occupation: '軟件工程師',
          education: '香港科技大學',
          height: 175,
          languages: ['繁體中文', '英語', '日語'],
          stories: ['story1', 'story2'],
          completionPercentage: 0.90,
          lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
        );
      case '5':
        return UserProfile(
          id: '5',
          name: '建華',
          age: 30,
          location: '香港灣仔',
          bio: '主廚，美食探索家。對烹飪充滿熱情，喜歡嘗試不同國家的料理。夢想是開一家自己的餐廳。',
          photos: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
          interests: ['烹飪', '美食', '紅酒', '旅行', '文化', '創業'],
          mbtiType: 'ESFP',
          currentDatingMode: DatingMode.explore,
          occupation: '主廚',
          education: '香港酒店管理學院',
          height: 172,
          languages: ['繁體中文', '英語', '法語'],
          stories: ['story1', 'story2', 'story3'],
          completionPercentage: 0.87,
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        );
      default:
        // 如果沒有匹配的 userId，返回默認數據
        return UserProfile.sample();
    }
  }
}

class EnhancedProfilePage extends ConsumerStatefulWidget {
  final bool isOwnProfile;
  final String? userId;

  const EnhancedProfilePage({
    super.key,
    this.isOwnProfile = true,
    this.userId,
  });

  @override
  ConsumerState<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends ConsumerState<EnhancedProfilePage>
    with TickerProviderStateMixin {
  
  late AnimationController _headerAnimationController;
  late AnimationController _sectionsAnimationController;
  late ScrollController _scrollController;
  
  late Animation<double> _headerAnimation;
  late Animation<Offset> _sectionsSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController = ScrollController();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _sectionsAnimationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic),
    );

    _sectionsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _sectionsAnimationController, curve: Curves.easeOutCubic),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _sectionsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _sectionsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根據是否有 userId 來決定使用哪個 provider
    final profile = widget.userId != null 
        ? ref.watch(userProfileByIdProvider(widget.userId!))
        : ref.watch(userProfileProvider);
    final isEditMode = widget.isOwnProfile ? ref.watch(profileEditModeProvider) : false;
    final currentSection = ref.watch(profileSectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.isOwnProfile 
          ? CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(profile, isEditMode),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _sectionsAnimationController,
              builder: (context, child) {
                return SlideTransition(
                  position: _sectionsSlideAnimation,
                  child: FadeTransition(
                    opacity: _sectionsAnimationController,
                    child: Column(
                      children: [
                        _buildProfileSummary(profile),
                        _buildSectionNavigation(currentSection),
                        _buildSectionContent(profile, currentSection, isEditMode),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
            )
          : _buildOtherUserBumbleStyle(profile),
      floatingActionButton: widget.isOwnProfile ? _buildEditButton(isEditMode) : null,
      bottomNavigationBar: !widget.isOwnProfile ? _buildOtherUserActions(profile) : null,
    );
  }

  Widget _buildAppBar(UserProfile profile, bool isEditMode) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _headerAnimation.value),
              child: Opacity(
                opacity: _headerAnimation.value,
                child: _buildProfileHeader(profile),
              ),
            );
          },
        ),
      ),
      actions: [
        if (widget.isOwnProfile) ...[
          IconButton(
            icon: Icon(
              isEditMode ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(profileEditModeProvider.notifier).state = !isEditMode;
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsMenu(context),
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => _likeProfile(profile),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () => _startChat(profile),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // 主要頭像
              Hero(
                tag: 'profile_avatar_${profile.id}',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: AppShadows.floating,
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // 名字和年齡
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${profile.name}, ${profile.age}',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '線上',
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // 位置
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.location,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
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

  Widget _buildProfileSummary(UserProfile profile) {
    return Container(
      margin: AppSpacing.pagePadding,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          // 完成度進度條
          Row(
            children: [
              const Icon(
                Icons.verified_user,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '檔案完成度',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(profile.completionPercentage * 100).toInt()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: profile.completionPercentage,
            backgroundColor: AppColors.textTertiary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 快速信息卡片
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  icon: Icons.psychology,
                  label: 'MBTI',
                  value: profile.mbtiType ?? '未測試',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildQuickInfoCard(
                  icon: Icons.favorite,
                  label: '約會模式',
                  value: _getDatingModeText(profile.currentDatingMode),
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionNavigation(int currentSection) {
    final sections = [
      {'title': '基本信息', 'icon': Icons.person},
      {'title': '照片', 'icon': Icons.photo_library},
      {'title': '興趣', 'icon': Icons.favorite},
      {'title': 'Stories', 'icon': Icons.auto_stories},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isSelected = currentSection == index;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(profileSectionProvider.notifier).state = index;
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                boxShadow: isSelected ? AppShadows.medium : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    section['icon'] as IconData,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    section['title'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContent(UserProfile profile, int currentSection, bool isEditMode) {
    switch (currentSection) {
      case 0:
        return _buildBasicInfoSection(profile, isEditMode);
      case 1:
        return _buildPhotosSection(profile, isEditMode);
      case 2:
        return _buildInterestsSection(profile, isEditMode);
      case 3:
        return _buildStoriesSection(profile, isEditMode);
      default:
        return _buildBasicInfoSection(profile, isEditMode);
    }
  }

  Widget _buildBasicInfoSection(UserProfile profile, bool isEditMode) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    const Text(
                  '基本信息',
                      style: AppTextStyles.h5,
                    ),
                const SizedBox(height: AppSpacing.lg),
                
                _buildInfoItem(
                  icon: Icons.person,
                  label: '姓名',
                  value: profile.name,
                  isEditable: isEditMode,
                ),
                
                _buildInfoItem(
                  icon: Icons.cake,
                  label: '年齡',
                  value: '${profile.age} 歲',
                  isEditable: isEditMode,
                ),
                
                _buildInfoItem(
                  icon: Icons.location_on,
                  label: '位置',
                  value: profile.location,
                  isEditable: isEditMode,
                ),
                
                _buildInfoItem(
                  icon: Icons.work,
                  label: '職業',
                  value: profile.occupation,
                  isEditable: isEditMode,
                ),
                
                _buildInfoItem(
                  icon: Icons.school,
                  label: '教育',
                  value: profile.education,
                  isEditable: isEditMode,
                ),
                
                _buildInfoItem(
                  icon: Icons.height,
                  label: '身高',
                  value: '${profile.height} cm',
                  isEditable: isEditMode,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '個人簡介',
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: AppSpacing.md),
                
                if (isEditMode)
                  AppTextField(
                    hint: '介紹一下你自己...',
                    maxLines: 5,
                    controller: TextEditingController(text: profile.bio),
                  )
                else
                Text(
                  profile.bio,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '語言能力',
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: AppSpacing.md),
                
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: profile.languages.map((language) => AppChip(
                    label: language,
                    isSelected: true,
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(UserProfile profile, bool isEditMode) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: Column(
        children: [
          if (isEditMode)
            AppCard(
              child: Column(
                  children: [
                    const Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: AppColors.primary,
                    ),
                  const SizedBox(height: AppSpacing.md),
                    Text(
                    '添加照片',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '最多可上傳 6 張照片',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: '選擇照片',
                    onPressed: () {},
                    icon: Icons.photo_library,
                    ),
                  ],
                ),
            ),
          
          const SizedBox(height: AppSpacing.lg),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.8,
            ),
            itemCount: profile.photos.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        color: AppColors.surface,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.photo,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    if (isEditMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () {},
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(UserProfile profile, bool isEditMode) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '興趣愛好',
                  style: AppTextStyles.h5,
                ),
                const Spacer(),
                if (isEditMode)
                  AppButton(
                    text: '編輯',
                    onPressed: () {},
                    size: AppButtonSize.small,
                    type: AppButtonType.outline,
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: profile.interests.map((interest) => AppChip(
                label: interest,
                isSelected: true,
                onTap: isEditMode ? () {} : null,
              )).toList(),
            ),
            
            if (isEditMode) ...[
            const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              
              const Text(
                '推薦興趣',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: AppSpacing.md),
              
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ['健身', '烹飪', '登山', '游泳', '舞蹈'].map((interest) => AppChip(
                  label: interest,
                  isSelected: false,
                  onTap: () {},
                )).toList(),
              ),
        ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection(UserProfile profile, bool isEditMode) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: StoriesIntegrationWidget(
        stories: profile.stories,
        isOwnProfile: widget.isOwnProfile,
        onStoriesChanged: (stories) {
          // 更新 stories
        },
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
            icon,
            size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
                const SizedBox(height: 2),
                if (isEditable)
                  AppTextField(
                    hint: value,
                    controller: TextEditingController(text: value),
                  )
                else
                  Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(bool isEditMode) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        ref.read(profileEditModeProvider.notifier).state = !isEditMode;
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: Icon(isEditMode ? Icons.save : Icons.edit),
      label: Text(isEditMode ? '保存' : '編輯'),
    );
  }

  String _getDatingModeText(DatingMode mode) {
    switch (mode) {
      case DatingMode.explore:
        return '探索模式';
      case DatingMode.serious:
        return '認真交往';
      case DatingMode.passion:
        return '激情模式';
    }
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('帳戶設置'),
              onTap: () => Navigator.pop(context),
            ),
            
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: AppColors.secondary),
              title: const Text('隱私設置'),
              onTap: () => Navigator.pop(context),
            ),
            
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.warning),
              title: const Text('通知設置'),
              onTap: () => Navigator.pop(context),
            ),
            
            ListTile(
              leading: const Icon(Icons.help, color: AppColors.info),
              title: const Text('幫助與支援'),
              onTap: () => Navigator.pop(context),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('登出'),
              onTap: () => Navigator.pop(context),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _passUser(UserProfile profile) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已跳過 ${profile.name}'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _startChat(UserProfile profile) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealTimeChatPage(
          chatId: 'chat_${profile.id}',
          otherUserId: profile.id,
          otherUserName: profile.name,
          otherUserPhoto: profile.photos.isNotEmpty ? profile.photos.first : null,
        ),
      ),
    );
  }

  void _likeProfile(UserProfile profile) {
    HapticFeedback.mediumImpact();
    
    // 顯示喜歡動畫
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '已喜歡！',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '如果 ${profile.name} 也喜歡你，你們就會配對成功',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '繼續探索',
                      onPressed: () {
                        Navigator.of(context).pop(); // 關閉對話框
                        Navigator.of(context).pop(); // 返回探索頁面
                      },
                      type: AppButtonType.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: '發送消息',
                      onPressed: () {
                        Navigator.of(context).pop(); // 關閉對話框
                        _startChat(profile);
                      },
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

  Widget _buildOtherUserBumbleStyle(UserProfile profile) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 大型照片輪播區域
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: PageView.builder(
                  itemCount: profile.photos.length,
                  itemBuilder: (context, index) {
                    return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.pink.shade300,
                            Colors.purple.shade300,
                            Colors.blue.shade300,
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 照片占位符
                          const Center(
                            child: Icon(
                              Icons.photo_camera,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                          
                          // 頂部漸變遮罩（用於狀態欄和導航）
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 120,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 底部漸變遮罩（用於基本信息）
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 200,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 照片指示器
                          Positioned(
                            top: 60,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: List.generate(
                                profile.photos.length,
                                (dotIndex) => Expanded(
                                  child: Container(
                                    height: 3,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: dotIndex == index 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // 返回按鈕
                          Positioned(
                            top: 40,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                child: const Icon(
                                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
                            ),
                          ),
                          
                          // 更多選項按鈕
                          Positioned(
                            top: 40,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          
                          // 底部基本信息覆蓋
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                                              '${profile.name}, ${profile.age}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.work,
                                                  color: Colors.white70,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                    Text(
                                                  profile.occupation,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.white70,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  profile.location,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 在線狀態
              Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: Colors.white, size: 8),
                                            SizedBox(width: 4),
                                            Text(
                                              '線上',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // 詳細信息內容
            SliverToBoxAdapter(
              child: _buildDetailedContent(profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedContent(UserProfile profile) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 配對度和標籤區域
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 配對度圓圈
                Container(
                  padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${(profile.completionPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '配對度',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // 標籤區域
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (profile.mbtiType != null)
                        _buildInfoTag(profile.mbtiType!, Icons.psychology, AppColors.secondary),
                      _buildInfoTag(_getDatingModeText(profile.currentDatingMode), Icons.favorite, AppColors.primary),
                      _buildInfoTag('${profile.height}cm', Icons.height, AppColors.info),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // MBTI 深度分析區域
          if (profile.mbtiType != null) _buildMBTIAnalysisSection(profile),
          
          const Divider(height: 1),
          
          // 個人簡介
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '個人簡介',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 詳細個人信息
          _buildDetailedPersonalInfo(profile),
          
          const Divider(height: 1),
          
          // 性格洞察
          _buildPersonalityInsights(profile),
          
          const Divider(height: 1),
          
          // 生活方式與價值觀
          _buildLifestyleAndValues(profile),
          
          const Divider(height: 1),
          
          // 興趣愛好詳細展示
          _buildDetailedInterests(profile),
          
          const Divider(height: 1),
          
          // 約會期望與關係目標
          _buildDatingExpectations(profile),
          
          const Divider(height: 1),
          
          // 深入問答
          _buildPersonalityQuestions(profile),
          
          const Divider(height: 1),
          
          // 更多照片（網格展示）
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '更多照片',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${profile.photos.length} 張',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 6, // 顯示6張照片
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade200,
                            Colors.purple.shade200,
                            Colors.blue.shade200,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100), // 為底部按鈕留空間
        ],
      ),
    );
  }

  Widget _buildMBTIAnalysisSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.mbtiType} - ${_getMBTIDescription(profile.mbtiType!)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '深度性格分析',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // MBTI 四個維度分析
          ..._buildMBTIDimensions(profile.mbtiType!),
          
          const SizedBox(height: 20),
          
          // 性格特質詳細描述
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '性格特質',
                  style: TextStyle(
                        fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMBTIDetailedDescription(profile.mbtiType!),
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 14,
                      ),
                    ),
                  ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 戀愛風格分析
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade50, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '戀愛風格',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                ),
              ),
            ],
          ),
                const SizedBox(height: 8),
                Text(
                  _getMBTILoveStyle(profile.mbtiType!),
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMBTIDimensions(String mbti) {
    final dimensions = [
      {
        'title': '能量來源',
        'type': mbti[0] == 'E' ? '外向型 (E)' : '內向型 (I)',
        'description': mbti[0] == 'E' 
            ? '從社交互動中獲得能量，喜歡與人群在一起，表達開放' 
            : '從獨處中獲得能量，喜歡深度思考，較為內斂',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': '信息接收',
        'type': mbti[1] == 'S' ? '感覺型 (S)' : '直覺型 (N)',
        'description': mbti[1] == 'S' 
            ? '關注具體事實和細節，偏好實際和現實的信息' 
            : '關注可能性和模式，偏好創新和未來導向',
        'icon': Icons.visibility,
        'color': Colors.green,
      },
      {
        'title': '決策方式',
        'type': mbti[2] == 'T' ? '思考型 (T)' : '情感型 (F)',
        'description': mbti[2] == 'T' 
            ? '基於邏輯和客觀分析做決定，重視公平和效率' 
            : '基於價值觀和他人感受做決定，重視和諧和同理心',
        'icon': Icons.psychology,
        'color': Colors.orange,
      },
      {
        'title': '生活態度',
        'type': mbti[3] == 'J' ? '判斷型 (J)' : '感知型 (P)',
        'description': mbti[3] == 'J' 
            ? '喜歡計劃和組織，偏好確定性和結構' 
            : '喜歡靈活和自發，偏好保持選擇開放',
        'icon': Icons.schedule,
        'color': Colors.purple,
      },
    ];

    return dimensions.map((dim) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (dim['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (dim['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            dim['icon'] as IconData,
            color: dim['color'] as Color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
                  '${dim['title']}: ${dim['type']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dim['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dim['description'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildDetailedPersonalInfo(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '詳細資料',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 分類展示個人信息
          _buildInfoCategory('職業發展', [
            _buildInfoRow(Icons.work, '職業', profile.occupation),
            _buildInfoRow(Icons.school, '教育背景', profile.education),
            _buildInfoRow(Icons.trending_up, '職業目標', '成為業界領先的設計師'),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoCategory('基本信息', [
            _buildInfoRow(Icons.height, '身高', '${profile.height} cm'),
            _buildInfoRow(Icons.language, '語言能力', profile.languages.join('、')),
            _buildInfoRow(Icons.location_on, '居住地', profile.location),
            _buildInfoRow(Icons.home, '故鄉', '台北'),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoCategory('生活狀態', [
            _buildInfoRow(Icons.smoke_free, '吸菸', '從不'),
            _buildInfoRow(Icons.local_bar, '飲酒', '社交場合'),
            _buildInfoRow(Icons.fitness_center, '運動習慣', '每週3-4次'),
            _buildInfoRow(Icons.pets, '寵物', '喜歡貓咪'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCategory(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildPersonalityInsights(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.insights,
                color: AppColors.info,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '性格洞察',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 性格雷達圖模擬
              Container(
            padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade50, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '性格特質分析',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPersonalityTrait('外向性', 0.8, Colors.blue),
                _buildPersonalityTrait('開放性', 0.9, Colors.green),
                _buildPersonalityTrait('責任心', 0.7, Colors.orange),
                _buildPersonalityTrait('親和力', 0.85, Colors.purple),
                _buildPersonalityTrait('情緒穩定性', 0.75, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTrait(String trait, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                trait,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleAndValues(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.favorite_border,
                  color: AppColors.secondary,
                  size: 24,
                ),
              SizedBox(width: 8),
              Text(
                '生活方式與價值觀',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildValueCard('人生目標', '追求創意和自由，希望通過設計改變世界', Icons.flag, Colors.green),
          _buildValueCard('理想週末', '和朋友一起探索新咖啡廳，或在家看Netflix放鬆', Icons.weekend, Colors.blue),
          _buildValueCard('重要價值', '誠實、創造力、家庭、個人成長', Icons.star, Colors.orange),
          _buildValueCard('未來規劃', '計劃在30歲前開設自己的設計工作室', Icons.trending_up, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildValueCard(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                    ),
                const SizedBox(height: 4),
                    Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInterests(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '興趣愛好深度探索',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                        color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getCommonInterests(profile).length} 個共同',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 興趣分類展示
          ..._buildInterestCategories(profile),
        ],
      ),
    );
  }

  List<Widget> _buildInterestCategories(UserProfile profile) {
    final categories = {
      '創意藝術': ['攝影', '繪畫', '設計', '音樂'],
      '生活享受': ['旅行', '咖啡', '美食', '電影'],
      '運動健康': ['瑜伽', '健身', '登山', '游泳'],
      '學習成長': ['閱讀', '語言學習', '寫作', '心理學'],
    };

    return categories.entries.map((category) {
      final userHasInterests = category.value.any((interest) => profile.interests.contains(interest));
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
              category.key,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: userHasInterests ? AppColors.primary : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: category.value.map((interest) {
                final isUserInterest = profile.interests.contains(interest);
                final isCommon = _getCommonInterests(profile).contains(interest);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isCommon
                        ? LinearGradient(
                            colors: [AppColors.secondary.withOpacity(0.8), AppColors.primary.withOpacity(0.8)],
                          )
                        : null,
                    color: isUserInterest && !isCommon 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCommon 
                          ? Colors.transparent 
                          : isUserInterest 
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCommon) ...[
                        const Icon(
                          Icons.favorite,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ] else if (isUserInterest) ...[
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        interest,
                        style: TextStyle(
                          color: isCommon 
                              ? Colors.white 
                              : isUserInterest 
                                  ? AppColors.primary 
                                  : Colors.grey[600],
                          fontWeight: isCommon || isUserInterest ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
            ),
          ),
        ],
      ),
    );
              }).toList(),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDatingExpectations(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '約會期望與關係目標',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade50, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpectationItem('約會模式', _getDatingModeText(profile.currentDatingMode), Icons.favorite),
                _buildExpectationItem('理想關係', '尋找能互相成長、支持彼此夢想的伴侶', Icons.group),
                _buildExpectationItem('約會頻率', '每週1-2次，保持個人空間', Icons.schedule),
                _buildExpectationItem('溝通方式', '開放誠實，願意分享內心想法', Icons.chat),
                _buildExpectationItem('未來規劃', '希望找到可以共度人生的伴侶', Icons.home),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityQuestions(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppColors.info,
                size: 24,
      ),
              SizedBox(width: 8),
              Text(
                '深入了解',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._buildQuestionAnswers(),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionAnswers() {
    final qas = [
      {
        'question': '你的理想約會是什麼？',
        'answer': '我喜歡海邊日落時的浪漫晚餐，可以一邊享受美食一邊聊天到深夜。或者一起參觀藝術展覽，分享彼此對美的見解。',
        'icon': Icons.restaurant,
        'color': Colors.pink,
      },
      {
        'question': '你最喜歡的旅行方式？',
        'answer': '我偏愛背包旅行，喜歡深入當地文化，品嘗地道美食，用相機記錄每個難忘瞬間。不喜歡匆忙的團體旅遊。',
        'icon': Icons.backpack,
        'color': Colors.blue,
      },
      {
        'question': '如何度過理想的週末？',
        'answer': '週六會去看展覽或找新的咖啡廳，和朋友拍照打卡。週日喜歡宅在家看Netflix，偶爾畫畫或整理照片。',
        'icon': Icons.weekend,
        'color': Colors.green,
      },
      {
        'question': '什麼事情讓你最有成就感？',
        'answer': '完成一個設計作品並得到客戶認可時，或者幫助朋友解決問題時。我喜歡創造和貢獻的感覺。',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
      },
      {
        'question': '你如何處理壓力？',
        'answer': '我會通過瑜伽和冥想來放鬆，或者約朋友聊天。有時候會一個人去海邊走走，大自然總能讓我平靜下來。',
        'icon': Icons.spa,
        'color': Colors.purple,
      },
    ];

    return qas.map((qa) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (qa['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (qa['color'] as Color).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  qa['icon'] as IconData,
                  color: qa['color'] as Color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    qa['question'] as String,
                    style: TextStyle(
          fontWeight: FontWeight.w600,
                      color: qa['color'] as Color,
                      fontSize: 15,
        ),
      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              qa['answer'] as String,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getMBTIDescription(String mbti) {
    switch (mbti) {
      case 'ENFP':
        return '熱情的夢想家';
      case 'INFJ':
        return '神秘的理想主義者';
      case 'ISFP':
        return '溫柔的藝術家';
      case 'INTJ':
        return '獨立的思想家';
      case 'ESFP':
        return '自由的娛樂者';
      case 'ISFJ':
        return '守護者';
      case 'INFP':
        return '調停者';
      default:
        return '獨特的個性';
    }
  }

  String _getMBTIDetailedDescription(String mbti) {
    switch (mbti) {
      case 'ENFP':
        return '充滿創造力和熱情，善於激勵他人，總是對新事物保持好奇心。喜歡深入的對話和有意義的連結。在感情中會全心投入，重視精神層面的交流。';
      case 'INFJ':
        return '具有深刻的洞察力，關心他人的成長，傾向於追求有意義的關係和深層的理解。是天生的理想主義者，在愛情中尋求靈魂伴侶。';
      case 'ISFP':
        return '溫和而富有同情心，重視和諧與美感，善於欣賞藝術和自然之美。在關係中非常忠誠，會用行動表達愛意。';
      case 'INTJ':
        return '獨立思考，目標導向，善於制定長期計劃，對知識和能力的提升有強烈追求。在感情中理性而專一，重視深度溝通。';
      case 'ESFP':
        return '熱愛生活，善於享受當下，喜歡與人互動，帶給周圍的人歡樂和正能量。在戀愛中充滿激情，重視共同體驗。';
      case 'ISFJ':
        return '體貼溫暖，總是關心他人需求，是天生的照顧者。在感情中非常投入，會為對方著想，創造溫馨的關係。';
      case 'INFP':
        return '理想主義者，重視內在價值和真實性，追求有意義的關係。在愛情中深情而專一，重視精神上的契合。';
      default:
        return '每個人都有獨特的個性特質，讓人想要進一步了解。';
    }
  }

  String _getMBTILoveStyle(String mbti) {
    switch (mbti) {
      case 'ENFP':
        return '在戀愛中充滿激情和創意，喜歡為對方策劃驚喜，重視情感表達和深度溝通。會全心投入關係，但也需要個人空間來保持創造力。';
      case 'INFJ':
        return '在愛情中尋求深層連結，重視靈魂契合度。會默默觀察對方，用心理解對方需求。一旦認定就會非常專一，但也需要時間獨處來充電。';
      case 'ISFP':
        return '表達愛意的方式溫柔而含蓄，更喜歡用行動勝過言語。重視關係中的和諧，會避免衝突，但內心情感非常豐富深刻。';
      case 'INTJ':
        return '在感情中理性而專一，會把戀愛當作長期項目來經營。重視智力上的交流，喜歡和伴侶一起規劃未來，建立穩固的關係基礎。';
      case 'ESFP':
        return '戀愛風格熱情開放，喜歡和伴侶分享生活中的每個精彩瞬間。重視共同體驗和樂趣，會用行動和言語表達愛意。';
      case 'ISFJ':
        return '在愛情中細心體貼，會記住對方的喜好和需求。傾向於傳統的戀愛方式，重視穩定和承諾，會為維護關係付出很多努力。';
      case 'INFP':
        return '在戀愛中深情而真誠，重視價值觀的契合。會用獨特的方式表達愛意，重視關係的真實性和深度，不喜歡表面的浪漫。';
      default:
        return '每個人在愛情中都有獨特的表達方式，值得被理解和珍惜。';
    }
  }

  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherUserActions(UserProfile profile) {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 配對度顯示
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(profile.completionPercentage * 100).toInt()}% 配對度',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '基於共同興趣和價值觀',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (profile.mbtiType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      child: Text(
                        profile.mbtiType!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '不感興趣',
                    onPressed: () => _passUser(profile),
                    type: AppButtonType.outline,
                    icon: Icons.close,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: '發送消息',
                    onPressed: () => _startChat(profile),
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  text: '',
                  onPressed: () => _likeProfile(profile),
                  type: AppButtonType.secondary,
                  icon: Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCommonInterests(UserProfile profile) {
    // 模擬共同興趣（實際應用中會與當前用戶的興趣比較）
    final currentUserInterests = ['旅行', '攝影', '咖啡', '電影', '音樂', '閱讀'];
    return profile.interests.where((interest) => currentUserInterests.contains(interest)).toList();
  }
} 