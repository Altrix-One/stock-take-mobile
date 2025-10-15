import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:stock_count/hr/services/hrms_api_client.dart';
import 'package:stock_count/config.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  // Resolve the current Employee ID for the logged-in user.
  // Order of resolution:
  // 1) Cached in Hive authBox under key 'employee'
  // 2) Present in userDetails JSON under key 'employee'
  // 3) Lookup Employee by user_id (email/user) via REST and cache
  static Future<String?> currentEmployee() async {
    try {
      if (!Hive.isBoxOpen('authBox')) await Hive.openBox('authBox');
      final box = Hive.box('authBox');

      final cached = box.get('employee');
      if (cached is String && cached.isNotEmpty) return cached;

      final raw = box.get('userDetails');
      if (raw is String && raw.isNotEmpty) {
        try {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          final fromProfile = m['employee']?.toString();
          if (fromProfile != null && fromProfile.isNotEmpty) {
            await box.put('employee', fromProfile);
            return fromProfile;
          }
          // Try common fields
          final email =
              (m['email'] ?? m['preferred_username'] ?? m['sub'])?.toString();
          if (email != null && email.isNotEmpty) {
            final resolved = await _lookupEmployeeByUserId(email);
            if (resolved != null) {
              await box.put('employee', resolved);
              return resolved;
            }
          }
        } catch (_) {}
      }

      // As a last resort, if we have userId separately
      final userId = box.get('userId');
      if (userId is String && userId.isNotEmpty) {
        final resolved = await _lookupEmployeeByUserId(userId);
        if (resolved != null) {
          await box.put('employee', resolved);
          return resolved;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> _lookupEmployeeByUserId(String userId) async {
    try {
      // GET /api/resource/Employee?fields=["name"]&filters=[["Employee","user_id","=","user@domain.com"]]&limit=1
      final res = await HrmsApiClient.getJson(
        '/api/resource/Employee',
        query: {
          'fields': '["name"]',
          'filters': '[["Employee","user_id","=","$userId"]]',
          'limit': '1',
        },
      );
      final data = res['data'];
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map && first['name'] != null)
          return first['name'].toString();
      }
    } catch (_) {}
    return null;
  }

  // Fetch detailed employee information
  static Future<Map<String, dynamic>?> getEmployeeDetails() async {
    try {
      final employeeId = await currentEmployee();
      if (employeeId == null) return null;

      final res = await HrmsApiClient.getJson(
        '/api/resource/Employee/$employeeId',
        query: {
          'fields':
              '["name","employee_name","employee_number","gender","date_of_birth","date_of_joining","blood_group","company","department","designation","branch","employment_type","cell_number","personal_email","company_email","preferred_email","current_address","permanent_address","emergency_contact_name","emergency_contact_number","pan_number","bank_name","bank_ac_no","ifsc_code","image","user_id"]',
        },
      );

      if (res['data'] is Map<String, dynamic>) {
        return res['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching employee details: $e');
    }
    return null;
  }

  // Update employee information
  static Future<bool> updateEmployeeDetails(Map<String, dynamic> data) async {
    try {
      final employeeId = await currentEmployee();
      if (employeeId == null) return false;

      // Use postMethod to update employee via Frappe's API
      await HrmsApiClient.postMethod(
        'frappe.client.set_value',
        params: {
          'doctype': 'Employee',
          'name': employeeId,
          'fieldname': data,
        },
      );
      return true;
    } catch (e) {
      print('Error updating employee details: $e');
      return false;
    }
  }

  // Upload profile image and update employee record
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final employeeId = await currentEmployee();
      if (employeeId == null) return null;

      // Get auth token
      if (!Hive.isBoxOpen('authBox')) await Hive.openBox('authBox');
      final token = Hive.box('authBox').get('accessToken');
      if (token == null) throw Exception('Not authenticated');

      // Get base URL
      final baseUrl = await AppConfig.baseUrl;

      // Create multipart request for file upload
      final uri = Uri.parse('$baseUrl/api/method/upload_file');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      final filename =
          'profile_${employeeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: filename,
        ),
      );

      // Add additional fields
      request.fields['doctype'] = 'Employee';
      request.fields['docname'] = employeeId;
      request.fields['fieldname'] = 'image';
      request.fields['is_private'] = '0'; // Make public so it can be accessed

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final fileUrl = data['message']?['file_url']?.toString();

        if (fileUrl != null) {
          // Update employee record with new image URL
          await updateEmployeeDetails({'image': fileUrl});
          return fileUrl;
        }
      }

      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Get full image URL from Frappe
  static Future<String?> getFullImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final baseUrl = await AppConfig.baseUrl;

      // If it's already a full URL, return as is
      if (imagePath.startsWith('http')) return imagePath;

      // If it starts with /, prepend base URL
      if (imagePath.startsWith('/')) return '$baseUrl$imagePath';

      // Otherwise, assume it's a relative path from files
      return '$baseUrl/files/$imagePath';
    } catch (e) {
      print('Error building image URL: $e');
      return null;
    }
  }
}
