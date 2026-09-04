import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/custom_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Header
              Text(
                'Welcome to JointSaathi',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select your role to get started',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: AppSpacing.xxxl),
              // Role cards
              _buildRoleCard(
                context,
                'Health Worker',
                'I\'m a healthcare professional conducting screenings',
                Icons.medical_services,
                AppColors.primary,
                0,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildRoleCard(
                context,
                'Self-Check User',
                'I want to check my own osteoarthritis risk',
                Icons.person,
                AppColors.accent,
                200,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      int delayMs,
      ) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      onTap: () {
        final role = title == 'Health Worker' ? 'agent' : 'user';
        context.go('/login?role=$role');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs)).slideY(
      begin: 0.2,
      end: 0,
      duration: 400.ms,
      delay: Duration(milliseconds: delayMs),
    );
  }
}