import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
// 導入個人檔案頁面
import '../profile/enhanced_profile_page.dart';

// 配對數據模型
class Match {
  final String id;
  final String name;
  final int age;
  final String avatar;
  final String bio;
  final List<String> interests;
  final DateTime matchTime;
  final bool isNewMatch;
  final bool isOnline;
  final int compatibilityScore;
  final String location;

  Match({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    required this.bio,
    required this.interests,
    required this.matchTime,
    this.isNewMatch = false,
    this.isOnline = false,
    required this.compatibilityScore,
    required this.location,
  });
}

// 模擬配對數據
final sampleMatches = [
  Match(
    id: '1',
    name: '小雅',
    age: 25,
    avatar: '👩‍🦰',
    bio: '熱愛攝影和旅行的設計師',
    interests: ['攝影', '旅行', '設計', '咖啡'],
    matchTime: DateTime.now().subtract(const Duration(minutes: 30)),
    isNewMatch: true,
    isOnline: true,
    compatibilityScore: 92,
    location: '中環',
  ),
  Match(
    id: '2',
    name: '美玲',
    age: 26,
    avatar: '🧘‍♀️',
    bio: '瑜伽教練，追求健康生活',
    interests: ['瑜伽', '健身', '素食', '冥想'],
    matchTime: DateTime.now().subtract(const Duration(hours: 2)),
    isNewMatch: true,
    isOnline: false,
    compatibilityScore: 88,
    location: '銅鑼灣',
  ),
  Match(
    id: '3',
    name: '詩婷',
    age: 24,
    avatar: '👩‍🎨',
    bio: '藝術家，喜歡創作和音樂',
    interests: ['繪畫', '音樂', '展覽', '文學'],
    matchTime: DateTime.now().subtract(const Duration(hours: 5)),
    isNewMatch: false,
    isOnline: true,
    compatibilityScore: 85,
    location: '尖沙咀',
  ),
  Match(
    id: '4',
    name: '志明',
    age: 28,
    avatar: '👨‍💻',
    bio: '軟件工程師，電影愛好者',
    interests: ['編程', '電影', '遊戲', '科技'],
    matchTime: DateTime.now().subtract(const Duration(days: 1)),
    isNewMatch: false,
    isOnline: false,
    compatibilityScore: 79,
    location: '觀塘',
  ),
  Match(
    id: '5',
    name: '建華',
    age: 30,
    avatar: '👨‍🍳',
    bio: '主廚，美食探索家',
    interests: ['烹飪', '美食', '紅酒', '旅行'],
    matchTime: DateTime.now().subtract(const Duration(days: 2)),
    isNewMatch: false,
    isOnline: true,
    compatibilityScore: 83,
    location: '灣仔',
  ),
];

class EnhancedMatchesPage extends ConsumerStatefulWidget {
  const EnhancedMatchesPage({super.key});

  @override
  ConsumerState<EnhancedMatchesPage> createState() => _EnhancedMatchesPageState();
}

class _EnhancedMatchesPageState extends ConsumerState<EnhancedMatchesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewMatches(),
                _buildAllMatches(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppBorderRadius.bottomOnly,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '💕 配對',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _showSearchDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_getNewMatchesCount()} 個新配對 • ${sampleMatches.length} 個總配對',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.h6,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('新配對'),
                if (_getNewMatchesCount() > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_getNewMatchesCount()}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: '所有配對'),
        ],
      ),
    );
  }

  Widget _buildNewMatches() {
    final newMatches = sampleMatches.where((match) => match.isNewMatch).toList();
    
    if (newMatches.isEmpty) {
      return const AppEmptyState(
        icon: Icons.favorite_border,
        title: '還沒有新配對',
        subtitle: '繼續滑動探索更多人吧！',
        actionText: '開始探索',
      );
    }

    return Column(
      children: [
        // 新配對慶祝區域
        Container(
          margin: AppSpacing.pagePadding,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: AppBorderRadius.large,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 恭喜！',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '你有 ${newMatches.length} 個新配對',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 新配對網格
        Expanded(
          child: GridView.builder(
            padding: AppSpacing.pagePadding,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: newMatches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(newMatches[index], isNew: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllMatches() {
    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: sampleMatches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(sampleMatches[index]);
      },
    );
  }

  Widget _buildMatchCard(Match match, {bool isNew = false}) {
    return AppCard(
      onTap: () => _viewProfile(match),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頭像和狀態
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Center(
                  child: Text(
                    match.avatar,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              
              // 新配對標記
              if (isNew)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
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
                ),
              
              // 在線狀態
              if (match.isOnline)
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // 基本信息
          Text(
            '${match.name}, ${match.age}',
            style: AppTextStyles.h6,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          // 位置
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  match.location,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // 配對度
          Row(
            children: [
              const Icon(
                Icons.favorite,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${match.compatibilityScore}% 配對',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // 興趣標籤
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: match.interests.take(2).map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  interest,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '聊天',
                  onPressed: () => _startChat(match),
                  size: AppButtonSize.small,
                  type: AppButtonType.outline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  iconSize: 20,
                  onPressed: () => _likeMatch(match),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getNewMatchesCount() {
    return sampleMatches.where((match) => match.isNewMatch).length;
  }

  void _viewProfile(Match match) {
    // 導航到完整的個人檔案頁面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedProfilePage(
          isOwnProfile: false,
          userId: match.id,
        ),
      ),
    );
  }

  void _startChat(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('開始與 ${match.name} 聊天'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _likeMatch(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已喜歡 ${match.name}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索配對'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '輸入姓名...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          AppButton(
            text: '搜索',
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('篩選配對'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('只顯示在線用戶'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('高配對度優先'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          AppButton(
            text: '應用',
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
} 