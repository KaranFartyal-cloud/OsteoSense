import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum CardVariant {
  default_,
  elevated,
  outlined,
  riskLow,
  riskMedium,
  riskHigh,
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isClickable;
  final Widget? trailing;
  final Widget? leading;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CardVariant.default_,
    this.padding,
    this.margin,
    this.onTap,
    this.isClickable = false,
    this.trailing,
    this.leading,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCardColors();
    final cardPadding = padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMd);
    final cardMargin = margin ?? EdgeInsets.zero;

    Widget cardChild = Padding(
      padding: cardPadding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(child: child),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (leading == null && trailing == null) {
      cardChild = Padding(padding: cardPadding, child: child);
    }

    final card = Container(
      width: width,
      height: height,
      margin: cardMargin,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: variant == CardVariant.outlined
            ? Border.all(color: colors.borderColor, width: 1)
            : null,
        gradient: colors.gradient,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: cardChild,
    );

    if (isClickable || onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: card,
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 300.ms,
        curve: Curves.easeOut,
      );
    }

    return card.animate().fadeIn(duration: 300.ms);
  }

  _CardColors _getCardColors() {
    switch (variant) {
      case CardVariant.elevated:
        return _CardColors(
          backgroundColor: AppColors.surface,
          shadowColor: AppColors.shadow,
          borderColor: Colors.transparent,
          gradient: null,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
        );
      case CardVariant.outlined:
        return _CardColors(
          backgroundColor: AppColors.surface,
          shadowColor: Colors.transparent,
          borderColor: AppColors.border,
          gradient: null,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
        );
      case CardVariant.riskLow:
        return _CardColors(
          backgroundColor: AppColors.riskLowSurface,
          shadowColor: AppColors.riskLow.withOpacity(0.2),
          borderColor: Colors.transparent,
          gradient: AppColors.riskLowGradient,
          splashColor: AppColors.riskLow.withOpacity(0.2),
          highlightColor: AppColors.riskLow.withOpacity(0.1),
        );
      case CardVariant.riskMedium:
        return _CardColors(
          backgroundColor: AppColors.riskMediumSurface,
          shadowColor: AppColors.riskMedium.withOpacity(0.2),
          borderColor: Colors.transparent,
          gradient: AppColors.riskMediumGradient,
          splashColor: AppColors.riskMedium.withOpacity(0.2),
          highlightColor: AppColors.riskMedium.withOpacity(0.1),
        );
      case CardVariant.riskHigh:
        return _CardColors(
          backgroundColor: AppColors.riskHighSurface,
          shadowColor: AppColors.riskHigh.withOpacity(0.2),
          borderColor: Colors.transparent,
          gradient: AppColors.riskHighGradient,
          splashColor: AppColors.riskHigh.withOpacity(0.2),
          highlightColor: AppColors.riskHigh.withOpacity(0.1),
        );
      case CardVariant.default_:
      default:
        return _CardColors(
          backgroundColor: AppColors.surface,
          shadowColor: AppColors.shadowLight,
          borderColor: Colors.transparent,
          gradient: null,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
        );
    }
  }
}

class _CardColors {
  final Color backgroundColor;
  final Color shadowColor;
  final Color borderColor;
  final LinearGradient? gradient;
  final Color splashColor;
  final Color highlightColor;

  _CardColors({
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderColor,
    required this.gradient,
    required this.splashColor,
    required this.highlightColor,
  });
}
