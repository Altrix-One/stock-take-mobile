import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? tint;

  const GlassContainer(
      {super.key,
      required this.child,
      this.blur = 18,
      this.opacity = 0.15,
      this.padding = const EdgeInsets.all(12),
      this.borderRadius = const BorderRadius.all(Radius.circular(16)),
      this.tint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = tint ?? theme.colorScheme.surface;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: base.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(color: base.withOpacity(opacity + 0.05)),
            boxShadow: [
              BoxShadow(
                  color: base.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
