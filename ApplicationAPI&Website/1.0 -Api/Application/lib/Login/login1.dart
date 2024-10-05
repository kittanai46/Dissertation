import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ClassTracking/Function/f2.dart';
import 'package:ClassTracking/Login/login.dart';
import 'package:ClassTracking/Student/HomeStudent.dart';
import 'package:ClassTracking/api_constants.dart'; // import ไฟล์ api_constants.dart เพื่อใช้ URL จากตัวแปรกลาง
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // สำหรับจัดการสิทธิ์

class Login1 extends StatefulWidget {
  const Login1({Key? key}) : super(key: key);

  @override
  _Login1State createState() => _Login1State();
}

class _Login1State extends State<Login1> {
  final TextEditingController _idController =
      TextEditingController(); // เปลี่ยนเป็น id_number
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // เรียกฟังก์ชันการตรวจสอบสิทธิ์เมื่อเริ่มต้น
  }

  // ฟังก์ชันการตรวจสอบสิทธิ์
  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses.values.every((status) => status.isGranted)) {
        print('All permissions granted');
      } else if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        _showSettingsAlert(); // แสดงการแจ้งเตือนเมื่อสิทธิ์ถูกปฏิเสธถาวร
      } else {
        _showPermissionAlert(); // แสดงการแจ้งเตือนเมื่อสิทธิ์ไม่ได้รับอนุญาต
      }
    }
  }

  // ฟังก์ชันการตรวจสอบการล็อกอิน
  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse(getLoginEndpoint()), // ใช้ฟังก์ชันจาก api_constants.dart
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_number': _idController.text, // ส่ง id_number ไปที่ API
          'password': _passwordController.text, // ส่ง password ไปที่ API
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // ล็อกอินสำเร็จ นำผู้ใช้ไปหน้า HomeStudent
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          setState(() {
            _errorMessage = 'ID หรือรหัสผ่านไม่ถูกต้อง';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    }

    // Reset the error message after 6 seconds
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  // แสดงการแจ้งเตือนให้ผู้ใช้ไปที่การตั้งค่า
  void _showSettingsAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ต้องการสิทธิ์'),
        content: const Text('กรุณาไปที่การตั้งค่าเพื่ออนุญาตสิทธิ์ที่จำเป็น'),
        actions: [
          TextButton(
            child: const Text('ไปที่การตั้งค่า'),
            onPressed: () {
              openAppSettings(); // เปิดการตั้งค่าของแอพ
            },
          ),
        ],
      ),
    );
  }

  // แสดงการแจ้งเตือนสิทธิ์ที่ไม่ได้รับอนุญาต
  void _showPermissionAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ต้องการสิทธิ์'),
        content: const Text(
            'กรุณาอนุญาตสิทธิ์ทั้งหมดที่จำเป็นเพื่อใช้งาน Bluetooth และ Location'),
        actions: [
          TextButton(
            child: const Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop();
              _checkPermissions(); // เรียกตรวจสอบสิทธิ์อีกครั้งหลังจากปิดการแจ้งเตือน
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "หน้าล็อกอิน",
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              child: Container(
                alignment: Alignment.topCenter,
                height: 400,
                child: Image.asset(
                  'assets/Images/Bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/Images/log1.png',
                    width: 200,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/Images/university.png',
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "BluetoothClass Tracking",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 4, 7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ล็อกอินเข้าสู่ระบบสำหรับนิสิต",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 0, 4, 7),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: TextField(
                            controller: _idController,
                            decoration: const InputDecoration(
                              labelText:
                                  "ID Number", // เปลี่ยน Label เป็น ID Number
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "รหัสผ่าน",
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_idController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              setState(() {
                                _errorMessage =
                                    'กรุณากรอก ID Number และรหัสผ่าน';
                              });
                            } else if (_passwordController.text.length < 6) {
                              setState(() {
                                _errorMessage =
                                    'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                              });
                            } else {
                              _login(); // เรียกฟังก์ชันล็อกอินที่เชื่อมต่อกับเซิร์ฟเวอร์
                            }
                            Timer(const Duration(seconds: 6), () {
                              if (mounted) {
                                setState(() {
                                  _errorMessage =
                                      ''; // ล้างข้อความหลังจาก 6 วินาที
                                });
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 106, 9, 108),
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 35),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                        const SizedBox(height: 15),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => f2()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right: 235),
                            child: const Text(
                              "คู่มือการใช้งาน ",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right: 140),
                            child: const Text(
                              "เลือกรูปแบบการล็อกอินอีกครั้ง",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
