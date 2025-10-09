import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/services/stock_service.dart';

class OutboxQueue {
  static const _uuid = Uuid();

  static Future<Database> _db() async {
    var databasesPath = await getDatabasesPath();
    return openDatabase(
      '$databasesPath/stock_count.db',
      version: DBSchema.dbVersion,
      onCreate: DBSchema.initDB,
      onUpgrade: DBSchema.upgradeDB,
    );
  }

  // Add an operation to the Outbox and return idempotency key
  static Future<String> addOperation(String opType, Map<String, dynamic> payload) async {
    final db = await _db();
    final key = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert('Outbox', {
      'op_type': opType,
      'payload': jsonEncode(payload),
      'idempotency_key': key,
      'status': 'queued',
      'attempts': 0,
      'created_at': now,
      'updated_at': now,
    });
    return key;
  }

  // Process queued operations (minimal: stock_entry only)
  static Future<void> processQueue() async {
    final db = await _db();

    // Ensure auth exists before doing network work
    final authBox = await Hive.openBox('authBox');
    final accessToken = authBox.get('accessToken');
    final tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');
    if (accessToken == null || tokenExpiry == null || DateTime.now().isAfter(tokenExpiry)) {
      return; // Skip until user is authenticated
    }

    final rows = await db.query('Outbox', where: 'status = ?', whereArgs: ['queued'], limit: 20);
    for (final row in rows) {
      final id = row['id'] as int;
      final opType = row['op_type'] as String;
      final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;

      try {
        await db.update('Outbox', {'status': 'sending', 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);

        switch (opType) {
          case 'stock_entry':
            await StockService.pushStockEntry(payload);
            break;
          case 'stock_reconciliation':
            await StockService.createReconciliation(payload);
            break;
          default:
            throw Exception('Unsupported operation: $opType');
        }

        await db.update('Outbox', {'status': 'acked', 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        final attempts = (row['attempts'] as int) + 1;
        await db.update(
          'Outbox',
          {
            'status': 'queued', // keep queued with backoff controlled by caller schedule
            'attempts': attempts,
            'last_error': e.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }
}
