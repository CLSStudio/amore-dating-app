import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
// 導入個人檔案頁面
import '../profile/enhanced_profile_page.dart';

// 用戶資料模型
class UserProfile {
  final String name;
  final int age;
  final String bio;
  final List<String> images;
  final int distance;
  final String mbti;
  final List<String> interests;
  final String occupation;
  final int compatibility;
  final Map<String, dynamic> personalityInsights;
  final String datingMode;

  UserProfile({
    required this.name,
    required this.age,
    required this.bio,
    required this.images,
    required this.distance,
    required this.mbti,
    required this.interests,
    required this.occupation,
    required this.compatibility,
    this.personalityInsights = const {},
    this.datingMode = 'casual',
  });
}

// 滑動狀態管理
final swipeStateProvider = StateNotifierProvider<SwipeStateNotifier, SwipeState>((ref) {
  return SwipeStateNotifier();
});

class SwipeState {
  final int currentIndex;
  final List<UserProfile> profiles;
  final bool isLoading;
  final SwipeDirection? lastSwipeDirection;
  final UserProfile? lastProfile;

  SwipeState({
    this.currentIndex = 0,
    this.profiles = const [],
    this.isLoading = false,
    this.lastSwipeDirection,
    this.lastProfile,
  });

  SwipeState copyWith({
    int? currentIndex,
    List<UserProfile>? profiles,
    bool? isLoading,
    SwipeDirection? lastSwipeDirection,
    UserProfile? lastProfile,
  }) {
    return SwipeState(
      currentIndex: currentIndex ?? this.currentIndex,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      lastSwipeDirection: lastSwipeDirection ?? this.lastSwipeDirection,
      lastProfile: lastProfile ?? this.lastProfile,
    );
  }
}

enum SwipeDirection { left, right, up }

class SwipeStateNotifier extends StateNotifier<SwipeState> {
  SwipeStateNotifier() : super(SwipeState()) {
    _loadProfiles();
  }

