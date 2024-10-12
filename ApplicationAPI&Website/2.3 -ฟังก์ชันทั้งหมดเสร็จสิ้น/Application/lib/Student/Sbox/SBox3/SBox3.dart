import 'dart:io';

import 'package:ClassTracking/api_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

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
  String? _leaveDocumentName;
  String? _medicalCertificateName;

  int get currentBuddhistYear => DateTime.now().year + 543;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedCourse = null;
      _selectedLeaveType = null;
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
    } catch (e) {
      print('Error fetching student courses: $e');
      throw Exception('เกิดข้อผิดพลาดในการโหลดข้อมูลรายวิชา: $e');
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
      throw Exception('เกิดข้อผิดพลาดในการโหลดประเภทการลา: $e');
    }
  }

  String formatBuddhistDate(DateTime date) {
    final buddhistYear = date.year + 543;
    return DateFormat('d MMMM ', 'th').format(date) + buddhistYear.toString();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(currentBuddhistYear - 543),
      lastDate: DateTime(currentBuddhistYear - 543 + 1, 12, 31),
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
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  bool _isPDF(File file) {
    String extension = path.extension(file.path).toLowerCase();
    return extension == '.pdf';
  }

  Future<void> _pickFile(bool isLeaveDocument) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        if (_isPDF(file)) {
          setState(() {
            if (isLeaveDocument) {
              _leaveDocument = file;
              _leaveDocumentName = path.basename(file.path);
            } else {
              _medicalCertificate = file;
              _medicalCertificateName = path.basename(file.path);
            }
          });
        } else {
          _showErrorSnackBar('ไม่สามารถแนปไฟล์อื่นนอกจาก PDF ได้');
        }
      } else {
        print('ไม่มีไฟล์ถูกเลือก');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเลือกไฟล์: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการเลือกไฟล์: $e');
    }
  }

  void _removeFile(bool isLeaveDocument) {
    setState(() {
      if (isLeaveDocument) {
        _leaveDocument = null;
        _leaveDocumentName = null;
      } else {
        _medicalCertificate = null;
        _medicalCertificateName = null;
      }
    });
  }

  Widget _buildFileSelectionWidget(bool isLeaveDocument) {
    String buttonText =
        isLeaveDocument ? 'แนบใบลา' : 'แนบใบรับรองแพทย์ (ถ้ามี)';
    String? fileName =
        isLeaveDocument ? _leaveDocumentName : _medicalCertificateName;
    Color buttonColor = Color.fromRGBO(242, 176, 255, 1);

    return Row(
      children: [
        Container(
          width: 195,
          height: 35,
          child: ElevatedButton(
            onPressed: () => _pickFile(isLeaveDocument),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        if (fileName != null)
          Container(
            width: 170,
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey, size: 20),
                  onPressed: () => _removeFile(isLeaveDocument),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_leaveDocument == null) {
        _showErrorSnackBar('กรุณาแนบไฟล์ใบลา');
        return;
      }
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
          _resetForm();
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

  void _resetForm() {
    setState(() {
      _selectedCourse = null;
      _selectedLeaveType = null;
      _startDate = null;
      _endDate = null;
      _reason = null;
      _leaveDocument = null;
      _medicalCertificate = null;
      _leaveDocumentName = null;
      _medicalCertificateName = null;
    });
    _formKey.currentState?.reset();
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
                                            ? formatBuddhistDate(_startDate!)
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
                                            ? formatBuddhistDate(_endDate!)
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
                              SizedBox(height: 30),
                              _buildFileSelectionWidget(true),
                              SizedBox(height: 16),
                              _buildFileSelectionWidget(false),
                              SizedBox(height: 40),
                              Center(
                                child: Container(
                                  width: 360,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _submitLeaveRequest,
                                    child: Text(
                                      'ส่งใบลา',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(233, 143, 255, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
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
