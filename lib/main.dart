import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/app_theme_unified.dart';
import 'package:stock_count/widgets/universal_scaffold.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/screens/setup_dialog.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

// Initialize periodic HR sync tasks
Timer? _syncTimer;

void startPeriodicHRSync() {
  // Cancel any existing timer
  _syncTimer?.cancel();

  // Create a new timer that runs every 15 minutes
  _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
    print("Starting periodic sync at ${DateTime.now()}");

    // HR-focused sync - only process the Outbox queue for offline operations (leaves, claims, attendance)
    try {
      await OutboxQueue.processQueue();
      print("HR sync completed at ${DateTime.now()}");
    } catch (e) {
      print("Error during HR sync: $e");
    }
  });

  print("Periodic HR sync scheduled every 15 minutes");
}

// Initialize Hive for background tasks
Future<void> initializeHiveForBackgroundTasks() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('authBox');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // Start periodic sync tasks if not on web
  if (!kIsWeb) {
    try {
      startPeriodicHRSync();
      print("Periodic HR sync initialized successfully");
    } catch (e) {
      print("Failed to initialize periodic sync: $e");
    }
  } else {
    print("Periodic sync not supported on web platform");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isConfigured = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    try {
      final isConfigured = await AppConfig.isConfigured;
      if (mounted) {
        setState(() {
          _isConfigured = isConfigured;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking configuration: $e");
      if (mounted) {
        setState(() {
          _isConfigured = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cohenix ESS',
      theme: AppThemeUnified.lightTheme,
      darkTheme: AppThemeUnified.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const UniversalScaffold(
              body: UniversalLoading(
                message: 'Loading...',
              ),
            )
          : _isConfigured
              ? const LoginScreen()
              : Builder(
                  builder: (context) {
                    // Show setup dialog on first launch
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const SetupDialog(isFirstLaunch: true);
                        },
                      ).then((configured) {
                        if (configured == true) {
                          setState(() {
                            _isConfigured = true;
                          });
                        }
                      });
                    });

                    // Return a loading screen while dialog is being shown
                    return const UniversalScaffold(
                      body: UniversalLoading(
                        message: 'Setting up the app...',
                      ),
                    );
                  },
                ),
    );
  }
}

// Old callback functions have been removed
