import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:cohenix_ess/config.dart';

class StockService {
  // Create/submit a Stock Entry via Nex Bridge
  // payload shape expectation:
  // {
  //   "type": "Material Transfer" | "Material Issue" | "Material Receipt",
  //   "company": "...",
  //   "from_warehouse": "...",
  //   "to_warehouse": "...",
  //   "posting_date": "YYYY-MM-DD",
  //   "posting_time": "HH:MM:SS",
  //   "items": [
  //     {"item_code": "...", "barcode": "...", "qty": 1, "uom": "Nos", "warehouse": "...", "batch_no": null, "serial_nos": []}
  //   ]
  // }
  static Future<Map<String, dynamic>> pushStockEntry(
      Map<String, dynamic> payload) async {
    final authBox = Hive.box('authBox');
    final accessToken = authBox.get('accessToken');
    if (accessToken == null) throw Exception('Not authenticated');

    final baseUrl = await AppConfig.baseUrl;
    final uri = Uri.parse(
        '$baseUrl/api/method/nex_bridge.api.stock.create_stock_entry');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Stock entry push failed: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> createReconciliation(
      Map<String, dynamic> payload) async {
    final authBox = Hive.box('authBox');
    final accessToken = authBox.get('accessToken');
    if (accessToken == null) throw Exception('Not authenticated');

    final baseUrl = await AppConfig.baseUrl;
    final uri = Uri.parse(
        '$baseUrl/api/method/nex_bridge.api.stock.create_reconciliation');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception(
        'Reconciliation create failed: ${res.statusCode} ${res.body}');
  }
}
