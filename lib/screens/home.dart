import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:stock_count/components/calculator_card.dart';
import 'package:stock_count/components/center_box.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/utilis/api_service.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/utilis/dialog_messages.dart';
import 'package:iconify_flutter/icons/uil.dart';

class HomeScreen extends StatefulWidget {
  final int? recountEntryId;
  final String? recountWarehouse;
  final String? countType;
  final Database? database;

  const HomeScreen({
    Key? key,
    this.countType,
    this.recountEntryId,
    this.recountWarehouse,
    this.database,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool showCountTypeButton = true;
  Database? database;
  int currentEntryId = 0;
  bool isCountStarted = false;
  String? selectedWarehouse;
  bool isWarehouseSelected = false;
  bool recountEntry = false;
  String? firstName;
  String? lastName;
  String? userEmail;
  String? profilePictureUrl;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    initializeDb();
    fetchUserDetails();
    if (widget.recountEntryId != null &&
        widget.recountWarehouse != null &&
        widget.countType != null) {
      currentEntryId = widget.recountEntryId!;
      selectedWarehouse = widget.recountWarehouse!;
      isCountStarted = true;
      showCountTypeButton = false;
      recountEntry = true;
      database = widget.database;
    }
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsJson = prefs.getString('userDetails');
    accessToken = prefs.getString('accessToken');

    if (userDetailsJson != null) {
      Map<String, dynamic> userDetails = json.decode(userDetailsJson);

      setState(() {
        firstName = userDetails['given_name'];
        lastName = userDetails['family_name'] ?? "";
        userEmail = userDetails['email'];
        profilePictureUrl = userDetails['picture'];
        print('Profile Picture URL: $profilePictureUrl');
      });
    } else {
      print("User details JSON is null.");
      showErrorDialog(context, "User details JSON is null.");
    }
  }

  Future<void> initializeDb() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'stock_count.db');

