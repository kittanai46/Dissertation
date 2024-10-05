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
  String scanStatus = 'ไม่ได้เปิดบลูทูธ';

  // กำหนดตำแหน่งของสี
  double circleTop = 175.0;
  double circleRight = 20.0;

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
      scanStatus = 'กำลังค้นหา...';
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          print('Found device: ${result.device.remoteId}');
          if (result.device.remoteId.toString() == targetMacAddress) {
            print('Target device found!');
            setState(() {
              deviceFound = true;
              scanStatus = 'พบสัญญาณแล้ว';
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
        scanStatus = 'เกิดข้อผิดพลาดในการค้นหา';
      });
    }

    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isScanning = false;
      if (!deviceFound) {
        scanStatus = 'ไม่พบสัญญาณ';
      }
    });
  }

  void showTargetDeviceFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('พบอุปกรณ์เป้าหมาย'),
        content: Text('พบอุปกรณ์ที่มี MAC Address $targetMacAddress'),
        actions: [
          TextButton(
            child: const Text('ตกลง'),
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
            child: const Text('ตกลง'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget buildFunctionBox(
    String title,
    String description,
    String iconPath,
    VoidCallback onTap, {
    EdgeInsets titlePadding = const EdgeInsets.only(left: 10),
    EdgeInsets descriptionPadding = const EdgeInsets.only(left: 15),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(5.0)),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 0,
        ),
        child: Container(
          width: double.infinity,
          height: 74,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 223, 134, 240),
            borderRadius: borderRadius,
            border: const Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Image.asset(
                  iconPath,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: titlePadding,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: descriptionPadding,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          const Positioned(
            top: 180,
            right: 155,
            child: Text(
              'สถานะบลูทูธ :',
              style: TextStyle(
                fontSize: 14,
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

          // กล่องขาวใส่ข้อมูล
          Positioned(
            top: 210,
            left: 10,
            right: 10,
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // สถานะการสแกน
          Positioned(
            top: 180,
            left: 50,
            right: 57, // ปรับค่าเพื่อขยับข้อความ
            child: Align(
              alignment: Alignment.centerRight, // จัดให้ข้อความชิดขวา
              child: Text(
                scanStatus,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ในส่วนของ Positioned ที่ใช้เรียก buildFunctionBox แต่ละกล่อง

          Positioned(
            top: 420,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFunctionBox(
                    'เอกสารออนไลน์',
                    'ส่งเอกสารต่างๆ เช่น การขาด การลา',
                    'assets/Images/icon02.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Box2())),
                    titlePadding: const EdgeInsets.only(left: 50),
                    descriptionPadding: const EdgeInsets.only(left: 10),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'ประวัติการเข้าห้องเรียน',
                    'ประวัติการเข้าห้องเรียนที่ผ่านมา',
                    'assets/Images/icon03.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Box3())),
                    titlePadding: const EdgeInsets.only(left: 20, top: 5),
                    descriptionPadding: const EdgeInsets.only(left: 15, top: 5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'การแจ้งเตือน',
                    'แจ้งข่าวสารและการลงทะเบียนรายวิชา',
                    'assets/Images/icon04.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Box4())),
                    titlePadding: const EdgeInsets.only(left: 55, top: 10),
                    descriptionPadding: const EdgeInsets.only(left: 5, top: 5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'การตั้งค่า',
                    'โปรไฟล์ ข้อมูลส่วนตัวและอื่นๆ',
                    'assets/Images/icon05.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Box5())),
                    titlePadding: const EdgeInsets.only(left: 70, bottom: 5),
                    descriptionPadding:
                        const EdgeInsets.only(left: 25, bottom: 5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: circleTop,
            right: circleRight,
            child: Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: deviceFound
                    ? Colors.green
                    : Colors.red, // สีขึ้นอยู่กับสถานะการพบอุปกรณ์
                borderRadius: BorderRadius.circular(
                    20), // เปลี่ยนจากวงกลมเป็นสี่เหลี่ยมไม่มีมุม
              ),
            ),
          ),

          // ปุ่มรีเฟรช
          Positioned(
            top: 725,
            right: 30,
            child: SizedBox(
              width: 60.0,
              height: 60.0,
              child: FloatingActionButton(
                onPressed: checkBluetoothStatus,
                child: const Icon(
                  Icons.refresh,
                  size: 35.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
