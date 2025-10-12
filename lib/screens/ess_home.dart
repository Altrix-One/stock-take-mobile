import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/attendance_service.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:stock_count/hr/widgets/doctype_form.dart';
import 'package:stock_count/hr/widgets/leave_balance_card.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:hive/hive.dart';
import 'package:stock_count/ui/glass.dart';
import 'package:stock_count/utilis/sync_manager.dart';
import 'package:stock_count/screens/queue_status.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/widgets/professional_card.dart';
import 'package:stock_count/widgets/section_header.dart';
import 'package:stock_count/widgets/status_badge.dart';
import 'package:stock_count/widgets/professional_list_item.dart';
import 'package:stock_count/widgets/professional_loading.dart';
import 'package:stock_count/widgets/professional_error_dialog.dart';
import 'package:stock_count/utils/error_message_parser.dart';
import 'package:stock_count/widgets/modern_leave_item.dart';

class ESSHomeScreen extends StatefulWidget {
  const ESSHomeScreen({super.key});
  @override
  State<ESSHomeScreen> createState() => _ESSHomeScreenState();
}

class _ESSHomeScreenState extends State<ESSHomeScreen> {
  int _index = 0;
  bool _canApprove = true; // default true; will refine via roles
  int _approvalsNavCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    await _refreshApprovalsCount();
    try {
      // Try to gate Approvals based on roles in userDetails
      final box = await Hive.openBox('authBox');
      final raw = box.get('userDetails');
      if (raw is String) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final roles = (m['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
        setState(() {
          _canApprove = roles.any((r) => r.contains('Approver') || r.contains('Manager'));
        });
      }
    } catch (_) {}
  }

  Future<void> _refreshApprovalsCount() async {
    try {
      int approvals = 0;
      if (_canApprove) {
        final a1 = await LeavesService.teamLeaves();
        final a2 = await AttendanceService.teamAttendanceRequests();
        final a3 = await AttendanceService.teamShiftRequests();
        final a4 = await ClaimsService.teamClaims();
        approvals = (a1.length + a2.length + a3.length + a4.length);
      }
      if (mounted) setState(() => _approvalsNavCount = approvals);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(canApprove: _canApprove),
      _LeavesPage(),
      _AttendancePage(),
      _ClaimsPage(),
      if (_canApprove) _ApprovalsPage(),
      _ProfilePage(),
    ];
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Leaves'),
      const BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Attendance'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Claims'),
      if (_canApprove) BottomNavigationBarItem(icon: const Icon(Icons.verified_outlined), label: _approvalsNavCount>0 ? 'Approvals (${_approvalsNavCount})' : 'Approvals'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];
    // Clamp index if approvals hidden
    if (!_canApprove && _index == 4) _index = 3;
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35)],
          ),
        ),
        child: pages[_index],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassContainer(
          padding: EdgeInsets.zero,
          opacity: 0.18,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _index,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => setState(() => _index = i),
            items: items,
          ),
        ),
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  final bool canApprove;
  _DashboardPage({this.canApprove = true});
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  Map<String, dynamic>? _balance;
  List<dynamic> _shifts = [];
  int _pendingApprovals = 0;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
    // Auto-refresh when queue updates
    OutboxQueue.events.listen((_) { if (mounted) _load(); });
  }
  Future<void> _load() async {
    try {
      final bal = await LeavesService.leaveBalanceWithPending();
      final shifts = await AttendanceService.upcomingShifts();
      int approvals = 0;
      if (widget.canApprove) {
        final a1 = await LeavesService.teamLeaves();
        final a2 = await AttendanceService.teamAttendanceRequests();
        final a3 = await AttendanceService.teamShiftRequests();
        final a4 = await ClaimsService.teamClaims();
        approvals = (a1.length + a2.length + a3.length + a4.length);
      }
      if (!mounted) return;
      setState(() { _balance = bal; _shifts = shifts; _pendingApprovals = approvals; _loading = false; });
    } catch (_) { if(mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  GlassContainer(child: LeaveBalanceCard(balances: _balance)),
                  const SizedBox(height: 8),
                  if (widget.canApprove)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: const Text('Pending Approvals'),
                        trailing: CircleAvatar(radius: 14, child: Text('$_pendingApprovals')),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text('Quick Links', style: TextStyle(fontWeight: FontWeight.bold)),
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _quickLink('Attendance', Icons.add_task_outlined, ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewAttendanceRequestPage()))),
                      _quickLink('Shift', Icons.repeat_outlined, ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewShiftRequestPage()))),
                      _quickLink('Leave', Icons.event_note_outlined, () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_ApplyLeavePage())); if (mounted) _load(); }),
                      _quickLink('Claim', Icons.add_outlined, ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewClaimPage()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Upcoming Shifts', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_shifts.isEmpty) const ListTile(title: Text('None')),
                  for (final s in _shifts) ListTile(title: Text(s.toString())),
                ],
              ),
            ),
    );
  }
}

