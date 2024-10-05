import 'package:vsTest/Function/f1.dart';
import 'package:vsTest/Function/f2.dart';
import 'package:vsTest/Function/f3.dart';
import 'package:vsTest/Login/Login.dart';
import 'package:vsTest/Professor/Pbox/Pbox5/pack.dart';
import 'package:flutter/material.dart';

class PBox5 extends StatelessWidget {
  const PBox5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          //ปุ่มกลับ
          icon: Image.asset(
            'assets/Images/icon_back.png',
            width: 35,
            height: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 10,
            child: Center(
              child: Text(
                'การตั้งค่า',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 5 - 80,
            left: 0,
            right: 0,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage(
                      'assets/Images/usericon.png',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ชื่อผู้ใช้',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

// กล่อง1
          Positioned(
            top: 280,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pack()),
                );
              },
              child: Container(
                width: 360,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 242, 176, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/Images/pack1.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'บัญชี',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'บัญชีผู้ใช้ ข้อมูลส่วนตัวและโปรไฟล์ ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Image.asset(
                        'assets/Images/arrow.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

// กล่อง2
          Positioned(
            top: 365,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f1()),
                );
              },
              child: Container(
                width: 360,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 176, 255),
                  borderRadius: BorderRadius.circular(0),
                  border: const Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 143, 135, 135),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/Images/pack2.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'แจ้งเตือนและสิทธิ์',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'การอนุญาตการขอสิทธิ์และแจ้งเตือน',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Image.asset(
                        'assets/Images/arrow.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

// กล่อง3
          Positioned(
            top: 450,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f2()),
                );
              },
              child: Container(
                width: 360,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 242, 176, 255),
                  border: Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 143, 135, 135),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/Images/pack3.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'คู่มือการใช้งาน',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'คู่มือและวิธีการใช้งานโดยเบื้องต้น',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Image.asset(
                        'assets/Images/arrow.png',
                        width: 50,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

// กล่อง4
          Positioned(
            top: 530,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f3()),
                );
              },
              child: Container(
                width: 360,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 242, 176, 255),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 143, 135, 135),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/Images/pack4.png',
                        width: 50,
                        height: 70,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'เกี่ยวกับแอพพลิเคชัน',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'ข้อมูลต่างๆที่เกี่ยวกับแอพพลิเคชัน',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Image.asset(
                        'assets/Images/arrow.png',
                        width: 50,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

//รูปฟันเฟือง
          Positioned(
            left: 250,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon05.png',
                width: 60,
                height: 45,
              ),
            ),
          ),

//  หน้าต่างเด้งออกจากระบบ
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("ยืนยันการออกจากระบบ"),
                      content: const Text("คุณแน่ใจหรือไม่ที่จะออกจากระบบ?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('ยกเลิก'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: const Text('ตกลง'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),

//รูปปุ่มออกระบบ
                child: Image.asset(
                  'assets/Images/exit.png',
                  width: 30,
                  height: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
