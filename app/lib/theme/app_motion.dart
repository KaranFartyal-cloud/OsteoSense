import 'package:flutter/material.dart';

/// Centralized motion system for consistent, premium animations across the app.
/// All durations and curves defined here ensure every animation "feels" like
/// it belongs to the same product — the Linear/Stripe/Arc signature smooth deceleration.
class AppMotion {
  // Private constructor to prevent instantiation
  AppMotion._();

  // ========================================================================
  // DURATIONS
  // ========================================================================
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration standard = Duration(milliseconds: 400);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration moderate = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration slower = Duration(milliseconds: 800);
  static const Duration countUp = Duration(milliseconds: 1200);
  static const Duration countUpLong = Duration(milliseconds: 1500);
  static const Duration ambient = Duration(milliseconds: 1500);
  static const Duration ambientLong = Duration(milliseconds: 3000);
  static const Duration ambientSlow = Duration(milliseconds: 4000);
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // ========================================================================
  // CURVES
  // ========================================================================
  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveEmphasis = Curves.easeOutQuart;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curvePress = Curves.easeOutQuad;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveLinear = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve curvePop = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve curveCrossFade = Curves.easeInOutCubic;
  static const Curve curveFast = Curves.easeInOut;

  // ========================================================================
  // TRANSFORM PRESETS
  // ========================================================================
  static const double pressScale = 0.92;
  static const double selectedIconScale = 1.1;
  static const double entranceScaleBegin = 0.95;
  static const double entranceScaleEnd = 1.0;
  static const double pageScaleBegin = 0.98;
  static const double pageScaleEnd = 1.0;
  static const double listSlideOffset = 40.0;
  static const double pageSlideOffset = 1.0;

  // ========================================================================
  // OPACITY PRESETS
  // ========================================================================
  static const double opacityPressed = 0.8;
  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.9;

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Creates a curved animation with the standard curve
  static CurvedAnimation standardCurve(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: curve);
  }

  /// Creates a curved animation with the emphasis curve
  static CurvedAnimation emphasisCurve(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: curveEmphasis);
  }

  /// Creates a curved animation with the press curve
  static CurvedAnimation pressCurve(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: curvePress);
  }

  /// Creates a curved animation with the Linear signature curve
  static CurvedAnimation linearCurve(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: curveLinear);
  }

  /// Creates a tween for the standard press scale
  static Tween<double> pressScaleTween() {
    return Tween<double>(begin: 1.0, end: pressScale);
  }

  /// Creates a tween for entrance scale
  static Tween<double> entranceScaleTween() {
    return Tween<double>(begin: entranceScaleBegin, end: entranceScaleEnd);
  }

  /// Creates a tween for page transition scale
  static Tween<double> pageScaleTween() {
    return Tween<double>(begin: pageScaleBegin, end: pageScaleEnd);
  }

  /// Creates a tween for selected icon scale
  static Tween<double> selectedIconScaleTween() {
    return Tween<double>(begin: 1.0, end: selectedIconScale);
  }

  /// Creates a slide tween for list item entrance
  static Tween<Offset> listSlideTween() {
    return Tween<Offset>(begin: const Offset(0, listSlideOffset / 100), end: Offset.zero);
  }

  /// Creates a slide tween for shared-axis page transition
  static Tween<Offset> pageSlideTween() {
    return Tween<Offset>(begin: const Offset(pageSlideOffset, 0), end: Offset.zero);
  }
}

/// Extension for easier duration usage
extension AppMotionDuration on int {
  Duration get ms => Duration(milliseconds: this);
}