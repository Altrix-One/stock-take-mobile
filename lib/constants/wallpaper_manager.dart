import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

/// Wallpaper Manager - Manages iOS-style wallpapers and backgrounds
/// Provides dynamic wallpapers, particle effects, and blur effects
class WallpaperManager {
  static const String _wallpaperKey = 'selected_wallpaper';
  static const String _effectsKey = 'wallpaper_effects_enabled';

  // =============================================================================
  // iOS-STYLE WALLPAPER DEFINITIONS
  // =============================================================================

  static const Map<String, WallpaperDefinition> wallpapers = {
    'default': WallpaperDefinition(
      name: 'Default Ocean',
      type: WallpaperType.gradient,
      colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
      animated: true,
    ),
    'royal_ocean_blue': WallpaperDefinition(
      name: 'Royal & Ocean Blue',
      type: WallpaperType.gradient,
      colors: [Color(0xFF1436AC), Color(0xFF1483EB), Color(0xFF1436AC)],
      animated: true,
      particleEffect: ParticleEffectType.subtle,
    ),
    'ios_blue': WallpaperDefinition(
      name: 'iOS Blue',
      type: WallpaperType.gradient,
      colors: [Color(0xFF007AFF), Color(0xFF5856D6), Color(0xFFAF52DE)],
      animated: true,
      particleEffect: ParticleEffectType.floating,
    ),
    'ios_green': WallpaperDefinition(
      name: 'iOS Green',
      type: WallpaperType.gradient,
      colors: [Color(0xFF34C759), Color(0xFF30D158), Color(0xFF00C7BE)],
      animated: true,
      particleEffect: ParticleEffectType.bubbles,
    ),
    'ios_purple': WallpaperDefinition(
      name: 'iOS Purple',
      type: WallpaperType.gradient,
      colors: [Color(0xFF5856D6), Color(0xFFAF52DE), Color(0xFFBF5AF2)],
      animated: true,
      particleEffect: ParticleEffectType.stars,
    ),
    'aurora': WallpaperDefinition(
      name: 'Aurora',
      type: WallpaperType.aurora,
      colors: [
        Color(0xFF00F5FF),
        Color(0xFF00D4AA),
        Color(0xFFFF6B6B),
        Color(0xFF4ECDC4),
      ],
      animated: true,
      particleEffect: ParticleEffectType.floating,
    ),
    'sunset': WallpaperDefinition(
      name: 'Sunset',
      type: WallpaperType.gradient,
      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFFFF6B9D)],
      animated: true,
    ),
    'dark_elegance': WallpaperDefinition(
      name: 'Dark Elegance',
      type: WallpaperType.gradient,
      colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF4A6741)],
      animated: false,
      isDark: true,
    ),
    'corporate_teal': WallpaperDefinition(
      name: 'Corporate Teal',
      type: WallpaperType.gradient,
      colors: [Color(0xFF1A365D), Color(0xFF00BFA6), Color(0xFF4DD0E1)],
      animated: true,
      particleEffect: ParticleEffectType.subtle,
    ),
  };

  // =============================================================================
  // WALLPAPER MANAGEMENT
  // =============================================================================

  static Future<String> getCurrentWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wallpaperKey) ?? 'royal_ocean_blue';
  }

  static Future<void> setWallpaper(String wallpaperKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperKey, wallpaperKey);
  }

  static Future<bool> areEffectsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_effectsKey) ?? true;
  }

  static Future<void> setEffectsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_effectsKey, enabled);
  }

  // =============================================================================
  // WALLPAPER WIDGET BUILDERS
  // =============================================================================

  /// Creates a wallpaper widget from wallpaper definition
  static Widget createWallpaper(WallpaperDefinition definition,
      {bool effectsEnabled = true}) {
    switch (definition.type) {
      case WallpaperType.gradient:
        return _createGradientWallpaper(definition, effectsEnabled);
      case WallpaperType.aurora:
        return _createAuroraWallpaper(definition, effectsEnabled);
      case WallpaperType.mesh:
        return _createMeshWallpaper(definition, effectsEnabled);
    }
  }

  /// Creates a wallpaper from key
  static Widget fromKey(String key, {bool effectsEnabled = true}) {
    print('🎨 WallpaperManager: Loading wallpaper key: $key');
    final definition = wallpapers[key] ?? wallpapers['royal_ocean_blue']!;
    print(
        '🎨 WallpaperManager: Using definition: ${definition.name} with colors: ${definition.colors}');
    return createWallpaper(definition, effectsEnabled: effectsEnabled);
  }

  // =============================================================================
  // PRIVATE WALLPAPER BUILDERS
  // =============================================================================

  static Widget _createGradientWallpaper(
      WallpaperDefinition definition, bool effectsEnabled) {
    Widget wallpaper;

    if (definition.animated && effectsEnabled) {
      wallpaper = AnimatedGradientWallpaper(
        colors: definition.colors,
        animationSpeed: 0.03,
      );
    } else {
      wallpaper = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: definition.colors,
          ),
        ),
      );
    }

    if (definition.particleEffect != null && effectsEnabled) {
      wallpaper = Stack(
        children: [
          wallpaper,
          ParticleEffectWidget(
            type: definition.particleEffect!,
            colors: definition.colors,
          ),
        ],
      );
    }

    return wallpaper;
  }

  static Widget _createAuroraWallpaper(
      WallpaperDefinition definition, bool effectsEnabled) {
    return AuroraWallpaper(
      colors: definition.colors,
      animated: definition.animated && effectsEnabled,
    );
  }

  static Widget _createMeshWallpaper(
      WallpaperDefinition definition, bool effectsEnabled) {
    return MeshGradientWallpaper(
      colors: definition.colors,
      animated: definition.animated && effectsEnabled,
    );
  }
}

