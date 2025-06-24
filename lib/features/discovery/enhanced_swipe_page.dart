import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'enhanced_swipe_algorithm.dart';

// 滑動配對狀態管理
final currentCardIndexProvider = StateProvider<int>((ref) => 0);
final matchedUsersProvider = StateProvider<List<String>>((ref) => []);
final passedUsersProvider = StateProvider<List<String>>((ref) => []);

// 用戶數據模型
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String mbtiType;
  final int compatibilityScore;
  final String location;
  final String profession;
  final List<String> values;
  final bool isVerified;
  final String distance;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.mbtiType,
    required this.compatibilityScore,
    required this.location,
    required this.profession,
    required this.values,
    this.isVerified = false,
    this.distance = '2 公里',
  });
}

// 模擬用戶數據
final sampleUsers = [
  UserProfile(
    id: '1',
    name: '小雅',
    age: 25,
    bio: '喜歡旅行和攝影，尋找有趣的靈魂 ✈️📸\n\n熱愛探索新地方，記錄美好瞬間。希望找到一個能和我一起看世界的人。',
    photos: ['👩‍🦰', '📸', '🌅', '☕'],
    interests: ['旅行', '攝影', '咖啡', '瑜伽', '閱讀'],
    mbtiType: 'ENFP',
    compatibilityScore: 92,
    location: '香港島',
    profession: '攝影師',
    values: ['冒險', '創意', '真誠'],
    isVerified: true,
    distance: '1.2 公里',
  ),
  UserProfile(
    id: '2',
    name: '志明',
    age: 28,
    bio: '軟體工程師，熱愛音樂和電影 🎵🎬\n\n白天寫代碼，晚上彈吉他。相信技術能讓世界更美好。',
    photos: ['👨‍💻', '🎸', '🎬', '🍕'],
    interests: ['音樂', '電影', '程式設計', '遊戲', '美食'],
    mbtiType: 'INTJ',
    compatibilityScore: 87,
    location: '九龍',
    profession: '軟體工程師',
    values: ['創新', '邏輯', '成長'],
    isVerified: true,
    distance: '3.5 公里',
  ),
  UserProfile(
    id: '3',
    name: '美玲',
    age: 26,
    bio: '瑜伽教練，追求健康生活 🧘‍♀️🌱\n\n相信身心靈的平衡是幸福的關鍵。讓我們一起擁抱健康的生活方式。',
    photos: ['🧘‍♀️', '🥗', '🌿', '🏃‍♀️'],
    interests: ['瑜伽', '健身', '素食', '冥想', '自然'],
    mbtiType: 'ISFJ',
    compatibilityScore: 95,
    location: '新界',
    profession: '瑜伽教練',
    values: ['健康', '平衡', '關愛'],
    isVerified: false,
    distance: '5.8 公里',
  ),
  UserProfile(
    id: '4',
    name: '建華',
    age: 30,
    bio: '廚師，喜歡創造美味料理 👨‍🍳🍜\n\n用心做菜，用愛調味。希望能為特別的人做一桌好菜。',
    photos: ['👨‍🍳', '🍜', '🥘', '🍰'],
    interests: ['烹飪', '美食', '旅行', '品酒', '園藝'],
    mbtiType: 'ESFP',
    compatibilityScore: 89,
    location: '香港島',
    profession: '主廚',
    values: ['創意', '分享', '熱情'],
    isVerified: true,
    distance: '2.1 公里',
  ),
  UserProfile(
    id: '5',
    name: '詩婷',
    age: 24,
    bio: '藝術家，用畫筆描繪世界 🎨✨\n\n每一筆都是情感的表達，每一幅畫都是心靈的對話。',
    photos: ['👩‍🎨', '🎨', '🖼️', '🌈'],
    interests: ['繪畫', '藝術', '音樂', '文學', '展覽'],
    mbtiType: 'INFP',
    compatibilityScore: 91,
    location: '九龍',
    profession: '藝術家',
    values: ['創意', '真實', '美感'],
    isVerified: false,
    distance: '4.3 公里',
  ),
];

class EnhancedSwipePage extends ConsumerStatefulWidget {
  const EnhancedSwipePage({super.key});

  @override
  ConsumerState<EnhancedSwipePage> createState() => _EnhancedSwipePageState();
}

