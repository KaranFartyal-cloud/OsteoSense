import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_motion.dart';

enum CardVariant {
  default_,
  elevated,
  outlined,
  riskLow,
  riskMedium,
  riskHigh,
  glassmorphic,
}

class CustomCard extends StatefulWidget {
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
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: AppMotion.pressScale).animate(
      CurvedAnimation(parent: _pressController, curve: AppMotion.curvePress),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isClickable || widget.onTap != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getCardColors();
    final cardPadding = widget.padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMd);

    Widget cardChild = Padding(
      padding: cardPadding,
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(child: widget.child),
          if (widget.trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.leading == null && widget.trailing == null) {
      cardChild = Padding(padding: cardPadding, child: widget.child);
    }

    // Build the card decoration based on variant
    Widget card;

    if (widget.variant == CardVariant.glassmorphic) {
      card = _buildGlassmorphicCard(colors, cardChild);
    } else {
      card = _buildStandardCard(colors, cardChild);
    }

    card = AnimatedBuilder(
      animation: _pressAnimation,
      child: card,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: child,
        );
      },
    );

    if (widget.isClickable || widget.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: card,
        ),
      ).animate().fadeIn(duration: AppMotion.fast).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: AppMotion.fast,
        curve: Curves.easeOut,
      );
    }

    return card.animate().fadeIn(duration: AppMotion.fast);
  }

  Widget _buildStandardCard(_CardColors colors, Widget child) {
    // Risk variants use a left accent border strip instead of full fills
    final isRiskVariant = widget.variant == CardVariant.riskLow ||
        widget.variant == CardVariant.riskMedium ||
        widget.variant == CardVariant.riskHigh;

    if (isRiskVariant) {
      return Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: colors.borderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4px left accent strip — risk level as signal
              Container(
                width: 4,
                color: colors.accentColor,
              ),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: widget.variant == CardVariant.outlined
            ? Border.all(color: colors.borderColor, width: 1)
            : widget.variant == CardVariant.default_
                ? Border.all(color: colors.borderColor, width: 1)
                : null,
        boxShadow: colors.boxShadows,
      ),
      child: child,
    );
  }

  Widget _buildGlassmorphicCard(_CardColors colors, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  _CardColors _getCardColors() {
    switch (widget.variant) {
      case CardVariant.elevated:
        // Purposefully floating element — shadow is appropriate here
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
          borderColor: AppColors.border,
          accentColor: AppColors.primary,
          gradient: null,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
        );
      case CardVariant.outlined:
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [],
          borderColor: AppColors.border,
          accentColor: AppColors.primary,
          gradient: null,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
        );
      // Risk variants: white card + left border accent strip (signal not fill)
      case CardVariant.riskLow:
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [],
          borderColor: AppColors.border,
          accentColor: AppColors.riskLow,
          gradient: null,
          splashColor: AppColors.riskLow.withValues(alpha: 0.1),
          highlightColor: AppColors.riskLow.withValues(alpha: 0.05),
        );
      case CardVariant.riskMedium:
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [],
          borderColor: AppColors.border,
          accentColor: AppColors.riskMedium,
          gradient: null,
          splashColor: AppColors.riskMedium.withValues(alpha: 0.1),
          highlightColor: AppColors.riskMedium.withValues(alpha: 0.05),
        );
      case CardVariant.riskHigh:
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [],
          borderColor: AppColors.border,
          accentColor: AppColors.riskHigh,
          gradient: null,
          splashColor: AppColors.riskHigh.withValues(alpha: 0.1),
          highlightColor: AppColors.riskHigh.withValues(alpha: 0.05),
        );
      case CardVariant.glassmorphic:
        // Now a clean card (blur removed) — same as outlined
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderColor: AppColors.border,
          accentColor: AppColors.primary,
          gradient: null,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
        );
      case CardVariant.default_:
      default:
        // Primary depth technique: 1px border, no shadow
        return _CardColors(
          backgroundColor: AppColors.surface,
          boxShadows: [],
          borderColor: AppColors.border,
          accentColor: AppColors.primary,
          gradient: null,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
        );
    }
  }
}

class _CardColors {
  final Color backgroundColor;
  final List<BoxShadow> boxShadows;
  final Color borderColor;
  final Color accentColor; // Used for left-border strip on risk variants
  final LinearGradient? gradient;
  final Color splashColor;
  final Color highlightColor;

  _CardColors({
    required this.backgroundColor,
    required this.boxShadows,
    required this.borderColor,
    required this.accentColor,
    required this.gradient,
    required this.splashColor,
    required this.highlightColor,
  });
}