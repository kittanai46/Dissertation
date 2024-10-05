import 'package:flutter/material.dart';

//ตรวจสอบคนเข้าเรียน
class PBox3 extends StatelessWidget {
  const PBox3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ปุ่มย้อนกลับ
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // ไอคอนด้านขวา
          Positioned(
            top: 80,
            right: 20,
            child: Image.asset(
              'assets/Images/icon03.png',
              width: 50,
              height: 50,
            ),
          ),
          // ข้อความกลางหน้าจอ
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ตรวจสอบการเข้าเรียน',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // เพิ่ม widget อื่น ๆ ถ้าจำเป็น
        ],
      ),
    );
  }
}
