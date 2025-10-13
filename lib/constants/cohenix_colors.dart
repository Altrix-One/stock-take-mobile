import 'package:flutter/material.dart';

/// Cohenix Brand Color Palette
/// Based on the official Cohenix Style Guide
class CohenixColors {
  // =============================================================================
  // PRIMARY COLORS - Core Brand Colors
  // =============================================================================
  
  /// Royal Blue - Primary brand color
  /// HEX: #1436AC, RGB: 20, 54, 172, CMYK: 96, 88, 0, 0
  static const Color royalBlue = Color(0xFF1436AC);
  
  /// Ocean Blue - Secondary brand color
  /// HEX: #1483EB, RGB: 20, 131, 235, CMYK: 77, 46, 0, 0
  static const Color oceanBlue = Color(0xFF1483EB);

  // =============================================================================
  // SECONDARY COLORS - Supporting Brand Colors
  // =============================================================================
  
  /// Pure Black
  /// HEX: #000000, CMYK: 75, 68, 67, 90, RGB: 0, 0, 0
  static const Color pureBlack = Color(0xFF000000);
  
  /// Midnight Blue
  /// HEX: #011553, CMYK: 100, 96, 31, 40, RGB: 1, 21, 83
  static const Color midnightBlue = Color(0xFF011553);
  
  /// Sky Blue
  /// HEX: #AED8F7, CMYK: 29, 5, 0, 0, RGB: 174, 216, 247
  static const Color skyBlue = Color(0xFFAED8F7);

  // =============================================================================
  // APP COLORS - Application-Specific Colors
  // =============================================================================
  
  // Education
  static const Color education = Color(0xFFF16863);
  
  // Fitness  
  static const Color fitness = Color(0xFFD73B2C);
  
  // Raven
  static const Color raven = Color(0xFFF0592B);
  
  // Drive
  static const Color drive = Color(0xFFEF8621);
  
  // LMS
  static const Color lms = Color(0xFFF8CA57);
  
  // Mobile Item
  static const Color mobileItem = Color(0xFFF0B91E);
  
  // Slides
  static const Color slides = Color(0xFFFBE261);
  
  // CRM
  static const Color crm = Color(0xFF80C243);
  
  // Framework
  static const Color framework = Color(0xFF459F47);
  
  // Lending
  static const Color lending = Color(0xFF238B45);
  
  // Payroll
  static const Color payroll = Color(0xFF40BDAD);
  
  // Print Designer
  static const Color printDesigner = Color(0xFF52C2C2);
  
  // Books
  static const Color books = Color(0xFF40B8E9);
  
  // Commit
  static const Color commit = Color(0xFF6797B8);
  
  // ERP
  static const Color erp = Color(0xFF1A70B8);
  
  // App Builder
  static const Color appBuilder = Color(0xFF88C3FB);
  
  // Web App Builder
  static const Color webAppBuilder = Color(0xFF2C2A75);
  
  // Game Plan
  static const Color gamePlan = Color(0xFF422C8A);
  
  // Insights
  static const Color insights = Color(0xFF66499C);
  
  // Builder
  static const Color builder = Color(0xFFA64E9D);
  
  // Helpdesk
  static const Color helpdesk = Color(0xFFCC2565);
  
  // WIKI
  static const Color wiki = Color(0xFFCE233C);
  
  // Health
  static const Color health = Color(0xFFCE181E);

  // =============================================================================
  // SEMANTIC COLORS - Status & Feedback Colors
  // =============================================================================
  
  /// Success Green - Harmonized with Cohenix palette
  static const Color success = Color(0xFF238B45);
  
  /// Warning Orange - Harmonized with Cohenix palette  
  static const Color warning = Color(0xFFEF8621);
  
  /// Error Red - Harmonized with Cohenix palette
  static const Color error = Color(0xFFCE181E);
  
  /// Info Blue - Uses Ocean Blue
  static const Color info = oceanBlue;

  // =============================================================================
  // NEUTRAL COLORS - Light Theme
  // =============================================================================
  
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightOutlineVariant = Color(0xFFF0F0F0);
  
  // Text colors for light theme
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);
  static const Color lightOnSurfaceSecondary = Color(0xFF999999);

  // =============================================================================
  // NEUTRAL COLORS - Dark Theme
  // =============================================================================
  
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkOutline = Color(0xFF404040);
  static const Color darkOutlineVariant = Color(0xFF303030);
  
  // Text colors for dark theme
  static const Color darkOnSurface = Color(0xFFFAFAFA);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);
  static const Color darkOnSurfaceSecondary = Color(0xFF808080);

  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Get appropriate text color for Royal Blue background
  static Color onRoyalBlue = Colors.white;
  
  /// Get appropriate text color for Ocean Blue background  
  static Color onOceanBlue = Colors.white;
  
  /// Get appropriate text color for Midnight Blue background
  static Color onMidnightBlue = Colors.white;
  
  /// Get app color by module name
  static Color? getAppColor(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'education': return education;
      case 'fitness': return fitness;
      case 'raven': return raven;
      case 'drive': return drive;
      case 'lms': return lms;
      case 'mobile item': return mobileItem;
      case 'slides': return slides;
      case 'crm': return crm;
      case 'framework': return framework;
      case 'lending': return lending;
      case 'payroll': return payroll;
      case 'print designer': return printDesigner;
      case 'books': return books;
      case 'commit': return commit;
      case 'erp': return erp;
      case 'app builder': return appBuilder;
      case 'web app builder': return webAppBuilder;
      case 'game plan': return gamePlan;
      case 'insights': return insights;
      case 'builder': return builder;
      case 'helpdesk': return helpdesk;
      case 'wiki': return wiki;
      case 'health': return health;
      default: return null;
    }
  }

  // =============================================================================
  // THEME-AWARE COLOR GETTERS
  // =============================================================================
  
  /// Get background color based on theme brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
  
  /// Get surface color based on theme brightness
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }
  
  /// Get primary text color based on theme brightness
  static Color getOnSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkOnSurface : lightOnSurface;
  }
  
  /// Get secondary text color based on theme brightness
  static Color getOnSurfaceVariantColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkOnSurfaceVariant : lightOnSurfaceVariant;
  }
  
  /// Get outline color based on theme brightness
  static Color getOutlineColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkOutline : lightOutline;
  }
}