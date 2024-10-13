import 'dart:io';

import 'package:ClassTracking/Professor/HomeProfessor.dart';
import 'package:ClassTracking/Student/HomeStudent.dart';
import 'package:ClassTracking/api_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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

      if (!await APIConstants.isServerOnline()) {
        throw Exception('Server is not reachable');
      }

      print('Attempting login with ID: ${_idController.text}');

      final result = await APIConstants.login(
        _idController.text,
        _passwordController.text,
      );

      print('Login Response: $result');

      if (result['success'] == true) {
        final user = result['user'];
        final role = user['role'];
        print('User role: $role');

        if (!mounted) return;

        if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeProfessor(
                firstName: user['first_name'] ?? '',
                lastName: user['last_name'] ?? '',
                idNumber: user['id_number'] ?? '',
              ),
            ),
          );
        } else if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeStudent(
                firstName: user['first_name'] ?? '',
                lastName: user['last_name'] ?? '',
                idNumber: user['id_number'] ?? '',
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'ไม่สามารถระบุประเภทผู้ใช้งานได้: $role';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'ล็อกอินไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
        });
      }
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        if (e.toString().contains('No internet connection')) {
          _errorMessage = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
        } else if (e.toString().contains('Server is not reachable')) {
          _errorMessage =
              'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่อีกครั้ง';
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
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Images/Bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 140),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Images/NewLogo.png',
                      height: 120,
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
                      "ล็อกอินเข้าสู่ระบบ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 4, 7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: "ไอดี",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
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
                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 106, 9, 108),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // ตั้งค่ามุมให้เป็นเหลี่ยม
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('เข้าสู่ระบบ',
                              style: TextStyle(fontSize: 19)),
                    ),
                    const SizedBox(height: 15),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          _errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
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
