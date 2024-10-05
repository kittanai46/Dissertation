import 'package:flutter/material.dart';

class f2s extends StatefulWidget {
  @override
  _f2sState createState() => _f2sState();
}

class _f2sState extends State<f2s> {
  final List<Map<String, String>> userGuideContent = [
    {
      'title': 'คู่มือการใช้งานสำหรับนิสิตนักศึกษา',
      'content': '''
คู่มือนี้จะแนะนำวิธีการใช้งานแอปพลิเคชันสำหรับนิสิตนักศึกษา โปรดอ่านอย่างละเอียดเพื่อทำความเข้าใจกับตัวระบบของแอปพลิเคชัน
'''
    },
    {
      'title': '1. การเข้าสู่ระบบ',
      'content': '''
- เปิดแอปพลิเคชันและกรอกรหัสนิสิต/รหัสผ่าน
- กดปุ่ม "เข้าสู่ระบบ" เพื่อเข้าใช้งาน
'''
    },
    {
      'title': '2. หน้าหลัก',
      'content': '''
- แสดงข้อมูลส่วนตัว: ชื่อ-นามสกุล, รหัสนิสิต
- แสดงสถานะการเชื่อมต่อ Bluetooth
- มีเมนูหลัก 4 รายการ:
  1. ประวัติการเข้าห้องเรียน
  2. การประกาศข่าวสาร
  3. เอกสารออนไลน์
  4. การตั้งค่า
'''
    },
    {
      'title': '3. การเช็คชื่อเข้าเรียน',
      'content': '''
- เปิดใช้งาน Bluetooth บนอุปกรณ์
- ระบบจะค้นหาสัญญาณห้องเรียนโดยอัตโนมัติ
- เมื่อพบสัญญาณ ระบบจะแสดงข้อความยืนยันและบันทึกการเข้าเรียนโดยอัตโนมัติ
'''
    },
    {
      'title': '4. ประวัติการเข้าห้องเรียน',
      'content': '''
- ความเร็วในการแสดงข้อมูลจากการเช็คชื่อจะถูกส่งมาแบบเรียลทาม
- แสดงรายการประวัติการเข้าเรียนทั้งหมด
- สามารถดูรายละเอียดได้โดยการกดที่รายการ
'''
    },
    {
      'title': '5. การประกาศข่าวสาร',
      'content': '''
- แสดงรายการประกาศและข่าวสารจากอาจารย์
- กดที่รายการเพื่อดูรายละเอียดเพิ่มเติม
'''
    },
    {
      'title': '6. เอกสารออนไลน์',
      'content': '''
- สามารถส่งเอกสารการขาดเรียนหรือการลาได้
- เลือกแนปเอกสารเพื่อการลา กรอกข้อมูลในใบลา และแนบไฟล์(ถ้ามี)
'''
    },
    {
      'title': '7. การตั้งค่า',
      'content': '''
- สามารถเปลี่ยนรูปโปรไฟล์
- สามารถดูข้อมูลผู้ใช้
- สามารถดูการอนุญาตสิทธิ์และการเชื่อมต่อได้
- สามารถดูรายละเอียดทั่วไปของแอปพลิเคชันได้
'''
    },
    {
      'title': '8. การใช้งานระบบใบลาออนไลน์',
      'content': '''
- เข้าสู่เมนู "เอกสารออนไลน์" จากหน้าหลัก
- เลือก "ส่งใบลาออนไลน์"
- มีตัวเลือก 3 รายการ:
  1. ตรวจสอบการอนุมัติ: ดูสถานะของใบลาที่ส่งไปแล้ว
  2. ส่งใบลา: กรอกข้อมูลและส่งใบลาใหม่
  3. ดาวน์โหลดใบลา: ดาวน์โหลดแบบฟอร์มใบลาเปล่า

วิธีส่งใบลา
1. เลือก "ส่งใบลา"
2. เลือกรายวิชาที่ต้องการลา
3. กรอกรายละเอียดการลา เช่น วันที่ลา รายละเอียด ประเภทของการลา
4. แนบใบรับรองแพทย์ (ถ้ามี) เพื่อความน่าเชื่อถือ
5. กดส่งใบลา

การตรวจสอบสถานะใบลา
1. เลือก "ตรวจสอบการอนุมัติ"
2. ดูรายการใบลาที่เคยส่งและสถานะการอนุมัติ
'''
    },
    {
      'title': '9. การจัดการบัญชีผู้ใช้',
      'content': '''
- เข้าสู่เมนู "การตั้งค่า" จากหน้าหลัก
- เลือก "บัญชี" เพื่อดูข้อมูลส่วนตัว
- สามารถเปลี่ยนรูปโปรไฟล์ได้โดยการกดที่รูปภาพ
- กดปุ่ม "บันทึก" เพื่อบันทึกการเปลี่ยนแปลง
'''
    },
    {
      'title': '10. สิทธิ์และการเชื่อมต่อ',
      'content': '''
- เข้าสู่เมนู "การตั้งค่า" จากหน้าหลัก
- เลือก "สิทธิ์และการเชื่อมต่อ" เพื่อตรวจสอบสิทธิ์และการเชื่อมต่อข้อมูล
'''
    },
    {
      'title': '11. การดูคู่มือการใช้งาน',
      'content': '''
- เข้าสู่เมนู "การตั้งค่า" จากหน้าหลัก
- เลือก "คู่มือการใช้งาน" เพื่อดูคำแนะนำโดยละเอียด
'''
    },
    {
      'title': '12. การออกจากระบบ',
      'content': '''
- เข้าสู่เมนู "การตั้งค่า" จากหน้าหลัก
- กดไอคอนออกจากระบบที่มุมขวาล่าง
- ยืนยันการออกจากระบบเมื่อมีข้อความแจ้งเตือน
'''
    },
    {
      'title': 'ข้อควรระวัง',
      'content': '''
- ตรวจสอบให้แน่ใจว่าเปิดใช้งาน Bluetooth และ Location บนอุปกรณ์
- หากมีปัญหาในการเช็คชื่อ ให้ติดต่ออาจารย์ผู้สอนหรือเจ้าหน้าที่
- ตรวจสอบการแจ้งเตือนอย่างสม่ำเสมอเพื่อไม่พลาดข่าวสารสำคัญ

หากมีข้อสงสัยหรือต้องการความช่วยเหลือเพิ่มเติม กรุณาติดต่ออาจารย์ผู้สอนหรือติดต่อทีมพัฒนาโทร 061-485-2560
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
            right: 110,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/Images/Homeicon.png',
                width: 70,
                height: 60,
              ),
            ),
          ),
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
