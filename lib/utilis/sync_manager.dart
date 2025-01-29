import 'package:flutter/material.dart';
import 'package:stock_count/config.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // Hive for token management
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:stock_count/utilis/db_schema.dart';

class SyncManager {
  static const _baseUrl = AppConfig.baseUrl;
  static Future<Database> getDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'stock_count.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: DBSchema.initDB,
    );
  }

  // Ensure that the 'authBox' is open before accessing it
  static Future<Box> _getAuthBox() async {
    if (!Hive.isBoxOpen('authBox')) {
      return await Hive.openBox('authBox');
    }
    return Hive.box('authBox');
  }

  // Sync to server without refreshing token automatically
  static Future<void> syncToServer() async {
    var authBox = await _getAuthBox(); // Ensure box is open
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');

    // Proceed only if token is still valid
    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      print("Access token is either missing or expired. Sync aborted.");
      return;
    }

    Database db = await getDatabase();

    try {
      // Fetch only unsynced entries (synced = 0)
      List<Map<String, dynamic>> unsyncedEntries = await db.query(
        'StockCountEntry',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (unsyncedEntries.isNotEmpty) {
        List<Map<String, dynamic>> bulkData = [];

        for (var entry in unsyncedEntries) {
          // Fetch associated unsynced items for each entry
          List<Map<String, dynamic>> entryItems = await db.query(
            'StockCountEntryItem',
            where: 'stock_count_entry_id = ? AND synced = 0',
            whereArgs: [entry['id']],
          );

          bulkData.add({
            'entry': {
              'local_id': entry['id'], // Map 'id' as 'local_id'
              'company': entry['company'],
              'set_warehouse':
                  entry['warehouse'], // Map 'warehouse' to 'set_warehouse'
              'posting_date': entry['posting_date'],
              'posting_time': entry['posting_time'],
            },
            'entry_items': entryItems.map((item) {
              return {
                'local_id': item['id'], // Map 'id' as 'local_id'
                'barcode': item['item_barcode'],
                'warehouse': item['warehouse'],
                'qty': item['qty'],
                // If you have item_name and item_code locally, include them
                // Otherwise, you may need to fetch or map them accordingly
                // For now, we'll omit them as they're not in local schema
              };
            }).toList(),
          });
        }

        var postData = {
          'api_call_type': 'sync_bulk_entries',
          'entries': bulkData,
        };

        var response = await http.post(
          Uri.parse(
              '$_baseUrl/api/method/nex_bridge.api.stock_take.sync_entry'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(postData),
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          var syncedEntries = responseData['message']['synced_entries'];

          if (syncedEntries != null && syncedEntries is List) {
            for (var syncedEntry in syncedEntries) {
              // Update local entries with server_id and mark as synced
              await db.update(
                'StockCountEntry',
                {
                  'synced': 1,
                  'server_id': syncedEntry['server_id'],
                  'last_sync_time': DateTime.now().toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: [syncedEntry['local_id']],
              );

              // Update associated items
              // Assuming the server response includes item mappings
              List<dynamic> syncedItems = syncedEntry['items'] ?? [];

              for (var syncedItem in syncedItems) {
                await db.update(
                  'StockCountEntryItem',
                  {
                    'synced': 1,
                    'server_id': syncedItem['server_id'],
                    'last_sync_time': DateTime.now().toIso8601String(),
                    // 'current_qty' is not present locally; handle accordingly
                    // 'item_name' and 'item_code' are not present locally; handle if needed
                  },
                  where: 'id = ?',
                  whereArgs: [syncedItem['local_id']],
                );
              }
            }
            print("Bulk sync completed successfully.");
          } else {
            print("No synced entries found in response.");
          }
        } else {
          print("Error during bulk sync: ${response.body}");
        }
      } else {
        print("No unsynced entries found for sync.");
      }
    } catch (e) {
      print("Bulk sync to server failed: $e");
    }
  }

  // Revised syncFromServer method based on server_id
  static Future<void> syncFromServer() async {
    var authBox = await _getAuthBox(); // Ensure box is open
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');

    // Proceed only if token is still valid
    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      print("Access token is either missing or expired. Sync aborted.");
      return;
    }

    try {
      var postData = {'api_call_type': 'get_entries'};

      var response = await http.post(
        Uri.parse('$_baseUrl/api/method/nex_bridge.api.stock_take.sync_entry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body)['message'];
        List<dynamic> serverEntries = responseData['entries'] ?? [];

        Database db = await getDatabase();

        for (var entry in serverEntries) {
          String? serverId = entry['name'];
          List<Map<String, dynamic>> localEntry = await db.query(
            'StockCountEntry',
            where: 'server_id = ?',
            whereArgs: [serverId],
          );

          if (localEntry.isEmpty) {
            await db.insert(
              'StockCountEntry',
              {
                'server_id': serverId,
                'company': entry['company'],
                'warehouse': entry['set_warehouse'],
                'posting_date': entry['posting_date'],
                'posting_time': entry['posting_time'],
                'stock_count_person': entry['owner'],
                'synced': 1,
                'last_sync_time': DateTime.now().toIso8601String(),
              },
            );

            List<dynamic> entryItems = entry['items'] ?? [];
            for (var item in entryItems) {
              await db.insert(
                'StockCountEntryItem',
                {
                  'stock_count_entry_id':
                      await _getLocalEntryIdByServerId(db, serverId!),
                  'server_id': item['name'],
                  'item_barcode': item['barcode'],
                  'warehouse': item['warehouse'],
                  'qty': item['qty'],
                  'synced': 1,
                  'last_sync_time': DateTime.now().toIso8601String(),
                },
              );
            }
          } else {
            await db.update(
              'StockCountEntry',
              {
                'company': entry['company'],
                'warehouse': entry['set_warehouse'],
                'posting_date': entry['posting_date'],
                'posting_time': entry['posting_time'],
                'stock_count_person': entry['owner'],
                'synced': 1,
                'last_sync_time': DateTime.now().toIso8601String(),
              },
              where: 'server_id = ?',
              whereArgs: [serverId],
            );

            // Update associated items for the existing entry
            List<dynamic> entryItems = entry['items'] ?? [];
            for (var item in entryItems) {
              String? itemServerId = item['name'];
              // Check if item exists
              List<Map<String, dynamic>> localItem = await db.query(
                'StockCountEntryItem',
                where: 'server_id = ?',
                whereArgs: [itemServerId],
              );

              if (localItem.isEmpty) {
                // Insert new item
                await db.insert(
                  'StockCountEntryItem',
                  {
                    'stock_count_entry_id':
                        await _getLocalEntryIdByServerId(db, serverId!),
                    'server_id': itemServerId,
                    'item_barcode': item['barcode'],
                    'warehouse': item['warehouse'],
                    'qty': item['qty'],
                    'synced': 1,
                    'last_sync_time': DateTime.now().toIso8601String(),
                  },
                );
              } else {
                await db.update(
                  'StockCountEntryItem',
                  {
                    'item_barcode': item['barcode'],
                    'warehouse': item['warehouse'],
                    'qty': item['qty'],
                    'synced': 1,
                    'last_sync_time': DateTime.now().toIso8601String(),
                  },
                  where: 'server_id = ?',
                  whereArgs: [itemServerId],
                );
              }
            }
          }
        }

        print("Fetch from server completed successfully.");
      } else {
        print("Error fetching from server: ${response.body}");
      }
    } catch (e) {
      print("Fetch from server failed: $e");
    }
  }

  // Helper method to get local entry id by server_id
  static Future<int?> _getLocalEntryIdByServerId(
      Database db, String serverId) async {
    List<Map<String, dynamic>> result = await db.query(
      'StockCountEntry',
      where: 'server_id = ?',
      whereArgs: [serverId],
      columns: ['id'],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    }
    return null;
  }

  // Method to fetch and store warehouses and companies in Hive
  static Future<void> fetchAndStoreWarehousesAndCompanies() async {
    var authBox = await _getAuthBox();
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');

    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      print("Access token is either missing or expired. Sync aborted.");
      return;
    }

    // Clear previous data
    await authBox.delete('warehouses_by_company');
    await authBox.delete('companies');
    print(
        "Cleared previous warehouse and company data before fetching new ones.");

    try {
      var response = await http.post(
        Uri.parse(
            '$_baseUrl/api/method/nex_bridge.api.stock_take.get_warehouses_grouped_by_company'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Process and store in Hive
        if (data['message'] != null &&
            data['message']['warehouses_by_company'] != null &&
            data['message']['companies'] != null) {
          Map<String, List<String>> warehousesByCompany = {};
          (data['message']['warehouses_by_company'] as Map<String, dynamic>)
              .forEach((key, value) {
            warehousesByCompany[key] =
                List<String>.from(value as List<dynamic>);
          });

          List<String> companies =
              List<String>.from(data['message']['companies']);

          await authBox.put(
              'warehouses_by_company', jsonEncode(warehousesByCompany));
          await authBox.put('companies', jsonEncode(companies));

          print("Warehouses and companies stored in Hive.");
        } else {
          print("Unexpected response format for warehouses and companies.");
        }
      } else {
        print("Failed to fetch warehouses and companies: ${response.body}");
      }
    } catch (e) {
      print("Error fetching warehouses and companies: $e");
    }
  }

  // Method to fetch and store assigned items in Hive
  static Future<void> fetchAndStoreAssignedItems() async {
    var authBox = await _getAuthBox();
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');

    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      print("Access token is either missing or expired. Sync aborted.");
      return;
    }

    // Clear existing data to avoid stale cache issues
    await authBox.delete('assigned_items');
    print("Cleared previous assigned items before fetching new ones.");

    try {
      var response = await http.post(
        Uri.parse(
            '$_baseUrl/api/method/nex_bridge.api.stock_take.get_user_assigned_items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely check if 'message' and 'assigned_items' are valid keys and if the assigned items are a list.
        if (data is Map<String, dynamic> &&
            data['message'] is Map<String, dynamic> &&
            data['message']['assigned_items'] is List) {
          List<dynamic> assignedItems = data['message']['assigned_items'];

          if (assignedItems.isNotEmpty) {
            await authBox.put('assigned_items', jsonEncode(assignedItems));
            print("Assigned items stored in Hive.");
          } else {
            // No assigned items available
            print(
                "Assigned items are empty. Cleared assigned_items from Hive.");
          }
        } else {
          // Response not in expected format, ensure nothing stale is left
          print(
              "Unexpected response format for assigned items. Cleared assigned_items from Hive.");
        }
      } else {
        print("Failed to fetch assigned items: ${response.body}");
      }
    } catch (e) {
      print("Error fetching assigned items: $e");
    }
  }

  // Token refreshing logic for login (not used in background tasks)
  // static Future<void> refreshTokenIfNeeded() async {
  //   var authBox = await _getAuthBox(); // Ensure box is open
  //   String? refreshToken = authBox.get('refreshToken');
  //   DateTime? tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');

  //   if (tokenExpiry != null && DateTime.now().isAfter(tokenExpiry)) {
  //     print("Token expired, refreshing...");
  //     try {
  //       var response = await http.post(
  //         Uri.parse(
  //             '$_baseUrl/api/method/frappe.integrations.oauth2.get_token'),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: {
  //           'grant_type': 'refresh_token',
  //           'refresh_token': refreshToken,
  //           'client_id': AppConfig.clientId,
  //           'redirect_uri': AppConfig.redirectUri,
  //         },
  //       );

  //       if (response.statusCode == 200) {
  //         var tokenData = jsonDecode(response.body);
  //         authBox.put('accessToken', tokenData['access_token']);
  //         authBox.put('tokenExpiry',
  //             DateTime.now().add(Duration(seconds: tokenData['expires_in'])));
  //         print("Token refreshed successfully.");
  //       } else {
  //         print("Error refreshing token: ${response.body}");
  //       }
  //     } catch (e) {
  //       print("Token refresh failed: $e");
  //     }
  //   } else {
  //     print("Token still valid, no need to refresh.");
  //   }
  // }
}