class _LeavesPage extends StatefulWidget { @override State<_LeavesPage> createState() => _LeavesPageState(); }
Widget _quickLink(String title, IconData icon, VoidCallback onTap){
  return Card(child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 20), const SizedBox(height: 6), Text(title, style: const TextStyle(fontSize: 12))]))));
}

class _LeavesPageState extends State<_LeavesPage> {
  List<dynamic> _rows = []; bool _loading = true; Map<String,dynamic>? _balance;
  Timer? _autoTimer; int _ticks = 0;
  @override void initState(){ super.initState(); _load();
    // Auto-refresh when queue updates
    OutboxQueue.events.listen((_) { if (mounted) _load(); });
    // Light periodic refresh for a short window so approvals appear without manual pull
    _autoTimer = Timer.periodic(const Duration(seconds: 15), (t){
      if (!mounted) return;
      _ticks++;
      _load();
      if (_ticks >= 8) { // ~2 minutes then stop
        t.cancel();
      }
    });
  }
  Future<void> _load() async { 
    try { 
      _rows = await LeavesService.myLeaves(); 
      _balance = await LeavesService.leaveBalanceWithPending();
    } catch (_) {
      _rows = []; _balance = {};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load leaves')));
      }
    } finally { if(mounted) setState(()=>_loading=false);} }

  List<Widget> _unapprovedSection(){
    final draft = _rows.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='open' || s=='draft' || s=='pending' || s=='applied' || s.contains('queued');
      }
      return false;
    }).toList();
    
    if (draft.isEmpty) {
      return [
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.pending_actions_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Applications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your pending leave applications will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      ];
    }
    
    return [
      for(final r in draft) 
        ModernLeaveItem(
          leave: r as Map<String, dynamic>,
          onCancel: () => _handleCancelLeave(r),
        ),
    ];
  }

  List<Widget> _approvedSection(){
    final approved = _rows.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='approved' || s=='sanctioned';
      }
      return false;
    }).toList();
    
    if (approved.isEmpty) {
      return [
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'No Approved Leaves',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your approved leave applications will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      ];
    }
    
    return [
      for(final r in approved) 
        ModernLeaveItem(
          leave: r as Map<String, dynamic>,
        ),
    ];
  }
  Future<void> _handleCancelLeave(Map r) async {
    final name = r['name']?.toString();
    final lt = r['leave_type']?.toString() ?? '';
    final fd = r['from_date']?.toString() ?? '';
    final td = r['to_date']?.toString() ?? '';
    final st = r['status']?.toString() ?? '';
    
    // Check if cancellable
    if (st.toLowerCase() == 'cancelled') return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Cancel Leave?'),
          ],
        ),
        content: Text('Do you want to cancel your $lt leave application from $fd to $td?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // Resolve document name if missing
        String? doc = name;
        if (doc == null || doc.isEmpty) {
          final emp = await ProfileService.currentEmployee();
          doc = await LeavesService.resolveLeaveName(
            leaveType: lt,
            fromDate: fd,
            toDate: td,
            employee: emp,
          );
        }
        
        if (doc == null || doc.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not locate leave document to cancel')),
            );
          }
          return;
        }
        
        // Perform immediate cancel (fall back to queue only if it fails)
        try {
          await LeavesService.cancelLeaveApplication(doc);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Leave cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (_) {
          await OutboxQueue.addOperation('cancel_leave', {'name': doc});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📤 Cancellation queued (offline mode)'),
              ),
            );
          }
        }
        
        // Refresh list and balances
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cancelling leave: ${e.toString()}')),
          );
        }
      }
    }
  }
  
  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose(){ _autoTimer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leaves'),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _ApplyLeavePage()),
                );
                if (mounted) _load();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Apply'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: _loading 
        ? const ProfessionalLoading(message: 'Loading your leave applications...')
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Leave Balance Card
                LeaveBalanceCard(balances: _balance),
                const SizedBox(height: 24),
                
                // Pending Applications Section
                SectionHeader(
                  title: 'Pending Applications',
                  subtitle: 'Applications awaiting approval',
                  icon: Icons.pending_actions_rounded,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 12),
                ..._unapprovedSection(),
                
                const SizedBox(height: 32),
                
                // Approved Applications Section
                SectionHeader(
                  title: 'Approved Applications',
                  subtitle: 'Your approved leave history',
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                ),
                const SizedBox(height: 12),
                ..._approvedSection(),
                
                // Bottom padding for navigation
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }
}

