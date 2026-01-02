import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_entry.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_loader.dart';
import 'add_food_screen.dart';
import 'scan_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownConfetti = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        // Check if we should show confetti (goal reached)
        final shouldCelebrate = provider.currentEnergy >= 100 && !_hasShownConfetti;

        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: const SafeArea(
              child: SkeletonHomeScreen(),
            ),
          );
        }

        return ConfettiTrigger(
          trigger: shouldCelebrate,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.refreshEnergy();
                },
                color: AppTheme.primaryTeal,
                backgroundColor: AppTheme.cardBackground,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildHeader(provider),
                        const SizedBox(height: 32),
                        _buildEnergyCard(provider),
                        const SizedBox(height: 20),
                        _buildStatsRow(provider),
                        const SizedBox(height: 28),
                        _buildFoodSection(context, provider),
                        const SizedBox(height: 24),
                        _buildLogButton(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CalorieProvider provider) {
    final name = provider.userName.isNotEmpty ? provider.userName : 'there';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.greeting,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (provider.showEnergyLostBanner) ...[
              GestureDetector(
                onTap: provider.dismissEnergyLostBanner,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: AppTheme.accentOrange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '-${provider.energyLostSinceLastLogin.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            _buildMiniCircle(
              value: provider.currentEnergy.clamp(0, 100) / 100,
              label: '${provider.currentEnergy.round()}%',
              icon: Icons.bolt_rounded,
              color: AppTheme.getFuelColor(provider.progressPercent),
            ),
            const SizedBox(width: 10),
            _buildMiniCircle(
              value: provider.progressPercent.clamp(0, 1),
              label: '${provider.totalCalories}',
              icon: Icons.local_fire_department_rounded,
              color: AppTheme.accentOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCircle({
    required double value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                AppTheme.surfaceLight.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: 46,
            height: 46,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(CalorieProvider provider) {
    final percent = provider.currentEnergy.clamp(0.0, 100.0);
    final fuelColor = AppTheme.getFuelColor(provider.progressPercent);

    // Check for goal achievement
    if (provider.currentEnergy >= 100 && !_hasShownConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _hasShownConfetti = true);
      });
    }

    return SimpleGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          AnimatedPercentage(
            value: percent,
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w300,
              color: fuelColor,
              height: 1,
              letterSpacing: -3,
            ),
            percentStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: fuelColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ENERGY LEVEL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          // Animated progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: provider.progressPercent.clamp(0.0, 1.0),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fuelColor.withValues(alpha: 0.8),
                          fuelColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: fuelColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CalorieProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            provider.totalCalories,
            'eaten',
            Icons.restaurant_rounded,
            isAnimated: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            provider.calorieGoal,
            'goal',
            Icons.flag_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCardText(
            '-${provider.decayRatePerHour.toStringAsFixed(0)}%',
            'per hr',
            Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(int value, String label, IconData icon, {bool isAnimated = false}) {
    return SimpleGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryTeal.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(height: 8),
          isAnimated
              ? AnimatedCounterStateful(
                  value: value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                )
              : Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardText(String value, String label, IconData icon) {
    return SimpleGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.accentOrange.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSection(BuildContext context, CalorieProvider provider) {
    final entries = provider.currentLog.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '${entries.length} items',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.glassBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 32,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No meals logged yet',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap below to add your first meal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.glassBorder,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppTheme.glassBorder,
              ),
              itemBuilder: (context, index) {
                return _buildFoodItem(entries[index], provider);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFoodItem(FoodEntry entry, CalorieProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.dangerRed.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 22),
      ),
      onDismissed: (_) => provider.removeFoodEntry(entry.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  entry.mealType.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                entry.foodName,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${entry.calories}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showMealSelector(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryTeal,
                    AppTheme.primaryTealLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Log Food',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showMealSelector(context, true),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppTheme.accentOrange,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  void _showMealSelector(BuildContext context, bool isScan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isScan ? 'AI Scan' : 'Log Food',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a meal type',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                for (final mealType in MealType.values)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isScan
                              ? ScanFoodScreen(mealType: mealType)
                              : AddFoodScreen(mealType: mealType),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                mealType.icon,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            mealType.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: AppTheme.textMuted,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
