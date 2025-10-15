import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/modern_design_system.dart';
import 'modern_ui_components.dart';

/// Modern Action Card - For quick actions with icons
class ModernActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isDestructive;
  final bool showArrow;
  final EdgeInsets? margin;

  const ModernActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.color,
    this.isDestructive = false,
    this.showArrow = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final actionColor = isDestructive
        ? ModernDesignSystem.error
        : (color ?? ModernDesignSystem.primaryTeal);

    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
      decoration: BoxDecoration(
        // Glass morphism effect - much more transparent
        color: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
              child: Padding(
                padding:
                    const EdgeInsets.all(ModernDesignSystem.spaceCompactMD),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
                      decoration: BoxDecoration(
                        color: brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(ModernDesignSystem.radiusSM),
                        border: Border.all(
                          color: brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: actionColor,
                        size: 20,
                      ),
                    ),
                    ModernDesignSystem.horizontalSpaceXS,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style:
                                ModernDesignSystem.bodyCompactMedium.copyWith(
                              color: isDestructive
                                  ? ModernDesignSystem.error
                                  : ModernDesignSystem.getTextPrimary(
                                      brightness),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: ModernDesignSystem.captionCompact.copyWith(
                                color: ModernDesignSystem.getTextSecondary(
                                    brightness),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showArrow && onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: ModernDesignSystem.getTextTertiary(brightness),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Stats Card - For displaying key metrics
class ModernStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isCompact;

  const ModernStatsCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = color ?? ModernDesignSystem.primaryTeal;

    return Container(
      decoration: BoxDecoration(
        // Glass morphism effect - much more transparent
        color: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
              child: Padding(
                padding: EdgeInsets.all(isCompact
                    ? ModernDesignSystem.spaceCompactMD
                    : ModernDesignSystem.spaceMD),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(ModernDesignSystem.spaceXS),
                          decoration: BoxDecoration(
                            color: brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusXS),
                            border: Border.all(
                              color: brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: cardColor,
                            size: isCompact ? 16 : 20,
                          ),
                        ),
                        const Spacer(),
                        if (onTap != null)
                          Icon(
                            Icons.more_horiz,
                            size: 16,
                            color:
                                ModernDesignSystem.getTextTertiary(brightness),
                          ),
                      ],
                    ),
                    ModernDesignSystem.verticalSpaceMD,
                    Text(
                      value,
                      style: isCompact
                          ? ModernDesignSystem.headlineCompact.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cardColor,
                            )
                          : ModernDesignSystem.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cardColor,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ModernDesignSystem.verticalSpaceXS,
                    Text(
                      label,
                      style: ModernDesignSystem.captionCompact.copyWith(
                        color: ModernDesignSystem.getTextSecondary(brightness),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      ModernDesignSystem.verticalSpaceMicro,
                      Text(
                        subtitle!,
                        style: ModernDesignSystem.captionLarge.copyWith(
                          color: ModernDesignSystem.getTextTertiary(brightness),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Info Card - For displaying information with optional actions
class ModernInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final String? badge;
  final IconData icon;
  final Color? iconColor;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final EdgeInsets? margin;

  const ModernInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.badge,
    required this.icon,
    this.iconColor,
    this.badgeColor,
    this.onTap,
    this.actions,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardIconColor = iconColor ?? ModernDesignSystem.primaryTeal;

    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
      decoration: ModernDesignSystem.modernCardDecoration(brightness),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceCompactMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
                      decoration: BoxDecoration(
                        color: cardIconColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(ModernDesignSystem.radiusSM),
                      ),
                      child: Icon(
                        icon,
                        color: cardIconColor,
                        size: 20,
                      ),
                    ),
                    ModernDesignSystem.horizontalSpaceXS,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: ModernDesignSystem.bodyCompactMedium
                                      .copyWith(
                                    color: ModernDesignSystem.getTextPrimary(
                                        brightness),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (badge != null) ...[
                                ModernDesignSystem.horizontalSpaceXS,
                                ModernStatusBadge(
                                  label: badge!,
                                  color: badgeColor,
                                ),
                              ],
                            ],
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: ModernDesignSystem.captionCompact.copyWith(
                                color: ModernDesignSystem.getTextSecondary(
                                    brightness),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (value != null) ...[
                      Text(
                        value!,
                        style: ModernDesignSystem.headlineCompact.copyWith(
                          color: ModernDesignSystem.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (onTap != null) ...[
                      ModernDesignSystem.horizontalSpaceXS,
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: ModernDesignSystem.getTextTertiary(brightness),
                      ),
                    ],
                  ],
                ),
                if (actions != null) ...[
                  ModernDesignSystem.verticalSpaceMD,
                  Divider(
                    color: ModernDesignSystem.getDividerColor(brightness),
                    height: 1,
                  ),
                  ModernDesignSystem.verticalSpaceXS,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Hero Card - For prominent content sections
class ModernHeroCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ModernHeroCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.gradient,
    this.actions,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceLG),
      decoration: BoxDecoration(
        // Glass morphism effect for hero card
        color: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLG),
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLG),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || subtitle != null || icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
                  decoration: BoxDecoration(
                    color: (backgroundColor ??
                            ModernDesignSystem.getSurfaceColor(brightness))
                        .withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(ModernDesignSystem.radiusLG),
                      topRight: Radius.circular(ModernDesignSystem.radiusLG),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: ModernDesignSystem.getDividerColor(brightness),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding:
                              const EdgeInsets.all(ModernDesignSystem.spaceXS),
                          decoration: BoxDecoration(
                            color:
                                ModernDesignSystem.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusXS),
                          ),
                          child: Icon(
                            icon!,
                            color: ModernDesignSystem.primaryTeal,
                            size: 20,
                          ),
                        ),
                        ModernDesignSystem.horizontalSpaceSM,
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style:
                                    ModernDesignSystem.headlineMedium.copyWith(
                                  color: ModernDesignSystem.getTextPrimary(
                                      brightness),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (subtitle != null) ...[
                              ModernDesignSystem.verticalSpaceMicro,
                              Text(
                                subtitle!,
                                style: ModernDesignSystem.bodyMedium.copyWith(
                                  color: ModernDesignSystem.getTextSecondary(
                                      brightness),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
              ],
              Padding(
                padding:
                    padding ?? const EdgeInsets.all(ModernDesignSystem.spaceMD),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern List Item Card - For list-based content
class ModernListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final Color? leadingIconColor;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsets? margin;

  const ModernListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.leadingIconColor,
    this.onTap,
    this.showDivider = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final iconColor = leadingIconColor ?? ModernDesignSystem.primaryTeal;

    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceXS),
      decoration: ModernDesignSystem.subtleCardDecoration(brightness),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceCompactMD),
            child: Column(
              children: [
                Row(
                  children: [
                    if (leadingWidget != null)
                      leadingWidget!
                    else if (leadingIcon != null)
                      Container(
                        padding:
                            const EdgeInsets.all(ModernDesignSystem.spaceXS),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              ModernDesignSystem.radiusXS),
                        ),
                        child: Icon(
                          leadingIcon!,
                          color: iconColor,
                          size: 16,
                        ),
                      ),
                    if (leadingWidget != null || leadingIcon != null)
                      ModernDesignSystem.horizontalSpaceSM,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                ModernDesignSystem.bodyCompactMedium.copyWith(
                              color:
                                  ModernDesignSystem.getTextPrimary(brightness),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: ModernDesignSystem.captionCompact.copyWith(
                                color: ModernDesignSystem.getTextSecondary(
                                    brightness),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailingWidget != null)
                      trailingWidget!
                    else if (trailing != null) ...[
                      Text(
                        trailing!,
                        style: ModernDesignSystem.bodyCompact.copyWith(
                          color:
                              ModernDesignSystem.getTextSecondary(brightness),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (onTap != null) ...[
                      ModernDesignSystem.horizontalSpaceXS,
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: ModernDesignSystem.getTextTertiary(brightness),
                      ),
                    ],
                  ],
                ),
                if (showDivider) ...[
                  ModernDesignSystem.verticalSpaceXS,
                  Divider(
                    color: ModernDesignSystem.getDividerColor(brightness),
                    height: 1,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