Widget _attendanceTile(dynamic r){
  if (r is Map) {
    final reason = r['reason']?.toString() ?? '';
    final fd = r['from_date']?.toString() ?? r['from_time']?.toString() ?? '';
    final td = r['to_date']?.toString() ?? r['to_time']?.toString() ?? '';
    final st = r['status']?.toString() ?? '';
    return ListTile(title: Text('$fd → $td'), subtitle: Text('$reason • $st'));
  }
  return ListTile(title: Text(r.toString()));
}

Widget _shiftTile(dynamic r){
  if (r is Map) {
    final shift = r['shift']?.toString() ?? '';
    final fd = r['from_date']?.toString() ?? '';
    final td = r['to_date']?.toString() ?? '';
    final st = r['status']?.toString() ?? '';
    return ListTile(title: Text('$shift: $fd → $td'), subtitle: Text(st));
  }
  return ListTile(title: Text(r.toString()));
}

class _ApplyLeavePage extends StatefulWidget {
  @override
  State<_ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<_ApplyLeavePage> {
  final _formKey = GlobalKey<FormState>();
  String? _leaveType;
  String? _fromDate;
  String? _toDate;
  String? _reason;
  bool _halfDay = false;
  String? _halfDayDate;
  double? _days;
  double? _balance;
  bool _loading = false;
  bool _loadingMeta = true;
  List<String> _leaveTypes = const [];
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final types = await LeavesService.leaveTypes();
      final t = <String>[];
      for (final x in types) {
        if (x is Map && x['name'] != null) t.add(x['name'].toString());
        else if (x is String) t.add(x);
      }
      // Resolve employee id reliably
      try {
        _employeeId = await ProfileService.currentEmployee();
        if (_employeeId == null) {
          final box = await Hive.openBox('authBox');
          final raw = box.get('userDetails');
          if (raw is String) {
            final m = jsonDecode(raw) as Map<String, dynamic>;
            _employeeId = m['employee']?.toString();
          }
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _leaveTypes = t;
        _loadingMeta = false;
      });
    } catch (_) { if(mounted) setState(()=>_loadingMeta=false); }
  }

  Future<void> _recalc() async {
    if (_leaveType != null && _fromDate != null && _toDate != null) {
      setState(() => _loading = true);
      try {
        _employeeId ??= await ProfileService.currentEmployee();
        final days = await LeavesService.getNumberOfLeaveDays(
          fromDate: _fromDate!,
          toDate: _toDate!,
          leaveType: _leaveType!,
          employee: _employeeId,
          halfDay: _halfDay,
          halfDayDate: _halfDay ? (_halfDayDate ?? _fromDate) : null,
        );
        final bal = await LeavesService.getLeaveBalanceOn(date: _fromDate!, leaveType: _leaveType!, employee: _employeeId);
        setState(() { _days = days; _balance = bal; });
      } finally { if(mounted) setState(()=>_loading=false); }
    }
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, firstDate: DateTime(now.year-2), lastDate: DateTime(now.year+2), initialDate: now);
    if (picked != null) {
      final v = picked.toIso8601String().substring(0,10);
      setState(() { if (from) _fromDate = v; else _toDate = v; });
      await _recalc();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      // Client-side validation
      if ((_days ?? 0) <= 0) {
        await ProfessionalErrorDialog.show(
          context: context,
          title: '📅 Invalid Date Range',
          errorMessage: 'The selected date range is invalid. Please ensure the end date is after the start date.',
          canRetry: false,
        );
        return;
      }
      
      if (_balance != null && _days != null && _days! > _balance!) {
        await ProfessionalErrorDialog.show(
          context: context,
          title: '⚖️ Insufficient Leave Balance',
          errorMessage: 'You do not have sufficient leave balance (${_balance!.toStringAsFixed(1)} days available) for this ${_days!.toStringAsFixed(1)}-day request. Please adjust your dates or choose a different leave type.',
          canRetry: false,
        );
        return;
      }

      // Check for overlapping leave applications
      if (!await _validateNoOverlappingLeaves()) {
        return; // Error dialog already shown in validation method
      }
      
      final payload = {
        'leave_type': _leaveType,
        'from_date': _fromDate,
        'to_date': _toDate,
        'reason': _reason,
        if (_employeeId != null) 'employee': _employeeId,
        'half_day': _halfDay ? 1 : 0,
        if (_halfDay) 'half_day_date': _halfDayDate ?? _fromDate,
        'days': _days,
      };
      
      // Try immediate submission first
      try {
        await LeavesService.submitLeaveApplication(payload);
        
        // Success - show confirmation
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '✅ Leave Application Submitted',
            message: 'Your leave application for ${_days!.toStringAsFixed(1)} day(s) from ${_fromDate!} to ${_toDate!} has been successfully submitted for approval.',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // If immediate submission fails, add to queue as fallback
        final errorMessage = e.toString();
        final friendlyMessage = ErrorMessageParser.parseLeaveApplicationError(errorMessage);
        
        // Check if this is a recoverable error that should be queued
        if (_isRecoverableError(errorMessage)) {
          await OutboxQueue.addOperation('leave_application', payload);
          
          if (mounted) {
            await ProfessionalSuccessDialog.show(
              context: context,
              title: '📤 Leave Application Queued',
              message: 'Your leave application has been queued for submission. It will be automatically submitted when connection is restored.',
            );
            Navigator.of(context).pop();
          }
        } else if (_isConcurrencyError(errorMessage)) {
          // Handle concurrency errors with retry option
          if (mounted) {
            await ProfessionalErrorDialog.showLeaveApplicationError(
              context: context,
              rawErrorMessage: errorMessage,
              onRetry: () async {
                // Refresh metadata and retry
                await _loadMeta();
                await _recalc();
                await _submit();
              },
            );
          }
        } else {
          // Show user-friendly error for non-recoverable errors
          if (mounted) {
            await ProfessionalErrorDialog.showLeaveApplicationError(
              context: context,
              rawErrorMessage: errorMessage,
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  bool _isRecoverableError(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('network') || 
           lowerError.contains('timeout') ||
           lowerError.contains('connection') ||
           lowerError.contains('unreachable') ||
           lowerError.contains('500') ||
           lowerError.contains('502') ||
           lowerError.contains('503') ||
           lowerError.contains('504');
  }
  
  bool _isConcurrencyError(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('timestampmismatcherror') ||
           lowerError.contains('has been modified after you have opened it');
  }
  
  Future<bool> _validateNoOverlappingLeaves() async {
    try {
      // Get existing leave applications
      final existingLeaves = await LeavesService.myLeaves();
      final currentFrom = DateTime.parse(_fromDate!);
      final currentTo = DateTime.parse(_toDate!);
      
      for (final leave in existingLeaves) {
        if (leave is Map) {
          final status = leave['status']?.toString().toLowerCase();
          // Skip cancelled or rejected leaves
          if (status == 'cancelled' || status == 'rejected') continue;
          
          final existingFrom = DateTime.tryParse(leave['from_date']?.toString() ?? '');
          final existingTo = DateTime.tryParse(leave['to_date']?.toString() ?? '');
          
          if (existingFrom != null && existingTo != null) {
            // Check for date overlap
            if ((currentFrom.isBefore(existingTo) || currentFrom.isAtSameMomentAs(existingTo)) &&
                (currentTo.isAfter(existingFrom) || currentTo.isAtSameMomentAs(existingFrom))) {
              
              if (mounted) {
                await ProfessionalErrorDialog.show(
                  context: context,
                  title: '📅 Overlapping Leave Application',
                  errorMessage: 'You already have a ${leave['leave_type']} leave application from ${leave['from_date']} to ${leave['to_date']} that overlaps with your selected dates. Please choose different dates or cancel the existing application first.',
                  canRetry: false,
                );
              }
              return false;
            }
          }
        }
      }
      
      return true;
    } catch (e) {
      // If validation fails due to network issues, allow submission (server will validate)
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Leave'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _loadingMeta 
        ? const ProfessionalLoading(message: 'Loading leave types...')
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_note_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'New Leave Application',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in the details below to submit your leave request',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Leave Type Dropdown
                _buildFormSection(
                  title: 'Leave Details',
                  icon: Icons.category_rounded,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _leaveType,
                        items: _leaveTypes.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (v) {
                          setState(() => _leaveType = v);
                          _recalc();
                        },
                        decoration: InputDecoration(
                          labelText: 'Leave Type',
                          prefixIcon: const Icon(Icons.work_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (v) => v == null ? 'Please select a leave type' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date Selection
                _buildFormSection(
                  title: 'Duration',
                  icon: Icons.date_range_rounded,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: _fromDate ?? ''),
                              onTap: () => _pickDate(true),
                              decoration: InputDecoration(
                                labelText: 'From Date',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.calendar_today_rounded),
                                suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: _toDate ?? ''),
                              onTap: () => _pickDate(false),
                              decoration: InputDecoration(
                                labelText: 'To Date',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.event_rounded),
                                suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Half Day Option
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Half Day Leave',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Check this if you need only half day off',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: _halfDay,
                          onChanged: (v) {
                            setState(() => _halfDay = v);
                            _recalc();
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      
                      if (_halfDay) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: _halfDayDate ?? _fromDate ?? ''),
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(now.year - 2),
                              lastDate: DateTime(now.year + 2),
                              initialDate: DateTime.tryParse((_halfDayDate ?? _fromDate) ?? '') ?? now,
                            );
                            if (picked != null) {
                              setState(() => _halfDayDate = picked.toIso8601String().substring(0, 10));
                              await _recalc();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Half Day Date',
                            labelStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(Icons.schedule_rounded),
                            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          validator: (v) {
                            if (!_halfDay) return null;
                            return (v == null || v.isEmpty) ? 'Half day date is required' : null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reason Section
                _buildFormSection(
                  title: 'Additional Information',
                  icon: Icons.edit_note_rounded,
                  child: TextFormField(
                    maxLines: 3,
                    onChanged: (v) => _reason = v,
                    decoration: InputDecoration(
                      labelText: 'Reason (Optional)',
                      hintText: 'Please provide a brief reason for your leave...',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),

                // Leave Calculation Display
                if (_days != null || _balance != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.2),
                          theme.colorScheme.primaryContainer.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calculate_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Leave Calculation',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Requested Days',
                                _days?.toStringAsFixed(1) ?? '-',
                                Icons.event_note_rounded,
                                theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatItem(
                                'Available Balance',
                                _balance?.toStringAsFixed(1) ?? '-',
                                Icons.account_balance_rounded,
                                _balance != null && _days != null && _days! <= _balance!
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Loading indicator
                if (_loading) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const LinearProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _loading ? 'Submitting...' : 'Submit Leave Application',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
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
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _leaveRow(BuildContext context, Map r){
  final name = r['name']?.toString();
  final lt = r['leave_type']?.toString() ?? '';
  final fd = r['from_date']?.toString() ?? '';
  final td = r['to_date']?.toString() ?? '';
  final st = r['status']?.toString() ?? '';
  final cancellable = st.toLowerCase() != 'cancelled';
  return ListTile(
    title: Text('$lt: $fd → $td'),
    subtitle: Text(st),
    trailing: cancellable ? IconButton(
      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
      onPressed: () async {
        final confirm = await showDialog<bool>(context: context, builder: (ctx)=>AlertDialog(
          title: const Text('Cancel leave?'),
          content: Text('Do you want to cancel $lt from $fd to $td?'),
          actions: [
            TextButton(onPressed: ()=>Navigator.of(ctx).pop(false), child: const Text('No')),
            ElevatedButton(onPressed: ()=>Navigator.of(ctx).pop(true), child: const Text('Yes')),
          ],
        ));
        if (confirm == true) {
          // Resolve document name if missing
          String? doc = name;
          if (doc == null || doc.isEmpty) {
            final emp = await ProfileService.currentEmployee();
            doc = await LeavesService.resolveLeaveName(leaveType: lt, fromDate: fd, toDate: td, employee: emp);
          }
          if (doc == null || doc.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not locate leave document to cancel')));
            }
            return;
          }
          // Perform immediate cancel (fall back to queue only if it fails)
          try {
            await LeavesService.cancelLeaveApplication(doc);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave cancelled')));
            }
          } catch (_) {
            await OutboxQueue.addOperation('cancel_leave', {'name': doc});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline: cancellation queued')));
            }
          }
          // Refresh list and balances
          if (context.mounted) {
            final state = context.findAncestorStateOfType<_LeavesPageState>();
            state?._load();
          }
        }
      },
    ) : null,
    onTap: (){
      // Could expand to a details page; for now use the same dialog
      if (name != null) {
        showDialog(context: context, builder: (ctx)=>AlertDialog(
          title: Text(lt),
          content: Text('From: $fd\nTo: $td\nStatus: $st\nName: $name'),
          actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('Close'))],
        ));
      }
    },
  );
}

class _AttendancePage extends StatefulWidget { @override State<_AttendancePage> createState()=>_AttendancePageState(); }
class _AttendancePageState extends State<_AttendancePage> {
  List<dynamic> _att = []; List<dynamic> _shift = []; bool _loading=true;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { 
    try{ 
      _att = await AttendanceService.myAttendanceRequests(); 
      _shift = await AttendanceService.myShiftRequests(); 
    } catch(_) {
      _att = []; _shift = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load attendance data')));
      }
    } finally { if(mounted) setState(()=>_loading=false);} }
  @override Widget build(BuildContext context){
    if(_loading) return const Center(child:CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), actions: [
        IconButton(onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewAttendanceRequestPage())), icon: const Icon(Icons.add_task_outlined)),
        IconButton(onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewShiftRequestPage())), icon: const Icon(Icons.repeat_outlined)),
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
          const Text('Attendance Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_att.isEmpty) const ListTile(title: Text('No attendance requests')),
          for(final r in _att) _attendanceTile(r),
          const SizedBox(height: 12),
          const Text('Shift Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_shift.isEmpty) const ListTile(title: Text('No shift requests')),
          for(final r in _shift) _shiftTile(r),
        ]),
      ),
    );
  }
}

class _ClaimsPage extends StatefulWidget { @override State<_ClaimsPage> createState()=>_ClaimsPageState(); }
class _ClaimsPageState extends State<_ClaimsPage> {
  List<dynamic> _claims = []; Map<String,dynamic>? _summary; bool _loading=true;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { 
    try{ 
      _claims = await ClaimsService.myClaims(); 
      _summary = await ClaimsService.expenseClaimSummary(); 
    } catch(_) {
      _claims = []; _summary = {};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load claims')));
      }
    } finally { if(mounted) setState(()=>_loading=false);} }
  @override Widget build(BuildContext context){
    if(_loading) return const Center(child:CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Claims'), actions: [
        IconButton(onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>_NewClaimPage())), icon: const Icon(Icons.add_outlined)),
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
          const Text('Claim Summary', style: TextStyle(fontWeight: FontWeight.bold)),
          Text((_summary ?? {}).isEmpty ? '—' : _summary.toString()),
          const SizedBox(height: 12),
          const Text('My Claims', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_claims.isEmpty) const ListTile(title: Text('No claims found')),
          for(final c in _claims) ListTile(title: Text(c.toString())),
        ]),
      ),
    );
  }
}

