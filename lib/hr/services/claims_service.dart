import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/hr/services/profile_service.dart';

class ClaimsService {
  static Future<Map<String, dynamic>> expenseClaimSummary() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claim_summary', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) { return {}; }
  }

  static Future<List<dynamic>> myClaims() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claims', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> teamClaims() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claims',
          params: { 'for_approval': 1, if (emp != null) 'employee': emp });
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> claimTypes() async {
    final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claim_types');
    return res['message'] as List<dynamic>? ?? [];
  }
  static Future<Map<String, dynamic>> getExpenseApprovalDetails(String employee) async {
    final res = await HrmsApiClient.postMethod('hrms.api.get_expense_approval_details', params: {'employee': employee});
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<Map<String, dynamic>> getCompanyAccounts(String company) async {
    final res = await HrmsApiClient.postMethod('hrms.api.get_company_cost_center_and_expense_account', params: {'company': company});
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  static Future<List<dynamic>> getAdvances(String employee) async {
    final res = await HrmsApiClient.postMethod('hrms.hr.doctype.expense_claim.expense_claim.get_advances', params: {'employee': employee});
    return res['message'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> submitExpenseClaim(Map<String, dynamic> payload) async {
    final res = await HrmsApiClient.postMethod('hrms.api.submit_expense_claim', params: payload);
    return res['message'] as Map<String, dynamic>? ?? {};
  }

  // Get claim categories for the modern claims page
  static Future<List<dynamic>> claimCategories() async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.get_expense_claim_categories');
      return res['message'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  // Get claims statistics
  static Future<Map<String, dynamic>> claimsStats() async {
    try {
      final emp = await ProfileService.currentEmployee();
      final res = await HrmsApiClient.postMethod('hrms.api.get_claims_stats', params: {
        if (emp != null) 'employee': emp,
      });
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Update claim
  static Future<Map<String, dynamic>> updateClaim(Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.update_expense_claim', params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Submit claim
  static Future<Map<String, dynamic>> submitClaim(Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.submit_expense_claim', params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // Save draft claim
  static Future<Map<String, dynamic>> saveDraft(Map<String, dynamic> payload) async {
    try {
      final res = await HrmsApiClient.postMethod('hrms.api.save_expense_claim_draft', params: payload);
      return res['message'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}
