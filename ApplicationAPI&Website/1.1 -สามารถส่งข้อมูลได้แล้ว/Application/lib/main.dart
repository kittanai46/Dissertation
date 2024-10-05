import 'package:ClassTracking/Login/Login.dart'; // ตรวจสอบชื่อและตำแหน่งของไฟล์นี้
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'หน้า Main',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(), // ตรวจสอบว่า class Login ถูกต้อง
    );
  }
}
