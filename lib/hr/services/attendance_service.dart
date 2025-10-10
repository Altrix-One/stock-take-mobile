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
