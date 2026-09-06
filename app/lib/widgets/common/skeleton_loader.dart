import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Centralized skeleton/shimmer widgets that replace all generic spinners.
/// Each skeleton is shaped like the real content it replaces, creating a
/// seamless transition when data loads. Skeletons shimmer continuously
/// until real content cross-fades in smoothly.

// ========================================================================
// BASIC SKELETONS
// ========================================================================

/// A generic skeleton box — shape configurable
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool rounded;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        (rounded ? BorderRadius.circular(AppSpacing.radiusMd) : BorderRadius.zero);
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: radius,
        ),
      ),
    );
  }
}

/// A circular skeleton (avatar, profile image)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ========================================================================
// SCREEN-SPECIFIC SKELETONS
// ========================================================================

/// Skeleton for a list tile (patient list, screening list)
/// Matches the shape of _buildPatientCard in PatientListScreen
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingLg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              const SkeletonCircle(size: AppSpacing.avatarMd),
              const SizedBox(width: AppSpacing.md),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name line
                  SkeletonBox(
                    width: double.infinity,
                    height: AppSpacing.sm,
                    rounded: true,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Subtitle line (shorter)
                  SkeletonBox(
                    width: 140,
                    height: AppSpacing.xs,
                    rounded: true,
                  ),
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: AppSpacing.md),
              const SkeletonBox(
                width: AppSpacing.iconMd,
                height: AppSpacing.iconMd,
                rounded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen skeleton for loading states (home dashboard, patient list)
/// Contains multiple skeleton blocks that mirror the actual layout
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header area
          const SkeletonBox(width: 120, height: 16, rounded: true),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(width: 200, height: 32, rounded: true),
          const SizedBox(height: AppSpacing.xl),

          // Stat cards
          const Row(
            children: [
              Expanded(
                child: SkeletonCard(
                  height: 90,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: SkeletonCard(
                  height: 90,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: SkeletonCard(
                  height: 90,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: SkeletonCard(
                  height: 90,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Section header
          const SkeletonBox(width: 140, height: 22, rounded: true),
          const SizedBox(height: AppSpacing.md),

          // List tiles
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: SkeletonListTile(),
          )),
        ],
      ),
    );
  }
}

/// Skeleton for stat cards — matches _PremiumStatCard shape
class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title line
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surface,
            child: Container(
              width: 80,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Value line
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surface,
            child: Container(
              width: 60,
              height: AppSpacing.lg,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a single report item
class SkeletonReportTile extends StatelessWidget {
  const SkeletonReportTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingLg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: 48,
            height: 48,
            rounded: true,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14, rounded: true),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(width: 180, height: 12, rounded: true),
              ],
            ),
          ),
          SkeletonBox(
            width: 40,
            height: 24,
            rounded: true,
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the risk result screen gauge area
class SkeletonRiskResult extends StatelessWidget {
  const SkeletonRiskResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gauge placeholder
        Center(
          child: Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const SkeletonCircle(size: 100),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Text placeholders
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
          child: Column(
            children: [
              SkeletonBox(width: 150, height: 20, rounded: true),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(width: 250, height: 16, rounded: true),
              SizedBox(height: AppSpacing.xl),
              SkeletonBox(width: double.infinity, height: 60, rounded: true),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-page skeleton for initial loading (splash-like loading)
class SkeletonPage extends StatelessWidget {
  final bool showAppBar;
  final int listItemCount;

  const SkeletonPage({
    super.key,
    this.showAppBar = true,
    this.listItemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showAppBar) ...[
          // App bar placeholder
          const Padding(
            padding: EdgeInsets.all(AppSpacing.screenPaddingLg),
            child: Row(
              children: [
                SkeletonCircle(size: 36),
                SizedBox(width: AppSpacing.md),
                SkeletonBox(width: 100, height: 24, rounded: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Content skeleton
        ...List.generate(listItemCount, (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonListTile(),
        )),
      ],
    );
  }
}