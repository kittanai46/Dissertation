// routes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const dbConnection = require('./dbConnection');



// Middleware
const ifNotLoggedIn = (req, res, next) => {
    if (!req.session.isLoggedIn) {
        return res.render('login');
    }
    next();
};

const ifLoggedin = (req, res, next) => {
    if (req.session.isLoggedIn)  {
        return res.redirect('/home');
    }
    next();
};

const ownsCourse = async (req, res, next) => {
    const userId = req.session.userID;
    
    // ตรวจสอบว่าพารามิเตอร์มาจาก req.params หรือ req.body
    const courseCode = req.params.courseCode || req.body.courseCode;
    const section = req.params.section || req.body.section;

    // ตรวจสอบว่าค่าของ userId, courseCode และ section มีหรือไม่
    if (!userId || !courseCode || !section) {
        console.error('Missing parameters:', { userId, courseCode, section });
        return res.status(400).send('Bad request: Missing required parameters');
    }

    try {
        const [[course]] = await dbConnection.execute(`
            SELECT c.course_code, c.section
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE c.course_code = ? AND c.section = ? AND ct.teacher_id = ?`, 
            [courseCode, section, userId]
        );

        if (!course) {
            return res.status(403).send('Forbidden: You do not have permission to access this course');
        }

        next(); // ตรวจสอบผ่านแล้ว ไปยังขั้นตอนถัดไป
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
};
module.exports = { ownsCourse };

const ownsCourseFromBody = async (req, res, next) => {
    const userId = req.session.userID;
    const { courseCode, section } = req.body; // ดึงข้อมูลจาก req.body

    if (!userId || !courseCode || !section) {
        console.error('Missing parameters:', { userId, courseCode, section });
        return res.status(400).send('Bad request: Missing required parameters');
    }

    try {
        const [[course]] = await dbConnection.execute(`
            SELECT c.course_code, c.section
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE c.course_code = ? AND c.section = ? AND ct.teacher_id = ?`, 
            [courseCode, section, userId]
        );

        if (!course) {
            return res.status(403).send('Forbidden: You do not have permission to access this course');
        }

        next();
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
};

// Route definitions

// Root page
router.get('/', ifLoggedin, (req, res) => {
    res.redirect('/home');
});

// HOME PAGE
router.get('/home', ifNotLoggedIn, async (req, res) => {
    const teacherId = req.session.userID;
    if (!teacherId) {
        return res.redirect('/login');
    }
    try {
        const [[user]] = await dbConnection.execute('SELECT role FROM users WHERE id_number = ?', [teacherId]);
        if (!user || user.role !== 'teacher') {
            return res.status(403).send('Forbidden: Only teachers can access this page');
        }

        // ดึงข้อมูลรายวิชาที่อาจารย์สอน
        const [rows] = await dbConnection.execute(`
            SELECT c.course_code, c.course_name, c.section, c.year
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ?
        `, [teacherId]);

        const courses = rows.map(row => ({
            course_code: row.course_code,
            name: `${row.course_code} - ${row.course_name}`,
            year: row.year,
            section: row.section
        }));

        res.render('home', { subjects: courses });
    } catch (err) {
        console.error(err);
        res.status(500).send('An error occurred');
    }
});

// REGISTER
router.post('/register', [
    body('role').isIn(['student', 'teacher']).withMessage('Invalid role selected!'),
    body('first_name').trim().not().isEmpty().withMessage('First Name cannot be empty!'),
    body('last_name').trim().not().isEmpty().withMessage('Last Name cannot be empty!'),
    body('id_number').trim().not().isEmpty().withMessage('ID Number cannot be empty!')
        .custom(async (value) => {
            const [rows] = await dbConnection.execute('SELECT `id_number` FROM `users` WHERE `id_number`=?', [value]);
            if (rows.length > 0) {
                throw new Error('This ID Number is already in use!');
            }
        }),
    body('password').trim().isLength({ min: 6 }).withMessage('The password must be at least 6 characters long'),
], async (req, res) => {
    const errors = validationResult(req);
    if (errors.isEmpty()) {
        const { first_name, last_name, id_number, password, role } = req.body;
        try {
            const hashedPassword = await bcrypt.hash(password, 12);
            await dbConnection.execute(
                "INSERT INTO `users`(`first_name`, `last_name`, `id_number`, `password`, `role`) VALUES(?,?,?,?,?)",
                [first_name, last_name, id_number, hashedPassword, role]
            );
            res.send(`Your account has been created successfully. Now you can <a href="/">Login</a>`);
        } catch (err) {
            console.error(err);
            res.status(500).send('An error occurred during registration');
        }
    } else {
        res.render('register', {
            register_errors: errors.array().map(error => error.msg),
            old_data: req.body
        });
    }
});

// Login
router.post('/', [
    body('id_number').trim().not().isEmpty().withMessage('ID Number cannot be empty!'),
    body('password').trim().not().isEmpty().withMessage('Password cannot be empty!'),
], async (req, res) => {
    const errors = validationResult(req);
    if (errors.isEmpty()) {
        const { password, id_number } = req.body;
        try {
            const [rows] = await dbConnection.execute("SELECT * FROM users WHERE id_number=?", [id_number]);
            if (rows.length > 0) {
                const user = rows[0];
                const isMatch = await bcrypt.compare(password, user.password);
                if (isMatch) {
                    if (user.role === 'teacher') {
                        req.session.isLoggedIn = true;
                        req.session.userID = user.id_number;
                        res.redirect('home');
                    } else {
                        res.render('login', { login_errors: ['Access denied. Only teachers can log in.'] });
                    }
                } else {
                    res.render('login', { login_errors: ['Invalid Password!'] });
                }
            } else {
                res.render('login', { login_errors: ['Invalid ID Number!'] });
            }
        } catch (err) {
            console.error(err);
            res.status(500).send('An error occurred during login');
        }
    } else {
        res.render('login', { login_errors: errors.array().map(error => error.msg) });
    }
});
//-----------------------------------------------------------------------------
// ล็อกอินแอพ
router.post('/login', async (req, res) => {
    const { id_number, password } = req.body;

    if (!id_number || !password) {
        return res.status(400).json({ success: false, error: 'ID number and password are required' });
    }

    try {
        const [rows] = await dbConnection.execute("SELECT * FROM users WHERE id_number = ?", [id_number]);

        if (rows.length > 0) {
            const user = rows[0];
            const isMatch = await bcrypt.compare(password, user.password);

            if (isMatch) {
                req.session.isLoggedIn = true;
                req.session.userID = user.id_number;
                req.session.role = user.role;

                return res.status(200).json({
                    success: true,
                    message: 'Login successful',
                    user: {
                        id_number: user.id_number,
                        first_name: user.first_name,
                        last_name: user.last_name,
                        role: user.role
                    }
                });
            } else {
                return res.status(401).json({ success: false, error: 'Invalid password' });
            }
        } else {
            return res.status(401).json({ success: false, error: 'Invalid ID number' });
        }
    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, error: 'An error occurred during login' });
    }
});

