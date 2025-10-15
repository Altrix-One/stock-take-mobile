// Test script to validate the new API endpoint calls
// This helps verify that all endpoints are correctly formatted before server installation

import 'package:flutter/material.dart';
import 'package:stock_count/hr/services/attendance_service.dart';
import 'package:stock_count/hr/services/leaves_service.dart';
import 'package:stock_count/hr/services/claims_service.dart';
import 'package:stock_count/hr/services/approvals_service.dart';

class ApiEndpointTest {
  static void printEndpointSummary() {
    print('=== API Endpoint Summary ===');
    print('');

    print('ATTENDANCE ENDPOINTS:');
    print('  • nex_bridge.api.hrms.attendance.checkin');
    print('  • nex_bridge.api.hrms.attendance.checkout');
    print('  • nex_bridge.api.hrms.attendance.get_attendance_history');
    print('  • nex_bridge.api.hrms.attendance.get_attendance_requests');
    print('  • nex_bridge.api.hrms.attendance.get_shifts');
    print('  • nex_bridge.api.hrms.attendance.get_shift_types');
    print('');

    print('LEAVES ENDPOINTS:');
    print('  • nex_bridge.api.hrms.leaves.get_leave_applications');
    print('  • nex_bridge.api.hrms.leaves.get_leave_balance_map');
    print('  • nex_bridge.api.hrms.leaves.get_leave_types');
    print('  • nex_bridge.api.hrms.leaves.submit_leave_application');
    print('');

    print('CLAIMS ENDPOINTS:');
    print('  • nex_bridge.api.hrms.claims.get_expense_claim_summary');
    print('  • nex_bridge.api.hrms.claims.get_expense_claims');
    print('  • nex_bridge.api.hrms.claims.get_expense_claim_types');
    print('  • nex_bridge.api.hrms.claims.submit_expense_claim');
    print('');

    print('APPROVALS ENDPOINTS:');
    print('  • nex_bridge.api.hrms.approvals.pending_approvals');
    print('  • nex_bridge.api.hrms.approvals.my_approvals');
    print('  • nex_bridge.api.hrms.approvals.team_members');
    print('  • nex_bridge.api.hrms.approvals.approvals_stats');
    print('  • nex_bridge.api.hrms.approvals.approve_request');
    print('  • nex_bridge.api.hrms.approvals.reject_request');
    print('');

    print('NEXT STEPS:');
    print('1. Install the Nex Bridge API files on your Frappe server');
    print('2. Test each endpoint individually');
    print('3. Configure employee user linking');
    print('4. Set up leave types and expense claim types');
    print('5. Test the mobile app with real data');
    print('');

    print('=== Current Status ===');
    print('✅ Mobile app services updated to use Nex Bridge APIs');
    print('⏳ Server APIs need to be installed (see INSTALLATION.md)');
    print('⏳ Employee user linking needs configuration');
    print('⏳ Leave types and expense types need setup');
  }

  static Future<void> testEndpointConnectivity() async {
    print('=== Testing API Connectivity ===');
    print('');

    // Test attendance endpoints
    print('Testing Attendance APIs...');
    try {
      await AttendanceService.myAttendanceHistory();
      print('  ✅ Attendance history endpoint accessible');
    } catch (e) {
      print('  ❌ Attendance history endpoint error: $e');
    }

    try {
      await AttendanceService.shiftTypes();
      print('  ✅ Shift types endpoint accessible');
    } catch (e) {
      print('  ❌ Shift types endpoint error: $e');
    }

    // Test leaves endpoints
    print('');
    print('Testing Leaves APIs...');
    try {
      await LeavesService.myLeaves();
      print('  ✅ My leaves endpoint accessible');
    } catch (e) {
      print('  ❌ My leaves endpoint error: $e');
    }

    try {
      await LeavesService.leaveBalance();
      print('  ✅ Leave balance endpoint accessible');
    } catch (e) {
      print('  ❌ Leave balance endpoint error: $e');
    }

    try {
      await LeavesService.leaveTypes();
      print('  ✅ Leave types endpoint accessible');
    } catch (e) {
      print('  ❌ Leave types endpoint error: $e');
    }

    // Test claims endpoints
    print('');
    print('Testing Claims APIs...');
    try {
      await ClaimsService.myClaims();
      print('  ✅ My claims endpoint accessible');
    } catch (e) {
      print('  ❌ My claims endpoint error: $e');
    }

    try {
      await ClaimsService.claimTypes();
      print('  ✅ Claim types endpoint accessible');
    } catch (e) {
      print('  ❌ Claim types endpoint error: $e');
    }

    // Test approvals endpoints
    print('');
    print('Testing Approvals APIs...');
    try {
      await ApprovalsService.pendingApprovals();
      print('  ✅ Pending approvals endpoint accessible');
    } catch (e) {
      print('  ❌ Pending approvals endpoint error: $e');
    }

    try {
      await ApprovalsService.approvalsStats();
      print('  ✅ Approvals stats endpoint accessible');
    } catch (e) {
      print('  ❌ Approvals stats endpoint error: $e');
    }

    print('');
    print('=== Test Complete ===');
    print(
        'If you see ❌ errors, it means the Nex Bridge APIs are not installed on your server yet.');
    print('Install them following the INSTALLATION.md guide, then re-test.');
  }
}

class ApiTestWidget extends StatelessWidget {
  const ApiTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Endpoint Test'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'API Endpoint Testing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This screen helps test the new Nex Bridge HRMS API endpoints.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ApiEndpointTest.printEndpointSummary();
              },
              child: const Text('Print Endpoint Summary'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ApiEndpointTest.testEndpointConnectivity();
              },
              child: const Text('Test API Connectivity'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check your debug console for test results.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
