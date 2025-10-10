import 'package:stock_count/hr/services/hrms_api_client.dart';

class DoctypeService {
  static Future<List<dynamic>> getDoctypeFields(String doctype) async {
    final res = await HrmsApiClient.postMethod('hrms.api.get_doctype_fields', params: {
      'doctype': doctype,
    });
    return res['message'] as List<dynamic>? ?? [];
  }
}