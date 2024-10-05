import 'package:flutter/material.dart';

class pack extends StatelessWidget {
  const pack({Key? key}) : super(key: key);
//บัญชีผู้ใช้
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // คลื่นด้านบน
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: Top1(),
              child: Container(
                height: 120,
                color: Colors.purple[300], // ใช้สีเพื่อสร้างคลื่นด้านบน
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: Top2(),
              child: Container(
                height: 55,
                color: Color.fromARGB(
                    255, 107, 53, 116), // ใช้สีเพื่อสร้างคลื่นด้านบน
              ),
            ),
          ),

          // คลื่นด้านล่าง
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipperBottom(),
              child: Container(
                height: 60,
                color: Colors.purple[100], // ใช้สีเพื่อสร้างคลื่นด้านล่าง
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
                'บัญชีของฉัน', // แสดงข้อความบัญชีของฉัน
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

//
//
//คลื่นบน1
class Top1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    // กำหนด Control Points เพื่อสร้างคลื่นด้านบน
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 10);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

//
//
// คลื่นบน2
class Top2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height + 20); // เลื่อนจุดเริ่มต้นของคลื่นขึ้น

    // ปรับค่า Control Points เพื่อสร้างคลื่นด้านบน
    var firstControlPoint =
        Offset(size.width / 4, size.height + 30); // เลื่อนขึ้นและยก
    var firstEndPoint =
        Offset(size.width / 2, size.height - 50); // เลื่อนขึ้นและยก
    var secondControlPoint =
        Offset(size.width * 3 / 4, size.height - 70); // เลื่อนลงและยก
    var secondEndPoint = Offset(size.width, size.height - 20); // เลื่อนลง

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

//
//
// คลื่นล่าง
class WaveClipperBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 30);

    // กำหนด Control Points เพื่อสร้างคลื่นด้านล่าง
    var firstControlPoint = Offset(size.width / 5, 0);
    var firstEndPoint = Offset(size.width / 2, 20);
    var secondControlPoint = Offset(size.width * 3 / 4, 40);
    var secondEndPoint = Offset(size.width, 10);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
