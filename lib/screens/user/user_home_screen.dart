import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../shared/preventive_care_home_screen.dart';
import '../shared/symptom_questionnaire_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/role');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: AppSpacing.screenPaddingLg, bottom: AppSpacing.lg),
              title: Text(
                'My Dashboard',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            ),
          ),

          // ── Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome card
                _buildWelcomeCard(context)
                    .animate()
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),
                
                const SizedBox(height: AppSpacing.xxl),

                // Main CTA
                Text('Self Assessment', style: AppTypography.titleMedium.copyWith(fontWeight: AppTypography.semiBold)),
                const SizedBox(height: AppSpacing.md),
                _buildAssessmentCta(context)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                const SizedBox(height: AppSpacing.xxl),

                // Preventive care access
                Text('Learn & Prevent', style: AppTypography.titleMedium.copyWith(fontWeight: AppTypography.semiBold)),
                const SizedBox(height: AppSpacing.md),
                _buildPreventiveCareCard(context)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back!', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    Text(
                      'Jane Doe', // Hardcoded for demo until integrated
                      style: AppTypography.titleLarge.copyWith(fontWeight: AppTypography.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Risk Status: LOW', style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                      Text('Assessed 2 weeks ago', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCta(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Just launch a symptom questionnaire directly for self-assessment.
        // We will need to set a dummy patient ID in the provider or handle this in Phase 3.
        Navigator.of(context).push(
          MaterialPageRoute(
            // Passing a dummy patient ID for the demo UI flow.
            // In integration phase, we'll fetch/create the User's own Patient record.
            builder: (_) => const SymptomQuestionnaireScreen(patientId: 0),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Self-Check',
                    style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: AppTypography.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Answer a few questions & take a short walk to check your joint health.',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventiveCareCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Preventive Care Home Screen
        // We need to create a route for this or just push it. Let's push for simplicity.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PreventiveCareHomeScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4), // Light green tint
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preventive Care',
                    style: AppTypography.titleMedium.copyWith(color: const Color(0xFF166534), fontWeight: AppTypography.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exercises, diet tips, and habits to protect your joints.',
                    style: AppTypography.bodySmall.copyWith(color: const Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF166534)),
          ],
        ),
      ),
    );
  }
}
