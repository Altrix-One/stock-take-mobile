import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';

class ClaimsService {
  static Future<Map<String, dynamic>> expenseClaimSummary() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found for expense claim summary');
        return {};
      }

      final res = await HrmsApiClient.postMethod(
          'hrms.api.get_expense_claim_summary',
          params: {
            'employee': emp,
          });

      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error getting expense claim summary: $e');
      return {};
    }
  }

  static Future<List<dynamic>> myClaims() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) {
        print('No current employee found for expense claims');
        return [];
      }

      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claims',
          params: {
            'employee': emp,
            'limit': 100,
          });

      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting expense claims: $e');
      return [];
    }
  }

  static Future<List<dynamic>> teamClaims() async {
    try {
      final emp = await ProfileService.currentEmployee();
      if (emp == null) return [];

      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claims',
          params: {
            'employee': emp,
            'for_approval': true,
            'limit': 100,
          });
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting team claims: $e');
      return [];
    }
  }

  static Future<List<dynamic>> claimTypes() async {
    try {
      final res =
          await HrmsApiClient.postMethod('hrms.api.get_expense_claim_types');
      return res['message'] as List<dynamic>? ?? [];
    } catch (e) {
      print('Error getting expense claim types: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getExpenseApprovalDetails(
      String employee) async {
    final res = await HrmsApiClient.postMethod(
        'hrms.api.get_expense_approval_details',
        params: {'employee': employee});
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> getCompanyAccounts(String company) async {
    final res = await HrmsApiClient.postMethod(
        'hrms.api.get_company_cost_center_and_expense_account',
        params: {'company': company});
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<List<dynamic>> getAdvances(String employee) async {
    final res = await HrmsApiClient.postMethod(
        'hrms.hr.doctype.expense_claim.expense_claim.get_advances',
        params: {'employee': employee});
    return res['message'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> submitExpenseClaim(
      Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod('hrms.api.submit_expense_claim',
        params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  // Get claim categories for the modern claims page
  static Future<List<dynamic>> claimCategories() async {
    // Use the same method as claimTypes since they're the same in Frappe HRMS
    return await claimTypes();
  }

  // Get claims statistics
  static Future<Map<String, dynamic>> claimsStats() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res =
          await HrmsApiClient.postMethod('hrms.api.get_claims_stats', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Update claim
  static Future<Map<String, dynamic>> updateClaim(
      Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod(
          'hrms.api.update_expense_claim',
          params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Submit claim via standard Frappe API
  static Future<Map<String, dynamic>> submitClaim(
      Map<String, dynamic> payload) async {
    try {
      // Create the expense claim document
      final createRes =
          await HrmsApiClient.postMethod('frappe.client.save', params: {
        'doc': {
          'doctype': 'Expense Claim',
          'employee': payload['employee'],
          'total_claimed_amount': payload['total_claimed_amount'],
          'company': payload['company'],
          'expense_approver': payload['expense_approver'],
          'posting_date': payload['posting_date'] ??
              DateTime.now().toIso8601String().split('T')[0],
          'expenses': payload['expenses'] ?? [],
        }
      });

      final docName = createRes['message']?['name'];
      if (docName == null) {
        return {'success': false, 'message': 'Failed to create expense claim'};
      }

      // Submit the document
      await HrmsApiClient.postMethod('frappe.client.submit', params: {
        'doc': {
          'doctype': 'Expense Claim',
          'name': docName,
        }
      });

      return {
        'success': true,
        'name': docName,
        'message': 'Expense claim submitted successfully',
      };
    } catch (e) {
      print('Error submitting expense claim: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Save draft claim
  static Future<Map<String, dynamic>> saveDraft(
      Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod(
          'hrms.api.save_expense_claim_draft',
          params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}
