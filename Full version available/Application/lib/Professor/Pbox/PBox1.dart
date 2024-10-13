import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class PBox1 extends StatefulWidget {
  final String teacherId;

  const PBox1({Key? key, required this.teacherId}) : super(key: key);

  @override
  _PBox1State createState() => _PBox1State();
}

class _PBox1State extends State<PBox1> {
  List<Map<String, dynamic>> courses = [];
  String? selectedCourseCode;
  String? selectedSection;
  DateTime? startDate;
  DateTime? endDate;
  Map<String, dynamic>? attendanceSummary;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH', null).then((_) {
      _loadTeacherCourses();
    });
  }

  Future<void> _loadTeacherCourses() async {
    setState(() => isLoading = true);
    try {
      final teacherCourses =
          await APIConstants.getPBox1TeacherCourses(widget.teacherId);
      setState(() {
        courses = teacherCourses;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading teacher courses: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดรายวิชาได้')),
      );
    }
  }

  Future<void> _fetchAttendanceSummary() async {
    if (selectedCourseCode == null ||
        selectedSection == null ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกข้อมูลให้ครบทุกช่อง')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final summary = await APIConstants.getPBox1AttendanceSummary(
        selectedCourseCode!,
        selectedSection!,
        DateFormat('yyyy-MM-dd').format(startDate!),
        DateFormat('yyyy-MM-dd').format(endDate!),
      );

      setState(() {
        attendanceSummary = summary;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance summary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลสรุปการเข้าเรียนได้')),
      );
      setState(() => isLoading = false);
    }
  }

  String _formatShortThaiDate(DateTime date) {
    final thaiMonthsAbbr = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    final day = date.day;
    final month = thaiMonthsAbbr[date.month - 1];
    final year = date.year + 543; // Convert to Buddhist Era
    return '$day $month $year';
  }

  String _formatFullThaiDate(DateTime date) {
    final thaiDays = [
      'อาทิตย์',
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์'
    ];
    final thaiMonths = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    final dayName = thaiDays[date.weekday % 7];
    final day = date.day;
    final month = thaiMonths[date.month - 1];
    final year = date.year + 543; // Convert to Buddhist Era
    return 'วัน$dayName ที่ $day $month $year';
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
            top: 90,
            right: 50,
            child: Image.asset(
              'assets/Images/j1.png',
              width: 40,
              height: 50,
            ),
          ),
          // Title
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'ตรวจสอบการเข้าเรียน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'เลือกรายวิชา',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCourseCode,
                        hint: Text('เลือกวิชา'),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCourseCode = newValue;
                            selectedSection = courses
                                .firstWhere((course) =>
                                    course['course_code'] ==
                                    newValue)['section']
                                .toString();
                          });
                        },
                        items: courses.map<DropdownMenuItem<String>>(
                            (Map<String, dynamic> course) {
                          return DropdownMenuItem<String>(
                            value: course['course_code'],
                            child: Text(
                                '${course['course_code']}[${course['section']}] - ${course['course_name']} '),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'วันที่เริ่มต้น',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  startDate = picked;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startDate == null
                                      ? 'เลือกวันที่เริ่มต้น'
                                      : _formatShortThaiDate(startDate!),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'วันที่สิ้นสุด',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  endDate = picked;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endDate == null
                                      ? 'เลือกวันที่สิ้นสุด'
                                      : _formatShortThaiDate(endDate!),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      child: Text(
                        'กดที่นี้เพื่อแสดงข้อมูล',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(233, 143, 255, 1),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _fetchAttendanceSummary,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (attendanceSummary != null)
                    _buildSummaryWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryWidget() {
    if (attendanceSummary == null || attendanceSummary!.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลการเข้าเรียน'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'รายวิชา: ${attendanceSummary!['course_name'] ?? 'ไม่ระบุ'} ${attendanceSummary!['course_code'] ?? 'ไม่ระบุ'}'),
        Text('กลุ่มเรียน: ${attendanceSummary!['section'] ?? 'ไม่ระบุ'}'),
        Text(
            'จำนวนนิสิตทั้งหมด: ${attendanceSummary!['total_students'] ?? 'ไม่ระบุ'}'),
        SizedBox(height: 10),
        Text('สรุปการเข้าเรียน:'),
        if (attendanceSummary!['summary'] == null ||
            attendanceSummary!['summary'].isEmpty)
          Text('ไม่พบข้อมูลสรุปการเข้าเรียน')
        else
          ...attendanceSummary!['summary'].entries.map((entry) {
            final dateString = entry.key;
            final daySummary = entry.value;

            if (daySummary == null || !(daySummary is Map)) {
              return ListTile(
                  title: Text('ข้อมูลไม่ถูกต้องสำหรับวันที่: $dateString'));
            }

            final date =
                DateFormat('EEE MMM dd yyyy HH:mm:ss').parse(dateString, true);
            final thaiDate = _formatFullThaiDate(date.toLocal());

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      thaiDate,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusWidget(
                          'ปกติ',
                          (daySummary['present'] ?? 0).toString(),
                          Colors.green),
                      _buildStatusWidget('สาย',
                          (daySummary['late'] ?? 0).toString(), Colors.orange),
                      _buildStatusWidget('ขาด',
                          (daySummary['absent'] ?? 0).toString(), Colors.red),
                      _buildStatusWidget('ลา',
                          (daySummary['leave'] ?? 0).toString(), Colors.blue),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildStatusWidget(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 4),
        Text('$count คน'),
      ],
    );
  }
}
