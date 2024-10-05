import 'package:flutter/material.dart';

//ส่งการประกาศข่าวสาร
class PBox4 extends StatelessWidget {
  const PBox4({Key? key}) : super(key: key);

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
          Positioned(
            top: 70,
            right: 40,
            child: Image.asset(
              'assets/Images/icon04.png',
              width: 50,
              height: 50,
            ),
          ),
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ส่งการประกาศข่าวสาร',
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