class _ApprovalsPage extends StatefulWidget { @override State<_ApprovalsPage> createState()=>_ApprovalsPageState(); }
class _ApprovalsPageState extends State<_ApprovalsPage> {
  List<dynamic> _leave=[], _att=[], _shift=[], _claims=[]; bool _loading=true;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { try{
    _leave = await LeavesService.teamLeaves();
    _att = await AttendanceService.teamAttendanceRequests();
    _shift = await AttendanceService.teamShiftRequests();
    _claims = await ClaimsService.teamClaims();
  } catch(_) {
    _leave = []; _att = []; _shift = []; _claims = [];
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load approvals')));
    }
  } finally { if(mounted) setState(()=>_loading=false);} }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: _loading ? const Center(child:CircularProgressIndicator()) : RefreshIndicator(
        onRefresh:_load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
          const Text('Leaves for Approval', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_leave.isEmpty) const ListTile(title: Text('No leave approvals')),
          for(final r in _leave) _approvalTile('Leave Application', r),
          const SizedBox(height: 12),
          const Text('Attendance for Approval', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_att.isEmpty) const ListTile(title: Text('No attendance approvals')),
          for(final r in _att) _approvalTile('Attendance Request', r),
          const SizedBox(height: 12),
          const Text('Shift Requests for Approval', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_shift.isEmpty) const ListTile(title: Text('No shift approvals')),
          for(final r in _shift) _approvalTile('Shift Request', r),
          const SizedBox(height: 12),
          const Text('Claims for Approval', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_claims.isEmpty) const ListTile(title: Text('No claim approvals')),
          for(final r in _claims) _approvalTile('Expense Claim', r),
        ]),
      ),
    );
  }
}

