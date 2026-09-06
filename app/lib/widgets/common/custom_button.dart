import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final bool isLoading;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool disabled;
  final bool showScaleFeedback;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.disabled = false,
    this.showScaleFeedback = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.showScaleFeedback ? AppMotion.pressScale : 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: AppMotion.curvePress),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.disabled && !widget.isLoading) {
      _scaleController.forward();
      setState(() => _isPressed = true);
      if (widget.variant == ButtonVariant.primary) {
        _shimmerController.forward(from: 0);
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.disabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(context, isEnabled),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled) {
    final colors = _getButtonColors();
    final height = _getButtonHeight();
    final padding = _getButtonPadding();

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.isLoading) ...[
          widget.icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        if (widget.isLoading)
          SizedBox(
            height: _getLoadingSize(),
            width: _getLoadingSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
            ),
          )
        else
          Text(
            widget.text,
            style: AppTypography.button.copyWith(
              color: colors.textColor,
            ),
          ),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailingIcon!,
        ],
      ],
    );

    // Build decoration based on variant
    final decoration = _buildDecoration(colors, isEnabled, height, padding);

    if (widget.variant == ButtonVariant.ghost) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? widget.onPressed : null,
          onTapDown: isEnabled ? _handleTapDown : null,
          onTapUp: isEnabled ? _handleTapUp : null,
          onTapCancel: isEnabled ? _handleTapCancel : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: height,
            padding: padding,
            child: Center(child: buttonContent),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: isEnabled ? widget.onPressed : null,
        onTapDown: isEnabled ? _handleTapDown : null,
        onTapUp: isEnabled ? _handleTapUp : null,
        onTapCancel: isEnabled ? _handleTapCancel : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        splashColor: colors.splashColor,
        highlightColor: colors.highlightColor,
        child: Ink(
          height: height,
          padding: padding,
          decoration: decoration,
          child: Center(child: buttonContent),
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.fast);
  }

  BoxDecoration _buildDecoration(_ButtonColors colors, bool isEnabled, double height, EdgeInsets padding) {
    if (!isEnabled) {
      return BoxDecoration(
        color: colors.disabledBackgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: widget.variant == ButtonVariant.outline
            ? Border.all(color: colors.disabledBorderColor, width: 1.5)
            : null,
      );
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2,
            ),
            if (_isPressed)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
          ],
        );
      case ButtonVariant.secondary:
        return BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        );
      case ButtonVariant.outline:
        return BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: colors.borderColor, width: 1.5),
        );
      case ButtonVariant.ghost:
        return const BoxDecoration();
      case ButtonVariant.danger:
        return BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        );
    }
  }

  _ButtonColors _getButtonColors() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textHint,
          textColor: Colors.white,
          disabledTextColor: Colors.white,
          splashColor: AppColors.primaryLight.withValues(alpha: 0.3),
          highlightColor: AppColors.primaryDark.withValues(alpha: 0.2),
          borderColor: AppColors.primary,
          disabledBorderColor: AppColors.textHint,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.textHint,
          textColor: Colors.white,
          disabledTextColor: Colors.white,
          splashColor: AppColors.accentLight.withValues(alpha: 0.3),
          highlightColor: AppColors.accentDark.withValues(alpha: 0.2),
          borderColor: AppColors.accent,
          disabledBorderColor: AppColors.textHint,
        );
      case ButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          disabledTextColor: AppColors.textHint,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          borderColor: AppColors.primary,
          disabledBorderColor: AppColors.textHint,
        );
      case ButtonVariant.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          disabledTextColor: AppColors.textHint,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          borderColor: Colors.transparent,
          disabledBorderColor: Colors.transparent,
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: AppColors.error,
          disabledBackgroundColor: AppColors.textHint,
          textColor: Colors.white,
          disabledTextColor: Colors.white,
          splashColor: AppColors.riskHighLight.withValues(alpha: 0.3),
          highlightColor: AppColors.riskHighDark.withValues(alpha: 0.2),
          borderColor: AppColors.error,
          disabledBorderColor: AppColors.textHint,
        );
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case ButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color splashColor;
  final Color highlightColor;
  final Color borderColor;
  final Color disabledBorderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.textColor,
    required this.disabledTextColor,
    required this.splashColor,
    required this.highlightColor,
    required this.borderColor,
    required this.disabledBorderColor,
  });
}