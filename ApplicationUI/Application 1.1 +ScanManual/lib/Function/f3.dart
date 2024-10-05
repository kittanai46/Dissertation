import 'package:flutter/material.dart';

class f3 extends StatelessWidget {
  const f3({Key? key}) : super(key: key);

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
            top: -20,
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
            top: 90,
            left: 0,
            right: 30,
            child: Center(
              child: Text(
                'เกี่ยวกับแอพพลิเคชัน', // แสดงข้อความบัญชีของฉัน
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            left: 320,
            top: 85,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/pack4.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 40,
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
