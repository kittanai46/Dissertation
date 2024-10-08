import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';

class PBox4 extends StatefulWidget {
  final String teacherId;
  final String firstName;
  final String lastName;

  const PBox4({
    Key? key,
    required this.teacherId,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  _PBox4State createState() => _PBox4State();
}

class _PBox4State extends State<PBox4> {
  List<Map<String, dynamic>> courses = [];
  String? selectedCourseCode;
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    try {
      final fetchedCourses =
          await APIConstants.getTeacherCourses(widget.teacherId);
      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() => isLoading = false);
      _showErrorSnackBar('เกิดข้อผิดพลาดในการโหลดรายวิชา: ${e.toString()}');
    }
  }

  Future<void> sendMessage() async {
    if (selectedCourseCode == null ||
        titleController.text.isEmpty ||
        messageController.text.isEmpty) {
      _showErrorSnackBar('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await APIConstants.sendCourseMessage(
        teacherId: widget.teacherId,
        courseCode: selectedCourseCode!,
        title: titleController.text,
        message: messageController.text,
      );

      if (response['success'] == true) {
        _showSuccessDialog();
        _clearForm();
      } else {
        throw Exception('Failed to send message: ${response['error']}');
      }
    } catch (e) {
      print('Error sending message: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการส่งข้อความ: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      selectedCourseCode = null;
      titleController.clear();
      messageController.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ส่งข้อความสำเร็จ'),
          content:
              Text('ข้อความและการแจ้งเตือนถูกส่งไปยังนักเรียนเรียบร้อยแล้ว'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBackButton(),
          _buildIcon(),
          _buildTitle(),
          _buildContent(),
          if (isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
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
    );
  }

  Widget _buildBackButton() {
    return Positioned(
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
    );
  }

  Widget _buildIcon() {
    return Positioned(
      top: 70,
      right: 40,
      child: Image.asset(
        'assets/Images/icon04.png',
        width: 50,
        height: 50,
      ),
    );
  }

  Widget _buildTitle() {
    return const Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'ส่งการประกาศข่าวสาร',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      bottom: 20,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดี อาจารย์ ${widget.firstName} ${widget.lastName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildCourseDropdown(),
            SizedBox(height: 20),
            _buildTitleInput(),
            SizedBox(height: 20),
            _buildMessageInput(),
            SizedBox(height: 20),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'เลือกรายวิชา',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      value: selectedCourseCode,
      items: courses.map((course) {
        return DropdownMenuItem<String>(
          value: '${course['course_code']}[${course['section']}]',
          child: Text(
            '${course['course_code']}[${course['section']}] - ${course['course_name']}',
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCourseCode = value;
        });
      },
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: 'หัวข้อ',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: messageController,
      decoration: InputDecoration(
        labelText: 'เนื้อหาข่าวสาร',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 5,
    );
  }

  Widget _buildSendButton() {
    return Center(
      child: Container(
        width: 300,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : sendMessage,
          child: Text(
            'ส่งการประกาศข่าวสาร',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(233, 143, 255, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
