import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:stock_count/config.dart';
import 'package:stock_count/utilis/auth_service.dart';

class HrmsApiClient {
  static Future<String> _baseUrl() async => await AppConfig.baseUrl;

  static Future<String?> _token() async {
    if (!Hive.isBoxOpen('authBox')) await Hive.openBox('authBox');
    return Hive.box('authBox').get('accessToken');
  }

  static Future<Map<String, dynamic>> postMethod(String method,
      {Map<String, dynamic>? params}) async {
    Future<http.Response> doPost(String bearer) async {
      final base = await _baseUrl();
      final uri = Uri.parse('$base/api/method/$method');
      return http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $bearer',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(params ?? {}),
      );
    }

    var token = await _token();
    if (token == null) {
      final refreshed = await AuthService.refreshTokenIfNeeded(force: true);
      if (refreshed) token = await _token();
      if (token == null) throw Exception('Not authenticated');
    }
    var res = await doPost(token);
    if (res.statusCode == 401) {
      final ok = await AuthService.refreshTokenIfNeeded(force: true);
      if (ok) {
        final newToken = await _token();
        if (newToken != null) res = await doPost(newToken);
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('HRMS API error ${res.statusCode}: ${res.body}');
  }

  static Future<Map<String, dynamic>> getJson(String path,
      {Map<String, String>? query}) async {
    Future<http.Response> doGet(String bearer) async {
      final base = await _baseUrl();
      final uri = Uri.parse('$base$path').replace(queryParameters: query);
      return http.get(uri, headers: {'Authorization': 'Bearer $bearer'});
    }

    var token = await _token();
    if (token == null) {
      final refreshed = await AuthService.refreshTokenIfNeeded(force: true);
      if (refreshed) token = await _token();
      if (token == null) throw Exception('Not authenticated');
    }
    var res = await doGet(token);
    if (res.statusCode == 401) {
      final ok = await AuthService.refreshTokenIfNeeded(force: true);
      if (ok) {
        final newToken = await _token();
        if (newToken != null) res = await doGet(newToken);
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed ${res.statusCode}: ${res.body}');
  }

  /// Fetch field options for a specific doctype field
  /// This can be used to get dropdown options from Frappe backend dynamically
  static Future<List<String>> getFieldOptions(
      String doctype, String fieldname) async {
    try {
      // Try to get from doctype meta first (which includes select options)
      final meta = await postMethod('frappe.client.get_meta', params: {
        'doctype': doctype,
      });

      if (meta['message'] is Map) {
        final fields = meta['message']['fields'] as List<dynamic>? ?? [];
        for (final field in fields) {
          if (field is Map && field['fieldname'] == fieldname) {
            final options = field['options']?.toString();
            if (options != null && options.isNotEmpty) {
              return options
                  .split('\n')
                  .where((option) => option.trim().isNotEmpty)
                  .map((option) => option.trim())
                  .toList();
            }
            break;
          }
        }
      }
    } catch (e) {
      print('Error fetching field options for $doctype.$fieldname: $e');
    }

    // Return empty list if no options found
    return [];
  }

  /// Get list of values from a doctype (like getting all Leave Types, Shift Types, etc.)
  static Future<List<String>> getDocTypeValues(String doctype,
      {String nameField = 'name', String? filters, int limit = 100}) async {
    try {
      final result = await getJson('/api/resource/$doctype', query: {
        'fields': '["$nameField"]',
        if (filters != null) 'filters': filters,
        'limit': limit.toString(),
        'order_by': '$nameField asc',
      });

      final data = result['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => item is Map ? (item[nameField]?.toString() ?? '') : '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error fetching $doctype values: $e');
      return [];
    }
  }
}
