import 'dart:convert';
import 'dart:io';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Record extends StatefulWidget {
  final String studentId;

  const Record({Key? key, required this.studentId}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  List<Map<String, dynamic>> leaveHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaveHistory();
  }

  Future<void> fetchLeaveHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseURL}/api/leave-history/${widget.studentId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          leaveHistory = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave history');
      }
    } catch (e) {
      print('Error fetching leave history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'อนุมัติ':
        return '#4CAF50';
      case 'ไม่อนุมัติ':
        return '#F44336';
      case 'รออนุมัติ':
        return '#FFC107';
      default:
        return '#9E9E9E';
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'รอการตอบกลับ..';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void showLeaveDetails(Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดใบลา'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'วิชา: ${leave['course_name']} (${leave['course_code']})[${leave['section'] ?? 'N/A'}]'),
                Text('ประเภท: ${leave['leave_type']}'),
                Text(
                    'วันที่: ${formatDate(leave['start_date'])} - ${formatDate(leave['end_date'])}'),
                Text('เหตุผล: ${leave['reason']}'),
                Text(
                    'วันที่ดำเนินการ: ${formatDate(leave['approval_date'] ?? leave['action_date'])}'),
                Text('สถานะ: ${leave['action'] ?? 'รออนุมัติ'}'),
                Text('ความคิดเห็น: ${leave['comment'] ?? 'ไม่มีความคิดเห็น'}'),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('ดูเอกสารใบลา'),
                  onPressed: () =>
                      _viewDocument(leave['id'].toString(), 'leave'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text('ดูใบรับรองแพทย์'),
                  onPressed: () =>
                      _viewDocument(leave['id'].toString(), 'medical'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ปิด'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewDocument(String leaveRequestId, String documentType) async {
    try {
      final url = Uri.parse(
          '${APIConstants.baseURL}/download/$documentType/$leaveRequestId');
      print('Downloading document from: $url');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          throw Exception('ไม่พบไฟล์เอกสาร');
        }
        final tempDir = await getTemporaryDirectory();
        final file =
            File('${tempDir.path}/${documentType}_$leaveRequestId.pdf');
        await file.writeAsBytes(bytes);

        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          throw Exception('ไม่สามารถเปิดไฟล์ได้');
        }
      } else if (response.statusCode == 404) {
        _showNoFileDialog(documentType);
      } else {
        throw Exception('เกิดข้อผิดพลาดในการดาวน์โหลดไฟล์');
      }
    } catch (e) {
      print('Error viewing document: $e');
      if (e.toString().contains('ไม่พบไฟล์เอกสาร')) {
        _showNoFileDialog(documentType);
      } else {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showNoFileDialog(String documentType) {
    String documentName = documentType == 'leave' ? 'ใบลา' : 'ใบรับรองแพทย์';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ไม่พบไฟล์'),
          content: Text('ไม่พบไฟล์$documentName'),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
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
          // Back button
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
          // Right icon
          Positioned(
            top: 80,
            right: 20,
            child: Image.asset(
              'assets/Images/icon03.png',
              width: 50,
              height: 50,
            ),
          ),
          // Title
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ประวัติการลา',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Leave history list
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : leaveHistory.isEmpty
                    ? Center(child: Text('ไม่พบประวัติการลา'))
                    : ListView.builder(
                        itemCount: leaveHistory.length,
                        itemBuilder: (context, index) {
                          final leave = leaveHistory[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: InkWell(
                              onTap: () => showLeaveDetails(leave),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${leave['course_name'] ?? 'N/A'} ${leave['course_code'] ?? 'N/A'}[${leave['section'] ?? 'N/A'}]',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'ประเภท: ${leave['leave_type'] ?? 'N/A'}'),
                                    Text(
                                        'วันที่: ${formatDate(leave['start_date'])} - ${formatDate(leave['end_date'])}'),
                                    Text('เหตุผล: ${leave['reason'] ?? 'N/A'}'),
                                    Text(
                                        'วันที่ดำเนินการ: ${formatDate(leave['approval_date'] ?? leave['action_date'])}'),
                                    if (leave['comment'] != null)
                                      Text('ความคิดเห็น: ${leave['comment']}'),
                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(getStatusColor(
                                                  leave['action'] ??
                                                      'รออนุมัติ')
                                              .replaceAll('#', '0xFF'))),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          leave['action'] ?? 'รออนุมัติ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
