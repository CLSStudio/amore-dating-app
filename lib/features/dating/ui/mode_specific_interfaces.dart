import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/dating_modes/mode_manager.dart';
import '../../../core/dating_modes/theme_manager.dart';
import '../modes/dating_mode_system.dart';
import '../../../core/models/user_model.dart';

/// 🎯 Amore 模式專屬界面
/// 為三大核心模式提供差異化的用戶體驗

// =============================================================================
// 🎯 認真交往模式界面
// =============================================================================

class SeriousDatingInterface extends ConsumerStatefulWidget {
  const SeriousDatingInterface({super.key});

  @override
  ConsumerState<SeriousDatingInterface> createState() => _SeriousDatingInterfaceState();
}

class _SeriousDatingInterfaceState extends ConsumerState<SeriousDatingInterface> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager().getThemeForMode(DatingMode.serious);
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildSeriousAppBar(context),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _SeriousDiscoveryView(),
            _SeriousMatchesView(),
            _SeriousCompatibilityView(),
            _SeriousConsultantView(),
          ],
        ),
        bottomNavigationBar: _buildSeriousBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildSeriousAppBar(BuildContext context) {
    return AppBar(
      title: const Text('認真交往', style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      )),
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.psychology, color: Colors.white),
          tooltip: 'MBTI匹配',
          onPressed: () => _showMBTICenter(context),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          tooltip: '價值觀中心',
          onPressed: () => _showValuesCenter(context),
        ),
      ],
    );
  }

  Widget _buildSeriousBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '深度探索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '心動匹配',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: '相容分析',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: '愛情顧問',
        ),
      ],
    );
  }

  void _showMBTICenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MBTIMatchingCenter(),
    );
  }

  void _showValuesCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ValuesAlignmentCenter(),
    );
  }
}

class _SeriousDiscoveryView extends StatelessWidget {
  const _SeriousDiscoveryView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0277BD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text('尋找真愛', style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '基於深度價值觀匹配和MBTI相容性分析，為您推薦最適合的人生伴侶',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSeriousProfileCard(context, index),
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeriousProfileCard(BuildContext context, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('用戶 ${index + 1}', style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF81C784),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('INFJ', style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                      const SizedBox(width: 4),
                      const Text('95%匹配', style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriousMatchesView extends StatelessWidget {
  const _SeriousMatchesView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildMatchCard(context, index),
    );
  }

  Widget _buildMatchCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('心動匹配 ${index + 1}', style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('92%', style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('價值觀高度契合，人生目標一致', style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCompatibilityChip('MBTI匹配', '95%', const Color(0xFF81C784)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompatibilityChip('價值觀', '88%', const Color(0xFF64B5F6)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompatibilityChip('生活方式', '91%', const Color(0xFFFFB74D)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityChip(String label, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: 2),
          Text(percentage, style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }
}

class _SeriousCompatibilityView extends StatelessWidget {
  const _SeriousCompatibilityView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('相容性分析視圖'),
    );
  }
}

class _SeriousConsultantView extends StatelessWidget {
  const _SeriousConsultantView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('愛情顧問視圖'),
    );
  }
}

class _MBTIMatchingCenter extends StatelessWidget {
  const _MBTIMatchingCenter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('MBTI匹配中心'),
      ),
    );
  }
}

class _ValuesAlignmentCenter extends StatelessWidget {
  const _ValuesAlignmentCenter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('價值觀對齊中心'),
      ),
    );
  }
}

// =============================================================================
// 🌟 探索模式界面
// =============================================================================

class ExploreInterface extends ConsumerStatefulWidget {
  const ExploreInterface({super.key});

  @override
  ConsumerState<ExploreInterface> createState() => _ExploreInterfaceState();
}

class _ExploreInterfaceState extends ConsumerState<ExploreInterface> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager().getThemeForMode(DatingMode.explore);
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: _buildExploreAppBar(context),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _ExploreDiscoveryView(),
            _ExploreActivitiesView(),
            _ExploreCommunitiesView(),
            _ExploreEventsView(),
          ],
        ),
        bottomNavigationBar: _buildExploreBottomNav(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showQuickMatch(context),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.explore, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildExploreAppBar(BuildContext context) {
    return AppBar(
      title: const Text('探索交友', style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      )),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          tooltip: '興趣篩選',
          onPressed: () => _showInterestFilter(context),
        ),
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white),
          tooltip: '附近活動',
          onPressed: () => _showNearbyActivities(context),
        ),
      ],
    );
  }

  Widget _buildExploreBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: '探索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: '活動',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: '社群',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: '聚會',
        ),
      ],
    );
  }

  void _showQuickMatch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuickMatchModal(),
    );
  }

  void _showInterestFilter(BuildContext context) {
    // 實現興趣篩選
  }

  void _showNearbyActivities(BuildContext context) {
    // 實現附近活動
  }
}

