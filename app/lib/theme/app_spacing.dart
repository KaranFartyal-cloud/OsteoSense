/// Spacing system following the premium redesign:
/// - Generous padding (24px+ screen margins)
/// - Tighter spacing within components (8-12px)
/// - More breathing room between sections (32-40px)
/// - Smaller border radii (8-12px) for precise, technical feel
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base spacing unit (8pt grid system)
  static const double unit = 8.0;

  // ========================================================================
  // SPACING SCALE
  // ========================================================================
  static const double xs = unit; // 8
  static const double sm = unit * 2; // 16
  static const double md = unit * 3; // 24
  static const double lg = unit * 4; // 32
  static const double xl = unit * 5; // 40
  static const double xxl = unit * 6; // 48
  static const double xxxl = unit * 8; // 64

  // ========================================================================
  // BORDER RADIUS — Smaller, more precise (8-12px range)
  // ========================================================================
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // Default border radius for cards and buttons (12px for precise feel)
  static const double borderRadius = radiusMd;

  // ========================================================================
  // ELEVATION (subtle, used sparingly)
  // ========================================================================
  static const double elevationNone = 0;
  static const double elevationSm = 1;
  static const double elevationMd = 2;
  static const double elevationLg = 4;
  static const double elevationXl = 8;

  // ========================================================================
  // ICON SIZES
  // ========================================================================
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // ========================================================================
  // AVATAR SIZES
  // ========================================================================
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // ========================================================================
  // BUTTON HEIGHTS
  // ========================================================================
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // ========================================================================
  // INPUT FIELD HEIGHTS
  // ========================================================================
  static const double inputHeightSm = 44.0;
  static const double inputHeightMd = 52.0;
  static const double inputHeightLg = 60.0;

  // ========================================================================
  // CARD PADDING — Generous internal padding
  // ========================================================================
  static const double cardPaddingSm = 16.0;
  static const double cardPaddingMd = 20.0;
  static const double cardPaddingLg = 24.0;

  // ========================================================================
  // SCREEN PADDING — 24px+ minimum for generous margins
  // ========================================================================
  static const double screenPaddingSm = 20.0;
  static const double screenPaddingMd = 24.0;
  static const double screenPaddingLg = 28.0;

  // ========================================================================
  // SECTION GAPS — More breathing room between sections (32-40px)
  // ========================================================================
  static const double sectionGap = 32.0;
  static const double sectionGapLg = 40.0;

  // ========================================================================
  // ANIMATION DURATIONS (kept for backwards compatibility)
  // ========================================================================
  static const int durationFast = 150;
  static const int durationNormal = 250;
  static const int durationSlow = 400;
  static const int durationSlower = 600;
}