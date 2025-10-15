import 'package:flutter/material.dart';
import '../constants/app_theme_unified.dart';
import '../widgets/universal_scaffold.dart';
import '../hr/services/leaves_service.dart';

/// Modern Leaves Page - Refactored to use Unified Theme System
/// This demonstrates the pattern for refactoring screens
class ModernLeavesPageRefactored extends StatefulWidget {
  const ModernLeavesPageRefactored({super.key});

  @override
  State<ModernLeavesPageRefactored> createState() =>
      _ModernLeavesPageRefactoredState();
}

class _ModernLeavesPageRefactoredState extends State<ModernLeavesPageRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Leave data
  Map<String, dynamic>? _leaveBalance;
  List<dynamic> _myLeaves = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaveData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveData() async {
    try {
      final balance = await LeavesService.leaveBalanceWithPending();
      final leaves = await LeavesService.myLeaves();

      if (mounted) {
        setState(() {
          _leaveBalance = balance;
          _myLeaves = leaves;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leave data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UniversalScaffold(
      appBar: UniversalAppBar(
        title: 'My Leaves',
        actions: [
          IconButton(
            onPressed: _loadLeaveData,
            icon: const Icon(
              Icons.refresh,
              color: AppThemeUnified.textPrimary,
            ),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: AppThemeUnified.spaceMD),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined),
              text: 'My Applications',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet_outlined),
              text: 'Leave Balance',
            ),
          ],
          indicatorColor: AppThemeUnified.textPrimary,
          labelColor: AppThemeUnified.textPrimary,
          unselectedLabelColor: AppThemeUnified.textSecondary,
          labelStyle: AppThemeUnified.labelMedium,
          unselectedLabelStyle: AppThemeUnified.labelMedium,
        ),
      ),
      body: _isLoading
          ? const UniversalLoading(
              message: 'Loading leave information...',
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyApplicationsTab(),
                _buildLeaveBalanceTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeaveDialog,
        backgroundColor: AppThemeUnified.primaryRoyalBlue,
        foregroundColor: AppThemeUnified.textPrimary,
        icon: const Icon(Icons.add),
        label: Text(
          'Apply Leave',
          style: AppThemeUnified.labelLarge,
        ),
      ),
    );
  }

  Widget _buildMyApplicationsTab() {
    if (_myLeaves.isEmpty) {
      return const UniversalEmptyState(
        icon: Icons.event_note_outlined,
        title: 'No Leave Applications',
        message: 'Your leave applications will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaveData,
      child: UniversalPageContent(
        children: [
          UniversalSectionHeader(
            title: 'Recent Applications',
            subtitle: '${_myLeaves.length} applications found',
            icon: Icons.history,
          ),

          ..._myLeaves.map((leave) => _buildLeaveApplicationCard(leave)),

          // Bottom spacing for FAB
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceTab() {
    if (_leaveBalance == null || _leaveBalance!.isEmpty) {
      return const UniversalEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Leave Balance',
        message: 'Your leave balance information will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaveData,
      child: UniversalPageContent(
        children: [
          UniversalSectionHeader(
            title: 'Leave Balance',
            subtitle: 'Current allocation and usage',
            icon: Icons.account_balance_wallet,
          ),
          ..._leaveBalance!.entries
              .map((entry) => _buildLeaveBalanceCard(entry.key, entry.value)),
          const SizedBox(height: AppThemeUnified.spaceLG),
        ],
      ),
    );
  }

  Widget _buildLeaveApplicationCard(Map<String, dynamic> leave) {
    final leaveType = leave['leave_type']?.toString() ?? 'Leave';
    final fromDate = leave['from_date']?.toString() ?? '';
    final toDate = leave['to_date']?.toString() ?? '';
    final status = leave['status']?.toString() ?? '';
    final days = leave['total_leave_days']?.toString() ?? '0';

    return UniversalCard(
      onTap: () => _showLeaveDetails(leave),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppThemeUnified.spaceXS),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusXS),
                ),
                child: Icon(
                  _getLeaveTypeIcon(leaveType),
                  size: 16,
                  color: AppThemeUnified.textPrimary,
                ),
              ),
              const SizedBox(width: AppThemeUnified.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveType,
                      style: AppThemeUnified.titleMedium,
                    ),
                    Text(
                      '$fromDate to $toDate',
                      style: AppThemeUnified.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemeUnified.spaceXS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius:
                          BorderRadius.circular(AppThemeUnified.radiusXS),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: AppThemeUnified.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$days days',
                    style: AppThemeUnified.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceCard(String leaveType, dynamic balanceData) {
    String allocated = '0';
    String used = '0';
    String remaining = '0';

    if (balanceData is Map<String, dynamic>) {
      allocated = balanceData['allocated_leaves']?.toString() ?? '0';
      used = balanceData['leaves_taken']?.toString() ?? '0';
      remaining = balanceData['remaining_leaves']?.toString() ?? '0';
    }

    final progress =
        double.tryParse(allocated) != null && double.parse(allocated) > 0
            ? double.tryParse(used)! / double.parse(allocated)
            : 0.0;

    return UniversalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppThemeUnified.spaceXS),
                decoration: BoxDecoration(
                  color: _getLeaveTypeColor(leaveType),
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusXS),
                ),
                child: Icon(
                  _getLeaveTypeIcon(leaveType),
                  size: 16,
                  color: AppThemeUnified.textPrimary,
                ),
              ),
              const SizedBox(width: AppThemeUnified.spaceSM),
              Expanded(
                child: Text(
                  leaveType,
                  style: AppThemeUnified.titleMedium,
                ),
              ),
              Text(
                remaining,
                style: AppThemeUnified.displaySmall.copyWith(
                  color: _getLeaveTypeColor(leaveType),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppThemeUnified.spaceMD),

          // Progress indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Used: $used',
                    style: AppThemeUnified.bodySmall,
                  ),
                  Text(
                    'Allocated: $allocated',
                    style: AppThemeUnified.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppThemeUnified.spaceXS),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppThemeUnified.glassLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getLeaveTypeColor(leaveType),
                ),
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusXS),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppThemeUnified.success;
      case 'pending':
      case 'open':
        return AppThemeUnified.warning;
      case 'rejected':
      case 'cancelled':
        return AppThemeUnified.error;
      default:
        return AppThemeUnified.glassMedium;
    }
  }

  Color _getLeaveTypeColor(String leaveType) {
    final type = leaveType.toLowerCase();
    if (type.contains('casual')) return AppThemeUnified.primaryRoyalBlue;
    if (type.contains('sick')) return AppThemeUnified.error;
    if (type.contains('annual')) return AppThemeUnified.success;
    if (type.contains('maternity') || type.contains('paternity'))
      return const Color(0xFF9C27B0);
    return AppThemeUnified.secondaryOceanBlue;
  }

  IconData _getLeaveTypeIcon(String leaveType) {
    final type = leaveType.toLowerCase();
    if (type.contains('casual')) return Icons.event_note;
    if (type.contains('sick')) return Icons.local_hospital;
    if (type.contains('annual')) return Icons.beach_access;
    if (type.contains('maternity') || type.contains('paternity'))
      return Icons.child_care;
    return Icons.event;
  }

  void _showLeaveDetails(Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeUnified.glassDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
        ),
        title: Text(
          'Leave Details',
          style: AppThemeUnified.titleLarge,
        ),
        content: Text(
          'Leave application details will be shown here.',
          style: AppThemeUnified.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppThemeUnified.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeUnified.glassDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
        ),
        title: Text(
          'Apply for Leave',
          style: AppThemeUnified.titleLarge,
        ),
        content: Text(
          'Leave application form will be shown here.',
          style: AppThemeUnified.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppThemeUnified.labelLarge,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle leave application
            },
            child: Text(
              'Apply',
              style: AppThemeUnified.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
