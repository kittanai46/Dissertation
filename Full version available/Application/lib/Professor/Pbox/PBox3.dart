import 'dart:io';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PBox3 extends StatefulWidget {
  final String teacherId;

  const PBox3({Key? key, required this.teacherId}) : super(key: key);

  @override
  _PBox3State createState() => _PBox3State();
}

class _PBox3State extends State<PBox3> {
  List<Map<String, dynamic>> _pendingLeaveRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingLeaveRequests();
  }

  Future<void> _fetchPendingLeaveRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests =
          await APIConstants.getPendingLeaveRequests(widget.teacherId);
      setState(() {
        _pendingLeaveRequests = requests;
      });
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmApproval(String leaveRequestId, bool isApproved) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isApproved ? 'ยืนยันการอนุมัติ' : 'ยืนยันการปฏิเสธ'),
          content: Text(
              'คุณแน่ใจหรือไม่ที่จะ${isApproved ? 'อนุมัติ' : 'ปฏิเสธ'}ใบลานี้?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('ยืนยัน'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _approveLeaveRequest(leaveRequestId, isApproved);
    }
  }

  Future<void> _approveLeaveRequest(
      String leaveRequestId, bool isApproved) async {
    String? comment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: Text('เพิ่มความเห็น'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: "กรอกความเห็น (ถ้ามี)"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยืนยัน'),
              onPressed: () =>
                  Navigator.of(context).pop(commentController.text),
            ),
          ],
        );
      },
    );

    setState(() => _isLoading = true);
    try {
      final result = await APIConstants.approveLeaveRequest(
        leaveRequestId: leaveRequestId,
        teacherId: widget.teacherId,
        status: isApproved ? 'อนุมัติ' : 'ไม่อนุมัติ',
        comment: comment,
      );
      if (result['success'] == true) {
        _showSuccessSnackBar(
            isApproved ? 'อนุมัติใบลาสำเร็จ' : 'ปฏิเสธใบลาสำเร็จ');
        _fetchPendingLeaveRequests(); // Refresh the list
      } else {
        throw Exception(result['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Error in approveLeaveRequest: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLeaveDetails(Map<String, dynamic> leaveRequest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดใบลา'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('นิสิต: ${leaveRequest['student_name']}'),
                Text('รหัสนิสิต: ${leaveRequest['student_id']}'),
                Text('วิชา: ${leaveRequest['course_name']}'),
                // Text('รหัสวิชา: ${leaveRequest['course_code']}'),
                // Text('Section: ${leaveRequest['section']}'),
                Text('ประเภทการลา: ${leaveRequest['leave_type']}'),
                Text(
                    'วันที่เริ่มลา: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['start_date']))}'),
                Text(
                    'วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['end_date']))}'),
                Text('เหตุผล: ${leaveRequest['reason']}'),
                SizedBox(height: 15),
                ElevatedButton(
                  child: Text('ดูเอกสารใบลา'),
                  onPressed: () => _viewDocument(leaveRequest['id'], 'leave'),
                ),
                ElevatedButton(
                  child: Text('ดูใบรับรองแพทย์'),
                  onPressed: () => _viewDocument(leaveRequest['id'], 'medical'),
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
          content: Text('นิสิตไม่ได้แนบไฟล์$documentNameมาด้วย'),
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
      SnackBar(content: Text(message), backgroundColor: Colors.black),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
            top: 55,
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
            right: 70,
            child: Image.asset(
              'assets/Images/icon03.png',
              width: 50,
              height: 50,
            ),
          ),
          // Screen title
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'การอนุมัติใบลา',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Pending leave requests list
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _pendingLeaveRequests.isEmpty
                    ? Center(child: Text('ไม่มีใบลาที่รอการอนุมัติ'))
                    : ListView.builder(
                        itemCount: _pendingLeaveRequests.length,
                        itemBuilder: (context, index) {
                          final leaveRequest = _pendingLeaveRequests[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                  '${leaveRequest['student_name']} - ${leaveRequest['course_name']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'วันที่ลา: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['start_date']))}'),
                                  Text(
                                      'ประเภทการลา: ${leaveRequest['leave_type']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _confirmApproval(
                                        leaveRequest['id'], true),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _confirmApproval(
                                        leaveRequest['id'], false),
                                  ),
                                ],
                              ),
                              onTap: () => _showLeaveDetails(leaveRequest),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPendingLeaveRequests,
        child: Icon(Icons.refresh),
        tooltip: 'รีเฟรชข้อมูล',
      ),
    );
  }
}
