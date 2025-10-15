import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cohenix_colors.dart';
import 'cohenix_typography.dart';
import 'modern_design_system.dart';

/// Cohenix App Theme
/// Professional theme implementation based on Cohenix Style Guide
class AppTheme {
  // =============================================================================
  // LEGACY COLOR SUPPORT - For backward compatibility
  // =============================================================================

  // Map legacy colors to Cohenix colors
  static const Color primaryColor = CohenixColors.royalBlue;
  static const Color primaryLightColor = CohenixColors.oceanBlue;
  static const Color primaryDarkColor = CohenixColors.midnightBlue;
  static const Color tealPrimary = CohenixColors.royalBlue;
  static const Color tealSecondary = CohenixColors.oceanBlue;
  static const Color tealDark = CohenixColors.midnightBlue;
  static const Color secondaryColor = CohenixColors.oceanBlue;

  // Status colors
  static const Color successColor = CohenixColors.success;
  static const Color warningColor = CohenixColors.warning;
  static const Color errorColor = CohenixColors.error;
  static const Color infoColor = CohenixColors.info;
  static const Color greenColor = CohenixColors.success;
  static const Color redColor = CohenixColors.error;

  // Light theme colors
  static const Color lightBackground = CohenixColors.lightBackground;
  static const Color lightSurface = CohenixColors.lightSurface;
  static const Color lightSurfaceVariant = CohenixColors.lightSurfaceVariant;
  static const Color lightCardBackground = CohenixColors.lightSurface;
  static const Color lightCardTinted = CohenixColors.lightSurfaceVariant;
  static const Color lightTextPrimary = CohenixColors.lightOnSurface;
  static const Color lightTextSecondary = CohenixColors.lightOnSurfaceVariant;
  static const Color lightTextTertiary = CohenixColors.lightOnSurfaceSecondary;
  static const Color lightDivider = CohenixColors.lightOutline;
  static const Color lightBorder = CohenixColors.lightOutline;
  static const Color lightBorderLight = CohenixColors.lightOutlineVariant;

  // Dark theme colors
  static const Color darkBackground = CohenixColors.darkBackground;
  static const Color darkSurface = CohenixColors.darkSurface;
  static const Color darkSurfaceVariant = CohenixColors.darkSurfaceVariant;
  static const Color darkCardBackground = CohenixColors.darkSurface;
  static const Color darkCardTinted = CohenixColors.darkSurfaceVariant;
  static const Color darkTextPrimary = CohenixColors.darkOnSurface;
  static const Color darkTextSecondary = CohenixColors.darkOnSurfaceVariant;
  static const Color darkTextTertiary = CohenixColors.darkOnSurfaceSecondary;
  static const Color darkDivider = CohenixColors.darkOutline;
  static const Color darkBorder = CohenixColors.darkOutline;
  static const Color darkBorderLight = CohenixColors.darkOutlineVariant;

