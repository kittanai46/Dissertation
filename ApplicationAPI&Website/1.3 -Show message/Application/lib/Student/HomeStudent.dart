import 'dart:async';
import 'dart:io';

import 'package:ClassTracking/Student/Sbox/Sbox2/Sbox2.dart';
import 'package:ClassTracking/Student/Sbox/Sbox3/Sbox3.dart';
import 'package:ClassTracking/Student/Sbox/Sbox4/Sbox4.dart';
import 'package:ClassTracking/Student/Sbox/Sbox5/Sbox5.dart';
import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeStudent extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String idNumber;

  const HomeStudent({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
  }) : super(key: key);

  @override
  _HomeStudentState createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  bool isScanning = false;
  bool deviceFound = false;
  bool popupShown = false;
  final String targetUUID = "952f7b6f622c04a2a8407abf6c719dba";
  String scanStatus = 'ไม่ได้เปิดบลูทูธ';
  double circleTop = 175.0;
  double circleRight = 20.0;
  File? _profileImage;
  int? major;
  int? minor;
  String? _error;
  bool _isLoading = true;
  DateTime? targetFoundTime;
  bool _isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    print(
        'HomeStudent initialized with: ${widget.firstName}, ${widget.lastName}, ${widget.idNumber}');
    WidgetsBinding.instance.addPostFrameCallback((_) => checkBleSupport());
    _loadProfileImage();
    _initializeUserData();
    listenToBluetoothState();
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
      setState(() {
        _isBluetoothOn = isOn;
      });
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

  void listenToBluetoothState() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        _isBluetoothOn = state == BluetoothAdapterState.on;
      });
    });
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
                sendAttendanceData(scannedMajor!, scannedMinor!);
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

  Future<void> sendAttendanceData(int major, int minor) async {
    final DateTime now = targetFoundTime ?? DateTime.now();
    final String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final Map<String, dynamic> data = {
      'id_number': widget.idNumber,
      'major': major,
      'minor': minor,
      'schedule_date': formattedDate,
      'schedule_time': formattedTime,
    };

    try {
      print('Sending attendance data: $data');
      bool success = await APIConstants.sendAttendanceData(data);

      if (success) {
        print('Attendance data sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกการเข้าเรียนสำเร็จ')),
        );
      } else {
        print('Failed to send attendance data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกการเข้าเรียน')),
        );
      }
    } catch (e) {
      print('Error sending attendance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: $e')),
      );
    }
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
        title: const Text('พบห้องเรียนแล้ว'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Major: $major'),
            Text('Minor: $minor'),
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
          'รหัสนิสิต: ${widget.idNumber.isNotEmpty ? widget.idNumber : 'ไม่ระบุ'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            left: 0,
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
          // รูป Homeicon.png ด้านบนซ้ายของกล่องสีขาว
          Positioned(
            top: 70, // ตำแหน่งให้รูปอยู่ด้านบนกล่องเล็กน้อย
            right: 110, // ด้านซ้ายของกล่อง
            child: Opacity(
              opacity:
                  0.3, // ปรับความจางของรูป (0.0 = โปร่งใสทั้งหมด, 1.0 = เห็นชัดเจน)
              child: Image.asset(
                'assets/Images/Homeicon.png',
                width: 70, // ขนาดของไอคอน
                height: 60, // ขนาดของไอคอน
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
                    child: _buildUserInfo(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 130,
            right: 20,
            child: Icon(
              _isBluetoothOn ? Icons.bluetooth : Icons.bluetooth_disabled,
              color: _isBluetoothOn ? Colors.blue : Colors.grey,
              size: 30,
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
                color: deviceFound ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
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
                    'ประวัติการเข้าห้องเรียน',
                    'ประวัติการเข้าห้องเรียนที่ผ่านมา',
                    'assets/Images/icon03.png',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Sbox3(idNumber: widget.idNumber)),
                    ),
                    titlePadding: const EdgeInsets.only(left: 40),
                    descriptionPadding: const EdgeInsets.only(left: 40),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  buildFunctionBox(
                    'เอกสารออนไลน์',
                    'ส่งเอกสารต่างๆ เช่น การขาด การลา',
                    'assets/Images/icon02.png',
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Box2())),
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
                    'การประกาศข่าวสาร',
                    'การประกาศการแจ้งเตือนข่าวสารต่างๆ',
                    'assets/Images/icon04.png',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Sbox4(studentId: widget.idNumber)),
                    ),
                    titlePadding: const EdgeInsets.only(left: 40, top: 10),
                    descriptionPadding: const EdgeInsets.only(left: 40, top: 5),
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
                    titlePadding: const EdgeInsets.only(left: 40, bottom: 5),
                    descriptionPadding:
                        const EdgeInsets.only(left: 40, bottom: 5),
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
