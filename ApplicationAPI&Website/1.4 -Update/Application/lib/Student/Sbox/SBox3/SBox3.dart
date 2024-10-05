import 'package:flutter/material.dart';

//ใบลา
class SBox3 extends StatelessWidget {
  const SBox3({Key? key}) : super(key: key);

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
            right: 0,
            child: Center(
              child: Text(
                'เอกสารออนไลน์',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Positioned(
            top: 75,
            left: 20,
            child: Text(
              'เลือกรายวิชา : ',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Padding ควรอยู่ใน children ของ Stack
          Positioned(
            left: 310,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon02.png',
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
