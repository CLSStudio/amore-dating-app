import 'package:flutter/material.dart';
import '../../../../shared/widgets/user_card.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 模擬用戶數據
  final List<Map<String, dynamic>> _users = [
    {
      'name': '小雅',
      'age': 25,
      'distance': 2.5,
      'bio': '喜歡旅行和攝影，尋找有趣的靈魂 📸✈️',
      'mbti': 'ENFP',
      'interests': ['攝影', '旅行', '咖啡', '音樂'],
      'photos': ['https://picsum.photos/400/600?random=1'],
    },
    {
      'name': '志明',
      'age': 28,
      'distance': 1.2,
      'bio': '軟體工程師，熱愛科技和美食 💻🍜',
      'mbti': 'INTJ',
      'interests': ['程式設計', '美食', '電影', '健身'],
      'photos': ['https://picsum.photos/400/600?random=2'],
    },
    {
      'name': '美琪',
      'age': 26,
      'distance': 3.8,
      'bio': '藝術家，用色彩描繪世界 🎨',
      'mbti': 'ISFP',
      'interests': ['繪畫', '設計', '瑜伽', '植物'],
      'photos': ['https://picsum.photos/400/600?random=3'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFFE91E63),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '香港',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 篩選功能
            },
            icon: const Icon(
              Icons.tune,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 用戶卡片
          Expanded(
            child: _users.isEmpty
                ? _buildEmptyState()
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: UserCard(
                          user: _users[index],
                          onLike: () => _handleLike(index),
                          onPass: () => _handlePass(index),
                        ),
                      );
                    },
                  ),
          ),
          
          // 操作按鈕
          if (_users.isNotEmpty) _buildActionButtons(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暫時沒有新的配對',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '稍後再來看看吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 不喜歡按鈕
          GestureDetector(
            onTap: () => _handlePass(_currentIndex),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 28,
              ),
            ),
          ),
          
          // 超級喜歡按鈕
          GestureDetector(
            onTap: () => _handleSuperLike(_currentIndex),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.blue,
                size: 24,
              ),
            ),
          ),
          
          // 喜歡按鈕
          GestureDetector(
            onTap: () => _handleLike(_currentIndex),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike(int index) {
    setState(() {
      _users.removeAt(index);
      if (_currentIndex >= _users.length && _users.isNotEmpty) {
        _currentIndex = _users.length - 1;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已喜歡！'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handlePass(int index) {
    setState(() {
      _users.removeAt(index);
      if (_currentIndex >= _users.length && _users.isNotEmpty) {
        _currentIndex = _users.length - 1;
      }
    });
  }

  void _handleSuperLike(int index) {
    setState(() {
      _users.removeAt(index);
      if (_currentIndex >= _users.length && _users.isNotEmpty) {
        _currentIndex = _users.length - 1;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('超級喜歡！⭐'),
        duration: Duration(seconds: 1),
      ),
    );
  }
} 