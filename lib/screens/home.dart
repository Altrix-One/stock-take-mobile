import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart'; // Hive for token management

import 'package:stock_count/components/calculator_card.dart';
import 'package:stock_count/components/center_box.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/utilis/api_service.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/utilis/dialog_messages.dart';
import 'package:stock_count/screens/login.dart'; // Import login screen

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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool showCountTypeButton = true;
  Database? database;
  int currentEntryId = 0;
  bool isCountStarted = false;
  String? selectedWarehouse;
  String? selectedCompany;
  bool isWarehouseSelected = false;
  bool recountEntry = false;
  String? firstName;
  String? lastName;
  String? userEmail;
  String? profilePictureUrl;
  String? accessToken;
  bool isTokenExpired = false; // Variable to track token expiration
  List<Map<String, dynamic>> assignedItems = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = ""; // State to store search input

  // Variables for slide-in dialog
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    checkAuthentication(); // Check authentication before loading HomeScreen
    initializeDb();

    // Initialize Animation Controller for the slide-in dialog
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Slow down the transition
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start off-screen
      end: Offset.zero, // End at screen's center
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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

  // Check if the user is authenticated by verifying the token
  Future<void> checkAuthentication() async {
    var authBox = await Hive.openBox('authBox');
    String? accessToken = authBox.get('accessToken');
    String? tokenExpiryString =
        authBox.get('tokenExpiry'); // Retrieve as String

    DateTime? tokenExpiry;

    // Parse the tokenExpiryString to DateTime if it's not null
    if (tokenExpiryString != null) {
      tokenExpiry = DateTime.parse(tokenExpiryString);
    }

    // If no token or token is expired, redirect to login
    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      // Token is invalid or expired, log out and redirect to login
      logOutUser();
      return;
    }

    // If token is valid, proceed to fetch user details
    fetchUserDetails();
  }

  // Log out user and clear Hive token data
  void logOutUser() async {
    var authBox = await Hive.openBox('authBox');
    await authBox.clear(); // Clear all stored token data

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> fetchUserDetails() async {
    var authBox = await Hive.openBox('authBox');
    String? userDetailsJson = authBox.get('userDetails');
    accessToken = authBox.get('accessToken');

    if (userDetailsJson != null) {
      Map<String, dynamic> userDetails = json.decode(userDetailsJson);

      setState(() {
        firstName = userDetails['given_name'];
        lastName = userDetails['family_name'] ?? "";
        userEmail = userDetails['email'];
        profilePictureUrl = userDetails['picture'];
      });
    } else {
      showErrorDialog(context, "User details are missing.");
    }
  }

  Future<void> initializeDb() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'stock_count.db');

    database = await openDatabase(path, version: 1, onCreate: DBSchema.initDB);
  }

  void startCount() async {
    var authBox = await Hive.openBox('authBox');
    String? userId = authBox.get('userId');

    String postingDate = DateTime.now().toString().substring(0, 10);
    String postingTime = DateTime.now().toString().substring(11);

    int id = await database!.insert('StockCountEntry', {
      'company': selectedCompany,
      'warehouse': selectedWarehouse,
      'posting_date': postingDate,
      'posting_time': postingTime,
      'stock_count_person': userId
    });

    setState(() {
      currentEntryId = id;
    });
  }

  // Toggle the visibility of the slide-in dialog and fetch assigned items if counting is started
  void _toggleDialog() {
    if (_isDialogVisible) {
      _animationController.reverse().then((_) {
        setState(() {
          _isDialogVisible = false;
        });
      });
    } else {
      if (isCountStarted) {
        fetchAssignedItems(); // Fetch assigned items only when opening the dialog in count mode
      }
      setState(() {
        _isDialogVisible = true;
      });
      _animationController.forward();
    }
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
      // Fetch both warehouses and companies from Hive storage
      var authBox = await Hive.openBox('authBox'); // Ensure Hive box is open

      String? warehousesJson = authBox.get('warehouses_by_company');
      String? companiesJson = authBox.get('companies');

      if (warehousesJson != null && companiesJson != null) {
        Map<String, List<String>> warehousesByCompany = {};
        (jsonDecode(warehousesJson) as Map<String, dynamic>)
            .forEach((key, value) {
          warehousesByCompany[key] = List<String>.from(value as List<dynamic>);
        });

        List<String> companies = List<String>.from(jsonDecode(companiesJson));

        if (warehousesByCompany.isNotEmpty) {
          showWarehouseBottomSheet(context, warehousesByCompany, companies);
        }
      } else {
        // Optional: handle the case where no data is found in Hive
        showErrorDialog(
            context, 'No warehouse or company data found in local storage.');
      }
      return;
    } else if (isCountStarted && index == 1) {
      showErrorDialog(context, "Please stop the count first.");
      return;
    } else if (isCountStarted) {
      setState(() {
        isCountStarted = false;
        showCountTypeButton = true;
        _selectedIndex =
            1; // Navigate to "Entries" tab when stop count is pressed
      });
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchAssignedItems() async {
    var authBox = await Hive.openBox('authBox'); // Ensure Hive box is open

    // Fetch assigned items from Hive storage
    String? assignedItemsJson = authBox.get('assigned_items');

    if (assignedItemsJson != null) {
      List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from(jsonDecode(assignedItemsJson));

      setState(() {
        assignedItems = items;
      });
    } else {
      // Optional: handle the case where no assigned items are found in Hive
      showErrorDialog(context, 'No assigned items found in local storage.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
                onPressed: _toggleDialog, // Trigger the slide-in dialog
                icon: Iconify(
                  isCountStarted ? Carbon.list : Carbon.settings,
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
            items: _selectedIndex == 1 && isCountStarted
                ? [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.list_alt), // Change to a list icon
                      label: 'Entries', // Update label to "Entries"
                    ),
                  ]
                : isCountStarted
                    ? [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.stop_circle_outlined),
                          label: 'Stop Count',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.list_alt), // Change to a list icon
                          label: 'Entries', // Update label to "Entries"
                        ),
                      ]
                    : [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons
                              .play_circle_outline), // Use play icon from Icons
                          label: 'Start Count',
                        ),
                        const BottomNavigationBarItem(
                          icon:
                              Icon(Icons.list_alt), // Use list icon from Icons
                          label: 'Entries', // Update label to "Entries"
                        ),
                      ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: greyColor,
            onTap: _onItemTapped,
          ),
        ),
        if (_isDialogVisible) ...[
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap:
                  _toggleDialog, // Close the drawer if you tap on the dimmed area
              child: Container(
                color: Colors.black.withOpacity(0.5), // Dim the background
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.6, // Half-screen width
                  height: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: isCountStarted
                        ? buildAssignedItemsList()
                        : buildSettingsList(),
                  ),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

// Build list of settings items (when not counting)
  List<Widget> buildSettingsList() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Settings', style: semibold16Black33),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _toggleDialog,
          ),
        ],
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout', style: medium14Black33),
        onTap: logOutUser,
      ),
      const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Version 0.0.1', style: medium14Black33),
      ),
      const Spacer(),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Image.asset(
          'assets/images/aakvatech.jpg',
          width: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
    ];
  }

  // Updated buildAssignedItemsList with search functionality
  List<Widget> buildAssignedItemsList() {
    // Filter items based on the search query
    List<Map<String, dynamic>> filteredItems = assignedItems.where((item) {
      String itemName = item['item']?.toLowerCase() ?? '';
      return itemName.contains(searchQuery.toLowerCase());
    }).toList();

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Assigned Items', style: semibold16Black33),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _toggleDialog,
          ),
        ],
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search items...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        searchQuery = "";
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      const Divider(),
      // Wrapping the list in a Flexible widget with ListView
      Flexible(
        child: filteredItems.isNotEmpty
            ? ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  return ListTile(
                    title: Text(item['item'] ?? 'Unnamed Item',
                        style: medium14Black33),
                    onTap: () {
                      // Handle item selection, e.g., show details
                    },
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text(
                      "No items found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
      const Divider(),
    ];
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
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

  void showWarehouseBottomSheet(BuildContext context,
      Map<String, List<String>> warehousesByCompany, List<String> companies) {
    String defaultSelectedCompany =
        companies.isNotEmpty ? companies[0] : 'Select Company';
    List<String> filteredWarehouses =
        warehousesByCompany[defaultSelectedCompany] ?? [];
    bool isCompanyExpanded = false;
    bool isWarehouseExpanded = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Options',
                      style: semibold18Primary, textAlign: TextAlign.center),
                  const SizedBox(height: 16.0),

                  // Accordion for Company Selection
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCompanyExpanded = !isCompanyExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              defaultSelectedCompany,
                              style: medium14Black33,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            isCompanyExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isCompanyExpanded ? companies.length * 50.0 : 0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: companies.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(companies[index], style: medium14Black33),
                          onTap: () {
                            setState(() {
                              defaultSelectedCompany = companies[index];
                              filteredWarehouses =
                                  warehousesByCompany[defaultSelectedCompany] ??
                                      [];
                              isCompanyExpanded = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Accordion for Warehouse List
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isWarehouseExpanded = !isWarehouseExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Warehouses', style: medium14Black33),
                          Icon(
                            isWarehouseExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Limited Height and Scrollable Warehouse List
                  Flexible(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isWarehouseExpanded
                          ? MediaQuery.of(context).size.height * 0.5
                          : 0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredWarehouses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(filteredWarehouses[index],
                                style: medium14Black33),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                selectedWarehouse = filteredWarehouses[index];
                                selectedCompany = defaultSelectedCompany;
                                isCountStarted = true;
                                showCountTypeButton = false;
                              });
                              startCount();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
          color: whiteColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: black3CColor.withOpacity(0.1),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(type, style: semibold16Black33),
            Consumer<StockTakeNotifier>(
              builder: (context, stockTakeNotifier, child) {
                // Only show the icon if the type is the selected count type
                return stockTakeNotifier.countType == type
                    ? const Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      )
                    : const SizedBox(); // Empty space if not the selected type
              },
            ),
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
            if (snapshot.data!.statusCode == 200 &&
                snapshot.data!.headers['content-type']!.startsWith('image/')) {
              return Image.memory(snapshot.data!.bodyBytes);
            } else {
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
    return response;
  }
}
