import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FuelGauge extends StatelessWidget {
  final double percent;
  final int currentCalories;
  final int goalCalories;
  final String statusText;

  const FuelGauge({
    super.key,
    required this.percent,
    required this.currentCalories,
    required this.goalCalories,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: CustomPaint(
              painter: _GaugePainter(
                percent: percent.clamp(0, 1.25),
                gaugeColor: AppTheme.getFuelColor(percent),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_gas_station,
                      size: 32,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentCalories',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'of $goalCalories cal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.getFuelColor(percent).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getFuelColor(percent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildRemainingCalories(),
        ],
      ),
    );
  }

  Widget _buildRemainingCalories() {
    final remaining = goalCalories - currentCalories;
    final isOver = remaining < 0;

    return Text(
      isOver
          ? '${remaining.abs()} cal over goal'
          : '$remaining cal remaining',
      style: TextStyle(
        fontSize: 14,
        color: isOver ? AppTheme.dangerRed : AppTheme.textSecondary,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color gaugeColor;

  _GaugePainter({
    required this.percent,
    required this.gaugeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final progressSweep = sweepAngle * percent.clamp(0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = AppTheme.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i <= 4; i++) {
      final tickAngle = startAngle + (sweepAngle * i / 4);
      final innerRadius = radius - 24;
      final outerRadius = radius - 18;

      final startPoint = Offset(
        center.dx + innerRadius * math.cos(tickAngle),
        center.dy + innerRadius * math.sin(tickAngle),
      );
      final endPoint = Offset(
        center.dx + outerRadius * math.cos(tickAngle),
        center.dy + outerRadius * math.sin(tickAngle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // Draw E and F labels
    _drawLabel(canvas, center, radius, startAngle, 'E');
    _drawLabel(canvas, center, radius, startAngle + sweepAngle, 'F');
  }

  void _drawLabel(Canvas canvas, Offset center, double radius, double angle, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelRadius = radius + 20;
    final labelOffset = Offset(
      center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
      center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
    );

    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.gaugeColor != gaugeColor;
  }
}
