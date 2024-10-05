import 'package:ClassTracking/Student/Sbox/SBox3/Record.dart';
import 'package:ClassTracking/Student/Sbox/SBox3/SBox3.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Choose extends StatelessWidget {
  const Choose({Key? key}) : super(key: key);

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(
        'https://drive.google.com/file/d/1iXq7ZzDi50ROZ2JzUKcHgxle_iISChw4/view?usp=sharing');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // ทำการจัดการข้อผิดพลาดที่นี่ เช่น แสดง SnackBar หรือ AlertDialog
    }
  }

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
                  'ส่งใบลาออนไลน์',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // ข้อความ "เลือกรูปแบบการเข้าใช้งาน"
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'เลือกรูปแบบการเข้าใช้งาน',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          // กล่องที่มีภาพและข้อความด้านล่าง
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        // กล่องซ้าย (มีภาพ c1)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Record()),
                            );
                          },
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/Images/c1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ตรวจสอบการอนุมัติ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        // กล่องขวา (มีภาพ c2)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SBox3()),
                            );
                          },
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/Images/c2.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ส่งใบลา',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // กล่องใหม่ (ดาวโหลดใบลา)
                GestureDetector(
                  onTap: _launchURL,
                  child: Container(
                    width: 340,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(211, 132, 230, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'กดที่นี้เพื่อดาวน์โหลดใบลา',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
