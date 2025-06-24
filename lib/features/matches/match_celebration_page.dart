import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../chat/real_time_chat_page.dart';  // 添加導入

class MatchCelebrationPage extends StatefulWidget {
  final String matchedUserName;
  final String matchedUserImage;
  final String currentUserImage;
  final int compatibilityScore;

  const MatchCelebrationPage({
    super.key,
    required this.matchedUserName,
    required this.matchedUserImage,
    required this.currentUserImage,
    required this.compatibilityScore,
  });

  @override
  State<MatchCelebrationPage> createState() => _MatchCelebrationPageState();
}

class _MatchCelebrationPageState extends State<MatchCelebrationPage>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _heartAnimationController;
  late AnimationController _confettiAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _confettiAnimation;

  final List<Color> _confettiColors = [
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.orange,
    Colors.yellow,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _confettiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _heartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _confettiAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _confettiAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _startAnimations();
    
    // 觸覺反饋
    HapticFeedback.mediumImpact();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _heartAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _confettiAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _heartAnimationController.dispose();
    _confettiAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景漸變
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.pink.withOpacity(0.3),
                  Colors.purple.withOpacity(0.2),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // 彩紙動畫
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  animation: _confettiAnimation.value,
                  colors: _confettiColors,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // 主要內容
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // 配對成功標題
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: const Text(
                          "配對成功！",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 副標題
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value * 0.8,
                        child: Text(
                          "你和 ${widget.matchedUserName} 互相喜歡",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // 用戶頭像和愛心
                  _buildProfileSection(),
                  
                  const SizedBox(height: 40),
                  
                  // 兼容性分數
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: _buildCompatibilityScore(),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // 操作按鈕
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: _buildActionButtons(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 左側用戶頭像（當前用戶）
                Positioned(
                  left: 20,
                  child: _buildProfileAvatar(
                    imageUrl: widget.currentUserImage,
                    isCurrentUser: true,
                  ),
                ),
                
                // 右側用戶頭像（匹配用戶）
                Positioned(
                  right: 20,
                  child: _buildProfileAvatar(
                    imageUrl: widget.matchedUserImage,
                    isCurrentUser: false,
                  ),
                ),
                
                // 中間的愛心動畫
                AnimatedBuilder(
                  animation: _heartAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar({
    required String imageUrl,
    required bool isCurrentUser,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.grey.shade600,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompatibilityScore() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                color: Colors.blue.shade300,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '兼容性分析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 分數環形進度條
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: widget.compatibilityScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(widget.compatibilityScore),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.compatibilityScore}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getScoreDescription(widget.compatibilityScore),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _getCompatibilityMessage(widget.compatibilityScore),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 主要操作按鈕
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // 觸覺反饋
              HapticFeedback.mediumImpact();
              
              // 創建兼容性信息
              final compatibilityInfo = UserCompatibilityInfo(
                mbtiType: 'ENFP', // 這裡應該從實際數據獲取
                compatibilityScore: widget.compatibilityScore,
                commonInterests: ['攝影', '旅行', '咖啡'], // 從實際數據獲取
                matchReason: _getCompatibilityMessage(widget.compatibilityScore),
              );
              
              // 直接導航到實時聊天頁面，傳遞兼容性信息
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => RealTimeChatPage(
                    chatId: 'chat_${DateTime.now().millisecondsSinceEpoch}',
                    otherUserId: 'matched_user_id',
                    otherUserName: widget.matchedUserName,
                    otherUserPhoto: widget.matchedUserImage,
                    compatibilityInfo: compatibilityInfo,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '開始聊天',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 次要操作按鈕
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              '繼續探索',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '完美匹配';
    if (score >= 75) return '高度匹配';
    if (score >= 60) return '良好匹配';
    return '一般匹配';
  }

  String _getCompatibilityMessage(int score) {
    if (score >= 90) {
      return '你們有著驚人的相似性！共同的價值觀和興趣讓你們很容易產生共鳴。';
    } else if (score >= 75) {
      return '你們在很多方面都很合拍，有著良好的互補性和共同點。';
    } else if (score >= 60) {
      return '雖然有些差異，但這些差異可能會讓你們的關係更加有趣。';
    } else {
      return '你們各有特色，或許能在彼此身上發現新的世界。';
    }
  }
}

// 彩紙動畫繪製器
class ConfettiPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  
  ConfettiPainter({
    required this.animation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // 固定種子確保一致性

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 100;
      
      final currentY = startY + (endY - startY) * animation;
      
      // 添加一些搖擺效果
      final swayX = x + math.sin((currentY / 100) + i) * 30;
      
      paint.color = colors[i % colors.length].withOpacity(0.8);
      
      // 繪製小矩形作為彩紙
      final rect = Rect.fromCenter(
        center: Offset(swayX, currentY),
        width: 8,
        height: 15,
      );
      
      canvas.save();
      canvas.translate(swayX, currentY);
      canvas.rotate(animation * math.pi * 2 + i);
      canvas.translate(-swayX, -currentY);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
} 