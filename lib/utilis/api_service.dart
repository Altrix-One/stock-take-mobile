import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/screens/home.dart';
import 'package:stock_count/utilis/dialog_messages.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseUrl;

  static const String _clientId = AppConfig.clientId;
  static const String _redirectUri = AppConfig.redirectUri;
  static const String _authorizationEndpoint = AppConfig.baseUrl;
  static const String _tokenEndpoint = AppConfig.tokenEndpoint;
  static const String _userInfoEndpoint = AppConfig.userInfoEndpoint;

  // New loginWithFrappe function
  static Future<void> loginWithFrappe(BuildContext context) async {
    try {
      // Construct the authorization URL
      final url = Uri.parse(
          '$_authorizationEndpoint/api/method/frappe.integrations.oauth2.authorize?client_id=$_clientId&response_type=code&scope=all%20openid&redirect_uri=$_redirectUri');

      // Start the web authentication
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: 'stockcount', // The scheme from your redirect URI
      );

      // Extract the authorization code from the resulting URL
      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        // Exchange the authorization code for an access token
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

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', jsonEncode(accessToken));

          // Fetch user information using the access token
          final userInfoResponse = await http.get(
            Uri.parse('$_authorizationEndpoint$_userInfoEndpoint'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (userInfoResponse.statusCode == 200) {
            final userInfo = jsonDecode(userInfoResponse.body);
            print("userInfo:${userInfo}");

            // Store user information in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('userDetails', jsonEncode(userInfo));

            // Navigate to home screen or next part of your app
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsJson = prefs.getString('userDetails');
    String? accessToken = prefs.getString('accessToken');

    if (userDetailsJson != null && accessToken != null) {
      Map<String, dynamic> userDetails = json.decode(userDetailsJson);
      String userEmail = userDetails['email'];

      try {
        // Check for network connectivity
        List<ConnectivityResult> result =
            await Connectivity().checkConnectivity();

        // Check if the result is either mobile or Wi-Fi
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          accessToken = accessToken.replaceAll('"', '');

          // Make the API call to fetch warehouses
          final response = await http.post(
            Uri.parse('$_baseUrl/api/method/fetch_user_warehouse'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'user': userEmail}),
          );

          // Check if the response is successful
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            // Check if the response contains the "message" field with warehouse data
            if (data['message'] != null && data['message'] is List) {
              // Save the warehouses to SharedPreferences for offline use
              await prefs.setString('warehouses', jsonEncode(data['message']));
              return List<String>.from(data['message']);
            } else {
              // Handle unexpected server response
              String errorMessage =
                  data['message'] ?? 'Unexpected response from the server';
              showErrorDialog(context, errorMessage);
              return [];
            }
          } else {
            // Handle non-200 status codes and extract the message from the backend response
            final errorData = jsonDecode(response.body);
            String errorMessage =
                errorData['message'] ?? 'Failed to load warehouses.';
            showErrorDialog(context, errorMessage);
            return [];
          }
        } else {
          // If not connected to the internet, retrieve stored warehouses from SharedPreferences
          String? storedWarehousesJson = prefs.getString('warehouses');
          if (storedWarehousesJson != null) {
            List<String> storedWarehouses =
                List<String>.from(jsonDecode(storedWarehousesJson));
            return storedWarehouses;
          } else {
            showErrorDialog(context,
                'No internet connection and no stored warehouses available.');
            return [];
          }
        }
      } catch (e) {
        // Handle any other errors during the HTTP request
        String errorMessage = 'Error fetching warehouses: $e';
        showErrorDialog(context, errorMessage);
        return [];
      }
    } else {
      // Handle the case where user details or access token are missing
      String errorMessage =
          'User details or access token missing in SharedPreferences';
      showErrorDialog(context, errorMessage);
      return [];
    }
  }
}
