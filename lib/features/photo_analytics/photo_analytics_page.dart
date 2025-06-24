import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// 照片分析數據模型
class PhotoAnalytics {
  final String photoId;
  final String photoUrl;
  final int views;
  final int likes;
  final int superLikes;
  final int shares;
  final double likeRate;
  final double engagementRate;
  final int rank;
  final DateTime uploadDate;
  final List<String> topInteractions;
  final Map<String, int> ageGroupLikes;
  final Map<String, double> timeOfDayViews;
  final bool isProfilePhoto;

  PhotoAnalytics({
    required this.photoId,
    required this.photoUrl,
    required this.views,
    required this.likes,
    required this.superLikes,
    required this.shares,
    required this.likeRate,
    required this.engagementRate,
    required this.rank,
    required this.uploadDate,
    required this.topInteractions,
    required this.ageGroupLikes,
    required this.timeOfDayViews,
    this.isProfilePhoto = false,
  });
}

// 照片建議模型
class PhotoSuggestion {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String impact;

  PhotoSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.impact,
  });
}

// 照片分析狀態管理
final photoAnalyticsProvider = StateNotifierProvider<PhotoAnalyticsNotifier, List<PhotoAnalytics>>((ref) {
  return PhotoAnalyticsNotifier();
});

class PhotoAnalyticsNotifier extends StateNotifier<List<PhotoAnalytics>> {
  PhotoAnalyticsNotifier() : super([]) {
    _loadPhotoAnalytics();
  }

  void _loadPhotoAnalytics() {
    // 模擬載入照片分析數據
    final analytics = [
      PhotoAnalytics(
        photoId: '1',
        photoUrl: 'https://picsum.photos/400/600?random=1',
        views: 2847,
        likes: 456,
        superLikes: 23,
        shares: 12,
        likeRate: 0.16,
        engagementRate: 0.18,
        rank: 1,
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        topInteractions: ['旅行愛好者', '攝影師', '戶外運動'],
        ageGroupLikes: {'18-25': 45, '26-30': 38, '31-35': 17},
        timeOfDayViews: {'早上': 0.2, '下午': 0.4, '晚上': 0.4},
        isProfilePhoto: true,
      ),
      PhotoAnalytics(
        photoId: '2',
        photoUrl: 'https://picsum.photos/400/600?random=2',
        views: 2156,
        likes: 387,
        superLikes: 18,
        shares: 8,
        likeRate: 0.18,
        engagementRate: 0.19,
        rank: 2,
        uploadDate: DateTime.now().subtract(const Duration(days: 8)),
        topInteractions: ['美食愛好者', '咖啡控', '生活品味'],
        ageGroupLikes: {'18-25': 52, '26-30': 31, '31-35': 17},
        timeOfDayViews: {'早上': 0.15, '下午': 0.35, '晚上': 0.5},
      ),
      PhotoAnalytics(
        photoId: '3',
        photoUrl: 'https://picsum.photos/400/600?random=3',
        views: 1923,
        likes: 298,
        superLikes: 15,
        shares: 6,
        likeRate: 0.155,
        engagementRate: 0.165,
        rank: 3,
        uploadDate: DateTime.now().subtract(const Duration(days: 22)),
        topInteractions: ['健身愛好者', '運動達人', '健康生活'],
        ageGroupLikes: {'18-25': 38, '26-30': 42, '31-35': 20},
        timeOfDayViews: {'早上': 0.3, '下午': 0.3, '晚上': 0.4},
      ),
      PhotoAnalytics(
        photoId: '4',
        photoUrl: 'https://picsum.photos/400/600?random=4',
        views: 1654,
        likes: 234,
        superLikes: 11,
        shares: 4,
        likeRate: 0.141,
        engagementRate: 0.151,
        rank: 4,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        topInteractions: ['藝術愛好者', '文青', '創意人士'],
        ageGroupLikes: {'18-25': 35, '26-30': 45, '31-35': 20},
        timeOfDayViews: {'早上': 0.25, '下午': 0.45, '晚上': 0.3},
      ),
      PhotoAnalytics(
        photoId: '5',
        photoUrl: 'https://picsum.photos/400/600?random=5',
        views: 1432,
        likes: 189,
        superLikes: 8,
        shares: 3,
        likeRate: 0.132,
        engagementRate: 0.14,
        rank: 5,
        uploadDate: DateTime.now().subtract(const Duration(days: 30)),
        topInteractions: ['音樂愛好者', '樂器演奏', '文藝青年'],
        ageGroupLikes: {'18-25': 48, '26-30': 32, '31-35': 20},
        timeOfDayViews: {'早上': 0.2, '下午': 0.3, '晚上': 0.5},
      ),
      PhotoAnalytics(
        photoId: '6',
        photoUrl: 'https://picsum.photos/400/600?random=6',
        views: 987,
        likes: 123,
        superLikes: 5,
        shares: 2,
        likeRate: 0.125,
        engagementRate: 0.132,
        rank: 6,
        uploadDate: DateTime.now().subtract(const Duration(days: 12)),
        topInteractions: ['寵物愛好者', '動物保護', '溫暖人心'],
        ageGroupLikes: {'18-25': 55, '26-30': 30, '31-35': 15},
        timeOfDayViews: {'早上': 0.35, '下午': 0.25, '晚上': 0.4},
      ),
    ];

    state = analytics;
  }

