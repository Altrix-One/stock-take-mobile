import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:stock_count/hr/services/hrms_api_client.dart';

class ProfileService {
  // Resolve the current Employee ID for the logged-in user.
  // Order of resolution:
  // 1) Cached in Hive authBox under key 'employee'
  // 2) Present in userDetails JSON under key 'employee'
  // 3) Lookup Employee by user_id (email/user) via REST and cache
  static Future<String?> currentEmployee() async {
    try {
      if (!Hive.isBoxOpen('authBox')) await Hive.openBox('authBox');
      final box = Hive.box('authBox');

      final cached = box.get('employee');
      if (cached is String && cached.isNotEmpty) return cached;

      final raw = box.get('userDetails');
      if (raw is String && raw.isNotEmpty) {
        try {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          final fromProfile = m['employee']?.toString();
          if (fromProfile != null && fromProfile.isNotEmpty) {
            await box.put('employee', fromProfile);
            return fromProfile;
          }
          // Try common fields
          final email = (m['email'] ?? m['preferred_username'] ?? m['sub'])?.toString();
          if (email != null && email.isNotEmpty) {
            final resolved = await _lookupEmployeeByUserId(email);
            if (resolved != null) {
              await box.put('employee', resolved);
              return resolved;
            }
          }
        } catch (_) {}
      }

      // As a last resort, if we have userId separately
      final userId = box.get('userId');
      if (userId is String && userId.isNotEmpty) {
        final resolved = await _lookupEmployeeByUserId(userId);
        if (resolved != null) {
          await box.put('employee', resolved);
          return resolved;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> _lookupEmployeeByUserId(String userId) async {
    try {
      // GET /api/resource/Employee?fields=["name"]&filters=[["Employee","user_id","=","user@domain.com"]]&limit=1
      final res = await HrmsApiClient.getJson(
        '/api/resource/Employee',
        query: {
          'fields': '["name"]',
          'filters': '[["Employee","user_id","=","$userId"]]',
          'limit': '1',
        },
      );
      final data = res['data'];
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map && first['name'] != null) return first['name'].toString();
      }
    } catch (_) {}
    return null;
  }
}