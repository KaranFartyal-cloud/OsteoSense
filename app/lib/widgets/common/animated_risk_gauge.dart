import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../models/screening.dart';

class AnimatedRiskGauge extends StatefulWidget {
  final double value; // 0-100
  final RiskLevel riskLevel;
  final double size;
  final int? confidencePercentage;
  final String? subtitle;
  final bool animate;

  const AnimatedRiskGauge({
    super.key,
    required this.value,
    required this.riskLevel,
    this.size = 200,
    this.confidencePercentage,
    this.subtitle,
    this.animate = true,
  });

  @override
  State<AnimatedRiskGauge> createState() => _AnimatedRiskGaugeState();
}

class _AnimatedRiskGaugeState extends State<AnimatedRiskGauge>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _gaugeAnimation;
  late Animation<int> _confidenceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main gauge animation controller
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.countUpLong,
    );
    print('AnimatedRiskGauge: Animation started (duration: ${AppMotion.countUpLong.inMilliseconds}ms)');

    _gaugeAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _confidenceAnimation = IntTween(
      begin: 0,
      end: widget.confidencePercentage ?? 0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Continuous "breathing" glow — starts after gauge reveal completes
    // 3.5s loop, barely perceptible, gives the result screen life without chaos
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.ambientLong,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Particle orbit animation
    _particleController = AnimationController(
      vsync: this,
      duration: AppMotion.ambientLong,
    );

    if (widget.animate) {
      _controller.forward();
      // Start breathing glow and particles after gauge fill completes
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _pulseController.repeat(reverse: true);
          _particleController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// Smooth HSL interpolation between risk colors for natural transitions
  /// Uses HSL to interpolate hue while maintaining saturation and lightness
  Color _interpolateRiskColor(double t) {
    if (t < 0.33) {
      // Green to amber transition
      final localT = t / 0.33;
      const green = AppColors.riskLow;
      const amber = AppColors.riskMedium;
      return _hslInterpolate(green, amber, localT);
    } else if (t < 0.66) {
      // Amber to red transition
      final localT = (t - 0.33) / 0.33;
      const amber = AppColors.riskMedium;
      const red = AppColors.riskHigh;
      return _hslInterpolate(amber, red, localT);
    } else {
      return AppColors.riskHigh;
    }
  }

  /// HSL interpolation for natural color transitions
  Color _hslInterpolate(Color a, Color b, double t) {
    final hslA = HSLColor.fromColor(a);
    final hslB = HSLColor.fromColor(b);
    final interpolatedHsl = HSLColor.lerp(hslA, hslB, t);
    // HSLColor.lerp can return null if both are null — safe fallback
    return interpolatedHsl?.toColor() ?? a;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_gaugeAnimation, _pulseAnimation, _particleController]),
        builder: (context, child) {
          final normalizedValue = _gaugeAnimation.value / 100;
          // Use smooth HSL interpolation — color transitions during fill animation
          // instead of hard-snapping at 0.33/0.66 thresholds
          final riskColor = _interpolateRiskColor(normalizedValue);
          final pulseIntensity = _pulseAnimation.value;


          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: widget.size + 40, // Extra space for particles
                height: widget.size + 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing glow effect behind the gauge
                    _PulsingGlow(
                      color: riskColor,
                      intensity: pulseIntensity,
                      size: widget.size,
                    ),

                    // Background circle
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: GaugePainter(
                        value: 1.0,
                        color: AppColors.surfaceVariant,
                        strokeWidth: 12,
                      ),
                    ),

                    // Animated foreground circle
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: GaugePainter(
                        value: normalizedValue,
                        color: riskColor,
                        strokeWidth: 12,
                        isAnimated: true,
                      ),
                    ),

                    // Orbiting particles on reveal
                    _OrbitingParticles(
                      progress: _particleController.value,
                      color: riskColor,
                      size: widget.size,
                      isVisible: _particleController.isAnimating || _particleController.value > 0,
                    ),

                    // Center circle with score
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _gaugeAnimation.value.toStringAsFixed(0),
                          style: AppTypography.displayLarge.copyWith(
                            color: riskColor,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        Text(
                          'Risk Score',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Risk level label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _getRiskSurfaceColor(riskColor),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Text(
                  _getRiskLevelText(widget.riskLevel),
                  style: AppTypography.titleSmall.copyWith(
                    color: riskColor,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ),

              if (widget.confidencePercentage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: AppSpacing.iconMd,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_confidenceAnimation.value}% Confidence',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getRiskLevelText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  Color _getRiskSurfaceColor(Color riskColor) {
    if (riskColor == AppColors.riskLow) {
      return AppColors.riskLowSurface;
    } else if (riskColor == AppColors.riskMedium) {
      return AppColors.riskMediumSurface;
    } else {
      return AppColors.riskHighSurface;
    }
  }
}

/// Pulsing glow effect behind the gauge
class _PulsingGlow extends StatelessWidget {
  final Color color;
  final double intensity;
  final double size;

  const _PulsingGlow({
    required this.color,
    required this.intensity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 30,
      height: size + 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3 + (intensity * 0.5)),
            blurRadius: 20 + (intensity * 20),
            spreadRadius: -5 + (intensity * 10),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1 + (intensity * 0.3)),
            blurRadius: 40 + (intensity * 30),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

/// Orbiting particles that appear on gauge reveal
class _OrbitingParticles extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final bool isVisible;

  const _OrbitingParticles({
    required this.progress,
    required this.color,
    required this.size,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    const particleCount = 6;
    final orbitRadius = (size / 2) + 20;
    final center = Offset((size + 40) / 2, (size + 40) / 2);

    // Particles fade out as they complete their orbit
    final opacity = 1.0 - progress;
    if (opacity <= 0) return const SizedBox.shrink();

    return CustomPaint(
      size: Size(size + 40, size + 40),
      painter: _ParticlePainter(
        progress: progress,
        particleCount: particleCount,
        orbitRadius: orbitRadius,
        center: center,
        color: color.withValues(alpha: opacity * 0.8),
        dotRadius: 3 + (2 * math.sin(progress * math.pi)),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;
  final double orbitRadius;
  final Offset center;
  final Color color;
  final double dotRadius;

  _ParticlePainter({
    required this.progress,
    required this.particleCount,
    required this.orbitRadius,
    required this.center,
    required this.color,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      // Distribute particles evenly with offset based on progress
      final angle = (2 * math.pi / particleCount * i) + (progress * 2 * math.pi);
      final x = center.dx + orbitRadius * math.cos(angle);
      final y = center.dy + orbitRadius * math.sin(angle);

      // Vary the dot size slightly
      final radius = dotRadius * (0.7 + 0.3 * math.sin(i.toDouble()));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class GaugePainter extends CustomPainter {
  final double value; // 0-1
  final Color color;
  final double strokeWidth;
  final bool isAnimated;

  GaugePainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
    this.isAnimated = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Add glow effect for animated gauge
    if (isAnimated && value > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final center = Offset(size.width / 2, size.height / 2);
      final radius = (size.width - strokeWidth) / 2;

      const startAngle = -135 * 3.14159 / 180;
      const sweepAngle = 270 * 3.14159 / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * value,
        false,
        glowPaint,
      );
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc from -135 to 135 degrees (270 degree arc)
    const startAngle = -135 * 3.14159 / 180;
    const sweepAngle = 270 * 3.14159 / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
