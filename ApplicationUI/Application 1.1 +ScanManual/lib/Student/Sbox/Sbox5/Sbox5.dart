import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ClassTracking/Student/Sbox/Sbox5/pack1.dart';
import 'package:ClassTracking/Function/f1.dart';
import 'package:ClassTracking/Function/f2.dart';
import 'package:ClassTracking/Function/f3.dart';
import 'package:ClassTracking/Login/login.dart';

class Box5 extends StatefulWidget {
  const Box5({Key? key}) : super(key: key);

  @override
  _Box5State createState() => _Box5State();
}

class _Box5State extends State<Box5> {
  String userName = 'ชื่อผู้ใช้';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String? firstName = prefs.getString('thaiFirstName');
      String? lastName = prefs.getString('thaiLastName');
      if (firstName != null && lastName != null) {
        userName = '$firstName $lastName';
      }
    });
  }

  void _navigateToPack1() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const pack1()),
    );

    if (result != null) {
      setState(() {
        userName = '${result['thaiFirstName']} ${result['thaiLastName']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildPositionedWidget(
            top: -20,
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
          _buildPositionedWidget(
            top: 60,
            left: 15,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          _buildPositionedWidget(
            top: 90,
            left: 0,
            right: 10,
            child: const Center(
              child: Text(
                'การตั้งค่า',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildPositionedWidget(
            top: MediaQuery.of(context).size.height / 5 - 30,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage(
                      'assets/Images/usericon.png',
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildOptionBox(
            context: context,
            image: 'assets/Images/pack1.png',
            title: 'บัญชี',
            subtitle: 'บัญชีผู้ใช้ ข้อมูลส่วนตัวและโปรไฟล์',
            navigateTo: const pack1(),
            top: 380,
            onTap: _navigateToPack1,
          ),
          _buildOptionBox(
            context: context,
            image: 'assets/Images/pack2.png',
            title: 'แจ้งเตือนและสิทธิ์',
            subtitle: 'การอนุญาตการขอสิทธิ์และแจ้งเตือน',
            navigateTo: f1(),
            top: 470,
          ),
          _buildOptionBox(
            context: context,
            image: 'assets/Images/pack3.png',
            title: 'คู่มือการใช้งาน',
            subtitle: 'คู่มือและวิธีการใช้งานโดยเบื้องต้น',
            navigateTo: const f2(),
            top: 560,
          ),
          _buildOptionBox(
            context: context,
            image: 'assets/Images/pack4.png',
            title: 'เกี่ยวกับแอพพลิเคชัน',
            subtitle: 'ข้อมูลต่างๆที่เกี่ยวกับแอพพลิเคชัน',
            navigateTo: const f3(),
            top: 650,
          ),
          _buildPositionedWidget(
            left: MediaQuery.of(context).size.width - 150,
            top: 90,
            child: Padding(
              padding: const EdgeInsets.only(right: 100),
              child: Image.asset(
                'assets/Images/icon05.png',
                width: 60,
                height: 45,
              ),
            ),
          ),
          _buildPositionedWidget(
            bottom: 20,
            right: 20,
            child: LogoutButton(),
          ),
        ],
      ),
    );
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

  Widget _buildOptionBox({
    required BuildContext context,
    required String image,
    required String title,
    required String subtitle,
    required Widget navigateTo,
    required double top,
    VoidCallback? onTap,
  }) {
    return _buildPositionedWidget(
      top: top,
      left: (MediaQuery.of(context).size.width - 360) / 2,
      child: GestureDetector(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => navigateTo),
              );
            },
        child: OptionBox(
          image: image,
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }
}

class OptionBox extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OptionBox({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 90,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 242, 176, 255),
        borderRadius: title == 'บัญชี'
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : title == 'เกี่ยวกับแอพพลิเคชัน'
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : BorderRadius.circular(0),
        border: title != 'บัญชี'
            ? const Border(
                top: BorderSide(
                  color: Color.fromARGB(255, 143, 135, 135),
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              image,
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Image.asset(
              'assets/Images/arrow.png',
              width: 50,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("ยืนยันการออกจากระบบ"),
              content: const Text("คุณแน่ใจหรือไม่ที่จะออกจากระบบ?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          'assets/Images/exit.png',
          width: 40,
          height: 50,
        ),
      ),
    );
  }
}
