import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:stock_count/utilis/db_schema.dart';
import 'package:stock_count/utilis/outbox_queue.dart';
import 'package:stock_count/utilis/sync_manager.dart';
import 'package:stock_count/services/item_service.dart';

class MoveScreen extends StatefulWidget {
  const MoveScreen({Key? key}) : super(key: key);
  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Material Transfer';
  String? _company;
  String? _fromWh;
  String? _toWh;
  final List<_Line> _lines = [];

  List<String> _companies = [];
  Map<String, List<String>> _warehousesByCompany = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCaches();
  }

  Future<void> _loadCaches() async {
    final box = await Hive.openBox('authBox');

    Future<void> _decodeFromBox() async {
      final companiesJson = box.get('companies');
      final whJson = box.get('warehouses_by_company');
      _companies = [];
      _warehousesByCompany = {};
      if (companiesJson != null) {
        _companies = List<String>.from(jsonDecode(companiesJson));
      }
      if (whJson != null) {
        (jsonDecode(whJson) as Map<String, dynamic>).forEach((k, v) {
          _warehousesByCompany[k] = List<String>.from(v as List);
        });
      }
      if (_companies.isNotEmpty) {
        _company = _company != null && _companies.contains(_company!)
            ? _company
            : _companies.first;
      } else {
        _company = null;
      }
    }

    await _decodeFromBox();
    if (_companies.isEmpty || _warehousesByCompany.isEmpty) {
      // Try fetching fresh data then decode again
      try {
        await SyncManager.fetchAndStoreWarehousesAndCompanies();
      } catch (_) {}
      await _decodeFromBox();
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _enqueue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }
    _formKey.currentState!.save();

    final postingDate = DateTime.now().toString().substring(0, 10);
    final postingTime = DateTime.now().toString().substring(11, 19);

    final payload = {
      'type': _type,
      'company': _company,
      'from_warehouse': _fromWh,
      'to_warehouse': _toWh,
      'posting_date': postingDate,
      'posting_time': postingTime,
      'items': _lines
          .map((l) => {
                'item_code': l.itemCode?.trim(),
                'barcode': l.barcode?.trim(),
                'qty': l.qty,
                'uom': l.uom,
                'warehouse': _type == 'Material Receipt' ? _toWh : _fromWh,
              })
          .toList(),
    };

    await OutboxQueue.addOperation('stock_entry', payload);

    // Also persist a local draft StockEntry row for visibility
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(p.join(dbPath, 'stock_count.db'),
        version: DBSchema.dbVersion,
        onCreate: DBSchema.initDB,
        onUpgrade: DBSchema.upgradeDB);
    final entryId = await db.insert('StockEntry', {
      'type': _type,
      'company': _company,
      'from_warehouse': _fromWh,
      'to_warehouse': _toWh,
      'posting_date': postingDate,
      'posting_time': postingTime,
      'status': 'queued',
      'synced': 0,
    });
    for (final l in _lines) {
      await db.insert('StockEntryItem', {
        'stock_entry_id': entryId,
        'item_code': l.itemCode,
        'barcode': l.barcode,
        'qty': l.qty,
        'uom': l.uom,
        'warehouse': _type == 'Material Receipt' ? _toWh : _fromWh,
        'synced': 0,
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movement queued for sync')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final whs =
        _company != null ? (_warehousesByCompany[_company] ?? []) : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movements'),
        actions: [
          IconButton(
            tooltip: 'Refresh companies/warehouses',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Refreshing companies and warehouses...')),
                );
              }
              setState(() => _loading = true);
              await SyncManager.fetchAndStoreWarehousesAndCompanies();
              await _loadCaches();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refresh complete')),
                );
              }
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Type
                    DropdownButtonFormField<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(
                            value: 'Material Transfer',
                            child: Text('Material Transfer')),
                        DropdownMenuItem(
                            value: 'Material Issue',
                            child: Text('Material Issue')),
                        DropdownMenuItem(
                            value: 'Material Receipt',
                            child: Text('Material Receipt')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 12),
                    // Company
                    DropdownButtonFormField<String>(
                      value: _company,
                      items: _companies
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: _companies.isEmpty
                          ? null
                          : (v) => setState(() {
                                _company = v;
                                _fromWh = null;
                                _toWh = null;
                              }),
                      decoration: const InputDecoration(labelText: 'Company'),
                      validator: (v) => v == null ? 'Company required' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_type != 'Material Receipt')
                      DropdownButtonFormField<String>(
                        value: _fromWh,
                        items: whs
                            .map((w) =>
                                DropdownMenuItem(value: w, child: Text(w)))
                            .toList(),
                        onChanged: whs.isEmpty
                            ? null
                            : (v) => setState(() => _fromWh = v),
                        decoration:
                            const InputDecoration(labelText: 'From Warehouse'),
                        validator: (v) =>
                            v == null ? 'From warehouse required' : null,
                      ),
                    if (_type != 'Material Issue')
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: DropdownButtonFormField<String>(
                          value: _toWh,
                          items: whs
                              .map((w) =>
                                  DropdownMenuItem(value: w, child: Text(w)))
                              .toList(),
                          onChanged: whs.isEmpty
                              ? null
                              : (v) => setState(() => _toWh = v),
                          decoration:
                              const InputDecoration(labelText: 'To Warehouse'),
                          validator: (v) =>
                              v == null ? 'To warehouse required' : null,
                        ),
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lines',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => setState(() => _lines.add(_Line())),
                          icon: const Icon(Icons.add),
                          label: const Text('Add line'),
                        ),
                      ],
                    ),
                    for (int i = 0; i < _lines.length; i++)
                      _LineEditor(
                          line: _lines[i],
                          onRemove: () => setState(() => _lines.removeAt(i))),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: _enqueue,
                        icon: const Icon(Icons.save),
                        label: const Text('Queue Movement')),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Line {
  String? itemCode;
  String? barcode;
  double qty = 1.0;
  String uom = 'Nos';
}

