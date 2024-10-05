import 'dart:async';
import 'dart:io';

import 'package:ClassTracking/Student/Sbox/Sbox2/Sbox2.dart';
import 'package:ClassTracking/Student/Sbox/Sbox3/Sbox3.dart';
import 'package:ClassTracking/Student/Sbox/Sbox4/Sbox4.dart';
import 'package:ClassTracking/Student/Sbox/Sbox5/Sbox5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScanning = false;
  bool deviceFound = false;
  bool popupShown = false;
  final String targetMacAddress = "B0:A7:32:DA:98:B2";
  String scanStatus = 'ยังไม่ได้สแกน';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkBleSupport());
  }

  Future<void> checkBleSupport() async {
    try {
      bool isSupported = await FlutterBluePlus.isAvailable;
      if (!isSupported) {
        showAlertDialog(
            'BLE ไม่รองรับ', 'อุปกรณ์นี้ไม่รองรับ Bluetooth Low Energy');
      } else {
        await requestPermissions();
      }
    } catch (e) {
      print('Error checking BLE support: $e');
      showAlertDialog('เกิดข้อผิดพลาด', 'ไม่สามารถตรวจสอบการรองรับ BLE ได้');
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses.values.every((status) => status.isGranted)) {
        await checkBluetoothStatus();
      } else {
        showAlertDialog('ต้องการสิทธิ์',
            'กรุณาอนุญาตสิทธิ์ทั้งหมดที่จำเป็นเพื่อใช้งานการสแกน Bluetooth');
      }
    } else {
      await checkBluetoothStatus();
    }
  }

  Future<void> checkBluetoothStatus() async {
    try {
      bool isOn = await FlutterBluePlus.isOn;
      if (isOn) {
        startScan();
      } else {
        showAlertDialog(
            'Bluetooth ปิดอยู่', 'กรุณาเปิด Bluetooth เพื่อดำเนินการต่อ');
      }
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      showAlertDialog('เกิดข้อผิดพลาด', 'ไม่สามารถตรวจสอบสถานะ Bluetooth ได้');
    }
  }

  Future<void> startScan() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      deviceFound = false;
      scanStatus = 'กำลังสแกน...';
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          print('Found device: ${result.device.remoteId}');
          if (result.device.remoteId.toString() == targetMacAddress) {
            print('Target device found!');
            setState(() {
              deviceFound = true;
              scanStatus = 'พบอุปกรณ์เป้าหมาย';
            });
            if (!popupShown) {
              showTargetDeviceFoundDialog();
              popupShown = true;
            }
            break;
          }
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
      setState(() {
        scanStatus = 'เกิดข้อผิดพลาดในการสแกน';
      });
    }

    await Future.delayed(Duration(seconds: 4));
    setState(() {
      isScanning = false;
      if (!deviceFound) {
        scanStatus = 'ไม่พบอุปกรณ์เป้าหมาย';
      }
    });
  }

  void showTargetDeviceFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('พบอุปกรณ์เป้าหมาย'),
        content: Text('พบอุปกรณ์ที่มี MAC Address $targetMacAddress'),
        actions: [
          TextButton(
            child: Text('ตกลง'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('ตกลง'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: 90,
            left: 40,
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
          Positioned(
            top: 150,
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
                width: 55,
                height: 210,
              ),
            ),
          ),

          // สถานะการสแกน
          Positioned(
            top: 180,
            left: 30,
            child: Text(
              scanStatus,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // ปุ่มรีเฟรช
          Positioned(
            top: 170,
            right: 30,
            child: FloatingActionButton(
              onPressed: checkBluetoothStatus,
              child: Icon(Icons.refresh),
              mini: true,
            ),
          ),

          // กล่อง 1
          Positioned(
            top: 220,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Box2()),
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
                            'ส่งเอกสารต่างๆ เช่น การขาด การลา',
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
          ),

          // กล่อง 2
          Positioned(
            top: 340,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Box3()),
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
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            'ประวัติการเข้าห้องเรียน',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: 13),
                          child: Text(
                            'ตรวจสอบประวัติการเข้าห้องเรียน',
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
          ),

          // กล่อง 3
          Positioned(
            top: 460,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Box4()),
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
                          padding: EdgeInsets.only(left: 40),
                          child: Text(
                            'การแจ้งเตือน',
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
          ),

          // กล่อง 4
          Positioned(
            top: 580,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Box5()),
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
          ),
        ],
      ),
    );
  }
}
