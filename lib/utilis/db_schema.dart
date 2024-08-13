import 'package:sqflite/sqflite.dart';

class DBSchema {
  // Function to initialize the database
  static Future<void> initDB(Database db, int version) async {
    // Execute the SQL code to create the main table
    await db.execute(
        '''
      CREATE TABLE StockCountEntry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        posting_date TEXT NOT NULL,
        posting_time TEXT NOT NULL,
        stock_count_person TEXT NOT NULL
      );
    ''');

    // Execute the SQL code to create the child table
    await db.execute(
        '''
      CREATE TABLE StockCountEntryItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_count_entry_id INTEGER NOT NULL,
        item_barcode TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        qty INTEGER NOT NULL,
        FOREIGN KEY(stock_count_entry_id) REFERENCES StockCountEntry(id) ON DELETE CASCADE
      );
    ''');
  }
}
