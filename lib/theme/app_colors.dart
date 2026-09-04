import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Deep Teal/Emerald
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14919B);
  static const Color primaryDark = Color(0xFF094A4D);
  static const Color primarySurface = Color(0xFFE0F7FA);

  // Accent Colors - Warm Coral/Amber
  static const Color accent = Color(0xFFFF784E);
  static const Color accentLight = Color(0xFFFFA07A);
  static const Color accentDark = Color(0xFFCC5C3E);

  // Background Colors - Soft Off-white/Cream
  static const Color background = Color(0xFFFAF9F6);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color surfaceVariant = Color(0xFFF5F3EF);
  static const Color surfaceVariantDark = Color(0xFF3A3A3A);

  // Text Colors - Dark Charcoal
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color textSecondaryDark = Color(0xFFA1A1A6);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color textHint = Color(0xFFC7C7CC);
  static const Color textHintDark = Color(0xFF48484A);

  // Risk Level Colors
  static const Color riskLow = Color(0xFF34C759);
  static const Color riskLowLight = Color(0xFF4CDF7D);
  static const Color riskLowDark = Color(0xFF28A745);
  static const Color riskLowSurface = Color(0xFFE8F5E9);

  static const Color riskMedium = Color(0xFFFF9500);
  static const Color riskMediumLight = Color(0xFFFFAC33);
  static const Color riskMediumDark = Color(0xFFCC7700);
  static const Color riskMediumSurface = Color(0xFFFFF3E0);

  static const Color riskHigh = Color(0xFFFF3B30);
  static const Color riskHighLight = Color(0xFFFF6961);
  static const Color riskHighDark = Color(0xFFCC2F26);
  static const Color riskHighSurface = Color(0xFFFFEBEE);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // Border & Divider
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFF38383A);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient riskLowGradient = LinearGradient(
    colors: [riskLowLight, riskLow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient riskMediumGradient = LinearGradient(
    colors: [riskMediumLight, riskMedium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient riskHighGradient = LinearGradient(
    colors: [riskHighLight, riskHigh],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Gradients based on risk level
  static LinearGradient getRiskGradient(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return riskHighGradient;
      case 'medium':
        return riskMediumGradient;
      case 'low':
      default:
        return riskLowGradient;
    }
  }

  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return riskHigh;
      case 'medium':
        return riskMedium;
      case 'low':
      default:
        return riskLow;
    }
  }

  static Color getRiskSurfaceColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return riskHighSurface;
      case 'medium':
        return riskMediumSurface;
      case 'low':
      default:
        return riskLowSurface;
    }
  }
}
