const express = require('express');
const path = require('path');
const cookieSession = require('cookie-session');
const routes = require('./routes');
const dbConnection = require('./dbConnection');
const cors = require('cors'); // เพิ่ม CORS
const app = express();

// ตั้งค่า CORS
app.use(cors({
  origin: '*', // หรือกำหนด origin ที่เฉพาะเจาะจง
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// ตั้งค่า cookie-session
app.use(cookieSession({
    name: 'session',
    keys: ['key1', 'key2'], // คีย์สำหรับการเข้ารหัส
    maxAge: 24 * 60 * 60 * 1000 // อายุของ session (1 วัน)
}));

// Middleware
app.use(express.json()); // สำหรับ parsing application/json
app.use(express.urlencoded({ extended: true })); // สำหรับ parsing application/x-www-form-urlencoded
app.use(express.static(path.join(__dirname, 'public')));

// ตั้งค่า view engine เป็น ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// เพิ่ม logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
dbConnection.getConnection()
    .then(connection => {
        console.log("Database connected successfully");
        connection.release();
    })
    .catch(error => {
        console.error("Database connection failed:", error);
    });

// Routes
app.use('/', routes);

// 404 Error handler
app.use((req, res, next) => {
    const error = new Error('Not Found');
    error.status = 404;
    next(error);
});

// Global error handler
app.use((error, req, res, next) => {
    console.error('Global error handler:', error);
    res.status(error.status || 500);
    res.json({
      error: {
        message: error.message || 'Internal Server Error'
      }
    });
  });

  app.use(cors({
    origin: '*', // หรือกำหนด origin ที่เฉพาะเจาะจง
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
  }));

// Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server is running on http://localhost:${PORT}`));

module.exports = app; // เพื่อการทดสอบ