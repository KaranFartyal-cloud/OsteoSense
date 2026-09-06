import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';

class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
  });

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late AnimationController _pillController;
  int? _prevIndex;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // Pill slide animation
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _prevIndex = widget.currentIndex;

    if (widget.currentIndex >= 0 && widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reverse previous
      if (oldWidget.currentIndex >= 0 && oldWidget.currentIndex < _controllers.length) {
        _controllers[oldWidget.currentIndex].reverse();
      }
      // Forward new
      if (widget.currentIndex >= 0 && widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
    // Update pill animation when index changes
    if (widget.currentIndex != _prevIndex) {
      _prevIndex = widget.currentIndex;
      // Animate pill to new position
      _pillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 16,
          top: 8,
        ),
        child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            // Layered shadow: tight dark + large soft glow
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              offset: const Offset(0, 12),
              blurRadius: 32,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated pill background for selected item
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _getPillPosition(),
              width: (_getNavWidth() / widget.items.length) - 8,
              top: 6,
              bottom: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            // Nav items row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => Expanded(
                  child: _BottomNavItemWidget(
                    item: widget.items[index],
                    isSelected: widget.currentIndex == index,
                    controller: _controllers[index],
                    onTap: () => widget.onTap(index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  double _getPillPosition() {
    if (widget.items.isEmpty) return 4;
    final widthPerItem = _getNavWidth() / widget.items.length;
    return 4 + (widget.currentIndex * widthPerItem) + (widthPerItem - (widthPerItem - 8)) / 2 - 4;
  }

  double _getNavWidth() {
    return MediaQuery.of(context).size.width - 40;
  }
}

class _BottomNavItemWidget extends StatefulWidget {
  final BottomNavItem item;
  final bool isSelected;
  final AnimationController controller;
  final VoidCallback onTap;

  const _BottomNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.controller,
    required this.onTap,
  });

  @override
  State<_BottomNavItemWidget> createState() => _BottomNavItemWidgetState();
}

class _BottomNavItemWidgetState extends State<_BottomNavItemWidget> {
  @override
  void initState() {
    super.initState();
    // Listen to controller to trigger rebuilds
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(widget.controller);

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Icon(
                    widget.item.icon,
                    color: widget.isSelected ? Colors.white : AppColors.textTertiary,
                    size: AppSpacing.iconMd,
                  ),
                );
              },
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: AppMotion.standard,
            curve: Curves.easeOutCubic,
            style: AppTypography.labelSmall.copyWith(
              color: widget.isSelected ? Colors.white : AppColors.textTertiary,
              fontWeight: widget.isSelected ? AppTypography.semiBold : AppTypography.medium,
            ),
            child: Text(
              widget.item.label,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.label,
  });
}