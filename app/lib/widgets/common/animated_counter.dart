import 'package:flutter/material.dart';
import '../../theme/app_motion.dart';

/// A widget that counts up from 0 to a target number with a smooth
/// easeOutCubic curve. Use this for stat cards, risk scores, confidence %,
/// and any numeric display that should animate its appearance.
///
/// Example:
/// ```dart
/// AnimatedCounter(value: 42, style: Theme.of(context).textTheme.headlineMedium)
/// ```
class AnimatedCounter extends StatefulWidget {
  /// The target number to count up to
  final int value;

  /// The text style to apply to the number
  final TextStyle? style;

  /// Duration of the count-up animation
  final Duration duration;

  /// Whether to format the number with commas
  final bool formatWithCommas;

  /// Optional prefix (e.g., '+', '$')
  final String? prefix;

  /// Optional suffix (e.g., '%', ' pts')
  final String? suffix;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = AppMotion.countUp,
    this.formatWithCommas = false,
    this.prefix,
    this.suffix,
    this.onComplete,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _animation.addListener(() {
      setState(() {
        _currentValue = _animation.value.round();
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });

    print('AnimatedCounter initState: starting forward from 0 to: ${widget.value}');
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.duration != widget.duration) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _animation = Tween<double>(begin: _currentValue.toDouble(), end: widget.value.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _animation.addListener(() {
        setState(() {
          _currentValue = _animation.value.round();
        });
      });
      print('AnimatedCounter didUpdateWidget: starting forward from old: ${oldWidget.value} to new: ${widget.value}');
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.prefix ?? '';
    final formattedValue = widget.formatWithCommas
        ? _currentValue.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[0]},',
          )
        : _currentValue.toString();
    final suffix = widget.suffix ?? '';

    return Text(
      '$text$formattedValue$suffix',
      style: widget.style,
    );
  }
}

/// A simpler AnimatedCounter for double values (e.g., decimal risk scores)
class AnimatedCounterDouble extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedCounterDouble({
    super.key,
    required this.value,
    this.style,
    this.duration = AppMotion.countUp,
    this.decimals = 0,
  });

  @override
  State<AnimatedCounterDouble> createState() => _AnimatedCounterDoubleState();
}

class _AnimatedCounterDoubleState extends State<AnimatedCounterDouble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _animation.addListener(() {
      setState(() {
        _currentValue = _animation.value;
      });
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounterDouble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentValue.toStringAsFixed(widget.decimals),
      style: widget.style,
    );
  }
}