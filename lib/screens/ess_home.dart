import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/attendance_service.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stock_count/hr/widgets/leave_balance_card.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:hive/hive.dart';
import 'package:stock_count/screens/queue_status.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/widgets/section_header.dart';
import 'package:stock_count/widgets/professional_loading.dart';
import 'package:stock_count/widgets/professional_error_dialog.dart';
import 'package:stock_count/utils/error_message_parser.dart';
import 'package:stock_count/widgets/modern_leave_item.dart';
import 'package:stock_count/widgets/modern_attendance_item.dart';
import 'package:stock_count/widgets/modern_shift_item.dart';
import 'package:stock_count/widgets/modern_claim_item.dart';
import 'package:stock_count/screens/modern_profile_page.dart';
import 'package:stock_count/constants/modern_design_system.dart';

class ESSHomeScreen extends StatefulWidget {
  const ESSHomeScreen({super.key});
  @override
  State<ESSHomeScreen> createState() => _ESSHomeScreenState();
}

class _ESSHomeScreenState extends State<ESSHomeScreen> with TickerProviderStateMixin {
  int _index = 0;
  bool _canApprove = true; // default true; will refine via roles
  int _approvalsNavCount = 0;
  late AnimationController _animationController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController = PageController(initialPage: 0);
    _loadRoles();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
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
          // Only show approvals for HR Manager, not HR User
          _canApprove = roles.any((r) => r.contains('HR Manager'));
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
      ModernProfilePage(),
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
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _index = index;
            });
            _animationController.forward().then((_) {
              _animationController.reset();
            });
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: _buildAnimatedBottomNav(),
    );
  }
  
  Widget _buildAnimatedBottomNav() {
    final theme = Theme.of(context);
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      _NavItem(Icons.event_note_rounded, Icons.event_note_outlined, 'Leaves'),
      _NavItem(Icons.access_time_filled, Icons.access_time, 'Attendance'),
      _NavItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Claims'),
      if (_canApprove) _NavItem(Icons.verified, Icons.verified_outlined, 'Approvals'),
      _NavItem(Icons.person_rounded, Icons.person_outline, 'Profile'),
    ];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.outline.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _index == index;
                
                return Expanded(
                  child: _buildNavItem(
                    context,
                    item.activeIcon,
                    item.inactiveIcon,
                    item.label,
                    isSelected,
                    index,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    bool isSelected,
    int index,
  ) {
    final theme = Theme.of(context);
    final showBadge = _canApprove && index == 4 && _approvalsNavCount > 0;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_index != index) {
              setState(() {
                _index = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
              );
              _animationController.forward().then((_) {
                _animationController.reset();
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (theme.brightness == Brightness.dark
                      ? ModernDesignSystem.primaryTeal.withOpacity(0.2)
                      : ModernDesignSystem.primaryTeal.withOpacity(0.15))
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: theme.brightness == Brightness.dark
                          ? ModernDesignSystem.primaryTeal.withOpacity(0.8)
                          : ModernDesignSystem.primaryTeal,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        key: ValueKey(isSelected),
                        color: isSelected
                            ? ModernDesignSystem.primaryTeal
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        size: isSelected ? 22 : 20,
                      ),
                    ),
                    if (showBadge)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),  // Professional red
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE74C3C).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            _approvalsNavCount > 99 ? '99+' : _approvalsNavCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: isSelected ? 8 : 7,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? ModernDesignSystem.primaryTeal
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}

class _DashboardPage extends StatefulWidget {
  final bool canApprove;
  _DashboardPage({this.canApprove = true});
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  Map<String, dynamic>? _balance;
  int _pendingApprovals = 0;
  bool _loading = true;
  Map<String, dynamic>? _userInfo;
  String? _profileImageUrl;
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
      
      // Load user info from Hive
      await _loadUserInfo();
      
