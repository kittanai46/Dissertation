const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');  // เพิ่มการรองรับ CORS

// สร้างแอป Express
const app = express();
const port = 4000;  // พอร์ตที่คุณต้องการใช้

// ใช้ body-parser เพื่อดึงข้อมูลจาก body ของคำขอ POST
app.use(bodyParser.json());

// เปิดการใช้งาน CORS
app.use(cors());

// ตั้งค่าการเชื่อมต่อฐานข้อมูล MySQL
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '0811652684Za@', // รหัสผ่านของ MySQL
  database: 'accout',  // ชื่อฐานข้อมูล
  port: 3306           // พอร์ต MySQL
});

// ทดสอบการเชื่อมต่อฐานข้อมูล
connection.connect((err) => {
  if (err) {
    console.error('ไม่สามารถเชื่อมต่อฐานข้อมูลได้:', err.stack);
    return;
  }
  console.log('เชื่อมต่อฐานข้อมูลเรียบร้อยแล้ว');
});

// Route สำหรับ root (GET /)
app.get('/', (req, res) => {
  res.send('เซิร์ฟเวอร์ทำงานเรียบร้อย');
});

// Route สำหรับการล็อกอิน (POST)
app.post('/login', (req, res) => {
  const { id_number, password } = req.body;  // ดึง id_number และ password จาก body ของคำขอ

  // ตรวจสอบข้อมูลจากฐานข้อมูล
  const sql = 'SELECT * FROM user WHERE id_number = ? AND password = ?';
  connection.query(sql, [id_number, password], (error, results) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }

    // ตรวจสอบว่าพบผู้ใช้หรือไม่
    if (results.length > 0) {
      res.json({ success: true, message: 'Login successful' });
    } else {
      res.json({ success: false, message: 'Invalid ID or password' });
    }
  });
});

// Route ดึงข้อมูลผู้ใช้จากตาราง user (GET /users)
app.get('/users', (req, res) => {
  const sql = 'SELECT * FROM user';  // คำสั่ง SQL ดึงข้อมูลจากตาราง user
  connection.query(sql, (error, results) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json(results);  // ส่งผลลัพธ์กลับเป็น JSON
  });
});

// เริ่มต้นเซิร์ฟเวอร์
app.listen(port, () => {
  console.log(`เซิร์ฟเวอร์ทำงานอยู่ที่ http://localhost:${port}`);
});
