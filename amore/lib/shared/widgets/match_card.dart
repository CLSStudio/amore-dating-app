import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MatchCard extends StatefulWidget {
  final String name;
  final int age;
  final String? location;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final String? mbtiType;
  final double? compatibilityScore;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;
  final VoidCallback? onTap;
  final bool isInteractable;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    this.location,
    this.bio,
    this.photos = const [],
    this.interests = const [],
    this.mbtiType,
    this.compatibilityScore,
    this.onLike,
    this.onPass,
    this.onSuperLike,
    this.onTap,
    this.isInteractable = true,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with TickerProviderStateMixin {
  late AnimationController _dragController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  Offset _dragOffset = Offset.zero;
  double _rotation = 0;
  int _currentPhotoIndex = 0;

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
        widget.onLike?.call();
      });
    } else if (_dragOffset.dx < -threshold) {
      // 向左滑動 - 跳過
      _animateToPosition(const Offset(-400, 0), () {
        widget.onPass?.call();
      });
    } else if (_dragOffset.dy < -threshold) {
      // 向上滑動 - 超級喜歡
      _animateToPosition(const Offset(0, -400), () {
        widget.onSuperLike?.call();
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
    if (widget.photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex + 1) % widget.photos.length;
      });
    }
  }

  void _previousPhoto() {
    if (widget.photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex = _currentPhotoIndex > 0 
            ? _currentPhotoIndex - 1 
            : widget.photos.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _rotation * 0.1,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: widget.onTap,
                child: Container(
                  width: double.infinity,
                  height: 600,
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
                        if (widget.photos.length > 1) _buildPhotoIndicators(),
                        
                        // 照片導航區域
                        if (widget.photos.length > 1) _buildPhotoNavigation(),
                        
                        // 滑動指示器
                        _buildSwipeIndicators(),
                        
                        // 用戶信息
                        _buildUserInfo(),
                        
                        // 兼容性分數
                        if (widget.compatibilityScore != null) _buildCompatibilityBadge(),
                        
                        // MBTI 標籤
                        if (widget.mbtiType != null) _buildMBTIBadge(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoBackground() {
    if (widget.photos.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cardGradient,
        ),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 100,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Image.network(
      widget.photos[_currentPhotoIndex],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.cardGradient,
          ),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Color(0x80000000),
              Color(0xCC000000),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(
          widget.photos.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(
                right: index < widget.photos.length - 1 ? 4 : 0,
              ),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoNavigation() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _previousPhoto,
              child: Container(color: Colors.transparent),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _nextPhoto,
              child: Container(color: Colors.transparent),
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 姓名和年齡
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.name}, ${widget.age}',
                    style: AppTextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.location != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location!,
                        style: AppTextStyles.cardInfo,
                      ),
                    ],
                  ),
              ],
            ),
            
            if (widget.bio != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.bio!,
                style: AppTextStyles.cardInfo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            if (widget.interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.interests.take(3).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityBadge() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
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
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.compatibilityScore!.round()}%',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMBTIBadge() {
    return Positioned(
      top: 50,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.mbtiType!,
          style: AppTextStyles.mbtiType.copyWith(
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
} 