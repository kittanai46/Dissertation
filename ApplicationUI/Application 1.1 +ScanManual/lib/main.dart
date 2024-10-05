import 'package:flutter/material.dart';
import 'package:ClassTracking/Login/login.dart';

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
      home: Login(), // ตรวจสอบให้แน่ใจว่า Widget Login ถูกส่งอย่างถูกต้อง
    );
  }
}
