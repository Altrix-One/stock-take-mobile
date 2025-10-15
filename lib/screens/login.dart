import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/app_theme_unified.dart';
import 'package:stock_count/widgets/universal_scaffold.dart';
import 'package:stock_count/screens/setup_dialog.dart';
import 'package:stock_count/utilis/api_service.dart';
import 'package:stock_count/hr/widgets/leave_hero_animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backPressTime;
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
        return false;
      },
      child: UniversalScaffold(
        appBar: UniversalAppBar(
          title: '',
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => _showSettingsDialog(context),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppThemeUnified.textPrimary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppThemeUnified.glassLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemeUnified.radiusSM),
                ),
              ),
              tooltip: 'App Settings',
            ),
            const SizedBox(width: AppThemeUnified.spaceMD),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeUnified.spaceLG,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppThemeUnified.spaceMD),

                  // Logo at top center
                  _buildCenteredLogo(),

                  const SizedBox(height: AppThemeUnified.spaceLG),

                  // App Name
                  _buildAppName(),

                  const SizedBox(height: AppThemeUnified.space2XL),

                  // Features Animation
                  _buildFeaturesSection(context, Theme.of(context).brightness),

                  const SizedBox(height: AppThemeUnified.space2XL),

                  // Description
                  _buildCallToActionSection(
                      context, Theme.of(context).brightness),

                  const SizedBox(height: AppThemeUnified.space2XL),

                  // Login Button
                  _buildLoginButton(context),

                  const SizedBox(height: AppThemeUnified.spaceLG),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Centered Logo at top
  Widget _buildCenteredLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppThemeUnified.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppThemeUnified.primaryRoyalBlue.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppThemeUnified.radiusLG),
        child: Image.asset(
          'assets/images/cohenixess.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeUnified.primaryRoyalBlue,
                    AppThemeUnified.secondaryOceanBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppThemeUnified.radiusLG),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Colors.white,
                size: 56,
              ),
            );
          },
        ),
      ),
    );
  }

  // App Name Section
  Widget _buildAppName() {
    return Text(
      "Cohenix ESS",
      style: AppThemeUnified.displayMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Features Section with Animation
  Widget _buildFeaturesSection(BuildContext context, Brightness brightness) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: LeaveHeroAnimation(
        allocated: 20,
        used: 7.5,
        tiles: 16,
        columns: 4,
        accent: AppThemeUnified.primaryRoyalBlue,
        mode: LeaveHeroMode.calendar,
        showLabels: false,
      ),
    );
  }

  // Call to Action Section
  Widget _buildCallToActionSection(
      BuildContext context, Brightness brightness) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          Text(
            "Manage your team with ease through real-time data, automation, and effortless integration. Cohenix ESS makes HR simple.",
            style: AppThemeUnified.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Professional Login Button with Liquid styling
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoggingIn
            ? null
            : () async {
                setState(() {
                  _isLoggingIn = true;
                });
                await ApiService.loginWithFrappe(context);
                setState(() {
                  _isLoggingIn = false;
                });
              },
        child: _isLoggingIn
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.login_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "LOGIN",
                    style: AppThemeUnified.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Show settings dialog
  Future<void> _showSettingsDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const SetupDialog(isFirstLaunch: false);
      },
    );

    // If configuration was updated successfully, refresh the app state
    if (result == true) {
      setState(() {});
    }
  }

  // Custom back button handler: double-tap to exit
  bool onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) > const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
          content: const Text(
            "Press back once again to exit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
