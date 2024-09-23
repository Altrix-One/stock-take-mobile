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
    return await openDatabase(path, version: 1, onCreate: DBSchema.initDB);
  }

  // Sync to server without refreshing token automatically
  static Future<void> syncToServer() async {
    var authBox = Hive.box('authBox');
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = authBox.get('tokenExpiry');

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
      List<Map<String, dynamic>> unsyncedEntries = await db
          .query('StockCountEntry', where: 'synced = ?', whereArgs: [0]);

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
            'entry': entry,
            'entry_items': entryItems,
          });
        }

        var postData = {
          'api_call_type': 'sync_bulk_entries',
          'entries': bulkData,
        };

        var response = await http.post(
          Uri.parse('$_baseUrl/api/method/sync_entry'),
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
                {'synced': 1, 'server_id': syncedEntry['server_id']},
                where: 'id = ?',
                whereArgs: [syncedEntry['local_id']],
              );

              // Update associated items
              List<Map<String, dynamic>> entryItems = await db.query(
                'StockCountEntryItem',
                where: 'stock_count_entry_id = ?',
                whereArgs: [syncedEntry['local_id']],
              );

              for (var item in entryItems) {
                await db.update(
                  'StockCountEntryItem',
                  {'synced': 1},
                  where: 'id = ?',
                  whereArgs: [item['id']],
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

  // Sync from server without refreshing token automatically
  static Future<void> syncFromServer() async {
    var authBox = Hive.box('authBox');
    String? accessToken = authBox.get('accessToken');
    DateTime? tokenExpiry = authBox.get('tokenExpiry');

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
        Uri.parse('$_baseUrl/api/method/sync_entry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        List<dynamic> serverEntries = jsonDecode(response.body)['message'];
        Database db = await getDatabase();

        for (var entry in serverEntries) {
          // Check if entry already exists in local database
          List<Map<String, dynamic>> localEntry = await db.query(
            'StockCountEntry',
            where: 'server_id = ?',
            whereArgs: [entry['name']],
          );

          if (localEntry.isEmpty) {
            // If entry does not exist, insert it
            int entryId = await db.insert(
              'StockCountEntry',
              {
                'server_id': entry['name'], // Save server ID for syncing
                'company': entry['company'],
                'warehouse': entry['warehouse'],
                'posting_date': entry['posting_date'],
                'posting_time': entry['posting_time'],
                'stock_count_person': entry['st_user'],
                'synced': 1, // Mark as synced
                'last_sync_time': DateTime.now().toIso8601String(),
              },
            );

            // Insert associated items for the new entry
            List<dynamic> entryItems = entry['entry_items'];
            for (var item in entryItems) {
              await db.insert(
                'StockCountEntryItem',
                {
                  'stock_count_entry_id': entryId, // Local FK to the new entry
                  'server_id': item['name'], // Save server item ID
                  'item_barcode': item['item_barcode'],
                  'warehouse': entry['warehouse'],
                  'qty': item['qty'],
                  'synced': 1, // Mark as synced
                  'last_sync_time': DateTime.now().toIso8601String(),
                },
              );
            }
          } else {
            // If entry exists, update it
            int entryId = await db.update(
              'StockCountEntry',
              {
                'company': entry['company'],
                'warehouse': entry['warehouse'],
                'posting_date': entry['posting_date'],
                'posting_time': entry['posting_time'],
                'stock_count_person': entry['st_user'],
                'synced': 1,
                'last_sync_time': DateTime.now().toIso8601String(),
              },
              where: 'server_id = ?',
              whereArgs: [entry['name']],
            );

            // Update associated items for the existing entry
            List<dynamic> entryItems = entry['entry_items'];
            for (var item in entryItems) {
              await db.update(
                'StockCountEntryItem',
                {
                  'item_barcode': item['item_barcode'],
                  'warehouse': entry['warehouse'],
                  'qty': item['qty'],
                  'synced': 1,
                  'last_sync_time': DateTime.now().toIso8601String(),
                },
                where: 'server_id = ?',
                whereArgs: [item['name']],
              );
            }
          }
        }

        print("Fetch from server completed.");
      } else {
        print("Error fetching from server: ${response.body}");
      }
    } catch (e) {
      print("Fetch from server failed: $e");
    }
  }

  // Token refreshing logic for login (not used in background tasks)
  static Future<void> refreshTokenIfNeeded() async {
    var authBox = Hive.box('authBox');
    String? refreshToken = authBox.get('refreshToken');
    DateTime? tokenExpiry = authBox.get('tokenExpiry');

    if (tokenExpiry != null && DateTime.now().isAfter(tokenExpiry)) {
      print("Token expired, refreshing...");
      try {
        var response = await http.post(
          Uri.parse(
              '$_baseUrl/api/method/frappe.integrations.oauth2.get_token'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            'client_id': AppConfig.clientId,
            'redirect_uri': AppConfig.redirectUri,
          },
        );

        if (response.statusCode == 200) {
          var tokenData = jsonDecode(response.body);
          authBox.put('accessToken', tokenData['access_token']);
          authBox.put('tokenExpiry',
              DateTime.now().add(Duration(seconds: tokenData['expires_in'])));
          print("Token refreshed successfully.");
        } else {
          print("Error refreshing token: ${response.body}");
        }
      } catch (e) {
        print("Token refresh failed: $e");
      }
    } else {
      print("Token still valid, no need to refresh.");
    }
  }
}
