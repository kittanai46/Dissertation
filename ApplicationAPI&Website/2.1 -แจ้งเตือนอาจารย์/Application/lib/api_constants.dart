import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class APIConstants {
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.45:4000',
  );

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer <your-token>',
  };

  static IO.Socket? socket;

  static Future<bool> isServerOnline() async {
    try {
      final response = await http
          .get(Uri.parse(baseURL), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (error) {
      print('Error checking server status: $error');
      return false;
    }
  }

  static Future<http.Response> makeRequest(String endpoint,
      {String method = 'GET', Map<String, dynamic>? body}) async {
    try {
      http.Response response;
      final Uri uri = Uri.parse('$baseURL$endpoint');

      print('Making $method request to: $uri');
      if (body != null) {
        print('Request body: $body');
      }

      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http
              .post(uri, headers: _headers, body: jsonEncode(body))
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

  // Socket.IO methods
  static void initializeSocket(String userId) {
    socket = IO.io(baseURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();
    socket!.emit('join', userId);

    socket!.on('connect', (_) {
      print('Connected to Socket.IO server');
    });

    socket!.on('disconnect', (_) {
      print('Disconnected from Socket.IO server');
    });
  }

  static void disconnectSocket() {
    socket?.disconnect();
    socket = null;
  }

  static void listenForNotifications(Function(dynamic) onNotificationReceived) {
    socket?.on('notification', (data) {
      onNotificationReceived(data);
    });
  }

  // Authentication endpoints
  static String getLoginEndpoint() => '/login';
  static String getUsersEndpoint() => '/users';
  static String getUserByIdEndpoint(String userId) => '/api/user/$userId';

  // Attendance endpoints
  static String getLogAttendanceEndpoint() => '/log_attendance';

  // Leave system endpoints
  static String getLeaveTypesEndpoint() => '/api/leave-types';
  static String getLeaveRequestEndpoint() => '/api/leave-request';
  static String getLeaveHistoryEndpoint(String studentId) =>
      '/api/leave-history/$studentId';
  static String getPendingLeaveRequestsEndpoint(String teacherId) =>
      '/api/pending-leave-requests/$teacherId';
  static String getApproveLeaveRequestEndpoint(String leaveRequestId) =>
      '/api/approve-leave-request/$leaveRequestId';

  // Course endpoints
  static String getStudentCoursesEndpoint(String studentId) =>
      '/api/student_courses/$studentId';
  static String getTeacherCoursesEndpoint(String teacherId) =>
      '/api/teacher_courses/$teacherId';

  // Message endpoints
  static String getCourseMessagesEndpoint() => '/api/course_messages';
  static String getAllMessagesEndpoint() => '/api/messages';

  // User data methods
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final userResponse = await makeRequest(getUserByIdEndpoint(userId));
      final Map<String, dynamic> userData = jsonDecode(userResponse.body);

      final attendanceResponse = await makeRequest('/api/attendance/$userId');
      final List<dynamic> attendanceData = jsonDecode(attendanceResponse.body);

      Map<String, String> courseNames = {};
      for (var attendance in attendanceData) {
        courseNames[attendance['course_code']] = attendance['course_name'];
      }

      userData['attendance'] = attendanceData;
      userData['course_names'] = courseNames;

      print('User Data: $userData');
      return userData;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Attendance methods
  static Future<bool> sendAttendanceData(Map<String, dynamic> data) async {
    try {
      final response = await makeRequest(getLogAttendanceEndpoint(),
          method: 'POST', body: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending attendance data: $e');
      return false;
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>> login(
      String idNumber, String password) async {
    try {
      final response = await makeRequest(
        getLoginEndpoint(),
        method: 'POST',
        body: {
          'id_number': idNumber,
          'password': password,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error during login: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Course methods
  static Future<List<Map<String, dynamic>>> getStudentCourses(
      String studentId) async {
    try {
      final response = await makeRequest(getStudentCoursesEndpoint(studentId));
      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = jsonDecode(response.body);
        return coursesJson
            .map((course) => {
                  'course_id': course['course_id']?.toString() ?? '',
                  'course_code': course['course_code'] ?? '',
                  'course_name': course['course_name'] ?? '',
                  'section': course['section']?.toString() ?? '',
                  'name':
                      "${course['course_code'] ?? ''} - ${course['course_name'] ?? ''}"
                })
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStudentCourses: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTeacherCourses(
      String teacherId) async {
    try {
      final response = await makeRequest('/api/teacher_courses/$teacherId');
      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = jsonDecode(response.body);
        return coursesJson
            .map((course) => {
                  'course_code': course['course_code'] ?? '',
                  'course_name': course['course_name'] ?? '',
                  'section': course['section']?.toString() ?? '',
                })
            .toList();
      } else {
        throw Exception(
            'Failed to load teacher courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTeacherCourses: $e');
      rethrow;
    }
  }

  // Leave system methods
  static Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    try {
      final response = await makeRequest(getLeaveTypesEndpoint());
      if (response.statusCode == 200) {
        final List<dynamic> leaveTypesJson = jsonDecode(response.body);
        return leaveTypesJson
            .map((type) => type as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load leave types');
      }
    } catch (e) {
      print('Error in getLeaveTypes: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> submitLeaveRequest(
      Map<String, dynamic> leaveData,
      List<http.MultipartFile> attachments) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseURL${getLeaveRequestEndpoint()}'));

      request.fields.addAll(
          leaveData.map((key, value) => MapEntry(key, value.toString())));

      for (var file in attachments) {
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to submit leave request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in submitLeaveRequest: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingLeaveRequests(
      String teacherId) async {
    try {
      final response =
          await makeRequest(getPendingLeaveRequestsEndpoint(teacherId));
      if (response.statusCode == 200) {
        final List<dynamic> requestsJson = jsonDecode(response.body);
        return requestsJson.map((request) {
          return {
            'id': request['id'].toString(),
            'student_name': request['student_name'] ?? '',
            'course_name': request['course_name'] ?? '',
            'leave_type': request['leave_type'] ?? '',
            'start_date': request['start_date'] ?? '',
            'end_date': request['end_date'] ?? '',
            'reason': request['reason'] ?? '',
            'has_leave_document': request['has_leave_document'] ?? false,
            'has_medical_certificate':
                request['has_medical_certificate'] ?? false,
            'student_id': request['student_id'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load pending leave requests');
      }
    } catch (e) {
      print('Error in getPendingLeaveRequests: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> approveLeaveRequest({
    required String leaveRequestId,
    required String teacherId,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await makeRequest(
        getApproveLeaveRequestEndpoint(leaveRequestId),
        method: 'POST',
        body: {
          'status': status,
          'comment': comment,
          'approver_id': teacherId,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic>) {
          return responseBody;
        } else {
          print('Unexpected response body type: ${responseBody.runtimeType}');
          return {'success': false, 'error': 'Unexpected response body type'};
        }
      } else {
        print('Unexpected response: ${response.body}');
        return {
          'success': false,
          'error': 'Unexpected response from server: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error in approveLeaveRequest: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Message methods
  static Future<List<Map<String, dynamic>>> getCourseMessages(
      List<String> courseCodes) async {
    try {
      final response = await makeRequest(
        getCourseMessagesEndpoint(),
        method: 'POST',
        body: {'courses': courseCodes},
      );
      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = jsonDecode(response.body);
        return messagesJson
            .map((message) => message as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load course messages');
      }
    } catch (e) {
      print('Error in getCourseMessages: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllMessages() async {
    try {
      final response = await makeRequest(getAllMessagesEndpoint());
      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = jsonDecode(response.body);
        return messagesJson
            .map((message) => message as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load all messages');
      }
    } catch (e) {
      print('Error in getAllMessages: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendCourseMessage({
    required String teacherId,
    required String courseCode,
    required String title,
    required String message,
  }) async {
    final parts = courseCode.split('[');
    final code = parts[0];
    final section = parts.length > 1 ? parts[1].replaceAll(']', '') : '1';

    try {
      final response = await makeRequest(
        getCourseMessagesEndpoint(),
        method: 'POST',
        body: {
          'teacher_id': teacherId,
          'course_code': code,
          'section': section,
          'title': title,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true) {
          return decodedResponse;
        } else {
          throw Exception('Server returned success: false');
        }
      } else {
        throw Exception(
            'Failed to send course message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendCourseMessage: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Notification methods
  static Future<Map<String, dynamic>> sendNotification({
    required String recipientId,
    required String message,
    String? title,
  }) async {
    try {
      final response = await makeRequest(
        '/api/notifications/send',
        method: 'POST',
        body: {
          'recipientId': recipientId,
          'message': message,
          'title': title,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendNotification: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Additional utility methods

  // Method to format date for MySQL
  static String formatDateForMySQL(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Method to parse MySQL datetime to DateTime
  static DateTime parseMySQLDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  // Method to get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await makeRequest('/api/user/profile/$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Method to update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await makeRequest(
        '/api/user/profile/$userId',
        method: 'PUT',
        body: profileData,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateUserProfile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Method to get course details
  static Future<Map<String, dynamic>> getCourseDetails(
      String courseCode, String section) async {
    try {
      final response = await makeRequest('/api/course/$courseCode/$section');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get course details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCourseDetails: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Method to get student attendance summary
  static Future<Map<String, dynamic>> getStudentAttendanceSummary(
      String studentId, String courseCode, String section) async {
    try {
      final response = await makeRequest(
          '/api/attendance/summary/$studentId/$courseCode/$section');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to get attendance summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStudentAttendanceSummary: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Method to get all notifications for a user
  static Future<List<Map<String, dynamic>>> getUserNotifications(
      String userId) async {
    try {
      final response = await makeRequest('/api/notifications/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson = jsonDecode(response.body);
        return notificationsJson
            .map((notification) => notification as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            'Failed to get user notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserNotifications: $e');
      return [];
    }
  }

  // Method to mark a notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await makeRequest(
        '/api/notifications/read/$notificationId',
        method: 'PUT',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in markNotificationAsRead: $e');
      return false;
    }
  }

  // Method to get system settings
  static Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await makeRequest('/api/settings');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to get system settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getSystemSettings: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Add any additional methods or utilities as needed for your app
} // End of APIConstants class