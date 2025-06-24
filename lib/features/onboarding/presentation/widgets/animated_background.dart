import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? [
      AppColors.primary.withOpacity(0.1),
      AppColors.secondary.withOpacity(0.1),
      AppColors.success.withOpacity(0.1),
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors[0], colors[1], _animation.value)!,
                Color.lerp(colors[1], colors[2], _animation.value)!,
                Color.lerp(colors[2], colors[0], _animation.value)!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
} 