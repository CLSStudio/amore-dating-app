import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 排行榜用戶模型
class RankingUser {
  final String id;
  final String name;
  final int age;
  final String profilePhoto;
  final int hotScore;
  final int rank;
  final int likesReceived;
  final int profileViews;
  final String location;
  final List<String> interests;
  final bool isVerified;

  RankingUser({
    required this.id,
    required this.name,
    required this.age,
    required this.profilePhoto,
    required this.hotScore,
    required this.rank,
    required this.likesReceived,
    required this.profileViews,
    required this.location,
    required this.interests,
    this.isVerified = false,
  });
}

// 排行榜設置模型
class RankingSettings {
  final bool participateInRanking;
  final bool showInGlobalRanking;
  final bool showInLocalRanking;
  final bool allowProfileViewing;

  RankingSettings({
    this.participateInRanking = false,
    this.showInGlobalRanking = false,
    this.showInLocalRanking = false,
    this.allowProfileViewing = true,
  });

  RankingSettings copyWith({
    bool? participateInRanking,
    bool? showInGlobalRanking,
    bool? showInLocalRanking,
    bool? allowProfileViewing,
  }) {
    return RankingSettings(
      participateInRanking: participateInRanking ?? this.participateInRanking,
      showInGlobalRanking: showInGlobalRanking ?? this.showInGlobalRanking,
      showInLocalRanking: showInLocalRanking ?? this.showInLocalRanking,
      allowProfileViewing: allowProfileViewing ?? this.allowProfileViewing,
    );
  }
}

// 排行榜狀態管理
final rankingProvider = StateNotifierProvider<RankingNotifier, List<RankingUser>>((ref) {
  return RankingNotifier();
});

final rankingSettingsProvider = StateNotifierProvider<RankingSettingsNotifier, RankingSettings>((ref) {
  return RankingSettingsNotifier();
});

class RankingNotifier extends StateNotifier<List<RankingUser>> {
  RankingNotifier() : super([]) {
    _loadRankingData();
  }

  void _loadRankingData() {
    // 模擬載入排行榜數據
    final users = [
      RankingUser(
        id: '1',
        name: 'Emma Chen',
        age: 25,
        profilePhoto: 'https://picsum.photos/400/600?random=1',
        hotScore: 9850,
        rank: 1,
        likesReceived: 1247,
        profileViews: 5632,
        location: '中環',
        interests: ['旅行', '攝影', '美食'],
        isVerified: true,
      ),
      RankingUser(
        id: '2',
        name: 'Sarah Wong',
        age: 28,
        profilePhoto: 'https://picsum.photos/400/600?random=2',
        hotScore: 9720,
        rank: 2,
        likesReceived: 1156,
        profileViews: 4987,
        location: '銅鑼灣',
        interests: ['健身', '音樂', '藝術'],
        isVerified: true,
      ),
      RankingUser(
        id: '3',
        name: 'Amy Liu',
        age: 26,
        profilePhoto: 'https://picsum.photos/400/600?random=3',
        hotScore: 9580,
        rank: 3,
        likesReceived: 1089,
        profileViews: 4521,
        location: '尖沙咀',
        interests: ['閱讀', '電影', '咖啡'],
        isVerified: true,
      ),
      RankingUser(
        id: '4',
        name: 'Jessica Li',
        age: 24,
        profilePhoto: 'https://picsum.photos/400/600?random=4',
        hotScore: 9420,
        rank: 4,
        likesReceived: 987,
        profileViews: 4123,
        location: '旺角',
        interests: ['舞蹈', '時尚', '美妝'],
      ),
      RankingUser(
        id: '5',
        name: 'Michelle Tam',
        age: 27,
        profilePhoto: 'https://picsum.photos/400/600?random=5',
        hotScore: 9280,
        rank: 5,
        likesReceived: 923,
        profileViews: 3876,
        location: '灣仔',
        interests: ['瑜伽', '素食', '環保'],
      ),
      // 添加更多用戶...
      for (int i = 6; i <= 20; i++)
        RankingUser(
          id: '$i',
          name: 'User ${String.fromCharCode(64 + i)}',
          age: 22 + (i % 8),
          profilePhoto: 'https://picsum.photos/400/600?random=$i',
          hotScore: 9280 - (i - 5) * 150,
          rank: i,
          likesReceived: 923 - (i - 5) * 50,
          profileViews: 3876 - (i - 5) * 200,
          location: ['中環', '銅鑼灣', '尖沙咀', '旺角', '灣仔'][i % 5],
          interests: [
            ['運動', '健身'],
            ['音樂', '電影'],
            ['美食', '旅行'],
            ['藝術', '設計'],
            ['科技', '遊戲']
          ][i % 5],
        ),
    ];

    state = users;
  }

  void refreshRanking() {
    _loadRankingData();
  }
}

class RankingSettingsNotifier extends StateNotifier<RankingSettings> {
  RankingSettingsNotifier() : super(RankingSettings());

  void updateParticipation(bool participate) {
    state = state.copyWith(participateInRanking: participate);
  }

  void updateGlobalRanking(bool show) {
    state = state.copyWith(showInGlobalRanking: show);
  }

  void updateLocalRanking(bool show) {
    state = state.copyWith(showInLocalRanking: show);
  }

  void updateProfileViewing(bool allow) {
    state = state.copyWith(allowProfileViewing: allow);
  }
}

class HotRankingPage extends ConsumerStatefulWidget {
  const HotRankingPage({super.key});

  @override
  ConsumerState<HotRankingPage> createState() => _HotRankingPageState();
}

