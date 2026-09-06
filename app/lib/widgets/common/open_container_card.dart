import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

/// A reusable wrapper that gives any card a Material "container transform"
/// (fade-through) transition into the destination screen.
///
/// Used as the canonical Patient List → Patient Profile navigation.
class OpenContainerCard extends StatelessWidget {
  final Widget closedChild;
  final Widget Function(BuildContext context) openBuilder;
  final Duration transitionDuration;
  final BorderRadius? borderRadius;

  const OpenContainerCard({
    super.key,
    required this.closedChild,
    required this.openBuilder,
    this.transitionDuration = AppMotion.normal,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer<void>(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: transitionDuration,
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.background,
      closedShape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd),
      ),
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd),
          child: closedChild,
        );
      },
      openBuilder: (context, closeContainer) => openBuilder(context),
    );
  }
}
