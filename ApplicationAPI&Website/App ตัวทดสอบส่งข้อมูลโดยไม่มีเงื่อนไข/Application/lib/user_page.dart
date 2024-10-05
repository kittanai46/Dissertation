import 'dart:convert';

import 'package:vsTest/api_constants.dart'; // import ไฟล์ api_constants.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  final Function(String, String, String, String) onUserFetched;

  const UserPage({super.key, required this.onUserFetched});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List users = []; // เก็บข้อมูลผู้ใช้
  String errorMessage = ''; // ตัวแปรสำหรับข้อความข้อผิดพลาด
  bool isLoading = true; // ตัวแปรสำหรับการโหลดข้อมูล

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้จาก API
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true; // เริ่มต้นสถานะการโหลด
    });

    try {
      final response = await http.get(
        Uri.parse(APIConstants.getUsersEndpoint()), // เรียกผ่าน APIConstants
      );

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body); // แปลง JSON เป็น List
          errorMessage = ''; // เคลียร์ข้อความข้อผิดพลาด
          isLoading = false; // สถานะการโหลดเสร็จสิ้น

          if (users.isNotEmpty) {
            // ส่งข้อมูล first_name, last_name, id_number และ role ไปยังหน้าหลัก
            widget.onUserFetched(
              users[0]['first_name'],
              users[0]['last_name'],
              users[0]['id_number'].toString(),
              users[0]['role'], // เพิ่ม role ที่รับมาจาก API
            );
          }
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized request. Please log in.');
      } else if (response.statusCode == 404) {
        throw Exception('Data not found.');
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching users: $error'; // จัดการข้อผิดพลาดอื่นๆ
        isLoading = false; // เปลี่ยนสถานะการโหลดเป็น false
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers(); // ดึงข้อมูลเมื่อเริ่มหน้า
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดงการโหลดข้อมูล
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage), // แสดงข้อความข้อผิดพลาด
                      ElevatedButton(
                        onPressed: fetchUsers, // ปุ่ม retry เพื่อดึงข้อมูลใหม่
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? const Center(child: Text('No users found.')) // กรณีไม่มีผู้ใช้
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              '${users[index]['first_name']} ${users[index]['last_name']}'), // แสดงชื่อเต็ม
                          subtitle: Text(
                              'ID: ${users[index]['id_number']}'), // แสดง id_number
                          trailing: Text(
                              'Role: ${users[index]['role']}'), // แสดง role
                        );
                      },
                    ),
    );
  }
}
