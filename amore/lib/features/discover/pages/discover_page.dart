import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/match_card.dart';
import '../../../shared/widgets/custom_button.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'name': 'Clara',
      'age': 20,
      'location': '中環',
      'bio': '喜歡攝影和咖啡，尋找有趣的靈魂 ✨',
      'photos': [
        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      ],
      'interests': ['攝影', '咖啡', '旅行', '音樂'],
      'mbtiType': 'ENFP',
      'compatibilityScore': 92.0,
    },
    {
      'name': 'Brandon',
      'age': 20,
      'location': '銅鑼灣',
      'bio': '熱愛運動和美食，希望找到志同道合的人 🏃‍♂️',
      'photos': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      ],
      'interests': ['健身', '美食', '電影', '籃球'],
      'mbtiType': 'ESTP',
      'compatibilityScore': 85.0,
    },
    {
      'name': 'Alfredo',
      'age': 20,
      'location': '尖沙咀',
      'bio': '藝術愛好者，喜歡深度對話和創意思考 🎨',
      'photos': [
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
      ],
      'interests': ['藝術', '設計', '閱讀', '哲學'],
      'mbtiType': 'INFJ',
      'compatibilityScore': 78.0,
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onLike() {
    _animateButtonPress();
    _nextCard();
    // TODO: 實現喜歡邏輯
  }

  void _onPass() {
    _animateButtonPress();
    _nextCard();
    // TODO: 實現跳過邏輯
  }

  void _onSuperLike() {
    _animateButtonPress();
    _nextCard();
    // TODO: 實現超級喜歡邏輯
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _mockUsers.length;
    });
  }

  void _animateButtonPress() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導航欄
            _buildTopBar(),
            
            // 主要內容區域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // 匹配卡片區域
                    Expanded(
                      child: _buildCardStack(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 底部操作按鈕
                    _buildActionButtons(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 標題
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '尋找你的完美匹配',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 篩選按鈕
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.tune,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                // TODO: 打開篩選頁面
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    if (_mockUsers.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        // 背景卡片（下一張）
        if (_currentIndex + 1 < _mockUsers.length)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.5,
                child: _buildCard(_mockUsers[_currentIndex + 1], false),
              ),
            ),
          ),
        
        // 當前卡片
        Positioned.fill(
          child: _buildCard(_mockUsers[_currentIndex], true),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> user, bool isInteractable) {
    return MatchCard(
      name: user['name'],
      age: user['age'],
      location: user['location'],
      bio: user['bio'],
      photos: List<String>.from(user['photos']),
      interests: List<String>.from(user['interests']),
      mbtiType: user['mbtiType'],
      compatibilityScore: user['compatibilityScore'],
      isInteractable: isInteractable,
      onLike: _onLike,
      onPass: _onPass,
      onSuperLike: _onSuperLike,
      onTap: () {
        // TODO: 打開用戶詳情頁面
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            '沒有更多用戶了',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '試試調整你的篩選條件',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          CustomButton(
            text: '調整篩選',
            onPressed: () {
              // TODO: 打開篩選頁面
            },
            variant: ButtonVariant.outlined,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 跳過按鈕
              _buildActionButton(
                icon: Icons.close,
                color: AppColors.pass,
                gradient: AppColors.passGradient,
                onPressed: _onPass,
              ),
              
              // 超級喜歡按鈕
              _buildActionButton(
                icon: Icons.star,
                color: AppColors.superLike,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF03DAC6)],
                ),
                onPressed: _onSuperLike,
                size: 56,
              ),
              
              // 喜歡按鈕
              _buildActionButton(
                icon: Icons.favorite,
                color: AppColors.like,
                gradient: AppColors.likeGradient,
                onPressed: _onLike,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onPressed,
    double size = 64,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(size / 2),
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
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
} 