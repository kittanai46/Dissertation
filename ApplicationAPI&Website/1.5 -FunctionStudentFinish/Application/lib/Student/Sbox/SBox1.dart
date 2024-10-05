import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//ประวัติ
class SBox1 extends StatefulWidget {
  final String idNumber;

  const SBox1({Key? key, required this.idNumber}) : super(key: key);

  @override
  _SBox1State createState() => _SBox1State();
}

class _SBox1State extends State<SBox1> {
  List<Map<String, dynamic>> attendanceData = [];
  Map<String, String> courseNames = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      final data = await APIConstants.getUserData(widget.idNumber);
      if (data['attendance'] != null) {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(data['attendance']);
          courseNames = Map<String, String>.from(data['course_names']);
        });
      } else {
        setState(() {
          errorMessage = 'ไม่พบข้อมูลการเข้าเรียน';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการดึงข้อมูล: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'ไม่มีข้อมูล';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return 'ไม่มีข้อมูล';
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'ไม่มีข้อมูล';
    try {
      if (!timeString.contains('T') && !timeString.contains(' ')) {
        return timeString;
      }
      final time = DateTime.parse(timeString).toLocal();
      return DateFormat('HH:mm:ss').format(time);
    } catch (e) {
      print('Error formatting time: $e');
      return timeString;
    }
  }

  Widget getStatusWidget(String? status) {
    String displayStatus;
    Color textColor;
    Color backgroundColor;

    switch (status?.toLowerCase()) {
      case 'absent':
        displayStatus = 'ขาด';
        textColor = Colors.white;
        backgroundColor = Colors.red;
        break;
      case 'present':
        displayStatus = 'ปกติ';
        textColor = Colors.white;
        backgroundColor = Colors.green;
        break;
      case 'late':
        displayStatus = 'สาย';
        textColor = Colors.white;
        backgroundColor = Colors.orange;
        break;
      default:
        displayStatus = status ?? 'ไม่ทราบสถานะ';
        textColor = Colors.black;
        backgroundColor = Colors.grey[300]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void showAttendanceDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'รายละเอียดการเข้าเรียน',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('รหัสวิชา:',
                    record['course_code']?.toString() ?? 'ไม่มีข้อมูล'),
                _buildDetailRow('ชื่อวิชา:',
                    courseNames[record['course_code']] ?? 'ไม่มีข้อมูล'),
                _buildDetailRow(
                    'เซค:', record['section']?.toString() ?? 'ไม่มีข้อมูล'),
                _buildDetailRow('วันที่:', formatDate(record['date'])),
                _buildDetailRow(
                    'เวลาเช็คชื่อ:', formatTime(record['check_in_time'])),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('สถานะ: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    getStatusWidget(record['status']),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('ปิด', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ),
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
            right: 20,
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
                  'ประวัติการเข้าห้องเรียน',
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
            right: 0,
            bottom: 0,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : attendanceData.isEmpty
                        ? const Center(child: Text('ไม่พบข้อมูลการเข้าเรียน'))
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'รหัสนิสิต: ${widget.idNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: attendanceData.length,
                                    itemBuilder: (context, index) {
                                      final record = attendanceData[index];
                                      final courseName =
                                          courseNames[record['course_code']] ??
                                              'ไม่มีชื่อวิชา';
                                      return Card(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: ListTile(
                                          title: Text(courseName,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(
                                              '${formatDate(record['date'])} - ${formatTime(record['check_in_time'])}'),
                                          trailing:
                                              getStatusWidget(record['status']),
                                          onTap: () =>
                                              showAttendanceDetails(record),
                                        ),
                                      );
                                    },
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
