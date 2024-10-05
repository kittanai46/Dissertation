// routes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const dbConnection = require('./dbConnection');
const { parseISO, isAfter, formatISO } = require('date-fns');
const dateFns = require('date-fns');
const { format } = require('date-fns');
const multer = require('multer');
const upload = multer();


// ฟังก์ชันสำหรับแปลงวันที่เป็นรูปแบบ YYYY-MM-DD
function formatDateForMySQL(dateString) {
    const date = new Date(dateString);
    return format(date, 'yyyy-MM-dd');
}

function getStatusClass(status) {
    switch (status) {
        case 'present': return 'bg-success text-white';
        case 'late': return 'bg-warning text-dark';
        case 'absent': return 'bg-danger text-white';
        case 'leave': return 'bg-leave text-white';
        default: return 'text-white';
    }
}



// Middleware
const ifNotLoggedIn = (req, res, next) => {
    if (!req.session.isLoggedIn) {
        return res.render('login');
    }
    next();
};

const ifLoggedin = (req, res, next) => {
    if (req.session.isLoggedIn) {
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
// REGISTER
router.get('/register', (req, res) => {
    res.render('register');
});

// / Page
router.get('/login', (req, res) => {
    res.render('login');
});

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
        // ดึงข้อมูล role ของผู้ใช้
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
            course_name: row.course_name,
            name: `${row.course_code} - ${row.course_name}`,
            year: row.year,
            section: row.section
        }));

        // ดึงรูปภาพตารางสอนที่สัมพันธ์กับอาจารย์
        const [[scheduleImage]] = await dbConnection.execute(`
            SELECT schedule_image_url 
            FROM teacher_schedule_images 
            WHERE teacher_id = ?
        `, [teacherId]);

        // ส่ง URL รูปภาพไปยัง view ด้วย ถ้าไม่มีรูปภาพให้ใช้ค่าเริ่มต้น
        const scheduleImageUrl = scheduleImage ? scheduleImage.schedule_image_url : '/images/default_schedule.png';

        // ส่งข้อมูลไปที่ view
        res.render('home', {
            subjects: courses,
            scheduleImageUrl: scheduleImageUrl  // ส่ง URL ของรูปภาพตารางสอนไปด้วย
        });
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
            course_name: row.course_name,
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
// Route สำหรับแสดงผลข้อมูลในหน้าเว็บ
router.get('/students_class/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    try {
        await scheduleAttendanceCheck();

        const [students] = await dbConnection.execute(`
            SELECT s.id_number, u.first_name, u.last_name
            FROM students s
            JOIN users u ON s.id_number = u.id_number
            JOIN enrollments e ON s.id_number = e.student_id
            WHERE e.course_code = ? AND e.section = ?
        `, [courseCode, section]);

        const [rules] = await dbConnection.execute(`
            SELECT date, DATE_FORMAT(date, '%d/%m/%Y') AS short_date
            FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);

        const [attendances] = await dbConnection.execute(`
            SELECT student_id, date, status, check_in_time, is_edited
            FROM attendance
            WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        const studentsWithAttendance = students.map(student => {
            const studentAttendance = rules.map(rule => {
                const attendance = attendances.find(a =>
                    a.student_id === student.id_number &&
                    a.date.toISOString().split('T')[0] === rule.date.toISOString().split('T')[0]
                );
                return attendance ? {
                    status: attendance.status,
                    check_in_time: attendance.check_in_time ? attendance.check_in_time.slice(0, 5) : null,
                    is_edited: attendance.is_edited
                } : null;
            });

            return {
                ...student,
                attendance: studentAttendance
            };
        });

        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        res.render('student_list', {
            students: studentsWithAttendance,
            dates: rules,
            courseCode,
            section,
            courseName: course ? course.course_name : "Unknown Course",
            getStatusClass: getStatusClass // ส่งฟังก์ชันนี้ไปยัง EJS
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
            SELECT date, DATE_FORMAT(date, '%d/%m/%Y') AS short_date
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
            dates: rules.map(rule => ({
                date: rule.date,
                short_date: rule.short_date
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

//----------------------------------------------------//

// Get attendance rules
router.get('/attendance-rules/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    try {
        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        const [rules] = await dbConnection.execute(`
            SELECT id, course_code, section, 
                   DATE_FORMAT(date, '%d/%m/%Y') as display_date,
                   DATE_FORMAT(date, '%Y-%m-%d') as edit_date, 
                   present_until, late_until
            FROM attendance_rules
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

    console.log('Received data:', { courseCode, section, attendanceCount: Object.keys(attendance).length });

    if (!courseCode || !section || !attendance) {
        console.error('Missing required fields:', { courseCode, section, attendance });
        return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    const connection = await dbConnection.getConnection();
    try {
        await connection.beginTransaction();

        let updatedCount = 0;
        let insertedCount = 0;

        for (const [studentId, dates] of Object.entries(attendance)) {
            for (const [date, status] of Object.entries(dates)) {
                if (status) {
                    const formattedDate = formatDateForMySQL(date);
                    console.log(`Processing: Student ${studentId}, Date ${formattedDate}, Status ${status}`);
                    
                    try {
                        // ตรวจสอบว่ามีการบันทึกการเข้าเรียนสำหรับวันนี้แล้วหรือไม่
                        const [existingAttendance] = await connection.execute(`
                            SELECT * FROM attendance
                            WHERE course_code = ? AND section = ? AND student_id = ? AND date = ?
                        `, [courseCode, section, studentId, formattedDate]);

                        if (existingAttendance.length > 0) {
                            // ถ้ามีข้อมูลอยู่แล้วและสถานะเปลี่ยน ให้อัพเดทและตั้งค่า is_edited เป็น true
                            if (existingAttendance[0].status !== status) {
                                await connection.execute(`
                                    UPDATE attendance
                                    SET status = ?, is_edited = TRUE
                                    WHERE course_code = ? AND section = ? AND student_id = ? AND date = ?
                                `, [status, courseCode, section, studentId, formattedDate]);
                                console.log(`Updated attendance for student ${studentId} on ${formattedDate}. New status: ${status}`);
                                updatedCount++;
                            } else {
                                console.log(`No change in attendance for student ${studentId} on ${formattedDate}. Skipping.`);
                            }
                        } else {
                            // บันทึกข้อมูลการเข้าเรียนใหม่
                            await connection.execute(`
                                INSERT INTO attendance (course_code, section, student_id, date, status, check_in_time)
                                VALUES (?, ?, ?, ?, ?, TIME(NOW()))
                            `, [courseCode, section, studentId, formattedDate, status]);
                            console.log(`Inserted new attendance for student ${studentId} on ${formattedDate}. Status: ${status}`);
                            insertedCount++;
                        }
                    } catch (error) {
                        console.error(`Error processing student ${studentId} on ${formattedDate}:`, error);
                        throw error; // Re-throw to be caught by the outer try-catch
                    }
                }
            }
        }

        // ส่วนของการมาร์ค 'absent' สำหรับนักเรียนที่ไม่ได้เช็คชื่อ
        const todayFormatted = formatDateForMySQL(new Date());
        const [rules] = await connection.execute(`
            SELECT * FROM attendance_rules
            WHERE course_code = ? AND section = ? AND date = ?
        `, [courseCode, section, todayFormatted]);

        if (rules.length > 0) {
            const rule = rules[0];
            const lateUntil = parseISO(`${todayFormatted}T${rule.late_until}`);
            const now = new Date();

            console.log(`Checking for absent students. Current time: ${now}, Late until: ${lateUntil}`);

            if (now > lateUntil) {
                const [students] = await connection.execute(`
                    SELECT e.student_id
                    FROM enrollments e
                    LEFT JOIN attendance a ON e.student_id = a.student_id AND a.date = ?
                    WHERE e.course_code = ? AND e.section = ? AND a.student_id IS NULL
                `, [todayFormatted, courseCode, section]);

                console.log(`Found ${students.length} students without attendance records for today.`);

                for (const student of students) {
                    const [existingAttendance] = await connection.execute(`
                        SELECT * FROM attendance
                        WHERE course_code = ? AND section = ? AND student_id = ? AND date = ?
                    `, [courseCode, section, student.student_id, todayFormatted]);

                    if (existingAttendance.length === 0) {
                        await connection.execute(`
                            INSERT INTO attendance (course_code, section, student_id, date, status)
                            VALUES (?, ?, ?, ?, 'absent')
                        `, [courseCode, section, student.student_id, todayFormatted]);
                        console.log(`Marked student ${student.student_id} as absent for today.`);
                        insertedCount++;
                    }
                }
            }
        } else {
            console.log('No attendance rule found for today.');
        }

        await connection.commit();
        console.log(`Total updates: ${updatedCount}, Total inserts: ${insertedCount}`);
        res.json({ success: true, updatedCount, insertedCount });
    } catch (error) {
        await connection.rollback();
        console.error('Error saving attendance:', error);
        res.status(500).json({ success: false, error: error.message || 'Internal Server Error' });
    } finally {
        connection.release();
    }
});

// ฟังก์ชันตรวจสอบการเข้าเรียน
function checkAttendance(currentTime, lateUntilTime, courseId, sectionId) {
    const parsedCurrentTime = parseISO(currentTime);
    const parsedLateUntilTime = parseISO(lateUntilTime);

    console.log(`Current server time: ${formatISO(parsedCurrentTime)}`);
    console.log(`Late until time for course ${courseId}, section ${sectionId}: ${formatISO(parsedLateUntilTime)}`);

    if (isAfter(parsedCurrentTime, parsedLateUntilTime)) {
        console.log(`Late_until has passed for course ${courseId}, section ${sectionId}. Checking attendance now.`);
        return true;
    } else {
        console.log(`Still within attendance time for course ${courseId}, section ${sectionId}.`);
        return false;
    }
}

// ฟังก์ชันเพื่อแปลงวันที่จาก YYYY-MM-DD เป็น DD/MM/YYYY
function formatDate(date) {
    const d = new Date(date);
    let day = d.getDate();
    let month = d.getMonth() + 1; // เดือนเริ่มที่ 0 ใน JavaScript
    const year = d.getFullYear();

    if (day < 10) {
        day = '0' + day;
    }
    if (month < 10) {
        month = '0' + month;
    }

    return `${day}/${month}/${year}`;
}

// ฟังก์ชันเพื่อแปลงเวลาเป็น HH:MM:SS
function formatTime(time) {
    // ตรวจสอบว่า time เป็นชนิดข้อมูลที่สามารถใช้ split ได้
    if (typeof time === 'string') {
        const [hours, minutes, seconds] = time.split(':');
        return `${hours}:${minutes}:${seconds}`;
    } else if (time instanceof Date) {
        // ถ้าเป็น Date object ให้แปลงเป็นรูปแบบ HH:MM:SS
        return time.toTimeString().split(' ')[0];
    } else {
        throw new TypeError('Invalid time format');
    }
}
// แก้ไขฟังก์ชัน checkAttendance เพื่อใช้ scheduleAttendanceCheck
function checkAttendance(currentTime, lateUntilTime, courseId, sectionId) {
    const parsedCurrentTime = parseISO(currentTime);
    const parsedLateUntilTime = parseISO(lateUntilTime);

    console.log(`Current server time: ${formatISO(parsedCurrentTime)}`);
    console.log(`Late until time for course ${courseId}, section ${sectionId}: ${formatISO(parsedLateUntilTime)}`);

    if (isAfter(parsedCurrentTime, parsedLateUntilTime)) {
        console.log(`Late_until has passed for course ${courseId}, section ${sectionId}. Checking attendance now.`);
        return true;
    } else {
        console.log(`Still within attendance time for course ${courseId}, section ${sectionId}.`);
        return false;
    }
}
let isProcessing = false;

const scheduleAttendanceCheck = async () => {
    // ตรวจสอบว่ากำลังประมวลผลอยู่หรือไม่
    if (isProcessing) {
        console.log('Attendance check is already in progress. Skipping.');
        return;
    }

    isProcessing = true;

    try {
        const now = new Date();
        console.log(`Current server time: ${formatISO(now)}`);

        const [rules] = await dbConnection.execute(`
            SELECT *, DATE_FORMAT(date, '%Y-%m-%d') AS formatted_date
            FROM attendance_rules
            WHERE date = CURDATE()
        `);

        if (rules.length === 0) {
            console.log('No attendance rules found for today.');
            return;
        }

        for (const rule of rules) {
            const ruleDate = parseISO(rule.formatted_date);
            const lateUntil = new Date(ruleDate.getFullYear(), ruleDate.getMonth(), ruleDate.getDate(),
                ...rule.late_until.split(':').map(Number));

            console.log(`Late until time for course ${rule.course_code}, section ${rule.section}: ${formatISO(lateUntil)}`);
            console.log(`Current time (ms): ${now.getTime()}, Late until (ms): ${lateUntil.getTime()}`);

            const timeUntilLate = lateUntil.getTime() - now.getTime();
            console.log(`Time until late (ms): ${timeUntilLate}`);

            if (timeUntilLate > 0) {
                console.log(`Scheduling attendance check for course ${rule.course_code}, section ${rule.section} in ${timeUntilLate / 1000} seconds.`);
                setTimeout(async () => {
                    await markAbsentStudents(rule.course_code, rule.section, ruleDate);
                }, timeUntilLate);
            } else {
                console.log(`Late_until has already passed for course ${rule.course_code}, section ${rule.section}. Checking attendance now.`);
                await markAbsentStudents(rule.course_code, rule.section, ruleDate);
            }
        }
    } catch (error) {
        console.error('Error scheduling attendance check:', error);
    } finally {
        isProcessing = false;
    }
};

const markAbsentStudents = async (courseCode, section, date) => {
    try {
        const [students] = await dbConnection.execute(`
            SELECT e.student_id 
            FROM enrollments e
            LEFT JOIN attendance a ON e.student_id = a.student_id 
                AND a.course_code = ? AND a.section = ? AND a.date = ?
            WHERE e.course_code = ? AND e.section = ? AND a.id IS NULL
        `, [courseCode, section, date, courseCode, section]);

        for (const student of students) {
            await dbConnection.execute(`
                INSERT INTO attendance (course_code, section, student_id, date, status)
                VALUES (?, ?, ?, ?, 'absent')
            `, [courseCode, section, student.student_id, date]);
            console.log(`Marked student ${student.student_id} as absent for ${courseCode}, section ${section} on ${formatISO(date)}`);
        }

        if (students.length === 0) {
            console.log(`No new absences to record for ${courseCode}, section ${section} on ${formatISO(date)}`);
        }
    } catch (error) {
        console.error('Error marking absent students:', error);
    }
};

// Edit antendance rules
router.put('/api/attendance-rules/:id', ifNotLoggedIn, async (req, res) => {
    const { id } = req.params;
    const { courseCode, section, date, presentUntil, lateUntil } = req.body;
    try {
        await dbConnection.execute(`
            UPDATE attendance_rules 
            SET date = ?, present_until = ?, late_until = ?
            WHERE id = ? AND course_code = ? AND section = ?
        `, [date, presentUntil, lateUntil, id, courseCode, section]);
        res.json({ success: true });
    } catch (error) {
        console.error('Error updating attendance rule:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Route สำหรับการส่งข้อความไปยังนิสิตที่ลงทะเบียนในวิชาเฉพาะ
router.post('/send-message', ifNotLoggedIn, upload.none(), async (req, res) => {
    console.log('Request Body:', req.body);
    const { courseCode, title, message } = req.body;

    // ตรวจสอบว่ามีข้อมูลที่จำเป็นถูกส่งมาครบหรือไม่
    if (!courseCode || !title || !message) {
        return res.status(400).json({ success: false, error: 'Missing required fields: courseCode, title, or message' });
    }

    const course_code = courseCode.split('_')[0];
    const section = courseCode.split('_')[1];
    
    try {
        const teacherId = req.session.userID;  // ดึงค่า teacher_id จาก session

        // ตรวจสอบว่าข้อความนี้เคยถูกส่งไปแล้วหรือยัง
        const [existingMessages] = await dbConnection.execute(`
            SELECT * FROM messages 
            WHERE course_code = ? AND section = ? AND title = ? AND message = ?
        `, [course_code, section, title, message]);

        if (existingMessages.length > 0) {
            // ถ้าข้อความนี้เคยถูกส่งแล้ว
            return res.status(400).json({ success: false, error: 'Message with this title and content has already been sent.' });
        }

        // บันทึกข้อความลงในฐานข้อมูล
        await dbConnection.execute(`
            INSERT INTO messages (teacher_id, course_code, section, title, message) 
            VALUES (?, ?, ?, ?, ?)
        `, [teacherId, course_code, section, title, message]);

        res.status(200).json({ success: true, message: 'Message sent successfully' });
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

// ฟังก์ชันสำหรับส่งการแจ้งเตือน 
async function sendNotification(token, message) {
    // สร้างคำขอเพื่อส่งการแจ้งเตือน
    const notificationPayload = {
        to: token,
        notification: {
            title: 'New Message from Teacher',
            body: message,
        },
    };

    // ใช้ fetch หรือ axios เพื่อส่งคำขอไปยัง FCM
    try {
        const response = await fetch('https://fcm.googleapis.com/fcm/send', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `key=${process.env.FCM_SERVER_KEY}`, // คีย์ FCM จาก server
            },
            body: JSON.stringify(notificationPayload),
        });

        const data = await response.json();
        console.log('Notification response:', data);
    } catch (error) {
        console.error('Error sending notification:', error);
    }
}

router.get('/notification', ifNotLoggedIn, async (req, res) => {
    const teacherId = req.session.userID;  // ดึง teacher_id จาก session

    try {
        // ดึงวิชาที่อาจารย์สอนจากตาราง course_teachers และ courses
        const [subjects] = await dbConnection.execute(`
            SELECT DISTINCT c.course_code, c.course_name, ct.section
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ?
        `, [teacherId]);

        // ส่งข้อมูลไปยังหน้า notification.ejs
        res.render('notification', {
            subjects: subjects,  // ส่งข้อมูลวิชาที่อาจารย์สอน
            successMessage: null,
            errorMessage: null
        });
    } catch (err) {
        console.error(err);
        res.status(500).send('Internal Server Error');
    }
});

// Route สำหรับบันทึกการเข้าเรียน
router.post('/log_attendance', async (req, res) => {
    const { id_number, major, minor, schedule_date, schedule_time } = req.body;

    if (!id_number || major === undefined || minor === undefined || !schedule_date || !schedule_time) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const connection = await dbConnection.getConnection();
    try {
        await connection.beginTransaction();

        const [[course]] = await connection.execute(
            'SELECT course_code, section FROM courses WHERE major = ? AND minor = ?',
            [major, minor]
        );

        if (!course) {
            await connection.rollback();
            return res.status(400).json({ error: 'Invalid major or minor' });
        }

        const { course_code, section } = course;

        // บันทึก log_attendance ทุกครั้ง
        await connection.execute(
            'INSERT INTO log_attendance (id_number, major, minor, schedule_date, schedule_time) VALUES (?, ?, ?, ?, ?)',
            [id_number, major, minor, schedule_date, schedule_time]
        );

        // ตรวจสอบว่ามีการบันทึกการเข้าเรียนสำหรับวันนี้แล้วหรือไม่
        const [[existingAttendance]] = await connection.execute(`
            SELECT * FROM attendance
            WHERE course_code = ? AND section = ? AND student_id = ? AND date = ?
        `, [course_code, section, id_number, schedule_date]);

        if (existingAttendance) {
            // ถ้ามีข้อมูลอยู่แล้ว ให้อัพเดทเฉพาะเวลาเช็คอิน โดยไม่เปลี่ยนสถานะ
            await connection.execute(`
                UPDATE attendance 
                SET check_in_time = ?
                WHERE course_code = ? AND section = ? AND student_id = ? AND date = ?
            `, [schedule_time, course_code, section, id_number, schedule_date]);

            await connection.commit();
            return res.status(200).json({
                message: 'Attendance updated with new check-in time',
                status: existingAttendance.status,
                checkInTime: schedule_time
            });
        } else {
            // ถ้ายังไม่มีข้อมูล ให้คำนวณสถานะใหม่
            const [[rule]] = await connection.execute(`
                SELECT * FROM attendance_rules
                WHERE course_code = ? AND section = ? AND date = ?
            `, [course_code, section, schedule_date]);

            let calculatedStatus = 'absent';

            if (rule) {
                const presentUntil = new Date(`${schedule_date}T${rule.present_until}`);
                const lateUntil = new Date(`${schedule_date}T${rule.late_until}`);
                const checkInTime = new Date(`${schedule_date}T${schedule_time}`);

                if (checkInTime <= presentUntil) {
                    calculatedStatus = 'present';
                } else if (checkInTime <= lateUntil) {
                    calculatedStatus = 'late';
                }
            }

            // บันทึกข้อมูลการเข้าเรียนใหม่
            await connection.execute(`
                INSERT INTO attendance (course_code, section, student_id, date, status, check_in_time)
                VALUES (?, ?, ?, ?, ?, ?)
            `, [course_code, section, id_number, schedule_date, calculatedStatus, schedule_time]);

            await connection.commit();
            return res.status(200).json({
                message: 'Attendance recorded successfully',
                status: calculatedStatus,
                checkInTime: schedule_time
            });
        }
    } catch (error) {
        await connection.rollback();
        console.error('Error logging attendance:', error);
        res.status(500).json({ error: 'Failed to record attendance' });
    } finally {
        connection.release();
    }
});

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

//ดึงข้อมูลเข้าแอพ
// เพิ่ม route นี้ใน routes.js
router.get('/api/user/:idNumber', async (req, res) => {
    const { idNumber } = req.params;
    try {
        // ดึงข้อมูลผู้ใช้
        const [userRows] = await dbConnection.execute(
            'SELECT id_number, first_name, last_name, role FROM users WHERE id_number = ?',
            [idNumber]
        );

        if (userRows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = userRows[0];

        // ดึงข้อมูลการเข้าเรียน
        const [attendanceRows] = await dbConnection.execute(
            'SELECT course_code, section, date, status, check_in_time FROM attendance WHERE student_id = ?',
            [idNumber]
        );

        res.json({
            user: user,
            attendance: attendanceRows
        });
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

//ดึงข้อมูลเข้าแอพ
router.post('/get-course-names', async (req, res) => {
    const { course_codes } = req.body;

    if (!course_codes || !Array.isArray(course_codes)) {
        return res.status(400).json({ error: 'Invalid input: course_codes must be an array' });
    }

    try {
        const [rows] = await dbConnection.execute(`
            SELECT course_code, course_name 
            FROM courses 
            WHERE course_code IN (?)
        `, [course_codes]);

        const courseNames = rows.reduce((acc, row) => {
            acc[row.course_code] = row.course_name;
            return acc;
        }, {});

        res.json(courseNames);
    } catch (error) {
        console.error('Error fetching course names:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

//ดึงประวัติเข้าแอพ
router.get('/api/user/:idNumber', async (req, res) => {
    const { idNumber } = req.params;
    try {
        // ดึงข้อมูลผู้ใช้
        const [userRows] = await dbConnection.execute(
            'SELECT id_number, first_name, last_name, role FROM users WHERE id_number = ?',
            [idNumber]
        );

        if (userRows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = userRows[0];

        // ดึงข้อมูลการเข้าเรียน
        const [attendanceRows] = await dbConnection.execute(
            'SELECT course_code, section, date, status, check_in_time FROM attendance WHERE student_id = ?',
            [idNumber]
        );

        res.json({
            user: user,
            attendance: attendanceRows
        });
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

//ดึงชื่อวิชา
router.get('/api/attendance/:idNumber', async (req, res) => {
    const { idNumber } = req.params;
    try {
        const [attendanceRows] = await dbConnection.execute(
            `SELECT a.course_code, c.course_name, a.section, a.date, a.status, a.check_in_time 
             FROM attendance a
             JOIN courses c ON a.course_code = c.course_code
             WHERE a.student_id = ?`,
            [idNumber]
        );

        res.json(attendanceRows);
    } catch (error) {
        console.error('Error fetching attendance data:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

//ดึงการแจ้งเตือน
router.get('/api/messages', async (req, res) => {
    try {
        const [messages] = await dbConnection.execute(`
            SELECT message, title
            FROM messages m
            JOIN users u ON m.teacher_id = u.id_number
            WHERE u.role = 'teacher'
        `);

        res.json(messages);  // ส่งข้อมูลในรูปแบบ JSON กลับไป
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get courses for a student
router.get('/api/student_courses/:studentId', ifNotLoggedIn, async (req, res) => {
    const { studentId } = req.params;
    try {
      const [courses] = await dbConnection.execute(`
        SELECT DISTINCT c.course_code, c.course_name
        FROM enrollments e
        JOIN courses c ON e.course_code = c.course_code AND e.section = c.section
        WHERE e.student_id = ?
      `, [studentId]);
      res.json(courses);
    } catch (error) {
      console.error('Error fetching student courses:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  // Get messages for specific courses
router.post('/api/course_messages', ifNotLoggedIn, async (req, res) => {
    const { courses } = req.body;
    try {
      const courseCodes = courses.map(course => course.course_code);
      const [messages] = await dbConnection.execute(`
        SELECT m.id, m.teacher_id, m.course_code, c.course_name, m.section, m.message, m.created_at, m.title
        FROM messages m
        JOIN courses c ON m.course_code = c.course_code
        WHERE m.course_code IN (?)
        ORDER BY m.created_at DESC
      `, [courseCodes]);
      res.json(messages);
    } catch (error) {
      console.error('Error fetching course messages:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

router.get('/api/student_messages/:studentId', async (req, res) => {
    const { studentId } = req.params;
    try {
      const [messages] = await dbConnection.execute(`
        SELECT m.id, m.title, m.message, m.created_at, 
               m.course_code, c.course_name, 
               CONCAT(u.first_name, ' ', u.last_name) AS teacher_name
        FROM messages m
        JOIN courses c ON m.course_code = c.course_code AND m.section = c.section
        JOIN users u ON m.teacher_id = u.id_number
        JOIN enrollments e ON m.course_code = e.course_code AND m.section = e.section
        WHERE e.student_id = ?
        ORDER BY m.created_at DESC
      `, [studentId]);
      
      res.json(messages);
    } catch (error) {
      console.error('Error fetching student messages:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
module.exports = router;
