import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Liquid Theme System - Creates beautiful fluid/glass effects
/// Provides animated gradients, glass morphism, and liquid animations
class LiquidTheme {
  // =============================================================================
  // LIQUID COLOR PALETTES - iOS-inspired gradient combinations
  // =============================================================================
  
  static const Map<String, List<Color>> liquidPalettes = {
    // Default - Blue Ocean
    'ocean': [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFF6B73FF),
    ],
    
    // Sunset - Pink/Orange gradient
    'sunset': [
      Color(0xFFffeaa7),
      Color(0xFFfab1a0),
      Color(0xFFe17055),
    ],
    
    // Forest - Green gradient
    'forest': [
      Color(0xFF56ab2f),
      Color(0xFFa8e6cf),
      Color(0xFF4ecdc4),
    ],
    
    // Purple Dream - Purple gradient
    'purple': [
      Color(0xFF8360c3),
      Color(0xFF2ebf91),
      Color(0xFF6c5ce7),
    ],
    
    // Corporate - Professional teal/blue
    'corporate': [
      Color(0xFF1A365D), // Your existing primaryColor
      Color(0xFF00BFA6), // Your existing accentColor
      Color(0xFF4DD0E1), // Your existing accentLightColor
    ],
    
    // Rose Gold - Elegant pink/gold
    'roseGold': [
      Color(0xFFffeaa7),
      Color(0xFFfab1a0),
      Color(0xFFfd79a8),
    ],
  };

  // =============================================================================
  // GLASS MORPHISM EFFECTS
  // =============================================================================
  
  /// Creates a glass morphism decoration with blur and transparency
  static BoxDecoration glassDecoration({
    Color? color,
    double blur = 10.0,
    double opacity = 0.15,
    double borderOpacity = 0.3,
    BorderRadius? borderRadius,
    List<BoxShadow>? customShadows,
  }) {
    return BoxDecoration(
      color: color?.withOpacity(opacity) ?? Colors.white.withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: customShadows ?? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: blur / 2,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// Creates a frosted glass effect decoration
  static BoxDecoration frostedGlassDecoration({
    Color? baseColor,
    double opacity = 0.1,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: (baseColor ?? Colors.white).withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20.0,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 1.0,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // =============================================================================
  // LIQUID GRADIENT BUILDERS
  // =============================================================================
  
  /// Creates animated liquid gradient background
  static Widget liquidBackground({
    String palette = 'ocean',
    double animationSpeed = 0.02,
    List<Alignment>? customAlignments,
    List<double>? stops,
  }) {
    return AnimatedLiquidBackground(
      colors: liquidPalettes[palette] ?? liquidPalettes['ocean']!,
      animationSpeed: animationSpeed,
      alignments: customAlignments,
      stops: stops,
    );
  }

  /// Creates a static liquid gradient
  static LinearGradient staticLiquidGradient({
    String palette = 'ocean',
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    final colors = liquidPalettes[palette] ?? liquidPalettes['ocean']!;
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops ?? _generateStops(colors.length),
    );
  }

  /// Creates a radial liquid gradient
  static RadialGradient radialLiquidGradient({
    String palette = 'ocean',
    Alignment center = Alignment.center,
    double radius = 1.0,
    List<double>? stops,
  }) {
    final colors = liquidPalettes[palette] ?? liquidPalettes['ocean']!;
    return RadialGradient(
      center: center,
      radius: radius,
      colors: colors,
      stops: stops ?? _generateStops(colors.length),
    );
  }

  // =============================================================================
  // LIQUID ANIMATIONS
  // =============================================================================
  
  /// Creates a floating liquid animation effect
  static Widget floatingLiquidOrbs({
    required Widget child,
    int orbCount = 3,
    double minSize = 100,
    double maxSize = 200,
    Duration animationDuration = const Duration(seconds: 20),
  }) {
    return Stack(
      children: [
        ...List.generate(orbCount, (index) {
          return Positioned.fill(
            child: LiquidOrb(
              size: minSize + (maxSize - minSize) * (index / orbCount),
              color: liquidPalettes['ocean']![index % 3].withOpacity(0.1),
              animationDuration: animationDuration,
              delay: Duration(milliseconds: index * 2000),
            ),
          );
        }),
        child,
      ],
    );
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  static List<double> _generateStops(int colorCount) {
    if (colorCount <= 1) return [0.0];
    return List.generate(colorCount, (index) => index / (colorCount - 1));
  }

  /// Gets the primary color from a palette
  static Color getPrimaryColor(String palette) {
    final colors = liquidPalettes[palette] ?? liquidPalettes['ocean']!;
    return colors.first;
  }

  /// Gets the accent color from a palette
  static Color getAccentColor(String palette) {
    final colors = liquidPalettes[palette] ?? liquidPalettes['ocean']!;
    return colors.length > 1 ? colors[1] : colors.first;
  }
}

// =============================================================================
// ANIMATED LIQUID BACKGROUND WIDGET
// =============================================================================

class AnimatedLiquidBackground extends StatefulWidget {
  final List<Color> colors;
  final double animationSpeed;
  final List<Alignment>? alignments;
  final List<double>? stops;

  const AnimatedLiquidBackground({
    Key? key,
    required this.colors,
    this.animationSpeed = 0.02,
    this.alignments,
    this.stops,
  }) : super(key: key);

  @override
  State<AnimatedLiquidBackground> createState() => _AnimatedLiquidBackgroundState();
}

class _AnimatedLiquidBackgroundState extends State<AnimatedLiquidBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: (1 / widget.animationSpeed).round()),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.alignments != null) {
      _alignments = widget.alignments!;
    }

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _alignments[0] + Alignment(_animation.value * 0.1, 0),
              end: _alignments[1] + Alignment(0, _animation.value * 0.1),
              colors: widget.colors,
              stops: widget.stops ?? LiquidTheme._generateStops(widget.colors.length),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// LIQUID ORB WIDGET
// =============================================================================

class LiquidOrb extends StatefulWidget {
  final double size;
  final Color color;
  final Duration animationDuration;
  final Duration delay;

  const LiquidOrb({
    Key? key,
    required this.size,
    required this.color,
    this.animationDuration = const Duration(seconds: 10),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<LiquidOrb> createState() => _LiquidOrbState();
}

class _LiquidOrbState extends State<LiquidOrb>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _xAnimation = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _yAnimation = Tween<double>(
      begin: -0.2,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Apply delay before starting
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _xAnimation.value,
          top: MediaQuery.of(context).size.height * _yAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withOpacity(0.6),
                    widget.color.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}