class _EnhancedSwipePageState extends ConsumerState<EnhancedSwipePage>
    with TickerProviderStateMixin {
  late AnimationController _swipeAnimationController;
  late AnimationController _matchAnimationController;
  late AnimationController _cardEntranceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _cardEntranceAnimation;

  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;
  bool _showMatchDialog = false;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardEntranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));

    _matchScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _matchAnimationController,
      curve: Curves.elasticOut,
    ));

    _cardEntranceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardEntranceController,
      curve: Curves.easeOutBack,
    ));

    _cardEntranceController.forward();
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _matchAnimationController.dispose();
    _cardEntranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentCardIndexProvider);
    
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
          child: currentIndex < sampleUsers.length
              ? Column(
                  children: [
                    _buildEnhancedTopBar(context),
                    Expanded(child: _buildEnhancedCardStack(context, currentIndex)),
                    _buildEnhancedBottomActions(context),
                  ],
                )
              : _buildNoMoreCards(context),
        ),
      ),
    );
  }

  Widget _buildEnhancedTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '探索',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
                Icons.tune,
                color: Color(0xFF2D3748),
              ),
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCardStack(BuildContext context, int currentIndex) {
    return Stack(
      children: [
        // 第三張卡片（最底層）
        if (currentIndex + 2 < sampleUsers.length)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Transform.scale(
                scale: 0.85,
                child: Transform.translate(
                  offset: const Offset(0, 20),
                  child: _buildEnhancedUserCard(
                    sampleUsers[currentIndex + 2], 
                    isBackground: true,
                    opacity: 0.3,
                  ),
                ),
              ),
            ),
          ),

        // 第二張卡片（中間層）
        if (currentIndex + 1 < sampleUsers.length)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Transform.scale(
                scale: 0.92,
                child: Transform.translate(
                  offset: const Offset(0, 10),
                  child: _buildEnhancedUserCard(
                    sampleUsers[currentIndex + 1], 
                    isBackground: true,
                    opacity: 0.6,
                  ),
                ),
              ),
            ),
          ),
        
        // 主要卡片（當前）
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: _onCardTap,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _swipeAnimationController,
                  _cardEntranceController,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardEntranceAnimation.value * 
                           (_isDragging ? 1.0 : _scaleAnimation.value),
                    child: Transform.translate(
                      offset: _isDragging 
                          ? _dragOffset 
                          : _slideAnimation.value * MediaQuery.of(context).size.width,
                      child: Transform.rotate(
                        angle: _isDragging 
                            ? _dragOffset.dx * 0.0008 
                            : _rotationAnimation.value,
                        child: _buildEnhancedUserCard(sampleUsers[currentIndex]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // 滑動指示器
        if (_isDragging)
          Positioned.fill(
            child: _buildEnhancedSwipeIndicator(),
          ),

        // 配對成功對話框
        if (_showMatchDialog)
          Positioned.fill(
            child: _buildEnhancedMatchDialog(),
          ),
      ],
    );
  }

  Widget _buildEnhancedUserCard(UserProfile user, {bool isBackground = false, double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isBackground ? 0.05 : 0.15),
              blurRadius: isBackground ? 15 : 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // 照片區域
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getGradientColor(user.mbtiType)[0],
                          _getGradientColor(user.mbtiType)[1],
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 主要照片
                        Center(
                          child: Text(
                            user.photos[_currentPhotoIndex],
                            style: const TextStyle(fontSize: 120),
                          ),
                        ),
                        
                        // 照片導航區域
                        Row(
                          children: user.photos.asMap().entries.map((entry) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _changePhoto(entry.key),
                                child: Container(
                                  height: double.infinity,
                                  color: Colors.transparent,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        // 驗證徽章
                        if (user.isVerified)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        
                        // 兼容性分數
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getCompatibilityGradient(user.compatibilityScore),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCompatibilityColor(user.compatibilityScore).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.compatibilityScore}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 照片指示器
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: user.photos.asMap().entries.map((entry) {
                              return Expanded(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: entry.key == _currentPhotoIndex 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 信息區域
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 姓名、年齡和 MBTI
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user.name}, ${user.age}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _getMBTIGradient(user.mbtiType),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                user.mbtiType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 職業、位置和距離
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.profession,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.distance,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 個人簡介
                        Expanded(
                          child: Text(
                            user.bio,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF4A5568),
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 興趣標籤
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.take(3).map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.pink.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.pink[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSwipeIndicator() {
    final isLike = _dragOffset.dx > 0;
    final opacity = (_dragOffset.dx.abs() / 120).clamp(0.0, 1.0);
    
    return Container(
      decoration: BoxDecoration(
        color: (isLike ? Colors.green : Colors.red).withOpacity(opacity * 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: AnimatedScale(
          scale: 0.8 + (opacity * 0.4),
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLike 
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.red[400]!, Colors.red[600]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isLike ? Colors.green : Colors.red).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isLike ? Icons.favorite : Icons.close,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhancedActionButton(
            icon: Icons.close,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            ),
            onTap: () => _performSwipeAction(false),
            size: 56,
          ),
          _buildEnhancedActionButton(
            icon: Icons.star,
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
            onTap: _showSuperLike,
            size: 48,
          ),
          _buildEnhancedActionButton(
            icon: Icons.favorite,
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
            onTap: () => _performSwipeAction(true),
            size: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      onTapCancel: () => setState(() {}),
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchDialog() {
    final currentIndex = ref.read(currentCardIndexProvider);
    final user = sampleUsers[currentIndex];
    
    return AnimatedBuilder(
      animation: _matchAnimationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Transform.scale(
              scale: _matchScaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 慶祝動畫
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '🎉',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      '配對成功！',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      '你和 ${user.name} 互相喜歡',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF718096),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '兼容性 ${user.compatibilityScore}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _showMatchDialog = false;
                                  });
                                },
                                child: const Center(
                                  child: Text(
                                    '繼續探索',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667EEA).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _showMatchDialog = false;
                                  });
                                  // 導航到聊天頁面
                                },
                                child: const Center(
                                  child: Text(
                                    '開始聊天',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
      },
    );
  }

  Widget _buildNoMoreCards(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '🎯',
                style: TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '暫時沒有更多用戶了',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '擴大搜索範圍或稍後再來看看',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ref.read(currentCardIndexProvider.notifier).state = 0;
                    _currentPhotoIndex = 0;
                    _cardEntranceController.reset();
                    _cardEntranceController.forward();
                  },
                  child: const Center(
                    child: Text(
                      '重新開始',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 事件處理方法
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25;
    
    if (_dragOffset.dx.abs() > threshold) {
      final isLike = _dragOffset.dx > 0;
      _performSwipeAction(isLike);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    }
  }

  void _onCardTap() {
    // 點擊卡片查看詳細信息
    // TODO: 實現詳細信息頁面
  }

  void _changePhoto(int index) {
    setState(() {
      _currentPhotoIndex = index;
    });
  }

  void _performSwipeAction(bool isLike) {
    final currentIndex = ref.read(currentCardIndexProvider);
    final user = sampleUsers[currentIndex];
    
    // 設置動畫方向
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isLike ? 2.0 : -2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _swipeAnimationController.forward().then((_) {
      setState(() {
        _isDragging = false;
        _dragOffset = Offset.zero;
        _currentPhotoIndex = 0;
      });
      
      if (isLike) {
        ref.read(matchedUsersProvider.notifier).state = [
          ...ref.read(matchedUsersProvider),
          user.id,
        ];
        
        // 模擬配對成功（基於兼容性分數）
        if (user.compatibilityScore > 85 && math.Random().nextBool()) {
          setState(() {
            _showMatchDialog = true;
          });
          _matchAnimationController.forward().then((_) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _matchAnimationController.reset();
              }
            });
          });
        }
      } else {
        ref.read(passedUsersProvider.notifier).state = [
          ...ref.read(passedUsersProvider),
          user.id,
        ];
      }
      
      ref.read(currentCardIndexProvider.notifier).state = currentIndex + 1;
      _swipeAnimationController.reset();
      _cardEntranceController.reset();
      _cardEntranceController.forward();
    });
  }

  void _showSuperLike() {
    // 實現超級喜歡功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('超級喜歡功能即將推出！'),
        backgroundColor: const Color(0xFF4FACFE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnhancedFilterSheet(),
    );
  }

  Widget _buildEnhancedFilterSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題欄
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '篩選條件',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 年齡範圍
            _buildFilterSection(
              title: '年齡範圍',
              child: Column(
                children: [
                  RangeSlider(
                    values: const RangeValues(22, 35),
                    min: 18,
                    max: 50,
                    divisions: 32,
                    labels: const RangeLabels('22', '35'),
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (values) {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('18', style: TextStyle(color: Colors.grey[600])),
                      Text('50', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 距離
            _buildFilterSection(
              title: '距離',
              child: Column(
                children: [
                  Slider(
                    value: 25,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '25 公里',
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 公里', style: TextStyle(color: Colors.grey[600])),
                      Text('100+ 公里', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // MBTI 類型偏好
            _buildFilterSection(
              title: 'MBTI 類型偏好',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['ENFP', 'INTJ', 'ISFJ', 'ESFP', 'INFP', 'ENTJ', 'ISFP', 'ENTP'].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: false,
                    selectedColor: const Color(0xFF667EEA).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF667EEA),
                    onSelected: (selected) {},
                  );
                }).toList(),
              ),
            ),
            
            const Spacer(),
            
            // 底部按鈕
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text(
                            '重置',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text(
                            '應用',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  // 輔助方法
  Color _getCompatibilityColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }

  List<Color> _getCompatibilityGradient(int score) {
    if (score >= 90) return [Colors.green[400]!, Colors.green[600]!];
    if (score >= 80) return [Colors.orange[400]!, Colors.orange[600]!];
    return [Colors.red[400]!, Colors.red[600]!];
  }

  List<Color> _getGradientColor(String mbtiType) {
    final gradients = {
      'ENFP': [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      'INTJ': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'ISFJ': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      'ESFP': [const Color(0xFFFC466B), const Color(0xFF3F5EFB)],
      'INFP': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    };
    return gradients[mbtiType] ?? [Colors.pink[300]!, Colors.purple[300]!];
  }

  List<Color> _getMBTIGradient(String mbtiType) {
    return _getGradientColor(mbtiType);
  }
} 