import 'package:ClassTracking/Login/login1.dart';
import 'package:ClassTracking/Login/login2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    _checkPermissions(); // เรียกการขอสิทธิ์เมื่อแอปเริ่มทำงาน
  }

  Future<void> _checkPermissions() async {
    // ตรวจสอบและขอสิทธิ์ Bluetooth และ Location
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // ตรวจสอบว่าสิทธิ์ทั้งหมดได้รับการอนุญาต
    if (statuses.values.every((status) => status.isGranted)) {
      // ถ้าได้รับอนุญาตทั้งหมด ตรวจสอบสถานะ Bluetooth
      await _checkBluetoothStatus();
    } else {
      // ถ้าไม่ได้รับสิทธิ์บางอย่าง แสดง dialog แจ้งเตือน
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      bool isOn =
          await FlutterBluePlus.isOn; // ตรวจสอบว่า Bluetooth เปิดอยู่หรือไม่
      if (!isOn) {
        // ถ้า Bluetooth ปิดอยู่ แสดง dialog แจ้งเตือน
        _showBluetoothOffDialog();
      }
    } catch (e) {
      print('Error checking Bluetooth status: $e');
    }
  }

  // ฟังก์ชันแสดง dialog เมื่อสิทธิ์ถูกปฏิเสธ
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ต้องการสิทธิ์'),
          content: const Text(
              'กรุณาอนุญาตสิทธิ์ทั้งหมดที่จำเป็นเพื่อใช้งานแอปพลิเคชัน'),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // เปิดหน้าตั้งค่าแอปเพื่อให้ผู้ใช้อนุญาตสิทธิ์
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันแสดง dialog เมื่อ Bluetooth ปิด
  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth ปิดอยู่'),
          content: const Text('กรุณาเปิด Bluetooth เพื่อใช้งานแอปพลิเคชัน'),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง
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
                      // โลโก้มหาวิทยาลัย
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // กล่องนิสิตนักศึกษา
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
                          const SizedBox(width: 20),
                          // กล่องอาจารย์ผู้สอน
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
