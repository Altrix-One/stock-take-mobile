import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';
import 'package:stock_count/utilis/outbox_queue.dart';

class LeavesService {
  static Future<List<dynamic>> myLeaves() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_applications', params: {
        if (emp != null) 'employee': emp,
      });
      final list = (res['message'] as List<dynamic>? ?? []).toList();
      // Optimistically append queued local leaves
      try {
        final queued = await OutboxQueue.pendingLeaveRows();
        if (queued.isNotEmpty) list.insertAll(0, queued);
      } catch (_) {}
      return list;
    } catch (_) {
      // Fall back to only queued items if server call fails
      try { return await OutboxQueue.pendingLeaveRows(); } catch (_) {}
      return [];
    }
  }

  static Future<List<dynamic>> teamLeaves() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_applications',
          params: { 'for_approval': 1, if (emp != null) 'employee': emp });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> leaveBalance() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_balance_map', params: {
        if (emp != null) 'employee': emp,
      });
      return (res['message'] as Map<String, dynamic>? ?? {});
    } catch (_) {
      return {};
    }
  }

  static Future<List<dynamic>> leaveTypes() async {
    // Some servers may scope leave types per employee; include if available
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_leave_types', params: {
        if (emp != null) 'employee': emp,
      });
      final msg = res['message'];
      if (msg is List && msg.isNotEmpty) return msg;
    } catch (_) {}
    // Fallback to resource API
    try {
      final r = await HrmsApiClient.getJson('/api/resource/Leave%20Type', query: {
        'fields': '["name"]',
        'limit': '100',
        'order_by': 'name asc',
      });
      final data = r['data'];
      if (data is List) return data.map((e) => e is Map ? e['name'] ?? e.toString() : e.toString()).toList();
    } catch (_) {}
    return [];
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

  // Submit leave application (create + optional submit) via a bridged method or direct resource API
  static Future<Map<String, dynamic>> submitLeaveApplication(Map<String, dynamic> payload) async {
    // Try dedicated HRMS endpoint (if present on the server)
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.submit_leave_application', params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      // Fallback: create via resource API then submit the document
      // Map app payload to Frappe doc fields
      final doc = <String, dynamic>{
        'doctype': 'Leave Application',
        if (payload['employee'] != null) 'employee': payload['employee'],
        if (payload['leave_type'] != null) 'leave_type': payload['leave_type'],
        if (payload['from_date'] != null) 'from_date': payload['from_date'],
        if (payload['to_date'] != null) 'to_date': payload['to_date'],
        if (payload['half_day'] == 1 || payload['half_day'] == true) 'half_day': 1,
        if (payload['half_day_date'] != null) 'half_day_date': payload['half_day_date'],
        if (payload['reason'] != null) 'description': payload['reason'],
      };
      // Insert draft
      final inserted = await HrmsApiClient.postMethod('frappe.client.insert', params: {
        'doc': doc,
      });
      final message = inserted['message'];
      final name = (message is Map && message['name'] != null) ? message['name'].toString() : null;
      if (name == null) return message as Map<String, dynamic>? ?? {};
      // Submit (frappe.client.submit requires a 'doc' payload)
      final submitted = await HrmsApiClient.postMethod('frappe.client.submit', params: {
        'doc': {
          'doctype': 'Leave Application',
          'name': name,
        }
      });
      return submitted['message'] as Map<String, dynamic>? ?? {};
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
}
