import 'package:flutter/material.dart';
import '../constants/theme.dart';

enum StatusType {
  approved,
  pending,
  rejected,
  cancelled,
  draft,
  open,
  success,
  warning,
  error,
  info,
}

enum BadgeSize {
  small,
  medium,
  large,
}

enum BadgeStyle {
  filled,
  outlined,
  soft,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType? type;
  final Color? customColor;
  final BadgeSize size;
  final BadgeStyle style;
  final IconData? icon;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type,
    this.customColor,
    this.size = BadgeSize.medium,
    this.style = BadgeStyle.soft,
    this.icon,
    this.showIcon = true,
  });

  // Convenience constructors for common status types
  const StatusBadge.approved({
    super.key,
    this.text = 'Approved',
    this.size = BadgeSize.medium,
    this.style = BadgeStyle.soft,
    this.icon,
    this.showIcon = true,
  }) : type = StatusType.approved, customColor = null;

  const StatusBadge.pending({
    super.key,
    this.text = 'Pending',
    this.size = BadgeSize.medium,
    this.style = BadgeStyle.soft,
    this.icon,
    this.showIcon = true,
  }) : type = StatusType.pending, customColor = null;

  const StatusBadge.rejected({
    super.key,
    this.text = 'Rejected',
    this.size = BadgeSize.medium,
    this.style = BadgeStyle.soft,
    this.icon,
    this.showIcon = true,
  }) : type = StatusType.rejected, customColor = null;

  const StatusBadge.cancelled({
    super.key,
    this.text = 'Cancelled',
    this.size = BadgeSize.medium,
    this.style = BadgeStyle.soft,
    this.icon,
    this.showIcon = true,
  }) : type = StatusType.cancelled, customColor = null;

  Color _getStatusColor() {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case StatusType.approved:
      case StatusType.success:
        return successColor;
      case StatusType.pending:
      case StatusType.open:
      case StatusType.draft:
        return warningColor;
      case StatusType.rejected:
      case StatusType.cancelled:
      case StatusType.error:
        return errorColor;
      case StatusType.warning:
        return warningColor;
      case StatusType.info:
        return infoColor;
      default:
        return accentColor;
    }
  }

  IconData? _getStatusIcon() {
    if (icon != null) return icon;
    if (!showIcon) return null;

    switch (type) {
      case StatusType.approved:
      case StatusType.success:
        return Icons.check_circle_outline;
      case StatusType.pending:
        return Icons.schedule;
      case StatusType.open:
        return Icons.radio_button_unchecked;
      case StatusType.draft:
        return Icons.edit_outlined;
      case StatusType.rejected:
      case StatusType.error:
        return Icons.cancel_outlined;
      case StatusType.cancelled:
        return Icons.block;
      case StatusType.warning:
        return Icons.warning_amber_outlined;
      case StatusType.info:
        return Icons.info_outline;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    // Size calculations
    double fontSize;
    double iconSize;
    EdgeInsetsGeometry padding;
    double borderRadius;

    switch (size) {
      case BadgeSize.small:
        fontSize = 10.0;
        iconSize = 12.0;
        padding = const EdgeInsets.symmetric(horizontal: paddingXS, vertical: 2.0);
        borderRadius = radiusXS;
        break;
      case BadgeSize.medium:
        fontSize = 12.0;
        iconSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: paddingSM, vertical: paddingXS);
        borderRadius = radiusSM;
        break;
      case BadgeSize.large:
        fontSize = 14.0;
        iconSize = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: paddingMD, vertical: paddingSM);
        borderRadius = radiusMD;
        break;
    }

    // Style calculations
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    
    switch (style) {
      case BadgeStyle.filled:
        backgroundColor = statusColor;
        textColor = textOnAccentColor;
        borderColor = null;
        break;
      case BadgeStyle.outlined:
        backgroundColor = Colors.transparent;
        textColor = statusColor;
        borderColor = statusColor;
        break;
      case BadgeStyle.soft:
        backgroundColor = statusColor.withOpacity(0.1);
        textColor = statusColor;
        borderColor = statusColor.withOpacity(0.2);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            Icon(
              statusIcon,
              size: iconSize,
              color: textColor,
            ),
            SizedBox(width: spaceXS),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to create status badge from status string
StatusBadge statusBadgeFromString(String status, {BadgeSize size = BadgeSize.medium, BadgeStyle style = BadgeStyle.soft}) {
  final statusLower = status.toLowerCase();
  
  if (statusLower.contains('approved') || statusLower.contains('sanctioned')) {
    return StatusBadge.approved(size: size, style: style);
  } else if (statusLower.contains('pending') || statusLower.contains('applied')) {
    return StatusBadge.pending(size: size, style: style);
  } else if (statusLower.contains('rejected')) {
    return StatusBadge.rejected(size: size, style: style);
  } else if (statusLower.contains('cancelled')) {
    return StatusBadge.cancelled(size: size, style: style);
  } else if (statusLower.contains('draft')) {
    return StatusBadge(text: 'Draft', type: StatusType.draft, size: size, style: style);
  } else if (statusLower.contains('open')) {
    return StatusBadge(text: 'Open', type: StatusType.open, size: size, style: style);
  } else {
    return StatusBadge(text: status, size: size, style: style);
  }
}

// Count badge for showing numbers
class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final BadgeSize size;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = BadgeSize.small,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final bgColor = backgroundColor ?? errorColor;
    final tColor = textColor ?? textOnAccentColor;

    double fontSize;
    double minSize;
    EdgeInsetsGeometry padding;

    switch (size) {
      case BadgeSize.small:
        fontSize = 10.0;
        minSize = 16.0;
        padding = const EdgeInsets.all(2.0);
        break;
      case BadgeSize.medium:
        fontSize = 12.0;
        minSize = 20.0;
        padding = const EdgeInsets.all(4.0);
        break;
      case BadgeSize.large:
        fontSize = 14.0;
        minSize = 24.0;
        padding = const EdgeInsets.all(6.0);
        break;
    }

    return Container(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(minSize / 2),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: tColor,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }
}

// Priority badge for indicating importance levels
class PriorityBadge extends StatelessWidget {
  final String priority;
  final BadgeSize size;
  final BadgeStyle style;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.size = BadgeSize.small,
    this.style = BadgeStyle.soft,
  });

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return errorColor;
      case 'medium':
      case 'normal':
        return warningColor;
      case 'low':
        return successColor;
      default:
        return accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: priority,
      customColor: _getPriorityColor(),
      size: size,
      style: style,
      showIcon: false,
    );
  }
}