// Route สำหรับบันทึกการเข้าเรียน
router.post('/log_attendance', async (req, res) => {
    const { id_number, major, minor, schedule_date, schedule_time } = req.body;

    if (!id_number || major === undefined || minor === undefined || !schedule_date || !schedule_time) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        const [result] = await dbConnection.execute(
            'INSERT INTO log_attendance (id_number, major, minor, schedule_date, schedule_time) VALUES (?, ?, ?, ?, ?)',
            [id_number, major, minor, schedule_date, schedule_time]
        );

        console.log('Attendance recorded:', { id_number, major, minor, schedule_date, schedule_time, insertId: result.insertId });

        res.status(200).json({
            message: 'Attendance recorded successfully',
            recordId: result.insertId
        });
    } catch (error) {
        console.error('Error recording attendance:', error);
        res.status(500).json({ error: 'Failed to record attendance' });
    }
});

//-----------------------------------------------------------------------------

// LOGOUT
router.get('/logout', (req, res) => {
    req.session = null;
    res.redirect('/');
});

// Classroom
router.get('/Classroom', ifNotLoggedIn, async (req, res) => {
    const teacherId = req.session.userID;
    if (!teacherId) {
        return res.redirect('/login');
    }
    try {
        const [rows] = await dbConnection.execute(`
            SELECT c.course_code, c.course_name, c.section, c.year
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ?
        `, [teacherId]);

        const courses = rows.map(row => ({
            course_code: row.course_code,
            name: `${row.course_code} - ${row.course_name}`,
            year: row.year,
            section: row.section
        }));

        res.render('Classroom', { subjects: courses });
    } catch (err) {
        console.error(err);
        res.status(500).send('An error occurred');
    }
});

