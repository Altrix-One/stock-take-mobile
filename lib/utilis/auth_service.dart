import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:stock_count/config.dart';

class AuthService {
  static Future<Box> _box() async {
    if (!Hive.isBoxOpen('authBox')) {
      return await Hive.openBox('authBox');
    }
    return Hive.box('authBox');
  }

  static Future<String> _baseUrl() async => await AppConfig.baseUrl;
  static Future<String> _tokenEndpoint() async => AppConfig.tokenEndpoint; // path
  static Future<String> _clientId() async => await AppConfig.clientId;
  static String _redirectUri() => AppConfig.redirectUri;

  // Refresh access token if expired or when forced. Returns true if refreshed successfully.
  static Future<bool> refreshTokenIfNeeded({bool force = false}) async {
    final box = await _box();
    final String? accessToken = box.get('accessToken');
    final DateTime? tokenExpiry = DateTime.tryParse(box.get('tokenExpiry') ?? '');
    final String? refreshToken = box.get('refreshToken');

    final bool isExpired = tokenExpiry == null || DateTime.now().isAfter(tokenExpiry);
    if (!force && accessToken != null && !isExpired) {
      return false; // Still valid
    }
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final base = await _baseUrl();
      final tokenPath = await _tokenEndpoint();
      final clientId = await _clientId();
      final res = await http.post(
        Uri.parse('$base$tokenPath'),
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          'redirect_uri': _redirectUri(),
        },
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccess = data['access_token']?.toString();
        final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 0;
        if (newAccess != null && newAccess.isNotEmpty) {
          await box.put('accessToken', newAccess);
          if (expiresIn > 0) {
            await box.put('tokenExpiry', DateTime.now().add(Duration(seconds: expiresIn)).toString());
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}