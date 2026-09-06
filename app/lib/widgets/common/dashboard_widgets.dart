import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'animated_counter.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';

// ═══════════════════════════════════════════════════════════════════════════
// HEADER — Curved S-clip + geometric deco painter
// ═══════════════════════════════════════════════════════════════════════════

/// Clips the header with a gentle S-curve at the bottom, so content below
/// appears to flow out of the header organically.
class HeaderClipper extends CustomClipper<Path> {
  final double amplitude;

  HeaderClipper({this.amplitude = 1.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - (48 * amplitude));
    // S-curve: two cubic beziers meeting at the midpoint
    path.cubicTo(
      size.width * 0.18, size.height - (4 * amplitude),   // CP1
      size.width * 0.36, size.height + (20 * amplitude),  // CP2
      size.width * 0.5,  size.height + (4 * amplitude),   // midpoint
    );
    path.cubicTo(
      size.width * 0.64, size.height - (12 * amplitude),  // CP1
      size.width * 0.82, size.height - (36 * amplitude),  // CP2
      size.width,        size.height - (24 * amplitude),  // end
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant HeaderClipper oldClipper) => oldClipper.amplitude != amplitude;
}

/// Paints subtle, barely-visible geometric shapes inside the header as texture.
/// 4–5% opacity white circles and rounded rects — Stripe/Cash App style.
class HeaderDecoPainter extends CustomPainter {
  const HeaderDecoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);

    // Large circle — top-right, half off-screen
    canvas.drawCircle(Offset(size.width * 0.88, -size.height * 0.1), 140, paint);

    // Medium circle — left-center
    canvas.drawCircle(Offset(-30, size.height * 0.55), 100, paint);

    // Rounded rect — lower-right quadrant
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.78),
        width: 120,
        height: 120,
      ),
      const Radius.circular(28),
    );
    canvas.drawRRect(rrect, paint);

    // Small circle — upper-left accent
    final softPaint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.18), 60, softPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION HEADER — Title + 4×20px colored left accent tick
// ═══════════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  final String title;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left accent tick — 4px wide, 22px tall, rounded ends
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO STAT CARD — Full-width, 56px number, sparkline, watermark icon
// ═══════════════════════════════════════════════════════════════════════════

class HeroStatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final List<double> sparklineData;

  const HeroStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.sparklineData = const [3, 5, 4, 7, 6, 9, 8],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Watermark icon — large, barely visible, top-right background
          Positioned(
            right: -12,
            top: -16,
            child: Icon(
              icon,
              size: 110,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                title.toUpperCase(),
                style: AppTypography.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  letterSpacing: 1.8,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: 6),
              // Big number — animated count-up
              AnimatedCounter(
                value: value,
                duration: const Duration(milliseconds: 1400),
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.extraBold,
                  letterSpacing: -2.0,
                  fontSize: 56,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              // Sparkline — animates in after number, draws from left
              SizedBox(
                height: 48,
                child: _Sparkline(
                  data: sparklineData,
                  color: Colors.white,
                ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.12, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 8),
              // Subtle trend label
              Text(
                'Last 7 days',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: AppTypography.light,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.10, end: 0, duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// A self-drawing sparkline that animates its path over time using a CustomPainter.
class _Sparkline extends StatefulWidget {
  final List<double> data;
  final Color color;

  const _Sparkline({required this.data, required this.color});

  @override
  State<_Sparkline> createState() => _SparklineState();
}

class _SparklineState extends State<_Sparkline> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    // Add a slight delay before starting to draw
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: _SparklinePainter(
            data: widget.data,
            color: widget.color,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double progress;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(math.max) * 1.3;
    const minVal = 0.0;
    final range = maxVal - minVal;
    
    final path = Path();
    final widthStep = size.width / (data.length - 1);
    
    // Build the full path
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * widthStep;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    
    // Draw smooth cubic curve
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPointX = p1.dx + (p2.dx - p1.dx) / 2;
      path.cubicTo(
        controlPointX, p1.dy,
        controlPointX, p2.dy,
        p2.dx, p2.dy,
      );
    }

    // Extract the portion of the path based on progress
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    final pathMetric = pathMetrics.first;
    final extractPath = pathMetric.extractPath(0.0, pathMetric.length * progress);

    // Create bounds for the gradient
    final bounds = extractPath.getBounds();
    final gradient = LinearGradient(
      colors: [color, color.withValues(alpha: 0.3)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    // Draw the line
    final paint = Paint()
      ..shader = gradient.createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(extractPath, paint);
    
    // Draw the gradient area below the line (if progress is > 0)
    if (progress > 0) {
      final areaPath = Path.from(extractPath);
      // Close the path to the bottom to create the fill area
      final lastPoint = pathMetric.getTangentForOffset(pathMetric.length * progress)?.position ?? Offset(size.width * progress, size.height);
      areaPath.lineTo(lastPoint.dx, size.height);
      areaPath.lineTo(0, size.height);
      areaPath.close();

      final gradientPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.22 * progress),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
      canvas.drawPath(areaPath, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPACT STAT CARD — Asymmetric bento subordinate card
// Bold number, left color accent bar, no icon box
// ═══════════════════════════════════════════════════════════════════════════

class CompactStatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final String? subtitle;

  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          const BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max, // Fill the container
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        children: [
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: AppTypography.light,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Animated count-up for compact cards
          AnimatedCounter(
            value: value,
            duration: const Duration(milliseconds: 1200),
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTypography.extraBold,
              letterSpacing: -1.5,
              fontSize: 46,
              height: 1.0, // Keeping 1.0 but using SizedBox to prevent overlap
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: color.withValues(alpha: 0.85),
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENT AVATAR — Deterministic 2-color gradient from name hash
// ═══════════════════════════════════════════════════════════════════════════

/// Generates a consistent but varied 2-color gradient avatar for a patient.
/// The gradient colors are deterministically derived from the name string,
/// so the same patient always gets the same colors.
class GradientAvatar extends StatelessWidget {
  final String name;
  final double size;

  const GradientAvatar({
    super.key,
    required this.name,
    this.size = 44,
  });

  static const List<List<Color>> _palettes = [
    [Color(0xFF0D7377), Color(0xFF14919B)],  // teal
    [Color(0xFFFF784E), Color(0xFFFF9B7A)],  // coral
    [Color(0xFF6C63FF), Color(0xFF9B94FF)],  // violet
    [Color(0xFF00B4D8), Color(0xFF48CAE4)],  // sky
    [Color(0xFFFF9500), Color(0xFFFFAC33)],  // amber
    [Color(0xFF34C759), Color(0xFF5EDE7E)],  // green
    [Color(0xFFFF3B30), Color(0xFFFF6961)],  // red
    [Color(0xFF5856D6), Color(0xFF7A79E8)],  // indigo
    [Color(0xFFAF52DE), Color(0xFFCD7EEF)],  // purple
    [Color(0xFF32ADE6), Color(0xFF5BBEF0)],  // blue
  ];

  int _hashName(String name) {
    return name.codeUnits.fold(0, (prev, c) => (prev * 31 + c) & 0x7FFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final hash = _hashName(name);
    final palette = _palettes[hash % _palettes.length];
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().length == 1
            ? name.trim()[0].toUpperCase()
            : '${name.trim()[0]}${name.trim().split(' ').last[0]}'.toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: palette[0].withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: AppTypography.bold,
            fontSize: size * 0.32,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM ACTION CARD — Diagonal gradient, colored shadow, scale press
// ═══════════════════════════════════════════════════════════════════════════

class PremiumActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PremiumActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<PremiumActionCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
          decoration: BoxDecoration(
            // Barely-perceptible diagonal gradient — embossed feel
            gradient: LinearGradient(
              colors: _pressed
                  ? [const Color(0xFFF5F5F5), const Color(0xFFEEEEEE)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF7F7F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.25)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              // Generic lift shadow
              BoxShadow(
                color: AppColors.shadowDark.withValues(alpha: _pressed ? 0.08 : 0.12),
                blurRadius: _pressed ? 8 : 20,
                offset: Offset(0, _pressed ? 4 : 8),
              ),
              // Colored glow shadow matching the icon color
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? 0.35 : 0.15),
                blurRadius: _pressed ? 24 : 16,
                offset: const Offset(0, 6),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container — 56px, colored glow shadow
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _pressed ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _pressed ? 0.42 : 0.28),
                      blurRadius: _pressed ? 20 : 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: AppSpacing.iconMd + 4,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: AppTypography.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTypography.light,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AMBIENT ORBS BACKGROUND — Soft blurred color globs at 6% opacity
// Extracted as standalone wrapping widget for reuse on any screen section
// ═══════════════════════════════════════════════════════════════════════════

class AmbientOrbs extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  /// If true, orbs drift very slowly (12s cycle). False = static.
  final bool animated;

  const AmbientOrbs({
    super.key,
    required this.child,
    required this.primaryColor,
    required this.secondaryColor,
    this.animated = true,
  });

  @override
  State<AmbientOrbs> createState() => _AmbientOrbsState();
}

class _AmbientOrbsState extends State<AmbientOrbs>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = widget.animated ? _ctrl.value : 0.5;
              return Stack(
                children: [
                  Positioned(
                    top: -60 + (t * 40),
                    right: -40 - (t * 30),
                    child: _orb(widget.primaryColor, 280),
                  ),
                  Positioned(
                    bottom: -70 - ((1 - t) * 30),
                    left: -50 + ((1 - t) * 40),
                    child: _orb(widget.secondaryColor, 320),
                  ),
                  // Third subtle accent orb — center-ish
                  Positioned(
                    top: 80 + (t * 20),
                    left: 80 - (t * 15),
                    child: _orb(widget.primaryColor, 180),
                  ),
                ],
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _orb(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Bumped to 9% for more visible ambient glow
          color: color.withValues(alpha: 0.09),
        ),
      ),
    );
  }
}
