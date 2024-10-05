import 'dart:async';

import 'package:ClassTracking/Function/f2.dart';
import 'package:ClassTracking/Login/login.dart';
import 'package:ClassTracking/Student/HomeStudent.dart';
import 'package:flutter/material.dart';

//นิสิต
class Login1 extends StatefulWidget {
  const Login1({Key? key}) : super(key: key);

  @override
  _Login1State createState() => _Login1State();
}

class _Login1State extends State<Login1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;

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
//กล่องเมล
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: "อีเมล",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
//กล่องรหัสผ่าน
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
//ปุ่มเข้าสู่ระบบ
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_emailController.text == '' &&
                                _passwordController.text == '') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                              );
                            } else {
                              setState(() {
                                _errorMessage =
                                    'รหัสผ่านหรืออีเมลไม่ถูกต้อง ลองอีกครั้ง';
                              });
                              Timer(const Duration(seconds: 6), () {
                                setState(() {
                                  _errorMessage = '';
                                });
                              });
                            }
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
//ปุ่มคู่มือ
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
                                // backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
//ปุ่มเลือกล็อกอิน
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
                                // backgroundColor: Colors.transparent,
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
