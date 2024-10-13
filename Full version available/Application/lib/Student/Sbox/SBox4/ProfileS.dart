import 'dart:io';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileS extends StatefulWidget {
  final String idNumber;

  const ProfileS({Key? key, required this.idNumber}) : super(key: key);

  @override
  _ProfileSState createState() => _ProfileSState();
}

class _ProfileSState extends State<ProfileS> {
  String firstName = '';
  String lastName = '';
  String idNumber = '';
  bool isLoading = true;
  String errorMessage = '';
  File? _image;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final userData = await APIConstants.getUserData(widget.idNumber);
      setState(() {
        firstName = userData['user']['first_name'] ?? '';
        lastName = userData['user']['last_name'] ?? '';
        idNumber = userData['user']['id_number'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageChanged = true;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_image != null && _imageChanged) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', _image!.path);
      setState(() {
        _imageChanged = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_imageChanged) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('บันทึกการเปลี่ยนแปลง?'),
              content:
                  const Text('คุณต้องการบันทึกรูปภาพที่เปลี่ยนแปลงหรือไม่?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('ไม่บันทึก'),
                ),
                TextButton(
                  onPressed: () async {
                    await _saveImage();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('บันทึก'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // เพิ่มขนาดตัวอักษร
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17, // เพิ่มขนาดตัวอักษร
              color: valueColor ?? Colors.black, // ใช้สีที่ส่งเข้ามาหรือสีดำ
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
              top: 80,
              right: 90,
              child: Image.asset(
                'assets/Images/icon03.png',
                width: 50,
                height: 50,
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'บัญชีผู้ใช้',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!) as ImageProvider
                            : const AssetImage('assets/Images/usericon.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อมูลส่วนตัว',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('ชื่อ:', firstName),
                          _buildInfoRow('นามสกุล:', lastName),
                          _buildInfoRow('รหัสนิสิต:', idNumber),
                          _buildInfoRow('สถานะ:', 'นิสิตนักศึกษา',
                              valueColor: Colors.red), // สีแดงสำหรับสถานะ
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 210.0),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _saveImage();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('บันทึกรูปภาพเรียบร้อยแล้ว')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'บันทึก',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // ตัวหนา
                              fontSize: 16, // ปรับขนาดตัวอักษร
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
