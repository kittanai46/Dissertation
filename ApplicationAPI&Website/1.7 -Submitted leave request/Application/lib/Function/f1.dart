import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class f1 extends StatefulWidget {
  final bool isProfessor; // เพิ่มพารามิเตอร์เพื่อระบุว่าเป็นอาจารย์หรือนักเรียน

  f1({Key? key, required this.isProfessor}) : super(key: key);

  @override
  _f1State createState() => _f1State();
}

class _f1State extends State<f1> {
  Map<String, Map<String, bool>> _statuses = {
    'สถานะอนุญาตสิทธิ์ในการเข้าถึง': {
      'การเข้าถึงตำแหน่งที่ตั้ง': false,
      'การเข้าถึงฟังก์ชันบลูทูธ': false,
    },
    'สถานะการเชื่อมต่อ': {
      'การเชื่อมต่ออินเตอร์เน็ต': false,
      'การเชื่อมต่อกับฐานข้อมูล': false,
      'การเชื่อมต่อบลูทูธ': false,
    },
    'สถานะการค้นหาสัญญาณ': {
      'การค้นหาบลูทูธบริเวณโดยรอบ': false,
      'การค้นหาเป้าหมายสัญญาณ': false,
    },
  };

  bool isScanning = false;
  bool targetFound = false;
  final String targetUUID = "952f7b6f622c04a2a8407abf6c719dba";

  @override
  void initState() {
    super.initState();
    _checkStatuses();
  }

  Future<void> _checkStatuses() async {
    // ตรวจสอบสิทธิ์การเข้าถึง
    _statuses['สถานะอนุญาตสิทธิ์ในการเข้าถึง']!['การเข้าถึงตำแหน่งที่ตั้ง'] =
        await Permission.location.isGranted;
    _statuses['สถานะอนุญาตสิทธิ์ในการเข้าถึง']!['การเข้าถึงฟังก์ชันบลูทูธ'] =
        await Permission.bluetooth.isGranted;

    // ตรวจสอบการเชื่อมต่อ
    try {
      final result = await InternetAddress.lookup('google.com');
      _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่ออินเตอร์เน็ต'] =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่ออินเตอร์เน็ต'] = false;
    }

    _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่อกับฐานข้อมูล'] = true;
    _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่อบลูทูธ'] =
        await FlutterBluePlus.isOn;

    // เริ่มการสแกนบลูทูธ
    _startScan();

    setState(() {});
  }

  Future<void> _startScan() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      _statuses['สถานะการค้นหาสัญญาณ']!['การค้นหาบลูทูธบริเวณโดยรอบ'] = true;
      _statuses['สถานะการค้นหาสัญญาณ']!['การค้นหาเป้าหมายสัญญาณ'] = false;
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.advertisementData.manufacturerData.isNotEmpty) {
            Map<String, dynamic>? scannedData = _getUuidAndMajorMinor(
                result.advertisementData.manufacturerData.values.first);
            String? scannedUUID = scannedData?['uuid'];

            if (scannedUUID == targetUUID) {
              setState(() {
                targetFound = true;
                _statuses['สถานะการค้นหาสัญญาณ']!['การค้นหาเป้าหมายสัญญาณ'] =
                    true;
              });
              break;
            }
          }
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
    }

    await Future.delayed(Duration(seconds: 4));
    setState(() {
      isScanning = false;
    });
  }

  Map<String, dynamic>? _getUuidAndMajorMinor(List<int> manufacturerData) {
    if (manufacturerData.length >= 22) {
      String uuid = manufacturerData
          .sublist(2, 18)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();
      return {'uuid': uuid};
    }
    return null;
  }

  Widget _buildStatusContainer(String title, Map<String, bool> statuses) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ...statuses.entries
              .map((entry) => _buildStatus(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatus(String name, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isGranted ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 10),
          Expanded(child: Text(name, style: TextStyle(fontSize: 16))),
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
            top: -10,
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
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'การอนุญาตและการเชื่อมต่อ',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 20,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/Images/pack2.png',
                width: 50,
                height: 60,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
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
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: _statuses.entries
                    .map((entry) =>
                        _buildStatusContainer(entry.key, entry.value))
                    .toList(),
              ),
            ),
          ),
          Positioned(
            top: 730,
            right: 20,
            child: FloatingActionButton(
              onPressed: _checkStatuses,
              child: Icon(Icons.refresh, size: 30.0),
            ),
          ),
        ],
      ),
    );
  }
}
