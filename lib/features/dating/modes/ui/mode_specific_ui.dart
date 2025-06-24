import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/dating_modes/mode_manager.dart';
import '../../../../core/dating_modes/content/content_recommendation_engine.dart';
import '../dating_mode_system.dart';

/// 🎯 模式專屬UI介面管理器
class ModeSpecificUI extends StatelessWidget {
  final DatingMode mode;
  final String userId;

  const ModeSpecificUI({
    Key? key,
    required this.mode,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case DatingMode.serious:
        return SeriousDatingUI(userId: userId);
      case DatingMode.explore:
        return ExploreUI(userId: userId);
      case DatingMode.passion:
        return PassionUI(userId: userId);
    }
  }
}

/// 🎯 認真交往模式UI
class SeriousDatingUI extends StatefulWidget {
  final String userId;

  const SeriousDatingUI({Key? key, required this.userId}) : super(key: key);

  @override
  State<SeriousDatingUI> createState() => _SeriousDatingUIState();
}

class _SeriousDatingUIState extends State<SeriousDatingUI> {
  final ContentRecommendationEngine _contentEngine = ContentRecommendationEngine();
  List<ContentRecommendation> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final recommendations = await _contentEngine.getRecommendationsForMode(
        DatingMode.serious,
        widget.userId,
      );
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565C0), // 深藍色
            Color(0xFF1976D2), // 中藍色
            Color(0xFF1E88E5), // 淺藍色
          ],
        ),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeHeader(),
                  SizedBox(height: 20),
                  _buildValueMatchingCenter(),
                  SizedBox(height: 20),
                  _buildRelationshipRoadmap(),
                  SizedBox(height: 20),
                  _buildDeepConnectionFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildModeHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            '認真交往模式',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '尋找人生伴侶，建立深度連結和長期承諾',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValueMatchingCenter() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF1565C0), size: 28),
                SizedBox(width: 12),
                Text(
                  '價值觀匹配中心',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '深入了解你的核心價值觀，找到真正契合的伴侶',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildValueCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCategories() {
    final categories = [
      {'name': '家庭價值', 'icon': Icons.home, 'progress': 0.8},
      {'name': '事業理念', 'icon': Icons.work, 'progress': 0.6},
      {'name': '金錢觀念', 'icon': Icons.account_balance_wallet, 'progress': 0.7},
      {'name': '生活方式', 'icon': Icons.lifestyle, 'progress': 0.5},
    ];

    return Column(
      children: categories.map((category) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1565C0).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF1565C0).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category['icon'] as IconData, 
                       color: Color(0xFF1565C0), size: 24),
                  SizedBox(width: 12),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: category['progress'] as double,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
              SizedBox(height: 8),
              Text(
                '匹配度: ${((category['progress'] as double) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelationshipRoadmap() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Color(0xFF1565C0), size: 28),
                SizedBox(width: 12),
                Text(
                  '關係發展路線圖',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildRoadmapSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapSteps() {
    final steps = [
      {'title': '初次認識期', 'duration': '1-4週', 'status': 'completed'},
      {'title': '深入了解期', 'duration': '1-3個月', 'status': 'current'},
      {'title': '確立關係期', 'duration': '3-6個月', 'status': 'upcoming'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> step = entry.value;
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              _buildStepIndicator(step['status']!, index + 1),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getStepColor(step['status']!),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '預計時間: ${step['duration']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepIndicator(String status, int number) {
    Color color = _getStepColor(status);
    IconData icon = status == 'completed' ? Icons.check : Icons.fiber_manual_record;
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: status == 'completed' ? 24 : 16,
      ),
    );
  }

  Color _getStepColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'current':
        return Color(0xFF1565C0);
      case 'upcoming':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDeepConnectionFeatures() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Color(0xFF1565C0), size: 28),
                SizedBox(width: 12),
                Text(
                  '深度連結功能',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildFeatureGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'title': 'MBTI深度分析', 'icon': Icons.psychology, 'description': '詳細性格匹配'},
      {'title': '價值觀評估', 'icon': Icons.assessment, 'description': '核心價值對齊'},
      {'title': '未來規劃', 'icon': Icons.event_note, 'description': '人生目標討論'},
      {'title': '專業諮詢', 'icon': Icons.support_agent, 'description': '愛情顧問服務'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: features.map((feature) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1565C0).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF1565C0).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature['icon'] as IconData, 
                   color: Color(0xFF1565C0), size: 32),
              SizedBox(height: 8),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565C0),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                feature['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 🌟 探索模式UI
class ExploreUI extends StatefulWidget {
  final String userId;

  const ExploreUI({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExploreUI> createState() => _ExploreUIState();
}

class _ExploreUIState extends State<ExploreUI> {
  final ContentRecommendationEngine _contentEngine = ContentRecommendationEngine();
  List<ContentRecommendation> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final recommendations = await _contentEngine.getRecommendationsForMode(
        DatingMode.explore,
        widget.userId,
      );
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7043), // 橙色
            Color(0xFFFF8A65), // 淺橙色
            Color(0xFFFFAB91), // 更淺橙色
          ],
        ),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeHeader(),
                  SizedBox(height: 20),
                  _buildActivityCommunity(),
                  SizedBox(height: 20),
                  _buildPersonalityDiscovery(),
                  SizedBox(height: 20),
                  _buildExploreFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildModeHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.explore, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            '探索模式',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '開放探索各種可能性，發現最適合自己的交友方式',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCommunity() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Color(0xFFFF7043), size: 28),
                SizedBox(width: 12),
                Text(
                  '活動興趣社區',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '根據你的興趣找到同好，參與有趣的活動',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildActivityCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCategories() {
    final categories = [
      {'name': '戶外探險', 'count': 12, 'icon': Icons.hiking, 'color': Colors.green},
      {'name': '文化藝術', 'count': 8, 'icon': Icons.palette, 'color': Colors.purple},
      {'name': '美食體驗', 'count': 15, 'icon': Icons.restaurant, 'color': Colors.orange},
      {'name': '運動健身', 'count': 10, 'icon': Icons.fitness_center, 'color': Colors.blue},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: categories.map((category) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (category['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (category['color'] as Color).withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category['icon'] as IconData, 
                   color: category['color'] as Color, size: 32),
              SizedBox(height: 8),
              Text(
                category['name'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: category['color'] as Color,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${category['count']} 個活動',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalityDiscovery() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFFFF7043), size: 28),
                SizedBox(width: 12),
                Text(
                  '性格探索之旅',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '發現你獨特的性格特質和社交風格',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildDiscoveryProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryProgress() {
    final assessments = [
      {'name': '社交風格測試', 'progress': 0.8, 'status': '已完成'},
      {'name': '興趣匹配分析', 'progress': 0.6, 'status': '進行中'},
      {'name': '溝通模式評估', 'progress': 0.0, 'status': '待開始'},
    ];

    return Column(
      children: assessments.map((assessment) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFF7043).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFFF7043).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assessment['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                  Text(
                    assessment['status'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: assessment['progress'] as double,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExploreFeatures() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFFF7043), size: 28),
                SizedBox(width: 12),
                Text(
                  '探索功能',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {'title': 'AI模式推薦', 'description': '智能分析推薦適合的交友模式', 'icon': Icons.smart_toy},
      {'title': '興趣匹配', 'description': '根據興趣愛好找到同好', 'icon': Icons.favorite},
      {'title': '活動邀請', 'description': '參與或發起有趣的社交活動', 'icon': Icons.event},
      {'title': '成長追蹤', 'description': '記錄你的探索歷程和成長', 'icon': Icons.trending_up},
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFF7043).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(feature['icon'] as IconData, 
                   color: Color(0xFFFF7043), size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF7043),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 🔥 激情模式UI
class PassionUI extends StatefulWidget {
  final String userId;

  const PassionUI({Key? key, required this.userId}) : super(key: key);

  @override
  State<PassionUI> createState() => _PassionUIState();
}

class _PassionUIState extends State<PassionUI> {
  final ContentRecommendationEngine _contentEngine = ContentRecommendationEngine();
  List<ContentRecommendation> _recommendations = [];
  bool _isLoading = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final recommendations = await _contentEngine.getRecommendationsForMode(
        DatingMode.passion,
        widget.userId,
      );
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63), // 粉紅色
            Color(0xFFEC407A), // 中粉紅色
            Color(0xFFEF5350), // 淺粉紅色
          ],
        ),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeHeader(),
                  SizedBox(height: 20),
                  _buildLiveMap(),
                  SizedBox(height: 20),
                  _buildInstantVenues(),
                  SizedBox(height: 20),
                  _buildSafetyFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildModeHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            '激情模式',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '即時連結，直接溝通，享受當下的激情與自由',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMap() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(22.3193, 114.1694), // 香港座標
                  zoom: 12,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _buildMapMarkers(),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.near_me, color: Color(0xFFE91E63), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '即時地圖 - 發現附近的連結機會',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
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

  Set<Marker> _buildMapMarkers() {
    return {
      Marker(
        markerId: MarkerId('user1'),
        position: LatLng(22.3193, 114.1694),
        infoWindow: InfoWindow(title: '活躍用戶', snippet: '在線上'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
      Marker(
        markerId: MarkerId('user2'),
        position: LatLng(22.3093, 114.1794),
        infoWindow: InfoWindow(title: '熱門地點', snippet: '多人聚集'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };
  }

  Widget _buildInstantVenues() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFFE91E63), size: 28),
                SizedBox(width: 12),
                Text(
                  '即時約會場所',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '推薦附近適合即時約會的地點',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildVenueList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueList() {
    final venues = [
      {
        'name': 'Starbucks IFC',
        'type': '咖啡廳',
        'distance': '0.8km',
        'rating': 4.2,
        'atmosphere': '商務休閒',
        'busyLevel': '中等',
      },
      {
        'name': 'Sevva',
        'type': '酒吧',
        'distance': '1.2km',
        'rating': 4.5,
        'atmosphere': '時尚高雅',
        'busyLevel': '高',
      },
      {
        'name': 'The Pawn',
        'type': '餐廳',
        'distance': '1.5km',
        'rating': 4.3,
        'atmosphere': '浪漫溫馨',
        'busyLevel': '中等',
      },
    ];

    return Column(
      children: venues.map((venue) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE91E63).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE91E63).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${venue['type']} • ${venue['distance']} • ${venue['atmosphere']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (venue['rating'] as double).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '人流: ${venue['busyLevel']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 導航或邀請功能
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('邀請', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSafetyFeatures() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Color(0xFFE91E63), size: 28),
                SizedBox(width: 12),
                Text(
                  '安全保護',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '享受自由的同時保護自己',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildSafetyList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyList() {
    final safetyFeatures = [
      {'title': '位置隱私', 'description': '自動模糊位置到街區級別', 'icon': Icons.location_off},
      {'title': '一鍵隱身', 'description': '隨時隱藏在線狀態', 'icon': Icons.visibility_off},
      {'title': '即時報告', 'description': '快速報告不當行為', 'icon': Icons.report},
      {'title': '緊急聯絡', 'description': '緊急情況快速求助', 'icon': Icons.emergency},
    ];

    return Column(
      children: safetyFeatures.map((feature) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE91E63).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(feature['icon'] as IconData, 
                   color: Color(0xFFE91E63), size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                activeColor: Color(0xFFE91E63),
                onChanged: (value) {
                  // 切換安全功能
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 