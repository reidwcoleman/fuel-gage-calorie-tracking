import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_entry.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fuel_gauge.dart';
import 'add_food_screen.dart';
import 'scan_food_screen.dart';

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
                // Energy lost banner
                if (provider.showEnergyLostBanner)
                  SliverToBoxAdapter(
                    child: _buildEnergyLostBanner(context, provider),
                  ),
                // Greeting header
                SliverToBoxAdapter(
                  child: _buildGreeting(provider),
                ),
                // Main fuel gauge card
                SliverToBoxAdapter(
                  child: _buildFuelCard(provider),
                ),
                // Quick add buttons
                SliverToBoxAdapter(
                  child: _buildQuickActions(context),
                ),
                // Today's food
                SliverToBoxAdapter(
                  child: _buildTodaysFoodHeader(provider),
                ),
                // Food list
                if (provider.currentLog.entries.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = provider.currentLog.entries[index];
                        return _buildFoodItem(context, entry, provider);
                      },
                      childCount: provider.currentLog.entries.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyLostBanner(BuildContext context, CalorieProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.battery_2_bar,
            color: AppTheme.warningYellow,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '-${provider.energyLostSinceLastLogin.toStringAsFixed(0)}% since ${provider.lastActiveDescription}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: provider.dismissEnergyLostBanner,
            child: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(CalorieProvider provider) {
    final name = provider.userName.isNotEmpty ? provider.userName : 'there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${provider.greeting},',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelCard(CalorieProvider provider) {
    final percent = (provider.currentEnergy).clamp(0.0, 100.0);
    final fuelColor = AppTheme.getFuelColor(provider.progressPercent);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground,
            AppTheme.surfaceLight,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Energy Level',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${percent.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: fuelColor,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: fuelColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: FuelGauge(
                  percent: provider.progressPercent,
                  currentCalories: provider.totalCalories,
                  goalCalories: provider.calorieGoal,
                  statusText: provider.fuelStatus,
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progressPercent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation(fuelColor),
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                '${provider.totalCalories}',
                'eaten',
                AppTheme.primaryGreen,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textMuted.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                '${provider.calorieGoal}',
                'goal',
                AppTheme.textSecondary,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textMuted.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                '${provider.decayRatePerHour.toStringAsFixed(1)}%',
                '/hour',
                AppTheme.warningYellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add,
              label: 'Add Food',
              color: AppTheme.primaryGreen,
              onTap: () => _showMealTypeSelector(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.auto_awesome,
              label: 'AI Scan',
              color: AppTheme.accent,
              onTap: () => _showMealTypeSelectorForScan(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysFoodHeader(CalorieProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Today\'s Food',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '${provider.currentLog.entries.length} items',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No food logged yet',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + Add Food to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodEntry entry, CalorieProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppTheme.dangerRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.removeFoodEntry(entry.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  entry.mealType.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    entry.mealType.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${entry.calories}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
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
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add food to...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              for (final mealType in MealType.values)
                ListTile(
                  leading: Text(mealType.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    mealType.displayName,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFoodScreen(mealType: mealType),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showMealTypeSelectorForScan(BuildContext context) {
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
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Scan food to...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final mealType in MealType.values)
                ListTile(
                  leading: Text(mealType.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    mealType.displayName,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanFoodScreen(mealType: mealType),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