class _ExploreDiscoveryView extends StatelessWidget {
  const _ExploreDiscoveryView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.amber],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.explore, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text('探索新朋友', style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '透過共同興趣和活動偏好，發現志同道合的新朋友',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) => _buildInterestChip(context, index),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildExploreCard(context, index),
              childCount: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(BuildContext context, int index) {
    final interests = ['音樂', '運動', '旅行', '美食', '攝影', '閱讀'];
    final icons = [Icons.music_note, Icons.sports, Icons.flight, Icons.restaurant, Icons.camera, Icons.book];
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(icons[index], color: Colors.orange, size: 24),
          ),
          const SizedBox(height: 8),
          Text(interests[index], style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('探索夥伴 ${index + 1}', style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                  const SizedBox(height: 4),
                  const Text('喜歡音樂、旅行和美食', style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTagChip('音樂愛好者'),
                      const SizedBox(width: 8),
                      _buildTagChip('旅行達人'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, color: Colors.orange),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(
        fontSize: 11,
        color: Colors.orange,
        fontWeight: FontWeight.w500,
      )),
    );
  }
}

class _ExploreActivitiesView extends StatelessWidget {
  const _ExploreActivitiesView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('活動視圖'));
  }
}

class _ExploreCommunitiesView extends StatelessWidget {
  const _ExploreCommunitiesView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('社群視圖'));
  }
}

class _ExploreEventsView extends StatelessWidget {
  const _ExploreEventsView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('聚會視圖'));
  }
}

class _QuickMatchModal extends StatelessWidget {
  const _QuickMatchModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(child: Text('快速配對')),
    );
  }
}

// =============================================================================
// 🔥 激情模式界面
// =============================================================================

class PassionInterface extends ConsumerStatefulWidget {
  const PassionInterface({super.key});

  @override
  ConsumerState<PassionInterface> createState() => _PassionInterfaceState();
}

class _PassionInterfaceState extends ConsumerState<PassionInterface> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager().getThemeForMode(DatingMode.passion);
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: _buildPassionAppBar(context),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _PassionMapView(),
            _PassionNearbyView(),
            _PassionInstantView(),
            _PassionPrivacyView(),
          ],
        ),
        bottomNavigationBar: _buildPassionBottomNav(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showInstantConnect(context),
          backgroundColor: const Color(0xFFE91E63),
          child: const Icon(Icons.flash_on, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPassionAppBar(BuildContext context) {
    return AppBar(
      title: const Text('激情模式', style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      )),
      backgroundColor: const Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.security, color: Colors.white),
          tooltip: '安全設定',
          onPressed: () => _showSafetySettings(context),
        ),
        IconButton(
          icon: const Icon(Icons.timer, color: Colors.white),
          tooltip: '可用時間',
          onPressed: () => _showAvailabilityTimer(context),
        ),
      ],
    );
  }

  Widget _buildPassionBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF2D2D2D),
      selectedItemColor: const Color(0xFFE91E63),
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: '地圖',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.near_me),
          label: '附近',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flash_on),
          label: '即時',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.privacy_tip),
          label: '隱私',
        ),
      ],
    );
  }

  void _showInstantConnect(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _InstantConnectModal(),
    );
  }

  void _showSafetySettings(BuildContext context) {
    // 實現安全設定
  }

  void _showAvailabilityTimer(BuildContext context) {
    // 實現可用時間設定
  }
}

class _PassionMapView extends StatelessWidget {
  const _PassionMapView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFF1A1A1A),
          child: const Center(
            child: Text('地圖視圖 (集成地圖API)', style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            )),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Card(
            color: const Color(0xFF2D2D2D),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFE91E63)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('附近有 12 位用戶', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PassionNearbyView extends StatelessWidget {
  const _PassionNearbyView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => _buildNearbyCard(context, index),
    );
  }

  Widget _buildNearbyCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE91E63).withOpacity(0.2),
                  child: const Icon(Icons.person, color: Color(0xFFE91E63)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF2D2D2D), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('附近用戶 ${index + 1}', style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${(index + 1) * 100}m', style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('正在尋找有趣的聊天夥伴', style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  )),
                  const SizedBox(height: 8),
                  Text('可用時間: ${2 + index}小時', style: const TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.flash_on, color: Color(0xFFE91E63)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, color: Color(0xFFE91E63)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PassionInstantView extends StatelessWidget {
  const _PassionInstantView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('即時連結視圖', style: TextStyle(color: Colors.white)),
    );
  }
}

class _PassionPrivacyView extends StatelessWidget {
  const _PassionPrivacyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('隱私設定視圖', style: TextStyle(color: Colors.white)),
    );
  }
}

class _InstantConnectModal extends StatelessWidget {
  const _InstantConnectModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('即時連結', style: TextStyle(color: Colors.white)),
      ),
    );
  }
} 