      int approvals = 0;
      if (widget.canApprove) {
        final a1 = await LeavesService.teamLeaves();
        final a2 = await AttendanceService.teamAttendanceRequests();
        final a3 = await AttendanceService.teamShiftRequests();
        final a4 = await ClaimsService.teamClaims();
        approvals = (a1.length + a2.length + a3.length + a4.length);
      }
      if (!mounted) return;
      setState(() { _balance = bal; _pendingApprovals = approvals; _loading = false; });
    } catch (_) { if(mounted) setState(() => _loading = false); }
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
          };
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
  Widget _buildCustomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
          child: SizedBox(
            height: 32, // Fixed small height
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            // Company Logo/Name Section
            Expanded(
              child: Row(
                children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/images/cohenixess.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cohenix ESS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
            ),
            
            // User Profile Section
            if (_userInfo != null)
              GestureDetector(
                onTap: () {
                  // Navigate to profile page
                  final parentState = context.findAncestorStateOfType<_ESSHomeScreenState>();
                  if (parentState != null) {
                    // Profile tab index depends on whether approvals are visible
                    final profileIndex = widget.canApprove ? 5 : 4;
                    if (parentState._index != profileIndex) {
                      parentState.setState(() {
                        parentState._index = profileIndex;
                      });
                      // Actually navigate to the page
                      parentState._pageController.animateToPage(
                        profileIndex,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                      );
                      // Trigger animation
                      parentState._animationController.forward().then((_) {
                        parentState._animationController.reset();
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? Text(
                                (_userInfo!['full_name']?.toString() ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _userInfo!['full_name']?.toString() ?? 'User',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                fontSize: 10,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_userInfo!['designation']?.toString().isNotEmpty == true)
                              Text(
                                _userInfo!['designation']?.toString() ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 8,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 1),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 8,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceVariant.withOpacity(0.1),
                  ]
                : [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceVariant.withOpacity(0.15),
                  ],
          ),
        ),
        child: Column(
          children: [
            _buildCustomNavBar(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        children: [
                          // Welcome message
                          _buildWelcomeSection(context),
                          const SizedBox(height: 12),
                          
                          // Leave balance card
                          LeaveBalanceCard(balances: _balance),
                          const SizedBox(height: 12),
                          
                          // Approvals card (if user can approve - HR Manager role only)
                          if (widget.canApprove)
                            _buildApprovalsCard(context),
                          if (widget.canApprove) const SizedBox(height: 12),
                          
                          // Quick actions section
                          _buildQuickActionsSection(context),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _userInfo?['full_name']?.toString() ?? 'User';
    final firstName = userName.split(' ').first;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainer.withOpacity(0.5)
            : const Color(0xFFE8F0F3), // Subtle, light blue/gray background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.outline.withOpacity(0.4)
              : const Color(0xFFC4D5DD), // Lighter, soft border
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary, // Deep Navy Blue
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Welcome back,',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        firstName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.wb_sunny_rounded,
                color: Colors.amber,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildApprovalsCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFFFFC107).withOpacity(0.2)     // Professional amber background
              : const Color(0xFFFFF8E1),                     // Light amber background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFFE69900).withOpacity(0.5)   // Deeper amber border dark
                : const Color(0xFFFFC107).withOpacity(0.5),   // Standard amber border light
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE69900),  // Deeper amber for icon background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Pending Approvals',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Items awaiting your approval',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE69900),  // Deeper amber for count badge
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$_pendingApprovals',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
  
  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2.2,  // More compact proportions
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildModernQuickLink(
              context,
              'Apply Leave',
              Icons.event_note_rounded,
              theme.colorScheme.primary,  // Deep Navy Blue - Primary action
              () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _ApplyLeavePage()),
                );
                if (mounted) _load();
              },
            ),
            _buildModernQuickLink(
              context,
              'New Claim',
              Icons.receipt_long_rounded,
              const Color(0xFF4CAF50),  // Standard professional Green - Success/New
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _NewClaimPage()),
              ),
            ),
            _buildModernQuickLink(
              context,
              'Attendance',
              Icons.access_time_rounded,
              theme.colorScheme.primary,  // Deep Navy Blue - Primary action
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _NewAttendanceRequestPage()),
              ),
            ),
            _buildModernQuickLink(
              context,
              'Shift Request',
              Icons.swap_horiz_rounded,
              theme.colorScheme.primary,  // Deep Navy Blue - Primary action
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _NewShiftRequestPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildModernQuickLink(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? color.withOpacity(0.12)
                : color.withOpacity(0.08),  // More subtle background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? color.withOpacity(0.35)
                  : color.withOpacity(0.25),  // More subtle border
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? color.withOpacity(0.9)  // Slightly transparent in dark mode
                      : color,                   // Full opacity in light mode
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,  // Slightly smaller for more compact look
                    height: 1.2,   // Better line height
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ],
          ),
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
                const SizedBox(height: 120),
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
  Timer? _autoTimer; int _ticks = 0;
  
  @override void initState(){ 
    super.initState(); 
    _load();
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
    try{ 
      _att = await AttendanceService.myAttendanceRequests(); 
      _shift = await AttendanceService.myShiftRequests(); 
    } catch(_) {
      _att = []; _shift = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load attendance data')));
      }
    } finally { if(mounted) setState(()=>_loading=false);} 
  }
  
  List<Widget> _attendanceSection() {
    final pending = _att.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='open' || s=='draft' || s=='pending' || s=='applied' || s.contains('queued');
      }
      return false;
    }).toList();
    
    final approved = _att.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='approved' || s=='sanctioned';
      }
      return false;
    }).toList();
    
    List<Widget> widgets = [];
    
    // Pending attendance requests
    if (pending.isEmpty) {
      widgets.add(Container(
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
              Icons.access_time_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Requests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your pending attendance requests will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ));
    } else {
      for(final r in pending) {
        widgets.add(ModernAttendanceItem(
          attendance: r as Map<String, dynamic>,
          onCancel: () => _handleCancelAttendance(r),
        ));
      }
    }
    
    // Approved attendance requests
    if (approved.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Approved Requests',
          subtitle: 'Your approved attendance history',
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
      ]);
      
      for(final r in approved) {
        widgets.add(ModernAttendanceItem(
          attendance: r as Map<String, dynamic>,
        ));
      }
    }
    
    return widgets;
  }
  
  List<Widget> _shiftSection() {
    final pending = _shift.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='open' || s=='draft' || s=='pending' || s=='applied' || s.contains('queued');
      }
      return false;
    }).toList();
    
    final approved = _shift.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='approved' || s=='sanctioned';
      }
      return false;
    }).toList();
    
    List<Widget> widgets = [];
    
    // Pending shift requests
    if (pending.isEmpty) {
      widgets.add(Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.work_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Shift Requests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your pending shift requests will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ));
    } else {
      for(final r in pending) {
        widgets.add(ModernShiftItem(
          shift: r as Map<String, dynamic>,
          onCancel: () => _handleCancelShift(r),
        ));
      }
    }
    
    // Approved shift requests
    if (approved.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Approved Shifts',
          subtitle: 'Your approved shift history',
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
      ]);
      
      for(final r in approved) {
        widgets.add(ModernShiftItem(
          shift: r as Map<String, dynamic>,
        ));
      }
    }
    
    return widgets;
  }
  
  Future<void> _handleCancelAttendance(Map attendance) async {
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Attendance Request?'),
        content: const Text('Do you want to cancel this attendance request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), 
            child: const Text('No')
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Yes')
          ),
        ],
      )
    );
    
    if (confirm == true) {
      await OutboxQueue.addOperation('cancel_attendance', {'name': attendance['name']});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance request cancellation queued'))
        );
        _load();
      }
    }
  }
  
  Future<void> _handleCancelShift(Map shift) async {
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Shift Request?'),
        content: const Text('Do you want to cancel this shift request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), 
            child: const Text('No')
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Yes')
          ),
        ],
      )
    );
    
    if (confirm == true) {
      await OutboxQueue.addOperation('cancel_shift', {'name': shift['name']});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift request cancellation queued'))
        );
        _load();
      }
    }
  }
  
  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }
  
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance & Shifts'),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _NewAttendanceRequestPage()),
                );
                if (mounted) _load();
              },
              icon: const Icon(Icons.add_task_outlined, size: 18),
              label: const Text('Request'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _NewShiftRequestPage()),
                );
                if (mounted) _load();
              },
              icon: const Icon(Icons.repeat_outlined, size: 18),
              label: const Text('Shift'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: _loading 
        ? const ProfessionalLoading(message: 'Loading your attendance requests...')
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Attendance Requests Section
                SectionHeader(
                  title: 'Attendance Requests',
                  subtitle: 'Track your attendance requests',
                  icon: Icons.access_time_rounded,
                  iconColor: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                ..._attendanceSection(),
                
                const SizedBox(height: 32),
                
                // Shift Requests Section
                SectionHeader(
                  title: 'Shift Requests',
                  subtitle: 'Manage your shift changes',
                  icon: Icons.work_outline_rounded,
                  iconColor: theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 12),
                ..._shiftSection(),
                
                // Bottom padding for navigation
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }
}

class _ClaimsPage extends StatefulWidget { @override State<_ClaimsPage> createState()=>_ClaimsPageState(); }
class _ClaimsPageState extends State<_ClaimsPage> {
  List<dynamic> _claims = []; Map<String,dynamic>? _summary; bool _loading=true;
  Timer? _autoTimer; int _ticks = 0;
  
