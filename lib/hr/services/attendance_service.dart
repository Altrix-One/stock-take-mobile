import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';

class AttendanceService {
  static Future<List<dynamic>> myAttendanceRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_attendance_requests', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> myShiftRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> teamShiftRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests',
          params: { 'for_approval': 1, if (emp != null) 'employee': emp });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> teamAttendanceRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_attendance_requests',
          params: { 'for_approval': 1, if (emp != null) 'employee': emp });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> upcomingShifts() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_shifts', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> shiftTypes() async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_types');
      final msg = res['message'];
      if (msg is List && msg.isNotEmpty) return msg;
    } catch (_) {}
    // Fallback to resource API
    try {
      final r = await HrmsApiClient.getJson('/api/resource/Shift%20Type', query: {
        'fields': '["name"]',
        'limit': '100',
        'order_by': 'name asc',
      });
      final data = r['data'];
      if (data is List) return data.map((e) => e is Map ? e['name'] ?? e.toString() : e.toString()).toList();
    } catch (_) {}
    // Final fallback to common shift types
    return [
      'Day Shift (9:00 AM - 5:00 PM)',
      'Evening Shift (2:00 PM - 10:00 PM)',
      'Night Shift (10:00 PM - 6:00 AM)',
      'Flexible Shift',
      'Other',
    ];
  }
  static Future<Map<String, dynamic>> submitAttendanceRequest(Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod('hrms.api.submit_attendance_request', params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> submitShiftRequest(Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod('hrms.api.submit_shift_request', params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> approvalAction({required String doctype, required String name, required bool approve, String? comment}) async {
    final res = await HrmsApiClient.postMethod('hrms.api.approval_action', params: {
      'doctype': doctype,
      'name': name,
      'approve': approve ? 1 : 0,
      if (comment != null) 'comment': comment,
    });
    return res['message'] as Map<String, dynamic>? ?? {};
  }
}
