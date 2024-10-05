import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ClassTracking/Student/Sbox/Sbox2/Sbox2.dart';
import 'package:ClassTracking/Student/Sbox/Sbox3/Sbox3.dart';
import 'package:ClassTracking/Student/Sbox/Sbox4/Sbox4.dart';
import 'package:ClassTracking/Student/Sbox/Sbox5/Sbox5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScanning = false;
  bool deviceFound = false;
  bool popupShown = false;
  final String targetUUID = "952f7b6f622c04a2a8407abf6c719dba";
  String scanStatus = 'ไม่ได้เปิดบลูทูธ';
  double circleTop = 175.0;
  double circleRight = 20.0;
  File? _profileImage;
  String userName = '';
  String userSurname = '';
  String userId = '';
  int? major; // ตัวแปรเก็บค่า Major
  int? minor; // ตัวแปรเก็บค่า Minor

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkBleSupport());
    _loadProfileImage();
    _fetchUserData();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.171:4000/users'));
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        if (users.isNotEmpty) {
          setState(() {
            userName = users[0]['first_name'];
            userSurname = users[0]['last_name'];
            userId = users[0]['id_number'].toString();
          });
        }
      } else {
        print('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // ฟังก์ชันแสดง AlertDialog สำหรับแจ้งเตือน
  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
          if (result.advertisementData.manufacturerData.isNotEmpty) {
            Map<String, dynamic>? scannedData = getUuidAndMajorMinor(
                result.advertisementData.manufacturerData.values.first);
            String? scannedUUID = scannedData?['uuid'];
            int? scannedMajor = scannedData?['major'];
            int? scannedMinor = scannedData?['minor'];

            if (scannedUUID == targetUUID) {
              setState(() {
                deviceFound = true;
                major = scannedMajor; // เก็บค่า Major ที่สแกนได้
                minor = scannedMinor; // เก็บค่า Minor ที่สแกนได้
                scanStatus = 'พบสัญญาณแล้ว';
              });
              if (!popupShown) {
                showTargetDeviceFoundDialog(
                    scannedMajor, scannedMinor); // แสดงค่า Major และ Minor
                popupShown = true;
              }
              break;
            }
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

  // ฟังก์ชันดึง UUID, Major และ Minor จาก manufacturerData
  Map<String, dynamic>? getUuidAndMajorMinor(List<int> manufacturerData) {
    if (manufacturerData.length >= 22) {
      // UUID
      String uuid = manufacturerData
          .sublist(2, 18)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();

      // Major
      int major = (manufacturerData[18] << 8) + manufacturerData[19];

      // Minor
      int minor = (manufacturerData[20] << 8) + manufacturerData[21];

      return {'uuid': uuid, 'major': major, 'minor': minor};
    }
    return null;
  }

  // แก้ไขป็อปอัปเพื่อแสดงข้อความ "พบห้องเรียนแล้ว" พร้อมค่า Major และ Minor
  void showTargetDeviceFoundDialog(int? major, int? minor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('พบห้องเรียนแล้ว'),
        content: Text('Major: $major\nMinor: $minor'), // แสดง Major และ Minor
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
      String title, String description, String iconPath, VoidCallback onTap,
      {EdgeInsets titlePadding = const EdgeInsets.only(left: 10),
      EdgeInsets descriptionPadding = const EdgeInsets.only(left: 15),
      BorderRadius borderRadius =
          const BorderRadius.all(Radius.circular(5.0))}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        child: Container(
          width: double.infinity,
          height: 74,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 223, 134, 240),
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
                padding: const EdgeInsets.only(left: 25),
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
          Positioned(
            top: 210,
            left: 10,
            right: 10,
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/Images/usericon.png')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ชื่อ: $userName $userSurname', // แสดงชื่อและนามสกุล
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'รหัสนิสิต: $userId', // แสดง ID ของผู้ใช้
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'นิสิตนักศึกษา',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 50,
            right: 57,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                scanStatus,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // ปุ่มรีเฟรช
          Positioned(
            top: 745,
            right: 30,
            child: SizedBox(
              width: 52.0,
              height: 52.0,
              child: FloatingActionButton(
                onPressed: checkBluetoothStatus,
                child: const Icon(
                  Icons.refresh,
                  size: 25.0,
                ),
              ),
            ),
          ),
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
                    titlePadding: const EdgeInsets.only(left: 70),
                    descriptionPadding: const EdgeInsets.only(left: 35),
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
                    titlePadding: const EdgeInsets.only(left: 40, top: 5),
                    descriptionPadding: const EdgeInsets.only(left: 40, top: 5),
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
                    titlePadding: const EdgeInsets.only(left: 80, top: 10),
                    descriptionPadding: const EdgeInsets.only(left: 20, top: 5),
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
                    titlePadding: const EdgeInsets.only(left: 90, bottom: 5),
                    descriptionPadding:
                        const EdgeInsets.only(left: 35, bottom: 5),
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
        ],
      ),
    );
  }
}
