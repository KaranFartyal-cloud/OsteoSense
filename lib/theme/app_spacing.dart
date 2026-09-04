class AppSpacing {
  // Base spacing unit (8pt grid system)
  static const double unit = 8.0;

  // Spacing scale
  static const double xs = unit; // 8
  static const double sm = unit * 2; // 16
  static const double md = unit * 3; // 24
  static const double lg = unit * 4; // 32
  static const double xl = unit * 5; // 40
  static const double xxl = unit * 6; // 48
  static const double xxxl = unit * 8; // 64

  // Border radius
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
  
  // Default border radius for cards and buttons
  static const double borderRadius = radiusMd;

  // Elevation (soft shadows)
  static const double elevationNone = 0;
  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;
  static const double elevationXl = 16;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // Button heights
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Input field heights
  static const double inputHeightSm = 44.0;
  static const double inputHeightMd = 52.0;
  static const double inputHeightLg = 60.0;

  // Card padding
  static const double cardPaddingSm = 16.0;
  static const double cardPaddingMd = 20.0;
  static const double cardPaddingLg = 24.0;

  // Screen padding
  static const double screenPaddingSm = 16.0;
  static const double screenPaddingMd = 20.0;
  static const double screenPaddingLg = 24.0;

  // Animation durations (in milliseconds)
  static const int durationFast = 150;
  static const int durationNormal = 300;
  static const int durationSlow = 500;
  static const int durationSlower = 800;
}
