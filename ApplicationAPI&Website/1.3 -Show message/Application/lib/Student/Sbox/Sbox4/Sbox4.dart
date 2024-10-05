import 'dart:convert';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Sbox4 extends StatefulWidget {
  final String studentId;

  const Sbox4({Key? key, required this.studentId}) : super(key: key);

  @override
  _Sbox4State createState() => _Sbox4State();
}

class _Sbox4State extends State<Sbox4> {
  late Future<List<dynamic>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = fetchMessages();
  }

  Future<List<dynamic>> fetchMessages() async {
    try {
      final response = await APIConstants.makeRequest(
        '/api/student_messages/${widget.studentId}',
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  void _showMessageDetails(BuildContext context, Map<String, dynamic> message) {
    final dateTime = _formatDateLong(message['created_at']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['title'] ?? 'ไม่มีหัวข้อเรื่อง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Text(
                      message['message'] ??
                          'ข้อความทดสอบการแจ้งเตือนผ่านสารจากระบบ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'วิชา: ${message['course_code'] ?? '226482'} - ${message['course_name'] ?? 'ภาษาไทย'}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'อาจารย์: ${message['teacher_name'] ?? 'Makk Noy'}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'วัน/เดือน/ปี: ${dateTime['date']}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'เวลา: ${dateTime['time']}',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Spacer(), // ดันปุ่มไปทางขวา
                    ElevatedButton(
                      child: Text('ปิด', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // กำหนดพื้นหลังเป็นสีเทา
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
            right: 50,
            child: Image.asset(
              'assets/Images/icon04.png',
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
                  'การประกาศข่าวสาร',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 270,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'หัวข้อเรื่อง :',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 140.0),
              child: FutureBuilder<List<dynamic>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('ไม่มีข้อความ'));
                  } else {
                    final messages = snapshot.data!;
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            title: Text(
                              message['title'] ?? 'ไม่มีหัวข้อ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${message['course_code'] ?? 'N/A'} - ${message['course_name'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.orange),
                            ),
                            trailing: Text(
                              _formatDateShort(message['created_at']),
                              style: TextStyle(color: Colors.grey),
                            ),
                            onTap: () => _showMessageDetails(context, message),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid Date';
    }
  }

  Map<String, String> _formatDateLong(String? dateString) {
    if (dateString == null) return {'date': 'N/A', 'time': 'N/A'};
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return {
        'date': DateFormat('dd/MM/yyyy').format(date),
        'time': DateFormat('HH:mm:ss').format(date),
      };
    } catch (e) {
      print('Error parsing date: $e');
      return {'date': 'Invalid Date', 'time': 'Invalid Time'};
    }
  }
}