Widget _approvalTile(String doctype, dynamic row){
  final name = (row is Map && row['name']!=null) ? row['name'].toString() : row.toString();
  return ListTile(
    title: Text(name),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.close, color: Colors.redAccent), onPressed: () async {
        await OutboxQueue.addOperation('approval_action', {'doctype': doctype, 'name': name, 'approve': false});
      }),
      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () async {
        await OutboxQueue.addOperation('approval_action', {'doctype': doctype, 'name': name, 'approve': true});
      }),
    ]),
  );
}

class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    Map<String,dynamic>? profile;
    try {
      final box = Hive.box('authBox');
      final raw = box.get('userDetails');
      if (raw is String) profile = jsonDecode(raw) as Map<String,dynamic>;
    } catch(_) {}

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16,24,16,16), children: [
        ListTile(
          title: Text(profile?['full_name']?.toString() ?? 'Profile'),
          subtitle: Text(profile?['email']?.toString() ?? 'Employee details'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.cloud_sync_outlined),
          title: const Text('Queue status'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>QueueStatusScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync HR data'),
          onTap: () async {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HR sync started...')));
          try {
            await OutboxQueue.processQueue();
            // Process HR-related queue items (leaves, claims, attendance)
          } catch (e) {
            // ignore
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HR sync complete')));
          }
        },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            var authBox = await Hive.openBox('authBox');
            await authBox.clear();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_)=> LoginScreen()),
              (route)=>false,
            );
          },
        ),
      ]),
    );
  }
}

