import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/mbti_models.dart';

class MBTITraitsRadar extends StatefulWidget {
  final MBTIResult result;

  const MBTITraitsRadar({
    super.key,
    required this.result,
  });

  @override
  State<MBTITraitsRadar> createState() => _MBTITraitsRadarState();
}

class _MBTITraitsRadarState extends State<MBTITraitsRadar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(300, 300),
            painter: RadarChartPainter(
              result: widget.result,
              animationValue: _animation.value,
            ),
          );
        },
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final MBTIResult result;
  final double animationValue;

  RadarChartPainter({
    required this.result,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    // 繪製背景網格
    _drawGrid(canvas, center, radius);
    
    // 繪製軸線和標籤
    _drawAxes(canvas, center, radius);
    
    // 繪製數據區域
    _drawDataArea(canvas, center, radius);
    
    // 繪製數據點
    _drawDataPoints(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 繪製同心圓
    for (int i = 1; i <= 5; i++) {
      final circleRadius = radius * i / 5;
      canvas.drawCircle(center, circleRadius, gridPaint);
    }

    // 繪製軸線
    final angles = [0, math.pi / 2, math.pi, 3 * math.pi / 2];
    for (final angle in angles) {
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final labels = ['外向性', '直覺性', '思考性', '判斷性'];
    final angles = [0, math.pi / 2, math.pi, 3 * math.pi / 2];

    for (int i = 0; i < labels.length; i++) {
      final angle = angles[i];
      final labelRadius = radius + 30;
      final labelPosition = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: labels[i],
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();

      // 調整文字位置使其居中
      final textOffset = Offset(
        labelPosition.dx - textPainter.width / 2,
        labelPosition.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius) {
    final scores = [
      result.extraversionScore / 100,
      result.intuitionScore / 100,
      result.thinkingScore / 100,
      result.judgingScore / 100,
    ];

    final angles = [0, math.pi / 2, math.pi, 3 * math.pi / 2];
    final path = Path();

    for (int i = 0; i < scores.length; i++) {
      final angle = angles[i];
      final score = scores[i] * animationValue;
      final point = Offset(
        center.dx + radius * score * math.cos(angle),
        center.dy + radius * score * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // 填充區域
    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2 * animationValue)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 邊框
    final strokePaint = Paint()
      ..color = AppColors.primary.withOpacity(animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius) {
    final scores = [
      result.extraversionScore / 100,
      result.intuitionScore / 100,
      result.thinkingScore / 100,
      result.judgingScore / 100,
    ];

    final angles = [0, math.pi / 2, math.pi, 3 * math.pi / 2];
    
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final angle = angles[i];
      final score = scores[i] * animationValue;
      final point = Offset(
        center.dx + radius * score * math.cos(angle),
        center.dy + radius * score * math.sin(angle),
      );

      // 繪製點的白色邊框
      canvas.drawCircle(point, 6, pointBorderPaint);
      // 繪製點
      canvas.drawCircle(point, 4, pointPaint);

      // 繪製分數標籤
      if (animationValue > 0.8) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(scores[i] * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final labelOffset = Offset(
          point.dx - textPainter.width / 2,
          point.dy - textPainter.height / 2 - 20,
        );

        // 繪製標籤背景
        final labelBg = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(point.dx, point.dy - 20),
            width: textPainter.width + 8,
            height: textPainter.height + 4,
          ),
          const Radius.circular(8),
        );

        final bgPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawRRect(labelBg, bgPaint);
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RadarChartPainter && 
           oldDelegate.animationValue != animationValue;
  }
} 