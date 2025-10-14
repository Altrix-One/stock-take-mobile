import 'package:flutter/material.dart';

/// Modern Design System for Cohenix Corporate Applications
/// Provides comprehensive design tokens following modern corporate design principles
/// Inspired by Frappe's clean, professional mobile interface design
class ModernDesignSystem {
  
  // =============================================================================
  // ENHANCED SPACING SYSTEM - Professional proportions
  // =============================================================================
  
  /// Base unit for spacing calculations (standard 8.0 for better proportions)
  static const double baseUnit = 8.0;
  
  /// Micro spacing for fine adjustments
  static const double spaceMicro = 4.0;    // 0.5 * baseUnit
  
  /// Extra small spacing - minimal gaps
  static const double spaceXS = 8.0;       // 1 * baseUnit
  
  /// Small spacing - tight components
  static const double spaceSM = 12.0;      // 1.5 * baseUnit
  
  /// Medium spacing - standard component spacing
  static const double spaceMD = 16.0;      // 2 * baseUnit
  
  /// Large spacing - section separators
  static const double spaceLG = 24.0;      // 3 * baseUnit
  
  /// Extra large spacing - major sections
  static const double spaceXL = 32.0;      // 4 * baseUnit
  
  /// Extra extra large spacing - page-level separation
  static const double space2XL = 40.0;     // 5 * baseUnit
  
  /// Massive spacing for hero sections
  static const double space3XL = 48.0;     // 6 * baseUnit
  
  // =============================================================================
  // COMPACT SPACING - For smaller devices and dense layouts
  // =============================================================================
  
  /// Compact spacing variants for better space utilization
  static const double spaceCompactMicro = 2.0;    // Extra tight
  static const double spaceCompactXS = 6.0;       // Tight
  static const double spaceCompactSM = 10.0;      // Small compact
  static const double spaceCompactMD = 12.0;      // Medium compact

  // =============================================================================
  // MODERN CORPORATE COLOR PALETTE - Frappe-inspired professional colors
  // =============================================================================
  
  /// Primary brand color - Professional Navy Blue (main brand color)
  static const Color primaryNavy = Color(0xFF1A365D);
  
  /// Primary accent - Clean Teal (secondary brand color)
  static const Color primaryTeal = Color(0xFF0891B2);
  
  /// Light teal variations for backgrounds and subtle accents
  static const Color tealLight = Color(0xFF06B6D4);
  static const Color tealPale = Color(0xFFECFDF5);
  static const Color tealBackground = Color(0xFFF0FDFA);
  
  /// Legacy compatibility - keep old naming
  static const Color primaryTealLight = Color(0xFF06B6D4);
  static const Color primaryTealPale = Color(0xFFECFDF5);
  
  /// Professional grays - neutral color system
  static const Color neutralDark = Color(0xFF111827);      // Almost black
  static const Color neutralMedium = Color(0xFF374151);    // Dark gray
  static const Color neutralLight = Color(0xFF6B7280);     // Medium gray
  static const Color neutralPale = Color(0xFF9CA3AF);      // Light gray
  static const Color neutralVeryPale = Color(0xFFF9FAFB);  // Very light gray
  
