import 'package:flutter/material.dart';
import '../constants/app_theme_unified.dart';

/// Universal Scaffold
/// THE ONLY scaffold that should be used throughout the app
/// Ensures consistent royal blue gradient wallpaper on all screens
class UniversalScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;
  final bool showWallpaper;

  const UniversalScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = true,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
    this.showWallpaper = true, // Always show wallpaper by default
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Royal blue gradient wallpaper background - ALWAYS PRESENT
          if (showWallpaper)
            Positioned.fill(
              child: AppThemeUnified.wallpaperBackground,
            ),
          // Content over the wallpaper
          Positioned.fill(
            child: body,
          ),
        ],
      ),
    );
  }
}

/// Universal Page Content
/// Standard content container with proper padding for wallpaper visibility
class UniversalPageContent extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final bool scrollable;

  const UniversalPageContent({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(
        padding: padding ?? AppThemeUnified.pagePadding,
        child: content,
      );
    }

    return Padding(
      padding: padding ?? AppThemeUnified.pagePadding,
      child: content,
    );
  }
}

/// Universal App Bar
/// Standard app bar with consistent theming
class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const UniversalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: AppThemeUnified.textPrimary,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: Text(
        title,
        style: AppThemeUnified.headlineMedium,
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// Universal Card
/// Standard glass morphism card for wallpaper backgrounds
class UniversalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final double? borderRadius;

  const UniversalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppThemeUnified.spaceMD),
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppThemeUnified.spaceMD,
      vertical: AppThemeUnified.spaceSM,
    ),
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius = AppThemeUnified.radiusMD,
  });

  @override
  Widget build(BuildContext context) {
    return AppThemeUnified.glassCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius!,
      onTap: onTap,
      child: child,
    );
  }
}

/// Universal Section Header
/// Standard section header with icon and subtitle support
class UniversalSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const UniversalSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppThemeUnified.sectionHeader(
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: trailing,
      padding: padding,
    );
  }
}

/// Universal Bottom Navigation
/// Standard bottom navigation with glass morphism
class UniversalBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int>? onTap;
  final BottomNavigationBarType? type;

  const UniversalBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.type = BottomNavigationBarType.fixed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUnified.glassDark,
        border: Border(
          top: BorderSide(
            color: AppThemeUnified.glassBorder,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        type: type,
        selectedItemColor: AppThemeUnified.textPrimary,
        unselectedItemColor: AppThemeUnified.textTertiary,
        selectedLabelStyle: AppThemeUnified.labelSmall,
        unselectedLabelStyle: AppThemeUnified.labelSmall,
        items: items,
      ),
    );
  }
}

/// Universal Loading
/// Standard loading indicator for the app
class UniversalLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const UniversalLoading({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? AppThemeUnified.textPrimary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppThemeUnified.spaceMD),
            Text(
              message!,
              style: AppThemeUnified.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Universal Empty State
/// Standard empty state with icon and message
class UniversalEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const UniversalEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppThemeUnified.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemeUnified.glassLight,
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusLG),
                border: Border.all(
                  color: AppThemeUnified.glassBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppThemeUnified.textSecondary,
              ),
            ),
            const SizedBox(height: AppThemeUnified.spaceLG),
            Text(
              title,
              style: AppThemeUnified.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppThemeUnified.spaceSM),
              Text(
                message!,
                style: AppThemeUnified.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppThemeUnified.spaceLG),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Universal Error State
/// Standard error state with retry action
class UniversalErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryText;

  const UniversalErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return UniversalEmptyState(
      icon: Icons.error_outline,
      title: title,
      message: message,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText!),
            )
          : null,
    );
  }
}