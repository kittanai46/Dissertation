import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class APIConstants {
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.171:4000',
  );

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer <your-token>',
  };

  static Future<bool> isServerOnline() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection');
        return false;
      }

      final response = await http
          .get(Uri.parse(baseURL), headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Server responded with status code: ${response.statusCode}');
      }
    } catch (error) {
      if (error is TimeoutException) {
        print('Request timed out');
      } else {
        print('Error checking server status: $error');
      }
    }
    return false;
  }

  static Future<http.Response> makeRequest(String endpoint,
      {String method = 'GET', Map<String, dynamic>? body}) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      http.Response response;
      switch (method) {
        case 'GET':
          response = await http
              .get(Uri.parse(endpoint), headers: _headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http
              .post(Uri.parse(endpoint),
                  headers: _headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      print('API Response (${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Request failed: $error');
      rethrow;
    }
  }

  static String getLoginEndpoint() {
    return '$baseURL/login';
  }

  static String getUsersEndpoint() {
    return '$baseURL/users';
  }

  static String getUserByIdEndpoint(String userId) {
    return '$baseURL/users/$userId';
  }

  // เปลี่ยนชื่อเมธอดนี้
  static String getLogAttendanceEndpoint() {
    return '$baseURL/log_attendance';
  }

  static Future<Map<String, dynamic>> getUserData(String userId) async {
    final endpoint = getUserByIdEndpoint(userId);
    try {
      final response = await makeRequest(endpoint);
      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // แก้ไขเมธอดนี้
  static Future<bool> sendAttendanceData(Map<String, dynamic> data) async {
    final endpoint = getLogAttendanceEndpoint();
    try {
      final response = await makeRequest(endpoint, method: 'POST', body: data);
      print(
          'Attendance data sent. Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending attendance data: $e');
      return false;
    }
  }
}
