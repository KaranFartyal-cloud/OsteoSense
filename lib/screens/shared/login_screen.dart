import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, this.role = 'agent'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();

    // Demo login (pre-integration) — calls existing demoLogin method
    await authProvider.demoLogin(widget.role);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (authProvider.isAuthenticated) {
      final route = widget.role == 'agent' ? '/agent/home' : '/user/home';
      context.go(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAgent = widget.role == 'agent';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top gradient banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingLg,
                  AppSpacing.xl,
                  AppSpacing.screenPaddingLg,
                  AppSpacing.xxl,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXl),
                    bottomRight: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
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
                    const SizedBox(height: AppSpacing.xl),

                    // JointSaathi logo
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('JointSaathi', style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: AppTypography.bold)),
                            Text('MDoNER Healthcare Initiative', style: AppTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      isAgent ? 'Health Worker Login' : 'Self-Check Login',
                      style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: AppTypography.bold),
                    ),
                    Text(
                      isAgent
                          ? 'Sign in to manage patients and run OA screenings'
                          : 'Sign in to check your personal OA risk',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                    ),
                  ],
                ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: -0.1, end: 0, duration: AppMotion.slow, curve: AppMotion.curve),
              ),

              // ── Form
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.md),

                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '10-digit mobile number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone number required';
                          if (v.length < 10) return 'Enter a valid 10-digit number';
                          return null;
                        },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 100.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                      const SizedBox(height: AppSpacing.md),

                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textTertiary, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 4) return 'Password too short';
                          return null;
                        },
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 150.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot password?', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      CustomButton(
                        text: 'Sign In',
                        onPressed: _isLoading ? null : _login,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
                        isLoading: _isLoading,
                        trailingIcon: const Icon(Icons.arrow_forward_rounded),
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 200.ms),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Sign up link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text('New to JointSaathi? ', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => context.push('/signup?role=${widget.role}'),
                              child: Text('Create Account', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: AppTypography.semiBold)),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 250.ms),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Role toggle
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded, color: AppColors.textTertiary, size: 18),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                isAgent ? 'Not a health worker?' : 'Are you a health worker?',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login?role=${isAgent ? 'user' : 'agent'}'),
                              child: Text(
                                isAgent ? 'Self-check login' : 'Agent login',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: AppTypography.semiBold),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}