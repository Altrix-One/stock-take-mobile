import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:stock_count/constants/app_theme_unified.dart';

class ModernClaimItem extends StatelessWidget {
  final Map<String, dynamic> claim;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ModernClaimItem({
    super.key,
    required this.claim,
    this.onTap,
    this.onCancel,
  });

  String _getClaimStatus(String? status) {
    if (status == null) return 'Unknown';
    switch (status.toLowerCase()) {
      case 'open':
      case 'draft':
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'sanctioned':
        return 'Approved';
      case 'paid':
        return 'Paid';
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
      case 'paid':
        return Colors.blue;
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
      case 'paid':
        return Icons.payments_rounded;
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

  IconData _getClaimIcon(String? claimType) {
    if (claimType == null) return Icons.receipt_long_rounded;
    final type = claimType.toLowerCase();

    if (type.contains('travel')) return Icons.directions_car_rounded;
    if (type.contains('meal') || type.contains('food'))
      return Icons.restaurant_rounded;
    if (type.contains('hotel') || type.contains('accommodation'))
      return Icons.hotel_rounded;
    if (type.contains('medical') || type.contains('health'))
      return Icons.medical_services_rounded;
    if (type.contains('fuel') || type.contains('petrol'))
      return Icons.local_gas_station_rounded;
    if (type.contains('office') || type.contains('supplies'))
      return Icons.business_center_rounded;

    return Icons.receipt_long_rounded;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'N/A';
    try {
      final value = double.parse(amount.toString());
      return NumberFormat.currency(symbol: 'R', decimalDigits: 2).format(value);
    } catch (_) {
      return amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final claimType = claim['expense_type']?.toString() ??
        claim['type']?.toString() ??
        'Expense Claim';
    final amount = claim['total_sanctioned_amount'] ??
        claim['total_amount'] ??
        claim['amount'];
    final status = _getClaimStatus(claim['status']?.toString());
    final description =
        claim['description']?.toString() ?? claim['purpose']?.toString() ?? '';
    final postingDate =
        claim['posting_date']?.toString() ?? claim['expense_date']?.toString();
    final company = claim['company']?.toString() ?? '';

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
                        // Header row with claim type and status
                        Row(
                          children: [
                            // Claim type icon
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
                                _getClaimIcon(claimType),
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
                                    claimType,
                                    style: AppThemeUnified.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppThemeUnified.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (postingDate != null)
                                    Text(
                                      _formatDate(postingDate),
                                      style:
                                          AppThemeUnified.bodyMedium.copyWith(
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

                        // Amount display - prominent
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppThemeUnified.glassLight,
                            borderRadius:
                                BorderRadius.circular(AppThemeUnified.radiusSM),
                            border: Border.all(
                              color: AppThemeUnified.glassBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: AppThemeUnified.textPrimary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Claim Amount',
                                    style: AppThemeUnified.labelMedium.copyWith(
                                      color: AppThemeUnified.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(amount),
                                    style:
                                        AppThemeUnified.headlineSmall.copyWith(
                                      color: AppThemeUnified.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      shadows: AppThemeUnified.textShadow,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Additional info
                        if (company.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 18,
                                color: AppThemeUnified.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                company,
                                style: AppThemeUnified.bodySmall.copyWith(
                                  color: AppThemeUnified.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Description (if available)
                        if (description.isNotEmpty) ...[
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
                                      Icons.description_rounded,
                                      size: 18,
                                      color: AppThemeUnified.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Description',
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
                                  description,
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
}
