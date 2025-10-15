import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/modern_design_system.dart';
import '../constants/app_theme_unified.dart';

/// Modern Button Component - Primary CTA button
class ModernPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final EdgeInsets? padding;

  const ModernPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: [
                  ModernDesignSystem.primaryNavy,
                  ModernDesignSystem.primaryTeal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? ModernDesignSystem.neutralPale : null,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        boxShadow: !isDisabled ? AppThemeUnified.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          child: Padding(
            padding: padding ?? ModernDesignSystem.buttonPaddingLarge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                else if (icon != null) ...[
                  Icon(
                    icon!,
                    color: AppThemeUnified.textPrimary,
                    size: 20,
                  ),
                  ModernDesignSystem.horizontalSpaceXS,
                ],
                Text(
                  text,
                  style: ModernDesignSystem.labelLarge.copyWith(
                    color: isDisabled
                        ? ModernDesignSystem.neutralLight
                        : AppThemeUnified.textPrimary,
                    fontWeight: FontWeight.w600,
                    shadows: !isDisabled ? AppThemeUnified.textShadow : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Secondary Button
class ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsets? padding;

  const ModernSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeUnified.glassLight,
        border: Border.all(
          color: ModernDesignSystem.primaryTeal,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        boxShadow: AppThemeUnified.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          child: Padding(
            padding: padding ?? ModernDesignSystem.buttonPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ModernDesignSystem.primaryTeal),
                      strokeWidth: 2,
                    ),
                  )
                else if (icon != null) ...[
                  Icon(
                    icon!,
                    color: ModernDesignSystem.primaryTeal,
                    size: 20,
                  ),
                  ModernDesignSystem.horizontalSpaceXS,
                ],
                Text(
                  text,
                  style: ModernDesignSystem.labelLarge.copyWith(
                    color: ModernDesignSystem.primaryTeal,
                    fontWeight: FontWeight.w600,
                    shadows: AppThemeUnified.textShadow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern App Bar
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool centerTitle;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? ModernDesignSystem.getSurfaceColor(brightness),
        border: Border(
          bottom: BorderSide(
            color: ModernDesignSystem.getBorderColor(brightness),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ModernDesignSystem.spaceMD,
            vertical: ModernDesignSystem.spaceSM,
          ),
          child: Row(
            children: [
              if (showBackButton && leading == null)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: ModernDesignSystem.getTextPrimary(brightness),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else if (leading != null)
                leading!
              else
                const SizedBox(width: 40),
              if (!centerTitle) ...[
                ModernDesignSystem.horizontalSpaceSM,
                Expanded(
                  child: Text(
                    title,
                    style: ModernDesignSystem.headlineSmall.copyWith(
                      color: ModernDesignSystem.getTextPrimary(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    title,
                    style: ModernDesignSystem.headlineSmall.copyWith(
                      color: ModernDesignSystem.getTextPrimary(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (actions != null) ...actions! else const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

/// Modern Status Badge
class ModernStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isOutlined;

  const ModernStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? ModernDesignSystem.primaryTeal;
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernDesignSystem.spaceXS,
        vertical: ModernDesignSystem.spaceMicro,
      ),
      decoration: BoxDecoration(
        color: isOutlined
            ? ModernDesignSystem.getSurfaceColor(brightness)
            : badgeColor.withOpacity(0.1),
        border: isOutlined ? Border.all(color: badgeColor, width: 1) : null,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
      ),
      child: Text(
        label.toUpperCase(),
        style: ModernDesignSystem.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Modern Input Field
class ModernInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool isRequired;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;

  const ModernInputField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.isRequired = false,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: ModernDesignSystem.labelLarge.copyWith(
                  color: AppThemeUnified.textPrimary,
                  fontWeight: FontWeight.w600,
                  shadows: AppThemeUnified.textShadow,
                ),
              ),
              if (isRequired) ...[
                ModernDesignSystem.horizontalSpaceMicro,
                Text(
                  '*',
                  style: ModernDesignSystem.labelLarge.copyWith(
                    color: ModernDesignSystem.error,
                  ),
                ),
              ],
            ],
          ),
          ModernDesignSystem.verticalSpaceXS,
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppThemeUnified.glassLight
                : AppThemeUnified.glassLight.withOpacity(0.5),
            border: Border.all(
              color: AppThemeUnified.glassBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            style: ModernDesignSystem.bodyMedium.copyWith(
              color: AppThemeUnified.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ModernDesignSystem.bodyMedium.copyWith(
                color: AppThemeUnified.textTertiary,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon!,
                      color: AppThemeUnified.textSecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(
                        suffixIcon!,
                        color: AppThemeUnified.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern Section Header
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
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
                color: AppThemeUnified.textPrimary,
                size: 20,
              ),
            ),
            ModernDesignSystem.horizontalSpaceXS,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernDesignSystem.headlineSmall.copyWith(
                    color: AppThemeUnified.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  ModernDesignSystem.verticalSpaceMicro,
                  Text(
                    subtitle!,
                    style: ModernDesignSystem.bodySmall.copyWith(
                      color: AppThemeUnified.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Modern Loading Indicator
class ModernLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const ModernLoadingIndicator({
    super.key,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(ModernDesignSystem.primaryTeal),
          strokeWidth: 3,
        ),
        if (message != null) ...[
          ModernDesignSystem.verticalSpaceMD,
          Text(
            message!,
            style: ModernDesignSystem.bodyMedium.copyWith(
              color: ModernDesignSystem.getTextSecondary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceLG),
            decoration: ModernDesignSystem.modernCardDecoration(brightness),
            child: content,
          ),
        ),
      );
    }

    return Center(child: content);
  }
}

/// Modern Stats Card
class ModernStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final bool isCompact;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const ModernStatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.isCompact = false,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = color ?? AppThemeUnified.primaryRoyalBlue;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppThemeUnified.spaceXS,
          ),
      child: AppThemeUnified.glassContainer(
        borderRadius: AppThemeUnified.radiusMD,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUnified.glassLight,
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                border: Border.all(
                  color: AppThemeUnified.glassBorder,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isCompact
                          ? AppThemeUnified.spaceMD
                          : AppThemeUnified.spaceLG,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Container(
                            padding:
                                const EdgeInsets.all(AppThemeUnified.spaceSM),
                            decoration: BoxDecoration(
                              color: AppThemeUnified.glassLight,
                              borderRadius: BorderRadius.circular(
                                  AppThemeUnified.radiusSM),
                              border: Border.all(
                                color: AppThemeUnified.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: AppThemeUnified.textPrimary,
                              size: isCompact ? 20 : 24,
                            ),
                          ),
                          SizedBox(
                              height: isCompact
                                  ? AppThemeUnified.spaceXS
                                  : AppThemeUnified.spaceSM),
                        ],
                        Text(
                          value,
                          style: (isCompact
                                  ? AppThemeUnified.headlineSmall
                                  : AppThemeUnified.headlineLarge)
                              .copyWith(
                            color: AppThemeUnified.textPrimary,
                            fontWeight: FontWeight.w700,
                            shadows: AppThemeUnified.textShadow,
                          ),
                        ),
                        const SizedBox(height: AppThemeUnified.spaceXS),
                        Text(
                          label,
                          style: (isCompact
                                  ? AppThemeUnified.bodySmall
                                  : AppThemeUnified.bodyMedium)
                              .copyWith(
                            color: AppThemeUnified.textSecondary,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Action Card
class ModernActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool showArrow;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ModernActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.showArrow = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = color ?? AppThemeUnified.primaryRoyalBlue;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppThemeUnified.spaceXS,
            vertical: AppThemeUnified.spaceXS,
          ),
      child: AppThemeUnified.glassContainer(
        borderRadius: AppThemeUnified.radiusMD,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUnified.glassLight,
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                border: Border.all(
                  color: AppThemeUnified.glassBorder,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                  child: Padding(
                    padding: padding ??
                        const EdgeInsets.all(AppThemeUnified.spaceMD),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Container(
                            padding:
                                const EdgeInsets.all(AppThemeUnified.spaceSM),
                            decoration: BoxDecoration(
                              color: AppThemeUnified.glassLight,
                              borderRadius: BorderRadius.circular(
                                  AppThemeUnified.radiusSM),
                              border: Border.all(
                                color: AppThemeUnified.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: AppThemeUnified.textPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppThemeUnified.spaceSM),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppThemeUnified.labelLarge.copyWith(
                                  color: AppThemeUnified.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: AppThemeUnified.spaceXS),
                                Text(
                                  subtitle!,
                                  style: AppThemeUnified.bodySmall.copyWith(
                                    color: AppThemeUnified.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (showArrow) ...[
                          const SizedBox(width: AppThemeUnified.spaceSM),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppThemeUnified.textTertiary,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Hero Card
class ModernHeroCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Color? headerColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ModernHeroCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.headerColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = headerColor ?? AppThemeUnified.primaryRoyalBlue;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppThemeUnified.spaceMD,
            vertical: AppThemeUnified.spaceXS,
          ),
      child: AppThemeUnified.glassContainer(
        borderRadius: AppThemeUnified.radiusMD,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUnified.glassLight,
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                border: Border.all(
                  color: AppThemeUnified.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty) ...[
                    Padding(
                      padding: padding ??
                          const EdgeInsets.fromLTRB(
                            AppThemeUnified.spaceMD,
                            AppThemeUnified.spaceMD,
                            AppThemeUnified.spaceMD,
                            AppThemeUnified.spaceSM,
                          ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              padding:
                                  const EdgeInsets.all(AppThemeUnified.spaceXS),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppThemeUnified.radiusXS),
                              ),
                              child: Icon(
                                icon,
                                color: cardColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppThemeUnified.spaceSM),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppThemeUnified.headlineSmall.copyWith(
                                    color: AppThemeUnified.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle!,
                                    style: AppThemeUnified.bodyMedium.copyWith(
                                      color: AppThemeUnified.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppThemeUnified.spaceMD,
                      0,
                      AppThemeUnified.spaceMD,
                      AppThemeUnified.spaceMD,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern List Item Card
class ModernListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ModernListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: AppThemeUnified.spaceXS,
          ),
      child: AppThemeUnified.glassContainer(
        borderRadius: AppThemeUnified.radiusSM,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUnified.glassLight,
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
                border: Border.all(
                  color: AppThemeUnified.glassBorder,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
                  child: Padding(
                    padding: padding ??
                        const EdgeInsets.symmetric(
                          horizontal: AppThemeUnified.spaceMD,
                          vertical: AppThemeUnified.spaceSM,
                        ),
                    child: Row(
                      children: [
                        if (leadingWidget != null)
                          leadingWidget!
                        else if (leadingIcon != null) ...[
                          Container(
                            padding:
                                const EdgeInsets.all(AppThemeUnified.spaceXS),
                            decoration: BoxDecoration(
                              color: AppThemeUnified.glassMedium,
                              borderRadius: BorderRadius.circular(
                                  AppThemeUnified.radiusXS),
                            ),
                            child: Icon(
                              leadingIcon,
                              color: AppThemeUnified.textSecondary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: AppThemeUnified.spaceSM),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppThemeUnified.bodyMedium.copyWith(
                                  color: AppThemeUnified.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle != null && subtitle!.isNotEmpty) ...[
                                const SizedBox(height: AppThemeUnified.spaceXS),
                                Text(
                                  subtitle!,
                                  style: AppThemeUnified.bodySmall.copyWith(
                                    color: AppThemeUnified.textSecondary,
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
                        else if (trailing != null && trailing!.isNotEmpty) ...[
                          const SizedBox(width: AppThemeUnified.spaceSM),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppThemeUnified.spaceXS,
                              vertical: AppThemeUnified.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppThemeUnified.glassMedium,
                              borderRadius: BorderRadius.circular(
                                  AppThemeUnified.radiusXS),
                            ),
                            child: Text(
                              trailing!,
                              style: AppThemeUnified.labelSmall.copyWith(
                                color: AppThemeUnified.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
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
        ),
      ),
    );
  }
}

/// Modern Info Card
class ModernInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? content;
  final String? badge;
  final Color? badgeColor;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final Widget? child;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ModernInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.badge,
    this.badgeColor,
    this.icon,
    this.color,
    this.iconColor,
    this.child,
    this.actions,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = color ?? ModernDesignSystem.primaryTeal;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: ModernDesignSystem.spaceMD,
            vertical: ModernDesignSystem.spaceXS,
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          child: Container(
            decoration: ModernDesignSystem.subtleCardDecoration(brightness),
            padding:
                padding ?? const EdgeInsets.all(ModernDesignSystem.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding:
                            const EdgeInsets.all(ModernDesignSystem.spaceXS),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              ModernDesignSystem.radiusXS),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor ?? cardColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: ModernDesignSystem.spaceSM),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ModernDesignSystem.headlineSmall.copyWith(
                              color:
                                  ModernDesignSystem.getTextPrimary(brightness),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
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
                    if (badge != null) ...[
                      const SizedBox(width: ModernDesignSystem.spaceSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ModernDesignSystem.spaceXS,
                          vertical: ModernDesignSystem.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? cardColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              ModernDesignSystem.radiusXS),
                        ),
                        child: Text(
                          badge!,
                          style: ModernDesignSystem.labelSmall.copyWith(
                            color: badgeColor ?? cardColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (content != null || child != null) ...[
                  const SizedBox(height: ModernDesignSystem.spaceSM),
                  if (child != null)
                    child!
                  else if (content != null)
                    Text(
                      content!,
                      style: ModernDesignSystem.bodyMedium.copyWith(
                        color: ModernDesignSystem.getTextPrimary(brightness),
                      ),
                    ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: ModernDesignSystem.spaceSM),
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

/// Modern Empty State
class ModernEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const ModernEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.space2XL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceLG),
            decoration: BoxDecoration(
              color: ModernDesignSystem.neutralVeryPale,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLG),
            ),
            child: Icon(
              icon,
              size: 48,
              color: ModernDesignSystem.neutralPale,
            ),
          ),
          ModernDesignSystem.verticalSpaceLG,
          Text(
            title,
            style: ModernDesignSystem.headlineMedium.copyWith(
              color: ModernDesignSystem.getTextPrimary(brightness),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            ModernDesignSystem.verticalSpaceXS,
            Text(
              subtitle!,
              style: ModernDesignSystem.bodyMedium.copyWith(
                color: ModernDesignSystem.getTextSecondary(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionText != null && onAction != null) ...[
            ModernDesignSystem.verticalSpaceLG,
            ModernSecondaryButton(
              text: actionText!,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
