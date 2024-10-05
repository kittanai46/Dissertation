import 'package:flutter/material.dart';

class PBox4 extends StatelessWidget {
  const PBox4({Key? key}) : super(key: key);

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
            right: 30,
            child: Center(
              child: Text(
                'การแจ้งเตือน',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Padding ควรอยู่ใน children ของ Stack
          Positioned(
            left: 280,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon04.png',
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
