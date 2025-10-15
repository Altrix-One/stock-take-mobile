import 'package:flutter/material.dart';

// =============================================================================
// PROFESSIONAL COLOR SYSTEM
// =============================================================================

// Primary Brand Colors
const Color primaryColor = Color.fromRGBO(26, 35, 52, 1); // Deep navy
const Color primaryLightColor = Color.fromRGBO(43, 57, 85, 1); // Lighter navy
const Color accentColor = Color(0xFF00BFA6); // Professional teal
const Color accentLightColor = Color(0xFF4DD0E1); // Light teal
const Color accentDarkColor = Color(0xFF00A693); // Dark teal
const Color accentPale = Color(0xFFE0F7F4); // Very light teal

// Semantic Colors
const Color successColor = Color(0xFF4CAF50); // Green for approved/success
const Color successLightColor = Color(0xFF81C784);
const Color warningColor = Color(0xFFFF9800); // Orange for pending/warning
const Color warningLightColor = Color(0xFFFFB74D);
const Color errorColor = Color(0xFFF44336); // Red for rejected/error
const Color errorLightColor = Color(0xFFE57373);
const Color infoColor = Color(0xFF2196F3); // Blue for info
const Color infoLightColor = Color(0xFF64B5F6);

// Neutral Colors
const Color whiteColor = Colors.white;
const Color blackColor = Color(0xFF1A1A1A);
const Color surfaceColor = Color(0xFFFAFAFA);
const Color backgroundLight = Color(0xFFF8F9FA);
const Color backgroundDark = Color(0xFF121212);

// Text Colors
const Color textPrimaryColor = Color(0xFF1A1A1A);
const Color textSecondaryColor = Color(0xFF666666);
const Color textTertiaryColor = Color(0xFF999999);
const Color textOnDarkColor = Color(0xFFFFFFFF);
const Color textOnAccentColor = Color(0xFFFFFFFF);

// Border Colors
const Color borderLightColor = Color(0xFFE0E0E0);
const Color borderMediumColor = Color(0xFFBDBDBD);
const Color borderDarkColor = Color(0xFF757575);
const Color dividerColor = Color(0xFFE0E0E0);

// Shadow Colors
const Color shadowLightColor = Color(0x1A000000);
const Color shadowMediumColor = Color(0x29000000);
const Color shadowDarkColor = Color(0x3D000000);

// Glass Effect Colors
const Color glassColor = Color(0x14FFFFFF);
const Color glassBorderColor = Color(0x29FFFFFF);

// Legacy Colors (for backward compatibility)
const Color secondaryColor = primaryLightColor;
const Color screenBgColor = backgroundLight;
const Color black3CColor = Color(0xFF3C3C3C);
const Color black33Color = Color(0xFF333333);
const Color greyColor = textSecondaryColor;
const Color greyD4Color = Color(0xFFD4D4D4);
const Color greyB4Color = Color(0xFFB4B4B4);
const Color f8Color = Color(0xFFF8F8F8);
const Color greenColor = successColor;
const Color redColor = errorColor;
const Color d9E3EAColor = Color(0xFFD9E3EA);
const Color darkBlueColor = primaryColor;
const Color darkGreenColor = accentDarkColor;
const Color darkRedColor = Color(0xFFD32F2F);
const Color gradientStartColor = primaryColor;
const Color greyBorderColor = borderLightColor;
const Color gradientEndColor = primaryLightColor;

// =============================================================================
// PROFESSIONAL SPACING SYSTEM
// =============================================================================

// Base spacing unit - follows 8pt grid system
const double spaceUnit = 8.0;

// Spacing constants
const double spaceXS = 4.0; // 0.5 * spaceUnit
const double spaceSM = 8.0; // 1 * spaceUnit
const double spaceMD = 16.0; // 2 * spaceUnit
const double spaceLG = 24.0; // 3 * spaceUnit
const double spaceXL = 32.0; // 4 * spaceUnit
const double space2XL = 40.0; // 5 * spaceUnit
const double space3XL = 48.0; // 6 * spaceUnit

