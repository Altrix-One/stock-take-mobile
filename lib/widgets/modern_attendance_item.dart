import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModernAttendanceItem extends StatelessWidget {
  final Map<String, dynamic> attendance;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ModernAttendanceItem({
    super.key,
    required this.attendance,
    this.onTap,
    this.onCancel,
  });

  String _getAttendanceStatus(String? status) {
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

  IconData _getAttendanceIcon(String? reason) {
    if (reason == null) return Icons.access_time_rounded;
    final reasonLower = reason.toLowerCase();
    
    if (reasonLower.contains('sick')) return Icons.healing_rounded;
    if (reasonLower.contains('emergency')) return Icons.warning_rounded;
    if (reasonLower.contains('meeting')) return Icons.groups_rounded;
    if (reasonLower.contains('training')) return Icons.school_rounded;
    if (reasonLower.contains('personal')) return Icons.person_rounded;
    
    return Icons.access_time_rounded;
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTimeRange(String? fromDate, String? toDate) {
    if (fromDate == null || toDate == null) return 'N/A';
    
    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);
      
      if (from.year == to.year && from.month == to.month && from.day == to.day) {
        return '${DateFormat('MMM dd, yyyy').format(from)} • ${DateFormat('hh:mm a').format(from)} - ${DateFormat('hh:mm a').format(to)}';
      }
      
      return '${DateFormat('MMM dd, hh:mm a').format(from)} - ${DateFormat('MMM dd, hh:mm a').format(to)}';
    } catch (_) {
      return '$fromDate - $toDate';
    }
  }

  double _calculateHours(String? fromDate, String? toDate) {
    if (fromDate == null || toDate == null) return 0;
    
    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);
      return to.difference(from).inMinutes / 60.0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = attendance['reason']?.toString() ?? 'Attendance Request';
    final fromDate = attendance['from_date']?.toString() ?? attendance['from_time']?.toString();
    final toDate = attendance['to_date']?.toString() ?? attendance['to_time']?.toString();
    final status = _getAttendanceStatus(attendance['status']?.toString());
    final hours = _calculateHours(fromDate, toDate);
    
    final statusColor = _getStatusColor(status, context);
    final canCancel = status.toLowerCase() == 'pending' || status.toLowerCase() == 'open';

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
              // Header row with attendance type and status
              Row(
                children: [
                  // Attendance type icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.secondary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getAttendanceIcon(reason),
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
                          'Attendance Request',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTimeRange(fromDate, toDate),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  if (hours > 0)
                    Expanded(
                      child: _statItem(
                        context,
                        'Duration',
                        '${hours.toStringAsFixed(1)} hrs',
                        Icons.schedule_rounded,
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
              if (reason.isNotEmpty && reason != 'Attendance Request') ...[
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
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _statItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.secondary,
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