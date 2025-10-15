import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:stock_count/utils/error_message_parser.dart';
import 'package:stock_count/widgets/professional_error_dialog.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});
  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  List<Map<String, Object?>> _rows = [];
  bool _loading = true;

  String _prettyError(String raw, String opType) {
    if (raw.isEmpty) return '';

    // Use our error message parser for user-friendly messages
    if (opType == 'leave_application' || opType == 'cancel_leave') {
      return ErrorMessageParser.parseLeaveApplicationError(raw);
    }

    return ErrorMessageParser.parseGeneralError(raw,
        operation: opType.replaceAll('_', ' '));
  }

  String _getStatusIcon(String status, String opType) {
    switch (status.toLowerCase()) {
      case 'acked':
        return '✅';
      case 'queued':
        return '⏳';
      case 'sending':
        return '📤';
      default:
        return '❌';
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'acked':
        return Colors.green;
      case 'queued':
        return theme.colorScheme.primary;
      case 'sending':
        return Colors.orange;
      default:
        return theme.colorScheme.error;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Database> _db() async {
    final dir = await getDatabasesPath();
    return openDatabase(p.join(dir, 'stock_count.db'),
        version: DBSchema.dbVersion,
        onCreate: DBSchema.initDB,
        onUpgrade: DBSchema.upgradeDB);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final db = await _db();
    final rows = await db.query('Outbox', orderBy: 'id desc', limit: 100);
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  Future<void> _retry(int id) async {
    final db = await _db();
    await db.update('Outbox', {'status': 'queued'},
        where: 'id = ?', whereArgs: [id]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retrying operation...')),
    );
    await OutboxQueue.processQueue();
    await _load();
  }

  Future<void> _showErrorDetails(String error, String opType) async {
    final friendlyMessage = _prettyError(error, opType);
    await ProfessionalErrorDialog.show(
      context: context,
      title: '${ErrorMessageParser.getErrorIcon(error)} Operation Failed',
      errorMessage: friendlyMessage,
      canRetry: false,
    );
  }

  Future<void> _deleteOperation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Operation'),
        content: const Text(
            'Are you sure you want to delete this operation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = await _db();
      await db.delete('Outbox', where: 'id = ?', whereArgs: [id]);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Queue')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'All operations completed!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No pending sync operations',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rows.length,
                    itemBuilder: (_, i) {
                      final r = _rows[i];
                      final opType = r['op_type']?.toString() ?? '';
                      final status = r['status']?.toString() ?? '';
                      final lastError = r['last_error']?.toString() ?? '';
                      final hasError = lastError.isNotEmpty;
                      final updatedAt = r['updated_at']?.toString() ?? '';
                      final attempts = r['attempts'] as int? ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: hasError
                              ? () => _showErrorDetails(lastError, opType)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status, context)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStatusIcon(status, opType),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            opType
                                                .replaceAll('_', ' ')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  status, context),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (attempts > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Attempt $attempts',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (hasError) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .errorContainer
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _prettyError(lastError, opType),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tap for details',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Updated: $updatedAt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (hasError)
                                      TextButton.icon(
                                        onPressed: () =>
                                            _deleteOperation(r['id'] as int),
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16),
                                        label: const Text('Delete'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    if (status != 'acked')
                                      FilledButton.icon(
                                        onPressed: () => _retry(r['id'] as int),
                                        icon:
                                            const Icon(Icons.refresh, size: 16),
                                        label: const Text('Retry'),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