  @override void initState(){ 
    super.initState(); 
    _load();
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
    try{ 
      _claims = await ClaimsService.myClaims(); 
      _summary = await ClaimsService.expenseClaimSummary(); 
    } catch(_) {
      _claims = []; _summary = {};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load claims')));
      }
    } finally { if(mounted) setState(()=>_loading=false);} 
  }
  
  Widget _buildSummaryCard() {
    final theme = Theme.of(context);
    if (_summary == null || _summary!.isEmpty) {
      return Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Claims Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No expense claims data available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Display actual summary data if available
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Claims Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryStats(theme),
        ],
      ),
    );
  }
  
  Widget _buildSummaryStats(ThemeData theme) {
    if (_summary == null || _summary!.isEmpty) {
      return Text(
        'No claims data available',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    // Extract key statistics from summary
    final totalClaims = _summary!['total_claims']?.toString() ?? '0';
    final totalAmount = _summary!['total_amount']?.toString() ?? '0.00';
    final pendingAmount = _summary!['pending_amount']?.toString() ?? '0.00';
    final approvedAmount = _summary!['approved_amount']?.toString() ?? '0.00';
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Claims',
                totalClaims,
                Icons.receipt_long_rounded,
                theme.colorScheme.primary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Amount',
                'R$totalAmount',
                Icons.payments_rounded,
                theme.colorScheme.primary,
                theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                'R$pendingAmount',
                Icons.pending_rounded,
                Colors.orange,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Approved',
                'R$approvedAmount',
                Icons.check_circle_rounded,
                Colors.green,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
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
  
  List<Widget> _claimsSection() {
    final pending = _claims.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='open' || s=='draft' || s=='pending' || s=='applied' || s.contains('queued');
      }
      return false;
    }).toList();
    
    final approved = _claims.where((r){
      if (r is Map) {
        final s = (r['status']??'').toString().toLowerCase();
        return s=='approved' || s=='sanctioned' || s=='paid';
      }
      return false;
    }).toList();
    
    List<Widget> widgets = [];
    
    // Pending claims
    if (pending.isEmpty) {
      widgets.add(Container(
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
              Icons.receipt_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Claims',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your pending expense claims will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ));
    } else {
      for(final r in pending) {
        widgets.add(ModernClaimItem(
          claim: r as Map<String, dynamic>,
          onCancel: () => _handleCancelClaim(r),
        ));
      }
    }
    
    // Approved claims
    if (approved.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Processed Claims',
          subtitle: 'Your approved and paid claims',
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
      ]);
      
      for(final r in approved) {
        widgets.add(ModernClaimItem(
          claim: r as Map<String, dynamic>,
        ));
      }
    }
    
    return widgets;
  }
  
  Future<void> _handleCancelClaim(Map claim) async {
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Expense Claim?'),
        content: const Text('Do you want to cancel this expense claim?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), 
            child: const Text('No')
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Yes')
          ),
        ],
      )
    );
    
    if (confirm == true) {
      await OutboxQueue.addOperation('cancel_claim', {'name': claim['name']});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense claim cancellation queued'))
        );
        _load();
      }
    }
  }
  
  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }
  
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Claims'),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _NewClaimPage()),
                );
                if (mounted) _load();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Claim'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: _loading 
        ? const ProfessionalLoading(message: 'Loading your expense claims...')
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Summary Card
                _buildSummaryCard(),
                const SizedBox(height: 24),
                
                // Pending Claims Section
                SectionHeader(
                  title: 'My Claims',
                  subtitle: 'Track your expense claims',
                  icon: Icons.receipt_long_rounded,
                  iconColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                ..._claimsSection(),
                
                // Bottom padding for navigation
                const SizedBox(height: 120),
              ],
            ),
          ),
    );
  }
}

class _ApprovalsPage extends StatefulWidget {
  @override
  State<_ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<_ApprovalsPage> {
  List<dynamic> _leaves = [];
  List<dynamic> _attendance = [];
  List<dynamic> _shifts = [];
  List<dynamic> _claims = [];
  bool _loading = true;
  Timer? _autoTimer;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _load();
    // Auto-refresh for fresh approvals
    _autoTimer = Timer.periodic(const Duration(seconds: 30), (t) {
      if (!mounted) return;
      _ticks++;
      _load();
      if (_ticks >= 10) {
        t.cancel(); // Stop after 5 minutes
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        LeavesService.teamLeaves(),
        AttendanceService.teamAttendanceRequests(),
        AttendanceService.teamShiftRequests(),
        ClaimsService.teamClaims(),
      ]);
      
      if (!mounted) return;
      setState(() {
        _leaves = results[0];
        _attendance = results[1];
        _shifts = results[2];
        _claims = results[3];
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _leaves = [];
          _attendance = [];
          _shifts = [];
          _claims = [];
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load approval requests'))
        );
      }
    }
  }