class _NewAttendanceRequestPage extends StatefulWidget { @override State<_NewAttendanceRequestPage> createState()=>_NewAttendanceRequestPageState(); }
class _NewAttendanceRequestPageState extends State<_NewAttendanceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _fromDate; String? _toDate; String? _reason;
  Future<void> _pick(bool from) async {
    final now = DateTime.now();
    final p = await showDatePicker(context: context, firstDate: DateTime(now.year-2), lastDate: DateTime(now.year+2), initialDate: now);
    if(p!=null) setState(()=> from? _fromDate=p.toIso8601String().substring(0,10) : _toDate=p.toIso8601String().substring(0,10));
  }
  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;
    await OutboxQueue.addOperation('attendance_request', {'from_date': _fromDate, 'to_date': _toDate, 'reason': _reason});
    if(!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance request queued'))); Navigator.of(context).pop();
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('New Attendance Request')),
      body: Form(key:_formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(readOnly:true, controller: TextEditingController(text:_fromDate??''), decoration: const InputDecoration(labelText:'From Date'), onTap: ()=>_pick(true), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
        TextFormField(readOnly:true, controller: TextEditingController(text:_toDate??''), decoration: const InputDecoration(labelText:'To Date'), onTap: ()=>_pick(false), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
        TextFormField(decoration: const InputDecoration(labelText:'Reason'), onChanged: (v)=>_reason=v),
        const SizedBox(height:16),
        ElevatedButton(onPressed:_submit, child: const Text('Submit'))
      ])));
  }
}

