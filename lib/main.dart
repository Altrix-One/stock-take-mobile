import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart'; // Use android_alarm_manager_plus
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:stock_count/utilis/sync_manager.dart'; // Import sync manager
import 'dart:isolate';
import 'dart:ui';

const int fetchDataTaskId = 0;
const int postDataTaskId = 1;
const String isolateName = 'sync_isolate';

// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const LoginScreen(),
    );
  }
}

// Callback function for fetching data
@pragma('vm:entry-point')
void fetchTaskCallback() async {
  final DateTime now = DateTime.now();
  print("[$now] Fetch task started");
  await SyncManager.syncFromServer();
  print("[$now] Fetch task completed");
}

// Callback function for posting data
@pragma('vm:entry-point')
void postTaskCallback() async {
  final DateTime now = DateTime.now();
  print("[$now] Post task started");
  await SyncManager.syncToServer();
  print("[$now] Post task completed");
}
