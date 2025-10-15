import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModernShiftItem extends StatelessWidget {
  final Map<String, dynamic> shift;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ModernShiftItem({
    super.key,
    required this.shift,
    this.onTap,
    this.onCancel,
  });

  String _getShiftStatus(String? status) {
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

  IconData _getShiftIcon(String? shiftType) {
    if (shiftType == null) return Icons.work_outline_rounded;
    final type = shiftType.toLowerCase();

    if (type.contains('morning') || type.contains('day'))
      return Icons.wb_sunny_rounded;
    if (type.contains('evening') || type.contains('afternoon'))
      return Icons.wb_twilight_rounded;
    if (type.contains('night')) return Icons.bedtime_rounded;
    if (type.contains('weekend')) return Icons.weekend_rounded;
    if (type.contains('overtime')) return Icons.access_time_filled_rounded;

    return Icons.work_outline_rounded;
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
    final theme = Theme.of(context);
    final shiftType = shift['shift']?.toString() ?? 'Shift Request';
    final fromDate = shift['from_date']?.toString();
    final toDate = shift['to_date']?.toString();
    final status = _getShiftStatus(shift['status']?.toString());
    final reason = shift['reason']?.toString() ?? '';
    final days = _calculateDays(fromDate, toDate);

    final statusColor = _getStatusColor(status, context);
    final canCancel =
        status.toLowerCase() == 'pending' || status.toLowerCase() == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with shift type and status
              Row(
                children: [
                  // Shift type icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiary,
                          theme.colorScheme.tertiary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.tertiary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getShiftIcon(shiftType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shiftType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateRange(fromDate, toDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reason',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reason,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.8),
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
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
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
    );
  }

  Widget _statItem(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
