import 'package:sqflite/sqflite.dart';

class DBSchema {
  static const int dbVersion = 2;

  // Function to initialize the database (fresh install)
  static Future<void> initDB(Database db, int version) async {
    await _createCoreTables(db);
    await _createStockMovementTables(db);
    await _createPickPackTables(db);
    await _createOutbox(db);
    await _createReconciliationTables(db);
    await _createIndexes(db);
  }

  // Function to handle migrations
  static Future<void> upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createStockMovementTables(db);
      await _createPickPackTables(db);
      await _createOutbox(db);
      await _createReconciliationTables(db);
      await _createIndexes(db);
    }
  }

  static Future<void> _createCoreTables(Database db) async {
    // Stock Count tables (existing)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockCountEntry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        company TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        posting_date TEXT NOT NULL,
        posting_time TEXT NOT NULL,
        stock_count_person TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        last_sync_time TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockCountEntryItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_count_entry_id INTEGER NOT NULL,
        server_id TEXT,
        item_barcode TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        qty REAL NOT NULL,
        synced INTEGER DEFAULT 0,
        last_sync_time TEXT,
        FOREIGN KEY(stock_count_entry_id) REFERENCES StockCountEntry(id) ON DELETE CASCADE
      );
    ''');
  }

  static Future<void> _createStockMovementTables(Database db) async {
    // Stock Entry (Transfer/Issue/Receipt)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockEntry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        docname TEXT,
        company TEXT,
        type TEXT NOT NULL,
        from_warehouse TEXT,
        to_warehouse TEXT,
        posting_date TEXT,
        posting_time TEXT,
        status TEXT DEFAULT 'draft',
        submitted INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        last_sync_time TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockEntryItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_entry_id INTEGER NOT NULL,
        server_id TEXT,
        item_code TEXT,
        barcode TEXT,
        warehouse TEXT,
        uom TEXT,
        conversion_factor REAL,
        qty REAL,
        batch_no TEXT,
        serial_nos_json TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY(stock_entry_id) REFERENCES StockEntry(id) ON DELETE CASCADE
      );
    ''');
  }

  static Future<void> _createPickPackTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PickList (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        docname TEXT,
        server_id TEXT,
        status TEXT,
        company TEXT,
        assigned_to TEXT,
        synced INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PickListItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pick_list_id INTEGER NOT NULL,
        item_code TEXT,
        required_qty REAL,
        picked_qty REAL,
        warehouse TEXT,
        bin TEXT,
        batch_no TEXT,
        serial_nos_json TEXT,
        server_id TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY(pick_list_id) REFERENCES PickList(id) ON DELETE CASCADE
      );
    ''');
  }

  static Future<void> _createReconciliationTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockReconciliation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        docname TEXT,
        company TEXT,
        warehouse TEXT,
        source_count_entry_id INTEGER,
        status TEXT,
        synced INTEGER DEFAULT 0,
        last_sync_time TEXT
      );
    ''');
  }

  static Future<void> _createOutbox(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        op_type TEXT NOT NULL,
        payload TEXT NOT NULL,
        idempotency_key TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'queued',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      );
    ''');
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_outbox_status ON Outbox(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stockentry_synced ON StockEntry(synced);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stockentryitem_entry ON StockEntryItem(stock_entry_id);');
  }
}
