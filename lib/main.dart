import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/utilis/change_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StockTakeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Taking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        primaryColor: primaryColor,
        fontFamily: 'Montserrat',
      ),
      home: const LoginScreen(),
    );
  }
}
