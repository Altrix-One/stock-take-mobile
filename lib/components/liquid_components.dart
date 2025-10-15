import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/liquid_theme.dart';

/// Liquid UI Components - Reusable components with glass morphism and liquid effects
/// Provides LiquidCard, LiquidButton, LiquidContainer, and other liquid-style widgets

// =============================================================================
// LIQUID CARD - Glass morphism card with liquid effects
// =============================================================================

class LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double opacity;
  final double borderRadius;
  final double blur;
  final VoidCallback? onTap;
  final bool animated;
  final String? liquidPalette;

  const LiquidCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.opacity = 0.15,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.onTap,
    this.animated = false,
    this.liquidPalette,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );

    if (animated && liquidPalette != null) {
      card = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LiquidTheme.staticLiquidGradient(palette: liquidPalette!),
        ),
        child: Container(
          margin: const EdgeInsets.all(1.0),
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: LiquidTheme.glassDecoration(
            color: backgroundColor,
            opacity: opacity,
            borderRadius: BorderRadius.circular(borderRadius - 1),
            blur: blur,
          ),
          child: child,
        ),
      );
    } else {
      card = Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: LiquidTheme.glassDecoration(
          color: backgroundColor,
          opacity: opacity,
          borderRadius: BorderRadius.circular(borderRadius),
          blur: blur,
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// =============================================================================
// LIQUID BUTTON - Animated button with liquid effects
// =============================================================================

class LiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String liquidPalette;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final bool animateOnTap;

  const LiquidButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.liquidPalette = 'ocean',
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.animateOnTap = true,
  }) : super(key: key);

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.animateOnTap && widget.onPressed != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.animateOnTap) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.animateOnTap) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LiquidTheme.staticLiquidGradient(
                  palette: widget.liquidPalette,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LiquidTheme.getPrimaryColor(widget.liquidPalette)
                        .withOpacity(0.3),
                    blurRadius: widget.elevation * 2,
                    offset: Offset(0, widget.elevation),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// LIQUID CONTAINER - Versatile container with liquid background
// =============================================================================

class LiquidContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String liquidPalette;
  final bool animated;
  final double borderRadius;
  final double opacity;
  final bool useGradientBackground;
  final bool useGlassEffect;

  const LiquidContainer({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.liquidPalette = 'ocean',
    this.animated = true,
    this.borderRadius = 16.0,
    this.opacity = 0.2,
    this.useGradientBackground = true,
    this.useGlassEffect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      child: child,
    );

    if (useGradientBackground && animated) {
      container = Stack(
        children: [
          // Animated liquid background
          Container(
            width: width,
            height: height,
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LiquidTheme.liquidBackground(
                palette: liquidPalette,
                animationSpeed: 0.02,
              ),
            ),
          ),
          // Glass overlay with content
          if (useGlassEffect)
            Container(
              width: width,
              height: height,
              margin: margin,
              padding: padding,
              decoration: LiquidTheme.glassDecoration(
                opacity: opacity,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            )
          else
            Container(
              width: width,
              height: height,
              margin: margin,
              padding: padding,
              child: child,
            ),
        ],
      );
    } else if (useGradientBackground) {
      container = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LiquidTheme.staticLiquidGradient(palette: liquidPalette),
        ),
        child: child,
      );
    } else if (useGlassEffect) {
      container = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: LiquidTheme.glassDecoration(
          opacity: opacity,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      );
    }

    return container;
  }
}

// =============================================================================
// LIQUID FLOATING ACTION BUTTON
// =============================================================================

class LiquidFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String liquidPalette;
  final double elevation;
  final bool mini;
  final String? heroTag;

  const LiquidFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.liquidPalette = 'ocean',
    this.elevation = 6.0,
    this.mini = false,
    this.heroTag,
  }) : super(key: key);

  @override
  State<LiquidFloatingActionButton> createState() =>
      _LiquidFloatingActionButtonState();
}

class _LiquidFloatingActionButtonState extends State<LiquidFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.mini ? 40.0 : 56.0;

    return Hero(
      tag: widget.heroTag ?? 'liquidFab',
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LiquidTheme.staticLiquidGradient(
                    palette: widget.liquidPalette,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LiquidTheme.getPrimaryColor(widget.liquidPalette)
                          .withOpacity(0.4),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ],
                ),
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// LIQUID BOTTOM NAVIGATION BAR
// =============================================================================

class LiquidBottomNavigationBar extends StatelessWidget {
  final List<LiquidBottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final String liquidPalette;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsetsGeometry margin;

  const LiquidBottomNavigationBar({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.liquidPalette = 'ocean',
    this.backgroundColor,
    this.elevation = 8.0,
    this.margin = const EdgeInsets.fromLTRB(12, 0, 12, 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: LiquidTheme.glassDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(24),
        blur: 20.0,
        customShadows: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: elevation * 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                return _LiquidBottomNavItem(
                  item: items[index],
                  isSelected: index == currentIndex,
                  liquidPalette: liquidPalette,
                  onTap: () => onTap?.call(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidBottomNavigationBarItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  const LiquidBottomNavigationBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _LiquidBottomNavItem extends StatefulWidget {
  final LiquidBottomNavigationBarItem item;
  final bool isSelected;
  final String liquidPalette;
  final VoidCallback? onTap;

  const _LiquidBottomNavItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.liquidPalette,
    this.onTap,
  }) : super(key: key);

  @override
  State<_LiquidBottomNavItem> createState() => _LiquidBottomNavItemState();
}

class _LiquidBottomNavItemState extends State<_LiquidBottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_LiquidBottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: widget.isSelected
                  ? BoxDecoration(
                      gradient: LiquidTheme.staticLiquidGradient(
                        palette: widget.liquidPalette,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: widget.isSelected && widget.item.activeIcon != null
                        ? widget.item.activeIcon!
                        : widget.item.icon,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// LIQUID APP BAR
// =============================================================================

class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final String liquidPalette;
  final double elevation;
  final bool centerTitle;

  const LiquidAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.liquidPalette = 'ocean',
    this.elevation = 0.0,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LiquidTheme.staticLiquidGradient(palette: liquidPalette),
      ),
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        centerTitle: centerTitle,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
