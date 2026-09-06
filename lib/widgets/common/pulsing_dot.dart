import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PulsingDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulsingDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .custom(
          duration: 1200.ms,
          builder: (context, value, child) => Opacity(
            opacity: 0.4 + (0.6 * value),
            child: Transform.scale(
              scale: 0.85 + (0.15 * value),
              child: child,
            ),
          ),
        );
  }
}
