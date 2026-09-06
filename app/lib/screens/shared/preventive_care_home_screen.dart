import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import 'preventive_care_category_screen.dart';

class PreventiveCareHomeScreen extends StatelessWidget {
  const PreventiveCareHomeScreen({super.key});

  static const _categories = [
    _CareCategory(
      id: 'exercises',
      title: 'Exercises',
      subtitle: 'Strengthen joints & improve mobility',
      icon: Icons.fitness_center_rounded,
      articleCount: 3,
      gradient: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _CareCategory(
      id: 'diet',
      title: 'Diet & Nutrition',
      subtitle: 'Anti-inflammatory foods for joint health',
      icon: Icons.restaurant_menu_rounded,
      articleCount: 3,
      gradient: LinearGradient(
        colors: [Color(0xFFFF784E), Color(0xFFFFB199)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _CareCategory(
      id: 'lifestyle',
      title: 'Lifestyle',
      subtitle: 'Daily habits to protect your joints',
      icon: Icons.self_improvement_rounded,
      articleCount: 3,
      gradient: LinearGradient(
        colors: [Color(0xFF5B6EE8), Color(0xFF0D7377)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Curved header
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _CategoryCard(category: cat)
                        .animate(delay: (index * 100).ms)
                        .fadeIn(duration: AppMotion.standard)
                        .slideY(begin: 0.12, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),

          // ── Tip of the day card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingLg,
                0,
                AppSpacing.screenPaddingLg,
                AppSpacing.xl,
              ),
              child: _buildTipOfDay()
                  .animate(delay: 400.ms)
                  .fadeIn(duration: AppMotion.standard),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXl),
          bottomRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingLg,
            AppSpacing.md,
            AppSpacing.screenPaddingLg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('9 articles', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Icon(Icons.spa_rounded, color: Colors.white, size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Preventive Care',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.bold,
                ),
              ),
              Text(
                'Evidence-based tips to protect joint health\nand reduce osteoarthritis risk',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.15, end: 0, duration: 800.ms, curve: AppMotion.curve);
  }

  Widget _buildTipOfDay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip of the Day', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: AppTypography.semiBold)),
                const SizedBox(height: 2),
                Text(
                  'Walking just 30 minutes a day reduces OA knee pain by up to 12% over 6 weeks.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CareCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PreventiveCareCategoryScreen(
            categoryId: category.id,
            categoryTitle: category.title,
            gradient: category.gradient,
            icon: category.icon,
          ),
        ),
      ),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: category.gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: (category.gradient.colors.first).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon (large, subtle)
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(category.icon, size: 100, color: Colors.white.withValues(alpha: 0.12)),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(category.title, style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: AppTypography.bold)),
                        const SizedBox(height: 4),
                        Text(category.subtitle, style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${category.articleCount} articles', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int articleCount;
  final LinearGradient gradient;

  const _CareCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.articleCount,
    required this.gradient,
  });
}
