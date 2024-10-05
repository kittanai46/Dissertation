import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ClassTracking/Function/f2.dart';
import 'package:ClassTracking/Student/HomeStudent.dart';
import 'package:ClassTracking/api_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _Login1State createState() => _Login1State();
}

class _Login1State extends State<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

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
        _showSettingsAlert();
      } else {
        _showPermissionAlert();
      }
    }
  }

  Future<void> _login() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      final response = await http
          .post(
            Uri.parse(APIConstants.getLoginEndpoint()),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'id_number': _idController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['success'] ?? false) == true) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeStudent(
                firstName: data['user']['first_name'] ?? '',
                lastName: data['user']['last_name'] ?? '',
                idNumber: data['user']['id_number'] ?? '',
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                data['error'] ?? 'ล็อกอินไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        if (e is TimeoutException) {
          _errorMessage = 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
        } else if (e.toString().contains('No internet connection')) {
          _errorMessage = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
        } else {
          _errorMessage = 'เกิดข้อผิดพลาด: $e';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

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
              _checkPermissions();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            labelText: "ID Number",
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
                        onPressed: _isLoading ? null : _login,
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
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('เข้าสู่ระบบ'),
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
                            MaterialPageRoute(
                                builder: (context) => const Login()),
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
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
