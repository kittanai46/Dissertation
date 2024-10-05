import 'package:flutter/material.dart';

class f2 extends StatelessWidget {
  const f2({Key? key}) : super(key: key);

  Widget _buildPositionedWidget({
    required Widget child,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildPositionedWidget(
            top: -30,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // เนื้อหาด้านใน
          const Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'คู่มือการใช้งาน', // แสดงข้อความบัญชีของฉัน
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 35,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Add more widgets here if needed
        ],
      ),
    );
  }
}