  void _loadProfiles([FilterState? filterState]) {
    state = state.copyWith(isLoading: true);
    
    // 完整的用戶資料庫
    final allProfiles = [
      UserProfile(
        name: 'Sarah Chen',
        age: 25,
        bio: '旅行愛好者，咖啡師，尋找有趣的靈魂一起探索世界 ✨☕',
        images: ['https://picsum.photos/400/600?random=1'],
        distance: 2,
        mbti: 'ENFP',
        interests: ['旅行', '咖啡', '攝影', '音樂', '戶外運動'],
        occupation: '咖啡師 & 自由攝影師',
        compatibility: 92,
        personalityInsights: {
          'energy': 85,
          'creativity': 92,
          'adventure': 89,
          'empathy': 87,
        },
        datingMode: 'serious',
      ),
      UserProfile(
        name: 'Emma Wong',
        age: 28,
        bio: '產品經理 | 瑜伽愛好者 | 週末探店達人 🧘‍♀️🍜',
        images: ['https://picsum.photos/400/600?random=2'],
        distance: 5,
        mbti: 'INFJ',
        interests: ['瑜伽', '美食', '閱讀', '電影', '冥想'],
        occupation: '產品經理',
        compatibility: 87,
        personalityInsights: {
          'energy': 65,
          'creativity': 78,
          'adventure': 72,
          'empathy': 95,
        },
        datingMode: 'casual',
      ),
      UserProfile(
        name: 'Lily Zhang',
        age: 26,
        bio: '藝術治療師，喜歡用色彩治癒世界 🎨💚',
        images: ['https://picsum.photos/400/600?random=3'],
        distance: 3,
        mbti: 'ISFP',
        interests: ['繪畫', '藝術治療', '園藝', '音樂', '動物保護'],
        occupation: '藝術治療師',
        compatibility: 78,
        personalityInsights: {
          'energy': 70,
          'creativity': 95,
          'adventure': 60,
          'empathy': 90,
        },
        datingMode: 'friendship',
      ),
      UserProfile(
        name: 'Amy Liu',
        age: 24,
        bio: 'UI/UX 設計師，熱愛創造美好的數位體驗 💻✨',
        images: ['https://picsum.photos/400/600?random=4'],
        distance: 1,
        mbti: 'INFP',
        interests: ['設計', '科技', '電影', '文學', '咖啡'],
        occupation: 'UI/UX 設計師',
        compatibility: 95,
        personalityInsights: {
          'energy': 75,
          'creativity': 88,
          'adventure': 80,
          'empathy': 85,
        },
        datingMode: 'serious',
      ),
      UserProfile(
        name: 'Jessica Wu',
        age: 30,
        bio: '律師，熱愛正義與公平，業餘時間喜歡登山 ⚖️🏔️',
        images: ['https://picsum.photos/400/600?random=5'],
        distance: 8,
        mbti: 'ENTJ',
        interests: ['法律', '登山', '閱讀', '辯論', '社會議題'],
        occupation: '律師',
        compatibility: 82,
        personalityInsights: {
          'energy': 90,
          'creativity': 70,
          'adventure': 85,
          'empathy': 75,
        },
        datingMode: 'serious',
      ),
      UserProfile(
        name: 'Michelle Lee',
        age: 22,
        bio: '大學生，主修心理學，喜歡探索人心的奧秘 🧠💭',
        images: ['https://picsum.photos/400/600?random=6'],
        distance: 15,
        mbti: 'INFJ',
        interests: ['心理學', '音樂', '寫作', '電影', '哲學'],
        occupation: '大學生',
        compatibility: 88,
        personalityInsights: {
          'energy': 60,
          'creativity': 85,
          'adventure': 65,
          'empathy': 95,
        },
        datingMode: 'casual',
      ),
    ];
    
    // 應用篩選條件
    List<UserProfile> filteredProfiles = allProfiles;
    
    if (filterState != null) {
      filteredProfiles = allProfiles.where((profile) {
        // 年齡篩選
        if (profile.age < filterState.ageRange.start || profile.age > filterState.ageRange.end) {
          return false;
        }
        
        // 距離篩選
        if (profile.distance > filterState.maxDistance) {
          return false;
        }
        
        // MBTI 篩選
        if (filterState.selectedMBTI.isNotEmpty && !filterState.selectedMBTI.contains(profile.mbti)) {
          return false;
        }
        
        // 交友模式篩選
        if (filterState.selectedDatingModes.isNotEmpty && !filterState.selectedDatingModes.contains(profile.datingMode)) {
          return false;
        }
        
        // 興趣篩選
        if (filterState.selectedInterests.isNotEmpty) {
          bool hasCommonInterest = profile.interests.any((interest) => 
            filterState.selectedInterests.contains(interest));
          if (!hasCommonInterest) {
            return false;
          }
        }
        
        return true;
      }).toList();
    }
    
    state = state.copyWith(profiles: filteredProfiles, isLoading: false, currentIndex: 0);
  }

  void applyFilters(FilterState filterState) {
    _loadProfiles(filterState);
  }

  void swipe(SwipeDirection direction) {
    if (state.currentIndex >= state.profiles.length) return;
    
    final currentProfile = state.profiles[state.currentIndex];
    
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      lastSwipeDirection: direction,
      lastProfile: currentProfile,
    );
  }

  void undoSwipe() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        lastSwipeDirection: null,
        lastProfile: null,
      );
    }
  }

  void loadMoreProfiles() {
    // 實際應用中會從 API 載入更多資料
    _loadProfiles();
  }
}

// 篩選狀態管理
final filterStateProvider = StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
  return FilterStateNotifier();
});

class FilterState {
  final RangeValues ageRange;
  final double maxDistance;
  final Set<String> selectedMBTI;
  final Set<String> selectedDatingModes;
  final Set<String> selectedInterests;

  FilterState({
    this.ageRange = const RangeValues(22, 35),
    this.maxDistance = 10,
    this.selectedMBTI = const {},
    this.selectedDatingModes = const {'serious'},
    this.selectedInterests = const {},
  });

