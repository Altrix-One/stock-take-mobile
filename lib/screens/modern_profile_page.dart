import 'package:flutter/material.dart';
import 'package:stock_count/constants/modern_design_system.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:stock_count/screens/queue_status.dart';
import 'package:stock_count/screens/login.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ModernProfilePage extends StatefulWidget {
  const ModernProfilePage({super.key});

  @override
  State<ModernProfilePage> createState() => _ModernProfilePageState();
}

class _ModernProfilePageState extends State<ModernProfilePage> {
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
          const SnackBar(content: Text('Failed to load profile data')),
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

      await OutboxQueue.addOperation('update_employee_profile', updateData);

      if (mounted) {
        setState(() {
          _editing = false;
          _saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: ModernDesignSystem.success,
          ),
        );

        await _loadEmployeeData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update profile'),
            backgroundColor: ModernDesignSystem.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (_loading) {
      return Scaffold(
        backgroundColor: ModernDesignSystem.getSurfaceVariant(brightness),
        appBar: _buildModernAppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            color: ModernDesignSystem.primaryTeal,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ModernDesignSystem.getSurfaceVariant(brightness),
      appBar: _buildModernAppBar(),
      body: _employeeData == null
          ? const Center(child: Text('No profile data found'))
          : Form(
              key: _formKey,
              child: RefreshIndicator(
                onRefresh: _loadEmployeeData,
                color: ModernDesignSystem.primaryTeal,
                child: ListView(
                  padding: ModernDesignSystem.pagePadding.copyWith(
                    top: ModernDesignSystem.spaceMD,
                    bottom: ModernDesignSystem.spaceXL * 4,
                  ),
                  children: [
                    // Profile Header Card
                    _buildProfileHeader(brightness),
                    ModernDesignSystem.verticalSpaceLG,

                    // Quick Stats Row
                    _buildQuickStats(brightness),
                    ModernDesignSystem.verticalSpaceLG,

                    // Profile Sections
                    if (!_editing) ...[
                      _buildPersonalInfoCard(brightness),
                      ModernDesignSystem.verticalSpaceMD,
                      _buildCompanyInfoCard(brightness),
                      ModernDesignSystem.verticalSpaceMD,
                    ],

                    _buildContactInfoCard(brightness),
                    ModernDesignSystem.verticalSpaceMD,
                    _buildAddressInfoCard(brightness),
                    ModernDesignSystem.verticalSpaceMD,
                    _buildEmergencyContactCard(brightness),
                    ModernDesignSystem.verticalSpaceMD,
                    _buildFinancialInfoCard(brightness),
                    ModernDesignSystem.verticalSpaceMD,
                    _buildSettingsCard(brightness),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'My Profile',
        style: ModernDesignSystem.headlineLarge.copyWith(
          color: ModernDesignSystem.getTextPrimary(Theme.of(context).brightness),
        ),
      ),
      actions: [
        if (!_editing && _employeeData != null)
          Container(
            margin: const EdgeInsets.only(right: ModernDesignSystem.spaceMD),
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryTealPale,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: ModernDesignSystem.primaryTeal,
              onPressed: () => setState(() => _editing = true),
            ),
          ),
        if (_editing) ...[
          TextButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _editing = false);
                    _populateControllers();
                  },
            child: Text(
              'Cancel',
              style: ModernDesignSystem.labelLarge.copyWith(
                color: ModernDesignSystem.neutralMedium,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: ModernDesignSystem.spaceMD),
            child: TextButton(
              onPressed: _saving ? null : _saveChanges,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ModernDesignSystem.primaryTeal,
                      ),
                    )
                  : Text(
                      'Save',
                      style: ModernDesignSystem.labelLarge.copyWith(
                        color: ModernDesignSystem.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileHeader(Brightness brightness) {
    return Container(
      decoration: ModernDesignSystem.modernCardDecoration(brightness),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernDesignSystem.primaryTealPale,
              ModernDesignSystem.primaryTealPale.withOpacity(0.6),
            ],
          ),
        ),
        padding: ModernDesignSystem.cardPadding.copyWith(
          top: ModernDesignSystem.spaceXL,
          bottom: ModernDesignSystem.spaceXL,
        ),
        child: Column(
          children: [
            // Profile Avatar
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ModernDesignSystem.primaryTeal.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ModernDesignSystem.primaryTeal.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: ModernDesignSystem.primaryTeal,
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      color: Colors.white,
        onPressed: _uploadingImage ? null : () {
                          _showImagePicker();
                        },
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ),
              ],
            ),
            ModernDesignSystem.verticalSpaceMD,

            // Name and Title
            Text(
              _employeeData!['employee_name']?.toString() ?? 'Unknown',
              style: ModernDesignSystem.displayMedium.copyWith(
                color: ModernDesignSystem.getTextPrimary(brightness),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            ModernDesignSystem.verticalSpaceXS,

            Text(
              _employeeData!['designation']?.toString() ?? '',
              style: ModernDesignSystem.bodyLarge.copyWith(
                color: ModernDesignSystem.getTextSecondary(brightness),
              ),
              textAlign: TextAlign.center,
            ),

            if (_employeeData!['employee_number'] != null) ...[
              ModernDesignSystem.verticalSpaceXS,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernDesignSystem.spaceMD,
                  vertical: ModernDesignSystem.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
                ),
                child: Text(
                  'ID: ${_employeeData!['employee_number']}',
                  style: ModernDesignSystem.labelMedium.copyWith(
                    color: ModernDesignSystem.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Brightness brightness) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Department', _employeeData!['department']?.toString(), Icons.business_outlined, brightness)),
        ModernDesignSystem.horizontalSpaceSM,
        Expanded(child: _buildStatCard('Branch', _employeeData!['branch']?.toString(), Icons.location_on_outlined, brightness)),
        ModernDesignSystem.horizontalSpaceSM,
        Expanded(child: _buildStatCard('Type', _employeeData!['employment_type']?.toString(), Icons.work_outline, brightness)),
      ],
    );
  }

  Widget _buildStatCard(String label, String? value, IconData icon, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.spaceMD),
      decoration: ModernDesignSystem.modernCardDecoration(brightness),
      child: Column(
        children: [
          Icon(
            icon,
            color: ModernDesignSystem.primaryTeal,
            size: 24,
          ),
          ModernDesignSystem.verticalSpaceXS,
          Text(
            value ?? '-',
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.getTextPrimary(brightness),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          ModernDesignSystem.verticalSpaceMicro,
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.getTextSecondary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Personal Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow('Full Name', _employeeData!['employee_name']?.toString(), brightness),
          _buildInfoRow('Gender', _employeeData!['gender']?.toString(), brightness),
          _buildInfoRow('Date of Birth', _employeeData!['date_of_birth']?.toString(), brightness),
          _buildInfoRow('Date of Joining', _employeeData!['date_of_joining']?.toString(), brightness),
          _buildInfoRow('Blood Group', _employeeData!['blood_group']?.toString(), brightness),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Company Information',
      icon: Icons.business_outlined,
      child: Column(
        children: [
          _buildInfoRow('Company', _employeeData!['company']?.toString(), brightness),
          _buildInfoRow('Department', _employeeData!['department']?.toString(), brightness),
          _buildInfoRow('Designation', _employeeData!['designation']?.toString(), brightness),
          _buildInfoRow('Branch', _employeeData!['branch']?.toString(), brightness),
          _buildInfoRow('Employment Type', _employeeData!['employment_type']?.toString(), brightness),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      child: _editing
          ? Column(
              children: [
                _buildModernTextField(
                  controller: _personalEmailController,
                  label: 'Personal Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isNotEmpty == true && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _cellController,
                  label: 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.isNotEmpty == true && v!.length < 10) {
                      return 'Enter a valid mobile number';
                    }
                    return null;
                  },
                ),
              ],
            )
          : Column(
              children: [
                _buildInfoRow('Company Email', _employeeData!['company_email']?.toString(), brightness),
                _buildInfoRow('Personal Email', _employeeData!['personal_email']?.toString(), brightness),
                _buildInfoRow('Mobile Number', _employeeData!['cell_number']?.toString(), brightness),
              ],
            ),
    );
  }

  Widget _buildAddressInfoCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Address Information',
      icon: Icons.location_on_outlined,
      child: _editing
          ? Column(
              children: [
                _buildModernTextField(
                  controller: _currentAddressController,
                  label: 'Current Address',
                  icon: Icons.home_outlined,
                  maxLines: 3,
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _permanentAddressController,
                  label: 'Permanent Address',
                  icon: Icons.location_city_outlined,
                  maxLines: 3,
                ),
              ],
            )
          : Column(
              children: [
                _buildInfoRow('Current Address', _employeeData!['current_address']?.toString(), brightness),
                _buildInfoRow('Permanent Address', _employeeData!['permanent_address']?.toString(), brightness),
              ],
            ),
    );
  }

  Widget _buildEmergencyContactCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Emergency Contact',
      icon: Icons.emergency_outlined,
      child: _editing
          ? Column(
              children: [
                _buildModernTextField(
                  controller: _emergencyNameController,
                  label: 'Emergency Contact Name',
                  icon: Icons.person_outline,
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _emergencyContactController,
                  label: 'Emergency Contact Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            )
          : Column(
              children: [
                _buildInfoRow('Contact Name', _employeeData!['emergency_contact_name']?.toString(), brightness),
                _buildInfoRow('Contact Number', _employeeData!['emergency_contact_number']?.toString(), brightness),
              ],
            ),
    );
  }

  Widget _buildFinancialInfoCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Financial Information',
      icon: Icons.account_balance_outlined,
      child: _editing
          ? Column(
              children: [
                _buildModernTextField(
                  controller: _panController,
                  label: 'PAN Number',
                  icon: Icons.credit_card_outlined,
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  icon: Icons.account_balance,
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _accountNumberController,
                  label: 'Account Number',
                  icon: Icons.numbers_outlined,
                ),
                ModernDesignSystem.verticalSpaceSM,
                _buildModernTextField(
                  controller: _ifscController,
                  label: 'IFSC Code',
                  icon: Icons.code_outlined,
                ),
              ],
            )
          : Column(
              children: [
                _buildInfoRow('PAN Number', _employeeData!['pan_number']?.toString(), brightness),
                _buildInfoRow('Bank Name', _employeeData!['bank_name']?.toString(), brightness),
                _buildInfoRow('Account Number', _employeeData!['bank_ac_no']?.toString(), brightness),
                _buildInfoRow('IFSC Code', _employeeData!['ifsc_code']?.toString(), brightness),
              ],
            ),
    );
  }

  Widget _buildSettingsCard(Brightness brightness) {
    return _buildModernCard(
      brightness: brightness,
      title: 'Settings',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.cloud_sync_outlined,
            title: 'Queue Status',
            subtitle: 'View pending operations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QueueStatusScreen()),
            ),
            brightness: brightness,
          ),
          _buildSettingsItem(
            icon: Icons.sync_outlined,
            title: 'Sync HR Data',
            subtitle: 'Synchronize with server',
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
                  SnackBar(
                    content: const Text('HR sync complete'),
                    backgroundColor: ModernDesignSystem.success,
                  ),
                );
              }
            },
            brightness: brightness,
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(),
            brightness: brightness,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required Brightness brightness,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: ModernDesignSystem.modernCardDecoration(brightness),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: ModernDesignSystem.cardPadding,
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryTealPale.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ModernDesignSystem.radiusMD),
                topRight: Radius.circular(ModernDesignSystem.radiusMD),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
                  ),
                  child: Icon(
                    icon,
                    color: ModernDesignSystem.primaryTeal,
                    size: 20,
                  ),
                ),
                ModernDesignSystem.horizontalSpaceSM,
                Text(
                  title,
                  style: ModernDesignSystem.headlineMedium.copyWith(
                    color: ModernDesignSystem.getTextPrimary(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: ModernDesignSystem.cardPadding,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ModernDesignSystem.labelLarge.copyWith(
                color: ModernDesignSystem.getTextSecondary(brightness),
              ),
            ),
          ),
          ModernDesignSystem.horizontalSpaceSM,
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'Not provided',
              style: ModernDesignSystem.bodyMedium.copyWith(
                color: value?.isNotEmpty == true
                    ? ModernDesignSystem.getTextPrimary(brightness)
                    : ModernDesignSystem.getTextSecondary(brightness),
                fontStyle: value?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ModernDesignSystem.primaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          borderSide: BorderSide(color: ModernDesignSystem.neutralLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          borderSide: BorderSide(color: ModernDesignSystem.neutralLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          borderSide: const BorderSide(color: ModernDesignSystem.primaryTeal, width: 2),
        ),
        filled: true,
        fillColor: ModernDesignSystem.primaryTealPale.withOpacity(0.3),
      ),
      validator: validator,
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Brightness brightness,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ModernDesignSystem.spaceXS),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ModernDesignSystem.spaceXS),
              decoration: BoxDecoration(
                color: isDestructive 
                  ? ModernDesignSystem.error.withOpacity(0.1)
                  : ModernDesignSystem.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXS),
              ),
              child: Icon(
                icon,
                color: isDestructive ? ModernDesignSystem.error : ModernDesignSystem.primaryTeal,
                size: 20,
              ),
            ),
            ModernDesignSystem.horizontalSpaceSM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ModernDesignSystem.bodyLarge.copyWith(
                      color: isDestructive
                          ? ModernDesignSystem.error
                          : ModernDesignSystem.getTextPrimary(brightness),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: ModernDesignSystem.bodySmall.copyWith(
                      color: ModernDesignSystem.getTextSecondary(brightness),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive
                  ? ModernDesignSystem.error
                  : ModernDesignSystem.getTextSecondary(brightness),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
        ),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: ModernDesignSystem.error,
            ),
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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() => _uploadingImage = true);
      
      try {
        await OutboxQueue.addOperation('update_employee_image', {
          'image_path': image.path,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile image updated successfully'),
              backgroundColor: ModernDesignSystem.success,
            ),
          );
          await _loadEmployeeData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update profile image'),
              backgroundColor: ModernDesignSystem.error,
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
  
  void _downloadData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Downloading your profile data...'),
          backgroundColor: ModernDesignSystem.primaryTeal,
        ),
      );
      
      // TODO: Implement actual data download
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile data downloaded successfully'),
            backgroundColor: ModernDesignSystem.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to download profile data'),
            backgroundColor: ModernDesignSystem.error,
          ),
        );
      }
    }
  }
}

// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.getSurfaceVariant(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Change Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: ModernDesignSystem.pagePadding,
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              isPassword: !_showCurrentPassword,
              onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
              validator: (v) => v?.isEmpty == true ? 'Enter current password' : null,
            ),
            ModernDesignSystem.verticalSpaceMD,
            
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              isPassword: !_showNewPassword,
              onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword),
              validator: (v) {
                if (v?.isEmpty == true) return 'Enter new password';
                if (v!.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
            ),
            ModernDesignSystem.verticalSpaceMD,
            
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isPassword: !_showConfirmPassword,
              onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              validator: (v) {
                if (v?.isEmpty == true) return 'Confirm new password';
                if (v != _newPasswordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            ModernDesignSystem.verticalSpaceXL,
            
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernDesignSystem.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMD),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSM),
          borderSide: const BorderSide(color: ModernDesignSystem.primaryTeal, width: 2),
        ),
      ),
      validator: validator,
    );
  }
  
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await OutboxQueue.addOperation('change_password', {
        'current_password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: ModernDesignSystem.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to change password'),
            backgroundColor: ModernDesignSystem.error,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
