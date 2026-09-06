import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completeColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completeColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? AppColors.surfaceVariant;
    final complete = completeColor ?? AppColors.success;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            totalSteps,
            (index) {
              final isActive = index == currentStep - 1;
              final isComplete = index < currentStep - 1;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: AppSpacing.radiusSm,
                            decoration: BoxDecoration(
                              color: isComplete || isActive ? active : inactive,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          width: AppSpacing.md,
                          height: AppSpacing.md,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? complete
                                : isActive
                                    ? active
                                    : inactive,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: isComplete
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        if (index < totalSteps - 1)
                          Expanded(
                            child: Container(
                              height: AppSpacing.radiusSm,
                              decoration: BoxDecoration(
                                color:
                                    isActive || isComplete ? active : inactive,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (stepLabels != null && index < stepLabels!.length) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        stepLabels![index],
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive || isComplete
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: isActive ? AppTypography.semiBold : null,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LinearProgressBar extends StatefulWidget {
  final double value; // 0-1
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool animate;
  final Duration? duration;

  const LinearProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.color,
    this.backgroundColor,
    this.animate = true,
    this.duration,
  });

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value)
          .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: LinearProgressIndicator(
            value: _animation.value,
            minHeight: widget.height,
            backgroundColor: widget.backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}