class _NewShiftRequestPage extends StatefulWidget { @override State<_NewShiftRequestPage> createState()=>_NewShiftRequestPageState(); }
class _NewShiftRequestPageState extends State<_NewShiftRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _shift; String? _fromDate; String? _toDate; String? _reason;
  Future<void> _pick(bool from) async {
    final now = DateTime.now();
    final p = await showDatePicker(context: context, firstDate: DateTime(now.year-2), lastDate: DateTime(now.year+2), initialDate: now);
    if(p!=null) setState(()=> from? _fromDate=p.toIso8601String().substring(0,10) : _toDate=p.toIso8601String().substring(0,10));
  }
  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;
    await OutboxQueue.addOperation('shift_request', {'shift': _shift, 'from_date': _fromDate, 'to_date': _toDate, 'reason': _reason});
    if(!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift request queued'))); Navigator.of(context).pop();
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('New Shift Request')),
      body: Form(key:_formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(decoration: const InputDecoration(labelText:'Shift'), onChanged: (v)=>_shift=v, validator: (v)=> (v==null||v.isEmpty)?'Required':null),
        TextFormField(readOnly:true, controller: TextEditingController(text:_fromDate??''), decoration: const InputDecoration(labelText:'From Date'), onTap: ()=>_pick(true), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
        TextFormField(readOnly:true, controller: TextEditingController(text:_toDate??''), decoration: const InputDecoration(labelText:'To Date'), onTap: ()=>_pick(false), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
        TextFormField(decoration: const InputDecoration(labelText:'Reason'), onChanged: (v)=>_reason=v),
        const SizedBox(height:16),
        ElevatedButton(onPressed:_submit, child: const Text('Submit'))
      ])));
  }
}

