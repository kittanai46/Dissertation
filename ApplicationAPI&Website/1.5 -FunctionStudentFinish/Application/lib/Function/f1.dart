import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class f1 extends StatefulWidget {
  @override
  _f1State createState() => _f1State();
}

class _f1State extends State<f1> {
  Map<String, Map<String, bool>> _statuses = {
    'สถานะอนุญาตสิทธิ์ในการเข้าถึง': {
      'การเข้าถึงตำแหน่งที่ตั้ง': false,
      'การเข้าถึงฟังก์ชันบลูทูธ': false,
      'การเข้าถึงอัลบั้มรูปภาพ': false,
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
    _statuses['สถานะอนุญาตสิทธิ์ในการเข้าถึง']!['การเข้าถึงอัลบั้มรูปภาพ'] =
        await Permission.photos.isGranted;

    // ตรวจสอบการเชื่อมต่อ
    try {
      final result = await InternetAddress.lookup('google.com');
      _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่ออินเตอร์เน็ต'] =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่ออินเตอร์เน็ต'] = false;
    }

    _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่อกับฐานข้อมูล'] =
        true; // จำลองการเชื่อมต่อฐานข้อมูล
    _statuses['สถานะการเชื่อมต่อ']!['การเชื่อมต่อบลูทูธ'] =
        await FlutterBluePlus.isOn;

    // จำลองการค้นหาสัญญาณ
    _statuses['สถานะการค้นหาสัญญาณ']!['การค้นหาบลูทูธบริเวณโดยรอบ'] =
        false; // สมมติว่ายังไม่ได้ค้นหา
    _statuses['สถานะการค้นหาสัญญาณ']!['การค้นหาเป้าหมายสัญญาณ'] =
        false; // สมมติว่ายังไม่พบเป้าหมาย

    setState(() {});
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
            top: 90,
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
            right: 110,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/Images/Homeicon.png',
                width: 70,
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
        ],
      ),
    );
  }
}
