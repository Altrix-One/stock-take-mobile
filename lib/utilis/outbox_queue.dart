import 'dart:convert';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:cohenix_ess/utilis/db_schema.dart';
import 'package:cohenix_ess/services/stock_service.dart';
import 'package:cohenix_ess/hr/services/leaves_service.dart';
import 'package:cohenix_ess/hr/services/attendance_service.dart';
import 'package:cohenix_ess/hr/services/claims_service.dart';

class OutboxQueue {
  static const _uuid = Uuid();

  // Broadcast simple events to help screens refresh automatically when the queue changes
  static final StreamController<void> _eventsController =
      StreamController<void>.broadcast();
  static Stream<void> get events => _eventsController.stream;

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
  static Future<String> addOperation(
      String opType, Map<String, dynamic> payload) async {
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
    // Notify listeners and try process immediately (fire-and-forget)
    _eventsController.add(null);
    // Best-effort immediate processing; do not await to keep UI snappy
    // ignore: unawaited_futures
    processQueue();
    return key;
  }

  // Totals of pending leave applications grouped by leave_type
  static Future<Map<String, double>> pendingLeaveByType() async {
    final db = await _db();
    final rows = await db.query('Outbox',
        where: "op_type = ? AND status IN ('queued','sending')",
        whereArgs: ['leave_application']);
    final totals = <String, double>{};
    for (final r in rows) {
      try {
        final payload =
            jsonDecode(r['payload'] as String) as Map<String, dynamic>;
        final lt = payload['leave_type']?.toString();
        final days = (payload['days'] is num)
            ? (payload['days'] as num).toDouble()
            : double.tryParse('${payload['days']}') ?? 0;
        if (lt != null && lt.isNotEmpty && days > 0) {
          totals[lt] = (totals[lt] ?? 0) + days;
        }
      } catch (_) {}
    }
    return totals;
  }

  // Process queued operations (minimal: stock_entry only)
  static Future<void> processQueue() async {
    final db = await _db();

    // Ensure auth exists before doing network work
    final authBox = await Hive.openBox('authBox');
    final accessToken = authBox.get('accessToken');
    final tokenExpiry = DateTime.tryParse(authBox.get('tokenExpiry') ?? '');
    if (accessToken == null ||
        tokenExpiry == null ||
        DateTime.now().isAfter(tokenExpiry)) {
      return; // Skip until user is authenticated
    }

    final rows = await db.query('Outbox',
        where: 'status = ?',
        whereArgs: ['queued'],
        orderBy: 'id asc',
        limit: 50);
    final now = DateTime.now();
    for (final row in rows) {
      final id = row['id'] as int;
      final opType = row['op_type'] as String;
      final payload =
          jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      final attempts = (row['attempts'] as int?) ?? 0;
      // simple exponential backoff: 0s, 30s, 2m, 6m, 30m, 60m cap
      final delays = [0, 30, 120, 360, 1800, 3600];
      final delay = delays[attempts.clamp(0, delays.length - 1)];
      final updatedAt = DateTime.tryParse(row['updated_at']?.toString() ??
              row['created_at']?.toString() ??
              '') ??
          now;
      if (now.difference(updatedAt).inSeconds < delay) {
        // Skip until backoff window expires
        continue;
      }

      try {
        await db.update(
            'Outbox',
            {
              'status': 'sending',
              'updated_at': DateTime.now().toIso8601String()
            },
            where: 'id = ?',
            whereArgs: [id]);

        switch (opType) {
          case 'stock_entry':
            await StockService.pushStockEntry(payload);
            break;
          case 'stock_reconciliation':
            await StockService.createReconciliation(payload);
            break;
          case 'leave_application':
            await _handleLeaveApplication(payload);
            break;
          case 'attendance_request':
            await _handleAttendanceRequest(payload);
            break;
          case 'shift_request':
            await _handleShiftRequest(payload);
            break;
          case 'expense_claim':
            await _handleExpenseClaim(payload);
            break;
          case 'approval_action':
            await _handleApprovalAction(payload);
            break;
          case 'cancel_leave':
            await _handleCancelLeave(payload);
            break;
          default:
            throw Exception('Unsupported operation: $opType');
        }

        await db.update('Outbox',
            {'status': 'acked', 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?', whereArgs: [id]);
        _eventsController.add(null);
      } catch (e) {
        final attempts = (row['attempts'] as int) + 1;
        await db.update(
          'Outbox',
          {
            'status':
                'queued', // keep queued with backoff controlled by caller schedule
            'attempts': attempts,
            'last_error': e.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        _eventsController.add(null);
      }
    }
  }

  // Expose pending leave rows for optimistic UI in lists
  static Future<List<Map<String, dynamic>>> pendingLeaveRows() async {
    final db = await _db();
    final rows = await db.query('Outbox',
        where: "op_type = ? AND status IN ('queued','sending')",
        whereArgs: ['leave_application']);
    final list = <Map<String, dynamic>>[];
    for (final r in rows) {
      try {
        final payload =
            jsonDecode(r['payload'] as String) as Map<String, dynamic>;
        list.add({
          'name': null,
          'leave_type': payload['leave_type'],
          'from_date': payload['from_date'],
          'to_date': payload['to_date'],
          'status': 'Applied (queued)',
        });
      } catch (_) {}
    }
    return list;
  }

  static Future<void> _handleLeaveApplication(
      Map<String, dynamic> payload) async {
    await LeavesService.submitLeaveApplication(payload);
  }

  static Future<void> _handleAttendanceRequest(
      Map<String, dynamic> payload) async {
    await AttendanceService.submitAttendanceRequest(payload);
  }

  static Future<void> _handleShiftRequest(Map<String, dynamic> payload) async {
    await AttendanceService.submitShiftRequest(payload);
  }

  static Future<void> _handleExpenseClaim(Map<String, dynamic> payload) async {
    await ClaimsService.submitExpenseClaim(payload);
  }

  static Future<void> _handleApprovalAction(
      Map<String, dynamic> payload) async {
    await AttendanceService.approvalAction(
      doctype: payload['doctype'] as String,
      name: payload['name'] as String,
      approve: (payload['approve'] as bool?) ?? true,
      comment: payload['comment'] as String?,
    );
  }

  static Future<void> _handleCancelLeave(Map<String, dynamic> payload) async {
    final name = payload['name']?.toString();
    final reason = payload['reason']?.toString();
    if (name == null || name.isEmpty)
      throw Exception('Missing leave application name');
    await LeavesService.cancelLeaveApplication(name, reason: reason);
  }
}
