import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallpaper_manager.dart';

/// Unified App Theme System
/// Complete theming solution with royal blue gradient wallpaper support
/// Replaces all other theme files for consistency
class AppThemeUnified {
  // =============================================================================
  // CORE COLORS - Royal Blue Gradient System
  // =============================================================================

  /// Primary Royal Blue
  static const Color primaryRoyalBlue = Color(0xFF1436AC);

  /// Secondary Ocean Blue
  static const Color secondaryOceanBlue = Color(0xFF1483EB);

  /// Light Sky Blue
  static const Color lightSkyBlue = Color(0xFFAED8F7);

  /// Gradient colors for wallpaper
  static const List<Color> gradientColors = [
    primaryRoyalBlue,
    secondaryOceanBlue,
    primaryRoyalBlue,
  ];

  // =============================================================================
  // SEMANTIC COLORS - Status and feedback
  // =============================================================================

  static const Color success = Color(0xFF238B45);
  static const Color warning = Color(0xFFEF8621);
  static const Color error = Color(0xFFCE181E);
  static const Color info = secondaryOceanBlue;

  // =============================================================================
  // GLASS MORPHISM COLORS - Enhanced for better content visibility
  // =============================================================================

  /// Light glass containers (white-based) - enhanced for better readability
  static const Color glassLight =
      Color(0x1FFFFFFF); // 12% white (rgba 255,255,255,0.12)
  static const Color glassMedium = Color(0x40FFFFFF); // 25% white
  static const Color glassStrong = Color(0x52FFFFFF); // 32% white for dialogs
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white

  /// Dark glass containers (black-based) for contrast
  static const Color glassDark = Color(0x1A000000); // 10% black
  static const Color glassDarkMedium = Color(0x33000000); // 20% black

  /// Text shadow for enhanced readability on gradient backgrounds
  static const List<Shadow> textShadow = [
    Shadow(
      color: Color(0x40000000), // rgba(0, 0, 0, 0.25)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Button shadow for elevated interaction areas
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Card shadow for layered depth
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // =============================================================================
  // TEXT COLORS - Enhanced contrast for better readability on gradient
  // =============================================================================

  /// Primary text - slightly off-white for better balance (92% white)
  static const Color textPrimary =
      Color(0xEBFFFFFF); // rgba(255, 255, 255, 0.92)
  /// Secondary text - medium light for hierarchy (85% white)
  static const Color textSecondary =
      Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)
  /// Tertiary text - subtle for less important info (70% white)
  static const Color textTertiary =
      Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.70)
  /// Disabled text - low emphasis (50% white)
  static const Color textDisabled =
      Color(0x80FFFFFF); // rgba(255, 255, 255, 0.50)

  // =============================================================================
  // SPACING AND SIZING - 8dp grid system
  // =============================================================================

  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 40.0;

  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;

  // =============================================================================
  // TYPOGRAPHY SYSTEM
  // =============================================================================

