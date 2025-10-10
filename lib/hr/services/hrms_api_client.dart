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
}