// =============================================================================
// WALLPAPER DEFINITION CLASSES
// =============================================================================

class WallpaperDefinition {
  final String name;
  final WallpaperType type;
  final List<Color> colors;
  final bool animated;
  final ParticleEffectType? particleEffect;
  final bool isDark;

  const WallpaperDefinition({
    required this.name,
    required this.type,
    required this.colors,
    this.animated = false,
    this.particleEffect,
    this.isDark = false,
  });
}

enum WallpaperType {
  gradient,
  aurora,
  mesh,
}

enum ParticleEffectType {
  floating,
  bubbles,
  stars,
  subtle,
}

// =============================================================================
// ANIMATED GRADIENT WALLPAPER
// =============================================================================

class AnimatedGradientWallpaper extends StatefulWidget {
  final List<Color> colors;
  final double animationSpeed;

  const AnimatedGradientWallpaper({
    Key? key,
    required this.colors,
    this.animationSpeed = 0.02,
  }) : super(key: key);

  @override
  State<AnimatedGradientWallpaper> createState() =>
      _AnimatedGradientWallpaperState();
}

class _AnimatedGradientWallpaperState extends State<AnimatedGradientWallpaper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: (1 / widget.animationSpeed * 100).round()),
      vsync: this,
    );

    _animation1 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation2 = Tween<double>(
      begin: 0.0,
      end: 4 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

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
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft +
                  Alignment(math.sin(_animation1.value) * 0.3,
                      math.cos(_animation1.value) * 0.2),
              end: Alignment.bottomRight +
                  Alignment(math.cos(_animation2.value) * 0.2,
                      math.sin(_animation2.value) * 0.3),
              colors: widget.colors,
              stops: _generateStops(widget.colors.length),
            ),
          ),
        );
      },
    );
  }

  List<double> _generateStops(int colorCount) {
    if (colorCount <= 1) return [0.0];
    return List.generate(colorCount, (index) => index / (colorCount - 1));
  }
}

// =============================================================================
// AURORA WALLPAPER
// =============================================================================

class AuroraWallpaper extends StatefulWidget {
  final List<Color> colors;
  final bool animated;

  const AuroraWallpaper({
    Key? key,
    required this.colors,
    this.animated = true,
  }) : super(key: key);

  @override
  State<AuroraWallpaper> createState() => _AuroraWallpaperState();
}

