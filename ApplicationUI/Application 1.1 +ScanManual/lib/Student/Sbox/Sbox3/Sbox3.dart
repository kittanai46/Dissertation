import 'package:flutter/material.dart';

class Box3 extends StatelessWidget {
  const Box3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/Images/icon_back.png',
            width: 30, // Adjust width as needed
            height: 40, // Adjust height as needed
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 20,
            child: Center(
              child: Text(
                'การเข้าห้องเรียน',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Padding ควรอยู่ใน children ของ Stack
          Positioned(
            left: 300,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon03.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          // Add more widgets here if needed
        ],
      ),
    );
  }
}
