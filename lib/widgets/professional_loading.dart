import 'package:flutter/material.dart';
import '../constants/theme.dart';

// Loading indicators
class ProfessionalLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;

  const ProfessionalLoading({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? accentColor;
    final loadingSize = size ?? 32.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: loadingSize,
            height: loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
          if (showMessage && message != null) ...[
            heightSpaceMD,
            Text(
              message!,
              style: bodyMedium.copyWith(
                color: textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Skeleton loading for list items
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.itemCount = 3,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(
            widget.itemCount,
            (index) => Container(
              height: widget.height ?? 80,
              margin: widget.margin ??
                  const EdgeInsets.symmetric(
                    horizontal: paddingMD,
                    vertical: paddingXS,
                  ),
              padding: widget.padding ?? const EdgeInsets.all(paddingMD),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(_animation.value),
                borderRadius: BorderRadius.circular(radiusMD),
              ),
              child: Row(
                children: [
                  // Leading circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(_animation.value + 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  widthSpaceMD,
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(_animation.value + 0.2),
                            borderRadius: BorderRadius.circular(radiusXS),
                          ),
                        ),
                        heightSpaceXS,
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(_animation.value + 0.1),
                            borderRadius: BorderRadius.circular(radiusXS),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trailing
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(_animation.value + 0.1),
                      borderRadius: BorderRadius.circular(radiusXS),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Professional form components
class ProfessionalTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;

  const ProfessionalTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          heightSpaceXS,
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: bodyLarge.copyWith(
            color: textPrimaryColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: bodyLarge.copyWith(
              color: textTertiaryColor,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: paddingMD,
                  vertical: paddingMD,
                ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMD),
              borderSide: BorderSide(
                color: isDark ? borderMediumColor : borderLightColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMD),
              borderSide: BorderSide(
                color: isDark ? borderMediumColor : borderLightColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMD),
              borderSide: const BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMD),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusMD),
              borderSide: const BorderSide(
                color: errorColor,
                width: 2,
              ),
            ),
          ),
        ),
        if (helperText != null || errorText != null) ...[
          heightSpaceXS,
          Text(
            errorText ?? helperText!,
            style: bodySmall.copyWith(
              color: errorText != null ? errorColor : textSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Professional buttons
class ProfessionalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const ProfessionalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = ButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  });

  const ProfessionalButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  }) : style = ButtonStyle.secondary;

  const ProfessionalButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  }) : style = ButtonStyle.outline;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (style) {
      case ButtonStyle.primary:
        backgroundColor = accentColor;
        foregroundColor = textOnAccentColor;
        borderColor = null;
        break;
      case ButtonStyle.secondary:
        backgroundColor = textSecondaryColor.withOpacity(0.1);
        foregroundColor = textPrimaryColor;
        borderColor = null;
        break;
      case ButtonStyle.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = accentColor;
        borderColor = accentColor;
        break;
    }

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !isLoading) ...[
                Icon(icon, size: 18),
                widthSpaceSM,
              ],
              Text(
                text,
                style: labelLarge.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: style == ButtonStyle.outline ? 0 : elevationSM,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: paddingLG,
                vertical: paddingMD,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

enum ButtonStyle {
  primary,
  secondary,
  outline,
}

// Professional app bar
class ProfessionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const ProfessionalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: headlineSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: foregroundColor ?? textPrimaryColor,
        ),
      ),
      backgroundColor: backgroundColor ??
          (isDark ? const Color(0xFF1A1A1A) : whiteColor),
      foregroundColor: foregroundColor ?? textPrimaryColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading: leading,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: elevation > 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
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
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (elevation > 0 ? 1 : 0),
      );
}