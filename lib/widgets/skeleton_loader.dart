import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Base shimmer skeleton loader
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Skeleton loader matching stat card shape
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.surfaceLight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader matching energy card shape
class SkeletonEnergyCard extends StatelessWidget {
  const SkeletonEnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.surfaceLight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Large percentage placeholder
            Container(
              width: 120,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            // "ENERGY LEVEL" label placeholder
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            // Progress bar placeholder
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader matching food item shape
class SkeletonFoodItem extends StatelessWidget {
  const SkeletonFoodItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            // Food name placeholder
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Calorie badge placeholder
            Container(
              width: 50,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for food list section
class SkeletonFoodList extends StatelessWidget {
  final int itemCount;

  const SkeletonFoodList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Column(
            children: [
              const SkeletonFoodItem(),
              if (index < itemCount - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full home screen skeleton
class SkeletonHomeScreen extends StatelessWidget {
  const SkeletonHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header skeleton
            Shimmer.fromColors(
              baseColor: AppTheme.cardBackground,
              highlightColor: AppTheme.surfaceLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 140,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Energy card skeleton
            const SkeletonEnergyCard(),
            const SizedBox(height: 20),
            // Stats row skeleton
            const Row(
              children: [
                Expanded(child: SkeletonStatCard()),
                SizedBox(width: 12),
                Expanded(child: SkeletonStatCard()),
                SizedBox(width: 12),
                Expanded(child: SkeletonStatCard()),
              ],
            ),
            const SizedBox(height: 28),
            // Food section skeleton
            const SkeletonFoodList(itemCount: 2),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
