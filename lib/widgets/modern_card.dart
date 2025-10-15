import 'package:flutter/material.dart';
import 'package:stock_count/constants/modern_design_system.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showHeader;

  const ModernCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Widget cardContent = Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
      decoration: ModernDesignSystem.modernCardDecoration(brightness).copyWith(
        color:
            backgroundColor ?? ModernDesignSystem.getSurfaceColor(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader && (title != null || icon != null))
            _buildHeader(brightness),
          Padding(
            padding: padding ?? ModernDesignSystem.cardPadding,
            child: child,
          ),
        ],
      ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildHeader(Brightness brightness) {
    return Container(
      padding: ModernDesignSystem.cardPadding,
      decoration: BoxDecoration(
        color: ModernDesignSystem.primaryTealPale.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ModernDesignSystem.radiusMD),
          topRight: Radius.circular(ModernDesignSystem.radiusMD),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
              decoration: BoxDecoration(
                color: ModernDesignSystem.primaryTeal.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(ModernDesignSystem.radiusXS),
              ),
              child: Icon(
                icon!,
                color: ModernDesignSystem.primaryTeal,
                size: 20,
              ),
            ),
            ModernDesignSystem.horizontalSpaceSM,
          ],
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: ModernDesignSystem.headlineMedium.copyWith(
                  color: ModernDesignSystem.getTextPrimary(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ModernInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ModernInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ModernCard(
      onTap: onTap,
      showHeader: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            decoration: BoxDecoration(
              color: (iconColor ?? ModernDesignSystem.primaryTeal)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: Icon(
              icon,
              color: iconColor ?? ModernDesignSystem.primaryTeal,
              size: 24,
            ),
          ),
          ModernDesignSystem.horizontalSpaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernDesignSystem.bodyLarge.copyWith(
                    color: ModernDesignSystem.getTextPrimary(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  ModernDesignSystem.verticalSpaceMicro,
                  Text(
                    subtitle!,
                    style: ModernDesignSystem.bodySmall.copyWith(
                      color: ModernDesignSystem.getTextSecondary(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            Text(
              value!,
              style: ModernDesignSystem.bodyLarge.copyWith(
                color: ModernDesignSystem.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (onTap != null) ...[
            ModernDesignSystem.horizontalSpaceSM,
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ModernDesignSystem.getTextSecondary(brightness),
            ),
          ],
        ],
      ),
    );
  }
}

class ModernStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const ModernStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = color ?? ModernDesignSystem.primaryTeal;

    return ModernCard(
      onTap: onTap,
      showHeader: false,
      padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: Icon(
              icon,
              color: cardColor,
              size: 24,
            ),
          ),
          ModernDesignSystem.verticalSpaceXS,
          Text(
            value,
            style: ModernDesignSystem.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: ModernDesignSystem.getTextPrimary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
          ModernDesignSystem.verticalSpaceMicro,
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.getTextSecondary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ModernActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isDestructive;

  const ModernActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final actionColor = isDestructive
        ? ModernDesignSystem.error
        : (color ?? ModernDesignSystem.primaryTeal);

    return ModernCard(
      onTap: onTap,
      showHeader: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
            ),
            child: Icon(
              icon,
              color: actionColor,
              size: 20,
            ),
          ),
          ModernDesignSystem.horizontalSpaceSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernDesignSystem.bodyLarge.copyWith(
                    color: isDestructive
                        ? ModernDesignSystem.error
                        : ModernDesignSystem.getTextPrimary(brightness),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  ModernDesignSystem.verticalSpaceMicro,
                  Text(
                    subtitle!,
                    style: ModernDesignSystem.bodySmall.copyWith(
                      color: ModernDesignSystem.getTextSecondary(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDestructive
                ? ModernDesignSystem.error
                : ModernDesignSystem.getTextSecondary(brightness),
          ),
        ],
      ),
    );
  }
}