  Widget _buildSummaryCard() {
    final theme = Theme.of(context);
    final totalPending = _leaves.length + _attendance.length + _shifts.length + _claims.length;
    
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approval Dashboard',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and approve team requests',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pending',
                  totalPending.toString(),
                  Icons.pending_actions_rounded,
                  theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Categories',
                  '4',
                  Icons.category_rounded,
                  theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildApprovalsSection() {
    final widgets = <Widget>[];
    
    // Leave Applications
    if (_leaves.isNotEmpty) {
      widgets.addAll([
        SectionHeader(
          title: 'Leave Applications',
          subtitle: '${_leaves.length} pending approval',
          icon: Icons.event_note_rounded,
          iconColor: Colors.blue,
        ),
        const SizedBox(height: 12),
      ]);
      
      for (final request in _leaves) {
        widgets.add(_buildApprovalCard(
          'Leave Application',
          request,
          Icons.event_note_rounded,
          Colors.blue,
        ));
      }
      widgets.add(const SizedBox(height: 24));
    }
    
    // Attendance Requests
    if (_attendance.isNotEmpty) {
      widgets.addAll([
        SectionHeader(
          title: 'Attendance Requests',
          subtitle: '${_attendance.length} pending approval',
          icon: Icons.access_time_rounded,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 12),
      ]);
      
      for (final request in _attendance) {
        widgets.add(_buildApprovalCard(
          'Attendance Request',
          request,
          Icons.access_time_rounded,
          Colors.orange,
        ));
      }
      widgets.add(const SizedBox(height: 24));
    }
    
    // Shift Requests
    if (_shifts.isNotEmpty) {
      widgets.addAll([
        SectionHeader(
          title: 'Shift Requests',
          subtitle: '${_shifts.length} pending approval',
          icon: Icons.swap_horiz_rounded,
          iconColor: Colors.purple,
        ),
        const SizedBox(height: 12),
      ]);
      
      for (final request in _shifts) {
        widgets.add(_buildApprovalCard(
          'Shift Request',
          request,
          Icons.swap_horiz_rounded,
          Colors.purple,
        ));
      }
      widgets.add(const SizedBox(height: 24));
    }
    
    // Expense Claims
    if (_claims.isNotEmpty) {
      widgets.addAll([
        SectionHeader(
          title: 'Expense Claims',
          subtitle: '${_claims.length} pending approval',
          icon: Icons.receipt_long_rounded,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
      ]);
      
      for (final request in _claims) {
        widgets.add(_buildApprovalCard(
          'Expense Claim',
          request,
          Icons.receipt_long_rounded,
          Colors.green,
        ));
      }
      widgets.add(const SizedBox(height: 24));
    }
    
    // Empty state
    if (widgets.isEmpty) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Approvals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All requests have been processed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Approvals'),
        elevation: 0,
      ),
      body: _loading
          ? const ProfessionalLoading(message: 'Loading approval requests...')
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  ..._buildApprovalsSection(),
                  // Bottom padding for navigation
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildApprovalCard(String type, dynamic request, IconData icon, Color color) {
    final theme = Theme.of(context);
    final requestMap = request as Map<String, dynamic>;
    
    // Extract common fields
    final name = requestMap['name']?.toString() ?? 'Unknown';
    final employee = requestMap['employee']?.toString() ?? 
                    requestMap['employee_name']?.toString() ?? 'Unknown Employee';
    final status = requestMap['status']?.toString() ?? 'Pending';
    final dateRequested = requestMap['creation']?.toString() ?? 
                         requestMap['date_requested']?.toString() ?? '';
    
    // Type-specific details
    String subtitle = '';
    String details = '';
    
    switch (type) {
      case 'Leave Application':
        final leaveType = requestMap['leave_type']?.toString() ?? '';
        final fromDate = requestMap['from_date']?.toString() ?? '';
        final toDate = requestMap['to_date']?.toString() ?? '';
        final days = requestMap['total_leave_days']?.toString() ?? '';
        subtitle = '$leaveType • $days day(s)';
        details = '$fromDate to $toDate';
        break;
      case 'Attendance Request':
        final reason = requestMap['reason']?.toString() ?? '';
        final fromDate = requestMap['from_date']?.toString() ?? 
                        requestMap['from_time']?.toString() ?? '';
        final toDate = requestMap['to_date']?.toString() ?? 
                      requestMap['to_time']?.toString() ?? '';
        subtitle = reason.isNotEmpty ? reason : 'Attendance correction';
        details = '$fromDate to $toDate';
        break;
      case 'Shift Request':
        final shift = requestMap['shift']?.toString() ?? '';
        final fromDate = requestMap['from_date']?.toString() ?? '';
        final toDate = requestMap['to_date']?.toString() ?? '';
        subtitle = shift.isNotEmpty ? shift : 'Shift change';
        details = '$fromDate to $toDate';
        break;
      case 'Expense Claim':
        final amount = requestMap['total_claimed_amount']?.toString() ?? 
                      requestMap['grand_total']?.toString() ?? '0';
        final purpose = requestMap['purpose']?.toString() ?? '';
        subtitle = 'R $amount claimed';
        details = purpose.isNotEmpty ? purpose : 'Expense reimbursement';
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showApprovalDialog(type, requestMap),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    details,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleApproval(type, name, false),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _handleApproval(type, name, true),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Approve'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showApprovalDialog(String type, Map<String, dynamic> request) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ApprovalReviewDialog(
        type: type,
        request: request,
      ),
    );
    
    if (result != null) {
      final name = result['name'] as String;
      final approve = result['approve'] as bool;
      final comment = result['comment'] as String?;
      
      await _processApproval(type, name, approve, comment);
    }
  }

  Future<void> _handleApproval(String type, String name, bool approve) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ApprovalCommentDialog(
        type: type,
        name: name,
        approve: approve,
      ),
    );
    
    if (result != null) {
      await _processApproval(type, name, approve, result.isEmpty ? null : result);
    }
  }

  Future<void> _processApproval(String type, String name, bool approve, String? comment) async {
    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Approving request...' : 'Rejecting request...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Try immediate approval
      try {
        await AttendanceService.approvalAction(
          doctype: type,
          name: name,
          approve: approve,
          comment: comment,
        );
        
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: approve ? '✅ Request Approved' : '❌ Request Rejected',
            message: approve 
                ? 'The $type has been approved successfully.'
                : 'The $type has been rejected.',
          );
          _load(); // Refresh the list
        }
      } catch (e) {
        // Fallback to queue
        await OutboxQueue.addOperation('approval_action', {
          'doctype': type,
          'name': name,
          'approve': approve,
          if (comment != null) 'comment': comment,
        });
        
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '📤 Approval Queued',
            message: 'Your approval decision has been queued for processing when connection is restored.',
          );
          _load(); // Refresh to remove from pending list
        }
      }
    } catch (e) {
      if (mounted) {
        await ProfessionalErrorDialog.show(
          context: context,
          title: '❌ Approval Failed',
          errorMessage: 'Failed to process approval: ${e.toString()}',
          canRetry: true,
        );
      }
    }
  }
}

/// Dialog for quick approval with optional comment
class ApprovalCommentDialog extends StatefulWidget {
  final String type;
  final String name;
  final bool approve;
  
  const ApprovalCommentDialog({
    super.key,
    required this.type,
    required this.name,
    required this.approve,
  });
  
  @override
  State<ApprovalCommentDialog> createState() => _ApprovalCommentDialogState();
}

