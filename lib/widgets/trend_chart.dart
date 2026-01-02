import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../theme/app_theme.dart';

/// Line chart showing calorie trends over time
class TrendChart extends StatelessWidget {
  final List<DailyLog> logs;
  final int days;
  final int calorieGoal;
  final double height;

  const TrendChart({
    super.key,
    required this.logs,
    this.days = 7,
    required this.calorieGoal,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: calorieGoal / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartData.length) {
                    return const SizedBox.shrink();
                  }
                  final date = chartData[index]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: calorieGoal / 2,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: 0,
          maxY: (calorieGoal * 1.5).toDouble(),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              // Goal line
              HorizontalLine(
                y: calorieGoal.toDouble(),
                color: AppTheme.accentOrange.withValues(alpha: 0.6),
                strokeWidth: 2,
                dashArray: [8, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  labelResolver: (line) => 'Goal',
                ),
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: chartData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['calories'] as int).toDouble(),
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppTheme.primaryTeal,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isToday = index == chartData.length - 1;
                  return FlDotCirclePainter(
                    radius: isToday ? 6 : 4,
                    color: isToday ? AppTheme.primaryTealLight : AppTheme.primaryTeal,
                    strokeWidth: isToday ? 2 : 0,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryTeal.withValues(alpha: 0.3),
                    AppTheme.primaryTeal.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) => AppTheme.cardBackground,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= chartData.length) return null;
                  final date = chartData[index]['date'] as DateTime;
                  final calories = spot.y.toInt();
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n',
                    const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '$calories cal',
                        style: const TextStyle(
                          color: AppTheme.primaryTealLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  List<Map<String, dynamic>> _prepareChartData() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final result = <Map<String, dynamic>>[];

    // Create a map of date keys to logs for quick lookup
    final logMap = <String, DailyLog>{};
    for (final log in logs) {
      logMap[log.dateKey] = log;
    }

    // Fill in all days, using 0 for missing days
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final log = logMap[dateKey];

      result.add({
        'date': date,
        'calories': log?.totalCalories ?? 0,
        'hasData': log != null,
      });
    }

    return result;
  }

  Widget _buildEmptyState() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 40,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Not enough data for trends',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Log food for a few days to see your progress',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact trend indicator showing direction
class TrendIndicator extends StatelessWidget {
  final List<DailyLog> logs;
  final int days;

  const TrendIndicator({
    super.key,
    required this.logs,
    this.days = 7,
  });

  @override
  Widget build(BuildContext context) {
    final trend = _calculateTrend();

    IconData icon;
    Color color;
    String text;

    if (trend > 5) {
      icon = Icons.trending_up_rounded;
      color = AppTheme.accentOrange;
      text = '+${trend.toStringAsFixed(0)}%';
    } else if (trend < -5) {
      icon = Icons.trending_down_rounded;
      color = AppTheme.primaryTeal;
      text = '${trend.toStringAsFixed(0)}%';
    } else {
      icon = Icons.trending_flat_rounded;
      color = AppTheme.textMuted;
      text = 'Stable';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculateTrend() {
    if (logs.length < 2) return 0;

    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    final recentLogs = sortedLogs.length > days
        ? sortedLogs.sublist(sortedLogs.length - days)
        : sortedLogs;

    if (recentLogs.length < 2) return 0;

    final midpoint = recentLogs.length ~/ 2;
    final firstHalf = recentLogs.sublist(0, midpoint);
    final secondHalf = recentLogs.sublist(midpoint);

    final firstAvg = firstHalf.fold<int>(0, (sum, log) => sum + log.totalCalories) /
        firstHalf.length;
    final secondAvg = secondHalf.fold<int>(0, (sum, log) => sum + log.totalCalories) /
        secondHalf.length;

    if (firstAvg == 0) return 0;
    return ((secondAvg - firstAvg) / firstAvg) * 100;
  }
}
