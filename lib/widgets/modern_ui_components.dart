import 'package:flutter/material.dart';
import '../constants/modern_design_system.dart';

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
        color: isDisabled 
            ? ModernDesignSystem.neutralPale
            : null,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        boxShadow: !isDisabled ? [
          BoxShadow(
            color: ModernDesignSystem.primaryNavy.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
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
                    color: Colors.white,
                    size: 20,
                  ),
                  ModernDesignSystem.horizontalSpaceXS,
                ],
                Text(
                  text,
                  style: ModernDesignSystem.labelLarge.copyWith(
                    color: isDisabled ? ModernDesignSystem.neutralLight : Colors.white,
                    fontWeight: FontWeight.w600,
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
        color: ModernDesignSystem.getSurfaceColor(brightness),
        border: Border.all(
          color: ModernDesignSystem.primaryTeal,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
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
                      valueColor: AlwaysStoppedAnimation<Color>(ModernDesignSystem.primaryTeal),
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
        color: backgroundColor ?? ModernDesignSystem.getSurfaceColor(brightness),
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
        border: isOutlined 
            ? Border.all(color: badgeColor, width: 1)
            : null,
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
                  color: ModernDesignSystem.getTextPrimary(brightness),
                  fontWeight: FontWeight.w500,
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
                ? ModernDesignSystem.getSurfaceColor(brightness)
                : ModernDesignSystem.getSurfaceVariant(brightness),
            border: Border.all(
              color: ModernDesignSystem.getBorderColor(brightness),
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
              color: ModernDesignSystem.getTextPrimary(brightness),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ModernDesignSystem.bodyMedium.copyWith(
                color: ModernDesignSystem.getTextTertiary(brightness),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon!,
                      color: ModernDesignSystem.getTextSecondary(brightness),
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(
                        suffixIcon!,
                        color: ModernDesignSystem.getTextSecondary(brightness),
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
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
              ),
              child: Icon(
                icon!,
                color: ModernDesignSystem.primaryTeal,
                size: 16,
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
          valueColor: AlwaysStoppedAnimation<Color>(ModernDesignSystem.primaryTeal),
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