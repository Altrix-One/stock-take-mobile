import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/approvals_service.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/constants/app_theme_unified.dart';
import 'package:stock_count/widgets/modern_ui_components.dart';
import 'package:stock_count/widgets/universal_scaffold.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'dart:async';

class ModernApprovalsPage extends StatefulWidget {
  const ModernApprovalsPage({super.key});

  @override
  State<ModernApprovalsPage> createState() => _ModernApprovalsPageState();
}

class _ModernApprovalsPageState extends State<ModernApprovalsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _pendingApprovals = [];
  List<dynamic> _myApprovals = [];
  List<dynamic> _teamMembers = [];
  Timer? _refreshTimer;
  Map<String, dynamic> _approvalsStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApprovalsData();
    
    // Listen to outbox queue changes
    OutboxQueue.events.listen((_) {
      if (mounted) _loadApprovalsData();
    });
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadApprovalsData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadApprovalsData() async {
    try {
      final results = await Future.wait([
        ApprovalsService.pendingApprovals(),
        ApprovalsService.myApprovals(),
        ApprovalsService.teamMembers(),
        ApprovalsService.approvalsStats(),
      ]);
      
      if (mounted) {
        setState(() {
          _pendingApprovals = results[0] as List<dynamic>;
          _myApprovals = results[1] as List<dynamic>;
          _teamMembers = results[2] as List<dynamic>;
          _approvalsStats = results[3] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading approvals data: $e');
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
        title: 'Approvals',
        actions: [
          if (_pendingApprovals.isNotEmpty) 
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppThemeUnified.spaceXS,
                vertical: AppThemeUnified.spaceXS,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_pendingApprovals.length}',
                    style: AppThemeUnified.labelSmall.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            onPressed: _loadApprovalsData,
            icon: Icon(
              Icons.refresh,
              color: AppThemeUnified.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppThemeUnified.glassLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? UniversalLoading(message: 'Loading approvals data...')
          : SafeArea(
              child: Column(
                children: [
                  SizedBox(height: AppThemeUnified.spaceSM),
                  _buildTabBar(),
                  SizedBox(height: AppThemeUnified.spaceMD),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPendingTab(),
                        _buildHistoryTab(),
                        _buildTeamTab(),
                      ],
                    ),
                  ),
                ],
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
                  'Approvals',
                  style: ModernDesignSystem.displaySmall.copyWith(
                    color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ModernDesignSystem.verticalSpaceMicro,
                Text(
                  'Manage team requests and approvals',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernDesignSystem.spaceXS,
              vertical: ModernDesignSystem.spaceMicro,
            ),
            decoration: BoxDecoration(
              color: ModernDesignSystem.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pending_actions,
                  size: 16,
                  color: ModernDesignSystem.error,
                ),
                ModernDesignSystem.horizontalSpaceMicro,
                Text(
                  '${_pendingApprovals.length}',
                  style: ModernDesignSystem.labelMedium.copyWith(
                    color: ModernDesignSystem.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ModernDesignSystem.horizontalSpaceXS,
          IconButton(
            onPressed: _loadApprovalsData,
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
    return AppThemeUnified.glassContainer(
      margin: EdgeInsets.symmetric(horizontal: AppThemeUnified.spaceMD),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppThemeUnified.radiusMD),
          color: AppThemeUnified.primaryRoyalBlue,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppThemeUnified.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 0,
        dividerColor: Colors.transparent,
        labelStyle: AppThemeUnified.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppThemeUnified.labelLarge,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pending'),
                if (_pendingApprovals.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_pendingApprovals.length}',
                      style: AppThemeUnified.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'History'),
          const Tab(text: 'Team'),
        ],
      ),
    );
  }
  
  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: _loadApprovalsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppThemeUnified.spaceMD).copyWith(
          top: AppThemeUnified.spaceLG,
        ),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Pending Approvals
            _buildPendingApprovals(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadApprovalsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Monthly Overview
            _buildMonthlyOverview(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Approval History
            _buildApprovalHistory(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTeamTab() {
    return RefreshIndicator(
      onRefresh: _loadApprovalsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Team Overview
            _buildTeamOverview(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Team Members
            _buildTeamMembers(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    final pendingCount = _approvalsStats['pending_count']?.toString() ?? '0';
    final approvedToday = _approvalsStats['approved_today']?.toString() ?? '0';
    final averageTime = _approvalsStats['average_approval_time']?.toString() ?? '0';
    
    return Row(
      children: [
        Expanded(
          child: ModernStatsCard(
            label: 'Pending',
            value: pendingCount,
            icon: Icons.pending_actions,
            color: ModernDesignSystem.warning,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Approved Today',
            value: approvedToday,
            icon: Icons.check_circle,
            color: ModernDesignSystem.success,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Avg Time (hrs)',
            value: averageTime,
            icon: Icons.schedule,
            color: ModernDesignSystem.info,
            isCompact: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPendingApprovals() {
    if (_pendingApprovals.isEmpty) {
      return ModernEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Caught Up!',
        subtitle: 'No pending approvals at the moment',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Pending Approvals',
          subtitle: '${_pendingApprovals.length} items require your attention',
          icon: Icons.pending_actions,
        ),
        
        ...(_pendingApprovals.map((approval) => _buildApprovalItem(approval as Map<String, dynamic>, isPending: true))),
      ],
    );
  }
  
  Widget _buildApprovalItem(Map<String, dynamic> approval, {bool isPending = false}) {
    final id = approval['id']?.toString() ?? '';
    final type = approval['type']?.toString() ?? '';
    final title = approval['title']?.toString() ?? 'Approval Request';
    // Try multiple fields for requester name with better fallbacks
    final requesterName = approval['requester_name']?.toString() ?? 
                          approval['employee_name']?.toString() ?? 
                          approval['employee']?.toString() ?? 
                          'Unknown Requester';
    final submittedDate = approval['submitted_date']?.toString() ?? '';
    final amount = approval['amount']?.toString();
    final status = approval['status']?.toString() ?? 'Pending';
    final priority = approval['priority']?.toString() ?? 'Normal';
    
    IconData typeIcon = Icons.help_outline;
    Color typeColor = ModernDesignSystem.primaryTeal;
    
    switch (type.toLowerCase()) {
      case 'leave':
        typeIcon = Icons.event_busy;
        typeColor = ModernDesignSystem.info;
        break;
      case 'expense':
      case 'claim':
        typeIcon = Icons.receipt;
        typeColor = ModernDesignSystem.warning;
        break;
      case 'attendance':
        typeIcon = Icons.access_time;
        typeColor = ModernDesignSystem.success;
        break;
      case 'overtime':
        typeIcon = Icons.schedule;
        typeColor = ModernDesignSystem.primaryNavy;
        break;
    }
    
    Color priorityColor = ModernDesignSystem.neutralLight;
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        priorityColor = ModernDesignSystem.error;
        break;
      case 'medium':
        priorityColor = ModernDesignSystem.warning;
        break;
      case 'low':
        priorityColor = ModernDesignSystem.success;
        break;
    }
    
    // Build more detailed subtitle
    String subtitle = 'Requested by $requesterName';
    
    // Add date information
    final fromDate = approval['from_date']?.toString();
    final toDate = approval['to_date']?.toString();
    if (fromDate != null && toDate != null) {
      subtitle += ' • $fromDate to $toDate';
    } else if (submittedDate.isNotEmpty) {
      subtitle += ' • Submitted: ${submittedDate.split(' ')[0]}'; // Just the date part
    }
    
    // Add amount or days information
    if (amount != null) {
      try {
        final value = double.parse(amount);
        subtitle += ' • \$${value.toStringAsFixed(2)}';
      } catch (e) {
        subtitle += ' • $amount';
      }
    } else {
      final totalDays = approval['total_leave_days']?.toString();
      if (totalDays != null && totalDays.isNotEmpty) {
        subtitle += ' • $totalDays days';
      }
    }
    
    // Add leave type for leave applications
    final leaveType = approval['leave_type']?.toString();
    if (leaveType != null && leaveType.isNotEmpty && !title.contains(leaveType)) {
      subtitle += ' • $leaveType';
    }
    
    return ModernInfoCard(
      title: title.isNotEmpty ? title : _generateBetterTitle(approval, type, requesterName),
      subtitle: subtitle,
      badge: _getBadgeText(approval, type, status),
      badgeColor: typeColor,
      icon: typeIcon,
      iconColor: typeColor,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
      onTap: () => _showApprovalDetails(approval),
      actions: isPending ? [
          PopupMenuButton<String>(
            onSelected: (action) => _handleApprovalAction(approval, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Approve'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Reject'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                size: 20,
              ),
            ),
          )
      ] : null,
    );
  }
  
  Widget _buildMonthlyOverview() {
    final thisMonth = DateTime.now();
    final thisMonthApproved = _approvalsStats['this_month_approved']?.toString() ?? '0';
    final thisMonthRejected = _approvalsStats['this_month_rejected']?.toString() ?? '0';
    final myPendingCount = _approvalsStats['my_pending_count']?.toString() ?? '0';
    
    return ModernHeroCard(
      title: 'Monthly Overview',
      subtitle: '${thisMonth.month}/${thisMonth.year}',
      icon: Icons.insights,
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewItem('Approved', thisMonthApproved, Icons.check_circle, ModernDesignSystem.success),
          ),
          Expanded(
            child: _buildOverviewItem('Pending', myPendingCount, Icons.pending_actions, ModernDesignSystem.warning),
          ),
          Expanded(
            child: _buildOverviewItem('Rejected', thisMonthRejected, Icons.cancel, ModernDesignSystem.error),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        ModernDesignSystem.verticalSpaceXS,
        Text(
          value,
          style: ModernDesignSystem.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
          ),
        ),
        Text(
          label,
          style: ModernDesignSystem.captionLarge.copyWith(
            color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildApprovalHistory() {
    if (_myApprovals.isEmpty) {
      return ModernEmptyState(
        icon: Icons.history,
        title: 'No Approval History',
        subtitle: 'Your approval history will appear here',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Recent Approvals',
          subtitle: '${_myApprovals.length} items',
          icon: Icons.history,
        ),
        
        ...(_myApprovals.take(10).map((approval) => _buildApprovalItem(approval as Map<String, dynamic>))),
        
        if (_myApprovals.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: ModernDesignSystem.spaceMD),
            child: Center(
              child: ModernSecondaryButton(
                text: 'View All History',
                onPressed: _showFullHistory,
                icon: Icons.list,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTeamOverview() {
    final activeMembers = _teamMembers.where((member) => member['is_active'] == true).length;
    final onLeaveToday = _approvalsStats['on_leave_today']?.toString() ?? '0';
    final avgTeamRating = _approvalsStats['avg_team_rating']?.toString() ?? '0.0';
    
    return ModernHeroCard(
      title: 'Team Overview',
      subtitle: 'Current team status',
      icon: Icons.groups,
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewItem('Active Members', activeMembers.toString(), Icons.person, ModernDesignSystem.primaryTeal),
          ),
          Expanded(
            child: _buildOverviewItem('On Leave Today', onLeaveToday, Icons.event_busy, ModernDesignSystem.warning),
          ),
          Expanded(
            child: _buildOverviewItem('Team Rating', avgTeamRating, Icons.star, ModernDesignSystem.success),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamMembers() {
    if (_teamMembers.isEmpty) {
      return ModernEmptyState(
        icon: Icons.group_add,
        title: 'No Team Members',
        subtitle: 'Team members will appear here',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Team Members',
          subtitle: '${_teamMembers.length} members',
          icon: Icons.groups,
        ),
        
        ...(_teamMembers.map((member) => _buildTeamMemberItem(member as Map<String, dynamic>))),
      ],
    );
  }
  
  Widget _buildTeamMemberItem(Map<String, dynamic> member) {
    // Use employee_name for display, fallback to name if needed
    final name = member['employee_name']?.toString() ?? 
                 member['name']?.toString() ?? 'Unknown Employee';
    final role = member['designation']?.toString() ?? 
                 member['role']?.toString() ?? '';
    final department = member['department']?.toString() ?? '';
    final isActive = member['is_active'] ?? true;
    final lastSeen = member['last_seen']?.toString() ?? '';
    final pendingRequests = member['pending_requests']?.toString() ?? '0';
    final profilePic = member['profile_picture']?.toString();
    
    return ModernInfoCard(
      title: name,
      subtitle: role.isNotEmpty ? '$role${department.isNotEmpty ? ' • $department' : ''}' : department,
      icon: Icons.person,
      iconColor: isActive ? ModernDesignSystem.success : ModernDesignSystem.neutralLight,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
      onTap: () => _showTeamMemberDetails(member),
    );
  }
  
  Future<void> _handleApprovalAction(Map<String, dynamic> approval, String action) async {
    final id = approval['id']?.toString() ?? '';
    
    try {
      switch (action) {
        case 'approve':
          await _approveRequest(approval);
          break;
        case 'reject':
          await _rejectRequest(approval);
          break;
        case 'details':
          _showApprovalDetails(approval);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _approveRequest(Map<String, dynamic> approval) async {
    final confirmed = await _showApprovalDialog(
      title: 'Approve Request',
      content: 'Are you sure you want to approve this request?',
      approveText: 'Approve',
      approveColor: ModernDesignSystem.success,
    );
    
    if (confirmed != true) return;
    
    try {
      // Determine doctype based on approval type or use a generic approach
      final doctype = _getDocTypeFromApproval(approval);
      await ApprovalsService.approveRequest(doctype, approval['id'].toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Request approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadApprovalsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request: $e')),
        );
      }
    }
  }
  
  Future<void> _rejectRequest(Map<String, dynamic> approval) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;
    
    try {
      // Determine doctype based on approval type or use a generic approach
      final doctype = _getDocTypeFromApproval(approval);
      await ApprovalsService.rejectRequest(doctype, approval['id'].toString(), reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Request rejected'),
            backgroundColor: Colors.red,
          ),
        );
        _loadApprovalsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: $e')),
        );
      }
    }
  }
  
  Future<bool?> _showApprovalDialog({
    required String title,
    required String content,
    required String approveText,
    required Color approveColor,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: approveColor,
              foregroundColor: Colors.white,
            ),
            child: Text(approveText),
          ),
        ],
      ),
    );
  }
  
  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            ModernDesignSystem.verticalSpaceMD,
            ModernInputField(
              controller: controller,
              hint: 'Enter rejection reason...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop(reason);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  void _showApprovalDetails(Map<String, dynamic> approval) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApprovalDetailsBottomSheet(
        approval: approval,
        onApprove: () => _approveRequest(approval),
        onReject: () => _rejectRequest(approval),
      ),
    );
  }
  
  void _showTeamMemberDetails(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeamMemberDetailsBottomSheet(member: member),
    );
  }
  
  void _showFullHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApprovalsHistoryPage(approvals: _myApprovals),
      ),
    );
  }
  
  String _generateBetterTitle(Map<String, dynamic> approval, String type, String requesterName) {
    final leaveType = approval['leave_type']?.toString();
    final company = approval['company']?.toString();
    final department = approval['department']?.toString();
    
    String baseTitle = 'Request';
    
    switch (type.toLowerCase()) {
      case 'leave':
        baseTitle = leaveType != null ? '$leaveType Request' : 'Leave Request';
        break;
      case 'expense':
      case 'claim':
        baseTitle = 'Expense Claim';
        break;
      case 'attendance':
        baseTitle = 'Attendance Request';
        break;
      case 'overtime':
        baseTitle = 'Overtime Request';
        break;
      default:
        if (leaveType != null) {
          baseTitle = '$leaveType Request';
        } else if (approval.containsKey('total_claimed_amount')) {
          baseTitle = 'Expense Claim';
        }
    }
    
    return baseTitle;
  }
  
  String _getBadgeText(Map<String, dynamic> approval, String type, String status) {
    // Show more specific badge text based on status and type
    if (status.toLowerCase() == 'open' || status.toLowerCase() == 'pending') {
      return 'PENDING';
    } else if (status.toLowerCase() == 'approved' || status.toLowerCase() == 'sanctioned') {
      return 'APPROVED';
    } else if (status.toLowerCase() == 'rejected' || status.toLowerCase() == 'cancelled') {
      return 'REJECTED';
    } else {
      return status.toUpperCase();
    }
  }
  
  String _generateHistoryTitle(Map<String, dynamic> approval, String type) {
    final leaveType = approval['leave_type']?.toString();
    final company = approval['company']?.toString();
    
    switch (type.toLowerCase()) {
      case 'leave':
        return leaveType != null ? '$leaveType Application' : 'Leave Application';
      case 'expense':
      case 'claim':
        return 'Expense Claim';
      case 'attendance':
        return 'Attendance Correction';
      case 'overtime':
        return 'Overtime Request';
      default:
        if (leaveType != null) {
          return '$leaveType Application';
        } else if (approval.containsKey('total_claimed_amount')) {
          return 'Expense Claim';
        }
        return 'Approval Request';
    }
  }

  String _getDocTypeFromApproval(Map<String, dynamic> approval) {
    final type = approval['type']?.toString().toLowerCase() ?? '';
    
    switch (type) {
      case 'leave':
        return 'Leave Application';
      case 'expense':
      case 'claim':
        return 'Expense Claim';
      case 'attendance':
        return 'Attendance Request';
      case 'overtime':
        return 'Overtime Request';
      default:
        // Try to infer from other fields or use a default
        if (approval['leave_type'] != null) return 'Leave Application';
        if (approval['total_claimed_amount'] != null) return 'Expense Claim';
        if (approval['from_date'] != null && approval['reason'] != null) return 'Attendance Request';
        return 'Leave Application'; // Default fallback
    }
  }
}

// Approval Details Bottom Sheet
class ApprovalDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  
  const ApprovalDetailsBottomSheet({
    super.key,
    required this.approval,
    required this.onApprove,
    required this.onReject,
  });
  
  @override
  Widget build(BuildContext context) {
    final isPending = approval['status']?.toString().toLowerCase() == 'pending';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    'Approval Details',
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
                  // Basic Information
                  _buildDetailItem(context, 'Request Type', _getDisplayType(approval)),
                  _buildDetailItem(context, 'Title/Subject', _getDisplayTitle(approval)),
                  _buildDetailItem(context, 'Requested By', _getRequesterName(approval)),
                  _buildDetailItem(context, 'Status', _getDisplayStatus(approval)),
                  
                  // Date Information
                  if (_getSubmittedDate(approval).isNotEmpty)
                    _buildDetailItem(context, 'Submitted Date', _getSubmittedDate(approval)),
                  if (_getFromDate(approval).isNotEmpty)
                    _buildDetailItem(context, 'From Date', _getFromDate(approval)),
                  if (_getToDate(approval).isNotEmpty)
                    _buildDetailItem(context, 'To Date', _getToDate(approval)),
                  
                  // Leave-specific information
                  if (_getLeaveType(approval).isNotEmpty)
                    _buildDetailItem(context, 'Leave Type', _getLeaveType(approval)),
                  if (_getTotalDays(approval).isNotEmpty)
                    _buildDetailItem(context, 'Total Days', _getTotalDays(approval)),
                  
                  // Financial Information
                  if (_getAmount(approval).isNotEmpty)
                    _buildDetailItem(context, 'Amount', _getAmount(approval)),
                  if (_getTotalClaimedAmount(approval).isNotEmpty)
                    _buildDetailItem(context, 'Claimed Amount', _getTotalClaimedAmount(approval)),
                  
                  // Description/Reason
                  if (_getDescription(approval).isNotEmpty)
                    _buildDetailItem(context, 'Description/Reason', _getDescription(approval)),
                  
                  // Additional Information
                  if (_getCompany(approval).isNotEmpty)
                    _buildDetailItem(context, 'Company', _getCompany(approval)),
                  if (_getDepartment(approval).isNotEmpty)
                    _buildDetailItem(context, 'Department', _getDepartment(approval)),
                  
                  // Approval workflow information
                  if (_getApprover(approval).isNotEmpty)
                    _buildDetailItem(context, 'Approver', _getApprover(approval)),
                  if (_getApprovalDate(approval).isNotEmpty)
                    _buildDetailItem(context, 'Approval Date', _getApprovalDate(approval)),
                  if (_getRejectionReason(approval).isNotEmpty)
                    _buildDetailItem(context, 'Rejection Reason', _getRejectionReason(approval)),
                  
                  // Attachments
                  if (approval['attachments'] != null && (approval['attachments'] as List).isNotEmpty)
                    _buildAttachmentsSection(context, approval['attachments'] as List),
                    
                  // Raw data for debugging (only show if other fields are empty)
                  if (_shouldShowDebugInfo(approval))
                    _buildDebugSection(context, approval),
                ],
              ),
            ),
          ),
          
          if (isPending)
            Container(
              padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ModernSecondaryButton(
                      text: 'Reject',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReject();
                      },
                      icon: Icons.cancel,
                    ),
                  ),
                  ModernDesignSystem.horizontalSpaceMD,
                  Expanded(
                    child: ModernPrimaryButton(
                      text: 'Approve',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onApprove();
                      },
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
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
            width: 120,
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
  
  // Helper methods for extracting approval data
  String _getDisplayType(Map<String, dynamic> approval) {
    return approval['type']?.toString() ?? 
           approval['doctype']?.toString() ?? 
           _inferTypeFromFields(approval) ?? 
           'Request';
  }
  
  String _getDisplayTitle(Map<String, dynamic> approval) {
    return approval['title']?.toString() ?? 
           approval['subject']?.toString() ?? 
           approval['name']?.toString() ?? 
           _generateTitleFromType(approval) ?? 
           'Approval Request';
  }
  
  String _getRequesterName(Map<String, dynamic> approval) {
    return approval['requester_name']?.toString() ?? 
           approval['employee_name']?.toString() ?? 
           approval['employee']?.toString() ?? 
           approval['owner']?.toString() ?? 
           approval['created_by']?.toString() ?? 
           'Unknown Requester';
  }
  
  String _getDisplayStatus(Map<String, dynamic> approval) {
    final status = approval['status']?.toString() ?? 
                  approval['workflow_state']?.toString() ?? 
                  'Unknown';
    return status.replaceAll('_', ' ').toUpperCase();
  }
  
  String _getSubmittedDate(Map<String, dynamic> approval) {
    return approval['submitted_date']?.toString() ?? 
           approval['posting_date']?.toString() ?? 
           approval['creation']?.toString() ?? 
           '';
  }
  
  String _getFromDate(Map<String, dynamic> approval) {
    return approval['from_date']?.toString() ?? '';
  }
  
  String _getToDate(Map<String, dynamic> approval) {
    return approval['to_date']?.toString() ?? '';
  }
  
  String _getLeaveType(Map<String, dynamic> approval) {
    return approval['leave_type']?.toString() ?? '';
  }
  
  String _getTotalDays(Map<String, dynamic> approval) {
    final days = approval['total_leave_days']?.toString() ?? 
                approval['total_days']?.toString() ?? '';
    return days.isNotEmpty ? '$days days' : '';
  }
  
  String _getAmount(Map<String, dynamic> approval) {
    final amount = approval['amount']?.toString() ?? '';
    if (amount.isNotEmpty) {
      try {
        final value = double.parse(amount);
        return '\$${value.toStringAsFixed(2)}';
      } catch (e) {
        return amount;
      }
    }
    return '';
  }
  
  String _getTotalClaimedAmount(Map<String, dynamic> approval) {
    final amount = approval['total_claimed_amount']?.toString() ?? 
                  approval['grand_total']?.toString() ?? '';
    if (amount.isNotEmpty) {
      try {
        final value = double.parse(amount);
        return '\$${value.toStringAsFixed(2)}';
      } catch (e) {
        return amount;
      }
    }
    return '';
  }
  
  String _getDescription(Map<String, dynamic> approval) {
    return approval['description']?.toString() ?? 
           approval['reason']?.toString() ?? 
           approval['remarks']?.toString() ?? 
           approval['purpose']?.toString() ?? 
           '';
  }
  
  String _getCompany(Map<String, dynamic> approval) {
    return approval['company']?.toString() ?? '';
  }
  
  String _getDepartment(Map<String, dynamic> approval) {
    return approval['department']?.toString() ?? '';
  }
  
  String _getApprover(Map<String, dynamic> approval) {
    return approval['approved_by']?.toString() ?? 
           approval['leave_approver']?.toString() ?? 
           approval['expense_approver']?.toString() ?? 
           '';
  }
  
  String _getApprovalDate(Map<String, dynamic> approval) {
    return approval['approval_date']?.toString() ?? 
           approval['approved_on']?.toString() ?? '';
  }
  
  String _getRejectionReason(Map<String, dynamic> approval) {
    return approval['rejection_reason']?.toString() ?? 
           approval['rejection_remarks']?.toString() ?? '';
  }
  
  String? _inferTypeFromFields(Map<String, dynamic> approval) {
    if (approval.containsKey('leave_type')) return 'Leave Application';
    if (approval.containsKey('total_claimed_amount')) return 'Expense Claim';
    if (approval.containsKey('attendance_date')) return 'Attendance Request';
    if (approval.containsKey('overtime_hours')) return 'Overtime Request';
    return null;
  }
  
  String? _generateTitleFromType(Map<String, dynamic> approval) {
    final type = _getDisplayType(approval).toLowerCase();
    final requester = _getRequesterName(approval);
    
    if (type.contains('leave')) {
      final leaveType = _getLeaveType(approval);
      return leaveType.isNotEmpty ? '$leaveType Request' : 'Leave Request';
    } else if (type.contains('expense')) {
      return 'Expense Claim Request';
    } else if (type.contains('attendance')) {
      return 'Attendance Correction Request';
    } else if (type.contains('overtime')) {
      return 'Overtime Request';
    }
    return null;
  }
  
  bool _shouldShowDebugInfo(Map<String, dynamic> approval) {
    // Show debug info if most display fields are empty
    final hasBasicInfo = _getDisplayType(approval) != 'Request' ||
                        _getDisplayTitle(approval) != 'Approval Request' ||
                        _getRequesterName(approval) != 'Unknown Requester';
    return !hasBasicInfo;
  }
  
  Widget _buildDebugSection(BuildContext context, Map<String, dynamic> approval) {
    return Container(
      margin: const EdgeInsets.only(top: ModernDesignSystem.spaceLG),
      padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: ModernDesignSystem.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
        border: Border.all(
          color: ModernDesignSystem.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: ModernDesignSystem.warning,
                size: 16,
              ),
              ModernDesignSystem.horizontalSpaceXS,
              Text(
                'Debug Information',
                style: ModernDesignSystem.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernDesignSystem.warning,
                ),
              ),
            ],
          ),
          ModernDesignSystem.verticalSpaceXS,
          Text(
            'Available fields: ${approval.keys.join(', ')}',
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
            ),
          ),
          if (approval.isNotEmpty) ...[
            ModernDesignSystem.verticalSpaceXS,
            ...approval.entries.take(10).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: ${entry.value?.toString() ?? 'null'}',
                style: ModernDesignSystem.captionLarge.copyWith(
                  color: ModernDesignSystem.getTextTertiary(Theme.of(context).brightness),
                ),
              ),
            )),
            if (approval.length > 10)
              Text(
                '... and ${approval.length - 10} more fields',
                style: ModernDesignSystem.captionLarge.copyWith(
                  color: ModernDesignSystem.getTextTertiary(Theme.of(context).brightness),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, List attachments) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments',
            style: ModernDesignSystem.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
            ),
          ),
          ModernDesignSystem.verticalSpaceXS,
          ...attachments.map((attachment) => Container(
            margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceXS),
            padding: const EdgeInsets.all(ModernDesignSystem.spaceSM),
            decoration: BoxDecoration(
              color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness).withOpacity(0.5),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: ModernDesignSystem.primaryTeal,
                  size: 20,
                ),
                ModernDesignSystem.horizontalSpaceXS,
                Expanded(
                  child: Text(
                    attachment['filename']?.toString() ?? 'Unknown file',
                    style: ModernDesignSystem.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// Team Member Details Bottom Sheet
class TeamMemberDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> member;
  
  const TeamMemberDetailsBottomSheet({super.key, required this.member});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                    'Team Member Details',
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
                  _buildDetailItem(context, 'Full Name', member['employee_name']?.toString() ?? member['name']?.toString() ?? 'Unknown'),
                  _buildDetailItem(context, 'Employee ID', member['name']?.toString() ?? ''),
                  _buildDetailItem(context, 'Designation', member['designation']?.toString() ?? member['role']?.toString() ?? ''),
                  _buildDetailItem(context, 'Department', member['department']?.toString() ?? ''),
                  _buildDetailItem(context, 'Status', (member['is_active'] ?? true) ? 'Active' : 'Inactive'),
                  if (member['user_id'] != null)
                    _buildDetailItem(context, 'Email', member['user_id']?.toString() ?? ''),
                  if (member['date_of_joining'] != null)
                    _buildDetailItem(context, 'Date of Joining', member['date_of_joining']?.toString() ?? ''),
                  if (member['last_seen'] != null)
                    _buildDetailItem(context, 'Last Seen', member['last_seen']?.toString() ?? 'Never'),
                  _buildDetailItem(context, 'Pending Requests', member['pending_requests']?.toString() ?? '0'),
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
            width: 120,
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

// Approvals History Page
class ApprovalsHistoryPage extends StatelessWidget {
  final List<dynamic> approvals;
  
  const ApprovalsHistoryPage({super.key, required this.approvals});
  
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
                title: 'Approval History',
                showBackButton: true,
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
                  itemCount: approvals.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryItem(approvals[index] as Map<String, dynamic>);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryItem(Map<String, dynamic> approval) {
    final type = approval['type']?.toString() ?? '';
    final title = approval['title']?.toString() ?? 'Approval Request';
    final requesterName = approval['requester_name']?.toString() ?? 'Unknown';
    final status = approval['status']?.toString() ?? '';
    final approvedDate = approval['approved_date']?.toString() ?? '';
    
    Color statusColor = ModernDesignSystem.neutralLight;
    IconData statusIcon = Icons.help_outline;
    
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = ModernDesignSystem.success;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = ModernDesignSystem.error;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
        statusColor = ModernDesignSystem.warning;
        statusIcon = Icons.pending;
        break;
    }
    
    // Build more detailed subtitle for history
    String historySubtitle = 'By $requesterName';
    
    // Add date range for leave applications
    final fromDate = approval['from_date']?.toString();
    final toDate = approval['to_date']?.toString();
    if (fromDate != null && toDate != null) {
      historySubtitle += ' • $fromDate to $toDate';
    }
    
    // Add amount or days
    final amount = approval['amount']?.toString() ?? approval['total_claimed_amount']?.toString();
    final totalDays = approval['total_leave_days']?.toString();
    
    if (amount != null && amount.isNotEmpty) {
      try {
        final value = double.parse(amount);
        historySubtitle += ' • \$${value.toStringAsFixed(2)}';
      } catch (e) {
        historySubtitle += ' • $amount';
      }
    } else if (totalDays != null && totalDays.isNotEmpty) {
      historySubtitle += ' • $totalDays days';
    }
    
    // Add approval/rejection date
    if (approvedDate.isNotEmpty) {
      final actionText = status.toLowerCase() == 'approved' ? 'Approved' : 'Processed';
      historySubtitle += ' • $actionText: ${approvedDate.split(' ')[0]}';
    }
    
    return ModernInfoCard(
      title: title.isNotEmpty ? title : _generateHistoryTitle(approval, type),
      subtitle: historySubtitle,
      badge: status.toUpperCase(),
      badgeColor: statusColor,
      icon: statusIcon,
      iconColor: statusColor,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
    );
  }
  
  String _generateHistoryTitle(Map<String, dynamic> approval, String type) {
    final leaveType = approval['leave_type']?.toString();
    
    switch (type.toLowerCase()) {
      case 'leave':
        return leaveType != null ? '$leaveType Application' : 'Leave Application';
      case 'expense':
      case 'claim':
        return 'Expense Claim';
      case 'attendance':
        return 'Attendance Correction';
      case 'overtime':
        return 'Overtime Request';
      default:
        if (leaveType != null) {
          return '$leaveType Application';
        } else if (approval.containsKey('total_claimed_amount')) {
          return 'Expense Claim';
        }
        return 'Approval Request';
    }
  }
}