    database = await openDatabase(path, version: 1, onCreate: DBSchema.initDB);
  }

  void startCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? company = prefs.getString('company');
    String? userId = prefs.getString('userId');

    String postingDate = DateTime.now().toString().substring(0, 10);
    String postingTime = DateTime.now().toString().substring(11);

    int id = await database!.insert('StockCountEntry', {
      'company': company,
      'warehouse': selectedWarehouse,
      'posting_date': postingDate,
      'posting_time': postingTime,
      'stock_count_person': userId
    });

    // Fetching and printing the newly added entry
    List<Map> result = await database!
        .query('StockCountEntry', where: 'id = ?', whereArgs: [id]);
    print("New Stock Count Entry: $result");
    setState(() {
      currentEntryId = id; // Store the new entry ID
    });
  }

  List<Widget> get _pages {
    return isCountStarted
        ? [
            CalculatorCard(
                database: database,
                entryId: currentEntryId,
                warehouse: selectedWarehouse,
                recountEntry: recountEntry),
            CenterBox(database: database)
          ]
        : [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              child: Center(
                child: Text(
                  "Please select the count type Beam or Camera. Then, press the Start Count button to initiate the counting process.",
                  style: medium15Grey,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            CenterBox(database: database),
          ];
  }

  void _onItemTapped(int index) async {
    if (Provider.of<StockTakeNotifier>(context, listen: false).countType ==
            'Count type' &&
        _selectedIndex == 0 &&
        index != 1) {
      showErrorDialog(context, "Please select the Count type first.");
      return;
    }
    if (index == 0 && !isCountStarted && _selectedIndex != 1) {
      List<String> warehouses = await ApiService.getWarehouses(context);
      // print(warehouses);
      if (warehouses.isNotEmpty) {
        showWarehouseDialog(context, warehouses);
      }
      return;
    } else if (isCountStarted && index == 1) {
      showErrorDialog(context, "Please stop the count first.");
      return;
    } else if (isCountStarted) {
      setState(() {
        isCountStarted = false;
        showCountTypeButton = true;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f8Color,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70.0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: primaryColor,
        titleSpacing: 20.0,
        title: headerTitle(),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            onPressed: () {
              // Future functionality for settings or notifications
            },
            icon: const Iconify(
              Carbon.settings,
              color: whiteColor,
              size: 22.0,
            ),
          )
        ],
      ),
      body: Consumer<StockTakeNotifier>(
        builder: (context, stockTakeNotifier, child) {
          return _pages.elementAt(_selectedIndex);
        },
      ),
      floatingActionButton: showCountTypeButton
          ? FloatingActionButton.extended(
              onPressed: () => _showSelectionDialog(context),
              backgroundColor: primaryColor,
              label: Consumer<StockTakeNotifier>(
                builder: (context, stockTakeNotifier, child) {
                  return Text(
                    stockTakeNotifier.countType,
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: isCountStarted
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.stop_circle_outlined),
                  label: 'Stop Count',
                ),
                const BottomNavigationBarItem(
                  icon: Iconify(Uil.refresh),
                  label: 'Re Count',
                ),
              ]
            : [
                const BottomNavigationBarItem(
                  icon: Iconify(Carbon.play_outline),
                  label: 'Start Count',
                ),
                const BottomNavigationBarItem(
                  icon: Iconify(Uil.refresh),
                  label: 'Re Count',
                ),
              ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteColor, // Uses whiteColor from your constants
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Rounded corners for the dialog
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Select Count Type', style: semibold18Primary),
                const SizedBox(height: 20),
                dialogOption('Beam'),
                dialogOption('Camera'),
              ],
            ),
          ),
        );
      },
    );
  }

  void showWarehouseDialog(BuildContext context, List<String> warehouses) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Select Warehouse',
            style: semibold18Primary,
            textAlign: TextAlign.center,
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: warehouses.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(warehouses[index], style: medium14Black33),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      selectedWarehouse = warehouses[index];
                      isCountStarted = true;
                      showCountTypeButton = false;
                    });
                    startCount();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget dialogOption(String type) {
    return InkWell(
      onTap: () {
        context.read<StockTakeNotifier>().setCountType(type);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: whiteColor, // Ensures each option is also white
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: black3CColor.withOpacity(
                  0.1), // Subtle shadow with a slightly defined color
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(type, style: semibold16Black33),
            const Icon(Icons.check_circle_outline, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget headerTitle() {
    return Row(
      children: [
        CircleAvatar(
          maxRadius: 25,
          backgroundColor: Colors.white,
          child: profilePictureUrl != null && accessToken != null
              ? ImageWithBearerToken(
                  imageUrl: profilePictureUrl!,
                  bearerToken: accessToken!,
                )
              : Text(
                  firstName != null ? firstName![0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: primaryColor,
                  ),
                ),
        ),
        widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    firstName ?? "",
                    style: semibold16White,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    lastName ?? "",
                    style: semibold16White,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              heightBox(2.0),
              Row(
                children: [
                  const Iconify(
                    Carbon.email,
                    color: whiteColor,
                    size: 14.0,
                  ),
                  width5Space,
                  Expanded(
                    child: Text(
                      userEmail ?? "",
                      style: medium14White,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  var timerBoxDecoration = BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(5.0),
    boxShadow: [
      BoxShadow(
        color: blackColor.withOpacity(0.2),
        blurRadius: 6.0,
      )
    ],
  );
}

class ImageWithBearerToken extends StatelessWidget {
  final String imageUrl;
  final String bearerToken;

  const ImageWithBearerToken({
    required this.imageUrl,
    required this.bearerToken,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: _fetchImage(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading image'));
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Check the status code and content type
            if (snapshot.data!.statusCode == 200 &&
                snapshot.data!.headers['content-type']!.startsWith('image/')) {
              return Image.memory(snapshot.data!.bodyBytes);
            } else {
              // Print debug information
              print('Invalid image data or unauthorized.');
              print('Status Code: ${snapshot.data!.statusCode}');
              print('Content-Type: ${snapshot.data!.headers['content-type']}');
              print(
                  'Response Body: ${snapshot.data!.bodyBytes.length > 100 ? snapshot.data!.bodyBytes.sublist(0, 100) : snapshot.data!.bodyBytes}');

              return Center(child: Text('Invalid image data or unauthorized.'));
            }
          } else {
            return Center(child: Text('No data received.'));
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<http.Response> _fetchImage() async {
    final headers = {'Authorization': 'Bearer $bearerToken'};
    final response = await http.get(Uri.parse(imageUrl), headers: headers);
    print('Bearer Token: $bearerToken');
    print('Response URL: $imageUrl');
    print(response.body);
    return response;
  }
}
