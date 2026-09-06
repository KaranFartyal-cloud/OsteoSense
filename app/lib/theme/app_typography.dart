import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single font family system: Inter throughout.
/// Headings use tightened letter-spacing (-0.02em) for precision.
/// No heading/body font pairing — Inter for everything.
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // ========================================================================
  // FONT FAMILY
  // ========================================================================
  static const String fontFamily = 'Inter';

  // ========================================================================
  // FONT WEIGHTS
  // ========================================================================
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ========================================================================
  // TEXT STYLES - All use Inter with appropriate sizing and letter-spacing
  // ========================================================================

  /// Display styles - Headings with tightened letter-spacing (-0.02em)
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: bold,
        letterSpacing: -0.02 * 57, // -0.02em
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: bold,
        letterSpacing: -0.02 * 45, // -0.02em
        height: 1.15,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: bold,
        letterSpacing: -0.02 * 36, // -0.02em
        height: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: bold,
        letterSpacing: -0.02 * 34, // -0.02em
        height: 1.15,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 30,
        fontWeight: bold,
        letterSpacing: -0.02 * 30, // -0.02em
        height: 1.2,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: bold,
        letterSpacing: -0.02 * 26, // -0.02em
        height: 1.25,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 22, // -0.02em
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: medium,
        letterSpacing: -0.02 * 18, // -0.02em
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: medium,
        letterSpacing: -0.02 * 16, // -0.02em
        height: 1.45,
      );

  // ========================================================================
  // BODY STYLES - Standard Inter
  // ========================================================================
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: light,
        letterSpacing: 0.2,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: light,
        letterSpacing: 0.2,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.5,
      );

  // ========================================================================
  // LABEL STYLES
  // ========================================================================
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ========================================================================
  // COMPONENT STYLES
  // ========================================================================
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: semiBold,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.4,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 1.5,
        height: 1.3,
      );

  // ========================================================================
  // HELPER METHODS
  // ========================================================================
  static TextStyle primaryText(Color color) => bodyMedium.copyWith(color: color);
  static TextStyle secondaryText(Color color) => bodySmall.copyWith(color: color);
  static TextStyle hintText(Color color) => bodySmall.copyWith(
        color: color,
        fontWeight: light,
      );
}