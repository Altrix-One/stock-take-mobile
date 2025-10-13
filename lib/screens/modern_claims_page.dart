import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/widgets/modern_ui_components.dart';
import 'package:stock_count/widgets/modern_enhanced_cards.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'dart:async';
import 'dart:io';

class ModernClaimsPage extends StatefulWidget {
  const ModernClaimsPage({super.key});

  @override
  State<ModernClaimsPage> createState() => _ModernClaimsPageState();
}

class _ModernClaimsPageState extends State<ModernClaimsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _myClaims = [];
  List<dynamic> _claimCategories = [];
  Timer? _refreshTimer;
  Map<String, dynamic> _claimsStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClaimsData();
    
    // Listen to outbox queue changes
    OutboxQueue.events.listen((_) {
      if (mounted) _loadClaimsData();
    });
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadClaimsData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadClaimsData() async {
    try {
      final results = await Future.wait([
        ClaimsService.myClaims(),
        ClaimsService.claimCategories(),
        ClaimsService.claimsStats(),
      ]);
      
      setState(() {
        _myClaims = results[0] as List<dynamic>;
        _claimCategories = results[1] as List<dynamic>;
        _claimsStats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading claims data: $e');
      setState(() {
        _isLoading = false;
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
                    ? const ModernLoadingIndicator(message: 'Loading claims data...')
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMyClaimsTab(),
                          _buildStatsTab(),
                          _buildCategoriesTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewClaimForm,
        backgroundColor: ModernDesignSystem.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Claim',
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
                  'Expense Claims',
                  style: ModernDesignSystem.displaySmall.copyWith(
                    color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ModernDesignSystem.verticalSpaceMicro,
                Text(
                  'Manage your expense claims',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadClaimsData,
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
          Tab(text: 'My Claims'),
          Tab(text: 'Statistics'),
          Tab(text: 'Categories'),
        ],
      ),
    );
  }
  
  Widget _buildMyClaimsTab() {
    return RefreshIndicator(
      onRefresh: _loadClaimsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Recent Claims
            _buildRecentClaims(),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadClaimsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Monthly Overview
            _buildMonthlyOverview(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Category Breakdown
            _buildCategoryBreakdown(),
            ModernDesignSystem.verticalSpaceLG,
            
            // Status Distribution
            _buildStatusDistribution(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoriesTab() {
    return RefreshIndicator(
      onRefresh: _loadClaimsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
        child: Column(
          children: [
            // Categories List
            _buildCategoriesList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    final pendingAmount = _claimsStats['pending_amount']?.toString() ?? '0.00';
    final approvedAmount = _claimsStats['approved_amount']?.toString() ?? '0.00';
    final totalClaims = _claimsStats['total_claims']?.toString() ?? '0';
    
    return Row(
      children: [
        Expanded(
          child: ModernStatsCard(
            label: 'Pending Amount',
            value: '\$${double.parse(pendingAmount).toStringAsFixed(2)}',
            icon: Icons.pending_actions,
            color: ModernDesignSystem.warning,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Approved Amount',
            value: '\$${double.parse(approvedAmount).toStringAsFixed(2)}',
            icon: Icons.check_circle,
            color: ModernDesignSystem.success,
            isCompact: true,
          ),
        ),
        ModernDesignSystem.horizontalSpaceXS,
        Expanded(
          child: ModernStatsCard(
            label: 'Total Claims',
            value: totalClaims,
            icon: Icons.receipt,
            color: ModernDesignSystem.primaryTeal,
            isCompact: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentClaims() {
    if (_myClaims.isEmpty) {
      return ModernEmptyState(
        icon: Icons.receipt_long,
        title: 'No Claims Found',
        subtitle: 'Your expense claims will appear here',
        actionText: 'Submit New Claim',
        onAction: _showNewClaimForm,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Recent Claims',
          subtitle: '${_myClaims.length} claims',
          icon: Icons.receipt,
        ),
        
        ...(_myClaims.map((claim) => _buildClaimItem(claim as Map<String, dynamic>))),
      ],
    );
  }
  
  Widget _buildClaimItem(Map<String, dynamic> claim) {
    final id = claim['id']?.toString() ?? '';
    final title = claim['title']?.toString() ?? 'Untitled Claim';
    final amount = claim['amount']?.toString() ?? '0.00';
    final status = claim['status']?.toString() ?? 'Draft';
    final submittedDate = claim['submitted_date']?.toString();
    final category = claim['category']?.toString() ?? '';
    
    Color statusColor = ModernDesignSystem.neutralLight;
        IconData statusIcon = Icons.edit_document;
    
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
      case 'submitted':
        statusColor = ModernDesignSystem.warning;
        statusIcon = Icons.pending;
        break;
      case 'paid':
        statusColor = ModernDesignSystem.info;
        statusIcon = Icons.payment;
        break;
    }
    
    return ModernInfoCard(
      title: title,
      subtitle: category.isNotEmpty ? '$category • \$${double.parse(amount).toStringAsFixed(2)}' : '\$${double.parse(amount).toStringAsFixed(2)}',
      badge: status.toUpperCase(),
      badgeColor: statusColor,
      icon: statusIcon,
      iconColor: statusColor,
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
      onTap: () => _showClaimDetails(claim),
      actions: status.toLowerCase() == 'draft' 
          ? [IconButton(
              onPressed: () => _editClaim(claim),
              icon: const Icon(Icons.edit),
              iconSize: 20,
              color: ModernDesignSystem.primaryTeal,
            )]
          : null,
    );
  }
  
  Widget _buildMonthlyOverview() {
    final thisMonth = DateTime.now();
    final thisMonthAmount = _claimsStats['this_month_amount']?.toString() ?? '0.00';
    final lastMonthAmount = _claimsStats['last_month_amount']?.toString() ?? '0.00';
    final avgMonthlyAmount = _claimsStats['avg_monthly_amount']?.toString() ?? '0.00';
    
    return ModernHeroCard(
      title: 'Monthly Overview',
      subtitle: '${thisMonth.month}/${thisMonth.year}',
      icon: Icons.insights,
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewItem('This Month', '\$${double.parse(thisMonthAmount).toStringAsFixed(2)}', Icons.calendar_today, ModernDesignSystem.primaryTeal),
          ),
          Expanded(
            child: _buildOverviewItem('Last Month', '\$${double.parse(lastMonthAmount).toStringAsFixed(2)}', Icons.history, ModernDesignSystem.info),
          ),
          Expanded(
            child: _buildOverviewItem('Avg Monthly', '\$${double.parse(avgMonthlyAmount).toStringAsFixed(2)}', Icons.trending_up, ModernDesignSystem.success),
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
  
  Widget _buildCategoryBreakdown() {
    final categoryStats = _claimsStats['category_breakdown'] as List<dynamic>? ?? [];
    
    if (categoryStats.isEmpty) {
      return ModernEmptyState(
        icon: Icons.pie_chart,
        title: 'No Category Data',
        subtitle: 'Category breakdown will appear here',
      );
    }
    
    return ModernHeroCard(
      title: 'Category Breakdown',
      subtitle: 'Top spending categories',
      icon: Icons.pie_chart,
      child: Column(
        children: categoryStats.take(5).map((category) {
          final name = category['name']?.toString() ?? '';
          final amount = category['amount']?.toString() ?? '0.00';
          final percentage = category['percentage']?.toString() ?? '0';
          
          return Container(
            margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceXS),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: ModernDesignSystem.labelLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                        ),
                      ),
                      LinearProgressIndicator(
                        value: double.parse(percentage) / 100,
                        backgroundColor: ModernDesignSystem.getBorderColor(Theme.of(context).brightness),
                        valueColor: AlwaysStoppedAnimation<Color>(ModernDesignSystem.primaryTeal),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                ModernDesignSystem.horizontalSpaceSM,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${double.parse(amount).toStringAsFixed(2)}',
                      style: ModernDesignSystem.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: ModernDesignSystem.captionLarge.copyWith(
                        color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStatusDistribution() {
    final statusStats = _claimsStats['status_distribution'] as List<dynamic>? ?? [];
    
    if (statusStats.isEmpty) {
      return ModernEmptyState(
        icon: Icons.donut_small,
        title: 'No Status Data',
        subtitle: 'Status distribution will appear here',
      );
    }
    
    return ModernHeroCard(
      title: 'Status Distribution',
      subtitle: 'Claims by status',
      icon: Icons.donut_small,
      child: Row(
        children: statusStats.map((status) {
          final name = status['name']?.toString() ?? '';
          final count = status['count']?.toString() ?? '0';
          
          Color statusColor = ModernDesignSystem.neutralLight;
          switch (name.toLowerCase()) {
            case 'approved':
              statusColor = ModernDesignSystem.success;
              break;
            case 'rejected':
              statusColor = ModernDesignSystem.error;
              break;
            case 'pending':
              statusColor = ModernDesignSystem.warning;
              break;
            case 'paid':
              statusColor = ModernDesignSystem.info;
              break;
          }
          
          return Expanded(
            child: _buildStatusItem(name, count, statusColor),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStatusItem(String status, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          ),
          child: Text(
            count,
            style: ModernDesignSystem.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        ModernDesignSystem.verticalSpaceXS,
        Text(
          status,
          style: ModernDesignSystem.captionLarge.copyWith(
            color: ModernDesignSystem.getTextSecondary(Theme.of(context).brightness),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildCategoriesList() {
    if (_claimCategories.isEmpty) {
      return ModernEmptyState(
        icon: Icons.category,
        title: 'No Categories Found',
        subtitle: 'Expense categories will appear here',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Expense Categories',
          subtitle: '${_claimCategories.length} categories',
          icon: Icons.category,
        ),
        
        ...(_claimCategories.map((category) => _buildCategoryItem(category as Map<String, dynamic>))),
      ],
    );
  }
  
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final name = category['name']?.toString() ?? '';
    final description = category['description']?.toString() ?? '';
    final maxAmount = category['max_amount']?.toString();
    final isActive = category['is_active'] ?? true;
    
    return ModernActionCard(
      title: name,
      subtitle: description.isNotEmpty ? description : null,
      icon: Icons.category,
      color: isActive ? ModernDesignSystem.primaryTeal : ModernDesignSystem.neutralLight,
      onTap: () => _showCategoryDetails(category),
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spaceSM),
    );
  }
  
  void _showNewClaimForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewClaimFormPage(),
      ),
    ).then((_) => _loadClaimsData());
  }
  
  void _editClaim(Map<String, dynamic> claim) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewClaimFormPage(existingClaim: claim),
      ),
    ).then((_) => _loadClaimsData());
  }
  
  void _showClaimDetails(Map<String, dynamic> claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClaimDetailsBottomSheet(claim: claim),
    );
  }
  
  void _showCategoryDetails(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryDetailsBottomSheet(category: category),
    );
  }
}

// New Claim Form Page
class NewClaimFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingClaim;
  
  const NewClaimFormPage({super.key, this.existingClaim});
  
  @override
  State<NewClaimFormPage> createState() => _NewClaimFormPageState();
}

class _NewClaimFormPageState extends State<NewClaimFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _expenseDate;
  String? _selectedCategory;
  List<File> _attachedFiles = [];
  bool _isSubmitting = false;
  List<dynamic> _categories = [];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // Pre-fill form if editing existing claim
    if (widget.existingClaim != null) {
      _titleController.text = widget.existingClaim!['title']?.toString() ?? '';
      _amountController.text = widget.existingClaim!['amount']?.toString() ?? '';
      _descriptionController.text = widget.existingClaim!['description']?.toString() ?? '';
      _selectedCategory = widget.existingClaim!['category']?.toString();
      final dateStr = widget.existingClaim!['expense_date']?.toString();
      if (dateStr != null) {
        _expenseDate = DateTime.parse(dateStr);
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await ClaimsService.claimCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
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
                title: widget.existingClaim != null ? 'Edit Claim' : 'New Expense Claim',
                showBackButton: true,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBasicInfoSection(),
                        ModernDesignSystem.verticalSpaceMD,
                        
                        _buildExpenseDetailsSection(),
                        ModernDesignSystem.verticalSpaceMD,
                        
                        _buildAttachmentsSection(),
                        ModernDesignSystem.verticalSpaceXL,
                        
                        _buildActionButtons(),
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
  
  Widget _buildBasicInfoSection() {
    return ModernHeroCard(
      title: 'Basic Information',
      icon: Icons.info,
      child: Column(
        children: [
          ModernInputField(
            controller: _titleController,
            label: 'Claim Title',
            hint: 'Enter a descriptive title',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a claim title';
              }
              return null;
            },
          ),
          ModernDesignSystem.verticalSpaceMD,
          
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              hintText: 'Select expense category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                borderSide: BorderSide(color: ModernDesignSystem.getBorderColor(Theme.of(context).brightness)),
              ),
              contentPadding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
            ),
            items: _categories.map((category) {
              final name = category['name']?.toString() ?? '';
              return DropdownMenuItem(
                value: name,
                child: Text(name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpenseDetailsSection() {
    return ModernHeroCard(
      title: 'Expense Details',
      icon: Icons.receipt,
      child: Column(
        children: [
          ModernInputField(
            controller: _amountController,
            label: 'Amount',
            hint: '0.00',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the expense amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          ModernDesignSystem.verticalSpaceMD,
          
          InkWell(
            onTap: _selectExpenseDate,
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
                    _expenseDate != null 
                        ? '${_expenseDate!.day}/${_expenseDate!.month}/${_expenseDate!.year}'
                        : 'Select expense date',
                    style: ModernDesignSystem.bodyMedium.copyWith(
                      color: _expenseDate != null 
                          ? ModernDesignSystem.getTextPrimary(Theme.of(context).brightness)
                          : ModernDesignSystem.getTextTertiary(Theme.of(context).brightness),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ModernDesignSystem.verticalSpaceMD,
          
          ModernInputField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Provide additional details about this expense...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttachmentsSection() {
    return ModernHeroCard(
      title: 'Attachments',
      subtitle: 'Add receipts and supporting documents',
      icon: Icons.attach_file,
      child: Column(
        children: [
          if (_attachedFiles.isNotEmpty) ...[
            ..._attachedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Container(
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
                        file.path.split('/').last,
                        style: ModernDesignSystem.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeAttachment(index),
                      icon: const Icon(Icons.close),
                      iconSize: 16,
                      color: ModernDesignSystem.error,
                    ),
                  ],
                ),
              );
            }),
            ModernDesignSystem.verticalSpaceSM,
          ],
          
          Row(
            children: [
              Expanded(
                child: ModernSecondaryButton(
                  text: 'Add Photo',
                  onPressed: _attachPhoto,
                  icon: Icons.camera_alt,
                ),
              ),
              ModernDesignSystem.horizontalSpaceXS,
              Expanded(
                child: ModernSecondaryButton(
                  text: 'Add File',
                  onPressed: _attachFile,
                  icon: Icons.attach_file,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        ModernPrimaryButton(
          text: widget.existingClaim != null ? 'Update Claim' : 'Submit Claim',
          isLoading: _isSubmitting,
          onPressed: _submitClaim,
          icon: Icons.send,
        ),
        
        if (widget.existingClaim != null) ...[
          ModernDesignSystem.verticalSpaceSM,
          ModernSecondaryButton(
            text: 'Save as Draft',
            onPressed: _saveDraft,
            icon: Icons.save,
          ),
        ],
      ],
    );
  }
  
  Future<void> _selectExpenseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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
      setState(() => _expenseDate = date);
    }
  }
  
  void _attachPhoto() {
    // TODO: Implement camera/photo picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo attachment will be available in a future update.')),
    );
  }
  
  void _attachFile() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attachment will be available in a future update.')),
    );
  }
  
  void _removeAttachment(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }
  
  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expenseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expense date')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      if (widget.existingClaim != null) {
        await ClaimsService.updateClaim({
          'id': widget.existingClaim!['id'].toString(),
          'title': _titleController.text.trim(),
          'amount': double.parse(_amountController.text.trim()),
          'category': _selectedCategory!,
          'expense_date': _expenseDate!.toIso8601String().split('T')[0],
          'description': _descriptionController.text.trim(),
          'attachments': _attachedFiles.map((f) => f.path).toList(),
        });
      } else {
        await ClaimsService.submitClaim({
          'title': _titleController.text.trim(),
          'amount': double.parse(_amountController.text.trim()),
          'category': _selectedCategory!,
          'expense_date': _expenseDate!.toIso8601String().split('T')[0],
          'description': _descriptionController.text.trim(),
          'attachments': _attachedFiles.map((f) => f.path).toList(),
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingClaim != null 
                ? '✅ Claim updated successfully' 
                : '✅ Claim submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
  
  Future<void> _saveDraft() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a claim title to save as draft')),
      );
      return;
    }
    
    try {
      await ClaimsService.saveDraft({
        'id': widget.existingClaim?['id']?.toString(),
        'title': _titleController.text.trim(),
        'amount': double.tryParse(_amountController.text.trim()),
        'category': _selectedCategory,
        'expense_date': _expenseDate?.toIso8601String().split('T')[0],
        'description': _descriptionController.text.trim(),
        'attachments': _attachedFiles.map((f) => f.path).toList(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Draft saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $e')),
        );
      }
    }
  }
}

// Claim Details Bottom Sheet
class ClaimDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> claim;
  
  const ClaimDetailsBottomSheet({super.key, required this.claim});
  
  @override
  Widget build(BuildContext context) {
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
                    'Claim Details',
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
                  _buildDetailItem(context, 'Title', claim['title']?.toString() ?? ''),
                  _buildDetailItem(context, 'Amount', '\$${double.parse(claim['amount']?.toString() ?? '0').toStringAsFixed(2)}'),
                  _buildDetailItem(context, 'Category', claim['category']?.toString() ?? ''),
                  _buildDetailItem(context, 'Status', claim['status']?.toString() ?? ''),
                  if (claim['expense_date'] != null)
                    _buildDetailItem(context, 'Expense Date', claim['expense_date']?.toString() ?? ''),
                  if (claim['submitted_date'] != null)
                    _buildDetailItem(context, 'Submitted Date', claim['submitted_date']?.toString() ?? ''),
                  if (claim['description'] != null && claim['description'].toString().isNotEmpty)
                    _buildDetailItem(context, 'Description', claim['description']?.toString() ?? ''),
                  if (claim['attachments'] != null && (claim['attachments'] as List).isNotEmpty)
                    _buildAttachmentsSection(context, claim['attachments'] as List),
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

// Category Details Bottom Sheet
class CategoryDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> category;
  
  const CategoryDetailsBottomSheet({super.key, required this.category});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                    'Category Details',
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
                  _buildDetailItem(context, 'Name', category['name']?.toString() ?? ''),
                  if (category['description'] != null)
                    _buildDetailItem(context, 'Description', category['description']?.toString() ?? ''),
                  if (category['max_amount'] != null)
                    _buildDetailItem(context, 'Maximum Amount', '\$${double.parse(category['max_amount']?.toString() ?? '0').toStringAsFixed(2)}'),
                  _buildDetailItem(context, 'Status', (category['is_active'] ?? true) ? 'Active' : 'Inactive'),
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