  static const String fontFamily = 'SF Pro Display'; // System font

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
    shadows: textShadow,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.25,
    shadows: textShadow,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
    shadows: textShadow,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700, // Increased from 600 for better hierarchy
    color: textPrimary,
    height: 1.3,
    shadows: textShadow,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
    shadows: textShadow,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.35,
    shadows: textShadow,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.43,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.33,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.33,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.27,
  );

  // Button Text Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.25,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.4,
    height: 1.2,
  );

  // =============================================================================
  // THEME CREATION - UNIFIED LIGHT THEME
  // =============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Transparent/glass based for wallpaper visibility
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: primaryRoyalBlue,
        onPrimary: textPrimary,
        primaryContainer: glassLight,
        onPrimaryContainer: textPrimary,
        secondary: secondaryOceanBlue,
        onSecondary: textPrimary,
        secondaryContainer: glassLight,
        onSecondaryContainer: textPrimary,
        tertiary: lightSkyBlue,
        onTertiary: primaryRoyalBlue,
        surface: Colors.transparent,
        onSurface: textPrimary,
        surfaceContainer: glassLight,
        surfaceContainerHigh: glassMedium,
        background: Colors.transparent,
        onBackground: textPrimary,
        error: error,
        onError: textPrimary,
        outline: glassBorder,
        outlineVariant: glassLight,
        surfaceVariant: glassLight,
        onSurfaceVariant: textSecondary,
      ),

      // Text Theme - All white for wallpaper visibility
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),

      // App Bar - Transparent with white text
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Scaffold - Transparent for wallpaper
      scaffoldBackgroundColor: Colors.transparent,

      // Card Theme - Glass morphism
      cardTheme: CardThemeData(
        color: glassLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: const BorderSide(
            color: glassBorder,
            width: 1,
          ),
        ),
        margin:
            const EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceSM),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textPrimary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceSM),
        titleTextStyle: titleMedium,
        subtitleTextStyle: bodySmall,
      ),

      // Input Decoration - Glass style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: textPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceMD),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRoyalBlue,
          foregroundColor: textPrimary,
          elevation: 4,
          shadowColor: primaryRoyalBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: spaceLG, vertical: spaceMD),
          textStyle: labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: labelLarge,
          padding: const EdgeInsets.symmetric(
              horizontal: spaceMD, vertical: spaceSM),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: spaceLG, vertical: spaceMD),
          textStyle: labelLarge,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryRoyalBlue,
        foregroundColor: textPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),

      // Bottom Navigation Bar - Glass effect
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: glassDark,
        selectedItemColor: textPrimary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: labelSmall,
        unselectedLabelStyle: labelSmall,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textPrimary),
      primaryIconTheme: const IconThemeData(color: textPrimary),

      // Divider
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 1,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: glassDarkMedium,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: glassLight,
        selectedColor: glassMedium,
        disabledColor: glassLight,
        labelStyle: labelMedium,
        secondaryLabelStyle: labelMedium.copyWith(color: textSecondary),
        padding:
            const EdgeInsets.symmetric(horizontal: spaceSM, vertical: spaceXS),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXS),
          side: const BorderSide(color: glassBorder),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: textPrimary,
        linearTrackColor: glassLight,
        circularTrackColor: glassLight,
      ),
    );
  }

  // =============================================================================
  // THEME CREATION - UNIFIED DARK THEME (same as light for wallpaper consistency)
  // =============================================================================

  static ThemeData get darkTheme => lightTheme; // Same theme for consistency

  // =============================================================================
  // WALLPAPER UTILITIES
  // =============================================================================

  /// Get the royal blue gradient wallpaper
  static Widget get wallpaperBackground {
    return WallpaperManager.fromKey('royal_ocean_blue');
  }

  /// Create an enhanced glass container with backdrop filter for better readability
  static Widget glassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = radiusMD,
    Color? color,
    double opacity = 0.12, // Enhanced from 0.1
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Color(0x1FFFFFFF), // rgba(255, 255, 255, 0.12)
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glassBorder,
          width: 1,
        ),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }

  /// Create a glass card with default styling
  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(spaceMD),
    EdgeInsetsGeometry? margin = const EdgeInsets.symmetric(
      horizontal: spaceMD,
      vertical: spaceSM,
    ),
    double borderRadius = radiusMD,
    VoidCallback? onTap,
  }) {
    final cardContent = glassContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Standard section header for pages
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    EdgeInsetsGeometry? padding = const EdgeInsets.fromLTRB(
      spaceMD,
      spaceLG,
      spaceMD,
      spaceSM,
    ),
  }) {
    return Padding(
      padding: padding!,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(spaceSM),
              decoration: BoxDecoration(
                color: glassLight,
                borderRadius: BorderRadius.circular(radiusXS),
                border: Border.all(color: glassBorder),
              ),
              child: Icon(icon, color: textPrimary, size: 20),
            ),
            const SizedBox(width: spaceSM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// Standard page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(spaceMD);

  /// Standard section spacing
  static const Widget sectionSpacing = SizedBox(height: spaceLG);

  /// Standard item spacing
  static const Widget itemSpacing = SizedBox(height: spaceSM);
}