  FilterState copyWith({
    RangeValues? ageRange,
    double? maxDistance,
    Set<String>? selectedMBTI,
    Set<String>? selectedDatingModes,
    Set<String>? selectedInterests,
  }) {
    return FilterState(
      ageRange: ageRange ?? this.ageRange,
      maxDistance: maxDistance ?? this.maxDistance,
      selectedMBTI: selectedMBTI ?? this.selectedMBTI,
      selectedDatingModes: selectedDatingModes ?? this.selectedDatingModes,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

class FilterStateNotifier extends StateNotifier<FilterState> {
  FilterStateNotifier() : super(FilterState());

  void updateAgeRange(RangeValues range) {
    state = state.copyWith(ageRange: range);
  }

  void updateMaxDistance(double distance) {
    state = state.copyWith(maxDistance: distance);
  }

  void toggleMBTI(String mbti) {
    final newSet = Set<String>.from(state.selectedMBTI);
    if (newSet.contains(mbti)) {
      newSet.remove(mbti);
    } else {
      newSet.add(mbti);
    }
    state = state.copyWith(selectedMBTI: newSet);
  }

  void toggleDatingMode(String mode) {
    final newSet = Set<String>.from(state.selectedDatingModes);
    if (newSet.contains(mode)) {
      newSet.remove(mode);
    } else {
      newSet.add(mode);
    }
    state = state.copyWith(selectedDatingModes: newSet);
  }

  void toggleInterest(String interest) {
    final newSet = Set<String>.from(state.selectedInterests);
    if (newSet.contains(interest)) {
      newSet.remove(interest);
    } else {
      newSet.add(interest);
    }
    state = state.copyWith(selectedInterests: newSet);
  }

  void reset() {
    state = FilterState();
  }
}

class EnhancedSwipeExperience extends ConsumerStatefulWidget {
  const EnhancedSwipeExperience({super.key});

  @override
  ConsumerState<EnhancedSwipeExperience> createState() => _EnhancedSwipeExperienceState();
}

class _EnhancedSwipeExperienceState extends ConsumerState<EnhancedSwipeExperience>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _matchAnimationController;
  late AnimationController _reactionAnimationController;
  
  late Animation<double> _cardRotation;
  late Animation<Offset> _cardPosition;
  late Animation<double> _cardScale;
  late Animation<double> _matchAnimation;
  late Animation<double> _reactionAnimation;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _reactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardRotation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut),
    );
    
