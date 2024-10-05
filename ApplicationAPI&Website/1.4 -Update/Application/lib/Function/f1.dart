import 'package:flutter/material.dart';
import 'package:ClassTracking/Function/scan.dart'; // import หน้าหมาย

class f1 extends StatefulWidget {
  @override
  _f1State createState() => _f1State();
}

class _f1State extends State<f1> {
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
          // Background
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
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดตำแหน่งแนวนอนกลาง
                children: [
                  Text(
                    'การอนุญาตสิทธิ์',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 60,
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
          // Box with Bluetooth text and image
          _buildPositionedWidget(
            top: 190,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => scan(), // หน้าเป้าหมาย
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 242, 176, 255), // สีพื้นหลังของกล่อง
                    borderRadius: BorderRadius.circular(10), // ขอบมน
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // เงาสีดำจางๆ
                        blurRadius: 10,
                        offset: Offset(0, 5), // ตำแหน่งของเงา
                      ),
                    ],
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey, // สีของเส้นขอบล่าง
                        width: 1.0, // ความหนาของเส้นขอบล่าง
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Images/bluetooth.png',
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(
                          width: 10), // เพิ่มช่องว่างระหว่างรูปภาพกับข้อความ
                      Text(
                        'บลูทูธ',
                        style: TextStyle(
                          fontSize: 22,
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
}
