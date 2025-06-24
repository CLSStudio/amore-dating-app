import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateIdeasPage extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const DateIdeasPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  ConsumerState<DateIdeasPage> createState() => _DateIdeasPageState();
}

class _DateIdeasPageState extends ConsumerState<DateIdeasPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<DateIdea> _dateIdeas = [];
  bool _isLoading = true;
  String _selectedCategory = '全部';

  final List<String> _categories = [
    '全部', '戶外活動', '文化藝術', '美食體驗', '休閒娛樂', '運動健身', '浪漫約會'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDateIdeas();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadDateIdeas() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 模擬 AI 生成約會建議
      await Future.delayed(const Duration(seconds: 2));
      
      _dateIdeas = _generateMockDateIdeas();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F8FF),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定義 AppBar
              _buildCustomAppBar(),
              
              // 分類篩選
              _buildCategoryFilter(),
              
              // 約會建議列表
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildDateIdeasList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF2D3748),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '約會建議',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  '與 ${widget.otherUserName} 的完美約會',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667EEA).withOpacity(0.2),
              checkmarkColor: const Color(0xFF667EEA),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF2D3748),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF667EEA) : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateIdeasList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final filteredIdeas = _selectedCategory == '全部' 
        ? _dateIdeas 
        : _dateIdeas.where((idea) => idea.category == _selectedCategory).toList();

    if (filteredIdeas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredIdeas.length,
      itemBuilder: (context, index) {
        final idea = filteredIdeas[index];
        return _buildDateIdeaCard(idea, index);
      },
    );
  }

  Widget _buildDateIdeaCard(DateIdea idea, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDateIdeaDetails(idea),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題和分類
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: _getCategoryGradient(idea.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(idea.category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(idea.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              idea.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(idea.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 評分
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            idea.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 描述
                Text(
                  idea.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // 詳細信息
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.access_time,
                      text: idea.duration,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      text: idea.priceRange,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.location_on,
                      text: idea.location,
                      color: Colors.orange,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 操作按鈕
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareIdea(idea),
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('分享'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF667EEA),
                          side: const BorderSide(color: Color(0xFF667EEA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendDateIdea(idea),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('發送'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
          SizedBox(height: 16),
          Text(
            'AI 正在為你們生成完美的約會建議...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '沒有找到 $_selectedCategory 的約會建議',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '試試其他分類或重新生成建議',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 輔助方法
  LinearGradient _getCategoryGradient(String category) {
    switch (category) {
      case '戶外活動':
        return const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]);
      case '文化藝術':
        return const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]);
      case '美食體驗':
        return const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)]);
      case '休閒娛樂':
        return const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]);
      case '運動健身':
        return const LinearGradient(colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)]);
      case '浪漫約會':
        return const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)]);
      default:
        return const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '戶外活動':
        return const Color(0xFF11998E);
      case '文化藝術':
        return const Color(0xFF667EEA);
      case '美食體驗':
        return const Color(0xFFFF6B6B);
      case '休閒娛樂':
        return const Color(0xFF4FACFE);
      case '運動健身':
        return const Color(0xFFFC466B);
      case '浪漫約會':
        return const Color(0xFFFF9A9E);
      default:
        return const Color(0xFF667EEA);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '戶外活動':
        return Icons.nature;
      case '文化藝術':
        return Icons.palette;
      case '美食體驗':
        return Icons.restaurant;
      case '休閒娛樂':
        return Icons.movie;
      case '運動健身':
        return Icons.fitness_center;
      case '浪漫約會':
        return Icons.favorite;
      default:
        return Icons.event;
    }
  }

  List<DateIdea> _generateMockDateIdeas() {
    return [
      DateIdea(
        id: '1',
        title: '太平山頂看夜景',
        description: '乘坐山頂纜車到太平山頂，欣賞香港壯麗的夜景，在浪漫的氛圍中享受二人世界。',
        category: '浪漫約會',
        duration: '3-4小時',
        priceRange: '\$200-400',
        location: '太平山',
        rating: 4.8,
        tags: ['夜景', '纜車', '浪漫'],
      ),
      DateIdea(
        id: '2',
        title: '中環藝術館文化之旅',
        description: '參觀香港藝術館，欣賞本地和國際藝術作品，在文化氛圍中增進彼此了解。',
        category: '文化藝術',
        duration: '2-3小時',
        priceRange: '\$50-150',
        location: '中環',
        rating: 4.5,
        tags: ['藝術', '文化', '室內'],
      ),
      DateIdea(
        id: '3',
        title: '石澳海灘漫步',
        description: '在石澳海灘享受陽光與海風，漫步沙灘，在海邊咖啡廳品嚐美食。',
        category: '戶外活動',
        duration: '半天',
        priceRange: '\$100-300',
        location: '石澳',
        rating: 4.6,
        tags: ['海灘', '自然', '放鬆'],
      ),
      DateIdea(
        id: '4',
        title: '茶餐廳美食探索',
        description: '探訪地道茶餐廳，品嚐港式奶茶和經典小食，體驗香港本土文化。',
        category: '美食體驗',
        duration: '1-2小時',
        priceRange: '\$80-200',
        location: '各區',
        rating: 4.3,
        tags: ['港式', '美食', '文化'],
      ),
      DateIdea(
        id: '5',
        title: '電影院約會',
        description: '在舒適的電影院觀看最新電影，享受爆米花和飲料，度過輕鬆愉快的時光。',
        category: '休閒娛樂',
        duration: '2-3小時',
        priceRange: '\$150-300',
        location: '各大商場',
        rating: 4.2,
        tags: ['電影', '室內', '輕鬆'],
      ),
      DateIdea(
        id: '6',
        title: '健身房運動',
        description: '一起到健身房運動，互相鼓勵，在運動中增進感情，保持健康生活。',
        category: '運動健身',
        duration: '1-2小時',
        priceRange: '\$100-250',
        location: '健身中心',
        rating: 4.0,
        tags: ['運動', '健康', '互動'],
      ),
    ];
  }

  void _showDateIdeaDetails(DateIdea idea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: _getCategoryGradient(idea.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(idea.category),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      idea.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 詳細描述
              Text(
                idea.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 詳細信息
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildInfoChip(
                    icon: Icons.access_time,
                    text: '時長: ${idea.duration}',
                    color: Colors.blue,
                  ),
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    text: '預算: ${idea.priceRange}',
                    color: Colors.green,
                  ),
                  _buildInfoChip(
                    icon: Icons.location_on,
                    text: '地點: ${idea.location}',
                    color: Colors.orange,
                  ),
                  _buildInfoChip(
                    icon: Icons.star,
                    text: '評分: ${idea.rating}',
                    color: Colors.amber,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 標籤
              const Text(
                '標籤',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: idea.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(idea.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCategoryColor(idea.category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              
              const Spacer(),
              
              // 操作按鈕
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareIdea(idea),
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF667EEA),
                        side: const BorderSide(color: Color(0xFF667EEA)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _sendDateIdea(idea);
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('發送給對方'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  void _shareIdea(DateIdea idea) {
    // TODO: 實現分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能即將推出！')),
    );
  }

  void _sendDateIdea(DateIdea idea) {
    // TODO: 發送約會建議到聊天
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已發送「${idea.title}」給 ${widget.otherUserName}！')),
    );
    Navigator.of(context).pop();
  }
}

// 約會建議數據模型
class DateIdea {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String priceRange;
  final String location;
  final double rating;
  final List<String> tags;

  DateIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.priceRange,
    required this.location,
    required this.rating,
    required this.tags,
  });
} 