class _AuroraWallpaperState extends State<AuroraWallpaper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _waveAnimations;

  @override
  void initState() {
    super.initState();

    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(seconds: 15),
        vsync: this,
      );

      _waveAnimations = List.generate(widget.colors.length, (index) {
        return Tween<double>(
          begin: 0.0,
          end: 2 * math.pi,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.colors.length,
            (index + 1) / widget.colors.length,
            curve: Curves.easeInOut,
          ),
        ));
      });

      _controller.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animated) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.colors,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AuroraPainter(
            colors: widget.colors,
            animations: _waveAnimations,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// =============================================================================
// AURORA PAINTER
// =============================================================================

class AuroraPainter extends CustomPainter {
  final List<Color> colors;
  final List<Animation<double>> animations;

  AuroraPainter({
    required this.colors,
    required this.animations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final path = Path();
      final amplitude = size.height * 0.3;
      final frequency = 2 + i * 0.5;
      final phase = animations[i].value;

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.5 +
            amplitude *
                math.sin((x / size.width) * frequency * math.pi + phase) *
                math.exp(-x / size.width);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// MESH GRADIENT WALLPAPER
// =============================================================================

class MeshGradientWallpaper extends StatefulWidget {
  final List<Color> colors;
  final bool animated;

  const MeshGradientWallpaper({
    Key? key,
    required this.colors,
    this.animated = true,
  }) : super(key: key);

  @override
  State<MeshGradientWallpaper> createState() => _MeshGradientWallpaperState();
}

class _MeshGradientWallpaperState extends State<MeshGradientWallpaper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(seconds: 20),
        vsync: this,
      );
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animated) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 2.0,
            colors: widget.colors,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MeshGradientPainter(
            colors: widget.colors,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// =============================================================================
// MESH GRADIENT PAINTER
// =============================================================================

class MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  MeshGradientPainter({
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    for (int i = 0; i < colors.length; i++) {
      final center = Offset(
        size.width * 0.5 +
            math.sin(animationValue * 2 * math.pi + i) * size.width * 0.3,
        size.height * 0.5 +
            math.cos(animationValue * 2 * math.pi + i) * size.height * 0.3,
      );

      final gradient = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: 1.5,
        colors: [
          colors[i].withOpacity(0.8),
          colors[i].withOpacity(0.0),
        ],
      );

      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// PARTICLE EFFECT WIDGET
// =============================================================================

class ParticleEffectWidget extends StatefulWidget {
  final ParticleEffectType type;
  final List<Color> colors;

  const ParticleEffectWidget({
    Key? key,
    required this.type,
    required this.colors,
  }) : super(key: key);

  @override
  State<ParticleEffectWidget> createState() => _ParticleEffectWidgetState();
}

class _ParticleEffectWidgetState extends State<ParticleEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    particles = _generateParticles();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Particle> _generateParticles() {
    final particleCount = _getParticleCount();
    return List.generate(particleCount, (index) {
      return Particle(
        color: widget.colors[index % widget.colors.length],
        type: widget.type,
        delay: Duration(milliseconds: index * 500),
      );
    });
  }

  int _getParticleCount() {
    switch (widget.type) {
      case ParticleEffectType.floating:
        return 15;
      case ParticleEffectType.bubbles:
        return 25;
      case ParticleEffectType.stars:
        return 30;
      case ParticleEffectType.subtle:
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// =============================================================================
// PARTICLE AND PAINTER CLASSES
// =============================================================================

class Particle {
  final Color color;
  final ParticleEffectType type;
  final Duration delay;
  late final double x;
  late final double y;
  late final double size;
  late final double speed;

  Particle({
    required this.color,
    required this.type,
    required this.delay,
  }) {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = _getSize();
    speed = _getSpeed();
  }

  double _getSize() {
    switch (type) {
      case ParticleEffectType.floating:
        return 20 + math.Random().nextDouble() * 40;
      case ParticleEffectType.bubbles:
        return 10 + math.Random().nextDouble() * 30;
      case ParticleEffectType.stars:
        return 3 + math.Random().nextDouble() * 8;
      case ParticleEffectType.subtle:
        return 30 + math.Random().nextDouble() * 60;
    }
  }

  double _getSpeed() {
    switch (type) {
      case ParticleEffectType.floating:
        return 0.1 + math.Random().nextDouble() * 0.2;
      case ParticleEffectType.bubbles:
        return 0.2 + math.Random().nextDouble() * 0.3;
      case ParticleEffectType.stars:
        return 0.05 + math.Random().nextDouble() * 0.1;
      case ParticleEffectType.subtle:
        return 0.03 + math.Random().nextDouble() * 0.08;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = (animationValue * particle.speed) % 1.0;
      final x = size.width * particle.x;
      final y = size.height * (particle.y + progress) % size.height;

      final paint = Paint()
        ..color = particle.color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      switch (particle.type) {
        case ParticleEffectType.floating:
        case ParticleEffectType.bubbles:
        case ParticleEffectType.subtle:
          canvas.drawCircle(
            Offset(x, y),
            particle.size,
            paint,
          );
          break;
        case ParticleEffectType.stars:
          _drawStar(canvas, Offset(x, y), particle.size, paint);
          break;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final angle = (2 * math.pi) / 5;

    for (int i = 0; i < 5; i++) {
      final x = center.dx + size * math.cos(i * angle - math.pi / 2);
      final y = center.dy + size * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
