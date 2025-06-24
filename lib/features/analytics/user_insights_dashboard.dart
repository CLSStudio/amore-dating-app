import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// 用戶統計數據模型
class UserInsights {
  final int profileViews;
  final int likesReceived;
  final int likesGiven;
  final int matches;
  final int conversations;
  final int messagesExchanged;
  final double responseRate;
  final double matchRate;
  final List<DailyActivity> weeklyActivity;
  final List<PopularTime> popularTimes;
  final Map<String, int> interestStats;
  final List<AgeGroupStat> ageGroupStats;

  UserInsights({
    required this.profileViews,
    required this.likesReceived,
    required this.likesGiven,
    required this.matches,
    required this.conversations,
    required this.messagesExchanged,
    required this.responseRate,
    required this.matchRate,
    required this.weeklyActivity,
    required this.popularTimes,
    required this.interestStats,
    required this.ageGroupStats,
  });
}

class DailyActivity {
  final String day;
  final int views;
  final int likes;
  final int matches;

  DailyActivity({
    required this.day,
    required this.views,
    required this.likes,
    required this.matches,
  });
}

class PopularTime {
  final String timeRange;
  final double activity;

  PopularTime({
    required this.timeRange,
    required this.activity,
  });
}

class AgeGroupStat {
  final String ageRange;
  final int count;
  final double percentage;

  AgeGroupStat({
    required this.ageRange,
    required this.count,
    required this.percentage,
  });
}

// 用戶洞察狀態管理
final userInsightsProvider = StateNotifierProvider<UserInsightsNotifier, UserInsights?>((ref) {
  return UserInsightsNotifier();
});

class UserInsightsNotifier extends StateNotifier<UserInsights?> {
  UserInsightsNotifier() : super(null) {
    _loadInsights();
  }

  void _loadInsights() {
    // 模擬載入用戶洞察數據
    final insights = UserInsights(
      profileViews: 1247,
      likesReceived: 89,
      likesGiven: 156,
      matches: 23,
      conversations: 18,
      messagesExchanged: 342,
      responseRate: 0.78,
      matchRate: 0.18,
      weeklyActivity: [
        DailyActivity(day: '週一', views: 45, likes: 8, matches: 2),
        DailyActivity(day: '週二', views: 67, likes: 12, matches: 3),
        DailyActivity(day: '週三', views: 89, likes: 15, matches: 4),
        DailyActivity(day: '週四', views: 123, likes: 18, matches: 5),
        DailyActivity(day: '週五', views: 156, likes: 22, matches: 6),
        DailyActivity(day: '週六', views: 234, likes: 28, matches: 8),
        DailyActivity(day: '週日', views: 198, likes: 25, matches: 7),
      ],
      popularTimes: [
        PopularTime(timeRange: '6-9', activity: 0.2),
        PopularTime(timeRange: '9-12', activity: 0.4),
        PopularTime(timeRange: '12-15', activity: 0.6),
        PopularTime(timeRange: '15-18', activity: 0.8),
        PopularTime(timeRange: '18-21', activity: 1.0),
        PopularTime(timeRange: '21-24', activity: 0.9),
        PopularTime(timeRange: '0-3', activity: 0.3),
        PopularTime(timeRange: '3-6', activity: 0.1),
      ],
      interestStats: {
        '旅行': 45,
        '美食': 38,
        '運動': 32,
        '音樂': 28,
        '電影': 25,
        '攝影': 22,
        '閱讀': 18,
        '藝術': 15,
      },
      ageGroupStats: [
        AgeGroupStat(ageRange: '18-22', count: 12, percentage: 0.15),
        AgeGroupStat(ageRange: '23-27', count: 28, percentage: 0.35),
        AgeGroupStat(ageRange: '28-32', count: 24, percentage: 0.30),
        AgeGroupStat(ageRange: '33-37', count: 12, percentage: 0.15),
        AgeGroupStat(ageRange: '38+', count: 4, percentage: 0.05),
      ],
    );

    state = insights;
  }

  void refreshInsights() {
    _loadInsights();
  }
}

class UserInsightsDashboard extends ConsumerStatefulWidget {
  const UserInsightsDashboard({super.key});

  @override
  ConsumerState<UserInsightsDashboard> createState() => _UserInsightsDashboardState();
}

