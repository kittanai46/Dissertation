import 'package:flutter/material.dart';
import 'package:ClassTracking/Professor/Pbox/Pbox2/Pbox2.dart';
import 'package:ClassTracking/Professor/Pbox/Pbox3/Pbox3.dart';
import 'package:ClassTracking/Professor/Pbox/Pbox4/Pbox4.dart';
import 'package:ClassTracking/Professor/Pbox/Pbox5/Pbox5.dart';

class HomeProfessor extends StatelessWidget {
  const HomeProfessor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 80,
            left: 30,
            right: 0,
            child: Center(
              child: Text(
                'หน้าหลัก',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Positioned(
            top: 130,
            right: 30,
            child: Text(
              'เลือกฟังก์ชัน',
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            left: 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Image.asset(
                'assets/Images/Homeicon.png',
                width: 50,
                height: 190,
              ),
            ),
          ),

//กล่อง2
          Positioned(
            top: 290,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PBox2()),
                      );
                    },
                    child: Container(
                      width: 350,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 223, 134, 240),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/Images/icon02.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  'เอกสารออนไลน์',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  'อนุมัติเอกสาร การขาด การลา ฯลฯ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

//กล่อง3
          Positioned(
            top: 400,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PBox3()),
                      );
                    },
                    child: Container(
                      width: 350,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 223, 137, 240),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/Images/icon03.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'ประกาศแจ้งเตือน',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'การแจ้งเตือน ข่าวสารเรื่องๆให้นิสิต',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

//กล่อง4
          Positioned(
            top: 510,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PBox4()),
                      );
                    },
                    child: Container(
                      width: 350,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 223, 134, 240),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/Images/icon04.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  'กำหนดเวลาการเข้าเรียน',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  'แจ้งข่าวสารและการลงทะเบียนรายวิชา',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

//กล่อง5
          Positioned(
            top: 620,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PBox5()),
                      );
                    },
                    child: Container(
                      width: 350,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFc04ae0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Image.asset(
                              'assets/Images/icon05.png',
                              width: 45,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 60),
                                child: Text(
                                  'การตั้งค่า',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'โปรไฟล์ ข้อมูลส่วนตัวและอื่นๆ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
