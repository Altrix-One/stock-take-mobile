import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart'; // Use android_alarm_manager_plus
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:stock_count/utilis/sync_manager.dart'; // Import sync manager
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive for token management
import 'dart:isolate';
import 'dart:ui';
import 'package:path_provider/path_provider.dart'; // For background isolate

const int fetchDataTaskId = 0;
const int postDataTaskId = 1;
// const int tokenRefreshTaskId = 2; // Task ID for token refresh
const String isolateName = 'sync_isolate';

// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('authBox'); // Box to store tokens

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  // Register the UI isolate's SendPort to allow for communication from the background isolate.
  IsolateNameServer.registerPortWithName(port.sendPort, isolateName);

  // Start periodic tasks for syncing data
  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    fetchDataTaskId,
    fetchTaskCallback,
    wakeup: true,
    exact: true,
  );

  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    postDataTaskId,
    postTaskCallback,
    wakeup: true,
    exact: true,
  );

  // Start token refresh task every 30 minutes (adjust timing as needed)
  // await AndroidAlarmManager.periodic(
  //   const Duration(minutes: 30),
  //   tokenRefreshTaskId,
  //   tokenRefreshCallback,
  //   wakeup: true,
  //   exact: true,
  // );

  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => StockTakeNotifier(),
      child: const MyApp(),
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
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

// Callback function for fetching data
@pragma('vm:entry-point')
void fetchTaskCallback() async {
  final DateTime now = DateTime.now();
  print("[$now] Fetch task started");

  await initializeHiveForBackgroundTasks(); // Initialize Hive for background tasks
  await SyncManager.syncFromServer();

  print("[$now] Fetch task completed");
}

// Callback function for posting data
@pragma('vm:entry-point')
void postTaskCallback() async {
  final DateTime now = DateTime.now();
  print("[$now] Post task started");

  await initializeHiveForBackgroundTasks(); // Initialize Hive for background tasks
  await SyncManager.syncToServer();

  print("[$now] Post task completed");
}

// Callback function for refreshing the token
// @pragma('vm:entry-point')
// void tokenRefreshCallback() async {
//   final DateTime now = DateTime.now();
//   print("[$now] Token refresh task started");

//   await initializeHiveForBackgroundTasks(); // Initialize Hive for background tasks
//   await SyncManager.refreshTokenIfNeeded();

//   print("[$now] Token refresh task completed");
// }

// Function to initialize Hive for background tasks
Future<void> initializeHiveForBackgroundTasks() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path); // Initialize Hive with directory path

  if (!Hive.isBoxOpen('authBox')) {
    await Hive.openBox('authBox');
  }
}
