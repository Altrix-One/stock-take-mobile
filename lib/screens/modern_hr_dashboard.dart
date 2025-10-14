import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/attendance_service.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/widgets/modern_ui_components.dart';
import 'package:stock_count/widgets/modern_enhanced_cards.dart';
import 'package:stock_count/screens/modern_profile_page.dart';
import 'package:stock_count/screens/modern_leaves_page.dart';
import 'package:stock_count/screens/modern_attendance_page.dart';
import 'package:stock_count/screens/modern_claims_page.dart';
import 'package:stock_count/screens/modern_approvals_page.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:stock_count/screens/login.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:async';

class ModernHRDashboard extends StatefulWidget {
  const ModernHRDashboard({super.key});

  @override
  State<ModernHRDashboard> createState() => _ModernHRDashboardState();
}

class _ModernHRDashboardState extends State<ModernHRDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  bool _isLoading = true;
  
  // User data
  Map<String, dynamic>? _userInfo;
  String? _profileImageUrl;
  
  // HR data
  Map<String, dynamic>? _leaveBalance;
  List<dynamic> _recentLeaves = [];
  List<dynamic> _recentClaims = [];
  List<dynamic> _teamApprovals = [];
  int _pendingApprovalsCount = 0;
  
  // Access control
  bool _canApprove = false;
  
  // Leave balance rotation
  Timer? _leaveBalanceTimer;
  int _currentLeaveTypeIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDashboardData();
    
    // Listen to outbox queue changes
    OutboxQueue.events.listen((_) {
      if (mounted) _loadDashboardData();
    });
    
    // Start leave balance rotation timer
    _startLeaveBalanceRotation();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _leaveBalanceTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      await Future.wait([
        _loadUserInfo(),
        _loadLeaveData(),
        _loadClaimsData(),
        _loadApprovalData(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadUserInfo() async {
    try {
      if (!Hive.isBoxOpen('authBox')) await Hive.openBox('authBox');
      final box = Hive.box('authBox');
      final raw = box.get('userDetails');
      
      if (raw is String && raw.isNotEmpty) {
        final userDetails = jsonDecode(raw) as Map<String, dynamic>;
        
        // Try to get employee details for more complete info
        final employeeDetails = await ProfileService.getEmployeeDetails();
        
        setState(() {
          _userInfo = {
            'full_name': employeeDetails?['employee_name'] ?? userDetails['full_name'] ?? userDetails['name'] ?? 'User',
            'email': employeeDetails?['company_email'] ?? userDetails['email'] ?? '',
            'employee_number': employeeDetails?['employee_number'] ?? '',
            'designation': employeeDetails?['designation'] ?? '',
            'department': employeeDetails?['department'] ?? '',
            'company': employeeDetails?['company'] ?? '',
          };
          
          // Check if user has approval rights
          final roles = (userDetails['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
          _canApprove = roles.any((r) => r.contains('HR Manager') || r.contains('Leave Approver'));
        });
        
        // Load profile image
        final imagePath = employeeDetails?['image']?.toString();
        if (imagePath != null && imagePath.isNotEmpty) {
          final fullUrl = await ProfileService.getFullImageUrl(imagePath);
          if (mounted) {
            setState(() {
              _profileImageUrl = fullUrl;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }
  
  Future<void> _loadLeaveData() async {
    try {
      final balance = await LeavesService.leaveBalanceWithPending();
      final recentLeaves = await LeavesService.myLeaves();
      
      setState(() {
        _leaveBalance = balance;
        _recentLeaves = recentLeaves.take(3).toList(); // Show only recent 3
      });
    } catch (e) {
      print('Error loading leave data: $e');
    }
  }
  
  Future<void> _loadClaimsData() async {
    try {
      final recentClaims = await ClaimsService.myClaims();
      setState(() {
        _recentClaims = recentClaims.take(3).toList(); // Show only recent 3
      });
    } catch (e) {
      print('Error loading claims data: $e');
    }
  }
  
  Future<void> _loadApprovalData() async {
    if (!_canApprove) return;
    
    try {
      final leaveApprovals = await LeavesService.teamLeaves();
      final attendanceApprovals = await AttendanceService.teamAttendanceRequests();
      final shiftApprovals = await AttendanceService.teamShiftRequests();
      final claimApprovals = await ClaimsService.teamClaims();
      
      final allApprovals = [
        ...leaveApprovals,
        ...attendanceApprovals,
        ...shiftApprovals,
        ...claimApprovals,
      ];
      
      setState(() {
        _teamApprovals = allApprovals.take(5).toList(); // Show recent 5
        _pendingApprovalsCount = allApprovals.length;
      });
    } catch (e) {
      print('Error loading approval data: $e');
    }
  }
  
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: ModernDesignSystem.error,
            ),
            ModernDesignSystem.horizontalSpaceXS,
            const Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ModernPrimaryButton(
            text: 'Sign Out',
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
        var authBox = await Hive.openBox('authBox');
        await authBox.clear();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    if (_isLoading) {
      return const Scaffold(
        body: ModernLoadingIndicator(
          message: 'Loading your dashboard...',
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernDesignSystem.getSurfaceColor(brightness),
              ModernDesignSystem.getSurfaceVariant(brightness),
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildDashboardPage(),
            const ModernLeavesPage(),
            const ModernAttendancePage(),
            const ModernClaimsPage(),
            if (_canApprove) const ModernApprovalsPage(),
            const ModernProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  
  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    final navItems = [
      _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
      _NavItem(Icons.event_note_rounded, Icons.event_note_outlined, 'Leaves'),
      _NavItem(Icons.access_time_filled, Icons.access_time, 'Attendance'),
      _NavItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Claims'),
      if (_canApprove) _NavItem(Icons.verified, Icons.verified_outlined, 'Approvals'),
      _NavItem(Icons.person_rounded, Icons.person_outline, 'Profile'),
    ];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLG),
        border: Border.all(
          color: ModernDesignSystem.getBorderColor(theme.brightness),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _selectedIndex == index;
            final showBadge = _canApprove && index == 4 && _pendingApprovalsCount > 0;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? ModernDesignSystem.primaryTeal.withOpacity(0.15) : null,
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
                    border: isSelected
                        ? Border.all(color: ModernDesignSystem.primaryTeal, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            color: isSelected
                                ? ModernDesignSystem.primaryTeal
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            size: isSelected ? 22 : 20,
                          ),
                          if (showBadge)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: ModernDesignSystem.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _pendingApprovalsCount > 99 ? '99+' : _pendingApprovalsCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      ModernDesignSystem.verticalSpaceMicro,
                      Text(
                        item.label,
                        style: ModernDesignSystem.captionSmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? ModernDesignSystem.primaryTeal
                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildDashboardPage() {
    final brightness = Theme.of(context).brightness;
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              ModernDesignSystem.verticalSpaceLG,
              
              // Quick Stats
              _buildQuickStats(),
              ModernDesignSystem.verticalSpaceLG,
              
              // Quick Actions
              _buildQuickActions(),
              ModernDesignSystem.verticalSpaceLG,
              
              // Recent Activities
              _buildRecentActivities(),
              
              // Bottom spacing for navigation
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final brightness = Theme.of(context).brightness;
    final userName = _userInfo?['full_name']?.toString() ?? 'User';
    final firstName = userName.split(' ').first;
    final designation = _userInfo?['designation']?.toString() ?? '';
    
    return ModernHeroCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ModernDesignSystem.primaryNavy,
          ModernDesignSystem.primaryTeal,
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD - 2),
              child: _profileImageUrl != null
                  ? Image.network(
                      _profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(firstName),
                    )
                  : _buildAvatarFallback(firstName),
            ),
          ),
          
          ModernDesignSystem.horizontalSpaceMD,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                ModernDesignSystem.verticalSpaceMicro,
                Text(
                  firstName,
                  style: ModernDesignSystem.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (designation.isNotEmpty) ...[
                  ModernDesignSystem.verticalSpaceMicro,
                  Text(
                    designation,
                    style: ModernDesignSystem.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarFallback(String firstName) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          style: ModernDesignSystem.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Quick Overview',
          icon: Icons.analytics_rounded,
        ),
        
        Row(
          children: [
            Expanded(
              child: _buildRotatingLeaveBalanceCard(),
            ),
            ModernDesignSystem.horizontalSpaceXS,
            Expanded(
              child: ModernStatsCard(
                label: 'Pending Claims',
                value: _getPendingClaimsCount(),
                icon: Icons.receipt_long,
                color: ModernDesignSystem.warning,
                isCompact: true,
              ),
            ),
            if (_canApprove) ...[
              ModernDesignSystem.horizontalSpaceXS,
              Expanded(
                child: ModernStatsCard(
                  label: 'Approvals',
                  value: _pendingApprovalsCount.toString(),
                  icon: Icons.verified,
                  color: ModernDesignSystem.error,
                  isCompact: true,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Quick Actions',
          icon: Icons.flash_on,
        ),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: ModernDesignSystem.spaceXS,
          crossAxisSpacing: ModernDesignSystem.spaceXS,
          children: [
            _buildActionButton(
              'Apply Leave',
              Icons.event_note,
              ModernDesignSystem.primaryTeal,
              () => _navigateToPage(1),
            ),
            _buildActionButton(
              'Submit Claim',
              Icons.receipt_long,
              ModernDesignSystem.success,
              () => _navigateToPage(3),
            ),
            _buildActionButton(
              'Check Attendance',
              Icons.access_time,
              ModernDesignSystem.primaryNavy,
              () => _navigateToPage(2),
            ),
            _buildActionButton(
              'My Profile',
              Icons.person,
              ModernDesignSystem.neutralMedium,
              () => _navigateToPage(_canApprove ? 5 : 4),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ModernActionCard(
      title: label,
      icon: icon,
      color: color,
      onTap: onTap,
      showArrow: false,
      margin: EdgeInsets.zero,
    );
  }
  
  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Recent Activities',
          icon: Icons.history,
        ),
        
        if (_recentLeaves.isNotEmpty) ...[
          _buildActivitySection('Recent Leave Applications', _recentLeaves, Icons.event_note),
          ModernDesignSystem.verticalSpaceSM,
        ],
        
        if (_recentClaims.isNotEmpty) ...[
          _buildActivitySection('Recent Claims', _recentClaims, Icons.receipt_long),
          ModernDesignSystem.verticalSpaceSM,
        ],
        
        if (_canApprove && _teamApprovals.isNotEmpty) ...[
          _buildActivitySection('Pending Approvals', _teamApprovals, Icons.verified),
        ],
        
        if (_recentLeaves.isEmpty && _recentClaims.isEmpty && _teamApprovals.isEmpty)
          ModernEmptyState(
            icon: Icons.history,
            title: 'No Recent Activities',
            subtitle: 'Your recent activities will appear here',
          ),
      ],
    );
  }
  
  Widget _buildActivitySection(String title, List<dynamic> items, IconData icon) {
    return ModernHeroCard(
      title: title,
      icon: icon,
      child: Column(
        children: items.map((item) {
          return ModernListItemCard(
            title: _getItemTitle(item),
            subtitle: _getItemSubtitle(item),
            trailing: _getItemStatus(item),
            onTap: () => _handleItemTap(item),
            margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceXS),
          );
        }).toList(),
      ),
    );
  }
  
  String _getItemTitle(dynamic item) {
    if (item is Map) {
      return item['leave_type']?.toString() ?? 
             item['expense_type']?.toString() ?? 
             item['title']?.toString() ?? 
             'Item';
    }
    return 'Item';
  }
  
  String _getItemSubtitle(dynamic item) {
    if (item is Map) {
      final fromDate = item['from_date']?.toString();
      final toDate = item['to_date']?.toString();
      final postingDate = item['posting_date']?.toString();
      
      if (fromDate != null && toDate != null) {
        return '$fromDate to $toDate';
      } else if (postingDate != null) {
        return 'Posted on $postingDate';
      }
    }
    return '';
  }
  
  String _getItemStatus(dynamic item) {
    if (item is Map) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      return status.toUpperCase();
    }
    return '';
  }
  
  void _handleItemTap(dynamic item) {
    // Handle item tap - navigate to detail screen
    print('Tapped item: $item');
  }
  
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _startLeaveBalanceRotation() {
    _leaveBalanceTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _leaveBalance != null && _leaveBalance!.isNotEmpty) {
        setState(() {
          _currentLeaveTypeIndex = (_currentLeaveTypeIndex + 1) % _leaveBalance!.length;
        });
      }
    });
  }
  
  void _rotateLeaveBalanceManually() {
    if (_leaveBalance != null && _leaveBalance!.isNotEmpty) {
      setState(() {
        _currentLeaveTypeIndex = (_currentLeaveTypeIndex + 1) % _leaveBalance!.length;
      });
    }
  }
  
  Map<String, dynamic> _getCurrentLeaveBalanceData() {
    if (_leaveBalance == null || _leaveBalance!.isEmpty) {
      return {
        'type': 'Leave Balance',
        'balance': '0',
        'color': ModernDesignSystem.success,
      };
    }
    
    final leaveTypes = _leaveBalance!.keys.toList();
    if (_currentLeaveTypeIndex >= leaveTypes.length) {
      _currentLeaveTypeIndex = 0;
    }
    
    final currentType = leaveTypes[_currentLeaveTypeIndex];
    final balanceData = _leaveBalance![currentType];
    
    String balance = '0';
    if (balanceData is Map) {
      // Try different field names for remaining balance
      balance = (balanceData['remaining_leaves'] ?? 
               balanceData['balance_leaves'] ?? 
               balanceData['available_leaves'] ?? 
               0).toString();
    }
    
    return {
      'type': currentType,
      'balance': balance,
      'color': _getLeaveTypeColor(currentType),
    };
  }
  
  Color _getLeaveTypeColor(String leaveType) {
    final lowerType = leaveType.toLowerCase();
    
    // Match colors based on leave type
    if (lowerType.contains('casual') || lowerType.contains('personal')) {
      return ModernDesignSystem.primaryTeal;
    } else if (lowerType.contains('sick') || lowerType.contains('medical')) {
      return ModernDesignSystem.error;
    } else if (lowerType.contains('annual') || lowerType.contains('vacation')) {
      return ModernDesignSystem.success;
    } else if (lowerType.contains('maternity') || lowerType.contains('paternity') || lowerType.contains('parental')) {
      return ModernDesignSystem.primaryNavy;
    } else if (lowerType.contains('emergency') || lowerType.contains('urgent')) {
      return ModernDesignSystem.warning;
    } else if (lowerType.contains('privilege') || lowerType.contains('earned')) {
      return ModernDesignSystem.info;
    } else if (lowerType.contains('compensatory') || lowerType.contains('comp')) {
      return const Color(0xFF9C27B0); // Purple
    } else if (lowerType.contains('study') || lowerType.contains('training')) {
      return const Color(0xFF795548); // Brown
    } else {
      // Default color rotation for unknown types
      final colors = [
        ModernDesignSystem.primaryTeal,
        ModernDesignSystem.success, 
        ModernDesignSystem.warning,
        ModernDesignSystem.info,
        ModernDesignSystem.error,
        ModernDesignSystem.primaryNavy,
      ];
      return colors[_currentLeaveTypeIndex % colors.length];
    }
  }
  
  Widget _buildRotatingLeaveBalanceCard() {
    final currentData = _getCurrentLeaveBalanceData();
    final currentColor = currentData['color'] as Color;
    final brightness = Theme.of(context).brightness;
    
    return Container(
      decoration: ModernDesignSystem.modernCardDecoration(brightness),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _rotateLeaveBalanceManually,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.spaceCompactMD),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
                      decoration: BoxDecoration(
                        color: currentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
                      ),
                      child: Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.event_available,
                              key: ValueKey(currentColor.value),
                              color: currentColor,
                              size: 16,
                            ),
                          ),
                          // Stack indicator with dynamic color
                          if (_leaveBalance != null && _leaveBalance!.length > 1)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: currentColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_currentLeaveTypeIndex + 1}/${_leaveBalance!.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                
                ModernDesignSystem.verticalSpaceMD,
                
                // Balance value with animation and dynamic color
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    currentData['balance']!,
                    key: ValueKey('${currentData['balance']}-${currentColor.value}'),
                    style: ModernDesignSystem.headlineCompact.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ModernDesignSystem.getTextPrimary(brightness),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                ModernDesignSystem.verticalSpaceXS,
                
                // Leave type label with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    currentData['type']!,
                    key: ValueKey(currentData['type']),
                    style: ModernDesignSystem.captionCompact.copyWith(
                      color: ModernDesignSystem.getTextSecondary(brightness),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getLeaveBalanceTotal() {
    if (_leaveBalance == null) return '0';
    
    int total = 0;
    _leaveBalance!.forEach((key, value) {
      if (value is Map && value['remaining_leaves'] != null) {
        total += (value['remaining_leaves'] as num).round();
      }
    });
    
    return total.toString();
  }
  
  String _getPendingClaimsCount() {
    if (_recentClaims.isEmpty) return '0';
    
    int pending = 0;
    for (final claim in _recentClaims) {
      if (claim is Map) {
        final status = claim['status']?.toString().toLowerCase() ?? '';
        if (status == 'draft' || status == 'pending' || status == 'open' || status == 'applied' || status.contains('queued')) {
          pending++;
        }
      }
    }
    
    return pending.toString();
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}