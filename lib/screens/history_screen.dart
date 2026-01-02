import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/daily_log.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trend_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<Map<String, DailyLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = context.read<CalorieProvider>().getAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Consumer<CalorieProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<Map<String, DailyLog>>(
            future: _logsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                );
              }

              final logs = snapshot.data ?? {};
              final sortedKeys = logs.keys.toList()..sort((a, b) => b.compareTo(a));

              if (sortedKeys.isEmpty) {
                return _buildEmptyState();
              }

              // Group logs by week
              final weeklyGroups = _groupByWeek(logs, sortedKeys);
              final allLogs = logs.values.toList();

              return CustomScrollView(
                slivers: [
                  // Trend Chart Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Calorie Trends',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              TrendIndicator(logs: allLogs, days: 7),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: TrendChart(
                              logs: allLogs,
                              days: 14,
                              calorieGoal: provider.calorieGoal,
                              height: 180,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Weekly sections
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final weekGroup = weeklyGroups[index];
                        return _buildWeekSection(
                          context,
                          provider,
                          weekGroup['title'] as String,
                          weekGroup['logs'] as List<DailyLog>,
                          provider.calorieGoal,
                        );
                      },
                      childCount: weeklyGroups.length,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No history yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging foods to see your history',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupByWeek(
    Map<String, DailyLog> logs,
    List<String> sortedKeys,
  ) {
    final groups = <Map<String, dynamic>>[];
    String? currentWeekTitle;
    List<DailyLog> currentWeekLogs = [];

    for (final key in sortedKeys) {
      final log = logs[key]!;
      final weekTitle = _getWeekTitle(log.date);

      if (weekTitle != currentWeekTitle) {
        if (currentWeekLogs.isNotEmpty) {
          groups.add({
            'title': currentWeekTitle,
            'logs': currentWeekLogs,
          });
        }
        currentWeekTitle = weekTitle;
        currentWeekLogs = [log];
      } else {
        currentWeekLogs.add(log);
      }
    }

    if (currentWeekLogs.isNotEmpty) {
      groups.add({
        'title': currentWeekTitle,
        'logs': currentWeekLogs,
      });
    }

    return groups;
  }

  String _getWeekTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(logDate).inDays;

    if (difference < 7) {
      return 'This Week';
    } else if (difference < 14) {
      return 'Last Week';
    } else {
      final weekStart = logDate.subtract(Duration(days: logDate.weekday - 1));
      return 'Week of ${DateFormat('MMM d').format(weekStart)}';
    }
  }

  Widget _buildWeekSection(
    BuildContext context,
    CalorieProvider provider,
    String title,
    List<DailyLog> logs,
    int goal,
  ) {
    final totalCalories = logs.fold<int>(0, (sum, log) => sum + log.totalCalories);
    final avgCalories = logs.isNotEmpty ? totalCalories ~/ logs.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Avg: $avgCalories cal/day',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final log in logs)
          _buildDayTile(context, provider, log, goal),
      ],
    );
  }

  Widget _buildDayTile(
    BuildContext context,
    CalorieProvider provider,
    DailyLog log,
    int goal,
  ) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final percent = (log.totalCalories / goal).clamp(0.0, 1.0);
    final isToday = _isSameDay(log.date, DateTime.now());
    final fuelColor = AppTheme.getFuelColor(log.totalCalories / goal);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          provider.selectDate(log.date);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        isToday ? 'Today' : dateFormat.format(log.date),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppTheme.primaryTeal
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${log.totalCalories} cal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: fuelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                lineHeight: 8,
                percent: percent,
                backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.3),
                progressColor: fuelColor,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${log.entries.length} items logged',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '${((log.totalCalories / goal) * 100).round()}% of goal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