// Container padding
const double paddingXS = spaceXS;
const double paddingSM = spaceSM;
const double paddingMD = spaceMD;
const double paddingLG = spaceLG;
const double paddingXL = spaceXL;

// Border radius
const double radiusXS = 4.0;
const double radiusSM = 8.0;
const double radiusMD = 12.0;
const double radiusLG = 16.0;
const double radiusXL = 20.0;
const double radiusRound = 999.0;

// Elevation/Shadow
const double elevationSM = 2.0;
const double elevationMD = 4.0;
const double elevationLG = 8.0;
const double elevationXL = 12.0;

// Legacy spacing (for backward compatibility)
const double fixPadding = spaceMD;

// Spacing widgets
const SizedBox heightSpaceXS = SizedBox(height: spaceXS);
const SizedBox heightSpaceSM = SizedBox(height: spaceSM);
const SizedBox heightSpaceMD = SizedBox(height: spaceMD);
const SizedBox heightSpaceLG = SizedBox(height: spaceLG);
const SizedBox heightSpaceXL = SizedBox(height: spaceXL);

const SizedBox widthSpaceXS = SizedBox(width: spaceXS);
const SizedBox widthSpaceSM = SizedBox(width: spaceSM);
const SizedBox widthSpaceMD = SizedBox(width: spaceMD);
const SizedBox widthSpaceLG = SizedBox(width: spaceLG);
const SizedBox widthSpaceXL = SizedBox(width: spaceXL);

// Legacy spacing widgets
const SizedBox heightSpace = SizedBox(height: fixPadding);
const SizedBox height5Space = SizedBox(height: 5.0);
const SizedBox height200Space = SizedBox(height: 200.0);
const SizedBox widthSpace = SizedBox(width: fixPadding);
const SizedBox width5Space = SizedBox(width: 5.0);

SizedBox heightBox(double height) => SizedBox(height: height);
SizedBox widthBox(double width) => SizedBox(width: width);

// =============================================================================
// PROFESSIONAL TYPOGRAPHY SYSTEM
// =============================================================================

// Font family
const String fontFamily = 'Montserrat';

// =============================================================================
// DISPLAY STYLES (Large headings)
// =============================================================================

const TextStyle displayLarge = TextStyle(
  fontFamily: fontFamily,
  fontSize: 32.0,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.25,
  color: textPrimaryColor,
);

const TextStyle displayMedium = TextStyle(
  fontFamily: fontFamily,
  fontSize: 28.0,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.25,
  color: textPrimaryColor,
);

const TextStyle displaySmall = TextStyle(
  fontFamily: fontFamily,
  fontSize: 24.0,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
  color: textPrimaryColor,
);

// =============================================================================
// HEADLINE STYLES (Section headers)
// =============================================================================

const TextStyle headlineLarge = TextStyle(
  fontFamily: fontFamily,
  fontSize: 22.0,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
  color: textPrimaryColor,
);

const TextStyle headlineMedium = TextStyle(
  fontFamily: fontFamily,
  fontSize: 20.0,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.15,
  color: textPrimaryColor,
);

const TextStyle headlineSmall = TextStyle(
  fontFamily: fontFamily,
  fontSize: 18.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
  color: textPrimaryColor,
);

// =============================================================================
// TITLE STYLES (Card/Component titles)
// =============================================================================

const TextStyle titleLarge = TextStyle(
  fontFamily: fontFamily,
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
  color: textPrimaryColor,
);

const TextStyle titleMedium = TextStyle(
  fontFamily: fontFamily,
  fontSize: 14.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
  color: textPrimaryColor,
);

const TextStyle titleSmall = TextStyle(
  fontFamily: fontFamily,
  fontSize: 12.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
  color: textPrimaryColor,
);

// =============================================================================
// BODY STYLES (Regular text)
// =============================================================================

const TextStyle bodyLarge = TextStyle(
  fontFamily: fontFamily,
  fontSize: 16.0,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.5,
  color: textPrimaryColor,
);

const TextStyle bodyMedium = TextStyle(
  fontFamily: fontFamily,
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
  color: textSecondaryColor,
);

