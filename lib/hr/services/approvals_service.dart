import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/hr/services/attendance_service.dart';

class ApprovalsService {
  static Future<List<dynamic>> pendingApprovals() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      // Get pending approvals from all modules
      final results = await Future.wait([
        LeavesService.teamLeaves(),
        ClaimsService.teamClaims(),
        AttendanceService.teamAttendanceRequests(),
        AttendanceService.teamShiftRequests(),
      ]);
      
      final allApprovals = <dynamic>[];
      for (final result in results) {
        if (result is List) {
          allApprovals.addAll(result);
        }
      }
      
      return allApprovals;
    } catch (e) {
      print('Error getting pending approvals: $e');
      return [];
    }
  }

  static Future<List<dynamic>> myApprovals() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      // Get user's own submissions from all modules
      final results = await Future.wait([
        LeavesService.myLeaves(),
        ClaimsService.myClaims(),
        AttendanceService.myAttendanceRequests(),
        AttendanceService.myShiftRequests(),
      ]);
      
      final allMyItems = <dynamic>[];
      for (final result in results) {
        if (result is List) {
          allMyItems.addAll(result);
        }
      }
      
      return allMyItems;
    } catch (e) {
      print('Error getting my approvals: $e');
      return [];
    }
  }

  static Future<List<dynamic>> teamMembers() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_all_employees');
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting team members: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> approvalsStats() async {
    try {
      final pendingItems = await pendingApprovals();
      final myItems = await myApprovals();
      
      // Calculate stats from the data we have
      int totalPending = pendingItems.length;
      int totalSubmitted = myItems.length;
      int approved = 0;
      int rejected = 0;
      
      for (final item in myItems) {
        if (item is Map) {
          final status = item['status']?.toString().toLowerCase();
          if (status == 'approved') {
            approved++;
          } else if (status == 'rejected') {
            rejected++;
          }
        }
      }
      
      return {
        'total_pending': totalPending,
        'total_submitted': totalSubmitted,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      print('Error getting approvals stats: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> approveRequest(String doctype, String name, {String? comments}) async {
    try {
      // Use Frappe's workflow API to approve
      final res = await HrmsApiClient.postMethod('frappe.client.set_value', params: {
        'doctype': doctype,
        'name': name,
        'fieldname': 'status',
        'value': 'Approved',
      });
      
      // If there are comments, add them
      if (comments != null && comments.isNotEmpty) {
        await HrmsApiClient.postMethod('frappe.client.set_value', params: {
          'doctype': doctype,
          'name': name,
          'fieldname': 'remarks',
          'value': comments,
        });
      }
      
      return {
        'success': true,
        'message': 'Request approved successfully',
      };
    } catch (e) {
      print('Error approving request: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> rejectRequest(String doctype, String name, {String? reason}) async {
    try {
      // Use Frappe's workflow API to reject
      final res = await HrmsApiClient.postMethod('frappe.client.set_value', params: {
        'doctype': doctype,
        'name': name,
        'fieldname': 'status',
        'value': 'Rejected',
      });
      
      // If there's a reason, add it
      if (reason != null && reason.isNotEmpty) {
        await HrmsApiClient.postMethod('frappe.client.set_value', params: {
          'doctype': doctype,
          'name': name,
          'fieldname': 'remarks',
          'value': reason,
        });
      }
      
      return {
        'success': true,
        'message': 'Request rejected successfully',
      };
    } catch (e) {
      print('Error rejecting request: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}