  // =============================================================================
  // COHENIX LIGHT THEME
  // =============================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: CohenixTypography.lightTextTheme,

    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: CohenixColors.royalBlue,
      onPrimary: Colors.white,
      primaryContainer: CohenixColors.skyBlue,
      onPrimaryContainer: CohenixColors.royalBlue,
      secondary: CohenixColors.oceanBlue,
      onSecondary: Colors.white,
      secondaryContainer: CohenixColors.oceanBlue.withOpacity(0.1),
      onSecondaryContainer: CohenixColors.oceanBlue,
      surface: CohenixColors.lightSurface,
      onSurface: CohenixColors.lightOnSurface,
      surfaceContainer: CohenixColors.lightSurfaceVariant,
      surfaceContainerHigh: CohenixColors.lightSurfaceVariant,
      background: CohenixColors.lightBackground,
      onBackground: CohenixColors.lightOnSurface,
      error: CohenixColors.error,
      onError: Colors.white,
      outline: CohenixColors.lightOutline,
      outlineVariant: CohenixColors.lightOutlineVariant,
      surfaceVariant: CohenixColors.lightSurfaceVariant,
      onSurfaceVariant: CohenixColors.lightOnSurfaceVariant,
      inverseSurface: CohenixColors.darkSurface,
      onInverseSurface: CohenixColors.darkOnSurface,
      tertiary: CohenixColors.skyBlue,
      onTertiary: CohenixColors.royalBlue,
    ),

    // App Bar Theme - Modern Teal with proper contrast
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: CohenixColors.lightOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: CohenixTypography.headlineSmall.copyWith(
        color: CohenixColors.lightOnSurface,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: CohenixColors.lightOnSurface),
      actionsIconTheme: IconThemeData(color: ModernDesignSystem.primaryTeal),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // Card Theme - Clean and minimal
    cardTheme: CardThemeData(
      color: CohenixColors.lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: CohenixColors.lightSurface,
      selectedItemColor: CohenixColors.royalBlue,
      unselectedItemColor: CohenixColors.lightOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: CohenixTypography.labelSmall,
      unselectedLabelStyle: CohenixTypography.labelSmall,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CohenixColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.lightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.royalBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.error, width: 2),
      ),
      labelStyle: CohenixTypography.withSecondaryColor(
          CohenixTypography.bodyMedium, Brightness.light),
      hintStyle: CohenixTypography.withSecondaryColor(
          CohenixTypography.bodySmall, Brightness.light),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CohenixColors.royalBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: CohenixColors.royalBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: CohenixTypography.buttonMedium,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CohenixColors.royalBlue,
        textStyle: CohenixTypography.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CohenixColors.royalBlue,
        side: BorderSide(color: CohenixColors.royalBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: CohenixTypography.buttonMedium,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: CohenixColors.royalBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: CohenixColors.lightSurfaceVariant,
      selectedColor: CohenixColors.skyBlue,
      disabledColor: CohenixColors.lightOutlineVariant,
      labelStyle: CohenixTypography.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: CohenixTypography.titleMedium,
      subtitleTextStyle: CohenixTypography.bodySmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: CohenixColors.lightOutline,
      thickness: 1,
      space: 1,
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CohenixColors.darkSurface,
      contentTextStyle: CohenixTypography.withColor(
          CohenixTypography.bodyMedium, Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // =============================================================================
  // COHENIX DARK THEME
  // =============================================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: CohenixTypography.darkTextTheme,

    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: CohenixColors.oceanBlue, // Brighter Ocean Blue for dark theme
      onPrimary: Colors.white,
      primaryContainer: CohenixColors.midnightBlue,
      onPrimaryContainer: CohenixColors.skyBlue,
      secondary: CohenixColors.skyBlue,
      onSecondary: CohenixColors.midnightBlue,
      secondaryContainer: CohenixColors.skyBlue.withOpacity(0.2),
      onSecondaryContainer: CohenixColors.skyBlue,
      surface: CohenixColors.darkSurface,
      onSurface: CohenixColors.darkOnSurface,
      surfaceContainer: CohenixColors.darkSurfaceVariant,
      surfaceContainerHigh: CohenixColors.darkSurfaceVariant,
      background: CohenixColors.darkBackground,
      onBackground: CohenixColors.darkOnSurface,
      error: CohenixColors.error,
      onError: Colors.white,
      outline: CohenixColors.darkOutline,
      outlineVariant: CohenixColors.darkOutlineVariant,
      surfaceVariant: CohenixColors.darkSurfaceVariant,
      onSurfaceVariant: CohenixColors.darkOnSurfaceVariant,
      inverseSurface: CohenixColors.lightSurface,
      onInverseSurface: CohenixColors.lightOnSurface,
      tertiary: CohenixColors.skyBlue,
      onTertiary: CohenixColors.midnightBlue,
    ),

    // App Bar Theme - Dark with modern contrast
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: CohenixColors.darkOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: CohenixTypography.headlineSmall.copyWith(
        color: CohenixColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: CohenixColors.darkOnSurface),
      actionsIconTheme: IconThemeData(color: ModernDesignSystem.primaryTeal),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Card Theme - Dark surfaces
    cardTheme: CardThemeData(
      color: CohenixColors.darkSurface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: CohenixColors.darkSurface,
      selectedItemColor: CohenixColors.oceanBlue,
      unselectedItemColor: CohenixColors.darkOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: CohenixTypography.labelSmall,
      unselectedLabelStyle: CohenixTypography.labelSmall,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CohenixColors.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.oceanBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CohenixColors.error, width: 2),
      ),
      labelStyle: CohenixTypography.withSecondaryColor(
          CohenixTypography.bodyMedium, Brightness.dark),
      hintStyle: CohenixTypography.withSecondaryColor(
          CohenixTypography.bodySmall, Brightness.dark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CohenixColors.oceanBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: CohenixColors.oceanBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: CohenixTypography.buttonMedium,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CohenixColors.oceanBlue,
        textStyle: CohenixTypography.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CohenixColors.oceanBlue,
        side: BorderSide(color: CohenixColors.oceanBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: CohenixTypography.buttonMedium,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: CohenixColors.oceanBlue,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: CohenixColors.darkSurfaceVariant,
      selectedColor: CohenixColors.skyBlue.withOpacity(0.3),
      disabledColor: CohenixColors.darkOutlineVariant,
      labelStyle: CohenixTypography.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: CohenixTypography.withPrimaryColor(
          CohenixTypography.titleMedium, Brightness.dark),
      subtitleTextStyle: CohenixTypography.withSecondaryColor(
          CohenixTypography.bodySmall, Brightness.dark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: CohenixColors.darkOutline,
      thickness: 1,
      space: 1,
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CohenixColors.darkSurfaceVariant,
      contentTextStyle: CohenixTypography.withColor(
          CohenixTypography.bodyMedium, Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // Helper methods for getting theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightCardBackground;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }
}
