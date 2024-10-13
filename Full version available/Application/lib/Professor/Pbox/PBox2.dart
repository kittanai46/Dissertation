import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PBox2 extends StatefulWidget {
  final String teacherId;

  const PBox2({Key? key, required this.teacherId}) : super(key: key);

  @override
  _PBox2State createState() => _PBox2State();
}

class _PBox2State extends State<PBox2> {
  String? selectedCourseId;
  DateTime selectedDate = DateTime.now();
  TimeOfDay presentUntil = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay lateUntil = TimeOfDay(hour: 9, minute: 15);
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> attendanceRules = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    try {
      final fetchedCourses =
          await APIConstants.getTeacherCoursesForAttendance(widget.teacherId);
      setState(() {
        courses = fetchedCourses.map((course) {
          return {
            'id': '${course['course_code']}[${course['section']}]',
            'course_code': course['course_code'],
            'course_name': course['course_name'],
            'section': course['section'],
          };
        }).toList();
        isLoading = false;
      });
      print(
          'Fetched courses: $courses'); // เพิ่ม log เพื่อตรวจสอบข้อมูลที่ได้รับ
    } catch (e) {
      print('Error fetching courses: $e');
      _showSnackBar('เกิดข้อผิดพลาดในการโหลดรายวิชา');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAttendanceRules() async {
    if (selectedCourseId == null) return;

    final parts = selectedCourseId!.split('[');
    final courseCode = parts[0];
    final section = int.parse(parts[1].replaceAll(']', ''));

    setState(() => isLoading = true);
    try {
      final fetchedRules =
          await APIConstants.getAttendanceRules(courseCode, section);
      setState(() {
        attendanceRules = fetchedRules.map((rule) {
          // แปลง date เป็น String ถ้าเป็น DateTime
          if (rule['date'] is DateTime) {
            rule['date'] = (rule['date'] as DateTime).toIso8601String();
          }
          return rule;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance rules: $e');
      _showSnackBar('เกิดข้อผิดพลาดในการโหลดกฎการเข้าเรียน');
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatTime(dynamic time) {
    if (time is String) {
      final parts = time.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    } else if (time is TimeOfDay) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return 'Invalid Time';
    }
  }

  Future<void> _selectTime(BuildContext context, bool isPresentUntil) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isPresentUntil ? presentUntil : lateUntil,
    );
    if (picked != null) {
      setState(() {
        if (isPresentUntil) {
          presentUntil = picked;
        } else {
          lateUntil = picked;
        }
      });
    }
  }

  Future<void> _submitAttendanceRule() async {
    if (selectedCourseId == null) {
      _showSnackBar('กรุณาเลือกวิชา');
      return;
    }

    final parts = selectedCourseId!.split('[');
    final courseCode = parts[0];
    final section = int.parse(parts[1].replaceAll(']', ''));

    setState(() => isLoading = true);
    try {
      final result = await APIConstants.setAttendanceRule(
        courseCode: courseCode,
        section: section,
        date: selectedDate,
        presentUntil: presentUntil,
        lateUntil: lateUntil,
      );

      if (result['success'] == true) {
        _showSnackBar('บันทึกกฎการเข้าเรียนสำเร็จ', isSuccess: true);
        fetchAttendanceRules();
      } else {
        throw Exception(result['error'] ?? 'Failed to set attendance rule');
      }
    } catch (e) {
      print('Error setting attendance rule: $e');
      _showSnackBar('เกิดข้อผิดพลาดในการบันทึกกฎการเข้าเรียน: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAttendanceRule(int id) async {
    setState(() => isLoading = true);
    try {
      final success = await APIConstants.deleteAttendanceRule(id);
      if (success) {
        _showSnackBar('ลบกฎการเข้าเรียนสำเร็จ', isError: true);
        fetchAttendanceRules();
      } else {
        throw Exception('Failed to delete attendance rule');
      }
    } catch (e) {
      print('Error deleting attendance rule: $e');
      _showSnackBar('เกิดข้อผิดพลาดในการลบกฎการเข้าเรียน', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            isSuccess ? Colors.green : (isError ? Colors.red : null),
        duration: Duration(seconds: 2),
      ),
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
            top: 90,
            right: 60,
            child: Image.asset(
              'assets/Images/j2.png',
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
                'กำหนดเวลาเข้าห้อง',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Main content
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseDropdown(),
                  SizedBox(height: 20),
                  _buildDatePicker(),
                  SizedBox(height: 20),
                  _buildTimePicker(
                      'กำหนดเวลาเข้าเรียน  คือ', presentUntil, true),
                  SizedBox(height: 20),
                  _buildTimePicker('กำหนดเวลาขาดเรียน คือ', lateUntil, false),
                  SizedBox(height: 40),
                  _buildSubmitButton(),
                  SizedBox(height: 40),
                  _buildAttendanceRulesList(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'เลือกวิชา',
        border: OutlineInputBorder(),
      ),
      value: selectedCourseId,
      items: courses.map((course) {
        return DropdownMenuItem<String>(
          value: course['id'],
          child: Text(
            '${course['course_code']}[${course['section']}] - ${course['course_name']}',
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCourseId = newValue;
        });
        fetchAttendanceRules();
      },
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Expanded(
          child:
              Text('วันที่: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
        ),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('เลือกวันที่'),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, bool isPresentUntil) {
    return Row(
      children: [
        Expanded(
          child: Text('$label: ${time.format(context)}'),
        ),
        ElevatedButton(
          onPressed: () => _selectTime(context, isPresentUntil),
          child: Text('เลือกเวลา'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitAttendanceRule,
        child: Text(
          'บันทึก',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(233, 143, 255, 1),
          padding: EdgeInsets.symmetric(horizontal: 120, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceRulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'กฎการเข้าเรียนที่มีอยู่:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...attendanceRules.map((rule) {
          DateTime ruleDate;
          if (rule['date'] is String) {
            ruleDate = DateTime.parse(rule['date']);
          } else if (rule['date'] is DateTime) {
            ruleDate = rule['date'];
          } else {
            ruleDate = DateTime.now();
          }

          return Card(
            child: ListTile(
              title: Text(
                'วันที่: ${DateFormat('dd/MM/yyyy').format(ruleDate)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'กำหนดเวลาเข้าเรียน   คือ ${formatTime(rule['present_until'])}  นาที\n' +
                    'กำหนดเวลาขาดเรียน คือ ${formatTime(rule['late_until'])}  นาที',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(rule['id']),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('คุณต้องการลบกฎการเข้าเรียนนี้จริงๆ หรือไม่?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ลบ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAttendanceRule(id);
              },
            ),
          ],
        );
      },
    );
  }
}
