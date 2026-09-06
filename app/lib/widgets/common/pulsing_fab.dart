import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PulsingFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Object? heroTag;

  const PulsingFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  @override
  State<PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    print('PulsingFAB: Animation started (looping)');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: AppSpacing.iconXl + AppSpacing.lg,
                height: AppSpacing.iconXl + AppSpacing.lg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.backgroundColor ?? AppColors.primary)
                      .withValues(alpha: (1.2 - _pulseAnimation.value).clamp(0.0, 0.2)),
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          heroTag: widget.heroTag ?? UniqueKey(),
          onPressed: widget.onPressed,
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          foregroundColor: widget.foregroundColor ?? Colors.white,
          tooltip: widget.tooltip,
          elevation: AppSpacing.elevationMd,
          child: Icon(widget.icon),
        ),
      ],
    );
  }
}