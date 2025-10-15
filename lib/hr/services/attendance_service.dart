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

      final res = await HrmsApiClient.postMethod(
          'hrms.api.get_attendance_requests',
          params: {
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

      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests',
          params: {
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

      final res = await HrmsApiClient.postMethod('hrms.api.get_shift_requests',
          params: {
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

      final res = await HrmsApiClient.postMethod(
          'hrms.api.get_attendance_requests',
          params: {
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

      final res =
          await HrmsApiClient.postMethod('hrms.api.get_shifts', params: {
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
      final result =
          await HrmsApiClient.getJson('/api/resource/Shift Type', query: {
        'fields': '["name","start_time","end_time"]',
        'filters': '[["Shift Type", "disabled", "!=", 1]]',
        'limit': '50',
      });

      final data = result['data'] as List<dynamic>? ?? [];
      if (data.isNotEmpty) {
        return data
            .map((item) => (item as Map)['name']?.toString() ?? '')
            .toList();
      }
    } catch (e) {
      print('Error getting shift types: $e');
    }

    return [];
  }

  static Future<Map<String, dynamic>> submitAttendanceRequest(
      Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod(
        'hrms.api.submit_attendance_request',
        params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> submitShiftRequest(
      Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod('hrms.api.submit_shift_request',
        params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> approvalAction(
      {required String doctype,
      required String name,
      required bool approve,
      String? comment}) async {
    final res =
        await HrmsApiClient.postMethod('hrms.api.approval_action', params: {
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

      final fromDate = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .split('T')[0];
      final toDate = DateTime.now().toIso8601String().split('T')[0];

      // Get Employee Checkin records for actual check-in/check-out history
      final result =
          await HrmsApiClient.getJson('/api/resource/Employee Checkin', query: {
        'fields': '["name","employee","time","log_type","creation"]',
        'filters':
            '[["Employee Checkin","employee","=","$emp"],["Employee Checkin","time",">=","$fromDate"],["Employee Checkin","time","<=","$toDate 23:59:59"]]',
        'order_by': 'time desc',
        'limit': '100',
      });

      final checkins = result['data'] as List<dynamic>? ?? [];

      // Group checkins by date for better display
      final groupedCheckins = <String, List<Map<String, dynamic>>>{};
      for (final checkin in checkins) {
        if (checkin is Map<String, dynamic>) {
          final time = checkin['time']?.toString();
          if (time != null) {
            final date = DateTime.parse(time).toIso8601String().split('T')[0];
            groupedCheckins[date] ??= [];
            groupedCheckins[date]!.add(checkin);
          }
        }
      }

      // Convert to attendance records with check-in/check-out pairs
      final attendanceRecords = <Map<String, dynamic>>[];
      groupedCheckins.forEach((date, dailyCheckins) {
        Map<String, dynamic>? checkIn;
        Map<String, dynamic>? checkOut;

        // Find the latest check-in and check-out for each day
        for (final checkin in dailyCheckins) {
          final logType = checkin['log_type']?.toString();
          if (logType == 'IN') {
            checkIn = checkin;
          } else if (logType == 'OUT') {
            checkOut = checkin;
          }
        }

        attendanceRecords.add({
          'date': date,
          'employee': emp,
          'check_in': checkIn?['time'],
          'check_out': checkOut?['time'],
          'status': checkIn != null ? 'Present' : 'No attendance data',
          'working_hours':
              _calculateWorkingHours(checkIn?['time'], checkOut?['time']),
          'checkin_records': dailyCheckins,
        });
      });

      return attendanceRecords;
    } catch (e) {
      print('Error getting attendance history: $e');
      return [];
    }
  }

  // Helper method to calculate working hours
  static double _calculateWorkingHours(
      String? checkInTime, String? checkOutTime) {
    if (checkInTime == null || checkOutTime == null) return 0.0;

    try {
      final checkIn = DateTime.parse(checkInTime);
      final checkOut = DateTime.parse(checkOutTime);
      final duration = checkOut.difference(checkIn);
      return duration.inMinutes / 60.0;
    } catch (e) {
      return 0.0;
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
  static Future<Map<String, dynamic>> requestShiftChange(
      Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod(
          'hrms.api.request_shift_change',
          params: payload);
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
      final checkins =
          await HrmsApiClient.getJson('/api/resource/Employee Checkin', query: {
        'fields': '["name","employee","time","log_type"]',
        'filters':
            '[["Employee Checkin","employee","=","$emp"],["Employee Checkin","time",">=","$today 00:00:00"],["Employee Checkin","time","<=","$today 23:59:59"]]',
        'order_by': 'time desc',
        'limit': '10',
      });

      final checkinData = checkins['data'] as List<dynamic>? ?? [];

      if (checkinData.isEmpty) {
        return {
          'checkedIn': false,
          'lastCheckinTime': null,
          'lastCheckoutTime': null,
          'todayCheckins': 0,
        };
      }

      // Sort records by time (most recent first)
      checkinData.sort((a, b) {
        final timeA = (a as Map)['time']?.toString() ?? '';
        final timeB = (b as Map)['time']?.toString() ?? '';
        return timeB.compareTo(timeA); // Descending order (most recent first)
      });

      String? lastCheckinTime;
      String? lastCheckoutTime;

      // Find the most recent check-in and check-out
      for (final record in checkinData) {
        if (record is Map) {
          final logType = record['log_type']?.toString();
          final time = record['time']?.toString();

          if (logType == 'IN' && lastCheckinTime == null) {
            lastCheckinTime = time;
          } else if (logType == 'OUT' && lastCheckoutTime == null) {
            lastCheckoutTime = time;
          }
        }
      }

      // Determine if currently checked in
      bool checkedIn = false;
      if (lastCheckinTime != null) {
        if (lastCheckoutTime == null) {
          // Have check-in but no check-out
          checkedIn = true;
        } else {
          // Compare which happened more recently
          final checkinDateTime = DateTime.tryParse(lastCheckinTime);
          final checkoutDateTime = DateTime.tryParse(lastCheckoutTime);
          if (checkinDateTime != null && checkoutDateTime != null) {
            checkedIn = checkinDateTime.isAfter(checkoutDateTime);
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

  // Calculate today's total working hours from all check-in/check-out pairs
  static Future<Duration> getTodayTotalWorkingHours() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return Duration.zero;

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get today's Employee Checkin records
      final checkins =
          await HrmsApiClient.getJson('/api/resource/Employee Checkin', query: {
        'fields': '["name","employee","time","log_type"]',
        'filters':
            '[["Employee Checkin","employee","=","$emp"],["Employee Checkin","time",">=","$today 00:00:00"],["Employee Checkin","time","<=","$today 23:59:59"]]',
        'order_by': 'time asc', // Ascending order for pairing
        'limit': '50',
      });

      final checkinData = checkins['data'] as List<dynamic>? ?? [];

      if (checkinData.isEmpty) {
        return Duration.zero;
      }

      // Sort records by time (oldest first for pairing)
      checkinData.sort((a, b) {
        final timeA = (a as Map)['time']?.toString() ?? '';
        final timeB = (b as Map)['time']?.toString() ?? '';
        return timeA.compareTo(timeB); // Ascending order
      });

      Duration totalWorked = Duration.zero;
      DateTime? currentCheckinTime;

      for (final record in checkinData) {
        if (record is Map) {
          final logType = record['log_type']?.toString();
          final timeStr = record['time']?.toString();

          if (timeStr == null) continue;

          final time = DateTime.tryParse(timeStr);
          if (time == null) continue;

          if (logType == 'IN') {
            // Start a new working session
            currentCheckinTime = time;
          } else if (logType == 'OUT' && currentCheckinTime != null) {
            // End the current working session
            final sessionDuration = time.difference(currentCheckinTime);
            totalWorked = totalWorked + sessionDuration;
            currentCheckinTime = null; // Reset for next session
          }
        }
      }

      // If currently checked in (no matching check-out), add time from last check-in to now
      if (currentCheckinTime != null) {
        final nowDuration = DateTime.now().difference(currentCheckinTime);
        totalWorked = totalWorked + nowDuration;
      }

      return totalWorked;
    } catch (e) {
      print('Error calculating today\'s working hours: $e');
      return Duration.zero;
    }
  }
}
