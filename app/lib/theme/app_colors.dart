import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========================================================================
  // PRIMARY COLORS — Deep Teal/Emerald (used as SIGNALS, not decoration)
  // ========================================================================
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14919B);
  static const Color primaryDark = Color(0xFF094A4D);
  static const Color primarySurface = Color(0xFFE0F7FA);

  // ========================================================================
  // ACCENT COLORS — Warm Coral (used as SIGNALS, not decoration)
  // ========================================================================
  static const Color accent = Color(0xFFFF784E);
  static const Color accentLight = Color(0xFFFFA07A);
  static const Color accentDark = Color(0xFFCC5C3E);

  // ========================================================================
  // BACKGROUND COLORS — Near-white, cool neutral
  // Primary depth technique: thin 1px border (#ECECEC), NOT heavy shadows
  // Shadows reserved for genuinely floating elements (FAB, modals, sheets)
  // ========================================================================
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF2D2D2D);

  // ========================================================================
  // TEXT COLORS — Near-black primary, gray scale secondary/tertiary
  // ========================================================================
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color textSecondaryDark = Color(0xFFA1A1A6);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color textHint = Color(0xFFC7C7CC);
  static const Color textHintDark = Color(0xFF48484A);

  // ========================================================================
  // GRAY SCALE — Full gray-50 through gray-900 for premium feel
  // ========================================================================
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  // ========================================================================
  // RISK LEVEL COLORS — Vivid and clear, used as SIGNAL not decoration
  // Small colored accent (left border, dot, or badge) rather than full fills
  // ========================================================================
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

  // ========================================================================
  // STATUS COLORS
  // ========================================================================
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // ========================================================================
  // BORDER & DIVIDER — Primary depth technique
  // ========================================================================
  static const Color border = Color(0xFFECECEC);
  static const Color borderDark = Color(0xFF38383A);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);

  // ========================================================================
  // SHADOW COLORS — Reserved for floating elements only
  // ========================================================================
  static const Color shadow = Color(0x0D000000);
  static const Color shadowLight = Color(0x08000000);
  static const Color shadowDark = Color(0x33000000);

  // ========================================================================
  // GRADIENTS — Subtle, restrained use
  // ========================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fullPrimaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================================================
  // GLASSMORPHISM — For modals, sheets, elevated cards
  // ========================================================================
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassWhiteDark = Color(0x1A2D2D2D);
  static const Color glassBorderDark = Color(0x33333333);

  // ========================================================================
  // MESH GRADIENT COLORS — Minimal, used sparingly for premium backgrounds
  // ========================================================================
  static const Color meshPrimary = Color(0x150D7377);
  static const Color meshAccent = Color(0x10FF784E);
  static const Color meshPrimaryLight = Color(0x1214919B);
  static const Color meshSurface = Color(0xE6FFFFFF);
  static const Color meshSurfaceDark = Color(0xE62D2D2D);

  // ========================================================================
  // RISK GRADIENTS — Subtle, surface-level
  // ========================================================================
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

  // ========================================================================
  // MOOD GRADIENTS — Expressive, premium gradients for specific contexts
  // ========================================================================
  static const LinearGradient onboardingGradient1 = LinearGradient(
    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient onboardingGradient2 = LinearGradient(
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient onboardingGradient3 = LinearGradient(
    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient trustGradient = LinearGradient(
    colors: [Color(0xFF094A4D), Color(0xFF0D7377)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF28A745), Color(0xFF34C759)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFCC7700), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFCC2F26), Color(0xFFFF3B30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient analyticsGradient = LinearGradient(
    colors: [Color(0xFF14919B), Color(0xFF0D7377)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient careGradient = LinearGradient(
    colors: [Color(0xFF0D7377), Color(0xFF14919B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get risk gradient based on level (low/medium/high)
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

  /// Get risk color based on level (low/medium/high)
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

  /// Get risk surface color based on level (low/medium/high)
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

  /// Get risk border color based on level (used for left accent border)
  static Color getRiskBorderColor(String riskLevel) {
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

  /// Interpolate between risk colors for smooth gauge animation
  /// Uses HSL interpolation for natural color transitions
  static Color lerpRiskColor(double t) {
    // t: 0.0 = low (green), 0.5 = medium (amber), 1.0 = high (red)
    if (t < 0.33) {
      // Green to amber
      final localT = t / 0.33;
      return Color.lerp(riskLow, riskMedium, localT)!;
    } else if (t < 0.66) {
      // Amber to red
      final localT = (t - 0.33) / 0.33;
      return Color.lerp(riskMedium, riskHigh, localT)!;
    } else {
      return riskHigh;
    }
  }
}