class _LineEditor extends StatefulWidget {
  final _Line line;
  final VoidCallback onRemove;
  const _LineEditor({required this.line, required this.onRemove, Key? key})
      : super(key: key);

  @override
  State<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<_LineEditor> {
  late TextEditingController _itemController;
  late TextEditingController _barcodeController;
  late TextEditingController _uomController;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.line.itemCode);
    _barcodeController = TextEditingController(text: widget.line.barcode);
    _uomController = TextEditingController(text: widget.line.uom);
    _qtyController = TextEditingController(text: widget.line.qty.toString());
  }

  @override
  void dispose() {
    _itemController.dispose();
    _barcodeController.dispose();
    _uomController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickItem() async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ItemPickerSheet(initialQuery: _itemController.text),
    );
    if (selected != null) {
      setState(() {
        _itemController.text = selected['item_code'] ?? '';
        _uomController.text = selected['uom'] ?? _uomController.text;
        widget.line.itemCode = _itemController.text;
        widget.line.uom = _uomController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              controller: _itemController,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Item Code (tap to search)'),
              onTap: _pickItem,
              onSaved: (v) => widget.line.itemCode = v,
            ),
            TextFormField(
              controller: _barcodeController,
              decoration:
                  const InputDecoration(labelText: 'Barcode (optional)'),
              onSaved: (v) => widget.line.barcode = v,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (v) =>
                        widget.line.qty = double.tryParse(v ?? '') ?? 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _uomController,
                    decoration: const InputDecoration(labelText: 'UOM'),
                    onSaved: (v) => widget.line.uom = (v ?? 'Nos').trim(),
                  ),
                ),
                IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  final String initialQuery;
  const _ItemPickerSheet({required this.initialQuery});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  final TextEditingController _query = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _query.text = widget.initialQuery;
    _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final items = await ItemService.searchItems(_query.text);
      setState(() => _results = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item search failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Search items',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _search(),
                      onChanged: (v) {
                        // rudimentary debounce via Future microtask
                        Future.delayed(const Duration(milliseconds: 250), () {
                          if (v == _query.text) _search();
                        });
                      },
                    ),
                  ),
                  IconButton(
                      onPressed: _search, icon: const Icon(Icons.refresh)),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final it = _results[index];
                    return ListTile(
                      title: Text(it['item_code'] ?? ''),
                      subtitle: Text(it['item_name'] ?? ''),
                      trailing: Text(it['uom'] ?? ''),
                      onTap: () => Navigator.of(context).pop({
                        'item_code': it['item_code'] as String,
                        'uom': it['uom'] as String?,
                      }),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
