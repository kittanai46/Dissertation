import 'package:flutter/material.dart';

class f2p extends StatefulWidget {
  @override
  _f2pState createState() => _f2pState();
}

class _f2pState extends State<f2p> {
  final List<Map<String, String>> userGuideContent = [
    {
      'title': 'คู่มือการใช้งานสำหรับอาจารย์',
      'content': '''
คู่มือนี้จะแนะนำวิธีการใช้งานแอปพลิเคชันสำหรับอาจารย์ โปรดอ่านอย่างละเอียดเพื่อทำความเข้าใจกับฟังก์ชันต่างๆ ของระบบ
'''
    },
    {
      'title': '1. การเข้าสู่ระบบ',
      'content': '''
- เปิดแอปพลิเคชันและกรอกรหัสอาจารย์/รหัสผ่าน
- กดปุ่ม "เข้าสู่ระบบ" เพื่อเข้าใช้งาน
'''
    },
    {
      'title': '2. หน้าหลัก',
      'content': '''
- แสดงข้อมูลส่วนตัว: ชื่อ-นามสกุล, รหัสอาจารย์
- แสดงสถานะการเชื่อมต่อ Bluetooth
- มีเมนูหลัก 5 รายการ:
  1. ตรวจสอบการเข้าเรียน
  2. กำหนดเวลาเข้าห้อง
  3. อนุมัติการยื่นใบลา
  4. ส่งประกาศข่าวสาร
  5. การตั้งค่า
'''
    },
    {
      'title': '3. ตรวจสอบการเข้าเรียน',
      'content': '''
- เข้าถึงได้จากเมนู "ตรวจสอบการเข้าเรียน"
- แสดงรายการการเข้าเรียนของนิสิตทั้งหมด
- มีตัวกรองเพื่อดูข้อมูลตามวิชาหรือวันที่
'''
    },
    {
      'title': '4. กำหนดเวลาเข้าห้อง',
      'content': '''
- เข้าถึงได้จากเมนู "กำหนดเวลาเข้าห้อง"
- สามารถตั้งเวลาเริ่มและสิ้นสุดการเช็คชื่อสำหรับแต่ละคาบเรียน
- เลือกวิชาและวันที่ที่ต้องการกำหนดเวลา
- บันทึกการตั้งค่าเวลาสำหรับการเช็คชื่ออัตโนมัติ
'''
    },
    {
      'title': '5. อนุมัติการยื่นใบลา',
      'content': '''
- เข้าถึงได้จากเมนู "อนุมัติการยื่นใบลา"
- แสดงรายการใบลาที่นิสิตยื่นมา
- สามารถดูรายละเอียดของแต่ละใบลา
- อนุมัติหรือปฏิเสธใบลาได้
'''
    },
    {
      'title': '6. ส่งประกาศข่าวสาร',
      'content': '''
- เข้าถึงได้จากเมนู "ส่งประกาศข่าวสาร"
- สร้างประกาศใหม่สำหรับนิสิต
- เลือกวิชาเป้าหมายที่จะส่งประกาศ 
'''
    },
    {
      'title': '7. การตั้งค่า',
      'content': '''
- เข้าถึงได้จากเมนู "การตั้งค่า"
- เปลี่ยนรูปโปรไฟล์
- ตั้งค่าการแจ้งเตือน
- ดูและจัดการสิทธิ์การใช้งานแอปพลิเคชัน
'''
    },
    {
      'title': '8. การใช้งาน Bluetooth',
      'content': '''
- เปิดใช้งาน Bluetooth บนอุปกรณ์
- ระบบจะค้นหาสัญญาณห้องเรียนโดยอัตโนมัติ
- เมื่อพบสัญญาณ ระบบจะแสดงข้อความยืนยันและแสดงว่าพบบอร์ดเป้าหมายของห้องแล้ว
'''
    },
    {
      'title': 'ข้อควรระวัง',
      'content': '''
- ตรวจสอบให้แน่ใจว่าเปิดใช้งาน Bluetooth และ Location บนอุปกรณ์
- ควรตรวจสอบการตั้งค่าเวลาเช็คชื่อก่อนเริ่มคาบเรียน
- ตรวจสอบการแจ้งเตือนอย่างสม่ำเสมอเพื่อไม่พลาดข้อมูลสำคัญจากนิสิต


'''
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
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
          const Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'คู่มือการใช้งาน',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 40,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/Images/NewLogo.png',
                width: 70,
                height: 60,
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 15,
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
            top: 140,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: userGuideContent.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['title']!,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          section['content']!,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
