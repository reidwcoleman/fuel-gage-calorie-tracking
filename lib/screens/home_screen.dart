import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/food_entry.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fuel_gauge.dart';
import '../widgets/meal_section.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, provider),
                ),
                SliverToBoxAdapter(
                  child: FuelGauge(
                    percent: provider.progressPercent,
                    currentCalories: provider.totalCalories,
                    goalCalories: provider.calorieGoal,
                    statusText: provider.fuelStatus,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickStats(provider),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    for (final mealType in MealType.values)
                      MealSection(
                        mealType: mealType,
                        entries: provider.currentLog.entriesForMeal(mealType),
                        totalCalories: provider.currentLog.caloriesForMeal(mealType),
                        onAddPressed: () => _navigateToAddFood(context, mealType),
                        onDeleteEntry: (id) => provider.removeFoodEntry(id),
                      ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showMealTypeSelector(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Food'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CalorieProvider provider) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final isToday = provider.isToday;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.goToPreviousDay,
            icon: const Icon(Icons.chevron_left, size: 28),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, provider),
            child: Column(
              children: [
                Text(
                  isToday ? 'Today' : dateFormat.format(provider.selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (!isToday)
                  TextButton(
                    onPressed: provider.goToToday,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Go to Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: provider.isToday ? null : provider.goToNextDay,
            icon: Icon(
              Icons.chevron_right,
              size: 28,
              color: provider.isToday ? AppTheme.textMuted : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(CalorieProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Breakfast',
              '${provider.currentLog.caloriesForMeal(MealType.breakfast)} cal',
              Icons.wb_sunny_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Lunch',
              '${provider.currentLog.caloriesForMeal(MealType.lunch)} cal',
              Icons.wb_cloudy_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Dinner',
              '${provider.currentLog.caloriesForMeal(MealType.dinner)} cal',
              Icons.nightlight_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context, CalorieProvider provider) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              surface: AppTheme.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      provider.selectDate(date);
    }
  }

  void _showMealTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add food to...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              for (final mealType in MealType.values)
                ListTile(
                  leading: Text(
                    mealType.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    mealType.displayName,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddFood(context, mealType);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddFood(BuildContext context, MealType mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(mealType: mealType),
      ),
    );
  }
}
