import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/login.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:stock_count/utilis/sync_manager.dart'; // Import sync manager
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';

const int fetchDataTaskId = 0;
const int postDataTaskId = 1;
const String isolateName = 'sync_isolate';

final ReceivePort port = ReceivePort();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');

  await AndroidAlarmManager.initialize();

  IsolateNameServer.registerPortWithName(port.sendPort, isolateName);

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

  await initializeHiveForBackgroundTasks();

  // Fetch and store warehouses, companies, and assigned items
  await SyncManager.fetchAndStoreWarehousesAndCompanies();
  await SyncManager.fetchAndStoreAssignedItems();
  await SyncManager.syncFromServer();

  print("[$now] Fetch task completed");
}

// Callback function for posting data
@pragma('vm:entry-point')
void postTaskCallback() async {
  final DateTime now = DateTime.now();
  print("[$now] Post task started");

  await initializeHiveForBackgroundTasks();
  await SyncManager.syncToServer();

  print("[$now] Post task completed");
}

// Function to initialize Hive for background tasks
Future<void> initializeHiveForBackgroundTasks() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  if (!Hive.isBoxOpen('authBox')) {
    await Hive.openBox('authBox');
  }
}