class _ApprovalCommentDialogState extends State<ApprovalCommentDialog> {
  final _commentController = TextEditingController();
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApprove = widget.approve;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isApprove ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isApprove ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isApprove ? 'Approve Request' : 'Reject Request',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to ${isApprove ? "approve" : "reject"} this ${widget.type.toLowerCase()}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Comment (Optional)',
              hintText: isApprove 
                  ? 'Add approval notes...' 
                  : 'Provide reason for rejection...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_commentController.text),
          style: FilledButton.styleFrom(
            backgroundColor: isApprove ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(isApprove ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}

/// Detailed dialog for reviewing request before approval
class ApprovalReviewDialog extends StatefulWidget {
  final String type;
  final Map<String, dynamic> request;
  
  const ApprovalReviewDialog({
    super.key,
    required this.type,
    required this.request,
  });
  
  @override
  State<ApprovalReviewDialog> createState() => _ApprovalReviewDialogState();
}

class _ApprovalReviewDialogState extends State<ApprovalReviewDialog> {
  final _commentController = TextEditingController();
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = widget.request;
    final name = request['name']?.toString() ?? 'Unknown';
    final employee = request['employee']?.toString() ?? 
                    request['employee_name']?.toString() ?? 'Unknown Employee';
    final status = request['status']?.toString() ?? 'Pending';
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(widget.type),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.type,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Review for approval',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Employee', employee),
                          _buildDetailRow('Request ID', name),
                          _buildDetailRow('Status', status, valueColor: Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Request Details
                    Text(
                      'Request Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _buildRequestDetails(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Comment Section
                    Text(
                      'Approval Comment',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add your approval comments here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop({
                        'name': name,
                        'approve': false,
                        'comment': _commentController.text.isEmpty ? null : _commentController.text,
                      }),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop({
                        'name': name,
                        'approve': true,
                        'comment': _commentController.text.isEmpty ? null : _commentController.text,
                      }),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'Leave Application':
        return Icons.event_note_rounded;
      case 'Attendance Request':
        return Icons.access_time_rounded;
      case 'Shift Request':
        return Icons.swap_horiz_rounded;
      case 'Expense Claim':
        return Icons.receipt_long_rounded;
      default:
        return Icons.description_rounded;
    }
  }
  
  List<Widget> _buildRequestDetails() {
    final request = widget.request;
    final details = <Widget>[];
    
    switch (widget.type) {
      case 'Leave Application':
        final leaveType = request['leave_type']?.toString() ?? '';
        final fromDate = request['from_date']?.toString() ?? '';
        final toDate = request['to_date']?.toString() ?? '';
        final days = request['total_leave_days']?.toString() ?? '';
        final reason = request['description']?.toString() ?? request['reason']?.toString() ?? '';
        final halfDay = request['half_day'] == 1 || request['half_day'] == true;
        
        if (leaveType.isNotEmpty) details.add(_buildDetailRow('Type', leaveType));
        if (fromDate.isNotEmpty) details.add(_buildDetailRow('From', fromDate));
        if (toDate.isNotEmpty) details.add(_buildDetailRow('To', toDate));
        if (days.isNotEmpty) details.add(_buildDetailRow('Days', '$days day(s)'));
        if (halfDay) details.add(_buildDetailRow('Half Day', 'Yes', valueColor: Colors.blue));
        if (reason.isNotEmpty) details.add(_buildDetailRow('Reason', reason));
        break;
        
      case 'Attendance Request':
        final fromDate = request['from_date']?.toString() ?? request['from_time']?.toString() ?? '';
        final toDate = request['to_date']?.toString() ?? request['to_time']?.toString() ?? '';
        final reason = request['reason']?.toString() ?? '';
        
        if (fromDate.isNotEmpty) details.add(_buildDetailRow('From', fromDate));
        if (toDate.isNotEmpty) details.add(_buildDetailRow('To', toDate));
        if (reason.isNotEmpty) details.add(_buildDetailRow('Reason', reason));
        break;
        
      case 'Shift Request':
        final shift = request['shift']?.toString() ?? '';
        final fromDate = request['from_date']?.toString() ?? '';
        final toDate = request['to_date']?.toString() ?? '';
        final reason = request['reason']?.toString() ?? '';
        
        if (shift.isNotEmpty) details.add(_buildDetailRow('Shift', shift));
        if (fromDate.isNotEmpty) details.add(_buildDetailRow('From', fromDate));
        if (toDate.isNotEmpty) details.add(_buildDetailRow('To', toDate));
        if (reason.isNotEmpty) details.add(_buildDetailRow('Reason', reason));
        break;
        
      case 'Expense Claim':
        final amount = request['total_claimed_amount']?.toString() ?? request['grand_total']?.toString() ?? '0';
        final purpose = request['purpose']?.toString() ?? '';
        final postingDate = request['posting_date']?.toString() ?? '';
        final company = request['company']?.toString() ?? '';
        
        if (amount != '0') details.add(_buildDetailRow('Amount', 'R $amount', valueColor: Colors.green));
        if (purpose.isNotEmpty) details.add(_buildDetailRow('Purpose', purpose));
        if (postingDate.isNotEmpty) details.add(_buildDetailRow('Date', postingDate));
        if (company.isNotEmpty) details.add(_buildDetailRow('Company', company));
        break;
    }
    
    return details;
  }
}

class _ProfilePage extends StatefulWidget {
  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  Map<String, dynamic>? _employeeData;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _profileImageUrl;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cellController;
  late TextEditingController _personalEmailController;
  late TextEditingController _currentAddressController;
  late TextEditingController _permanentAddressController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _panController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  
  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadEmployeeData();
  }
  
  void _initControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _cellController = TextEditingController();
    _personalEmailController = TextEditingController();
    _currentAddressController = TextEditingController();
    _permanentAddressController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _panController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cellController.dispose();
    _personalEmailController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _emergencyNameController.dispose();
    _emergencyContactController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }
  
