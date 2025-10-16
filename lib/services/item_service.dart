import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:cohenix_ess/config.dart';

class ItemService {
  static Future<List<Map<String, dynamic>>> searchItems(String query,
      {int limit = 50}) async {
    final authBox = Hive.box('authBox');
    final token = authBox.get('accessToken');
    if (token == null) throw Exception('Not authenticated');

    final baseUrl = await AppConfig.baseUrl;

    final fields = jsonEncode(["name", "item_name", "stock_uom"]);
    final filters = jsonEncode([
      ["Item", "disabled", "=", 0],
      ["Item", "has_variants", "=", 0]
    ]);
    final orFilters = jsonEncode([
      ["Item", "name", "like", "%$query%"],
      ["Item", "item_name", "like", "%$query%"]
    ]);

    final uri = Uri.parse('$baseUrl/api/method/frappe.client.get_list').replace(
      queryParameters: {
        'doctype': 'Item',
        'fields': fields,
        'filters': filters,
        'or_filters': orFilters,
        'limit_page_length': limit.toString(),
        'order_by': 'modified desc',
      },
    );

    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['message'] as List).cast<Map<String, dynamic>>();
      return data
          .map((e) => {
                'item_code': e['name'],
                'item_name': e['item_name'],
                'uom': e['stock_uom'],
              })
          .toList();
    }
    throw Exception('Item search failed: ${res.statusCode} ${res.body}');
  }
}
