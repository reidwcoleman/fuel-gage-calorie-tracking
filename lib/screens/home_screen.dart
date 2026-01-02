import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/food_entry.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/skeleton_loader.dart';
import 'add_food_screen.dart';
import 'scan_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _hasShownConfetti = false;
  late AnimationController _pulseController;
  late AnimationController _gaugeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        final shouldCelebrate = provider.currentEnergy >= 100 && !_hasShownConfetti;

        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: const SafeArea(child: SkeletonHomeScreen()),
          );
        }

        return ConfettiTrigger(
          trigger: shouldCelebrate,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: AppTheme.background,
              body: Container(
                decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
                child: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async => await provider.refreshEnergy(),
                    color: AppTheme.primaryTeal,
                    backgroundColor: AppTheme.cardBackground,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(provider),
                                const SizedBox(height: 32),
                                _buildFuelGauge(provider),
                                const SizedBox(height: 32),
                                _buildQuickStats(provider),
                                const SizedBox(height: 32),
                                _buildFoodList(provider),
                                const SizedBox(height: 24),
                                _buildActionButtons(context),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.greeting,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (provider.showEnergyLostBanner)
          GestureDetector(
            onTap: provider.dismissEnergyLostBanner,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentOrange.withValues(
                        alpha: 0.2 + (_pulseController.value * 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_down_rounded,
                        color: AppTheme.accentOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '-${provider.energyLostSinceLastLogin.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFuelGauge(CalorieProvider provider) {
    final energyPercent = (provider.currentEnergy / 100).clamp(0.0, 1.0);
    final energyColor = AppTheme.getFuelColor(provider.progressPercent);

    if (provider.currentEnergy >= 100 && !_hasShownConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _hasShownConfetti = true);
      });
    }

    return Center(
      child: AnimatedBuilder(
        animation: _gaugeController,
        builder: (context, child) {
          final animatedValue = Curves.easeOutCubic.transform(_gaugeController.value);

          return SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: energyColor.withValues(alpha: 0.2 * animatedValue),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Background ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _GaugeBackgroundPainter(),
                ),
                // Progress ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _GaugeProgressPainter(
                    progress: energyPercent * animatedValue,
                    color: energyColor,
                  ),
                ),
                // Inner content
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.background,
                    border: Border.all(
                      color: energyColor.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: energyColor,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      AnimatedCounterStateful(
                        value: provider.currentEnergy.round(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -2,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'ENERGY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(CalorieProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppTheme.accentOrange,
              value: provider.totalCalories.toString(),
              label: 'eaten',
              isAnimated: true,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppTheme.glassBorder,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.flag_rounded,
              iconColor: AppTheme.primaryTeal,
              value: provider.calorieGoal.toString(),
              label: 'goal',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppTheme.glassBorder,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.schedule_rounded,
              iconColor: AppTheme.textMuted,
              value: '-${provider.decayRatePerHour.toStringAsFixed(0)}%',
              label: 'per hour',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool isAnimated = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 8),
        isAnimated
            ? AnimatedCounterStateful(
                value: int.tryParse(value) ?? 0,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodList(CalorieProvider provider) {
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entries.length} ${entries.length == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          _buildEmptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  for (int i = 0; i < entries.length; i++) ...[
                    _buildFoodItem(entries[i], provider),
                    if (i < entries.length - 1)
                      Divider(
                        height: 1,
                        color: AppTheme.glassBorder,
                        indent: 60,
                      ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 24,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No meals logged',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start tracking your energy intake',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodEntry entry, CalorieProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppTheme.dangerRed.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppTheme.dangerRed,
          size: 22,
        ),
      ),
      onDismissed: (_) => provider.removeFoodEntry(entry.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryTeal.withValues(alpha: 0.15),
                    AppTheme.primaryTeal.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppTheme.primaryTeal,
                size: 18,
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
            Text(
              '+${entry.calories}',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AddFoodScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.primaryGlow(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Log Food',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ScanFoodScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentOrange.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.accentOrange,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for gauge background
class _GaugeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = AppTheme.surfaceLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(7),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for gauge progress
class _GaugeProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugeProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient
    final gradient = SweepGradient(
      startAngle: -math.pi * 0.75,
      endAngle: math.pi * 0.75,
      colors: [
        color.withValues(alpha: 0.6),
        color,
        color,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(7),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
