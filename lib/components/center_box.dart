import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/screens/entry_detail_screen.dart';
import 'package:stock_count/screens/home.dart';
import 'package:stock_count/utilis/dialog_messages.dart';
import 'package:provider/provider.dart';
import 'package:stock_count/utilis/change_notifier.dart';

class CenterBox extends StatefulWidget {
  final Database? database;

  const CenterBox({Key? key, required this.database}) : super(key: key);

  @override
  _CenterBoxState createState() => _CenterBoxState();
}

class _CenterBoxState extends State<CenterBox> {
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    if (widget.database != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDetailsJson = prefs.getString('userDetails');
        if (userDetailsJson != null) {
          String? stockCountPersonId = prefs.getString('userId');

          String query = '''
        SELECT 
          s.id, 
          s.warehouse, 
          s.posting_date, 
          s.posting_time, 
          COUNT(i.id) AS item_count
        FROM StockCountEntry AS s
        LEFT JOIN StockCountEntryItem AS i ON s.id = i.stock_count_entry_id
        WHERE s.stock_count_person = ?
        GROUP BY s.id
        ORDER BY s.id DESC
      ''';
          final List<Map<String, dynamic>> result =
              await widget.database!.rawQuery(query, [stockCountPersonId]);
          setState(() {
            entries = result;
          });
        }
      } catch (e) {
        print("Error fetching entries: $e");
      }
    }
  }

  void startRecount(int entryId, String warehouse, String countType) {
    if (countType == 'Count type') {
      showErrorDialog(context, "Please select the Count type first.");
      return;
    }
    widget.database!.query('StockCountEntry',
        where: 'id = ?', whereArgs: [entryId]).then((result) {
      if (result.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
                recountEntryId: entryId,
                recountWarehouse: warehouse,
                countType: countType,
                database: widget.database),
          ),
        );
      }
    });
  }

  void startEntryDetails(int entryId, String warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailsScreen(
          entryId: entryId,
          warehouse: warehouse,
          database: widget.database,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockTakeNotifier>(
      builder: (context, stockTakeNotifier, child) {
        String countType = stockTakeNotifier.countType;
        return Center(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 1.4, vertical: fixPadding * 3.5),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: entries.isEmpty
                ? const LinearProgressIndicator()
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          optionWidget(
                            () {
                              // Open the entry details when the card is tapped
                              startEntryDetails(entries[index]['id'],
                                  entries[index]['warehouse']);
                            },
                            "Entry ${entries[index]['id']} - ${entries[index]['warehouse']}",
                            "Items : ${entries[index]['item_count']} | ${entries[index]['posting_date']} | ${entries[index]['posting_time']}",
                            () {
                              // Start recount when the refresh icon is tapped
                              startRecount(
                                entries[index]['id'],
                                entries[index]['warehouse'],
                                countType,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

Widget optionWidget(VoidCallback onTap, String title, String subTitle,
    VoidCallback onRefreshTap) {
  return GestureDetector(
    onTap: onTap, // This handles the card tap for viewing entry details
    child: Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding, vertical: fixPadding * 1.6),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRefreshTap, // This handles the tap for the refresh icon
            child: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.15),
                    blurRadius: 6.0,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Iconify(Uil.refresh),
            ),
          ),
          const SizedBox(width: fixPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: semibold16Black33,
                ),
                const SizedBox(height: 5),
                Text(
                  subTitle,
                  style: medium14Grey,
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
              size: 20.0,
            ),
          ),
        ],
      ),
    ),
  );
}
