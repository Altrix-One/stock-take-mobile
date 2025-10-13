import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/constants/app_theme.dart';
import 'package:stock_count/constants/cohenix_colors.dart';
import 'package:stock_count/constants/cohenix_typography.dart';
import 'package:stock_count/constants/cohenix_spacing.dart';
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
    final brightness = Theme.of(context).brightness;
    
    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: CohenixColors.getBackgroundColor(brightness),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: brightness == Brightness.dark 
                ? Brightness.light 
                : Brightness.dark,
            ),
            actions: [
              // Settings button with Cohenix styling
              Container(
                margin: const EdgeInsets.only(right: CohenixSpacing.md),
                decoration: BoxDecoration(
                  color: CohenixColors.getOutlineColor(brightness).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CohenixSpacing.radiusSM),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: CohenixColors.getOnSurfaceColor(brightness),
                  ),
                  onPressed: () => _showSettingsDialog(context),
                  tooltip: 'App Settings',
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: CohenixSpacing.pagePadding,
                child: Column(
                  children: [
                    CohenixSpacing.verticalSpaceXL,
                    
                    // Hero Section with Logo and Brand
                    _buildHeroSection(context, brightness),
                    
                    CohenixSpacing.verticalSpaceXXL,
                    
                    // Features Animation
                    _buildFeaturesSection(context, brightness),
                    
                    CohenixSpacing.verticalSpaceXXL,
                    
                    // Call to Action
                    _buildCallToActionSection(context, brightness),
                    
                    CohenixSpacing.verticalSpaceXL,
                    
                    // Login Button
                    _buildLoginButton(context),
                    
                    CohenixSpacing.verticalSpaceLG,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hero Section with Cohenix branding
  Widget _buildHeroSection(BuildContext context, Brightness brightness) {
    return Column(
      children: [
        // Company Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CohenixSpacing.radiusLG),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CohenixSpacing.radiusLG),
            child: Image.asset(
              'assets/images/cohenixess.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CohenixColors.royalBlue,
                        CohenixColors.oceanBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(CohenixSpacing.radiusLG),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ),
        
        CohenixSpacing.verticalSpaceLG,
        
        // Brand Name with Cohenix Typography
        Text(
          "Cohenix ESS",
          style: CohenixTypography.withPrimaryColor(
            CohenixTypography.displayMedium,
            brightness,
          ),
          textAlign: TextAlign.center,
        ),
        
        CohenixSpacing.verticalSpaceSM,
        
      ],
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
        accent: accentColor,
        mode: LeaveHeroMode.calendar,
        showLabels: false,
      ),
    );
  }
  
  // Call to Action Section
  Widget _buildCallToActionSection(BuildContext context, Brightness brightness) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          Text(
            "Manage your team with ease through real-time data, automation, and effortless integration. Cohenix ESS makes HR simple.",
            style: CohenixTypography.withSecondaryColor(
              CohenixTypography.bodyLarge,
              brightness,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Professional Login Button with Cohenix styling
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoggingIn ? null : () async {
          setState(() {
            _isLoggingIn = true;
          });
          await ApiService.loginWithFrappe(context);
          setState(() {
            _isLoggingIn = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: CohenixSpacing.elevationMD,
          shadowColor: accentColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CohenixSpacing.radiusMD),
          ),
          padding: CohenixSpacing.buttonPaddingLarge,
          minimumSize: const Size(double.infinity, 56),
        ),
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
                  CohenixSpacing.horizontalSpaceSM,
                  Text(
                    "LOGIN",
                    style: CohenixTypography.withWhite(
                      CohenixTypography.buttonLarge,
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
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: semibold15White,
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}

