import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pack1 extends StatefulWidget {
  const pack1({Key? key}) : super(key: key);

  @override
  _Pack1State createState() => _Pack1State();
}

class _Pack1State extends State<pack1> {
  String? selectedThaiTitle;
  String englishTitle = '';

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController thaiFirstNameController = TextEditingController();
  final TextEditingController thaiLastNameController = TextEditingController();
  final TextEditingController englishFirstNameController =
      TextEditingController();
  final TextEditingController englishLastNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumberController.text = prefs.getString('phoneNumber') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      selectedThaiTitle = prefs.getString('selectedThaiTitle');
      thaiFirstNameController.text = prefs.getString('thaiFirstName') ?? '';
      thaiLastNameController.text = prefs.getString('thaiLastName') ?? '';
      englishFirstNameController.text =
          prefs.getString('englishFirstName') ?? '';
      englishLastNameController.text = prefs.getString('englishLastName') ?? '';
      englishTitle = prefs.getString('englishTitle') ?? '';
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumberController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('selectedThaiTitle', selectedThaiTitle ?? '');
    await prefs.setString('thaiFirstName', thaiFirstNameController.text);
    await prefs.setString('thaiLastName', thaiLastNameController.text);
    await prefs.setString('englishFirstName', englishFirstNameController.text);
    await prefs.setString('englishLastName', englishLastNameController.text);
    await prefs.setString('englishTitle', englishTitle);
  }

  Widget _buildPositionedWidget({
    required Widget child,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  Widget buildBox({
    required String title,
    required double width,
    required double height,
    required BorderRadius borderRadius,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      padding: const EdgeInsets.all(15.0),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 242, 176, 255),
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color.fromARGB(255, 143, 135, 135),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 10),
            Expanded(child: child),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildPositionedWidget(
            top: -30,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: 80,
            left: 0,
            right: 10,
            child: Center(
              child: Text(
                'บัญชีและข้อมูลส่วนตัว',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 320,
            top: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon06.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          const Positioned(
            top: 125,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage(
                  'assets/Images/usericon.png',
                ),
              ),
            ),
          ),
          Positioned(
            left: 250,
            top: 220,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon07.png',
                width: 40,
                height: 50,
              ),
            ),
          ),
          Positioned(
            top: 285,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 155,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 176, 255),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  border: Border.all(
                    color: const Color.fromARGB(255, 143, 135, 135),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'ข้อมูลพื้นฐาน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'เบอร์โทรศัพท์   : ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: phoneNumberController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'อีเมล                 : ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 350,
            top: 285,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                'assets/Images/icon07.png',
                width: 40,
                height: 50,
              ),
            ),
          ),
          Positioned(
            top: 420,
            left: 0,
            right: 0,
            child: Center(
              child: buildBox(
                title: 'ข้อมูลส่วนตัว',
                width: MediaQuery.of(context).size.width - 40,
                height: 450,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'คำนำหน้านาม(ภาษาไทย)   : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        DropdownButton<String>(
                          value: selectedThaiTitle,
                          items: <String>['นาย', 'นางสาว'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedThaiTitle = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text(
                          'ชื่อ(ภาษาไทย)        : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: thaiFirstNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'นามสกุล(ภาษาไทย)  : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: thaiLastNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'คำนำหน้า(ภาษาอังกฤษ) : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          englishTitle,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text(
                          'ชื่อ(ภาษาอังกฤษ) : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: englishFirstNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'นามสกุล(ภาษาอังกฤษ) : ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: englishLastNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _saveData();
                          },
                          child: const Text('บันทึก'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 35,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
