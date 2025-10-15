import 'package:flutter/material.dart';

/// Simple Blue Theme - Forces royal blue background everywhere
class SimpleBlueTheme {
  static const Color royalBlue = Color(0xFF1436AC);
  static const Color oceanBlue = Color(0xFF1483EB);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Force all possible backgrounds to royal blue
      scaffoldBackgroundColor: royalBlue,
      canvasColor: royalBlue,
      cardColor: royalBlue,
      dialogBackgroundColor: royalBlue,

      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: royalBlue,
        onPrimary: Colors.white,
        secondary: oceanBlue,
        onSecondary: Colors.white,
        surface: royalBlue,
        onSurface: Colors.white,
        surfaceVariant: royalBlue,
        onSurfaceVariant: Colors.white,
        background: royalBlue,
        onBackground: Colors.white,
        surfaceContainer: royalBlue,
        surfaceContainerHigh: royalBlue,
        surfaceContainerHighest: royalBlue,
        surfaceContainerLow: royalBlue,
        surfaceContainerLowest: royalBlue,
        inverseSurface: royalBlue,
        onInverseSurface: Colors.white,
        primaryContainer: oceanBlue,
        onPrimaryContainer: Colors.white,
        secondaryContainer: oceanBlue,
        onSecondaryContainer: Colors.white,
        tertiary: oceanBlue,
        onTertiary: Colors.white,
        tertiaryContainer: oceanBlue,
        onTertiaryContainer: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFFB71C1C),
        outline: Colors.white24,
        outlineVariant: Colors.white12,
        shadow: Colors.black26,
        scrim: Colors.black54,
        inversePrimary: Colors.white,
        surfaceTint: royalBlue,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: royalBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: royalBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: royalBlue,
        surfaceTintColor: royalBlue,
        shadowColor: Colors.black26,
        elevation: 0,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Text themes - all white
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          surfaceTintColor: oceanBlue,
          shadowColor: Colors.black26,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          surfaceTintColor: Colors.white,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          surfaceTintColor: oceanBlue,
        ),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: royalBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        tileColor: royalBlue,
        textColor: Colors.white,
        iconColor: Colors.white,
        selectedTileColor: oceanBlue,
        selectedColor: Colors.white,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: Colors.white),
      primaryIconTheme: const IconThemeData(color: Colors.white),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Dialog theme
      dialogTheme: const DialogThemeData(
        backgroundColor: royalBlue,
        surfaceTintColor: royalBlue,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: Colors.white),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Snack bar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
        linearTrackColor: Colors.white24,
        circularTrackColor: Colors.white24,
      ),

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabAlignment: TabAlignment.center,
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: royalBlue,
        surfaceTintColor: royalBlue,
        elevation: 16,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
