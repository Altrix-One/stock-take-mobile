import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'status_badge.dart';

enum ListItemStyle {
  standard,
  card,
  borderless,
}

class ProfessionalListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final ListItemStyle style;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;

  const ProfessionalListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.style = ListItemStyle.standard,
    this.padding,
    this.margin,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Style configuration
    Color backgroundColor;
    Color? borderColor;
    double? elevation;
    BorderRadius? borderRadius;

    switch (style) {
      case ListItemStyle.standard:
        backgroundColor = Colors.transparent;
        borderColor = null;
        elevation = null;
        borderRadius = null;
        break;
      case ListItemStyle.card:
        backgroundColor = isDark ? const Color(0xFF1E1E1E) : whiteColor;
        borderColor =
            isDark ? borderMediumColor.withOpacity(0.1) : borderLightColor;
        elevation = elevationSM;
        borderRadius = BorderRadius.circular(radiusMD);
        break;
      case ListItemStyle.borderless:
        backgroundColor = isDark ? const Color(0xFF1A1A1A) : surfaceColor;
        borderColor = null;
        elevation = null;
        borderRadius = BorderRadius.circular(radiusSM);
        break;
    }

    // Selection styling
    if (isSelected) {
      backgroundColor = accentColor.withOpacity(0.08);
      borderColor = accentColor.withOpacity(0.3);
    }

    final paddingValue = padding ?? const EdgeInsets.all(paddingMD);
    final marginValue = margin ??
        (style == ListItemStyle.card
            ? const EdgeInsets.symmetric(vertical: paddingXS)
            : EdgeInsets.zero);

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          widthSpaceMD,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? accentColor : textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                heightSpaceXS,
                Text(
                  subtitle!,
                  style: bodySmall.copyWith(
                    color: isSelected
                        ? accentColor.withOpacity(0.8)
                        : textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (description != null) ...[
                heightSpaceXS,
                Text(
                  description!,
                  style: bodySmall.copyWith(
                    color: textTertiaryColor,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                heightSpaceSM,
                Wrap(
                  spacing: paddingSM,
                  runSpacing: paddingXS,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          widthSpaceMD,
          trailing!,
        ],
      ],
    );

    Widget listItem = Container(
      margin: marginValue,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: shadowLightColor,
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius,
          child: Padding(
            padding: paddingValue,
            child: content,
          ),
        ),
      ),
    );

    return listItem;
  }
}

// Specialized list items for common use cases
class LeaveListItem extends ProfessionalListItem {
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String status;
  final VoidCallback? onCancel;
  final bool canCancel;

  LeaveListItem({
    super.key,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.status,
    this.onCancel,
    this.canCancel = false,
    super.onTap,
    super.style = ListItemStyle.card,
  }) : super(
          title: '$leaveType: $fromDate → $toDate',
          subtitle: status,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getLeaveTypeColor(leaveType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            child: Icon(
              _getLeaveTypeIcon(leaveType),
              color: _getLeaveTypeColor(leaveType),
              size: 20,
            ),
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              statusBadgeFromString(status, size: BadgeSize.small),
              if (canCancel && onCancel != null) ...[
                heightSpaceXS,
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: errorColor),
                  onPressed: onCancel,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                ),
              ],
            ],
          ),
        );

  static Color _getLeaveTypeColor(String leaveType) {
    final type = leaveType.toLowerCase();
    if (type.contains('sick')) return errorLightColor;
    if (type.contains('annual') || type.contains('vacation')) return infoColor;
    if (type.contains('casual')) return accentColor;
    return warningColor;
  }

  static IconData _getLeaveTypeIcon(String leaveType) {
    final type = leaveType.toLowerCase();
    if (type.contains('sick')) return Icons.healing_outlined;
    if (type.contains('annual') || type.contains('vacation'))
      return Icons.beach_access_outlined;
    if (type.contains('casual')) return Icons.weekend_outlined;
    return Icons.event_available_outlined;
  }
}

class ApprovalListItem extends ProfessionalListItem {
  final String doctype;
  final String requestor;
  final String date;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  ApprovalListItem({
    super.key,
    required this.doctype,
    required super.title,
    required this.requestor,
    required this.date,
    this.onApprove,
    this.onReject,
    super.onTap,
    super.style = ListItemStyle.card,
  }) : super(
          subtitle: 'Requested by $requestor',
          description: date,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            child: Icon(
              _getDocTypeIcon(doctype),
              color: warningColor,
              size: 20,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: errorColor),
                onPressed: onReject,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                iconSize: 18,
              ),
              widthSpaceXS,
              IconButton(
                icon: const Icon(Icons.check_circle, color: successColor),
                onPressed: onApprove,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                iconSize: 18,
              ),
            ],
          ),
        );

  static IconData _getDocTypeIcon(String doctype) {
    switch (doctype.toLowerCase()) {
      case 'leave application':
        return Icons.event_available_outlined;
      case 'attendance request':
        return Icons.schedule_outlined;
      case 'shift request':
        return Icons.swap_horiz_outlined;
      case 'expense claim':
        return Icons.receipt_long_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class ActionListItem extends ProfessionalListItem {
  final IconData icon;
  final Color? iconColor;
  final String? badge;
  final Color? badgeColor;

  ActionListItem({
    super.key,
    required super.title,
    super.subtitle,
    required this.icon,
    this.iconColor,
    this.badge,
    this.badgeColor,
    required super.onTap,
    super.style = ListItemStyle.borderless,
  }) : super(
          leading: Stack(
            children: [
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
              if (badge != null)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor ?? errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: textTertiaryColor,
            size: 20,
          ),
        );
}

class InfoListItem extends ProfessionalListItem {
  final String value;
  final IconData? icon;
  final Color? valueColor;

  InfoListItem({
    super.key,
    required super.title,
    required this.value,
    this.icon,
    this.valueColor,
    super.onTap,
  }) : super(
          leading: icon != null
              ? Icon(
                  icon,
                  color: textSecondaryColor,
                  size: 20,
                )
              : null,
          trailing: Text(
            value,
            style: titleMedium.copyWith(
              color: valueColor ?? textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
}

// Empty state component
class EmptyListState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;

  const EmptyListState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(space3XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: textTertiaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: textTertiaryColor,
              ),
            ),
            heightSpaceLG,
            Text(
              title,
              style: headlineSmall.copyWith(
                color: textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              heightSpaceSM,
              Text(
                subtitle!,
                style: bodyMedium.copyWith(
                  color: textTertiaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionTap != null) ...[
              heightSpaceLG,
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: textOnAccentColor,
                  elevation: elevationSM,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusMD),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
