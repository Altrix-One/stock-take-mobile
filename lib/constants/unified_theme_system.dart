import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallpaper_manager.dart';

/// Unified Theme System
/// Integrates wallpaper colors with Material 3 theming for consistent app-wide theming
class UnifiedThemeSystem {
  static const String _wallpaperKeyPrefs = 'selected_wallpaper';
  static const String _defaultWallpaper = 'royal_ocean_blue';
  
  // Cache for performance
  static String? _cachedWallpaperKey;
  static ThemeData? _cachedLightTheme;
  static ThemeData? _cachedDarkTheme;
  
  /// Get the current wallpaper key
  static Future<String> getCurrentWallpaperKey() async {
    if (_cachedWallpaperKey != null) return _cachedWallpaperKey!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedWallpaperKey = prefs.getString(_wallpaperKeyPrefs) ?? _defaultWallpaper;
      return _cachedWallpaperKey!;
    } catch (e) {
      print('Error loading wallpaper preference: $e');
      _cachedWallpaperKey = _defaultWallpaper;
      return _cachedWallpaperKey!;
    }
  }
  
  /// Set wallpaper key and clear cache
  static Future<void> setWallpaperKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperKeyPrefs, key);
      _cachedWallpaperKey = key;
      _cachedLightTheme = null;
      _cachedDarkTheme = null;
    } catch (e) {
      print('Error saving wallpaper preference: $e');
    }
  }
  
  /// Get wallpaper-aware light theme
  static Future<ThemeData> getLightTheme() async {
    if (_cachedLightTheme != null) return _cachedLightTheme!;
    
    final wallpaperKey = await getCurrentWallpaperKey();
    final wallpaperDef = WallpaperManager.wallpapers[wallpaperKey] ?? WallpaperManager.wallpapers['royal_ocean_blue']!;
    final primaryColor = wallpaperDef.colors.first;
    final secondaryColor = wallpaperDef.colors.length > 1 ? wallpaperDef.colors[1] : primaryColor;
    
    _cachedLightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: secondaryColor.withOpacity(0.1),
        onPrimaryContainer: primaryColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryColor.withOpacity(0.1),
        onSecondaryContainer: secondaryColor,
        surface: Colors.white.withOpacity(0.1), // Transparent for wallpaper
        onSurface: Colors.white,
        surfaceContainer: Colors.white.withOpacity(0.1),
        surfaceContainerHigh: Colors.white.withOpacity(0.15),
        background: Colors.transparent, // Transparent for wallpaper
        onBackground: Colors.white,
        error: const Color(0xFFCE181E),
        onError: Colors.white,
        outline: Colors.white.withOpacity(0.3),
        outlineVariant: Colors.white.withOpacity(0.1),
        surfaceVariant: Colors.white.withOpacity(0.05),
        onSurfaceVariant: Colors.white.withOpacity(0.8),
      ),
      
      // App Bar Theme - Transparent with white text
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card Theme - Glass morphism
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.1),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Text themes - All white for wallpaper visibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
      ),
      
      // Button themes with primary wallpaper color
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
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
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black.withOpacity(0.2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.2),
        thickness: 1,
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black.withOpacity(0.8),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    return _cachedLightTheme!;
  }
  
  /// Get wallpaper-aware dark theme (similar to light but with different opacity values)
  static Future<ThemeData> getDarkTheme() async {
    if (_cachedDarkTheme != null) return _cachedDarkTheme!;
    
    final wallpaperKey = await getCurrentWallpaperKey();
    final wallpaperDef = WallpaperManager.wallpapers[wallpaperKey] ?? WallpaperManager.wallpapers['royal_ocean_blue']!;
    final primaryColor = wallpaperDef.colors.first;
    final secondaryColor = wallpaperDef.colors.length > 1 ? wallpaperDef.colors[1] : primaryColor;
    
    _cachedDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: secondaryColor.withOpacity(0.2),
        onPrimaryContainer: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryColor.withOpacity(0.2),
        onSecondaryContainer: Colors.white,
        surface: Colors.black.withOpacity(0.1),
        onSurface: Colors.white,
        surfaceContainer: Colors.black.withOpacity(0.2),
        surfaceContainerHigh: Colors.black.withOpacity(0.3),
        background: Colors.transparent,
        onBackground: Colors.white,
        error: const Color(0xFFCE181E),
        onError: Colors.white,
        outline: Colors.white.withOpacity(0.3),
        outlineVariant: Colors.white.withOpacity(0.1),
        surfaceVariant: Colors.black.withOpacity(0.1),
        onSurfaceVariant: Colors.white.withOpacity(0.8),
      ),
      
      // Similar theming as light theme but with darker glass effects
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      cardTheme: CardThemeData(
        color: Colors.black.withOpacity(0.2),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
      ),
    );
    
    return _cachedDarkTheme!;
  }
  
  /// Clear theme cache (call when wallpaper changes)
  static void clearCache() {
    _cachedLightTheme = null;
    _cachedDarkTheme = null;
    _cachedWallpaperKey = null;
  }
}