// api_constants.dart

const String baseUrl = 'http://192.168.120.104:4000'; // URL ของเซิร์ฟเวอร์ API

// ฟังก์ชันสำหรับสร้าง URL เพื่อใช้งาน endpoint การล็อกอิน
String getLoginEndpoint() {
  return '$baseUrl/login'; // Endpoint สำหรับการล็อกอิน
}

// ฟังก์ชันสำหรับสร้าง URL เพื่อดึงข้อมูลผู้ใช้จาก API
String getUsersEndpoint() {
  return '$baseUrl/users'; // Endpoint สำหรับการดึงข้อมูลผู้ใช้
}
