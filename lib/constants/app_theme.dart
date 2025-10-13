import 'package:flutter/material.dart';

class AppTheme {
  // =============================================================================
  // PROFESSIONAL HR ESS COLOR SYSTEM
  // =============================================================================
  
  // Primary Brand Colors - Deep, Authoritative Corporate Colors
  static const Color primaryColor = Color(0xFF0A3F75);        // Deep Navy Blue
  static const Color primaryLightColor = Color(0xFF34495E);   // Steel Blue
  static const Color primaryDarkColor = Color(0xFF041E3A);    // Darker Navy
  
  // Deprecated teal colors (for backwards compatibility)
  static const Color tealPrimary = Color(0xFF0A3F75);         // Redirected to new primary
  static const Color tealSecondary = Color(0xFF34495E);       // Redirected to primary light
  static const Color tealDark = Color(0xFF041E3A);            // Redirected to primary dark
  
  // Legacy colors (for backwards compatibility)
  static const Color secondaryColor = Color(0xFF34495E);      // Steel Blue
  
  // Semantic Status Colors - Controlled Accent Colors
  static const Color successColor = Color(0xFF27AE60);        // Professional Green
  static const Color warningColor = Color(0xFFF39C12);        // Warm Amber/Orange
  static const Color errorColor = Color(0xFFE74C3C);          // Professional Red
  static const Color infoColor = Color(0xFF3498DB);           // Professional Blue
  
  // Deprecated status colors (for backwards compatibility)
  static const Color greenColor = Color(0xFF27AE60);          // Redirected to success
  static const Color redColor = Color(0xFFE74C3C);            // Redirected to error
  static const Color warningColorOld = Color(0xFFF39C12);     // Redirected to warning
  
  // =============================================================================
  // NEUTRAL COLORS - Clean, Professional Backgrounds
  // =============================================================================
  
  // Light Theme Colors - Clean Off-White & Subtle Tints
  static const Color lightBackground = Color(0xFFF7F9FA);      // Clean Off-White Background
  static const Color lightSurface = Color(0xFFFFFFFF);         // Pure White Surface
  static const Color lightSurfaceVariant = Color(0xFFF0F2F5);  // Light Gray Variant
  static const Color lightCardBackground = Color(0xFFFFFFFF);   // Pure White Cards
  static const Color lightCardTinted = Color(0xFFF8FAFC);      // Subtle Primary Tint (5% opacity equivalent)
  
  // Text Colors - High Contrast for Legibility
  static const Color lightTextPrimary = Color(0xFF1A1A1A);     // Near Black
  static const Color lightTextSecondary = Color(0xFF6B7280);   // Professional Gray
  static const Color lightTextTertiary = Color(0xFF9CA3AF);    // Light Gray
  
  // Border & Divider Colors
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFD1D5DB);
  static const Color lightBorderLight = Color(0xFFF3F4F6);
  
  // Dark Theme Colors - Rich, Deep Surfaces
  static const Color darkBackground = Color(0xFF0F172A);        // Deep Navy Background
  static const Color darkSurface = Color(0xFF1E293B);          // Rich Charcoal Surface
  static const Color darkSurfaceVariant = Color(0xFF334155);    // Lighter Charcoal
  static const Color darkCardBackground = Color(0xFF1E293B);    // Rich Charcoal Cards
  static const Color darkCardTinted = Color(0xFF1A2332);       // Subtle Primary Tint
  
  // Dark Text Colors - Optimized for Dark Backgrounds
  static const Color darkTextPrimary = Color(0xFFF8FAFC);      // Off-White
  static const Color darkTextSecondary = Color(0xFFCBD5E1);    // Light Gray
  static const Color darkTextTertiary = Color(0xFF94A3B8);     // Medium Gray
  
  // Dark Border & Divider Colors
  static const Color darkDivider = Color(0xFF475569);
  static const Color darkBorder = Color(0xFF64748B);
  static const Color darkBorderLight = Color(0xFF334155);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Montserrat',
    
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: primaryColor,                    // Deep Navy Blue
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withOpacity(0.15),
      onPrimaryContainer: primaryDarkColor,
      secondary: primaryLightColor,             // Steel Blue
      onSecondary: Colors.white,
      secondaryContainer: primaryLightColor.withOpacity(0.15),
      onSecondaryContainer: primaryDarkColor,
      surface: lightSurface,                    // Pure White
      onSurface: lightTextPrimary,              // Near Black
      surfaceContainer: lightCardTinted,        // Subtle Primary Tint
      surfaceContainerHigh: lightSurfaceVariant, // Light Gray
      background: lightBackground,              // Clean Off-White
      onBackground: lightTextPrimary,
      error: errorColor,                        // Professional Red
      onError: Colors.white,
      outline: lightBorder,                     // Professional Gray Border
      outlineVariant: lightBorderLight,
      surfaceVariant: lightSurfaceVariant,      // Light Gray Variant
      onSurfaceVariant: lightTextSecondary,     // Professional Gray Text
      inverseSurface: darkSurface,
      onInverseSurface: darkTextPrimary,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: lightCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    
    // Bottom Navigation Theme - Frosted Glass Effect
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,              // Deep Navy for selected items
      unselectedItemColor: lightTextSecondary,      // Professional gray for unselected
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceVariant,               // Light gray fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),  // Deep navy focus
      ),
      labelStyle: TextStyle(color: lightTextSecondary),
      hintStyle: TextStyle(color: lightTextTertiary),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,                // Deep Navy buttons
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,                // Deep Navy FAB
      foregroundColor: Colors.white,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Montserrat',
    
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryColor,                        // Deep Navy Blue (works in dark too)
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withOpacity(0.3),
      onPrimaryContainer: Colors.white,
      secondary: primaryLightColor,                 // Steel Blue
      onSecondary: Colors.white,
      secondaryContainer: primaryLightColor.withOpacity(0.3),
      onSecondaryContainer: Colors.white,
      surface: darkSurface,                         // Rich Charcoal
      onSurface: darkTextPrimary,                   // Off-White
      surfaceContainer: darkCardTinted,             // Subtle Primary Tint
      surfaceContainerHigh: darkSurfaceVariant,     // Lighter Charcoal
      background: darkBackground,                   // Deep Navy Background
      onBackground: darkTextPrimary,
      error: errorColor,                            // Professional Red
      onError: Colors.white,
      outline: darkBorder,                          // Professional Border
      outlineVariant: darkBorderLight,
      surfaceVariant: darkSurfaceVariant,           // Lighter Charcoal
      onSurfaceVariant: darkTextSecondary,          // Light Gray Text
      inverseSurface: lightSurface,
      onInverseSurface: lightTextPrimary,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkCardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    
    // Bottom Navigation Theme - Elevated Dark Surface
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,              // Deep Navy for selected items
      unselectedItemColor: darkTextSecondary,       // Light gray for unselected
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,                // Lighter charcoal fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),  // Deep navy focus
      ),
      labelStyle: TextStyle(color: darkTextSecondary),
      hintStyle: TextStyle(color: darkTextTertiary),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,                // Deep Navy buttons
        foregroundColor: Colors.white,                // White text on dark buttons
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,                // Deep Navy FAB
      foregroundColor: Colors.white,                // White icon on dark FAB
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