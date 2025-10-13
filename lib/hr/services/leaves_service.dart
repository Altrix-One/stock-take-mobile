import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/utilis/outbox_queue.dart';

class LeavesService {
  static Future<List<dynamic>> myLeaves() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found');
        return [];
      }
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_applications', params: {
        'employee': emp,
        'limit': 100,
      });
      
      final list = (res['message'] as List<dynamic>? ?? []).toList();
      
      // Optimistically append queued local leaves
      try {
        final queued = await OutboxQueue.pendingLeaveRows();
        if (queued.isNotEmpty) list.insertAll(0, queued);
      } catch (e) {
        print('Error getting queued leaves: $e');
      }
      
      return list;
    } catch (e) {
      print('Error getting leave applications: $e');
      // Final fallback: only queued items
      try {
        return await OutboxQueue.pendingLeaveRows();
      } catch (_) {
        return [];
      }
    }
  }

  static Future<List<dynamic>> teamLeaves() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_applications', params: {
        'employee': emp,
        'for_approval': true,
        'limit': 100,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting team leaves: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> leaveBalance() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found for leave balance');
        return {};
      }
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_balance_map', params: {
        'employee': emp,
      });
      
      return (res['message'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      print('Error getting leave balance: $e');
      return {};
    }
  }

  static Future<List<dynamic>> leaveTypes() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found for leave types');
        return [];
      }
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_types', params: {
        'employee': emp,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
      
      return (res['message'] as List<dynamic>? ?? []);
    } catch (e) {
      print('Error getting leave types: $e');
      return [];
    }
  }
  static Future<Map<String, dynamic>> getLeaveApprovalDetails(String employee) async {
    final res = await HrmsApiClient.postMethod('hrms.api.get_leave_approval_details', params: {
      'employee': employee,
    });
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<double> getNumberOfLeaveDays({required String fromDate, required String toDate, required String leaveType, String? employee, bool halfDay=false, String? halfDayDate}) async {
    final res = await HrmsApiClient.postMethod('hrms.hr.doctype.leave_application.leave_application.get_number_of_leave_days', params: {
      'from_date': fromDate,
      'to_date': toDate,
      'leave_type': leaveType,
      if (employee != null) 'employee': employee,
      if (halfDay) 'half_day': 1,
      if (halfDay && halfDayDate != null) 'half_day_date': halfDayDate,
    });
    final msg = res['message'];
    if (msg is num) return msg.toDouble();
    if (msg is String) return double.tryParse(msg) ?? 0;
    return 0;
  }

  static Future<double> getLeaveBalanceOn({required String date, required String leaveType, String? employee}) async {
    final res = await HrmsApiClient.postMethod('hrms.hr.doctype.leave_application.leave_application.get_leave_balance_on', params: {
      'date': date,
      'leave_type': leaveType,
      if (employee != null) 'employee': employee,
    });
    final msg = res['message'];
    if (msg is num) return msg.toDouble();
    if (msg is String) return double.tryParse(msg) ?? 0;
    return 0;
  }

  // Submit leave application via standard Frappe API
  static Future<Map<String, dynamic>> submitLeaveApplication(Map<String, dynamic> payload) async {
    try {
      print('Attempting to submit leave application with payload: $payload');
      
      // Create the leave application document
      final createRes = await HrmsApiClient.postMethod('frappe.client.save', params: {
        'doc': {
          'doctype': 'Leave Application',
          'employee': payload['employee'],
          'leave_type': payload['leave_type'],
          'from_date': payload['from_date'],
          'to_date': payload['to_date'],
          'total_leave_days': payload['total_leave_days'],
          'description': payload['description'] ?? '',
          if (payload['half_day'] == true) 'half_day': 1,
          if (payload['half_day_date'] != null) 'half_day_date': payload['half_day_date'],
        }
      });
      
      final docName = createRes['message']?['name'];
      if (docName == null) {
        return {'success': false, 'message': 'Failed to create leave application'};
      }
      
      // Submit the document
      await HrmsApiClient.postMethod('frappe.client.submit', params: {
        'doc': {
          'doctype': 'Leave Application',
          'name': docName,
        }
      });
      
      print('Successfully submitted leave application: $docName');
      return {
        'success': true,
        'name': docName,
        'message': 'Leave application submitted successfully',
      };
    } catch (e) {
      print('Error submitting leave application: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> cancelLeaveApplication(String name, {String? reason}) async {
    // Try dedicated HRMS endpoint first
    try {
      await HrmsApiClient.postMethod('hrms.api.cancel_leave_application', params: {
        'name': name,
        if (reason != null) 'reason': reason,
      });
      return;
    } catch (_) {}
    // Fallback to generic Frappe cancel
    await HrmsApiClient.postMethod('frappe.client.cancel', params: {
      'doctype': 'Leave Application',
      'name': name,
    });
  }

  // Resolve the document name of a leave application when lists don't include it
  static Future<String?> resolveLeaveName({required String leaveType, required String fromDate, required String toDate, String? employee}) async {
    try {
      final emp = employee ?? await ProfileService.currentEmployee();
      final r = await HrmsApiClient.getJson('/api/resource/Leave%20Application', query: {
        'fields': '["name","status"]',
        'filters': '[ ["Leave Application","leave_type","=","$leaveType"], ["Leave Application","from_date","=","$fromDate"], ["Leave Application","to_date","=","$toDate"]${emp!=null?',["Leave Application","employee","=","$emp"]':''} ]',
        'order_by': 'modified desc',
        'limit': '1',
      });
      final data = r['data'];
      if (data is List && data.isNotEmpty) {
        final m = data.first;
        if (m is Map && m['name'] != null) return m['name'].toString();
      }
    } catch (_) {}
    return null;
  }

  // Fetch server balances and overlay pending queued leave applications locally so UI reflects immediately
  static Future<Map<String, dynamic>> leaveBalanceWithPending() async {
    final base = await leaveBalance();
    try {
      final pending = await OutboxQueue.pendingLeaveByType();
      pending.forEach((lt, days) {
        final map = (base[lt] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final used = (map['leaves_taken'] is num) ? (map['leaves_taken'] as num).toDouble() : double.tryParse('${map['leaves_taken']}') ?? 0;
        final bal = (map['balance_leaves'] is num) ? (map['balance_leaves'] as num).toDouble() : double.tryParse('${map['balance_leaves']}') ?? 0;
        map['leaves_taken'] = (used + days);
        map['balance_leaves'] = (bal - days);
        base[lt] = map;
      });
    } catch (_) {}
    return base;
  }

  // Apply leave method for the modern leaves page - submit directly when online
  static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> payload) async {
    print('ApplyLeave called with payload: $payload');
    
    // Try to submit immediately if online
    try {
      final result = await submitLeaveApplication(payload);
      print('SubmitLeaveApplication result: $result');
      
      // If successful, return the result immediately
      if (result['success'] == true) {
        return {
          'success': true, 
          'message': 'Leave application submitted successfully',
          'data': result,
        };
      }
      
      // If not successful, queue for offline processing
      print('Direct submission failed, queuing for later submission...');
      await OutboxQueue.addOperation('leave_application', payload);
      return {
        'success': true, 
        'message': 'Leave application queued for submission',
        'queued': true,
      };
    } catch (e) {
      print('Leave submission failed: $e');
      
      // Queue for offline processing as fallback
      try {
        print('Queuing leave application for offline submission...');
        await OutboxQueue.addOperation('leave_application', payload);
        return {
          'success': true, 
          'message': 'Leave application queued for submission (offline)',
          'queued': true,
        };
      } catch (queueError) {
        print('Failed to queue leave application: $queueError');
        return {
          'success': false, 
          'message': 'Failed to submit leave application: $e',
        };
      }
    }
  }
}
