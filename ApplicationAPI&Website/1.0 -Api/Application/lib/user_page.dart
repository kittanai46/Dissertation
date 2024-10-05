import 'dart:convert';

import 'package:ClassTracking/api_constants.dart'; // import ไฟล์ api_constants.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  final Function(String, String, String)
      onUserFetched; // ตัวแปรสำหรับส่งข้อมูลกลับ

  UserPage({required this.onUserFetched});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List users = []; // เก็บข้อมูลผู้ใช้
  String errorMessage = ''; // ตัวแปรสำหรับข้อความข้อผิดพลาด

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้จาก API
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
          Uri.parse(getUsersEndpoint())); // ใช้ฟังก์ชันจาก api_constants.dart

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body); // แปลง JSON เป็น List
          errorMessage = ''; // เคลียร์ข้อความข้อผิดพลาด

          if (users.isNotEmpty) {
            // ส่งข้อมูล first_name, last_name และ id_number ไปยังหน้าหลัก
            widget.onUserFetched(
              users[0]['first_name'],
              users[0]['last_name'],
              users[0]['id_number'].toString(),
            );
          }
        });
      } else {
        throw Exception('Failed to load users'); // ข้อผิดพลาดในการดึงข้อมูล
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching users: $error'; // จัดการข้อผิดพลาดอื่นๆ
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
        title: Text('User List'),
      ),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage)) // แสดงข้อความข้อผิดพลาด
          : users.isEmpty
              ? Center(child: CircularProgressIndicator()) // แสดงการโหลดข้อมูล
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(users[index]['first_name']), // แสดงชื่อ
                      subtitle: Text(users[index]['last_name']), // แสดงนามสกุล
                      trailing: Text(users[index]['id_number']
                          .toString()), // แสดง id_number
                    );
                  },
                ),
    );
  }
}