  /// Surface colors - clean backgrounds
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFCFCFD);
  static const Color surfaceTertiary = Color(0xFFF8FAFC);
  static const Color surfaceQuaternary = Color(0xFFF1F5F9);
  
  // =============================================================================
  // SEMANTIC COLORS - Status and feedback colors
  // =============================================================================
  
  /// Success color - Green
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  
  /// Warning color - Amber
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Error color - Red
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  /// Info color - Blue
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // =============================================================================
  // MODERN RADIUS SYSTEM
  // =============================================================================
  
  static const double radiusXS = 6.0;      // Small elements
  static const double radiusSM = 8.0;      // Buttons, small cards
  static const double radiusMD = 12.0;     // Standard cards
  static const double radiusLG = 16.0;     // Large cards
  static const double radiusXL = 20.0;     // Hero sections
  
  // =============================================================================
  // ELEVATION SYSTEM
  // =============================================================================
  
  static const double elevationSM = 1.0;   // Subtle shadows
  static const double elevationMD = 2.0;   // Standard cards
  static const double elevationLG = 4.0;   // Floating elements
  static const double elevationXL = 8.0;   // Modal overlays

  // =============================================================================
  // ENHANCED TYPOGRAPHY SCALE - Modern professional type system
  // =============================================================================
  
  static const String fontFamily = 'SF Pro Display'; // System font fallback
  
  /// Display styles for hero text and main headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.25,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  /// Headline styles for section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.35,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  /// Body text styles for content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  /// Label styles for UI elements
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.27,
  );
  
  /// Caption styles for auxiliary text
  static const TextStyle captionLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.2,
  );
  
  // =============================================================================
  // COMPACT TEXT STYLES - For smaller devices and dense layouts
  // =============================================================================
  
  /// Compact versions for better fitting on smaller screens
  static const TextStyle headlineCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.35,
  );
  
  static const TextStyle bodyCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  static const TextStyle bodyCompactMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  static const TextStyle labelCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.35,
  );
  
  static const TextStyle captionCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // =============================================================================
  // CONTAINER AND PADDING STYLES
  // =============================================================================
  
  /// Page-level padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0);
  
  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  /// Section padding
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: spaceMD);
  
  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  // =============================================================================
  // ENHANCED HELPER METHODS FOR THEME-AWARE COLORS
  // =============================================================================
  
  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white : neutralDark;
  }
  
  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white70 : neutralMedium;
  }
  
  static Color getTextTertiary(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white60 : neutralLight;
  }
  
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? const Color(0xFF1A1A1A) : surfacePrimary;
  }
  
  static Color getSurfaceVariant(Brightness brightness) {
    return brightness == Brightness.dark ? const Color(0xFF2A2A2A) : surfaceSecondary;
  }
  
  static Color getSurfaceTertiary(Brightness brightness) {
    return brightness == Brightness.dark ? const Color(0xFF333333) : surfaceTertiary;
  }
  
  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? Colors.white.withOpacity(0.12) 
        : Colors.black.withOpacity(0.08);
  }
  
  static Color getDividerColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? Colors.white.withOpacity(0.08) 
        : Colors.black.withOpacity(0.06);
  }

  // =============================================================================
  // ENHANCED CARD DECORATIONS - Multiple card styles
  // =============================================================================
  
  /// Standard elevated card decoration
  static BoxDecoration modernCardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: getSurfaceColor(brightness),
      borderRadius: BorderRadius.circular(radiusMD),
      border: Border.all(
        color: getBorderColor(brightness),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Subtle card decoration for secondary cards
  static BoxDecoration subtleCardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: getSurfaceColor(brightness),
      borderRadius: BorderRadius.circular(radiusSM),
      border: Border.all(
        color: getBorderColor(brightness),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Hero card decoration for prominent content
  static BoxDecoration heroCardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: getSurfaceColor(brightness),
      borderRadius: BorderRadius.circular(radiusLG),
      border: Border.all(
        color: getBorderColor(brightness),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.6)
            : Colors.black.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Glass card decoration for overlay content
  static BoxDecoration glassCardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: brightness == Brightness.dark 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(radiusMD),
      border: Border.all(
        color: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // =============================================================================
  // SPACING WIDGETS
  // =============================================================================
  
  static const SizedBox verticalSpaceMicro = SizedBox(height: spaceMicro);
  static const SizedBox verticalSpaceXS = SizedBox(height: spaceXS);
  static const SizedBox verticalSpaceSM = SizedBox(height: spaceSM);
  static const SizedBox verticalSpaceMD = SizedBox(height: spaceMD);
  static const SizedBox verticalSpaceLG = SizedBox(height: spaceLG);
  static const SizedBox verticalSpaceXL = SizedBox(height: spaceXL);
  
  static const SizedBox horizontalSpaceMicro = SizedBox(width: spaceMicro);
  static const SizedBox horizontalSpaceXS = SizedBox(width: spaceXS);
  static const SizedBox horizontalSpaceSM = SizedBox(width: spaceSM);
  static const SizedBox horizontalSpaceMD = SizedBox(width: spaceMD);
  static const SizedBox horizontalSpaceLG = SizedBox(width: spaceLG);
  static const SizedBox horizontalSpaceXL = SizedBox(width: spaceXL);
}