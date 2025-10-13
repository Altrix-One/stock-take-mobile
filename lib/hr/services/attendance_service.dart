import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';

class AttendanceService {
  static Future<List<dynamic>> myAttendanceRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found for attendance requests');
        return [];
      }
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_attendance_requests', params: {
        'employee': emp,
        'limit': 50,
      });
      
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting attendance requests: $e');
      return [];
    }
  }

  static Future<List<dynamic>> myShiftRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests', params: {
        'employee': emp,
        'limit': 50,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting shift requests: $e');
      return [];
    }
  }

  static Future<List<dynamic>> teamShiftRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests', params: {
        'employee': emp,
        'for_approval': true,
        'limit': 50,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting team shift requests: $e');
      return [];
    }
  }

  static Future<List<dynamic>> teamAttendanceRequests() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_attendance_requests', params: {
        'employee': emp,
        'for_approval': true,
        'limit': 50,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting team attendance requests: $e');
      return [];
    }
  }

  static Future<List<dynamic>> upcomingShifts() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final res = await HrmsApiClient.postMethod('hrms.api.get_shifts', params: {
        'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting shifts: $e');
      return [];
    }
  }

  static Future<List<dynamic>> shiftTypes() async {
    try {
      // Get shift types from Frappe directly
      final result = await HrmsApiClient.getJson('/api/resource/Shift Type', query: {
        'fields': '["name","start_time","end_time"]',
        'filters': '[["Shift Type", "disabled", "!=", 1]]',
        'limit': '50',
      });
      
      final data = result['data'] as List<dynamic>? ?? [];
      if (data.isNotEmpty) {
        return data.map((item) => (item as Map)['name']?.toString() ?? '').toList();
      }
    } catch (e) {
      print('Error getting shift types: $e');
    }
    
    return [];
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

  // Get attendance history for the modern attendance page
  static Future<List<dynamic>> myAttendanceHistory() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];
      
      final fromDate = DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
      final toDate = DateTime.now().toIso8601String().split('T')[0];
      
      final result = await HrmsApiClient.postMethod('hrms.api.get_attendance_calendar_events', params: {
        'employee': emp,
        'from_date': fromDate,
        'to_date': toDate,
      });
      
      // Convert calendar events to attendance history format
      final events = result['message'] as Map<String, dynamic>? ?? {};
      final attendanceList = <Map<String, dynamic>>[];
      
      events.forEach((date, status) {
        attendanceList.add({
          'attendance_date': date,
          'status': status,
          'employee': emp,
        });
      });
      
      return attendanceList;
    } catch (e) {
      print('Error getting attendance history: $e');
      return [];
    }
  }

  // Check in method for attendance - creates Employee Checkin record
  static Future<Map<String, dynamic>> checkIn() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        return {'success': false, 'message': 'No employee found'};
      }
      
      final res = await HrmsApiClient.postMethod('frappe.client.save', params: {
        'doc': {
          'doctype': 'Employee Checkin',
          'employee': emp,
          'log_type': 'IN',
          'time': DateTime.now().toIso8601String(),
        }
      });
      
      return {
        'success': true,
        'message': 'Checked in successfully',
        'name': res['message']?['name'],
      };
    } catch (e) {
      print('Check-in error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check out method for attendance - creates Employee Checkin record
  static Future<Map<String, dynamic>> checkOut() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        return {'success': false, 'message': 'No employee found'};
      }
      
      final res = await HrmsApiClient.postMethod('frappe.client.save', params: {
        'doc': {
          'doctype': 'Employee Checkin',
          'employee': emp,
          'log_type': 'OUT',
          'time': DateTime.now().toIso8601String(),
        }
      });
      
      return {
        'success': true,
        'message': 'Checked out successfully',
        'name': res['message']?['name'],
      };
    } catch (e) {
      print('Check-out error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Request shift change
  static Future<Map<String, dynamic>> requestShiftChange(Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.request_shift_change', params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Get today's checkin status to show current state in UI
  static Future<Map<String, dynamic>> getTodayAttendanceStatus() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return {'checkedIn': false};
      
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Get today's Employee Checkin records
      final checkins = await HrmsApiClient.getJson('/api/resource/Employee%20Checkin', query: {
        'fields': '["name","employee","time","log_type"]',
        'filters': '[["Employee Checkin","employee","=","$emp"],["Employee Checkin","time","like","$today%"]]',
        'order_by': 'time desc',
        'limit': '10',
      });
      
      final checkinData = checkins['data'] as List<dynamic>? ?? [];
      
      bool checkedIn = false;
      String? lastCheckinTime;
      String? lastCheckoutTime;
      
      // Process checkin records to determine current status
      for (final record in checkinData) {
        if (record is Map) {
          final logType = record['log_type']?.toString();
          final time = record['time']?.toString();
          
          if (logType == 'IN' && lastCheckinTime == null) {
            lastCheckinTime = time;
            checkedIn = true;
          } else if (logType == 'OUT' && lastCheckoutTime == null) {
            lastCheckoutTime = time;
            if (lastCheckinTime == null) {
              checkedIn = false;
            } else {
              // Compare times to see which was most recent
              final checkinDateTime = DateTime.tryParse(lastCheckinTime);
              final checkoutDateTime = DateTime.tryParse(time ?? '');
              if (checkinDateTime != null && checkoutDateTime != null) {
                checkedIn = checkinDateTime.isAfter(checkoutDateTime);
              }
            }
          }
        }
      }
      
      return {
        'checkedIn': checkedIn,
        'lastCheckinTime': lastCheckinTime,
        'lastCheckoutTime': lastCheckoutTime,
        'todayCheckins': checkinData.length,
      };
    } catch (e) {
      print('Error getting today\'s attendance status: $e');
      return {'checkedIn': false};
    }
  }
}
