import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:stock_count/constants/app_theme_unified.dart';

class ModernLeaveItem extends StatelessWidget {
  final Map<String, dynamic> leave;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ModernLeaveItem({
    super.key,
    required this.leave,
    this.onTap,
    this.onCancel,
  });

  String _getLeaveStatus(String? status) {
    if (status == null) return 'Unknown';
    switch (status.toLowerCase()) {
      case 'open':
      case 'draft':
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'sanctioned':
        return 'Approved';
      case 'rejected':
      case 'cancelled':
        return status.substring(0, 1).toUpperCase() + status.substring(1);
      case 'applied (queued)':
        return 'Queued';
      default:
        return status.substring(0, 1).toUpperCase() + status.substring(1);
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'pending':
      case 'open':
      case 'draft':
        return Colors.orange;
      case 'approved':
      case 'sanctioned':
        return Colors.green;
      case 'rejected':
        return theme.colorScheme.error;
      case 'cancelled':
        return Colors.grey;
      case 'queued':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'open':
      case 'draft':
        return Icons.access_time_rounded;
      case 'approved':
      case 'sanctioned':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      case 'queued':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  IconData _getLeaveIcon(String? leaveType) {
    if (leaveType == null) return Icons.event_available_outlined;
    final type = leaveType.toLowerCase();

    if (type.contains('sick')) return Icons.healing_rounded;
    if (type.contains('annual') || type.contains('vacation'))
      return Icons.beach_access_rounded;
    if (type.contains('casual')) return Icons.weekend_rounded;
    if (type.contains('privilege')) return Icons.star_rounded;
    if (type.contains('maternity') || type.contains('paternity'))
      return Icons.child_care_rounded;
    if (type.contains('emergency')) return Icons.warning_rounded;

    return Icons.event_available_outlined;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateRange(String? fromDate, String? toDate) {
    if (fromDate == null || toDate == null) return 'N/A';

    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);

      if (from.year == to.year &&
          from.month == to.month &&
          from.day == to.day) {
        return DateFormat('MMM dd, yyyy').format(from);
      }

      return '${DateFormat('MMM dd').format(from)} - ${DateFormat('MMM dd, yyyy').format(to)}';
    } catch (_) {
      return '$fromDate - $toDate';
    }
  }

  double _calculateDays(String? fromDate, String? toDate) {
    if (fromDate == null || toDate == null) return 0;

    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);
      return to.difference(from).inDays + 1.0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveType = leave['leave_type']?.toString() ?? 'Unknown';
    final fromDate = leave['from_date']?.toString();
    final toDate = leave['to_date']?.toString();
    final status = _getLeaveStatus(leave['status']?.toString());
    final reason =
        leave['description']?.toString() ?? leave['reason']?.toString() ?? '';
    final days = _calculateDays(fromDate, toDate);

    final statusColor = _getStatusColor(status, context);
    final canCancel =
        status.toLowerCase() == 'pending' || status.toLowerCase() == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with leave type and status
                        Row(
                          children: [
                            // Leave type icon and name
                            Container(
                              padding: const EdgeInsets.all(10),
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
                                _getLeaveIcon(leaveType),
                                color: AppThemeUnified.textPrimary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    leaveType,
                                    style: AppThemeUnified.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppThemeUnified.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDateRange(fromDate, toDate),
                                    style: AppThemeUnified.bodyMedium.copyWith(
                                      color: AppThemeUnified.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(status),
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: _statItem(
                                context,
                                'Duration',
                                '${days.toStringAsFixed(0)} ${days == 1 ? 'day' : 'days'}',
                                Icons.calendar_today_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (fromDate != null)
                              Expanded(
                                child: _statItem(
                                  context,
                                  'From',
                                  _formatDate(fromDate),
                                  Icons.play_arrow_rounded,
                                ),
                              ),
                            const SizedBox(width: 16),
                            if (toDate != null)
                              Expanded(
                                child: _statItem(
                                  context,
                                  'To',
                                  _formatDate(toDate),
                                  Icons.stop_rounded,
                                ),
                              ),
                          ],
                        ),

                        // Reason (if available)
                        if (reason.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppThemeUnified.glassLight,
                              borderRadius: BorderRadius.circular(
                                  AppThemeUnified.radiusSM),
                              border: Border.all(
                                color: AppThemeUnified.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 18,
                                      color: AppThemeUnified.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Reason',
                                      style:
                                          AppThemeUnified.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppThemeUnified.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  reason,
                                  style: AppThemeUnified.bodySmall.copyWith(
                                    color: AppThemeUnified.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Action buttons (if available)
                        if (canCancel && onCancel != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: onCancel,
                                icon:
                                    const Icon(Icons.cancel_outlined, size: 16),
                                label: const Text('Cancel'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppThemeUnified.error,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
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

  Widget _statItem(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeUnified.glassLight,
        borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
        border: Border.all(
          color: AppThemeUnified.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppThemeUnified.textPrimary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppThemeUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppThemeUnified.textPrimary,
              shadows: AppThemeUnified.textShadow,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppThemeUnified.labelSmall.copyWith(
              color: AppThemeUnified.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
