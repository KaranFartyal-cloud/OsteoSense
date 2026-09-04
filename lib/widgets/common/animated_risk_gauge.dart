import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gaugeAnimation;
  late Animation<int> _confidenceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _gaugeAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _confidenceAnimation = IntTween(
      begin: 0,
      end: widget.confidencePercentage ?? 0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRiskColor(double normalizedValue) {
    if (normalizedValue < 0.33) {
      return AppColors.riskLow;
    } else if (normalizedValue < 0.66) {
      return AppColors.riskMedium;
    } else {
      return AppColors.riskHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _gaugeAnimation,
        builder: (context, child) {
          final normalizedValue = _gaugeAnimation.value / 100;
          final riskColor = _getRiskColor(normalizedValue);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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
                    // Center circle with score
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_gaugeAnimation.value.toStringAsFixed(0)}',
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
                  color: _getRiskSurfaceColor(_getRiskColor(normalizedValue)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Text(
                  _getRiskLevelText(widget.riskLevel),
                  style: AppTypography.titleSmall.copyWith(
                    color: _getRiskColor(normalizedValue),
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