// Student list
// Route แสดงรายการนักเรียนและการเช็คชื่อ
router.get('/students/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;

    try {
        // ดึงข้อมูลนักเรียน
        const [students] = await dbConnection.execute(`
            SELECT s.id_number, u.first_name, u.last_name
            FROM students s
            JOIN users u ON s.id_number = u.id_number
            JOIN enrollments e ON s.id_number = e.student_id
            WHERE e.course_code = ? AND e.section = ?
        `, [courseCode, section]);

        // ดึงข้อมูลกฎการเช็คชื่อ
        const [rules] = await dbConnection.execute(`
            SELECT date, DATE_FORMAT(date, '%d/%m/%y') AS short_date
            FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);

        // ดึงข้อมูลการเช็คชื่อ
        const [attendances] = await dbConnection.execute(`
            SELECT student_id, date, status
            FROM attendance
            WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        // จัดรูปแบบข้อมูลเพื่อส่งไปแสดงผลในหน้าเว็บ
        const studentsWithAttendance = students.map(student => {
            const studentAttendance = rules.map(rule => {
                const attendance = attendances.find(a => 
                    a.student_id === student.id_number && 
                    a.date.toISOString().split('T')[0] === rule.date.toISOString().split('T')[0]
                );
                return attendance ? attendance.status : null;
            });
            return { ...student, attendance: studentAttendance };
        });

        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        // ส่งข้อมูลไปยังหน้า student_list.ejs
        res.render('student_list', {
            students: studentsWithAttendance,
            dates: rules.map(r => ({
                short_date: r.short_date
            })),
            courseCode,
            section,
            courseName: course ? course.course_name : "Unknown Course"
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});


// Student list edit route
router.get('/students/:courseCode/:section/edit', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    
    try {
        const [students] = await dbConnection.execute(`
            SELECT s.id_number, u.first_name, u.last_name
            FROM students s
            JOIN users u ON s.id_number = u.id_number
            JOIN enrollments e ON s.id_number = e.student_id
            WHERE e.course_code = ? AND e.section = ?
        `, [courseCode, section]);

        const [rules] = await dbConnection.execute(`
            SELECT date, DATE_FORMAT(date, '%d/%m/%y') AS short_date
            FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);

        const [attendances] = await dbConnection.execute(`
            SELECT student_id, date, status
            FROM attendance
            WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        const studentsWithAttendance = students.map(student => {
            const studentAttendance = rules.map(rule => {
                const attendance = attendances.find(a => 
                    a.student_id === student.id_number && 
                    a.date.toISOString().split('T')[0] === rule.date.toISOString().split('T')[0]
                );
                return attendance ? attendance.status : null;
            });
            return { ...student, attendance: studentAttendance };
        });

        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        res.render('student_list_edit', {
            students: studentsWithAttendance,
            dates: rules,
            courseCode,
            section,
            courseName: course ? course.course_name : "Unknown Course"
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

//----------------------------------------------------//

// Get attendance rules
router.get('/api/attendance-rules/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    try {
        const [rules] = await dbConnection.execute(`
            SELECT * FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);
        res.json(rules);
    } catch (error) {
        console.error('Error fetching attendance rules:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Save attendance rule
router.post('/api/attendance-rules', ifNotLoggedIn, ownsCourseFromBody, async (req, res) => {
    const { courseCode, section, date, presentUntil, lateUntil } = req.body;
    try {
        await dbConnection.execute(`
            INSERT INTO attendance_rules (course_code, section, date, present_until, late_until)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE present_until = ?, late_until = ?
        `, [courseCode, section, date, presentUntil, lateUntil, presentUntil, lateUntil]);
        res.json({ success: true });
    } catch (error) {
        console.error('Error saving attendance rule:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Delete attendance rule
router.delete('/api/attendance-rules/:id', ifNotLoggedIn, async (req, res) => {
    const { id } = req.params;
    try {
        await dbConnection.execute(`
            DELETE FROM attendance_rules WHERE id = ?
        `, [id]);
        res.json({ success: true });
    } catch (error) {
        console.error('Error deleting attendance rule:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});


// Attendance Rules page
router.get('/attendance-rules/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    try {
        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        const [rules] = await dbConnection.execute(`
            SELECT * FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);

        res.render('AttendanceRules', { 
            courseCode,
            section,
            courseName: course ? course.course_name : "Unknown Course",
            attendanceRules: rules
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Save attendance
router.post('/save-attendance', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section, attendance } = req.body;

    try {
        for (const [studentId, dates] of Object.entries(attendance)) {
            for (const [date, status] of Object.entries(dates)) {
                if (status) {
                    const [[rule]] = await dbConnection.execute(`
                        SELECT * FROM attendance_rules
                        WHERE course_code = ? AND section = ? AND date = ?
                    `, [courseCode, section, date]);

                    let calculatedStatus = status;
                    if (rule) {
                        const now = new Date();  // เวลาปัจจุบัน
                        const presentUntil = new Date(`${date}T${rule.present_until}`);
                        const lateUntil = new Date(`${date}T${rule.late_until}`);

                        if (now <= presentUntil) {
                            calculatedStatus = 'present';  // มาทันเวลา
                        } else if (now <= lateUntil) {
                            calculatedStatus = 'late';  // มาสาย
                        } else {
                            calculatedStatus = 'absent';  // ขาดเรียน
                        }
                    }

                    await dbConnection.execute(`
                        INSERT INTO attendance (course_code, section, student_id, date, status)
                        VALUES (?, ?, ?, ?, ?)
                        ON DUPLICATE KEY UPDATE status = ?
                    `, [courseCode, section, studentId, date, calculatedStatus, calculatedStatus]);
                }
            }
        }
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error saving attendance:', error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

module.exports = router;
