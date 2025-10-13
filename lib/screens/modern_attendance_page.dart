import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/attendance_service.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/widgets/modern_ui_components.dart';
import 'package:stock_count/widgets/modern_enhanced_cards.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'dart:async';

class ModernAttendancePage extends StatefulWidget {
  const ModernAttendancePage({super.key});

  @override
  State<ModernAttendancePage> createState() => _ModernAttendancePageState();
}

class _ModernAttendancePageState extends State<ModernAttendancePage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isCheckedIn = false;
  DateTime? _lastCheckInTime;
  DateTime? _lastCheckOutTime;
  List<dynamic> _attendanceHistory = [];
  List<dynamic> _shiftRequests = [];
  Timer? _refreshTimer;
  Duration _workingTime = Duration.zero;
  Timer? _workingTimeTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendanceData();
    
    // Listen to outbox queue changes
    OutboxQueue.events.listen((_) {
      if (mounted) _loadAttendanceData();
    });
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadAttendanceData();
    });
    
    // Update working time every minute
    _workingTimeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _isCheckedIn) _updateWorkingTime();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _workingTimeTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadAttendanceData() async {
    try {
      final results = await Future.wait([
        _checkAttendanceStatus(),
        AttendanceService.myAttendanceHistory(),
        AttendanceService.myShiftRequests(),
      ]);
      
      setState(() {
        _attendanceHistory = results[1] as List<dynamic>;
        _shiftRequests = results[2] as List<dynamic>;
        _isLoading = false;
      });
      
      if (_isCheckedIn && _lastCheckInTime != null) {
        _updateWorkingTime();
      }
    } catch (e) {
      print('Error loading attendance data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<bool> _checkAttendanceStatus() async {
    try {
      final today = DateTime.now();
      final todayAttendance = _attendanceHistory.where((attendance) {
        if (attendance is Map && attendance['date'] != null) {
          final attendanceDate = DateTime.parse(attendance['date'].toString());
          return attendanceDate.year == today.year &&
                 attendanceDate.month == today.month &&
                 attendanceDate.day == today.day;
        }
        return false;
      }).toList();
      
      if (todayAttendance.isNotEmpty) {
        final latest = todayAttendance.last as Map;
        final checkInTime = latest['check_in']?.toString();
        final checkOutTime = latest['check_out']?.toString();
        
        setState(() {
          _lastCheckInTime = checkInTime != null ? DateTime.parse(checkInTime) : null;
          _lastCheckOutTime = checkOutTime != null ? DateTime.parse(checkOutTime) : null;
          _isCheckedIn = checkInTime != null && checkOutTime == null;
        });
        
        return _isCheckedIn;
      }
      
      setState(() {
        _isCheckedIn = false;
        _lastCheckInTime = null;
        _lastCheckOutTime = null;
      });
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  void _updateWorkingTime() {
    if (_isCheckedIn && _lastCheckInTime != null) {
      setState(() {
        _workingTime = DateTime.now().difference(_lastCheckInTime!);
      });
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
                    ? const ModernLoadingIndicator(message: 'Loading attendance data...')
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTodayTab(),
                          _buildHistoryTab(),
                          _buildShiftRequestsTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 2 
          ? FloatingActionButton.extended(
              onPressed: _showShiftRequestForm,
              backgroundColor: ModernDesignSystem.primaryTeal,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text(
                'Request Shift',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
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
                  'Attendance',
                  style: ModernDesignSystem.displaySmall.copyWith(
                    color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ModernDesignSystem.verticalSpaceMicro,
                Text(
                  'Track your working hours',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadAttendanceData,
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
          Tab(text: 'Today'),
          Tab(text: 'History'),
          Tab(text: 'Shifts'),
        ],
      ),
    );
  }
  
  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Check-in/Check-out Card
            _buildCheckInOutCard(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Today's Stats
            _buildTodayStats(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Monthly Summary
            _buildMonthlySummary(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Attendance History
            _buildAttendanceHistory(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShiftRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Shift Requests
            _buildShiftRequests(),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckInOutCard() {
    return ModernHeroCard(
      title: _isCheckedIn ? 'Working Now' : 'Ready to Work',
      icon: _isCheckedIn ? Icons.work : Icons.play_circle,
      gradient: _isCheckedIn 
          ? LinearGradient(
              colors: [ModernDesignSystem.success, ModernDesignSystem.success.withOpacity(0.7)],
            )
          : LinearGradient(
              colors: [ModernDesignSystem.primaryNavy, ModernDesignSystem.primaryTeal],
            ),
      child: Column(
        children: [
          if (_isCheckedIn) ...[
            // Working time display
            Text(
              _formatDuration(_workingTime),
              style: ModernDesignSystem.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            ModernDesignSystem.verticalSpaceXS,
            Text(
              'Working Time',
              style: ModernDesignSystem.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            ModernDesignSystem.verticalSpaceLG,
            
            // Check-in time
            if (_lastCheckInTime != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernDesignSystem.spaceMD,
                  vertical: ModernDesignSystem.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                ),
                child: Text(
                  'Checked in at ${_formatTime(_lastCheckInTime!)}',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            ModernDesignSystem.verticalSpaceMD,
          ] else ...[
            Icon(
              Icons.access_time,
              size: 48,
              color: Colors.white.withOpacity(0.9),
            ),
            ModernDesignSystem.verticalSpaceMD,
            Text(
              'Start Your Day',
              style: ModernDesignSystem.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            ModernDesignSystem.verticalSpaceXS,
            Text(
              'Tap the button below to check in',
              style: ModernDesignSystem.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            ModernDesignSystem.verticalSpaceLG,
          ],
          
          // Check-in/Check-out button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckedIn ? _checkOut : _checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _isCheckedIn ? ModernDesignSystem.error : ModernDesignSystem.success,
                padding: const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceMD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
                ),
                elevation: 2,
              ),
              icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
              label: Text(
                _isCheckedIn ? 'Check Out' : 'Check In',
                style: ModernDesignSystem.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodayStats() {
    final hoursWorked = _workingTime.inHours + (_workingTime.inMinutes % 60) / 60.0;
    final regularHours = 8.0;
    final overtimeHours = hoursWorked > regularHours ? hoursWorked - regularHours : 0.0;
    
    return Row(
      children: [
        Expanded(
          child: ModernStatsCard(
            label: 'Hours Today',
            value: hoursWorked.toStringAsFixed(1),
            icon: Icons.schedule,
            color: ModernDesignSystem.primaryTeal,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Regular Hours',
            value: (hoursWorked > regularHours ? regularHours : hoursWorked).toStringAsFixed(1),
            icon: Icons.work_history,
            color: ModernDesignSystem.success,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Overtime',
            value: overtimeHours.toStringAsFixed(1),
            icon: Icons.trending_up,
            color: overtimeHours > 0 ? ModernDesignSystem.warning : ModernDesignSystem.neutralLight,
            isCompact: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return ModernHeroCard(
      title: 'Quick Actions',
      icon: Icons.flash_on,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Break',
                  Icons.coffee,
                  ModernDesignSystem.warning,
                  _takeBreak,
                ),
              ),
              ModernDesignSystem.horizontalSpaceXS,
              Expanded(
                child: _buildQuickActionButton(
                  'Overtime',
                  Icons.access_time_filled,
                  ModernDesignSystem.info,
                  _requestOvertime,
                ),
              ),
            ],
          ),
          ModernDesignSystem.verticalSpaceXS,
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Remote Work',
                  Icons.home_work,
                  ModernDesignSystem.primaryTeal,
                  _requestRemoteWork,
                ),
              ),
              ModernDesignSystem.horizontalSpaceXS,
              Expanded(
                child: _buildQuickActionButton(
                  'Report Issue',
                  Icons.report_problem,
                  ModernDesignSystem.error,
                  _reportIssue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ModernActionCard(
      title: label,
      icon: icon,
      color: color,
      onTap: onTap,
      showArrow: false,
      margin: EdgeInsets.zero,
    );
  }
  
  Widget _buildMonthlySummary() {
    final thisMonth = DateTime.now();
    final workingDays = _getWorkingDaysInMonth(thisMonth);
    final presentDays = _getPresentDaysInMonth(thisMonth);
    final totalHours = _getTotalHoursInMonth(thisMonth);
    
    return ModernHeroCard(
      title: 'This Month Summary',
      subtitle: '${thisMonth.month}/${thisMonth.year}',
      icon: Icons.calendar_month,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem('Working Days', workingDays.toString(), Icons.calendar_today, ModernDesignSystem.primaryTeal),
          ),
          Expanded(
            child: _buildSummaryItem('Present Days', presentDays.toString(), Icons.check_circle, ModernDesignSystem.success),
          ),
          Expanded(
            child: _buildSummaryItem('Total Hours', totalHours.toStringAsFixed(1), Icons.schedule, ModernDesignSystem.info),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
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
  
  Widget _buildAttendanceHistory() {
    if (_attendanceHistory.isEmpty) {
      return ModernEmptyState(
        icon: Icons.history,
        title: 'No Attendance Records',
        subtitle: 'Your attendance history will appear here',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Attendance History',
          subtitle: '${_attendanceHistory.length} records',
          icon: Icons.history,
        ),
        
        ...(_attendanceHistory.take(10).map((attendance) => _buildAttendanceItem(attendance as Map<String, dynamic>))),
      ],
    );
  }
  
  Widget _buildAttendanceItem(Map<String, dynamic> attendance) {
    final date = attendance['date']?.toString() ?? '';
    final checkIn = attendance['check_in']?.toString();
    final checkOut = attendance['check_out']?.toString();
    final status = attendance['status']?.toString() ?? 'Present';
    
    Color statusColor = ModernDesignSystem.success;
    IconData statusIcon = Icons.check_circle;
    
    switch (status.toLowerCase()) {
      case 'absent':
        statusColor = ModernDesignSystem.error;
        statusIcon = Icons.cancel;
        break;
      case 'half day':
        statusColor = ModernDesignSystem.warning;
        statusIcon = Icons.schedule;
        break;
      case 'late':
        statusColor = ModernDesignSystem.warning;
        statusIcon = Icons.access_time;
        break;
    }
    
    return ModernInfoCard(
      title: date,
      subtitle: checkIn != null && checkOut != null 
          ? 'In: ${_formatTime(DateTime.parse(checkIn))} - Out: ${_formatTime(DateTime.parse(checkOut))}'
          : checkIn != null 
              ? 'In: ${_formatTime(DateTime.parse(checkIn))} - Still working'
              : 'No attendance data',
      badge: status.toUpperCase(),
      badgeColor: statusColor,
      icon: statusIcon,
      iconColor: statusColor,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
    );
  }
  
  Widget _buildShiftRequests() {
    if (_shiftRequests.isEmpty) {
      return ModernEmptyState(
        icon: Icons.schedule,
        title: 'No Shift Requests',
        subtitle: 'Your shift requests will appear here',
        actionText: 'Request Shift Change',
        onAction: _showShiftRequestForm,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Shift Requests',
          subtitle: '${_shiftRequests.length} requests',
          icon: Icons.schedule,
        ),
        
        ...(_shiftRequests.map((request) => _buildShiftRequestItem(request as Map<String, dynamic>))),
      ],
    );
  }
  
  Widget _buildShiftRequestItem(Map<String, dynamic> request) {
    final date = request['date']?.toString() ?? '';
    final fromShift = request['from_shift']?.toString() ?? '';
    final toShift = request['to_shift']?.toString() ?? '';
    final status = request['status']?.toString() ?? '';
    final reason = request['reason']?.toString() ?? '';
    
    Color statusColor = ModernDesignSystem.warning;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = ModernDesignSystem.success;
        break;
      case 'rejected':
        statusColor = ModernDesignSystem.error;
        break;
    }
    
    return ModernInfoCard(
      title: 'Shift Change Request',
      subtitle: '$fromShift → $toShift ($date)',
      badge: status.toUpperCase(),
      badgeColor: statusColor,
      icon: Icons.swap_horiz,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
      onTap: () => _showShiftRequestDetails(request),
    );
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  int _getWorkingDaysInMonth(DateTime month) {
    // Simplified calculation - in a real app, you'd consider holidays and weekends
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return (daysInMonth * 5 / 7).round(); // Rough estimate of working days
  }
  
  int _getPresentDaysInMonth(DateTime month) {
    return _attendanceHistory.where((attendance) {
      if (attendance is Map && attendance['date'] != null) {
        final attendanceDate = DateTime.parse(attendance['date'].toString());
        return attendanceDate.year == month.year && 
               attendanceDate.month == month.month &&
               attendance['status']?.toString().toLowerCase() != 'absent';
      }
      return false;
    }).length;
  }
  
  double _getTotalHoursInMonth(DateTime month) {
    double totalHours = 0.0;
    for (final attendance in _attendanceHistory) {
      if (attendance is Map && attendance['date'] != null) {
        final attendanceDate = DateTime.parse(attendance['date'].toString());
        if (attendanceDate.year == month.year && attendanceDate.month == month.month) {
          final checkIn = attendance['check_in']?.toString();
          final checkOut = attendance['check_out']?.toString();
          if (checkIn != null && checkOut != null) {
            final checkInTime = DateTime.parse(checkIn);
            final checkOutTime = DateTime.parse(checkOut);
            final duration = checkOutTime.difference(checkInTime);
            totalHours += duration.inMinutes / 60.0;
          }
        }
      }
    }
    return totalHours;
  }
  
  Future<void> _checkIn() async {
    try {
      final result = await AttendanceService.checkIn();
      if (mounted) {
        final success = result['success'] == true;
        final message = result['message']?.toString() ?? (success ? 'Checked in successfully' : 'Failed to check in');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '✅ $message' : '❌ $message'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          _loadAttendanceData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error checking in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _checkOut() async {
    try {
      final result = await AttendanceService.checkOut();
      if (mounted) {
        final success = result['success'] == true;
        final message = result['message']?.toString() ?? (success ? 'Checked out successfully' : 'Failed to check out');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '✅ $message' : '❌ $message'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          _loadAttendanceData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error checking out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _takeBreak() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Take a Break'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _requestOvertime() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Request Overtime'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _requestRemoteWork() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Request Remote Work'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Report Issue'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showShiftRequestForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ShiftRequestFormPage(),
      ),
    ).then((_) => _loadAttendanceData());
  }
  
  void _showShiftRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShiftRequestDetailsBottomSheet(request: request),
    );
  }
}

// Shift Request Form Page
class ShiftRequestFormPage extends StatefulWidget {
  const ShiftRequestFormPage({super.key});
  
  @override
  State<ShiftRequestFormPage> createState() => _ShiftRequestFormPageState();
}

class _ShiftRequestFormPageState extends State<ShiftRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _currentShift;
  String? _requestedShift;
  bool _isSubmitting = false;
  bool _isLoadingShifts = true;
  
  List<String> _shifts = [];
  
  @override
  void initState() {
    super.initState();
    _loadShiftTypes();
  }
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  Future<void> _loadShiftTypes() async {
    try {
      final types = await AttendanceService.shiftTypes();
      setState(() {
        _shifts = types.map((type) => type.toString()).toList();
        _isLoadingShifts = false;
      });
    } catch (e) {
      setState(() {
        _shifts = [
          'Morning Shift (9:00 AM - 5:00 PM)',
          'Afternoon Shift (1:00 PM - 9:00 PM)',
          'Night Shift (9:00 PM - 5:00 AM)',
          'Flexible Hours',
        ];
        _isLoadingShifts = false;
      });
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
                title: 'Request Shift Change',
                showBackButton: true,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildDateSelector(),
                        ModernDesignSystem.verticalSpaceMD,
                        
                        _buildShiftSelectors(),
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
  
  Widget _buildDateSelector() {
    return ModernHeroCard(
      title: 'Select Date',
      icon: Icons.date_range,
      child: InkWell(
        onTap: _selectDate,
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
                color: ModernDesignSystem.primaryTeal,
              ),
              ModernDesignSystem.horizontalSpaceSM,
              Text(
                _selectedDate != null 
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Select date for shift change',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: _selectedDate != null 
                      ? ModernDesignSystem.getTextPrimary(Theme.of(context).brightness)
                      : ModernDesignSystem.getTextTertiary(Theme.of(context).brightness),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildShiftSelectors() {
    if (_isLoadingShifts) {
      return ModernHeroCard(
        title: 'Shift Information',
        icon: Icons.schedule,
        child: Container(
          padding: const EdgeInsets.all(ModernDesignSystem.spaceLG),
          child: const Center(
            child: CircularProgressIndicator(
              color: ModernDesignSystem.primaryTeal,
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        ModernHeroCard(
          title: 'Current Shift',
          icon: Icons.schedule,
          child: DropdownButtonFormField<String>(
            value: _currentShift,
            decoration: InputDecoration(
              hintText: 'Select current shift',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                borderSide: BorderSide(color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness)),
              ),
              contentPadding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            ),
            items: _shifts.map((shift) => DropdownMenuItem(
              value: shift,
              child: Text(shift),
            )).toList(),
            onChanged: (value) => setState(() => _currentShift = value),
            validator: (value) => value == null ? 'Please select current shift' : null,
          ),
        ),
        
        ModernDesignSystem.verticalSpaceMD,
        
        ModernHeroCard(
          title: 'Requested Shift',
          icon: Icons.swap_horiz,
          child: DropdownButtonFormField<String>(
            value: _requestedShift,
            decoration: InputDecoration(
              hintText: 'Select requested shift',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                borderSide: BorderSide(color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness)),
              ),
              contentPadding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            ),
            items: _shifts.map((shift) => DropdownMenuItem(
              value: shift,
              child: Text(shift),
            )).toList(),
            onChanged: (value) => setState(() => _requestedShift = value),
            validator: (value) => value == null ? 'Please select requested shift' : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildReasonField() {
    return ModernHeroCard(
      title: 'Reason for Change',
      icon: Icons.edit_note,
      child: ModernInputField(
        controller: _reasonController,
        hint: 'Please provide a reason for the shift change...',
        maxLines: 4,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please provide a reason for the shift change';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildSubmitButton() {
    return ModernPrimaryButton(
      text: 'Submit Shift Request',
      isLoading: _isSubmitting,
      onPressed: _submitShiftRequest,
      icon: Icons.send,
    );
  }
  
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      setState(() => _selectedDate = date);
    }
  }
  
  Future<void> _submitShiftRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      await AttendanceService.requestShiftChange({
        'date': _selectedDate!.toIso8601String(),
        'from_shift': _currentShift!,
        'to_shift': _requestedShift!,
        'reason': _reasonController.text.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Shift request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

// Shift Request Details Bottom Sheet
class ShiftRequestDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> request;
  
  const ShiftRequestDetailsBottomSheet({super.key, required this.request});
  
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
                    'Shift Request Details',
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
                  _buildDetailItem(context, 'Date', request['date']?.toString() ?? ''),
                  _buildDetailItem(context, 'Current Shift', request['from_shift']?.toString() ?? ''),
                  _buildDetailItem(context, 'Requested Shift', request['to_shift']?.toString() ?? ''),
                  _buildDetailItem(context, 'Status', request['status']?.toString() ?? ''),
                  _buildDetailItem(context, 'Reason', request['reason']?.toString() ?? ''),
                  if (request['submitted_date'] != null)
                    _buildDetailItem(context, 'Submitted On', request['submitted_date']?.toString() ?? ''),
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