import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';

class ApprovalsService {
  static Future<List<dynamic>> pendingApprovals() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_pending_approvals', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> myApprovals() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_my_approvals', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> teamMembers() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_team_members', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> approvalsStats() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_approvals_stats', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> approveRequest(String requestId) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.approve_request', params: {
        'request_id': requestId,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> rejectRequest(String requestId, String reason) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.reject_request', params: {
        'request_id': requestId,
        'reason': reason,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}