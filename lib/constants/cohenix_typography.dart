import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cohenix_colors.dart';

/// Cohenix Typography System
/// Based on the official Cohenix Style Guide
/// 
/// Primary Typeface: Lato - For logos and headers in formal communication
/// Secondary Typeface: Open Sans - For formal communication and multi-media artifacts
/// Electronic Typeface: Verdana - For Word, Excel, PowerPoint, and e-mailed materials
class CohenixTypography {
  
  // =============================================================================
  // DISPLAY STYLES - Large headings (Lato)
  // =============================================================================
  
  static TextStyle displayLarge = GoogleFonts.lato(
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    height: 1.25,
  );

  static TextStyle displayMedium = GoogleFonts.lato(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.29,
  );

  static TextStyle displaySmall = GoogleFonts.lato(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
  );

  // =============================================================================
  // HEADLINE STYLES - Section headers (Lato)
  // =============================================================================

  static TextStyle headlineLarge = GoogleFonts.lato(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.36,
  );

  static TextStyle headlineMedium = GoogleFonts.lato(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle headlineSmall = GoogleFonts.lato(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.44,
  );

  // =============================================================================
  // TITLE STYLES - Card/Component titles (Open Sans)
  // =============================================================================

  static TextStyle titleLarge = GoogleFonts.openSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle titleMedium = GoogleFonts.openSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle titleSmall = GoogleFonts.openSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.33,
  );

  // =============================================================================
  // BODY STYLES - Regular text (Open Sans)
  // =============================================================================

  static TextStyle bodyLarge = GoogleFonts.openSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.openSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle bodySmall = GoogleFonts.openSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // =============================================================================
  // LABEL STYLES - Buttons, chips, etc. (Open Sans)
  // =============================================================================

  static TextStyle labelLarge = GoogleFonts.openSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle labelMedium = GoogleFonts.openSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle labelSmall = GoogleFonts.openSans(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // =============================================================================
  // ELECTRONIC STYLES - For digital materials (Verdana)
  // =============================================================================

  static TextStyle electronicHeading = TextStyle(
    fontFamily: 'Verdana',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle electronicBody = TextStyle(
    fontFamily: 'Verdana',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle electronicCaption = TextStyle(
    fontFamily: 'Verdana',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // =============================================================================
  // THEME-AWARE TEXT STYLES
  // =============================================================================

  /// Apply appropriate text color based on theme brightness
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply theme-aware primary text color
  static TextStyle withPrimaryColor(TextStyle style, Brightness brightness) {
    return style.copyWith(
      color: CohenixColors.getOnSurfaceColor(brightness),
    );
  }

  /// Apply theme-aware secondary text color
  static TextStyle withSecondaryColor(TextStyle style, Brightness brightness) {
    return style.copyWith(
      color: CohenixColors.getOnSurfaceVariantColor(brightness),
    );
  }

  /// Apply Royal Blue color
  static TextStyle withRoyalBlue(TextStyle style) {
    return style.copyWith(color: CohenixColors.royalBlue);
  }

  /// Apply Ocean Blue color
  static TextStyle withOceanBlue(TextStyle style) {
    return style.copyWith(color: CohenixColors.oceanBlue);
  }

  /// Apply white color
  static TextStyle withWhite(TextStyle style) {
    return style.copyWith(color: Colors.white);
  }

  // =============================================================================
  // BUTTON TEXT STYLES
  // =============================================================================

  static TextStyle buttonLarge = GoogleFonts.openSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.5,
  );

  static TextStyle buttonMedium = GoogleFonts.openSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.43,
  );

  static TextStyle buttonSmall = GoogleFonts.openSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.33,
  );

  // =============================================================================
  // THEME DATA TEXT THEME
  // =============================================================================

  /// Generate TextTheme for light mode
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: withPrimaryColor(displayLarge, Brightness.light),
    displayMedium: withPrimaryColor(displayMedium, Brightness.light),
    displaySmall: withPrimaryColor(displaySmall, Brightness.light),
    headlineLarge: withPrimaryColor(headlineLarge, Brightness.light),
    headlineMedium: withPrimaryColor(headlineMedium, Brightness.light),
    headlineSmall: withPrimaryColor(headlineSmall, Brightness.light),
    titleLarge: withPrimaryColor(titleLarge, Brightness.light),
    titleMedium: withPrimaryColor(titleMedium, Brightness.light),
    titleSmall: withPrimaryColor(titleSmall, Brightness.light),
    bodyLarge: withPrimaryColor(bodyLarge, Brightness.light),
    bodyMedium: withSecondaryColor(bodyMedium, Brightness.light),
    bodySmall: withSecondaryColor(bodySmall, Brightness.light),
    labelLarge: withPrimaryColor(labelLarge, Brightness.light),
    labelMedium: withPrimaryColor(labelMedium, Brightness.light),
    labelSmall: withSecondaryColor(labelSmall, Brightness.light),
  );

  /// Generate TextTheme for dark mode
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: withPrimaryColor(displayLarge, Brightness.dark),
    displayMedium: withPrimaryColor(displayMedium, Brightness.dark),
    displaySmall: withPrimaryColor(displaySmall, Brightness.dark),
    headlineLarge: withPrimaryColor(headlineLarge, Brightness.dark),
    headlineMedium: withPrimaryColor(headlineMedium, Brightness.dark),
    headlineSmall: withPrimaryColor(headlineSmall, Brightness.dark),
    titleLarge: withPrimaryColor(titleLarge, Brightness.dark),
    titleMedium: withPrimaryColor(titleMedium, Brightness.dark),
    titleSmall: withPrimaryColor(titleSmall, Brightness.dark),
    bodyLarge: withPrimaryColor(bodyLarge, Brightness.dark),
    bodyMedium: withSecondaryColor(bodyMedium, Brightness.dark),
    bodySmall: withSecondaryColor(bodySmall, Brightness.dark),
    labelLarge: withPrimaryColor(labelLarge, Brightness.dark),
    labelMedium: withPrimaryColor(labelMedium, Brightness.dark),
    labelSmall: withSecondaryColor(labelSmall, Brightness.dark),
  );
}