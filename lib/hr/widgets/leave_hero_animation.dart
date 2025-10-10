import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// LeaveHeroAnimation
/// A hero-style animated grid that evokes a calendar filling/unfilling to represent leave balance.
/// Use on the Login/Welcome screen instead of the cardboard boxes Lottie.
enum LeaveHeroMode { calendar, box }

class LeaveHeroAnimation extends StatefulWidget {
  final int allocated; // total allocation in days (used only to compute ratios)
  final double used;   // used days
  final int tiles;     // number of tiles to display (e.g., 12 or 16)
  final int columns;   // grid columns (3, 4)
  final Color accent;  // brand accent color
  final Duration duration; // total duration for one reveal cycle
  final LeaveHeroMode mode; // visual silhouette to resolve into
  final List<IconData>? icons; // optional icon set to cycle on tiles

  const LeaveHeroAnimation({
    super.key,
    required this.allocated,
    required this.used,
    this.tiles = 12,
    this.columns = 4,
    required this.accent,
    this.duration = const Duration(milliseconds: 2200),
    this.mode = LeaveHeroMode.calendar,
    this.icons,
  });

  @override
  State<LeaveHeroAnimation> createState() => _LeaveHeroAnimationState();
}

class _LeaveHeroAnimationState extends State<LeaveHeroAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int get _filledTiles {
    final remaining = max(0.0, widget.allocated - widget.used);
    final ratio = widget.allocated <= 0 ? 0.0 : (remaining / widget.allocated).clamp(0.0, 1.0);
    return (ratio * widget.tiles).round();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // loop continuously to mimic stacking animation
  }

  @override
  void didUpdateWidget(covariant LeaveHeroAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.used != widget.used || oldWidget.allocated != widget.allocated ||
        oldWidget.tiles != widget.tiles || oldWidget.columns != widget.columns) {
      _controller
        ..stop()
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.columns;
    final rows = (widget.tiles / cols).ceil();
    final bg = Theme.of(context).colorScheme.surface;
    final accent = widget.accent;
    final onBg = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.mode == LeaveHeroMode.calendar ? Icons.calendar_month_rounded : Icons.inventory_2_outlined, color: accent, size: 22),
        const SizedBox(width: 8),
        Text('Leave Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );

    Widget grid = AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final gap = 8.0;
            final w = (constraints.maxWidth - (gap * (cols - 1))) / cols;
            final h = (constraints.maxHeight - (gap * (rows - 1))) / rows;
            final size = min(w, h);

            // We want tiles to "stack" from bottom row upwards, like boxes falling into a stack.
            // Create an index order that starts at the bottom-left and proceeds row-wise upwards.
            List<int> order = [];
            for (int r = rows - 1; r >= 0; r--) {
              for (int c = 0; c < cols; c++) {
                final idx = r * cols + c;
                if (idx < widget.tiles) order.add(idx);
              }
            }

            const dropDur = 0.45;   // portion of cycle spent on drop per tile
            const holdDur = 0.25;   // hold visible
            const fadeDur = 0.20;   // fade away before next cycle
            final cycle = dropDur + holdDur + fadeDur; // < 1.0 leaves some idle per tile
            final stagger = (1.0 - cycle) / max(1, widget.tiles); // spread across timeline

            // Icon set to cycle
            final defaultIcons = <IconData>[
              Icons.calendar_month_rounded,
              Icons.access_time_rounded,
              Icons.badge_outlined,
              Icons.diversity_3_outlined,
              Icons.fact_check_outlined,
              Icons.verified_outlined,
              Icons.task_alt_outlined,
              Icons.receipt_long_outlined,
              Icons.edit_calendar_outlined,
              Icons.event_available_outlined,
              Icons.co_present_outlined,
              Icons.beenhere_outlined,
            ];
            final iconPool = (widget.icons != null && widget.icons!.isNotEmpty) ? widget.icons! : defaultIcons;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(widget.tiles, (renderIndex) {
                final i = order[renderIndex];
                // local time for this tile within the looping controller value [0,1)
                final g = _controller.value; // 0..1
                final delay = renderIndex * stagger; // increasing delay so tiles stack
                double t = g - delay;
                if (t < 0) t += 1.0; // wrap around

                double opacity = 0.0;
                double translateY = -size * 1.6; // start above
                double scale = 0.85;

                if (t < dropDur) {
                  // Drop-in with a little bounce
                  final p = Curves.easeOutBack.transform((t / dropDur).clamp(0.0, 1.0));
                  translateY = lerpDouble(-size * 1.6, 0.0, p)!;
                  opacity = lerpDouble(0.0, 1.0, p)!;
                  scale = lerpDouble(0.9, 1.0, p)!;
                } else if (t < dropDur + holdDur) {
                  opacity = 1.0;
                  translateY = 0.0;
                  scale = 1.0;
                } else if (t < dropDur + holdDur + fadeDur) {
                  final p = ((t - dropDur - holdDur) / fadeDur).clamp(0.0, 1.0);
                  opacity = lerpDouble(1.0, 0.0, Curves.easeIn.transform(p))!;
                  translateY = lerpDouble(0.0, size * 0.3, p)!; // subtle sink
                  scale = lerpDouble(1.0, 0.95, p)!;
                } else {
                  opacity = 0.0;
                }
                // Ensure valid opacity range
                opacity = opacity.clamp(0.0, 1.0);

                final isRemaining = i < _filledTiles; // color mapping (remaining vs used)
                final color = isRemaining ? accent.withOpacity(0.85) : accent.withOpacity(0.18);
                final border = isRemaining ? accent.withOpacity(0.55) : accent.withOpacity(0.35);

                // Per-tile icon and rotation for character
                final icon = iconPool[renderIndex % iconPool.length];
                double rot = 0.0;
                if (t < dropDur) {
                  rot = lerpDouble(-0.35, 0.0, Curves.easeOutBack.transform((t / dropDur).clamp(0.0, 1.0)))!;
                } else if (t < dropDur + holdDur) {
                  rot = 0.0;
                } else if (t < dropDur + holdDur + fadeDur) {
                  rot = lerpDouble(0.0, 0.1, ((t - dropDur - holdDur) / fadeDur).clamp(0.0, 1.0))!;
                }

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Color.lerp(color, bg.withOpacity(0.5), 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border, width: 1),
                          boxShadow: [
                            BoxShadow(color: accent.withOpacity(0.1), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Stack(children: [
                          // Calendar nubs
                          if (widget.mode == LeaveHeroMode.calendar) ...[
                            Positioned(top: 6, left: 8, child: _nub(isRemaining ? Colors.white : onBg)),
                            Positioned(top: 6, right: 8, child: _nub(isRemaining ? Colors.white : onBg)),
                          ],
                          // Icon in the tile
                          Center(
                            child: Transform.rotate(
                              angle: rot,
                              child: Icon(
                                icon,
                                size: size * 0.55,
                                color: isRemaining
                                    ? Colors.white.withOpacity(0.95)
                                    : onBg.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );

    final gridHeight = rows * 30 + (rows - 1) * 8;
    Widget composed = SizedBox(height: gridHeight, child: grid);

    // Foreground silhouette painter (calendar or box) for WOW moment
    final overlayOpacity = (() {
      final g = _controller.value;
      // After last tile mostly settled, show silhouette briefly
      return (g > 0.75 && g < 0.95) ? ((g - 0.75) / 0.20).clamp(0.0, 1.0) : 0.0;
    })();

    composed = Stack(
      alignment: Alignment.center,
      children: [
        composed,
        IgnorePointer(
          child: Opacity(
            opacity: overlayOpacity,
            child: CustomPaint(
              size: Size(double.infinity, gridHeight.toDouble()),
              painter: _SilhouettePainter(mode: widget.mode, color: accent.withOpacity(0.75)),
            ),
          ),
        ),
      ],
    );

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: 14),
          composed,
          const SizedBox(height: 6),
          Text(
            '${(widget.allocated - widget.used).clamp(0, widget.allocated).toStringAsFixed(1)} remaining of ${widget.allocated}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onBg),
          )
        ],
      ),
    );
  }

  Widget _nub(Color color) {
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _SilhouettePainter extends CustomPainter {
  final LeaveHeroMode mode;
  final Color color;
  _SilhouettePainter({required this.mode, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final w = rect.width;
    final h = rect.height;

    if (mode == LeaveHeroMode.calendar) {
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.02, h * 0.02, w * 0.96, h * 0.96), const Radius.circular(16));
      canvas.drawRRect(r, paint);
      // Header bar
      canvas.drawLine(Offset(w * 0.02, h * 0.20), Offset(w * 0.98, h * 0.20), paint);
      // Binder rings
      final ringPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.15, h * 0.12), 4, ringPaint);
      canvas.drawCircle(Offset(w * 0.85, h * 0.12), 4, ringPaint);
    } else {
      // Simple 3D-ish box silhouette
      final base = Path()
        ..moveTo(w * 0.1, h * 0.25)
        ..lineTo(w * 0.9, h * 0.25)
        ..lineTo(w * 0.75, h * 0.85)
        ..lineTo(w * 0.25, h * 0.85)
        ..close();
      canvas.drawPath(base, paint);
      final lid = Path()
        ..moveTo(w * 0.1, h * 0.25)
        ..lineTo(w * 0.25, h * 0.02)
        ..lineTo(w * 0.9, h * 0.02)
        ..lineTo(w * 0.9, h * 0.25);
      canvas.drawPath(lid, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.color != color;
  }
}
