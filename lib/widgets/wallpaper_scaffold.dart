import 'package:flutter/material.dart';
import '../constants/wallpaper_manager.dart';
import '../constants/unified_theme_system.dart';

/// Wallpaper Scaffold
/// A reusable wrapper that applies wallpaper background to any screen
/// with consistent theming and glass morphism effects
class WallpaperScaffold extends StatefulWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final String? customWallpaperKey;

  const WallpaperScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = true,
    this.extendBody = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.customWallpaperKey,
  });

  @override
  State<WallpaperScaffold> createState() => _WallpaperScaffoldState();
}

class _WallpaperScaffoldState extends State<WallpaperScaffold> {
  String? _wallpaperKey;
  WallpaperDefinition? _wallpaperDef;
  
  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    try {
      final wallpaperKey = widget.customWallpaperKey ?? 
          await UnifiedThemeSystem.getCurrentWallpaperKey();
      final wallpaperDef = WallpaperManager.wallpapers[wallpaperKey] ?? 
          WallpaperManager.wallpapers['royal_ocean_blue']!;
      
      if (mounted) {
        setState(() {
          _wallpaperKey = wallpaperKey;
          _wallpaperDef = wallpaperDef;
        });
      }
    } catch (e) {
      print('Error loading wallpaper in WallpaperScaffold: $e');
      if (mounted) {
        setState(() {
          _wallpaperKey = 'royal_ocean_blue';
          _wallpaperDef = WallpaperManager.wallpapers['royal_ocean_blue']!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while wallpaper loads
    if (_wallpaperDef == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1436AC), // Royal blue fallback
        appBar: widget.appBar as PreferredSizeWidget?,
        body: widget.body,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        extendBody: widget.extendBody,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      extendBody: widget.extendBody,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.appBar as PreferredSizeWidget?,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          // Wallpaper background
          Positioned.fill(
            child: WallpaperManager.createWallpaper(_wallpaperDef!),
          ),
          // Content with glass morphism overlay if needed
          Positioned.fill(
            child: widget.body,
          ),
        ],
      ),
    );
  }
}

/// Glass Container
/// A reusable container with glass morphism effect that works well on wallpapers
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final Color? color;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.opacity = 0.1,
    this.borderOpacity = 0.2,
    this.color,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: blur / 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Glass Card
/// A card widget with glass morphism effect for use on wallpapers
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final VoidCallback? onTap;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 16.0,
    this.opacity = 0.1,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = GlassContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      opacity: opacity,
      color: color,
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
}

/// Section Header
/// A standardized section header with glass effect for wallpaper backgrounds
class WallpaperSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const WallpaperSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.white).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (iconColor ?? Colors.white).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}