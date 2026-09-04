import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/index.dart';

class SignupScreen extends StatelessWidget {
  final String role;
  const SignupScreen({super.key, this.role = 'agent'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign Up', style: AppTypography.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  role == 'agent'
                      ? 'Create your Health Worker account'
                      : 'Create your account to get started',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomButton(
                  text: 'Continue to Home',
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.demoLogin(role);

                    if (!context.mounted) return;

                    if (role == 'agent') {
                      context.go('/agent/home');
                    } else {
                      context.go('/user/home');
                    }
                  },
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    context.go('/login?role=$role');
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}