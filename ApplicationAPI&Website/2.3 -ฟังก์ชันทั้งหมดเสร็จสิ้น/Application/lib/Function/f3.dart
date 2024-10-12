import 'package:flutter/material.dart';

class f3 extends StatefulWidget {
  @override
  _f3State createState() => _f3State();
}

class _f3State extends State<f3> {
  final String appInfo = '''
# เกี่ยวกับแอปพลิเคชัน 
Class Tracking

## วัตถุประสงค์
แอปพลิเคชัน Class Tracking ถูกพัฒนาขึ้นเพื่อช่วยอำนวยความสะดวก ในการบริหารจัดการ
การเข้าเรียนของนิสิตนักศึกษาเพื่อแก้ไขปัญหาต่างๆ ในการเข้าเช็คชื่อโดยใช้เทคโนโลยีบลูทูธ
เพื่อระบุตำแหน่งและบันทึกการเข้าเรียนอัตโนมัติ

## คุณสมบัติหลักสำหรับนิสิตนักศึกษา
1. สามารถเช็คชื่ออัตโนมัติผ่าน Bluetooth
2. สามารถส่งใบลาออนไลน์
3. สามารถรับแจ้งเตือนและประกาศข่าวสาร
4. สามารถดูประวัติการเข้าเรียน

## คุณสมบัติหลักสำหรับอาจารย์ผู้สอน
1. สามารถตรวจสอบการเข้าเรียนของนิสิตโดยรวม
2. สามารถตั้งเวลาเช็คชื่อเข้าเรียนของนิสิต
3. สามารถส่งประกาศและข่าวสารถึงนิสิตนักศึกษา
4. สามารถอนุมัติใบลาออนไลน์

## เวอร์ชันปัจจุบัน
1.0.0 (อัปเดตล่าสุด: กันยายน 2024)

## ความต้องการของระบบ
- Android 10.0 (Android Q) ขึ้นไป
- อุปกรณ์ต้องรองรับ Bluetooth Low Energy

## การอนุญาตที่จำเป็น
- การเข้าถึงตำแหน่งที่ตั้ง 
(สำหรับการใช้งาน Bluetooth)
- การเข้าถึงกล้องถ่ายรูป 
(สำหรับการอัปโหลดรูปโปรไฟล์)

## นโยบายความเป็นส่วนตัว
แอปพลิเคชันนี้เก็บรวบรวมข้อมูลเฉพาะที่จำเป็นสำหรับการทำงานของระบบเท่านั้น 
ข้อมูลทั้งหมดจะถูกเก็บรักษาเป็นความลับและไม่มีการแบ่งปันกับบุคคลที่สามโดยไม่ได้รับอนุญาต

## ทีมพัฒนา
แอปพลิเคชันนี้พัฒนาโดย:

1. นายกฤตดนัย ศรีคำ
   รหัสนิสิต: 64020899
   Facebook: Kittanai Srikham

2. นายกันตพงศ์ วิชาแหลม
   รหัสนิสิต: 64020934
   Facebook: Tontan Kantapong 

คณะเทคโนโลยีสารสนเทศและการสื่อสาร 
สาขาวิศวกรรมคอมพิวเตอร์ 
มหาวิทยาลัยพะเยา

## อาจารย์ที่ปรึกษาโปรเจค
อาจารย์ คมกริช มาเที่ยง
  ''';

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
                'เกี่ยวกับแอพพลิเคชัน',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 10,
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
                  children: appInfo.split('\n\n').map((paragraph) {
                    if (paragraph.startsWith('# ')) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          paragraph.substring(2),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    } else if (paragraph.startsWith('## ')) {
                      String title = paragraph.substring(3).split('\n')[0];
                      String content =
                          paragraph.substring(3 + title.length + 1);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              content,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          paragraph,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
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
