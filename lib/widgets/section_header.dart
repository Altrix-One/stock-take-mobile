import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/modern_design_system.dart';

enum SectionHeaderStyle {
  standard,
  prominent,
  subtle,
  divider,
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final SectionHeaderStyle style;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? iconColor;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.style = SectionHeaderStyle.standard,
    this.padding,
    this.margin,
    this.iconColor,
    this.onActionTap,
  });

  // Convenience constructors for common patterns
  const SectionHeader.prominent({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
    this.margin,
    this.iconColor,
    this.onActionTap,
  }) : style = SectionHeaderStyle.prominent;

  const SectionHeader.subtle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
    this.margin,
    this.iconColor,
    this.onActionTap,
  }) : style = SectionHeaderStyle.subtle;

  const SectionHeader.withDivider({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
    this.margin,
    this.iconColor,
    this.onActionTap,
  }) : style = SectionHeaderStyle.divider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate text styles based on style
    TextStyle titleStyle;
    TextStyle? subtitleStyle;
    EdgeInsetsGeometry paddingValue;
    EdgeInsetsGeometry marginValue;

    switch (style) {
      case SectionHeaderStyle.standard:
        titleStyle = titleLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        );
        subtitleStyle = bodySmall.copyWith(color: textSecondaryColor);
        paddingValue = padding ??
            const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS);
        marginValue = margin ?? EdgeInsets.zero;
        break;

      case SectionHeaderStyle.prominent:
        titleStyle = headlineSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: textPrimaryColor,
        );
        subtitleStyle = bodyMedium.copyWith(color: textSecondaryColor);
        paddingValue = padding ??
            const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceSM);
        marginValue =
            margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceXS);
        break;

      case SectionHeaderStyle.subtle:
        titleStyle = titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: textSecondaryColor,
        );
        subtitleStyle = bodySmall.copyWith(color: textTertiaryColor);
        paddingValue = padding ??
            const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS);
        marginValue = margin ?? EdgeInsets.zero;
        break;

      case SectionHeaderStyle.divider:
        titleStyle = titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        );
        subtitleStyle = bodySmall.copyWith(color: textSecondaryColor);
        paddingValue = padding ??
            const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS);
        marginValue = margin ??
            const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS);
        break;
    }

    Widget headerContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(paddingXS),
            decoration: BoxDecoration(
              color: (iconColor ?? accentColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? accentColor,
            ),
          ),
          widthSpaceMD,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              if (subtitle != null) ...[
                heightSpaceXS,
                Text(subtitle!, style: subtitleStyle),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          widthSpaceMD,
          GestureDetector(
            onTap: onActionTap,
            child: action!,
          ),
        ],
      ],
    );

    Widget result = Container(
      padding: paddingValue,
      margin: marginValue,
      child: headerContent,
    );

    // Add divider for divider style
    if (style == SectionHeaderStyle.divider) {
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          result,
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dividerColor.withOpacity(0),
                  dividerColor,
                  dividerColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}

// Specialized section headers for common use cases
class CountSectionHeader extends SectionHeader {
  final int count;
  final Color? countColor;

  CountSectionHeader({
    super.key,
    required super.title,
    required this.count,
    this.countColor,
    super.subtitle,
    super.icon,
    super.style = SectionHeaderStyle.standard,
    super.padding,
    super.margin,
    super.iconColor,
    super.onActionTap,
  }) : super(
          action: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingSM,
              vertical: paddingXS,
            ),
            decoration: BoxDecoration(
              color: (countColor ?? accentColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusRound),
              border: Border.all(
                color: (countColor ?? accentColor).withOpacity(0.2),
              ),
            ),
            child: Text(
              count.toString(),
              style: labelMedium.copyWith(
                color: countColor ?? accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
}

class ActionSectionHeader extends SectionHeader {
  final String actionText;
  final IconData? actionIcon;

  ActionSectionHeader({
    super.key,
    required super.title,
    required this.actionText,
    this.actionIcon,
    super.subtitle,
    super.icon,
    super.style = SectionHeaderStyle.standard,
    super.padding,
    super.margin,
    super.iconColor,
    required super.onActionTap,
  }) : super(
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionText,
                style: labelMedium.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (actionIcon != null) ...[
                widthSpaceXS,
                Icon(
                  actionIcon,
                  size: 16,
                  color: accentColor,
                ),
              ],
            ],
          ),
        );
}

class StatusSectionHeader extends SectionHeader {
  final String status;
  final Color statusColor;

  StatusSectionHeader({
    super.key,
    required super.title,
    required this.status,
    required this.statusColor,
    super.subtitle,
    super.icon,
    super.style = SectionHeaderStyle.standard,
    super.padding,
    super.margin,
    super.iconColor,
    super.onActionTap,
  }) : super(
          action: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingSM,
              vertical: paddingXS,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusRound),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                widthSpaceXS,
                Text(
                  status.toUpperCase(),
                  style: labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
}