  Future<void> _loadEmployeeData() async {
    try {
      final data = await ProfileService.getEmployeeDetails();
      if (mounted) {
        setState(() {
          _employeeData = data;
          _loading = false;
        });
        _populateControllers();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load employee details')),
        );
      }
    }
  }
  
  void _populateControllers() {
    if (_employeeData != null) {
      _nameController.text = _employeeData!['employee_name']?.toString() ?? '';
      _emailController.text = _employeeData!['company_email']?.toString() ?? '';
      _cellController.text = _employeeData!['cell_number']?.toString() ?? '';
      _personalEmailController.text = _employeeData!['personal_email']?.toString() ?? '';
      _currentAddressController.text = _employeeData!['current_address']?.toString() ?? '';
      _permanentAddressController.text = _employeeData!['permanent_address']?.toString() ?? '';
      _emergencyNameController.text = _employeeData!['emergency_contact_name']?.toString() ?? '';
      _emergencyContactController.text = _employeeData!['emergency_contact_number']?.toString() ?? '';
      _panController.text = _employeeData!['pan_number']?.toString() ?? '';
      _bankNameController.text = _employeeData!['bank_name']?.toString() ?? '';
      _accountNumberController.text = _employeeData!['bank_ac_no']?.toString() ?? '';
      _ifscController.text = _employeeData!['ifsc_code']?.toString() ?? '';
      
      // Load profile image URL
      _loadProfileImage();
    }
  }
  
  Future<void> _loadProfileImage() async {
    if (_employeeData != null) {
      final imagePath = _employeeData!['image']?.toString();
      final fullUrl = await ProfileService.getFullImageUrl(imagePath);
      if (mounted) {
        setState(() {
          _profileImageUrl = fullUrl;
        });
      }
    }
  }
  
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return;
      
      setState(() => _uploadingImage = true);
      
      final file = File(pickedFile.path);
      final uploadedUrl = await ProfileService.uploadProfileImage(file);
      
      if (uploadedUrl != null && mounted) {
        setState(() {
          _profileImageUrl = uploadedUrl;
          // Update employee data locally
          _employeeData!['image'] = uploadedUrl;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingImage = false);
      }
    }
  }
  
  Future<void> _showImagePicker() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
            ],
          ),
        );
      },
    );
    
    if (choice != null) {
      if (choice == 'remove') {
        await _removeProfileImage();
      } else {
        final picker = ImagePicker();
        final source = choice == 'gallery' ? ImageSource.gallery : ImageSource.camera;
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 85,
        );
        
        if (pickedFile != null) {
          setState(() => _uploadingImage = true);
          
          try {
            final file = File(pickedFile.path);
            final uploadedUrl = await ProfileService.uploadProfileImage(file);
            
            if (uploadedUrl != null && mounted) {
              setState(() {
                _profileImageUrl = uploadedUrl;
                _employeeData!['image'] = uploadedUrl;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile image updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating image: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() => _uploadingImage = false);
            }
          }
        }
      }
    }
  }
  
  Future<void> _removeProfileImage() async {
    try {
      setState(() => _uploadingImage = true);
      
      await ProfileService.updateEmployeeDetails({'image': null});
      
      if (mounted) {
        setState(() {
          _profileImageUrl = null;
          _employeeData!['image'] = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingImage = false);
      }
    }
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);
    
    try {
      final updateData = {
        'cell_number': _cellController.text.trim(),
        'personal_email': _personalEmailController.text.trim(),
        'current_address': _currentAddressController.text.trim(),
        'permanent_address': _permanentAddressController.text.trim(),
        'emergency_contact_name': _emergencyNameController.text.trim(),
        'emergency_contact_number': _emergencyContactController.text.trim(),
        'pan_number': _panController.text.trim(),
        'bank_name': _bankNameController.text.trim(),
        'bank_ac_no': _accountNumberController.text.trim(),
        'ifsc_code': _ifscController.text.trim(),
      };
      
      // Add to queue for offline support
      await OutboxQueue.addOperation('update_employee_profile', updateData);
      
      if (mounted) {
        setState(() {
          _editing = false;
          _saving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload data
        await _loadEmployeeData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildFormSection({required String title, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: ProfessionalLoading()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing && _employeeData != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
          if (_editing) ...[
            TextButton(
              onPressed: _saving ? null : () {
                setState(() => _editing = false);
                _populateControllers(); // Reset form
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saving ? null : _saveChanges,
              child: _saving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
            ),
          ],
        ],
      ),
      body: _employeeData == null 
        ? const Center(child: Text('No employee data found'))
        : Form(
            key: _formKey,
            child: RefreshIndicator(
              onRefresh: _loadEmployeeData,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: _uploadingImage ? null : _showImagePicker,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: theme.colorScheme.primary,
                                  backgroundImage: _profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!)
                                      : null,
                                  child: _uploadingImage
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : _profileImageUrl == null
                                          ? Text(
                                              (_employeeData!['employee_name']?.toString() ?? 'U')
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                ),
                              ),
                            ),
                            if (!_uploadingImage)
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 16),
                                  color: Colors.white,
                                  onPressed: _showImagePicker,
                                  iconSize: 16,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _employeeData!['employee_name']?.toString() ?? 'Unknown',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _employeeData!['designation']?.toString() ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_employeeData!['employee_number'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${_employeeData!['employee_number']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Personal Information (Read-only)
                  if (!_editing)
                    _buildFormSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _buildInfoRow('Full Name', _employeeData!['employee_name']?.toString()),
                          _buildInfoRow('Gender', _employeeData!['gender']?.toString()),
                          _buildInfoRow('Date of Birth', _employeeData!['date_of_birth']?.toString()),
                          _buildInfoRow('Date of Joining', _employeeData!['date_of_joining']?.toString()),
                          _buildInfoRow('Blood Group', _employeeData!['blood_group']?.toString()),
                        ],
                      ),
                    ),
                  
                  // Company Information (Read-only)
                  if (!_editing)
                    _buildFormSection(
                      title: 'Company Information',
                      icon: Icons.business_outlined,
                      child: Column(
                        children: [
                          _buildInfoRow('Company', _employeeData!['company']?.toString()),
                          _buildInfoRow('Department', _employeeData!['department']?.toString()),
                          _buildInfoRow('Designation', _employeeData!['designation']?.toString()),
                          _buildInfoRow('Branch', _employeeData!['branch']?.toString()),
                          _buildInfoRow('Employment Type', _employeeData!['employment_type']?.toString()),
                        ],
                      ),
                    ),
                  
                  // Contact Information (Editable)
                  _buildFormSection(
                    title: 'Contact Information',
                    icon: Icons.contact_phone_outlined,
                    child: Column(
                      children: [
                        if (!_editing) ...[
                          _buildInfoRow('Company Email', _employeeData!['company_email']?.toString()),
                          _buildInfoRow('Personal Email', _employeeData!['personal_email']?.toString()),
                          _buildInfoRow('Mobile Number', _employeeData!['cell_number']?.toString()),
                        ] else ...[
                          TextFormField(
                            controller: _personalEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Personal Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                            validator: (v) {
                              if (v?.isNotEmpty == true && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cellController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                            validator: (v) {
                              if (v?.isNotEmpty == true && v!.length < 10) {
                                return 'Enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Address Information (Editable)
                  _buildFormSection(
                    title: 'Address Information',
                    icon: Icons.location_on_outlined,
                    child: Column(
                      children: [
                        if (!_editing) ...[
                          _buildInfoRow('Current Address', _employeeData!['current_address']?.toString()),
                          _buildInfoRow('Permanent Address', _employeeData!['permanent_address']?.toString()),
                        ] else ...[
                          TextFormField(
                            controller: _currentAddressController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Current Address',
                              prefixIcon: const Icon(Icons.home_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _permanentAddressController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Permanent Address',
                              prefixIcon: const Icon(Icons.location_city_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Emergency Contact (Editable)
                  _buildFormSection(
                    title: 'Emergency Contact',
                    icon: Icons.emergency_outlined,
                    child: Column(
                      children: [
                        if (!_editing) ...[
                          _buildInfoRow('Contact Name', _employeeData!['emergency_contact_name']?.toString()),
                          _buildInfoRow('Contact Number', _employeeData!['emergency_contact_number']?.toString()),
                        ] else ...[
                          TextFormField(
                            controller: _emergencyNameController,
                            decoration: InputDecoration(
                              labelText: 'Emergency Contact Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyContactController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Emergency Contact Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Financial Information (Editable)
                  _buildFormSection(
                    title: 'Financial Information',
                    icon: Icons.account_balance_outlined,
                    child: Column(
                      children: [
                        if (!_editing) ...[
                          _buildInfoRow('PAN Number', _employeeData!['pan_number']?.toString()),
                          _buildInfoRow('Bank Name', _employeeData!['bank_name']?.toString()),
                          _buildInfoRow('Account Number', _employeeData!['bank_ac_no']?.toString()),
                          _buildInfoRow('IFSC Code', _employeeData!['ifsc_code']?.toString()),
                        ] else ...[
                          TextFormField(
                            controller: _panController,
                            decoration: InputDecoration(
                              labelText: 'PAN Number',
                              prefixIcon: const Icon(Icons.credit_card_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bankNameController,
                            decoration: InputDecoration(
                              labelText: 'Bank Name',
                              prefixIcon: const Icon(Icons.account_balance),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _accountNumberController,
                            decoration: InputDecoration(
                              labelText: 'Account Number',
                              prefixIcon: const Icon(Icons.numbers_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ifscController,
                            decoration: InputDecoration(
                              labelText: 'IFSC Code',
                              prefixIcon: const Icon(Icons.code_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Settings Section
                  _buildFormSection(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.cloud_sync_outlined),
                          title: const Text('Queue Status'),
                          subtitle: const Text('View pending operations'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => QueueStatusScreen()),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.sync_outlined),
                          title: const Text('Sync HR Data'),
                          subtitle: const Text('Synchronize with server'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('HR sync started...')),
                            );
                            try {
                              await OutboxQueue.processQueue();
                            } catch (e) {
                              // ignore
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('HR sync complete'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout'),
                          subtitle: const Text('Sign out of your account'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              var authBox = await Hive.openBox('authBox');
                              await authBox.clear();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom padding for navigation
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildInfoRow(String label, String? value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'Not provided',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value?.isNotEmpty == true 
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontStyle: value?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewAttendanceRequestPage extends StatefulWidget {
  const _NewAttendanceRequestPage({super.key});
  @override 
  State<_NewAttendanceRequestPage> createState() => _NewAttendanceRequestPageState();
}

class _NewAttendanceRequestPageState extends State<_NewAttendanceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _fromDate;
  String? _toDate;
  String? _reason;
  bool _loading = false;

  Future<void> _pickDate(bool isFromDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (picked != null) {
      final dateString = picked.toIso8601String().substring(0, 10);
      setState(() {
        if (isFromDate) {
          _fromDate = dateString;
        } else {
          _toDate = dateString;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      await OutboxQueue.addOperation('attendance_request', {
        'from_date': _fromDate,
        'to_date': _toDate,
        'reason': _reason,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Attendance request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        color: theme.colorScheme.surfaceContainer?.withOpacity(0.5) ?? theme.colorScheme.surface,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Request'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Form(
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
                          Icons.access_time_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'New Attendance Request',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request attendance correction for specific dates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Date Selection Section
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
                            fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
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
                            fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason Section
            _buildFormSection(
              title: 'Details',
              icon: Icons.edit_note_rounded,
              child: TextFormField(
                maxLines: 3,
                onChanged: (v) => _reason = v,
                decoration: InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Please provide details about your attendance request...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
                ),
              ),
            ),

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
                  _loading ? 'Submitting...' : 'Submit Attendance Request',
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
}

class _NewShiftRequestPage extends StatefulWidget {
  const _NewShiftRequestPage({super.key});
  @override 
  State<_NewShiftRequestPage> createState() => _NewShiftRequestPageState();
}

class _NewShiftRequestPageState extends State<_NewShiftRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _shift;
  String? _fromDate;
  String? _toDate;
  String? _reason;
  bool _loading = false;
  bool _loadingMeta = true;
  List<String> _shiftOptions = [];

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final types = await AttendanceService.shiftTypes();
      final t = <String>[];
      for (final x in types) {
        if (x is Map && x['name'] != null) t.add(x['name'].toString());
        else if (x is String) t.add(x);
      }
      if (!mounted) return;
      setState(() {
        _shiftOptions = t;
        _loadingMeta = false;
      });
    } catch (_) { 
      if(mounted) setState(()=>_loadingMeta=false); 
    }
  }

  Future<void> _pickDate(bool isFromDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (picked != null) {
      final dateString = picked.toIso8601String().substring(0, 10);
      setState(() {
        if (isFromDate) {
          _fromDate = dateString;
        } else {
          _toDate = dateString;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final payload = {
        'shift': _shift,
        'from_date': _fromDate,
        'to_date': _toDate,
        'reason': _reason,
      };
      
      // Try immediate submission first
      try {
        await AttendanceService.submitShiftRequest(payload);
        
        // Success - show confirmation
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '✅ Shift Request Submitted',
            message: 'Your shift request for "${_shift!}" from ${_fromDate!} to ${_toDate!} has been successfully submitted for approval.',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // If immediate submission fails, add to queue as fallback
        await OutboxQueue.addOperation('shift_request', payload);
        
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '📤 Shift Request Queued',
            message: 'Your shift request has been queued for submission. It will be automatically submitted when connection is restored.',
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        await ProfessionalErrorDialog.show(
          context: context,
          title: '❌ Submission Failed',
          errorMessage: 'Failed to submit shift request: ${e.toString()}',
          canRetry: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        color: theme.colorScheme.surfaceContainer?.withOpacity(0.5) ?? theme.colorScheme.surface,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Request'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _loadingMeta 
        ? const ProfessionalLoading(message: 'Loading shift types...')
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
                          Icons.swap_horiz_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'New Shift Request',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request a change to your work shift schedule',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Shift Details Section
            _buildFormSection(
              title: 'Shift Details',
              icon: Icons.schedule_rounded,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _shift,
                items: _shiftOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                )).toList(),
                onChanged: (v) => setState(() => _shift = v),
                decoration: InputDecoration(
                  labelText: 'Requested Shift',
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
                ),
                validator: (v) => v == null ? 'Please select a shift' : null,
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection Section
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
                            fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
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
                            fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason Section
            _buildFormSection(
              title: 'Details',
              icon: Icons.edit_note_rounded,
              child: TextFormField(
                maxLines: 3,
                onChanged: (v) => _reason = v,
                decoration: InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Please provide details about your shift change request...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant?.withOpacity(0.3),
                ),
              ),
            ),

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
                  _loading ? 'Submitting...' : 'Submit Shift Request',
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
}

class _NewClaimPage extends StatefulWidget { @override State<_NewClaimPage> createState()=>_NewClaimPageState(); }
class _NewClaimPageState extends State<_NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields based on HRMS Expense Claim structure
  String? _employee;
  String? _company;
  String? _expenseType;
  String? _postingDate;
  double? _totalClaimedAmount;
  String? _purpose;
  String? _remark;
  String? _expenseApprover;
  String? _costCenter;
  String? _payableAccount;
  String? _project;
  String? _modeOfPayment;
  final List<File> _attachments = [];
  
  bool _loading = false;
  bool _loadingMeta = true;
  List<String> _companies = [];
  List<String> _expenseTypes = [];
  List<String> _expenseApprovers = [];
  Map<String, dynamic>? _companyDetails;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      // Get current employee
      _employeeId = await ProfileService.currentEmployee();
      
      // Get companies from userDetails (assuming it's available there)
      try {
        final box = await Hive.openBox('authBox');
        final raw = box.get('userDetails');
        if (raw is String) {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          _company = m['company']?.toString();
          if (_company != null) {
            _companies = [_company!]; // For now, just use the user's company
          }
        }
      } catch (_) {}
      
      // Get expense claim types
      final types = await ClaimsService.claimTypes();
      final expenseTypesList = <String>[];
      for (final x in types) {
        if (x is Map && x['name'] != null) expenseTypesList.add(x['name'].toString());
        else if (x is String) expenseTypesList.add(x);
      }
      
      // Set today as default posting date
      final today = DateTime.now();
      _postingDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      if (!mounted) return;
      setState(() {
        _expenseTypes = expenseTypesList;
        _loadingMeta = false;
      });
      
      // Load company details if company is selected
      if (_company != null) {
        await _loadCompanyDetails();
      }
      
      // Load expense approver details
      if (_employeeId != null) {
        await _loadApproverDetails();
      }
      
    } catch (_) { 
      if(mounted) setState(()=> _loadingMeta = false); 
    }
  }
  
  Future<void> _loadCompanyDetails() async {
    if (_company == null) return;
    try {
      final details = await ClaimsService.getCompanyAccounts(_company!);
      setState(() {
        _companyDetails = details;
        _costCenter = details['cost_center']?.toString();
        _payableAccount = details['default_expense_claim_payable_account']?.toString();
      });
    } catch (_) {}
  }
  
  Future<void> _loadApproverDetails() async {
    if (_employeeId == null) return;
    try {
      final details = await ClaimsService.getExpenseApprovalDetails(_employeeId!);
      final approvers = details['department_approvers'] as List<dynamic>? ?? [];
      final approversList = <String>[];
      
      for (final approver in approvers) {
        if (approver is Map) {
          final name = approver['name']?.toString();
          if (name != null) approversList.add(name);
        }
      }
      
      setState(() {
        _expenseApprovers = approversList;
        _expenseApprover = details['expense_approver']?.toString();
      });
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (picked != null) {
      setState(() {
        _postingDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        allowMultiple: true, 
        withData: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );
      if (res != null) {
        setState(() {
          for (final f in res.files) { 
            if (f.path != null && _attachments.length < 10) { // Limit to 10 attachments
              _attachments.add(File(f.path!)); 
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick files. Please try again.'))
        );
      }
    }
  }
  
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      // Validate required fields
      if (_totalClaimedAmount == null || _totalClaimedAmount! <= 0) {
        await ProfessionalErrorDialog.show(
          context: context,
          title: '💰 Invalid Amount',
          errorMessage: 'Please enter a valid claim amount greater than zero.',
          canRetry: false,
        );
        return;
      }

      // Process attachments
      final atts = <Map<String, dynamic>>[];
      for (final f in _attachments) {
        try {
          final bytes = await f.readAsBytes();
          final b64 = base64Encode(bytes);
          final filename = f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : 'attachment';
          atts.add({
            'filename': filename, 
            'data': b64,
            'is_private': 1,
          });
        } catch (_) {
          // Skip files that can't be read
        }
      }
      
      final payload = {
        'employee': _employeeId,
        'company': _company,
        'posting_date': _postingDate,
        'expense_type': _expenseType,
        'total_claimed_amount': _totalClaimedAmount,
        'purpose': _purpose,
        'remark': _remark,
        if (_expenseApprover != null) 'expense_approver': _expenseApprover,
        if (_costCenter != null) 'cost_center': _costCenter,
        if (_payableAccount != null) 'payable_account': _payableAccount,
        if (_project != null) 'project': _project,
        if (_modeOfPayment != null) 'mode_of_payment': _modeOfPayment,
        'attachments': atts,
      };
      
      // Try immediate submission first
      try {
        await ClaimsService.submitExpenseClaim(payload);
        
        // Success - show confirmation
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '✅ Expense Claim Submitted',
            message: 'Your expense claim for ${_formatCurrency(_totalClaimedAmount!)} has been successfully submitted for approval.',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // If immediate submission fails, add to queue as fallback
        await OutboxQueue.addOperation('expense_claim', payload);
        
        if (mounted) {
          await ProfessionalSuccessDialog.show(
            context: context,
            title: '📤 Expense Claim Queued',
            message: 'Your expense claim has been queued for submission. It will be automatically submitted when connection is restored.',
          );
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  String _formatCurrency(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense Claim'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _loadingMeta 
        ? const ProfessionalLoading(message: 'Loading expense claim form...')
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
                              Icons.receipt_long_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'New Expense Claim',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in your expense details below for reimbursement',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Company & Basic Details Section
                _buildFormSection(
                  title: 'Company Details',
                  icon: Icons.business_rounded,
                  child: Column(
                    children: [
                      if (_companies.isNotEmpty)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _company,
                          items: _companies.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          )).toList(),
                          onChanged: (v) async {
                            setState(() => _company = v);
                            if (v != null) await _loadCompanyDetails();
                          },
                          decoration: InputDecoration(
                            labelText: 'Company',
                            prefixIcon: const Icon(Icons.business_center_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          validator: (v) => v == null ? 'Please select a company' : null,
                        )
                      else
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Company',
                            prefixIcon: const Icon(Icons.business_center_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (v) => _company = v,
                          validator: (v) => (v == null || v.isEmpty) ? 'Company is required' : null,
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: _postingDate ?? ''),
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: 'Posting Date',
                          labelStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Date is required' : null,
                      ),
                    ],
                  ),
                ),

                // Expense Details Section
                _buildFormSection(
                  title: 'Expense Details',
                  icon: Icons.payment_rounded,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _expenseType,
                        items: _expenseTypes.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (v) => setState(() => _expenseType = v),
                        decoration: InputDecoration(
                          labelText: 'Expense Type',
                          prefixIcon: const Icon(Icons.category_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (v) => v == null ? 'Please select an expense type' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Claim Amount (R)',
                          prefixIcon: const Icon(Icons.payments_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        onChanged: (v) => _totalClaimedAmount = double.tryParse(v),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Amount is required';
                          final amount = double.tryParse(v);
                          if (amount == null || amount <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Purpose',
                          prefixIcon: const Icon(Icons.description_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        onChanged: (v) => _purpose = v,
                        validator: (v) => (v == null || v.isEmpty) ? 'Purpose is required' : null,
                      ),
                    ],
                  ),
                ),

                // Additional Information Section
                _buildFormSection(
                  title: 'Additional Information',
                  icon: Icons.edit_note_rounded,
                  child: Column(
                    children: [
                      if (_expenseApprovers.isNotEmpty)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _expenseApprover,
                          items: _expenseApprovers.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          )).toList(),
                          onChanged: (v) => setState(() => _expenseApprover = v),
                          decoration: InputDecoration(
                            labelText: 'Expense Approver (Optional)',
                            prefixIcon: const Icon(Icons.person_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                        ),
                      if (_expenseApprovers.isNotEmpty) const SizedBox(height: 16),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Remarks (Optional)',
                          hintText: 'Additional details about the expense...',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        onChanged: (v) => _remark = v,
                      ),
                    ],
                  ),
                ),

                // Attachments Section
                _buildFormSection(
                  title: 'Attachments',
                  icon: Icons.attachment_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attach receipts and supporting documents',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_attachments.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _attachments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            final filename = file.uri.pathSegments.isNotEmpty 
                              ? file.uri.pathSegments.last 
                              : 'file';
                            return Chip(
                              label: Text(
                                filename.length > 20 ? '${filename.substring(0, 17)}...' : filename,
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeAttachment(index),
                              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _attachments.length < 10 ? _pickFiles : null,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(_attachments.isEmpty 
                            ? 'Add Attachments' 
                            : 'Add More (${_attachments.length}/10)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                      _loading ? 'Submitting...' : 'Submit Expense Claim',
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
}
