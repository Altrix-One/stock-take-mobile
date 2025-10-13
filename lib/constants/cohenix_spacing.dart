import 'package:flutter/material.dart';

/// Cohenix Spacing System
/// Professional spacing constants based on 8pt grid system
/// Following Cohenix design principles for clean, consistent layouts
class CohenixSpacing {
  
  // =============================================================================
  // BASE SPACING UNITS
  // =============================================================================
  
  /// Base spacing unit - all other spacing is derived from this
  static const double baseUnit = 8.0;
  
  // =============================================================================
  // SPACING SCALES
  // =============================================================================
  
  /// Extra small spacing (4px)
  static const double xs = baseUnit * 0.5; // 4.0
  
  /// Small spacing (8px)
  static const double sm = baseUnit * 1.0; // 8.0
  
  /// Medium spacing (16px)
  static const double md = baseUnit * 2.0; // 16.0
  
  /// Large spacing (24px)
  static const double lg = baseUnit * 3.0; // 24.0
  
  /// Extra large spacing (32px)
  static const double xl = baseUnit * 4.0; // 32.0
  
  /// Extra extra large spacing (40px)
  static const double xxl = baseUnit * 5.0; // 40.0
  
  /// Triple extra large spacing (48px)
  static const double xxxl = baseUnit * 6.0; // 48.0
  
  // =============================================================================
  // SEMANTIC SPACING
  // =============================================================================
  
  /// Micro spacing for tight layouts
  static const double micro = xs; // 4.0
  
  /// Compact spacing for dense information
  static const double compact = sm; // 8.0
  
  /// Comfortable spacing for normal layouts
  static const double comfortable = md; // 16.0
  
  /// Spacious spacing for breathing room
  static const double spacious = lg; // 24.0
  
  /// Loose spacing for prominent sections
  static const double loose = xl; // 32.0
  
  // =============================================================================
  // COMPONENT SPACING
  // =============================================================================
  
  /// Padding for buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: sm, // 8.0
  );
  
  /// Padding for large buttons
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: lg, // 24.0
    vertical: md, // 16.0
  );
  
  /// Padding for small buttons
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm, // 8.0
    vertical: xs, // 4.0
  );
  
  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md); // 16.0
  
  /// Card margin
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: sm, // 8.0
  );
  
  /// Page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(md); // 16.0
  
  /// Page padding with extra horizontal space
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(
    horizontal: lg, // 24.0
    vertical: md, // 16.0
  );
  
  /// Section padding
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: lg, // 24.0
  );
  
  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: sm, // 8.0
  );
  
  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: md, // 16.0
  );
  
  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg); // 24.0
  
  /// Snackbar padding
  static const EdgeInsets snackbarPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
    vertical: sm, // 8.0
  );
  
  // =============================================================================
  // LAYOUT SPACING
  // =============================================================================
  
  /// App bar height
  static const double appBarHeight = 64.0;
  
  /// Bottom navigation height
  static const double bottomNavHeight = 80.0;
  
  /// Floating action button padding from edges
  static const double fabPadding = md; // 16.0
  
  /// Safe area padding
  static const EdgeInsets safeAreaPadding = EdgeInsets.all(md); // 16.0
  
  /// Screen edge padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md, // 16.0
  );
  
  // =============================================================================
  // SPACING WIDGETS - Vertical
  // =============================================================================
  
  /// Extra small vertical space
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  
  /// Small vertical space
  static const Widget verticalSpaceSM = SizedBox(height: sm);
  
  /// Medium vertical space
  static const Widget verticalSpaceMD = SizedBox(height: md);
  
  /// Large vertical space
  static const Widget verticalSpaceLG = SizedBox(height: lg);
  
  /// Extra large vertical space
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  
  /// Extra extra large vertical space
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);
  
  /// Triple extra large vertical space
  static const Widget verticalSpaceXXXL = SizedBox(height: xxxl);
  
  // =============================================================================
  // SPACING WIDGETS - Horizontal
  // =============================================================================
  
  /// Extra small horizontal space
  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  
  /// Small horizontal space
  static const Widget horizontalSpaceSM = SizedBox(width: sm);
  
  /// Medium horizontal space
  static const Widget horizontalSpaceMD = SizedBox(width: md);
  
  /// Large horizontal space
  static const Widget horizontalSpaceLG = SizedBox(width: lg);
  
  /// Extra large horizontal space
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  
  /// Extra extra large horizontal space
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);
  
  /// Triple extra large horizontal space
  static const Widget horizontalSpaceXXXL = SizedBox(width: xxxl);
  
  // =============================================================================
  // BORDER RADIUS VALUES
  // =============================================================================
  
  /// Extra small border radius
  static const double radiusXS = xs; // 4.0
  
  /// Small border radius
  static const double radiusSM = sm; // 8.0
  
  /// Medium border radius
  static const double radiusMD = 12.0;
  
  /// Large border radius
  static const double radiusLG = md; // 16.0
  
  /// Extra large border radius
  static const double radiusXL = 20.0;
  
  /// Round border radius (for circular elements)
  static const double radiusRound = 999.0;
  
  // =============================================================================
  // ELEVATION VALUES
  // =============================================================================
  
  /// No elevation
  static const double elevationNone = 0.0;
  
  /// Small elevation
  static const double elevationSM = 2.0;
  
  /// Medium elevation
  static const double elevationMD = 4.0;
  
  /// Large elevation
  static const double elevationLG = 8.0;
  
  /// Extra large elevation
  static const double elevationXL = 12.0;
  
  /// Maximum elevation
  static const double elevationMax = 24.0;
  
  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Create custom vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);
  
  /// Create custom horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width);
  
  /// Create custom padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    } else if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    } else {
      return EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        left: left ?? 0,
        right: right ?? 0,
      );
    }
  }
  
  /// Create border radius
  static BorderRadius borderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.circular(all);
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(topLeft ?? 0),
        topRight: Radius.circular(topRight ?? 0),
        bottomLeft: Radius.circular(bottomLeft ?? 0),
        bottomRight: Radius.circular(bottomRight ?? 0),
      );
    }
  }
  
  // =============================================================================
  // LEGACY SUPPORT - For backward compatibility
  // =============================================================================
  
  /// Legacy padding constant
  static const double fixPadding = md; // 16.0
  
  /// Legacy height space
  static const Widget heightSpace = verticalSpaceMD;
  
  /// Legacy width space
  static const Widget widthSpace = horizontalSpaceMD;
  
  /// Legacy small spaces
  static const Widget height5Space = SizedBox(height: 5.0);
  static const Widget width5Space = SizedBox(width: 5.0);
  
  /// Legacy height box method
  static SizedBox heightBox(double height) => SizedBox(height: height);
  
  /// Legacy width box method
  static SizedBox widthBox(double width) => SizedBox(width: width);
}