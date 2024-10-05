import 'package:flutter/material.dart';
import 'package:ClassTracking/Login/login1.dart';
import 'package:ClassTracking/Login/login2.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              alignment: Alignment.topCenter,
              height: 420,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/Images/university.png',
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "BluetoothClass Tracking",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 4, 7),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "ล็อกอินในรูปแบบ?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Color.fromARGB(255, 0, 4, 7),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        "เลือกรูปแบบการเข้าใช้งานเพื่อทำการล็อกอิน",
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 0, 4, 7),
                        ),
                      ),
//กล่องนักเรียน
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login1()),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 155,
                                  height: 156,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 82, 154, 212),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/Images/log1.png',
                                        height: 135,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "นิสิตนักศึกษา",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
//กล่องอาจารย์
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login2()),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 155,
                                  height: 156,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 193, 108, 208),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/Images/log2.png',
                                        height: 125,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "อาจารย์ผู้สอน",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
