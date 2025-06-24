import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EnhancedMatchCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isInteractable;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onTap;

  const EnhancedMatchCard({
    super.key,
    required this.user,
    this.isInteractable = true,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onTap,
  });

  @override
  State<EnhancedMatchCard> createState() => _EnhancedMatchCardState();
}

class _EnhancedMatchCardState extends State<EnhancedMatchCard>
    with TickerProviderStateMixin {
  late AnimationController _dragController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  Offset _dragOffset = Offset.zero;
  double _rotation = 0;
  int _currentPhotoIndex = 0;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _dragController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isInteractable) return;
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isInteractable) return;
    setState(() {
      _dragOffset += details.delta;
      _rotation = _dragOffset.dx / 300;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isInteractable) return;
    _scaleController.reverse();
    
    const threshold = 100.0;
    
    if (_dragOffset.dx > threshold) {
      // 向右滑動 - 喜歡
      _animateToPosition(const Offset(400, 0), () {
        widget.onSwipeRight?.call();
      });
    } else if (_dragOffset.dx < -threshold) {
      // 向左滑動 - 跳過
      _animateToPosition(const Offset(-400, 0), () {
        widget.onSwipeLeft?.call();
      });
    } else if (_dragOffset.dy < -threshold) {
      // 向上滑動 - 超級喜歡
      _animateToPosition(const Offset(0, -400), () {
        widget.onSwipeUp?.call();
      });
    } else {
      // 回到原位
      _animateToPosition(Offset.zero, null);
    }
  }

  void _animateToPosition(Offset target, VoidCallback? onComplete) {
    final animation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOut,
    ));

    animation.addListener(() {
      setState(() {
        _dragOffset = animation.value;
        _rotation = _dragOffset.dx / 300;
      });
    });

    _dragController.forward().then((_) {
      onComplete?.call();
      _dragController.reset();
      setState(() {
        _dragOffset = Offset.zero;
        _rotation = 0;
      });
    });
  }

  void _nextPhoto() {
    final photos = widget.user['photos'] as List<String>? ?? [];
    if (photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex + 1) % photos.length;
      });
    }
  }

  void _previousPhoto() {
    final photos = widget.user['photos'] as List<String>? ?? [];
    if (photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex - 1 + photos.length) % photos.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _rotation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // 背景圖片
                        _buildPhotoBackground(),
                        
                        // 漸變遮罩
                        _buildGradientOverlay(),
                        
                        // 照片指示器
                        _buildPhotoIndicators(),
                        
                        // 照片導航區域
                        _buildPhotoNavigation(),
                        
                        // 滑動指示器
                        _buildSwipeIndicators(),
                        
                        // 用戶信息
                        _buildUserInfo(),
                        
                        // 兼容性分數
                        _buildCompatibilityBadge(),
                        
                        // MBTI 標籤
                        _buildMBTIBadge(),
                        
                        // 詳細信息切換
                        _buildDetailsToggle(),
                        
                        // 詳細信息覆蓋層
                        if (_showDetails) _buildDetailsOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoBackground() {
    final photos = widget.user['photos'] as List<String>? ?? [];
    if (photos.isEmpty) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.person,
            size: 100,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      );
    }

    return Image.network(
      photos[_currentPhotoIndex],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.primary.withOpacity(0.1),
          child: const Center(
            child: Icon(
              Icons.error,
              size: 50,
              color: AppColors.error,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    final photos = widget.user['photos'] as List<String>? ?? [];
    if (photos.length <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: photos.asMap().entries.map((entry) {
          final index = entry.key;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(
                right: index < photos.length - 1 ? 4 : 0,
              ),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoNavigation() {
    final photos = widget.user['photos'] as List<String>? ?? [];
    if (photos.length <= 1) return const SizedBox.shrink();

    return Positioned.fill(
      child: Row(
        children: [
          // 左側點擊區域
          Expanded(
            child: GestureDetector(
              onTap: _previousPhoto,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 右側點擊區域
          Expanded(
            child: GestureDetector(
              onTap: _nextPhoto,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final opacity = math.min(_dragOffset.dx.abs() / 100, 1.0);
    
    return Stack(
      children: [
        // 喜歡指示器
        if (_dragOffset.dx > 20)
          Positioned(
            top: 100,
            right: 20,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.like, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIKE',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.like,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // 跳過指示器
        if (_dragOffset.dx < -20)
          Positioned(
            top: 100,
            left: 20,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.pass, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PASS',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.pass,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // 超級喜歡指示器
        if (_dragOffset.dy < -20)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: math.min(_dragOffset.dy.abs() / 100, 1.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.superLike, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SUPER LIKE',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.superLike,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    final name = widget.user['name'] as String? ?? '';
    final age = widget.user['age'] as int? ?? 0;
    final distance = widget.user['distance'] as double? ?? 0.0;
    final bio = widget.user['bio'] as String? ?? '';

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 姓名和年齡
          Row(
            children: [
              Expanded(
                child: Text(
                  '$name, $age',
                  style: AppTextStyles.headline3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${distance.toStringAsFixed(1)} km',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 簡介
          if (bio.isNotEmpty && !_showDetails)
            Text(
              bio.split('\n').first,
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityBadge() {
    final score = widget.user['compatibilityScore'] as double? ?? 0.0;
    
    return Positioned(
      top: 60,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
              '${score.toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMBTIBadge() {
    final mbti = widget.user['mbti'] as String? ?? '';
    if (mbti.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      top: 60,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          mbti,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsToggle() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _showDetails ? Icons.close : Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsOverlay() {
    final occupation = widget.user['occupation'] as String? ?? '';
    final education = widget.user['education'] as String? ?? '';
    final height = widget.user['height'] as int? ?? 0;
    final languages = widget.user['languages'] as List<String>? ?? [];
    final interests = widget.user['interests'] as List<String>? ?? [];
    final bio = widget.user['bio'] as String? ?? '';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              
              // 詳細簡介
              if (bio.isNotEmpty) ...[
                Text(
                  '關於我',
                  style: AppTextStyles.headline5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // 基本信息
              Text(
                '基本信息',
                style: AppTextStyles.headline5.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              if (occupation.isNotEmpty)
                _buildDetailItem('職業', occupation),
              if (education.isNotEmpty)
                _buildDetailItem('教育', education),
              if (height > 0)
                _buildDetailItem('身高', '$height cm'),
              if (languages.isNotEmpty)
                _buildDetailItem('語言', languages.join(', ')),
              
              const SizedBox(height: 20),
              
              // 興趣愛好
              if (interests.isNotEmpty) ...[
                Text(
                  '興趣愛好',
                  style: AppTextStyles.headline5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((interest) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      interest,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 