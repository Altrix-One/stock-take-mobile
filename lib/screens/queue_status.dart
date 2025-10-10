import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/utilis/outbox_queue.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});
  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  List<Map<String, Object?>> _rows = [];
  bool _loading = true;

  String _prettyError(String raw){
    if (raw.isEmpty) return '';
    // Try to extract the Python exception message from Frappe's JSON error
    try {
      // Common pattern: "HRMS API error 500: {\"exception\":\"TypeError: ...\" ... }"
      final idx = raw.indexOf('{');
      if (idx > 0) {
        final jsonPart = raw.substring(idx);
        final map = json.decode(jsonPart) as Map<String, dynamic>;
        final exc = map['exception']?.toString();
        if (exc != null && exc.isNotEmpty) return exc;
      }
    } catch (_) {}
    return raw.length > 500 ? raw.substring(0, 500) + '…' : raw;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Database> _db() async {
    final dir = await getDatabasesPath();
    return openDatabase(p.join(dir, 'stock_count.db'), version: DBSchema.dbVersion, onCreate: DBSchema.initDB, onUpgrade: DBSchema.upgradeDB);
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final db = await _db();
    final rows = await db.query('Outbox', orderBy: 'id desc', limit: 100);
    setState(() { _rows = rows; _loading = false; });
  }

  Future<void> _retry(int id) async {
    final db = await _db();
    await db.update('Outbox', {'status': 'queued'}, where: 'id = ?', whereArgs: [id]);
    await OutboxQueue.processQueue();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Queue')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (_, i) {
                  final r = _rows[i];
                  final lastError = (r['last_error']?.toString() ?? '');
                  final subtitle = lastError.isEmpty ? (r['updated_at']?.toString() ?? '') : _prettyError(lastError);
                  return ListTile(
                    title: Text('${r['op_type']} • ${r['status']}'),
                    subtitle: Text(subtitle),
                    trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: () => _retry(r['id'] as int)),
                  );
                },
              ),
            ),
    );
  }
}