class _HotRankingPageState extends ConsumerState<HotRankingPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankings = ref.watch(rankingProvider);
    final settings = ref.watch(rankingSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('熱度排行榜'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showRankingSettings(context),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              ref.read(rankingProvider.notifier).refreshRanking();
              _animationController.reset();
              _animationController.forward();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE91E63),
          tabs: const [
            Tab(text: '全球排行'),
            Tab(text: '本地排行'),
            Tab(text: '我的排名'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGlobalRanking(rankings),
            _buildLocalRanking(rankings),
            _buildMyRanking(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalRanking(List<RankingUser> rankings) {
    return Column(
      children: [
        // 頂部三甲
        _buildTopThree(rankings.take(3).toList()),
        
        // 排行榜列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rankings.length - 3,
            itemBuilder: (context, index) {
              final user = rankings[index + 3];
              return _buildRankingCard(user, index + 3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocalRanking(List<RankingUser> rankings) {
    // 篩選香港本地用戶
    final localUsers = rankings.where((user) => 
      ['中環', '銅鑼灣', '尖沙咀', '旺角', '灣仔'].contains(user.location)
    ).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFFE91E63),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '香港地區排行榜',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        
        // 本地頂部三甲
        _buildTopThree(localUsers.take(3).toList()),
        
        // 本地排行榜列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: localUsers.length - 3,
            itemBuilder: (context, index) {
              final user = localUsers[index + 3];
              return _buildRankingCard(user, index + 3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyRanking(RankingSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 我的排名卡片
          _buildMyRankingCard(),
          
          const SizedBox(height: 24),
          
          // 排行榜設置
          _buildRankingSettingsCard(settings),
          
          const SizedBox(height: 24),
          
          // 提升熱度建議
          _buildHotnessTips(),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<RankingUser> topUsers) {
    if (topUsers.length < 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 第二名
          _buildPodiumUser(topUsers[1], 2, Colors.grey.shade400),
          // 第一名
          _buildPodiumUser(topUsers[0], 1, Colors.amber),
          // 第三名
          _buildPodiumUser(topUsers[2], 3, Colors.brown.shade300),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(RankingUser user, int rank, Color medalColor) {
    final isFirst = rank == 1;
    final size = isFirst ? 80.0 : 70.0;
    
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: size / 2,
              backgroundImage: NetworkImage(user.profilePhoto),
            ),
            if (user.isVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            Positioned(
              top: -5,
              left: size / 2 - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: TextStyle(
            fontSize: isFirst ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${user.hotScore}',
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(RankingUser user, int displayIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 排名
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(user.rank).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${user.rank}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(user.rank),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 頭像
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.profilePhoto),
              ),
              if (user.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // 用戶信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user.age}歲',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: user.interests.take(2).map((interest) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
          
          // 熱度分數
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${user.hotScore}',
                  style: const TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '熱度',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.1),
            const Color(0xFFE91E63).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://picsum.photos/400/600?random=99'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '我的排名',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '#156',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '熱度: 7,234',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('檔案瀏覽', '2,341'),
              ),
              Expanded(
                child: _buildStatItem('收到喜歡', '187'),
              ),
              Expanded(
                child: _buildStatItem('成功配對', '23'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingSettingsCard(RankingSettings settings) {
    final notifier = ref.read(rankingSettingsProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '排行榜設置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            title: '參與排行榜',
            subtitle: '允許我出現在熱度排行榜中',
            value: settings.participateInRanking,
            onChanged: notifier.updateParticipation,
          ),
          
          if (settings.participateInRanking) ...[
            _buildSettingTile(
              title: '全球排行榜',
              subtitle: '在全球排行榜中顯示',
              value: settings.showInGlobalRanking,
              onChanged: notifier.updateGlobalRanking,
            ),
            _buildSettingTile(
              title: '本地排行榜',
              subtitle: '在香港本地排行榜中顯示',
              value: settings.showInLocalRanking,
              onChanged: notifier.updateLocalRanking,
            ),
            _buildSettingTile(
              title: '允許檔案查看',
              subtitle: '其他用戶可以從排行榜查看我的檔案',
              value: settings.allowProfileViewing,
              onChanged: notifier.updateProfileViewing,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildHotnessTips() {
    final tips = [
      {
        'icon': Icons.photo_camera,
        'title': '優化照片',
        'description': '上傳高質量、有吸引力的照片',
        'impact': '+15% 熱度',
      },
      {
        'icon': Icons.edit,
        'title': '完善檔案',
        'description': '填寫詳細的個人介紹和興趣',
        'impact': '+10% 熱度',
      },
      {
        'icon': Icons.chat,
        'title': '積極互動',
        'description': '主動發起對話，提高回覆率',
        'impact': '+20% 熱度',
      },
      {
        'icon': Icons.verified,
        'title': '身份驗證',
        'description': '完成照片和身份驗證',
        'impact': '+25% 熱度',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '提升熱度建議',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tip['icon'] as IconData,
                    color: const Color(0xFFE91E63),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tip['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip['impact'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return const Color(0xFFE91E63);
    if (rank <= 50) return Colors.blue;
    return Colors.grey;
  }

  void _showRankingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '排行榜說明',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard(
                      title: '熱度分數計算',
                      content: '• 檔案瀏覽次數 (30%)\n• 收到的喜歡數量 (25%)\n• 配對成功率 (20%)\n• 消息回覆率 (15%)\n• 檔案完整度 (10%)',
                      icon: Icons.calculate,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: '排行榜更新',
                      content: '• 每日更新一次\n• 基於過去7天的活動數據\n• 新用戶需要3天才能進入排行榜',
                      icon: Icons.update,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: '隱私保護',
                      content: '• 你可以隨時退出排行榜\n• 只有參與者才能看到排行榜\n• 不會顯示具體的個人數據',
                      icon: Icons.privacy_tip,
                      color: Colors.orange,
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

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 