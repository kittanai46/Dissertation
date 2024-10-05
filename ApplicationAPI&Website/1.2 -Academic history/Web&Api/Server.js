const express = require('express');
const path = require('path');
const cookieSession = require('cookie-session');
const routes = require('./routes');
const dbConnection = require('./dbConnection');
const app = express();

// ตั้งค่า cookie-session
app.use(cookieSession({
    name: 'session',
    keys: ['key1', 'key2'], // คีย์สำหรับการเข้ารหัส
    maxAge: 3600 * 1000 // อายุของ session (1 ชั่วโมง)
}));

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
dbConnection.getConnection()
    .then(connection => {
        console.log("Database connected successfully");
        connection.release();
    })
    .catch(error => {
        console.error("Database connection failed:", error);
    });

// ตั้งค่า view engine เป็น ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Routes
app.use('/', routes);

// 404 Error handler
app.use((req, res) => {
    res.status(404).send('<h1>404 Page Not Found!</h1>');
});

// Start server
app.listen(4000, () => console.log("Server is running on http://localhost:4000"));
