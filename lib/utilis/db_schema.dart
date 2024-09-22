import 'package:sqflite/sqflite.dart';

class DBSchema {
  // Function to initialize the database
  static Future<void> initDB(Database db, int version) async {
    // Creating the StockCountEntry table with sync-related columns
    await db.execute('''
      CREATE TABLE StockCountEntry (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Local unique ID
        server_id TEXT, -- The ID from the Frappe server, to sync data
        company TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        posting_date TEXT NOT NULL,
        posting_time TEXT NOT NULL,
        stock_count_person TEXT NOT NULL,
        synced INTEGER DEFAULT 0, -- Whether entry has been synced (0: no, 1: yes)
        last_sync_time TEXT -- Timestamp of the last sync
      );
    ''');

    // Creating the StockCountEntryItem table with sync-related columns
    await db.execute('''
      CREATE TABLE StockCountEntryItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Local unique ID
        stock_count_entry_id INTEGER NOT NULL, -- Local FK to StockCountEntry
        server_id TEXT, -- The ID from the Frappe server for each item
        item_barcode TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        qty INTEGER NOT NULL,
        synced INTEGER DEFAULT 0, -- Whether item has been synced (0: no, 1: yes)
        last_sync_time TEXT, -- Timestamp of the last sync
        FOREIGN KEY(stock_count_entry_id) REFERENCES StockCountEntry(id) ON DELETE CASCADE
      );
    ''');
  }
}
