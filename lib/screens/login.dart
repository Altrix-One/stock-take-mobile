import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/utilis/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backPressTime;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop(); // Call your existing onWillPop function
        if (backStatus) {
          exit(0);
        }
        return false; // Prevent default back behavior
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    headerImage(size),
                    SizedBox(height: size.height * 0.02), // Dynamic height
                    heroText(),
                    SizedBox(height: size.height * 0.015), // Dynamic height
                    welcomeText(),
                    SizedBox(height: size.height * 0.02), // Dynamic height
                    extraDescription(),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: fixPadding * 2.0,
                          vertical: size.height * 0.02),
                      child: loginButtonWithFrape(context, "Get Started"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header Image with Lottie animation
  headerImage(Size size) {
    return Container(
      padding: const EdgeInsets.only(top: fixPadding * 1.5),
      width: double.maxFinite,
      height: size.height * 0.4,
      color: primaryColor,
      alignment: Alignment.center,
      child: Lottie.asset('assets/lottie_assets/2.json'),
    );
  }

  // Get Started Button with loader control
  loginButtonWithFrape(BuildContext context, String buttonName) {
    return InkWell(
      onTap: _isLoggingIn
          ? null
          : () async {
              setState(() {
                _isLoggingIn = true;
              });
              // Call the login method and wait for completion
              await ApiService.loginWithFrappe(context);
              // Once done, set the state to stop showing the loader
              setState(() {
                _isLoggingIn = false;
              });
            },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isLoggingIn
            ? const SizedBox(
                width: 20, // Width of the CircularProgressIndicator
                height: 21, // Height of the CircularProgressIndicator
                child: CircularProgressIndicator(
                  strokeWidth: 2, // Reduces the stroke width to make it thinner
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white), // Spinner color
                ),
              )
            : Text(
                buttonName,
                style: bold18White,
              ),
      ),
    );
  }

  // Description Text
  welcomeText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Streamline your stock management with real-time data integration and easy ERPNext connectivity. Simplifying your stock-taking process for higher efficiency.",
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Additional Descriptive Text to fill space
  extraDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Track your inventory with precision, reduce human error, and improve productivity. This app offers intuitive navigation and seamless integration with your existing workflows.",
        style: medium14Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Hero Title "STOCK TAKE"
  heroText() {
    return const Text(
      "STOCK TAKE",
      style: semibold20Black33,
      textAlign: TextAlign.center,
    );
  }

  // Handle back button press
  onWillPop() {
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
