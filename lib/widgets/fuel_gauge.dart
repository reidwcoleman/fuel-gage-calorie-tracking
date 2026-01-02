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
    final displayPercent = (percent * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 220,
            width: 220,
            child: CustomPaint(
              painter: _GaugePainter(
                percent: percent.clamp(0, 1.25),
                gaugeColor: AppTheme.getFuelColor(percent),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large percentage display
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$displayPercent',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getFuelColor(percent),
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getFuelColor(percent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ENERGY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: AppTheme.warningYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$currentCalories / $goalCalories',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.getFuelColor(percent).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.getFuelColor(percent).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 18,
                  color: AppTheme.getFuelColor(percent),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getFuelColor(percent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildRemainingCalories(),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (percent > 1.0) return Icons.warning_amber_rounded;
    if (percent >= 0.75) return Icons.check_circle_outline;
    if (percent >= 0.5) return Icons.trending_up;
    if (percent >= 0.25) return Icons.trending_flat;
    return Icons.trending_down;
  }

  Widget _buildRemainingCalories() {
    final remaining = goalCalories - currentCalories;
    final isOver = remaining < 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOver ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: isOver ? AppTheme.dangerRed : AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          isOver
              ? '${remaining.abs()} cal over goal'
              : '$remaining cal remaining',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isOver ? AppTheme.dangerRed : AppTheme.textSecondary,
          ),
        ),
      ],
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
    final radius = math.min(size.width, size.height) / 2 - 12;

    // Background arc
    final backgroundPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
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

    // Progress arc with gradient effect
    final progressPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final progressSweep = sweepAngle * percent.clamp(0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Draw percentage markers
    for (int i = 0; i <= 4; i++) {
      final tickAngle = startAngle + (sweepAngle * i / 4);
      final innerRadius = radius - 26;
      final outerRadius = radius - 20;

      final tickPaint = Paint()
        ..color = AppTheme.textMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final startPoint = Offset(
        center.dx + innerRadius * math.cos(tickAngle),
        center.dy + innerRadius * math.sin(tickAngle),
      );
      final endPoint = Offset(
        center.dx + outerRadius * math.cos(tickAngle),
        center.dy + outerRadius * math.sin(tickAngle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);

      // Draw percentage labels
      final labelRadius = radius + 22;
      final percentLabel = '${i * 25}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: percentLabel,
          style: TextStyle(
            color: AppTheme.textMuted.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(tickAngle) - textPainter.width / 2,
        center.dy + labelRadius * math.sin(tickAngle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.gaugeColor != gaugeColor;
  }
}