    _cardPosition = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut),
    );
    
    _cardScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut),
    );

    _matchAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _matchAnimationController, curve: Curves.elasticOut),
    );

    _reactionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _reactionAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _matchAnimationController.dispose();
    _reactionAnimationController.dispose();
    super.dispose();
  }

  void _onSwipe(SwipeDirection direction) {
    final swipeState = ref.read(swipeStateProvider);
    if (swipeState.currentIndex >= swipeState.profiles.length) return;

    // 設置動畫
    _cardRotation = Tween<double>(
      begin: 0,
      end: direction == SwipeDirection.left ? -0.3 : 0.3,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut));
    
    _cardPosition = Tween<Offset>(
      begin: Offset.zero,
      end: direction == SwipeDirection.left 
          ? const Offset(-2, 0) 
          : direction == SwipeDirection.right 
              ? const Offset(2, 0) 
              : const Offset(0, -2),
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut));

    _cardAnimationController.forward().then((_) {
      ref.read(swipeStateProvider.notifier).swipe(direction);
      _cardAnimationController.reset();
      
      // 如果是右滑（喜歡），播放匹配動畫
      if (direction == SwipeDirection.right) {
        _playMatchAnimation();
      }
    });
    
    // 播放反應動畫
    _reactionAnimationController.forward().then((_) {
      _reactionAnimationController.reset();
    });
  }

  void _playMatchAnimation() {
    // 模擬配對成功（30% 機率）
    if (math.Random().nextDouble() < 0.3) {
      _matchAnimationController.forward().then((_) {
        _matchAnimationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeStateProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: swipeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                  _buildModernHeader(),
                  _buildActiveUsers(),
                  _buildSwipeSection(swipeState),
                  _buildSmartRecommendations(),
                  _buildActionRow(),
                ],
              ),
            ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 左側：位置和時間
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade400, Colors.purple.shade400],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '香港中環',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} · ${_getActiveUsersCount()} 人在線',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
        ),
              ],
            ),
          ),
          
          // 右側：篩選和通知
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.tune,
                onTap: _showFilterDialog,
                hasNotification: true,
              ),
              const SizedBox(width: 12),
              _buildHeaderButton(
                icon: Icons.favorite_border,
                onTap: () => _showLikesReceived(),
                hasNotification: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: Colors.grey[700],
              size: 20,
            ),
            if (hasNotification)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUsers() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '線上用戶',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_getActiveUsersCount()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAllActiveUsers(),
                child: Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 14,
                fontWeight: FontWeight.w600,
                    color: Colors.pink.shade400,
                  ),
              ),
            ),
          ],
        ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildActiveUserStory(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUserStory(int index) {
    final names = ['Sarah', 'Emma', 'Lily', 'Amy', 'Jessica', 'Michelle', 'Sophie', 'Nina'];
    final isOnline = math.Random().nextBool();
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 50, // 固定寬度
      child: Column(
        mainAxisSize: MainAxisSize.min, // 重要：使用最小尺寸
        children: [
          Flexible( // 使用 Flexible 包裝頭像
            child: Stack(
            children: [
        Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOnline 
                        ? [Colors.green.shade400, Colors.blue.shade400]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.primaries[index % Colors.primaries.length].shade300,
                            Colors.primaries[index % Colors.primaries.length].shade500,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          names[index][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          ),
          const SizedBox(height: 2), // 減少間距
          Flexible( // 使用 Flexible 包裝文字
            child: Text(
            names[index],
            style: TextStyle(
                fontSize: 10, // 稍微減小字體
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              ),
              maxLines: 1, // 限制為一行
              overflow: TextOverflow.ellipsis, // 超出時顯示省略號
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSwipeSection(SwipeState swipeState) {
    if (swipeState.currentIndex >= swipeState.profiles.length) {
      return Expanded(child: _buildNoMoreCards());
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Stack(
      alignment: Alignment.center,
      children: [
            // 背景卡片們（製造深度感）
            for (int i = 2; i >= 0; i--)
              if (swipeState.currentIndex + i < swipeState.profiles.length)
                Positioned(
                  top: i * 8.0,
                  child: Transform.scale(
                    scale: 1 - (i * 0.05),
                    child: _buildModernProfileCard(
                      swipeState.profiles[swipeState.currentIndex + i],
                      isBackground: i > 0,
                      stackIndex: i,
                    ),
                  ),
          ),
        
            // 主卡片動畫
        AnimatedBuilder(
          animation: _cardAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: _cardPosition.value * MediaQuery.of(context).size.width,
              child: Transform.rotate(
                angle: _cardRotation.value,
                    child: _buildModernProfileCard(
                    swipeState.profiles[swipeState.currentIndex],
                      isBackground: false,
                      stackIndex: 0,
                ),
              ),
            );
          },
        ),
        
            // 滑動提示覆蓋層
            _buildSwipeOverlay(),
            
            // 匹配動畫
        AnimatedBuilder(
          animation: _matchAnimation,
          builder: (context, child) {
            return _matchAnimation.value > 0
                    ? _buildMatchAnimation()
                : const SizedBox.shrink();
          },
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildModernProfileCard(UserProfile profile, {bool isBackground = false, int stackIndex = 0}) {
    final cardWidth = MediaQuery.of(context).size.width - 40;
    final cardHeight = MediaQuery.of(context).size.height * 0.65;
    
    return GestureDetector(
      onTap: isBackground ? null : () => _viewProfile(profile),
      child: Container(
        width: cardWidth,
        height: cardHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isBackground ? 0.1 : 0.15),
            blurRadius: isBackground ? 10 : 20,
              offset: Offset(0, isBackground ? 5 : 8),
          ),
        ],
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
        child: Stack(
            fit: StackFit.expand,
          children: [
              // 背景漸變
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.primaries[profile.name.hashCode % Colors.primaries.length].shade300,
                      Colors.primaries[profile.name.hashCode % Colors.primaries.length].shade600,
                      Colors.primaries[(profile.name.hashCode + 1) % Colors.primaries.length].shade400,
                    ],
                ),
              ),
            ),
              
              // 照片占位符
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${profile.images.length} 張照片',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                ),
                    ),
                  ],
              ),
            ),
            
            // 漸變覆蓋層
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                      Colors.black.withOpacity(0.7),
                  ],
                    stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
              // 內容信息
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
                child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                  children: [
                      // 主要信息
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                profile.occupation,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                        ),
                                ),
                              ),
                            ],
                          ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${profile.distance} 公里',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // 配對度圓圈
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${profile.compatibility}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '配對',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                      // 標籤行
                    Row(
                      children: [
                          _buildInfoChip(profile.mbti, Icons.psychology),
                          const SizedBox(width: 8),
                          _buildInfoChip(_getDatingModeText(profile.datingMode), Icons.favorite),
                          const SizedBox(width: 8),
                          _buildInfoChip('${profile.interests.length} 興趣', Icons.interests),
                      ],
                    ),
                    
                      const SizedBox(height: 12),
                    
                      // 簡介預覽
                    Text(
                      profile.bio,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        height: 1.4,
                      ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                    ),
              ),
                    
              // 在線狀態
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                          ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                              color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '線上',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            ],
            ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
              color: Colors.white,
            size: 14,
            ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendations() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.amber.shade600,
                size: 20,
      ),
              const SizedBox(width: 8),
              const Text(
                'AI 智能推薦',
                style: TextStyle(
                  fontSize: 16,
          fontWeight: FontWeight.bold,
                  color: Colors.black87,
      ),
              ),
              const Spacer(),
              Text(
                '更新中',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.shade200,
              ),
      ),
      child: Row(
        children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Text(
                        '今日推薦焦點',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '根據你的興趣，今天有 3 位高配對度用戶在線',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.amber.shade600,
                  size: 16,
                ),
              ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
                  icon: Icons.close,
            color: Colors.grey.shade600,
            size: 56,
                  onTap: () => _onSwipe(SwipeDirection.left),
                ),
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue.shade500,
            size: 48,
            onTap: () => _onSwipe(SwipeDirection.up),
          ),
          _buildActionButton(
                  icon: Icons.favorite,
            color: Colors.pink.shade500,
            size: 64,
                  onTap: () => _onSwipe(SwipeDirection.right),
          ),
          _buildActionButton(
            icon: Icons.flash_on,
            color: Colors.purple.shade500,
            size: 48,
            onTap: _showBoostDialog,
                ),
          _buildActionButton(
            icon: Icons.undo,
            color: Colors.amber.shade600,
            size: 56,
            onTap: () => ref.read(swipeStateProvider.notifier).undoSwipe(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildSwipeOverlay() {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        if (_cardAnimationController.value == 0) return const SizedBox.shrink();
        
        final direction = _cardRotation.value > 0 ? 'right' : 'left';
        final opacity = _cardAnimationController.value;
        
        return Positioned.fill(
          child: Container(
            margin: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: direction == 'right' 
                    ? Colors.green.withOpacity(opacity)
                    : Colors.red.withOpacity(opacity),
                width: 4,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: direction == 'right' 
                      ? Colors.green.withOpacity(opacity * 0.9)
                      : Colors.red.withOpacity(opacity * 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  direction == 'right' ? '喜歡 ❤️' : '跳過 ✋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchAnimation() {
    return Positioned.fill(
      child: Container(
        color: Colors.pink.withOpacity(0.8),
        child: Center(
          child: Transform.scale(
            scale: _matchAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.purple.shade400],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '配對成功！',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '你們互相喜歡對方',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getActiveUsersCount() {
    return 23 + math.Random().nextInt(15);
  }

  String _getDatingModeText(String mode) {
    switch (mode) {
      case 'casual': return '輕鬆交友';
      case 'serious': return '認真交往';
      case 'friendship': return '尋找朋友';
      default: return mode;
    }
  }

  void _viewProfile(UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedProfilePage(
          isOwnProfile: false,
          userId: profile.name.hashCode.toString(),
        ),
      ),
    );
  }

  void _showAllActiveUsers() {
    // 顯示所有線上用戶
  }

  void _showLikesReceived() {
    // 顯示收到的喜歡
  }

  void _showBoostDialog() {
    // 顯示加速功能對話框
  }

  Widget _buildNoMoreCards() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            '沒有更多用戶了',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '嘗試調整篩選條件或稍後再來',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(swipeStateProvider.notifier).loadMoreProfiles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('重新載入'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final filterState = ref.read(filterStateProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentFilter = ref.watch(filterStateProvider);
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
          color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
        ),
        child: Column(
          children: [
                // 拖拽指示器
            Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
              ),
                
                // 標題
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        '篩選條件',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref.read(filterStateProvider.notifier).reset();
                        },
                        child: const Text('重置'),
                      ),
                    ],
              ),
            ),
            
                const Divider(),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 年齡範圍
                        _buildFilterSection(
                          title: '年齡範圍',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('18'),
                                  Expanded(
                                    child: RangeSlider(
                                      values: currentFilter.ageRange,
                                      min: 18,
                                      max: 50,
                                      divisions: 32,
                                      labels: RangeLabels(
                                        currentFilter.ageRange.start.round().toString(),
                                        currentFilter.ageRange.end.round().toString(),
                                      ),
                                      onChanged: (values) {
                                        ref.read(filterStateProvider.notifier).updateAgeRange(values);
                                      },
                                    ),
                                  ),
                                  const Text('50'),
                                ],
                              ),
                              Text('${currentFilter.ageRange.start.round()} - ${currentFilter.ageRange.end.round()} 歲'),
                            ],
              ),
            ),
            
            const SizedBox(height: 24),
            
                        // 距離範圍
                        _buildFilterSection(
                          title: '距離範圍',
                          child: Column(
                            children: [
            Row(
              children: [
                                  const Text('1km'),
                Expanded(
                                    child: Slider(
                                      value: currentFilter.maxDistance,
                                      min: 1,
                                      max: 50,
                                      divisions: 49,
                                      label: '${currentFilter.maxDistance.round()}km',
                                      onChanged: (value) {
                                        ref.read(filterStateProvider.notifier).updateMaxDistance(value);
                                      },
                                    ),
                                  ),
                                  const Text('50km'),
                                ],
                              ),
                              Text('${currentFilter.maxDistance.round()} 公里內'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // MBTI 類型
                        _buildFilterSection(
                          title: 'MBTI 類型',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'ENFP', 'INFP', 'ENFJ', 'INFJ',
                              'ENTP', 'INTP', 'ENTJ', 'INTJ',
                              'ESFP', 'ISFP', 'ESFJ', 'ISFJ',
                              'ESTP', 'ISTP', 'ESTJ', 'ISTJ',
                            ].map((mbti) => FilterChip(
                              label: Text(mbti),
                              selected: currentFilter.selectedMBTI.contains(mbti),
                              onSelected: (selected) {
                                ref.read(filterStateProvider.notifier).toggleMBTI(mbti);
                              },
                              selectedColor: Colors.pink.shade100,
                              checkmarkColor: Colors.pink,
                            )).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 交友模式
                        _buildFilterSection(
                          title: '交友模式',
                          child: Column(
                            children: [
                              CheckboxListTile(
                                title: const Text('認真交往'),
                                value: currentFilter.selectedDatingModes.contains('serious'),
                                onChanged: (value) {
                                  ref.read(filterStateProvider.notifier).toggleDatingMode('serious');
                                },
                                activeColor: Colors.pink,
                              ),
                              CheckboxListTile(
                                title: const Text('輕鬆交友'),
                                value: currentFilter.selectedDatingModes.contains('casual'),
                                onChanged: (value) {
                                  ref.read(filterStateProvider.notifier).toggleDatingMode('casual');
                                },
                                activeColor: Colors.pink,
                              ),
                              CheckboxListTile(
                                title: const Text('尋找朋友'),
                                value: currentFilter.selectedDatingModes.contains('friendship'),
                                onChanged: (value) {
                                  ref.read(filterStateProvider.notifier).toggleDatingMode('friendship');
                                },
                                activeColor: Colors.pink,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 興趣愛好
                        _buildFilterSection(
                          title: '興趣愛好',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              '旅行', '攝影', '音樂', '電影', '閱讀',
                              '運動', '美食', '藝術', '科技', '遊戲',
                              '瑜伽', '咖啡', '設計', '法律', '心理學',
                            ].map((interest) => FilterChip(
                              label: Text(interest),
                              selected: currentFilter.selectedInterests.contains(interest),
                              onSelected: (selected) {
                                ref.read(filterStateProvider.notifier).toggleInterest(interest);
                    },
                              selectedColor: Colors.pink.shade100,
                              checkmarkColor: Colors.pink,
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 底部按鈕
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.pink.shade400),
                      ),
                          child: Text(
                            '取消',
                            style: TextStyle(color: Colors.pink.shade400),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                          child: const Text(
                            '應用篩選',
                            style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
                  ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _applyFilters() {
    final filterState = ref.read(filterStateProvider);
    
    // 應用篩選條件到用戶列表
    ref.read(swipeStateProvider.notifier).applyFilters(filterState);
    
    // 顯示篩選結果
    final swipeState = ref.read(swipeStateProvider);
    final filteredCount = swipeState.profiles.length;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('篩選完成，找到 $filteredCount 個符合條件的用戶'),
        backgroundColor: Colors.pink.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
} 