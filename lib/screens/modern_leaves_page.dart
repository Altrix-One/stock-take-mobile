import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/widgets/modern_ui_components.dart';
import 'package:stock_count/widgets/modern_enhanced_cards.dart';
import 'package:stock_count/hr/widgets/leave_balance_card.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'dart:async';

class ModernLeavesPage extends StatefulWidget {
  const ModernLeavesPage({super.key});

  @override
  State<ModernLeavesPage> createState() => _ModernLeavesPageState();
}

class _ModernLeavesPageState extends State<ModernLeavesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _leaveBalance;
  List<dynamic> _myLeaves = [];
  List<dynamic> _teamLeaves = [];
  List<dynamic> _leaveTypes = [];
  bool _canApprove = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeavesData();
    
    // Listen to outbox queue changes
    OutboxQueue.events.listen((_) {
      if (mounted) _loadLeavesData();
    });
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadLeavesData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadLeavesData() async {
    try {
      final results = await Future.wait([
        LeavesService.leaveBalanceWithPending(),
        LeavesService.myLeaves(),
        LeavesService.leaveTypes(),
        _checkApprovalRights(),
      ]);
      
      if (mounted) {
        setState(() {
          _leaveBalance = results[0] as Map<String, dynamic>?;
          _myLeaves = results[1] as List<dynamic>;
          _leaveTypes = results[2] as List<dynamic>;
          _isLoading = false;
        });
      }
      
      if (_canApprove) {
        final teamLeaves = await LeavesService.teamLeaves();
        if (mounted) {
          setState(() {
            _teamLeaves = teamLeaves;
          });
        }
      }
    } catch (e) {
      print('Error loading leaves data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<bool> _checkApprovalRights() async {
    try {
      // You can implement role checking logic here
      // For now, return false as default
      return false;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernDesignSystem.getSurfaceColor(Theme.of(context).brightness),
              ModernDesignSystem.getSurfaceVariant(Theme.of(context).brightness),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading 
                    ? const ModernLoadingIndicator(message: 'Loading leaves data...')
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMyLeavesTab(),
                          _buildLeaveBalanceTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeaveForm,
        backgroundColor: ModernDesignSystem.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Apply Leave',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Leaves',
                  style: ModernDesignSystem.displaySmall.copyWith(
                    color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ModernDesignSystem.verticalSpaceMicro,
                Text(
                  'Manage your leave applications',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadLeavesData,
            icon: Icon(
              Icons.refresh,
              color: ModernDesignSystem.primaryTeal,
            ),
            style: IconButton.styleFrom(
              backgroundColor: ModernDesignSystem.primaryTeal.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: ModernDesignSystem.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        border: Border.all(
          color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          color: ModernDesignSystem.primaryTeal,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
        labelStyle: ModernDesignSystem.labelLarge.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: ModernDesignSystem.labelLarge,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'My Applications'),
          Tab(text: 'Leave Balance'),
        ],
      ),
    );
  }
  
  Widget _buildMyLeavesTab() {
    return RefreshIndicator(
      onRefresh: _loadLeavesData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            _buildQuickStats(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Leave Applications
            _buildLeaveApplications(),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeaveBalanceTab() {
    return RefreshIndicator(
      onRefresh: _loadLeavesData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Leave Balance Cards
            if (_leaveBalance != null)
              LeaveBalanceCard(balances: _leaveBalance),
            
            ModernDesignSystem.verticalSpaceLG,
            
            // Leave Policy Info
            _buildLeavePolicyInfo(),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    final pendingCount = _myLeaves.where((leave) {
      if (leave is Map) {
        final status = (leave['status']?.toString() ?? '').toLowerCase();
        return status == 'open' || status == 'pending' || status == 'draft';
      }
      return false;
    }).length;
    
    final approvedCount = _myLeaves.where((leave) {
      if (leave is Map) {
        final status = (leave['status']?.toString() ?? '').toLowerCase();
        return status == 'approved' || status == 'sanctioned';
      }
      return false;
    }).length;
    
    final totalLeaves = _getTotalLeaveBalance();
    
    return ModernHeroCard(
      title: 'Leave Summary',
      icon: Icons.analytics,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Balance', totalLeaves, Icons.event_available, ModernDesignSystem.success),
          ),
          ModernDesignSystem.horizontalSpaceXS,
          Expanded(
            child: _buildStatCard('Pending', pendingCount.toString(), Icons.hourglass_empty, ModernDesignSystem.warning),
          ),
          ModernDesignSystem.horizontalSpaceXS,
          Expanded(
            child: _buildStatCard('Approved', approvedCount.toString(), Icons.check_circle, ModernDesignSystem.success),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.spaceSM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          ModernDesignSystem.verticalSpaceXS,
          Text(
            value,
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          ModernDesignSystem.verticalSpaceMicro,
          Text(
            label,
            style: ModernDesignSystem.captionLarge.copyWith(
              color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaveApplications() {
    if (_myLeaves.isEmpty) {
      return ModernEmptyState(
        icon: Icons.event_note,
        title: 'No Leave Applications',
        subtitle: 'You haven\'t applied for any leaves yet',
        actionText: 'Apply for Leave',
        onAction: _showApplyLeaveForm,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Leave Applications',
          subtitle: '${_myLeaves.length} applications',
          icon: Icons.list_alt,
        ),
        
        ..._myLeaves.map((leave) => _buildLeaveItem(leave as Map<String, dynamic>)),
      ],
    );
  }
  
  Widget _buildLeaveItem(Map<String, dynamic> leave) {
    final status = leave['status']?.toString() ?? '';
    final leaveType = leave['leave_type']?.toString() ?? '';
    final fromDate = leave['from_date']?.toString() ?? '';
    final toDate = leave['to_date']?.toString() ?? '';
    final totalDays = leave['total_leave_days']?.toString() ?? '0';
    final reason = leave['description']?.toString() ?? '';
    
    Color statusColor = ModernDesignSystem.neutralMedium;
    IconData statusIcon = Icons.info;
    
    switch (status.toLowerCase()) {
      case 'approved':
      case 'sanctioned':
        statusColor = ModernDesignSystem.success;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
      case 'cancelled':
        statusColor = ModernDesignSystem.error;
        statusIcon = Icons.cancel;
        break;
      case 'open':
      case 'pending':
      case 'draft':
        statusColor = ModernDesignSystem.warning;
        statusIcon = Icons.hourglass_empty;
        break;
    }
    
    return ModernInfoCard(
      title: leaveType,
      subtitle: '$fromDate to $toDate ($totalDays days)',
      badge: status.toUpperCase(),
      badgeColor: statusColor,
      icon: Icons.event_note,
      iconColor: statusColor,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
      actions: status.toLowerCase() == 'draft' || status.toLowerCase() == 'open' ? [
        TextButton.icon(
          onPressed: () => _cancelLeave(leave),
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: ModernDesignSystem.error,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ] : null,
      onTap: () => _showLeaveDetails(leave),
    );
  }
  
  Widget _buildLeavePolicyInfo() {
    if (_leaveTypes.isEmpty) {
      return ModernEmptyState(
        icon: Icons.policy,
        title: 'No Leave Types Available',
        subtitle: 'Leave type information will appear here',
      );
    }
    
    return ModernHeroCard(
      title: 'Leave Types',
      icon: Icons.policy,
      child: Column(
        children: _leaveTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final leaveType = entry.value.toString();
          
          // Dynamic icons based on leave type
          IconData getIcon(String type) {
            final lowerType = type.toLowerCase();
            if (lowerType.contains('annual') || lowerType.contains('vacation')) {
              return Icons.beach_access;
            } else if (lowerType.contains('sick') || lowerType.contains('medical')) {
              return Icons.local_hospital;
            } else if (lowerType.contains('casual') || lowerType.contains('personal')) {
              return Icons.person;
            } else if (lowerType.contains('maternity') || lowerType.contains('paternity')) {
              return Icons.family_restroom;
            } else if (lowerType.contains('emergency')) {
              return Icons.warning;
            } else {
              return Icons.event_available;
            }
          }
          
          // Dynamic colors
          final colors = [
            ModernDesignSystem.primaryTeal,
            ModernDesignSystem.success,
            ModernDesignSystem.warning,
            ModernDesignSystem.info,
            ModernDesignSystem.error,
          ];
          final color = colors[index % colors.length];
          
          // Dynamic descriptions based on balance data
          String getDescription(String type) {
            if (_leaveBalance != null && _leaveBalance!.containsKey(type)) {
              final balance = _leaveBalance![type];
              if (balance is Map) {
                final allocated = balance['allocated_leaves']?.toString() ?? '0';
                final remaining = balance['balance_leaves']?.toString() ?? '0';
                return '$remaining of $allocated days remaining';
              }
            }
            return 'Available for use as per policy';
          }
          
          return Column(
            children: [
              if (index > 0) ModernDesignSystem.verticalSpaceSM,
              _buildPolicyItem(
                leaveType,
                getDescription(leaveType),
                getIcon(leaveType),
                color,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildPolicyItem(String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        ModernDesignSystem.horizontalSpaceSM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ModernDesignSystem.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                ),
              ),
              Text(
                description,
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getTotalLeaveBalance() {
    if (_leaveBalance == null) return '0';
    
    int total = 0;
    _leaveBalance!.forEach((key, value) {
      if (value is Map && value['remaining_leaves'] != null) {
        total += (value['remaining_leaves'] as num).round();
      }
    });
    
    return total.toString();
  }
  
  void _showApplyLeaveForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ApplyLeaveFormPage(),
      ),
    ).then((_) => _loadLeavesData());
  }
  
  void _showLeaveDetails(Map<String, dynamic> leave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeaveDetailsBottomSheet(leave: leave),
    );
  }
  
  Future<void> _cancelLeave(Map<String, dynamic> leave) async {
    final name = leave['name']?.toString();
    if (name == null || name.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Cancel Leave Application'),
        content: const Text('Are you sure you want to cancel this leave application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ModernPrimaryButton(
            text: 'Yes, Cancel',
            onPressed: () => Navigator.of(context).pop(true),
            padding: const EdgeInsets.symmetric(
              horizontal: ModernDesignSystem.spaceMD,
              vertical: ModernDesignSystem.spaceXS,
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await LeavesService.cancelLeaveApplication(name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Leave application cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLeavesData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cancelling leave: $e')),
          );
        }
      }
    }
  }
}

// Apply Leave Form Page
class ApplyLeaveFormPage extends StatefulWidget {
  const ApplyLeaveFormPage({super.key});
  
  @override
  State<ApplyLeaveFormPage> createState() => _ApplyLeaveFormPageState();
}

class _ApplyLeaveFormPageState extends State<ApplyLeaveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isSubmitting = false;
  bool _isLoadingLeaveTypes = true;
  
  List<String> _leaveTypes = [];
  
  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  Future<void> _loadLeaveTypes() async {
    try {
      final types = await LeavesService.leaveTypes();
      if (mounted) {
        setState(() {
          _leaveTypes = types.map((type) => type.toString()).toList();
          _isLoadingLeaveTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _leaveTypes = [
            'Annual Leave',
            'Sick Leave', 
            'Casual Leave',
            'Maternity Leave',
            'Paternity Leave',
            'Emergency Leave',
          ];
          _isLoadingLeaveTypes = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernDesignSystem.getSurfaceColor(Theme.of(context).brightness),
              ModernDesignSystem.getSurfaceVariant(Theme.of(context).brightness),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ModernAppBar(
                title: 'Apply for Leave',
                showBackButton: true,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildLeaveTypeSelector(),
                        ModernDesignSystem.verticalSpaceMD,
                        
                        _buildDateSelectors(),
                        ModernDesignSystem.verticalSpaceMD,
                        
                        _buildReasonField(),
                        ModernDesignSystem.verticalSpaceXL,
                        
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaveTypeSelector() {
    return ModernHeroCard(
      title: 'Leave Type',
      icon: Icons.category,
      child: _isLoadingLeaveTypes
          ? Container(
              padding: const EdgeInsets.all(ModernDesignSystem.spaceLG),
              child: const Center(
                child: CircularProgressIndicator(
                  color: ModernDesignSystem.primaryTeal,
                ),
              ),
            )
          : DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              decoration: InputDecoration(
                hintText: 'Select leave type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                  borderSide: BorderSide(color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness)),
                ),
                contentPadding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
              ),
              items: _leaveTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() => _selectedLeaveType = value);
              }
            },
              validator: (value) => value == null ? 'Please select a leave type' : null,
            ),
    );
  }
  
  Widget _buildDateSelectors() {
    return ModernHeroCard(
      title: 'Leave Duration',
      icon: Icons.date_range,
      child: Row(
        children: [
          Expanded(
            child: _buildDateSelector(
              'From Date',
              _fromDate,
              (date) {
                if (mounted) {
                  setState(() => _fromDate = date);
                }
              },
            ),
          ),
          ModernDesignSystem.horizontalSpaceMD,
          Expanded(
            child: _buildDateSelector(
              'To Date',
              _toDate,
              (date) {
                if (mounted) {
                  setState(() => _toDate = date);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ModernDesignSystem.labelLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
          ),
        ),
        ModernDesignSystem.verticalSpaceXS,
        
        InkWell(
          onTap: () => _selectDate(onDateSelected),
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          child: Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            decoration: BoxDecoration(
              border: Border.all(color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness)),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: ModernDesignSystem.primaryTeal,
                ),
                ModernDesignSystem.horizontalSpaceXS,
                Text(
                  date != null 
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: date != null 
                        ? ModernDesignSystem.getTextPrimary(Theme.of(context).brightness)
                        : ModernDesignSystem.getTextTertiary(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildReasonField() {
    return ModernHeroCard(
      title: 'Reason for Leave',
      icon: Icons.edit_note,
      child: ModernInputField(
        controller: _reasonController,
        hint: 'Please provide a reason for your leave...',
        maxLines: 4,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please provide a reason for your leave';
          }
          if (value.trim().length < 10) {
            return 'Please provide a more detailed reason (at least 10 characters)';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildSubmitButton() {
    return ModernPrimaryButton(
      text: 'Submit Leave Application',
      isLoading: _isSubmitting,
      onPressed: _submitLeaveApplication,
      icon: Icons.send,
    );
  }
  
  Future<void> _selectDate(Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ModernDesignSystem.primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      onDateSelected(date);
    }
  }
  
  Future<void> _submitLeaveApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both from and to dates')),
      );
      return;
    }
    
    if (_fromDate!.isAfter(_toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From date cannot be after to date')),
      );
      return;
    }
    
    if (mounted) {
      setState(() => _isSubmitting = true);
    }
    
    try {
      await LeavesService.applyLeave({
        'leave_type': _selectedLeaveType!,
        'from_date': _fromDate!.toIso8601String().split('T')[0],
        'to_date': _toDate!.toIso8601String().split('T')[0],
        'description': _reasonController.text.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Leave application submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting leave: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Leave Details Bottom Sheet
class LeaveDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> leave;
  
  const LeaveDetailsBottomSheet({super.key, required this.leave});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: ModernDesignSystem.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ModernDesignSystem.radiusLG),
          topRight: Radius.circular(ModernDesignSystem.radiusLG),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Leave Details',
                    style: ModernDesignSystem.headlineMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
              child: Column(
                children: [
                  _buildDetailItem(context, 'Leave Type', leave['leave_type']?.toString() ?? ''),
                  _buildDetailItem(context, 'From Date', leave['from_date']?.toString() ?? ''),
                  _buildDetailItem(context, 'To Date', leave['to_date']?.toString() ?? ''),
                  _buildDetailItem(context, 'Total Days', leave['total_leave_days']?.toString() ?? '0'),
                  _buildDetailItem(context, 'Status', leave['status']?.toString() ?? ''),
                  _buildDetailItem(context, 'Reason', leave['description']?.toString() ?? ''),
                  if (leave['posting_date'] != null)
                    _buildDetailItem(context, 'Applied On', leave['posting_date']?.toString() ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ModernDesignSystem.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ModernDesignSystem.bodyMedium.copyWith(
                color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}