class _NewClaimPage extends StatefulWidget { @override State<_NewClaimPage> createState()=>_NewClaimPageState(); }
class _NewClaimPageState extends State<_NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  String? _type; String? _company; double? _amount; String? _desc;
  final List<File> _attachments = [];

  Future<void> _pickFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
      if (res != null) {
        setState(() {
          for (final f in res.files) { if (f.path != null) _attachments.add(File(f.path!)); }
        });
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;
    final atts = <Map<String, dynamic>>[];
    for (final f in _attachments) {
      try {
        final bytes = await f.readAsBytes();
        final b64 = base64Encode(bytes);
        atts.add({'filename': f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : 'file', 'data': b64});
      } catch (_) {}
    }
    await OutboxQueue.addOperation('expense_claim', {'company': _company, 'type': _type, 'amount': _amount, 'description': _desc, 'attachments': atts});
    if(!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense claim queued'))); Navigator.of(context).pop();
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('New Expense Claim')),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(decoration: const InputDecoration(labelText:'Company'), onChanged:(v)=>_company=v, validator:(v)=>(v==null||v.isEmpty)?'Required':null),
        TextFormField(decoration: const InputDecoration(labelText:'Claim Type'), onChanged:(v)=>_type=v, validator:(v)=>(v==null||v.isEmpty)?'Required':null),
        TextFormField(decoration: const InputDecoration(labelText:'Amount'), keyboardType: const TextInputType.numberWithOptions(decimal:true), onChanged:(v)=>_amount=double.tryParse(v)),
        TextFormField(decoration: const InputDecoration(labelText:'Description'), onChanged:(v)=>_desc=v),
        const SizedBox(height:12),
        Wrap(spacing: 8, runSpacing: 4, children: [for(final f in _attachments) Chip(label: Text(f.uri.pathSegments.isNotEmpty? f.uri.pathSegments.last : 'file'))]),
        TextButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.attachment), label: const Text('Add attachments')),
        const SizedBox(height:16),
        ElevatedButton(onPressed:_submit, child: const Text('Submit'))
      ])));
  }
}
