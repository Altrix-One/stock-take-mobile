import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/home.dart';
import 'package:stock_count/utilis/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backPressTime;
  bool _isLoggingIn = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
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
              // headerImage(size),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    height200Space,
                    heroText(),
                    heightSpace,
                    welcomeText(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    emailField(),
                    heightSpace,
                    heightSpace,
                    passwordField(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    forgotText(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    loginButton(context),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    supportText()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  loginButton(contex) {
    return InkWell(
      onTap: _isLoggingIn
          ? null
          : () async {
              // Disable onTap if already logging in
              setState(() {
                _isLoggingIn = true; 
              });
              await ApiService.login(
                  context, _emailController.text, _passwordController.text);
              if (mounted) {
                setState(() {
                  _isLoggingIn = false; 
                });
              }
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
            ? SizedBox(
                width: 20, // Width of the CircularProgressIndicator
                height: 21, // Height of the CircularProgressIndicator
                child: CircularProgressIndicator(
                  strokeWidth: 2, // Reduces the stroke width to make it thinner
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white), // Spinner color
                ),
              )
            : const Text(
                "Login",
                style: bold18White,
              ),
      ),
    );
  }

  emailField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        controller: _emailController,
        cursorColor: primaryColor,
        style: semibold15Black33,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your email",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.envelope,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your password",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.padlock,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "A Revolutionary Stock Management App Integrated with ERPNext",
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  forgotText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: InkWell(
        onTap: () {
          // pleaseWaitDialog(context);
        },
        child: const Text(
          "Forgot passowrd?",
          style: medium15Grey,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  heroText() {
    return const Text(
      "STOCK TAKE",
      style: semibold20Black33,
      textAlign: TextAlign.center,
    );
  }

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

  supportText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: InkWell(
        onTap: () {
          // Navigator.pushNamed(context, '/otp');
        },
        child: const Text(
          "Need Support? Click here.",
          style: medium15Grey,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
