import 'package:flutter/material.dart';

class TinderStyleSwipe extends StatefulWidget {
  final List<Widget> cards;
  final Function(int index, SwipeDirection direction)? onSwipe;
  final Function(int index)? onCardTap;

  const TinderStyleSwipe({
    super.key,
    required this.cards,
    this.onSwipe,
    this.onCardTap,
  });

  @override
  State<TinderStyleSwipe> createState() => _TinderStyleSwipeState();
}

class _TinderStyleSwipeState extends State<TinderStyleSwipe>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset += details.delta;
    });

    // 添加觸覺反饋
    if (_dragOffset.dx.abs() > 100) {
      // HapticFeedback.lightImpact();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 判斷滑動方向和速度
    if (_dragOffset.dx.abs() > screenWidth * 0.3 || velocity.dx.abs() > 1000) {
      // 執行滑動動畫
      final direction = _dragOffset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      _performSwipe(direction);
    } else {
      // 回彈動畫
      _resetCard();
    }
  }

  void _performSwipe(SwipeDirection direction) {
    _animationController.forward().then((_) {
      widget.onSwipe?.call(_currentIndex, direction);
      _nextCard();
    });
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
    });
    _animationController.reset();
  }

  // 程式化滑動（按鈕觸發）
  void swipeLeft() {
    _performSwipe(SwipeDirection.left);
  }

  void swipeRight() {
    _performSwipe(SwipeDirection.right);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景卡片（下一張）
        if (_currentIndex + 1 < widget.cards.length)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.7,
                child: widget.cards[_currentIndex + 1],
              ),
            ),
          ),

        // 當前卡片
        if (_currentIndex < widget.cards.length)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: () => widget.onCardTap?.call(_currentIndex),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final offset = _isDragging 
                      ? _dragOffset 
                      : _slideAnimation.value * MediaQuery.of(context).size.width;
                  
                  final rotation = _isDragging
                      ? _dragOffset.dx * 0.0005
                      : _rotationAnimation.value;

                  return Transform.translate(
                    offset: offset,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Stack(
                        children: [
                          widget.cards[_currentIndex],
                          
                          // 滑動指示器
                          if (_dragOffset.dx.abs() > 50)
                            Positioned(
                              top: 50,
                              left: _dragOffset.dx > 0 ? null : 50,
                              right: _dragOffset.dx > 0 ? 50 : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _dragOffset.dx > 0 
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _dragOffset.dx > 0 ? '喜歡' : '不喜歡',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // 操作按鈕
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 不喜歡按鈕
              FloatingActionButton(
                heroTag: "dislike",
                onPressed: swipeLeft,
                backgroundColor: Colors.red.shade400,
                child: const Icon(Icons.close, color: Colors.white),
              ),
              
              // 超級喜歡按鈕
              FloatingActionButton(
                heroTag: "superlike",
                onPressed: () {
                  // 實現超級喜歡功能
                },
                backgroundColor: Colors.blue.shade400,
                child: const Icon(Icons.star, color: Colors.white),
              ),
              
              // 喜歡按鈕
              FloatingActionButton(
                heroTag: "like",
                onPressed: swipeRight,
                backgroundColor: Colors.green.shade400,
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum SwipeDirection { left, right, up } 