class _UserInsightsDashboardState extends ConsumerState<UserInsightsDashboard> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    final insights = ref.watch(userInsightsProvider);
    final notifier = ref.read(userInsightsProvider.notifier);

    if (insights == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('我的洞察'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              notifier.refreshInsights();
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
              // 概覽統計
              _buildOverviewStats(insights),
              
              const SizedBox(height: 24),
              
              // 週活動圖表
              _buildWeeklyActivityChart(insights),
              
              const SizedBox(height: 24),
              
              // 熱門時段
              _buildPopularTimesChart(insights),
              
              const SizedBox(height: 24),
              
              // 興趣統計
              _buildInterestStats(insights),
              
              const SizedBox(height: 24),
              
              // 年齡群組分析
              _buildAgeGroupAnalysis(insights),
              
              const SizedBox(height: 24),
              
              // 成功率分析
              _buildSuccessRateAnalysis(insights),
              
              const SizedBox(height: 32),
              
              // 改進建議
              _buildImprovementSuggestions(insights),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(UserInsights insights) {
    final stats = [
      {'title': '檔案瀏覽', 'value': insights.profileViews.toString(), 'icon': Icons.visibility, 'color': Colors.blue},
      {'title': '收到喜歡', 'value': insights.likesReceived.toString(), 'icon': Icons.favorite, 'color': Colors.pink},
      {'title': '成功配對', 'value': insights.matches.toString(), 'icon': Icons.people, 'color': Colors.green},
      {'title': '對話數量', 'value': insights.conversations.toString(), 'icon': Icons.chat, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '本週概覽',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(UserInsights insights) {
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
            '週活動趨勢',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: insights.weeklyActivity.map((activity) {
                final maxViews = insights.weeklyActivity
                    .map((a) => a.views)
                    .reduce(math.max);
                final height = (activity.views / maxViews) * 160;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          activity.views.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFFE91E63),
                                const Color(0xFFE91E63).withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.day,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTimesChart(UserInsights insights) {
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
            '活躍時段分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '你最活躍的時段是 18:00-21:00',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              children: insights.popularTimes.map((time) {
                final height = time.activity * 80;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: height,
                          decoration: BoxDecoration(
                            color: time.activity > 0.8 
                                ? const Color(0xFFE91E63)
                                : const Color(0xFFE91E63).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          time.timeRange,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestStats(UserInsights insights) {
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
            '興趣匹配統計',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '與你有共同興趣的用戶分佈',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ...insights.interestStats.entries.map((entry) {
            final maxCount = insights.interestStats.values.reduce(math.max);
            final percentage = entry.value / maxCount;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAgeGroupAnalysis(UserInsights insights) {
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
            '年齡群組分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '你的配對年齡分佈',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(insights.ageGroupStats),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: insights.ageGroupStats.map((stat) {
              final colors = [Colors.pink, Colors.blue, Colors.green, Colors.orange, Colors.purple];
              final colorIndex = insights.ageGroupStats.indexOf(stat) % colors.length;
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[colorIndex],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${stat.ageRange} (${(stat.percentage * 100).toInt()}%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateAnalysis(UserInsights insights) {
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
            '成功率分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSuccessRateItem(
                  title: '配對成功率',
                  rate: insights.matchRate,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSuccessRateItem(
                  title: '回覆率',
                  rate: insights.responseRate,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateItem({
    required String title,
    required double rate,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Center(
                child: Text(
                  '${(rate * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementSuggestions(UserInsights insights) {
    final suggestions = [
      {
        'icon': Icons.photo_camera,
        'title': '優化照片',
        'description': '添加更多生活照片可以提高 25% 的配對率',
        'color': Colors.blue,
      },
      {
        'icon': Icons.schedule,
        'title': '最佳時段',
        'description': '在 18:00-21:00 時段更活躍可以獲得更多關注',
        'color': Colors.orange,
      },
      {
        'icon': Icons.chat_bubble,
        'title': '提高回覆率',
        'description': '更快回覆消息可以提升對話成功率',
        'color': Colors.green,
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
          const Text(
            '改進建議',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (suggestion['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    suggestion['icon'] as IconData,
                    color: suggestion['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion['description'] as String,
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
}

// 自定義圓餅圖繪製器
class PieChartPainter extends CustomPainter {
  final List<AgeGroupStat> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    final colors = [Colors.pink, Colors.blue, Colors.green, Colors.orange, Colors.purple];
    
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = data[i].percentage * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 