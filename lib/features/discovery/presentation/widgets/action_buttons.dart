import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;
  final VoidCallback onBoost;
  final Animation<double> animation;

  const ActionButtons({
    super.key,
    required this.onPass,
    required this.onSuperLike,
    required this.onLike,
    required this.onBoost,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 跳過按鈕
              _buildActionButton(
                icon: Icons.close,
                color: AppColors.pass,
                size: 56,
                onPressed: onPass,
              ),
              
              // 超級喜歡按鈕
              _buildActionButton(
                icon: Icons.star,
                color: AppColors.superLike,
                size: 48,
                onPressed: onSuperLike,
              ),
              
              // 喜歡按鈕
              _buildActionButton(
                icon: Icons.favorite,
                color: AppColors.like,
                size: 64,
                onPressed: onLike,
              ),
              
              // 推廣按鈕
              _buildActionButton(
                icon: Icons.flash_on,
                color: AppColors.boost,
                size: 48,
                onPressed: onBoost,
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
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.4,
        ),
      ),
    );
  }
} 