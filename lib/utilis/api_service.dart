import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stock_count/config.dart';
import 'package:stock_count/screens/home.dart';
import 'package:stock_count/utilis/dialog_messages.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:hive/hive.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseUrl;

  static const String _clientId = AppConfig.clientId;
  static const String _redirectUri = AppConfig.redirectUri;
  static const String _authorizationEndpoint = AppConfig.baseUrl;
  static const String _tokenEndpoint = AppConfig.tokenEndpoint;
  static const String _userInfoEndpoint = AppConfig.userInfoEndpoint;

  // Login with Frappe
  static Future<void> loginWithFrappe(BuildContext context) async {
    try {
      final url = Uri.parse(
          '$_authorizationEndpoint/api/method/frappe.integrations.oauth2.authorize?client_id=$_clientId&response_type=code&scope=all%20openid&redirect_uri=$_redirectUri');

      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: 'stockcount',
      );

      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        final tokenResponse = await http.post(
          Uri.parse('$_authorizationEndpoint$_tokenEndpoint'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': _redirectUri,
            'client_id': _clientId,
          },
        );

        if (tokenResponse.statusCode == 200) {
          final Map<String, dynamic> responseData =
              jsonDecode(tokenResponse.body);
          final accessToken = responseData['access_token'];
          final refreshToken = responseData['refresh_token'];
          final expiresIn =
              responseData['expires_in']; // Expiry time in seconds

          // Save tokens to Hive
          var authBox = Hive.box('authBox');
          await authBox.put('accessToken', accessToken);
          await authBox.put('refreshToken', refreshToken);
          await authBox.put('tokenExpiry',
              DateTime.now().add(Duration(seconds: expiresIn)).toString());

          // Fetch user information
          final userInfoResponse = await http.get(
            Uri.parse('$_authorizationEndpoint$_userInfoEndpoint'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (userInfoResponse.statusCode == 200) {
            final userInfo = jsonDecode(userInfoResponse.body);

            // Store user details in Hive
            await authBox.put('userDetails', jsonEncode(userInfo));

            // Navigate to HomeScreen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            showErrorDialog(
                context, "Failed to fetch user info: ${userInfoResponse.body}");
          }
        } else {
          showErrorDialog(context,
              "Token exchange failed with status: ${tokenResponse.body}");
        }
      } else {
        showErrorDialog(
            context, "No authorization code found in the redirect URL.");
      }
    } catch (e) {
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  static Future<List<String>> getWarehouses(BuildContext context) async {
    var authBox = Hive.box('authBox');
    String? userDetailsJson = authBox.get('userDetails');
    String? accessToken = authBox.get('accessToken');

    if (userDetailsJson != null && accessToken != null) {
      Map<String, dynamic> userDetails = json.decode(userDetailsJson);
      String userEmail = userDetails['email'];

      try {
        bool hasInternet = await InternetConnectionChecker().hasConnection;

        if (hasInternet) {
          accessToken = accessToken?.replaceAll('"', '');

          final response = await http.post(
            Uri.parse('$_baseUrl/api/method/fetch_user_warehouse'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'user': userEmail}),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (data['message'] != null &&
                data['message']['warehouses'] != null) {
              List<String> warehouses =
                  List<String>.from(data['message']['warehouses']);
              String company = data['message']['company'] ?? 'Unknown Company';
              String userId = data['message']['user_id'] ?? 'Unknown User ID';

              await authBox.put('warehouses', jsonEncode(warehouses));
              await authBox.put('company', company);
              await authBox.put('userId', userId);

              return warehouses;
            } else {
              showErrorDialog(context, 'Unexpected response from the server');
              return [];
            }
          } else {
            final errorData = jsonDecode(response.body);
            showErrorDialog(
                context, errorData['message'] ?? 'Failed to load warehouses.');
            return [];
          }
        } else {
          String? storedWarehousesJson = authBox.get('warehouses');
          String? storedCompany = authBox.get('company');
          String? storedUserId = authBox.get('userId');

          if (storedWarehousesJson != null &&
              storedCompany != null &&
              storedUserId != null) {
            List<String> storedWarehouses =
                List<String>.from(jsonDecode(storedWarehousesJson));
            return storedWarehouses;
          } else {
            showErrorDialog(context,
                'No internet connection and no stored data available.');
            return [];
          }
        }
      } catch (e) {
        showErrorDialog(context, 'Error fetching warehouses: $e');
        return [];
      }
    } else {
      showErrorDialog(context, 'User details or access token missing in Hive');
      return [];
    }
  }

  static Future<void> _logout(BuildContext context) async {
    var authBox = Hive.box('authBox');
    await authBox.clear(); // Clear all authentication data
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to login screen
  }
}
