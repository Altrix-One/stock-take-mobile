import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_count/screens/home.dart';
import 'package:stock_count/utilis/dialog_messages.dart';

class ApiService {
  static const String _baseUrl = "http://192.168.1.72:8000/api/method";

  static Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse(
            '$_baseUrl/csf_tz.stock_count.doctype.stock_count_person.stock_count_person.authenticate_stock_count_person'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      var responseData = jsonDecode(response.body);
      if (responseData['message']['status_code'] == 200) {
        var data = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userDetails', jsonEncode(data));

        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, jsonDecode(response.body)['message']['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorDialog(context, "An error occurred: $e");
      ;
    }
  }
}




