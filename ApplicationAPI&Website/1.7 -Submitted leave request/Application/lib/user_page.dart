import 'dart:convert';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  final Function(String, String, String, String) onUserFetched;
  final String? initialUserId;

  UserPage({required this.onUserFetched, this.initialUserId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> users = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(APIConstants.getUsersEndpoint()),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(jsonResponse);
          isLoading = false;

          if (users.isNotEmpty) {
            final user = widget.initialUserId != null
                ? users.firstWhere(
                    (u) => u['id_number'].toString() == widget.initialUserId,
                    orElse: () => users.first)
                : users.first;
            widget.onUserFetched(
              user['first_name'],
              user['last_name'],
              user['id_number'].toString(),
              user['role'],
            );
          }
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching users: $error';
        isLoading = false;
      });
    }
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text('${user['first_name']} ${user['last_name']}'),
          subtitle: Text('ID: ${user['id_number']}'),
          trailing: Text('Role: ${user['role']}'),
          onTap: () {
            widget.onUserFetched(
              user['first_name'],
              user['last_name'],
              user['id_number'].toString(),
              user['role'],
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายชื่อผู้ใช้'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchUsers,
                        child: Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? Center(child: Text('ไม่พบข้อมูลผู้ใช้'))
                  : _buildUserList(),
    );
  }
}
