import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';

/// Clean scaffold background — no decorative blobs or mesh gradients.
/// Per the premium redesign: backgrounds stay neutral (#FAFAFA), color
/// appears only as a signal (buttons, risk indicators, active states).
class GradientMeshBackground extends StatelessWidget {
  final Widget child;
  final bool animate; // kept for API compatibility, no-op
  final Color? baseColor;

  const GradientMeshBackground({
    super.key,
    required this.child,
    this.animate = true,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: baseColor ?? AppColors.background,
      child: child,
    );
  }
}

/// Premium clean card — white surface with thin 1px border as the primary
/// depth technique. BackdropFilter blur removed: it created visual noise
/// competing with content. Shadows reserved for genuinely floating elements.
///
/// Optional [tintColor] adds a very subtle left accent strip (4px) to
/// indicate interactive intent — keeps color as a signal not decoration.
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blur;       // kept for API compat, unused
  final double borderRadius;
  final Color? tintColor;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.blur = 10,
    this.borderRadius = 12,
    this.tintColor,
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: AppMotion.pressScale)
        .animate(CurvedAnimation(parent: _pressController, curve: AppMotion.curvePress));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) => _pressController.reverse();
  void _handleTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = widget.borderRadius;
    final hasTint = widget.tintColor != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: widget.margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: widget.onTap != null ? _handleTapDown : null,
            onTapUp: widget.onTap != null ? _handleTapUp : null,
            onTapCancel: widget.onTap != null ? _handleTapCancel : null,
            borderRadius: BorderRadius.circular(effectiveRadius),
            splashColor: (widget.tintColor ?? AppColors.primary).withValues(alpha: 0.08),
            highlightColor: (widget.tintColor ?? AppColors.primary).withValues(alpha: 0.04),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(effectiveRadius),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                // Subtle shadow — only for tappable (interactive) cards
                boxShadow: widget.onTap != null
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: hasTint
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 4px left accent strip as color signal
                        Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: widget.tintColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: widget.child),
                      ],
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper scaffold that wraps body with the clean background.
/// The "mesh" is removed — this is now a clean pass-through.
class GradientMeshScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? baseColor;

  const GradientMeshScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor ?? AppColors.background,
      body: body,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
