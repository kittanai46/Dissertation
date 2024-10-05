import 'dart:io';

import 'package:ClassTracking/api_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SBox3 extends StatefulWidget {
  final String studentId;

  const SBox3({Key? key, required this.studentId}) : super(key: key);

  @override
  _SBox3State createState() => _SBox3State();
}

class _SBox3State extends State<SBox3> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourse;
  String? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _reason;
  File? _leaveDocument;
  File? _medicalCertificate;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _leaveTypes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _fetchStudentCourses(),
        _fetchLeaveTypes(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudentCourses() async {
    try {
      final courses = await APIConstants.getStudentCourses(widget.studentId);
      setState(() {
        _courses = courses.map((course) {
          return {
            ...course,
            'display_name':
                "${course['course_code']}[${course['section']}] - ${course['course_name']}"
          };
        }).toList();
      });
      print('Fetched courses: $_courses');
    } catch (e) {
      print('Error fetching student courses: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการโหลดข้อมูลรายวิชา: $e');
      rethrow;
    }
  }

  Future<void> _fetchLeaveTypes() async {
    try {
      final leaveTypes = await APIConstants.getLeaveTypes();
      setState(() {
        _leaveTypes = leaveTypes;
      });
    } catch (e) {
      print('Error fetching leave types: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการโหลดประเภทการลา: $e');
      rethrow;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: const Locale('th', 'TH'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.purple.shade50,
              onSurface: Colors.purple.shade700,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile(bool isLeaveDocument) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isLeaveDocument) {
            _leaveDocument = File(result.files.single.path!);
          } else {
            _medicalCertificate = File(result.files.single.path!);
          }
        });
      } else {
        print('ไม่มีไฟล์ถูกเลือก');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเลือกไฟล์: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการเลือกไฟล์: $e');
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        List<http.MultipartFile> attachments = [];

        if (_leaveDocument != null) {
          attachments.add(await http.MultipartFile.fromPath(
              'leave_document', _leaveDocument!.path));
        }

        if (_medicalCertificate != null) {
          attachments.add(await http.MultipartFile.fromPath(
              'medical_certificate', _medicalCertificate!.path));
        }

        final leaveData = {
          'student_id': widget.studentId,
          'course_id': _selectedCourse,
          'leave_type_id': _selectedLeaveType,
          'reason': _reason,
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
          'status': 'รออนุมัติ',
        };

        print('Submitting leave request with data: $leaveData');
        final result =
            await APIConstants.submitLeaveRequest(leaveData, attachments);
        print('Leave request result: $result');

        if (result['success'] == true) {
          _showSuccessSnackBar('ส่งคำขอลาเรียนสำเร็จ');
          Navigator.pop(context);
        } else {
          throw Exception(result['error'] ?? 'Unknown error occurred');
        }
      } catch (e) {
        print('Error submitting leave request: $e');
        _showErrorSnackBar('เกิดข้อผิดพลาดในการส่งคำขอลาเรียน: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
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
              child: Text(
                'การส่งใบลา',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!,
                                style: TextStyle(color: Colors.red)),
                            ElevatedButton(
                              onPressed: _fetchInitialData,
                              child: Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration:
                                    InputDecoration(labelText: 'เลือกรายวิชา'),
                                value: _selectedCourse,
                                items: _courses.map((course) {
                                  return DropdownMenuItem<String>(
                                    value: course['course_id'],
                                    child: Text(course['display_name'] ??
                                        'Unknown Course'),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCourse = newValue;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'กรุณาเลือกรายวิชา' : null,
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration:
                                    InputDecoration(labelText: 'ประเภทการลา'),
                                value: _selectedLeaveType,
                                items: _leaveTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type['id'].toString(),
                                    child: Text(
                                        type['type_name'] ?? 'Unknown Type'),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedLeaveType = newValue;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'กรุณาเลือกประเภทการลา'
                                    : null,
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'วันที่เริ่มลา'),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: _startDate != null
                                            ? DateFormat('d MMMM yyyy', 'th')
                                                .format(_startDate!)
                                            : '',
                                      ),
                                      onTap: () => _selectDate(context, true),
                                      validator: (value) => _startDate == null
                                          ? 'กรุณาเลือกวันที่เริ่มลา'
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'วันที่สิ้นสุดการลา'),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: _endDate != null
                                            ? DateFormat('d MMMM yyyy', 'th')
                                                .format(_endDate!)
                                            : '',
                                      ),
                                      onTap: () => _selectDate(context, false),
                                      validator: (value) => _endDate == null
                                          ? 'กรุณาเลือกวันที่สิ้นสุดการลา'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'เหตุผลการลา'),
                                maxLines: 3,
                                onChanged: (value) => _reason = value,
                                validator: (value) => value!.isEmpty
                                    ? 'กรุณากรอกเหตุผลการลา'
                                    : null,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _pickFile(true),
                                child: Text('แนบใบลา'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              if (_leaveDocument != null)
                                Text(
                                    'ไฟล์ที่แนบ: ${_leaveDocument?.path.split('/').last ?? 'ไม่มีไฟล์ที่เลือก'}'),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _pickFile(false),
                                child: Text('แนบใบรับรองแพทย์ (ถ้ามี)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              if (_medicalCertificate != null)
                                Text(
                                    'ไฟล์ที่แนบ: ${_medicalCertificate?.path.split('/').last ?? 'ไม่มีไฟล์ที่เลือก'}'),
                              SizedBox(height: 24),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _submitLeaveRequest,
                                  child: Text('ส่งใบลา'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
