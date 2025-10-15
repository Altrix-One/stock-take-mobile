import 'package:flutter/material.dart';
import '../constants/theme.dart';

enum CardStyle {
  elevated,
  outlined,
  filled,
  glass,
}

class ProfessionalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final CardStyle style;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? customShadows;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? header;
  final Widget? footer;

  const ProfessionalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.style = CardStyle.elevated,
    this.backgroundColor,
    this.borderColor,
    this.customShadows,
    this.onTap,
    this.isSelected = false,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate colors based on style
    Color bgColor;
    Color? bColor;
    List<BoxShadow>? shadows;

    switch (style) {
      case CardStyle.elevated:
        bgColor =
            backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : whiteColor);
        shadows = customShadows ??
            [
              BoxShadow(
                color: shadowMediumColor,
                blurRadius: elevationLG,
                offset: const Offset(0, elevationSM),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: shadowLightColor,
                blurRadius: elevationMD,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ];
        break;

      case CardStyle.outlined:
        bgColor =
            backgroundColor ?? (isDark ? const Color(0xFF1A1A1A) : whiteColor);
        bColor = borderColor ?? (isDark ? borderMediumColor : borderLightColor);
        shadows = null;
        break;

      case CardStyle.filled:
        bgColor = backgroundColor ??
            (isDark ? const Color(0xFF2A2A2A) : surfaceColor);
        shadows = null;
        break;

      case CardStyle.glass:
        bgColor = backgroundColor ?? glassColor;
        bColor = borderColor ?? glassBorderColor;
        shadows = customShadows ??
            [
              BoxShadow(
                color: shadowLightColor,
                blurRadius: elevationMD,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ];
        break;
    }

    // Apply selection highlight
    if (isSelected) {
      bgColor = accentColor.withOpacity(0.08);
      bColor = accentColor;
    }

    final borderRadiusValue = borderRadius ?? radiusLG;
    final paddingValue = padding ?? const EdgeInsets.all(paddingLG);
    final marginValue = margin ?? EdgeInsets.zero;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header!,
          const Divider(height: 1, thickness: 0.5),
          heightSpaceSM,
        ],
        child,
        if (footer != null) ...[
          heightSpaceSM,
          const Divider(height: 1, thickness: 0.5),
          footer!,
        ],
      ],
    );

    Widget card = Container(
      margin: marginValue,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        border: bColor != null ? Border.all(color: bColor, width: 1) : null,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                  child: Padding(
                    padding: paddingValue,
                    child: content,
                  ),
                )
              : Padding(
                  padding: paddingValue,
                  child: content,
                ),
        ),
      ),
    );

    return card;
  }
}

// Specialized card variants
class StatusCard extends ProfessionalCard {
  final String status;
  final Color? statusColor;

  StatusCard({
    super.key,
    required super.child,
    required this.status,
    this.statusColor,
    super.padding,
    super.margin,
    super.onTap,
  }) : super(
          style: CardStyle.outlined,
          borderColor: statusColor,
          header: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: paddingSM, vertical: paddingXS),
            decoration: BoxDecoration(
              color: (statusColor ?? accentColor).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(radiusSM),
                topRight: Radius.circular(radiusSM),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor ?? accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                widthSpaceXS,
                Text(
                  status.toUpperCase(),
                  style: labelSmall.copyWith(
                    color: statusColor ?? accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
}

class ActionCard extends ProfessionalCard {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required super.onTap,
    super.padding = const EdgeInsets.all(paddingMD),
  }) : super(
          style: CardStyle.elevated,
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? accentColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(radiusSM),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? accentColor,
                    size: 20,
                  ),
                ),
                widthSpaceMD,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleMedium),
                    if (subtitle != null) ...[
                      heightSpaceXS,
                      Text(subtitle!, style: bodySmall),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: textTertiaryColor),
            ],
          ),
        );
}
