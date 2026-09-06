import 'dart:ui';
import 'package:flutter/material.dart';

/// Subtle, slow-moving blurred color glows behind screen content.
/// Very low opacity � meant to be felt, not consciously noticed.
class AmbientBackground extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color? secondaryColor;

  const AmbientBackground({
    super.key,
    required this.child,
    required this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (t * 40),
                    right: -80 - (t * 30),
                    child: _blob(widget.primaryColor, 280),
                  ),
                  if (widget.secondaryColor != null)
                    Positioned(
                      bottom: -120 - ((1 - t) * 30),
                      left: -100 + ((1 - t) * 40),
                      child: _blob(widget.secondaryColor!, 320),
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

  Widget _blob(Color color, double size) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.06),
          ),
        ),
      ),
    );
  }
}
