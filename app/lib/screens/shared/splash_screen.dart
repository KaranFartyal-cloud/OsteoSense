import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/ambient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _particleController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Background gradient animation morphing from trust to onboarding
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _initializeApp();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    debugPrint('Splash: waiting 2.5s...');
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      debugPrint('Splash: loading settings...');
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.loadSettings();
      debugPrint('Splash: settings loaded.');

      debugPrint('Splash: loading auth...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadCurrentUser();
      debugPrint('Splash: auth loaded.');

      if (!mounted) return;

      if (authProvider.isAuthenticated && authProvider.userRole != null) {
        if (authProvider.userRole == 'agent') {
          debugPrint('Splash: routing to agent home');
          context.go('/agent/home');
        } else {
          debugPrint('Splash: routing to user home');
          context.go('/user/home');
        }
      } else {
        debugPrint('Splash: routing to language');
        context.go('/language');
      }
    } catch (e, stack) {
      debugPrint('Splash Error: $e\n$stack');
      if (mounted) context.go('/language');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        primaryColor: Colors.white,
        child: AnimatedBuilder(
          animation: _bgAnimation,
          builder: (context, child) {
            final t = _bgAnimation.value;
            final color1 = Color.lerp(AppColors.trustGradient.colors[0], AppColors.onboardingGradient1.colors[0], t)!;
            final color2 = Color.lerp(AppColors.trustGradient.colors[1], AppColors.onboardingGradient1.colors[1], t)!;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2],
                ),
              ),
              child: Stack(
                children: [
                  // Animated particles in background
                  _AnimatedParticles(controller: _particleController),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with breathing glow animation
                        _BreathingLogo()
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.05, 1.05),
                              end: const Offset(1, 1),
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            ),

                        const SizedBox(height: AppSpacing.xl),

                        // App name with fade and slide
                        Text(
                          'JointSaathi',
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 300.ms),

                        const SizedBox(height: AppSpacing.sm),

                        // Tagline with fade
                        Text(
                          'AI-Assisted OA Risk Screening',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 500.ms),

                        const SizedBox(height: AppSpacing.xxxl),

                        // Loading indicator
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 700.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              delay: 700.ms,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Breathing logo with soft glow
class _BreathingLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 50,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Icon(
            Icons.health_and_safety,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Animated floating particles for depth
class _AnimatedParticles extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedParticles({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlesPainter(animation: controller.value),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animation;
  final _random = math.Random(42);

  _ParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Generate 15 particles at different positions
    for (int i = 0; i < 15; i++) {
      // Each particle has its own phase and speed
      final phase = i * 0.4;
      final speed = 0.5 + (i % 3) * 0.3;
      final particleProgress = (animation * speed + phase) % 1.0;

      // Base position
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;

      // Vertical floating motion
      final offsetY = math.sin(particleProgress * math.pi * 2) * 30;

      // Opacity fades in and out
      final opacity = math.sin(particleProgress * math.pi) * 0.15;
      paint.color = Colors.white.withValues(alpha: opacity);

      // Particle size varies
      final radius = 2.0 + (_random.nextDouble() * 3);

      canvas.drawCircle(
        Offset(baseX, baseY + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
