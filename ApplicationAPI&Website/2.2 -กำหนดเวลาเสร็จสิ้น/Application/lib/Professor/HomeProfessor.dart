import 'dart:async';
import 'dart:io';

import 'package:ClassTracking/Professor/Pbox/PBox1.dart';
import 'package:ClassTracking/Professor/Pbox/PBox2.dart';
import 'package:ClassTracking/Professor/Pbox/PBox3.dart';
import 'package:ClassTracking/Professor/Pbox/PBox4.dart';
import 'package:ClassTracking/Professor/Pbox/Pbox5/Pbox5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProfessor extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String idNumber;

  const HomeProfessor({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
  }) : super(key: key);

  @override
  _HomeProfessorState createState() => _HomeProfessorState();
}

class _HomeProfessorState extends State<HomeProfessor> {
  bool isScanning = false;
  bool deviceFound = false;
  bool popupShown = false;
  final String targetUUID = "952f7b6f622c04a2a8407abf6c719dba";
  String scanStatus = 'ไม่ได้เปิดบลูทูธ';
  double circleTop = 155.0;
  double circleRight = 20.0;
  File? _profileImage;
  int? major;
  int? minor;
  String? _error;
  bool _isLoading = true;
  DateTime? targetFoundTime;

  @override
  void initState() {
    super.initState();
    print(
        'HomeProfessor initialized with: ${widget.firstName}, ${widget.lastName}, ${widget.idNumber}');
    WidgetsBinding.instance.addPostFrameCallback((_) => checkBleSupport());
    _loadProfileImage();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
                major = scannedMajor;
                minor = scannedMinor;
                scanStatus = 'พบสัญญาณแล้ว';
                targetFoundTime = DateTime.now();
              });
              if (!popupShown) {
                showTargetDeviceFoundDialog(scannedMajor, scannedMinor);
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

  Map<String, dynamic>? getUuidAndMajorMinor(List<int> manufacturerData) {
    if (manufacturerData.length >= 22) {
      String uuid = manufacturerData
          .sublist(2, 18)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();

      int major = (manufacturerData[18] << 8) + manufacturerData[19];
      int minor = (manufacturerData[20] << 8) + manufacturerData[21];

      return {'uuid': uuid, 'major': major, 'minor': minor};
    }
    return null;
  }

  void showTargetDeviceFoundDialog(int? major, int? minor) {
    String formattedDateTime = targetFoundTime != null
        ? "${targetFoundTime!.year}-${targetFoundTime!.month.toString().padLeft(2, '0')}-${targetFoundTime!.day.toString().padLeft(2, '0')} ${targetFoundTime!.hour.toString().padLeft(2, '0')}:${targetFoundTime!.minute.toString().padLeft(2, '0')}:${targetFoundTime!.second.toString().padLeft(2, '0')}"
        : "ไม่ทราบวันและเวลา";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('พบบอร์ดห้องเรียนแล้ว'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รหัสวิชา: $major$minor'),
            Text('วันและเวลาที่พบ: $formattedDateTime'),
          ],
        ),
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

  Widget _buildUserInfo() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Text('เกิดข้อผิดพลาด: $_error');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ชื่อ: ${widget.firstName.isNotEmpty ? widget.firstName : 'ไม่ระบุ'} ${widget.lastName.isNotEmpty ? widget.lastName : ''}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          'เลขไอดี: ${widget.idNumber.isNotEmpty ? widget.idNumber : 'ไม่ระบุ'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'อาจารย์ผู้สอน',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'หน้าหลัก',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 195,
            left: 10,
            right: 10,
            child: Container(
              width: double.infinity,
              height: 140,
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
                      radius: 55,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/Images/usericon.png')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildUserInfo(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 160,
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
                color: deviceFound ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFunctionBox(
                    'ตรวจสอบการเข้าเรียน',
                    'การเช็คจำนวนการเข้าเรียนโดยรวมของนิสิต',
                    'assets/Images/j1.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PBox1())),
                    titlePadding: const EdgeInsets.only(left: 20),
                    descriptionPadding: const EdgeInsets.only(left: 20),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'กำหนดเวลาเข้าห้อง',
                    'ตั้งกำหนดเวลาการเข้าห้องเรียนให้กับนิสิต',
                    'assets/Images/j2.png',
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PBox2(teacherId: widget.idNumber))),
                    titlePadding: const EdgeInsets.only(left: 20, top: 5),
                    descriptionPadding: const EdgeInsets.only(left: 20, top: 5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'อนุมัติการยื่นใบลา',
                    'อนุมัติการยื่นใบลาของนิสิต',
                    'assets/Images/icon02.png',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PBox3(teacherId: widget.idNumber)),
                    ),
                    titlePadding: const EdgeInsets.only(left: 20, top: 10),
                    descriptionPadding: const EdgeInsets.only(left: 20, top: 5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'ส่งประกาศข่าวสาร',
                    'แจ้งข่าวสารให้กับนิสิตให้ได้ทราบ',
                    'assets/Images/icon04.png',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PBox4(
                          teacherId: widget.idNumber,
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                        ),
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(left: 20, top: 10),
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
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pbox5(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          idNumber: widget.idNumber,
                        ),
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 5),
                    descriptionPadding:
                        const EdgeInsets.only(left: 20, bottom: 5),
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
          // เพิ่มปุ่มรีเฟรช
          Positioned(
            top: 730,
            right: 20,
            child: FloatingActionButton(
              onPressed: checkBluetoothStatus,
              child: const Icon(
                Icons.refresh,
                size: 30.0,
              ),
              // backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
