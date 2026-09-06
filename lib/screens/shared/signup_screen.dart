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

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, this.role = 'agent'});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _healthCenterController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _healthCenterController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();

    // For now, call demo login. We will update this during the integration phase.
    await authProvider.demoLogin(widget.role);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (authProvider.isAuthenticated) {
      final route = widget.role == 'agent' ? '/agent/home' : '/user/home';
      context.go(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Signup failed'),
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

                    Text(
                      isAgent ? 'Create Health Worker Account' : 'Create Account',
                      style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: AppTypography.bold),
                    ),
                    Text(
                      isAgent
                          ? 'Join the network of health workers screening for osteoarthritis'
                          : 'Join JointSaathi to manage your osteoarthritis risk',
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
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Full name required';
                          return null;
                        },
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 50.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

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
                        hint: 'Create a password (min 6 chars)',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textTertiary, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 150.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                      if (isAgent) ...[
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: _healthCenterController,
                          label: 'Health Center / Clinic',
                          hint: 'Optional: name of your health center',
                          prefixIcon: const Icon(Icons.local_hospital_outlined),
                        ).animate().fadeIn(duration: AppMotion.standard, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: _locationController,
                          label: 'Location (Village / Block)',
                          hint: 'Optional: your operating area',
                          prefixIcon: const Icon(Icons.location_city_outlined),
                        ).animate().fadeIn(duration: AppMotion.standard, delay: 250.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),
                      ],

                      const SizedBox(height: AppSpacing.xxl),

                      CustomButton(
                        text: 'Sign Up',
                        onPressed: _isLoading ? null : _signup,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
                        isLoading: _isLoading,
                        trailingIcon: const Icon(Icons.arrow_forward_rounded),
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 300.ms),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Login link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text('Already have an account? ', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => context.go('/login?role=${widget.role}'),
                              child: Text('Login', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: AppTypography.semiBold)),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: AppMotion.standard, delay: 350.ms),
                      const SizedBox(height: AppSpacing.lg),
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