const TextStyle bodySmall = TextStyle(
  fontFamily: fontFamily,
  fontSize: 12.0,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.4,
  color: textSecondaryColor,
);

// =============================================================================
// LABEL STYLES (Buttons, chips, etc.)
// =============================================================================

const TextStyle labelLarge = TextStyle(
  fontFamily: fontFamily,
  fontSize: 14.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
  color: textPrimaryColor,
);

const TextStyle labelMedium = TextStyle(
  fontFamily: fontFamily,
  fontSize: 12.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  color: textPrimaryColor,
);

const TextStyle labelSmall = TextStyle(
  fontFamily: fontFamily,
  fontSize: 10.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  color: textTertiaryColor,
);

// =============================================================================
// LEGACY STYLES (for backward compatibility)
// =============================================================================

const TextStyle semibold15White = TextStyle(
    color: whiteColor,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily);

const TextStyle bold18White = TextStyle(
    color: whiteColor,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily);

const TextStyle bold18Primary = TextStyle(
    color: primaryColor,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily);

const TextStyle bold17Primary = TextStyle(
    color: primaryColor,
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily);

const TextStyle semibold28White =
    TextStyle(color: whiteColor, fontSize: 28.0, fontWeight: FontWeight.w600);

const TextStyle semibold20White =
    TextStyle(color: whiteColor, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold18White =
    TextStyle(color: whiteColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16White =
    TextStyle(color: whiteColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold20Black33 =
    TextStyle(color: black33Color, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold28Black33 =
    TextStyle(color: black33Color, fontSize: 28.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Black33 =
    TextStyle(color: black33Color, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold17Black33 =
    TextStyle(color: black33Color, fontSize: 17.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Black33 =
    TextStyle(color: black33Color, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Black33 =
    TextStyle(color: black33Color, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Black33 =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Grey =
    TextStyle(color: greyColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Grey =
    TextStyle(color: greyColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Grey =
    TextStyle(color: greyColor, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Grey =
    TextStyle(color: greyColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold13Grey =
    TextStyle(color: greyColor, fontSize: 13.0, fontWeight: FontWeight.w600);

const TextStyle semibold20Primary =
    TextStyle(color: primaryColor, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Primary =
    TextStyle(color: primaryColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Primary =
    TextStyle(color: primaryColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Primary =
    TextStyle(color: primaryColor, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Primary =
    TextStyle(color: primaryColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold24Secondary = TextStyle(
    color: secondaryColor, fontSize: 24.0, fontWeight: FontWeight.w600);

const TextStyle semibold17Secondary = TextStyle(
    color: secondaryColor, fontSize: 17.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Secondary = TextStyle(
    color: secondaryColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Red =
    TextStyle(color: redColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Green =
    TextStyle(color: greenColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Green =
    TextStyle(color: greenColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle medium16Black33 =
    TextStyle(color: black33Color, fontSize: 16.0, fontWeight: FontWeight.w500);

const TextStyle medium15Black33 =
    TextStyle(color: black33Color, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14Black33 =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12Black33 =
    TextStyle(color: black33Color, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium14Black3C =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium15White =
    TextStyle(color: whiteColor, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14White =
    TextStyle(color: whiteColor, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12White =
    TextStyle(color: whiteColor, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium20Grey =
    TextStyle(color: greyColor, fontSize: 20.0, fontWeight: FontWeight.w500);

const TextStyle medium18Grey =
    TextStyle(color: greyColor, fontSize: 18.0, fontWeight: FontWeight.w500);

const TextStyle medium16Grey =
    TextStyle(color: greyColor, fontSize: 16.0, fontWeight: FontWeight.w500);

const TextStyle medium15Grey =
    TextStyle(color: greyColor, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14Grey =
    TextStyle(color: greyColor, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12Grey =
    TextStyle(color: greyColor, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium20Primary =
    TextStyle(color: primaryColor, fontSize: 20.0, fontWeight: FontWeight.w500);

const TextStyle medium30Primary =
    TextStyle(color: primaryColor, fontSize: 30.0, fontWeight: FontWeight.w500);