  void refreshAnalytics() {
    _loadPhotoAnalytics();
  }

  void deletePhoto(String photoId) {
    state = state.where((photo) => photo.photoId != photoId).toList();
  }
}

class PhotoAnalyticsPage extends ConsumerStatefulWidget {
  const PhotoAnalyticsPage({super.key});

  @override
  ConsumerState<PhotoAnalyticsPage> createState() => _PhotoAnalyticsPageState();
}

class _PhotoAnalyticsPageState extends ConsumerState<PhotoAnalyticsPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _sortBy = 'rank'; // rank, likes, views, engagement

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(photoAnalyticsProvider);
    final sortedAnalytics = _sortAnalytics(analytics);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('照片分析'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rank',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 12),
                    Text('按排名排序'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'likes',
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 20),
                    SizedBox(width: 12),
                    Text('按喜歡數排序'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'views',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20),
                    SizedBox(width: 12),
                    Text('按瀏覽數排序'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'engagement',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 12),
                    Text('按互動率排序'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ref.read(photoAnalyticsProvider.notifier).refreshAnalytics();
              _animationController.reset();
              _animationController.forward();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 總體統計
              _buildOverallStats(analytics),
              
              const SizedBox(height: 24),
              
              // 最佳表現照片
              _buildTopPerformingPhoto(analytics),
              
              const SizedBox(height: 24),
              
              // 照片列表
              _buildPhotoList(sortedAnalytics),
              
              const SizedBox(height: 24),
              
              // 優化建議
              _buildOptimizationSuggestions(),
            ],
          ),
        ),
      ),
    );
  }

  List<PhotoAnalytics> _sortAnalytics(List<PhotoAnalytics> analytics) {
    final sorted = List<PhotoAnalytics>.from(analytics);
    
    switch (_sortBy) {
      case 'likes':
        sorted.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'views':
        sorted.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'engagement':
        sorted.sort((a, b) => b.engagementRate.compareTo(a.engagementRate));
        break;
      case 'rank':
      default:
        sorted.sort((a, b) => a.rank.compareTo(b.rank));
        break;
    }
    
    return sorted;
  }

  Widget _buildOverallStats(List<PhotoAnalytics> analytics) {
    final totalViews = analytics.fold(0, (sum, photo) => sum + photo.views);
    final totalLikes = analytics.fold(0, (sum, photo) => sum + photo.likes);
    final avgEngagement = analytics.fold(0.0, (sum, photo) => sum + photo.engagementRate) / analytics.length;
    final bestPhoto = analytics.isNotEmpty ? analytics.reduce((a, b) => a.rank < b.rank ? a : b) : null;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '照片表現總覽',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverallStatItem(
                  '總瀏覽',
                  totalViews.toString(),
                  Icons.visibility,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildOverallStatItem(
                  '總喜歡',
                  totalLikes.toString(),
                  Icons.favorite,
                  Colors.pink,
                ),
              ),
              Expanded(
                child: _buildOverallStatItem(
                  '平均互動率',
                  '${(avgEngagement * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          if (bestPhoto != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '最佳表現照片獲得了 ${bestPhoto.likes} 個喜歡',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildTopPerformingPhoto(List<PhotoAnalytics> analytics) {
    if (analytics.isEmpty) return const SizedBox.shrink();
    
    final topPhoto = analytics.reduce((a, b) => a.rank < b.rank ? a : b);
    
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
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '最佳表現照片',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  topPhoto.photoUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${topPhoto.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (topPhoto.isProfilePhoto)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '主照片',
                              style: TextStyle(
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMiniStat(Icons.visibility, '${topPhoto.views}', Colors.blue),
                        const SizedBox(width: 16),
                        _buildMiniStat(Icons.favorite, '${topPhoto.likes}', Colors.pink),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniStat(Icons.star, '${topPhoto.superLikes}', Colors.amber),
                        const SizedBox(width: 16),
                        _buildMiniStat(Icons.trending_up, '${(topPhoto.engagementRate * 100).toStringAsFixed(1)}%', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '這張照片最受 ${topPhoto.topInteractions.first} 歡迎',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
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

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoList(List<PhotoAnalytics> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '所有照片分析',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '排序：${_getSortLabel(_sortBy)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...analytics.map((photo) => _buildPhotoCard(photo)).toList(),
      ],
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'likes': return '喜歡數';
      case 'views': return '瀏覽數';
      case 'engagement': return '互動率';
      case 'rank':
      default: return '排名';
    }
  }

  Widget _buildPhotoCard(PhotoAnalytics photo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 照片
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photo.photoUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getRankColor(photo.rank),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${photo.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if (photo.isProfilePhoto)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '主照片',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // 統計數據
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatColumn('瀏覽', '${photo.views}', Icons.visibility, Colors.blue),
                          ),
                          Expanded(
                            child: _buildStatColumn('喜歡', '${photo.likes}', Icons.favorite, Colors.pink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatColumn('超讚', '${photo.superLikes}', Icons.star, Colors.amber),
                          ),
                          Expanded(
                            child: _buildStatColumn('互動率', '${(photo.engagementRate * 100).toStringAsFixed(1)}%', Icons.trending_up, Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '上傳於 ${_formatDate(photo.uploadDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 操作按鈕
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePhotoAction(value, photo),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.analytics, size: 20),
                          SizedBox(width: 12),
                          Text('詳細分析'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'optimize',
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 20),
                          SizedBox(width: 12),
                          Text('優化建議'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('刪除照片', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 展開詳情
          ExpansionTile(
            title: const Text(
              '查看詳細分析',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 年齡群組分析
                    _buildAgeGroupAnalysis(photo),
                    
                    const SizedBox(height: 16),
                    
                    // 時段分析
                    _buildTimeAnalysis(photo),
                    
                    const SizedBox(height: 16),
                    
                    // 互動類型
                    _buildInteractionTypes(photo),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
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

  Widget _buildAgeGroupAnalysis(PhotoAnalytics photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '年齡群組喜歡分佈',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...photo.ageGroupLikes.entries.map((entry) {
          final total = photo.ageGroupLikes.values.reduce((a, b) => a + b);
          final percentage = entry.value / total;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTimeAnalysis(PhotoAnalytics photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '時段瀏覽分佈',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: photo.timeOfDayViews.entries.map((entry) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      height: entry.value * 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInteractionTypes(PhotoAnalytics photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主要互動群體',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: photo.topInteractions.map((interaction) => 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                interaction,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildOptimizationSuggestions() {
    final suggestions = [
      PhotoSuggestion(
        type: 'lighting',
        title: '改善照片光線',
        description: '自然光拍攝的照片獲得 40% 更多喜歡',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        impact: '+40% 喜歡',
      ),
      PhotoSuggestion(
        type: 'composition',
        title: '優化構圖',
        description: '使用三分法則可以提升照片吸引力',
        icon: Icons.grid_on,
        color: Colors.blue,
        impact: '+25% 瀏覽',
      ),
      PhotoSuggestion(
        type: 'variety',
        title: '增加照片多樣性',
        description: '展示不同場景和活動的照片',
        icon: Icons.photo_library,
        color: Colors.green,
        impact: '+30% 互動',
      ),
      PhotoSuggestion(
        type: 'timing',
        title: '最佳上傳時間',
        description: '晚上 7-9 點上傳照片獲得最多關注',
        icon: Icons.schedule,
        color: Colors.purple,
        impact: '+20% 曝光',
      ),
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
                  color: Colors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Colors.lightBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '照片優化建議',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: suggestion.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.color,
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
                            suggestion.title,
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
                              suggestion.impact,
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
                        suggestion.description,
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
    if (rank <= 6) return const Color(0xFFE91E63);
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return '今天';
    if (difference == 1) return '昨天';
    if (difference < 7) return '$difference 天前';
    if (difference < 30) return '${(difference / 7).floor()} 週前';
    return '${(difference / 30).floor()} 個月前';
  }

  void _handlePhotoAction(String action, PhotoAnalytics photo) {
    switch (action) {
      case 'details':
        _showPhotoDetails(photo);
        break;
      case 'optimize':
        _showOptimizationTips(photo);
        break;
      case 'delete':
        _showDeleteConfirmation(photo);
        break;
    }
  }

  void _showPhotoDetails(PhotoAnalytics photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('照片 #${photo.rank} 詳細分析'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photo.photoUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text('瀏覽次數: ${photo.views}'),
              Text('喜歡次數: ${photo.likes}'),
              Text('超級喜歡: ${photo.superLikes}'),
              Text('分享次數: ${photo.shares}'),
              Text('喜歡率: ${(photo.likeRate * 100).toStringAsFixed(1)}%'),
              Text('互動率: ${(photo.engagementRate * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _showOptimizationTips(PhotoAnalytics photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('優化建議'),
        content: const Text('基於這張照片的表現，建議你在類似場景中拍攝更多照片，並注意光線和構圖。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PhotoAnalytics photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除照片'),
        content: const Text('確定要刪除這張照片嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(photoAnalyticsProvider.notifier).deletePhoto(photo.photoId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('照片已刪除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }
} 