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

// ฟังก์ชันสำหรับส่งค่า bg ของสถานะ
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

    // ตรวจสอบแค่ userId ว่าครูสอนวิชาอะไรบ้าง
    if (!userId) {
        console.error('Missing userId:', { userId });
        return res.status(400).send('Bad request: Missing required parameters');
    }

    try {
        const [courses] = await dbConnection.execute(`
            SELECT ct.course_code, ct.section
            FROM course_teachers ct
            WHERE ct.teacher_id = ?
        `, [userId]);

        if (courses.length === 0) {
            return res.status(403).send('Forbidden: You do not have permission to access any course');
        }

        // หากครูมีสิทธิ์สอนอย่างน้อย 1 วิชา ให้ผ่านไปยังขั้นตอนถัดไป
        next();
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

// Page
// Register
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

// Home Page
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
            scheduleImageUrl: scheduleImageUrl,  // ส่ง URL ของรูปภาพตารางสอนไปด้วย
            teacherId: teacherId
        });
    } catch (err) {
        console.error(err);
        res.status(500).send('An error occurred');
    }
});

// Logout Page
router.get('/logout', (req, res) => {
    req.session = null;
    res.redirect('/');
});

// Classroom Page
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

        res.render('Classroom', { subjects: courses, teacherId: teacherId });
    } catch (err) {
        console.error(err);
        res.status(500).send('An error occurred');
    }
});

// Students list Page
router.get('/students_class/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const teacherId = req.session.userID;
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
            teacherId: teacherId,
            getStatusClass: getStatusClass // ส่งฟังก์ชันนี้ไปยัง EJS
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Students list edit Page
router.get('/students/:courseCode/:section/edit', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const teacherId = req.session.userID;

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
            courseName: course ? course.course_name : "Unknown Course",
            teacherId: teacherId
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Attendance-rules Page
router.get('/attendance-rules/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const teacherId = req.session.userID;
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
            attendanceRules: rules,
            teacherId: teacherId
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Calculate 
router.get('/calculate', ifNotLoggedIn, async (req, res) => {
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

        res.render('calculate', { subjects: courses, teacherId: teacherId });
    } catch (err) {
        console.error(err);
        res.status(500).send('An error occurred');
    }
});

// Calculate Classroom
router.get('/calculate_class/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const teacherId = req.session.userID;
    const lateLimit = req.query.lateLimit !== undefined ? parseInt(req.query.lateLimit, 10) : null; // รับค่า lateLimit จากฟอร์ม
    const maxScore = req.query.maxScore !== undefined ? parseInt(req.query.maxScore, 10) : null; // รับค่า maxScore จากฟอร์ม (คะแนนที่ผู้ใช้กรอก)

    try {
        // ตรวจสอบว่ามีการตั้งค่าเงื่อนไขไว้หรือไม่
        const [conditionCheck] = await dbConnection.execute(`
            SELECT late_limit, max_score FROM course_conditions WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        let finalLateLimit = conditionCheck.length > 0 ? conditionCheck[0].late_limit : null;
        let finalMaxScore = conditionCheck.length > 0 ? conditionCheck[0].max_score : null;

        // ตรวจสอบการบันทึกเงื่อนไขใหม่ (รวมถึง lateLimit และ maxScore)
        if (lateLimit !== null || maxScore !== null) {
            if (conditionCheck.length === 0) {
                // บันทึกเงื่อนไขใหม่
                await dbConnection.execute(`
                    INSERT INTO course_conditions (course_code, section, late_limit, max_score)
                    VALUES (?, ?, ?, ?)
                `, [courseCode, section, lateLimit !== null ? lateLimit : finalLateLimit, maxScore !== null ? maxScore : finalMaxScore]);
            } else {
                // อัปเดตเงื่อนไขที่มีอยู่
                await dbConnection.execute(`
                    UPDATE course_conditions
                    SET late_limit = ?, max_score = ?
                    WHERE course_code = ? AND section = ?
                `, [
                    lateLimit !== null ? lateLimit : finalLateLimit,
                    maxScore !== null ? maxScore : finalMaxScore,
                    courseCode,
                    section
                ]);
            }
        }

        // ดึงข้อมูลนักเรียนและการเข้าเรียน
        const [students] = await dbConnection.execute(`
            SELECT s.id_number, u.first_name, u.last_name
            FROM students s
            JOIN users u ON s.id_number = u.id_number
            JOIN enrollments e ON s.id_number = e.student_id
            WHERE e.course_code = ? AND e.section = ?
        `, [courseCode, section]);

        // ดึงข้อมูลกฎการเข้าเรียน (วันที่เรียน)
        const [attendanceRules] = await dbConnection.execute(`
            SELECT date, DATE_FORMAT(date, '%d/%m/%Y') AS formatted_date
            FROM attendance_rules
            WHERE course_code = ? AND section = ?
            ORDER BY date
        `, [courseCode, section]);

        const [attendances] = await dbConnection.execute(`
            SELECT student_id, date, status
            FROM attendance
            WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        // คำนวณคะแนนสำหรับนักเรียนแต่ละคน
        const studentsWithAttendance = students.map(student => {
            let totalScore = 0;
            let lateCount = 0;
            const maxPossibleScore = attendanceRules.length; // คะแนนเต็มที่เป็นไปได้

            // สร้าง attendanceByDate เพื่อให้ EJS ใช้งาน
            const attendanceByDate = attendanceRules.map(rule => {
                const attendance = attendances.find(a =>
                    a.student_id === student.id_number &&
                    a.date.toISOString().split('T')[0] === rule.date.toISOString().split('T')[0]
                );

                if (attendance) {
                    if (attendance.status === 'present') {
                        totalScore += 1;
                        return { date: rule.formatted_date, status: 'present' };
                    } else if (attendance.status === 'late') {
                        lateCount += 1;
                        totalScore += 1;
                        return { date: rule.formatted_date, status: 'late' };
                    } else if (attendance.status === 'leave') {
                        totalScore += 1;
                        return { date: rule.formatted_date, status: 'leave' };
                    } else if (attendance.status === 'absent') {
                        return { date: rule.formatted_date, status: 'absent' };
                    }
                } else {
                    // หากไม่มีข้อมูลการเข้าเรียนให้แสดง "ขาด" โดยปริยาย
                    return { date: rule.formatted_date, status: 'absent' };
                }
            });

            // หักคะแนนถ้า lateCount เกินค่าที่กำหนด แต่ถ้า lateLimit = 0 จะไม่หักคะแนน
            let penaltyScore = 0;
            if (finalLateLimit > 0 && lateCount >= finalLateLimit) {
                penaltyScore = Math.floor(lateCount / finalLateLimit);
                totalScore -= penaltyScore;
            }

            // คำนวณคะแนนที่ใช้งานจริง (actualScore) โดยใช้สูตรบัญญัติไตรยางศ์
            let actualScore = totalScore;
            if (finalMaxScore !== null && finalMaxScore > 0) {
                actualScore = (totalScore / maxPossibleScore) * finalMaxScore;
            }

            return {
                ...student,
                totalScore,
                lateCount,
                penaltyScore, // จำนวนคะแนนที่จะถูกลบ
                attendanceByDate,  // ส่ง attendanceByDate ให้กับ EJS
                actualScore // ส่ง actualScore ให้กับ EJS เพื่อแสดงผล
            };
        });

        // ดึงชื่อวิชา
        const [[course]] = await dbConnection.execute(`
            SELECT course_name FROM courses WHERE course_code = ? AND section = ?
        `, [courseCode, section]);

        // ส่งข้อมูลไปยัง EJS เพื่อแสดงผล
        res.render('calculate_class', {
            students: studentsWithAttendance,
            courseCode,
            section,
            courseName: course ? course.course_name : "Unknown Course",
            lateLimit: finalLateLimit,
            maxScore: finalMaxScore,
            dates: attendanceRules,
            teacherId: teacherId  // ส่งข้อมูลวันที่การเข้าเรียนไปยัง EJS
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Route สำหรับบันทึก lateLimit
router.post('/updateLateLimit/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const lateLimit = parseInt(req.body.lateLimit, 10); // รับค่า lateLimit จากฟอร์ม

    try {
        await dbConnection.execute(`
            UPDATE course_conditions
            SET late_limit = ?
            WHERE course_code = ? AND section = ?
        `, [lateLimit, courseCode, section]);
        res.redirect(`/calculate_class/${courseCode}/${section}`);
    } catch (error) {
        console.error('Error updating lateLimit:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Route สำหรับบันทึก maxScore
router.post('/updateMaxScore/:courseCode/:section', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { courseCode, section } = req.params;
    const maxScore = parseInt(req.body.maxScore, 10); // รับค่า maxScore จากฟอร์ม

    try {
        await dbConnection.execute(`
            UPDATE course_conditions
            SET max_score = ?
            WHERE course_code = ? AND section = ?
        `, [maxScore, courseCode, section]);
        res.redirect(`/calculate_class/${courseCode}/${section}`);
    } catch (error) {
        console.error('Error updating maxScore:', error);
        res.status(500).send('Internal Server Error');
    }
});
//-----------------------------------------------------------------------------------------------------------------


// Route สำหรับแสดงหน้า EJS
router.get('/graph', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const teacherId = req.session.userID;

    // Query สำหรับการดึงข้อมูลการขาดเรียนและมาสาย
    const absentQuery = `
        WITH RankedAbsent AS (
            SELECT 
                a.student_id, 
                u.first_name, 
                u.last_name, 
                a.course_code, 
                a.section, 
                COUNT(*) as absent_count,
                ROW_NUMBER() OVER (PARTITION BY a.course_code ORDER BY COUNT(*) DESC) as \`rank\`
            FROM attendance a
            JOIN users u ON a.student_id = u.id_number
            WHERE a.status = 'absent'
            GROUP BY a.student_id, a.course_code, a.section
        )
        SELECT * FROM RankedAbsent WHERE \`rank\` = 1;
    `;

    const lateQuery = `
        WITH RankedLate AS (
            SELECT 
                a.student_id, 
                u.first_name, 
                u.last_name, 
                a.course_code, 
                a.section, 
                COUNT(*) as late_count,
                ROW_NUMBER() OVER (PARTITION BY a.course_code ORDER BY COUNT(*) DESC) as \`rank\`
            FROM attendance a
            JOIN users u ON a.student_id = u.id_number
            WHERE a.status = 'late'
            GROUP BY a.student_id, a.course_code, a.section
        )
        SELECT * FROM RankedLate WHERE \`rank\` = 1;
    `;

    const mostAbsentCourseQuery = `
        SELECT a.course_code, c.course_name, a.section, COUNT(*) as absent_count
        FROM attendance a
        JOIN courses c ON a.course_code = c.course_code
        WHERE a.status = 'absent'
        GROUP BY a.course_code, a.section, c.course_name
        ORDER BY absent_count DESC
        LIMIT 1;
    `;

    const mostLateCourseQuery = `
        SELECT a.course_code, c.course_name, a.section, COUNT(*) as late_count
        FROM attendance a
        JOIN courses c ON a.course_code = c.course_code
        WHERE a.status = 'late'
        GROUP BY a.course_code, a.section, c.course_name
        ORDER BY late_count DESC
        LIMIT 1;
    `;

    try {
        // ดึงข้อมูลการขาดเรียนและมาสาย
        const [absentStudents] = await dbConnection.query(absentQuery);
        const [lateStudents] = await dbConnection.query(lateQuery);
        const [mostAbsentCourseResult] = await dbConnection.query(mostAbsentCourseQuery);
        const [mostLateCourseResult] = await dbConnection.query(mostLateCourseQuery);

        // ดึงข้อมูลรายวิชาที่ครูสอน
        const [subjects] = await dbConnection.execute(`
            SELECT DISTINCT c.course_code, c.course_name, ct.section
            FROM courses c
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ?
        `, [teacherId]);

        // ดึงข้อมูลวันที่ที่มีการเช็คชื่อ
        const [dates] = await dbConnection.execute(`
            SELECT DISTINCT date FROM attendance_rules
            WHERE course_code IN (SELECT course_code FROM course_teachers WHERE teacher_id = ?)
            ORDER BY date ASC
        `, [teacherId]);

        // การเตรียมข้อมูลของวิชาที่มีการขาดเรียนและมาสายมากที่สุด
        const mostAbsentCourse = mostAbsentCourseResult.length > 0
            ? {
                course_name: mostAbsentCourseResult[0].course_name,
                course_code: mostAbsentCourseResult[0].course_code,
                section: mostAbsentCourseResult[0].section,
                absent_count: mostAbsentCourseResult[0].absent_count
            } : null;

        const mostLateCourse = mostLateCourseResult.length > 0
            ? {
                course_name: mostLateCourseResult[0].course_name,
                course_code: mostLateCourseResult[0].course_code,
                section: mostLateCourseResult[0].section,
                late_count: mostLateCourseResult[0].late_count
            } : null;

        // ส่งข้อมูลทั้งหมดไปยังหน้า EJS
        res.render('graph', {
            absentStudents: absentStudents || [],
            lateStudents: lateStudents || [],
            mostAbsentCourse: mostAbsentCourse || null,
            mostLateCourse: mostLateCourse || null,
            teacherId: teacherId,
            subjects: subjects || [],
            dates: dates || [] // ส่งข้อมูลวันที่เพื่อให้แสดงในหน้า EJS
        });
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send('Error fetching data');
    }
});

// Route สำหรับดึงวันที่ที่มีการเช็คชื่อสำหรับรายวิชาที่เลือก
router.get('/getDatesForCourse', async (req, res) => {
    const course = req.query.course;

    if (!course) {
        return res.status(400).json({ error: "Missing course parameter" });
    }

    const [courseCode, section] = course.split('_');

    try {
        const [dates] = await dbConnection.execute(`
            SELECT DISTINCT date FROM attendance
            WHERE course_code = ? AND section = ?
            ORDER BY date ASC
        `, [courseCode, section]);

        res.json(dates);
    } catch (error) {
        console.error('Error fetching dates:', error);
        res.status(500).send('Error fetching dates');
    }
});

// Route สำหรับดึงข้อมูลการเข้าชั้นเรียน
router.get('/getAttendanceData', async (req, res) => {
    const course = req.query.course;
    const date = req.query.date;

    if (!course || !date) {
        return res.status(400).json({ error: "Missing course or date parameter" });
    }

    const [courseCode, section] = course.split('_');

    try {
        const [attendanceData] = await dbConnection.execute(`
            SELECT status FROM attendance
            WHERE course_code = ? AND section = ? AND date = ?
        `, [courseCode, section, date]);

        const statusCounts = { present: 0, late: 0, absent: 0, leave: 0 };

        attendanceData.forEach(record => {
            statusCounts[record.status]++;
        });

        res.json({
            presentCount: statusCounts.present,
            lateCount: statusCounts.late,
            absentCount: statusCounts.absent,
            leaveCount: statusCounts.leave
        });
    } catch (error) {
        console.error('Error fetching attendance data:', error);
        res.status(500).send('Error fetching attendance data');
    }
});

router.get('/getAttendanceByTime', async (req, res) => {
    const course = req.query.course;
    const date = req.query.date;

    if (!course || !date) {
        return res.status(400).json({ error: "Missing course or date parameter" });
    }

    const [courseCode, section] = course.split('_');

    try {
        // ดึงข้อมูล check_in_time และจัดกลุ่มตามช่วงเวลา 5 นาที
        const [attendanceData] = await dbConnection.execute(`
            SELECT 
    CONCAT(
        DATE_FORMAT(SEC_TO_TIME(FLOOR(TIME_TO_SEC(check_in_time) / 300) * 300), '%H:%i'),
        '-', 
        DATE_FORMAT(SEC_TO_TIME(FLOOR(TIME_TO_SEC(check_in_time) / 300) * 300 + 299), '%H:%i')
    ) AS time_range,
    COUNT(*) AS count
FROM 
    attendance
WHERE 
    course_code = ? AND section = ? AND date = ?
GROUP BY 
    time_range
ORDER BY 
    time_range ASC 
        `, [courseCode, section, date]);

        console.log('Attendance Data:', attendanceData); // ตรวจสอบข้อมูลที่ได้จากฐานข้อมูล

        res.json(attendanceData);
    } catch (error) {
        console.error('Error fetching attendance data by time:', error);
        res.status(500).send('Error fetching attendance data');
    }
});

// Route สำหรับดึงข้อมูลการเข้าชั้นเรียนรวมของทุกวันสำหรับรายวิชาที่เลือก
router.get('/getAttendanceDataForAllDates', async (req, res) => {
    const course = req.query.course;

    if (!course) {
        return res.status(400).json({ error: "Missing course parameter" });
    }

    const [courseCode, section] = course.split('_');

    try {
        const [attendanceData] = await dbConnection.execute(`
            SELECT status, COUNT(*) as count
            FROM attendance
            WHERE course_code = ? AND section = ?
            GROUP BY status
        `, [courseCode, section]);

        const statusCounts = { present: 0, late: 0, absent: 0, leave: 0 };

        attendanceData.forEach(record => {
            statusCounts[record.status] += record.count;
        });

        res.json({
            presentCount: statusCounts.present,
            lateCount: statusCounts.late,
            absentCount: statusCounts.absent,
            leaveCount: statusCounts.leave
        });
    } catch (error) {
        console.error('Error fetching attendance data for all dates:', error);
        res.status(500).send('Error fetching attendance data for all dates');
    }
});



//-----------------------------------------------------------------------------------------------------------------

router.get('/leave-requests/:teacherId', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { teacherId } = req.params;
    try {
        const [pendingRequests] = await dbConnection.execute(`
            SELECT lr.id, lr.student_id, lr.course_id, lr.leave_type_id, lr.reason, 
                   lr.start_date, lr.end_date, lr.status, lr.approval_comment,
                   lt.type_name AS leave_type, c.course_name, c.course_code, c.section, 
                   u.first_name, u.last_name,
                   CONCAT(u.first_name, ' ', u.last_name) AS student_name,
                   CASE WHEN lr.leave_document_url IS NOT NULL THEN true ELSE false END AS has_leave_document,
                   CASE WHEN lr.medical_certificate_url IS NOT NULL THEN true ELSE false END AS has_medical_certificate
            FROM leave_requests lr
            JOIN leave_types lt ON lr.leave_type_id = lt.id
            JOIN courses c ON lr.course_id = c.course_id
            JOIN users u ON lr.student_id = u.id_number
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ? 
            ORDER BY lr.created_at DESC
        `, [teacherId]);

        res.render('LeaveRequests', { pendingRequests, teacherId: teacherId });
    } catch (error) {
        console.error('Error fetching leave requests:', error);
    }
});

router.get('/leave-history/:teacherId', ifNotLoggedIn, ownsCourse, async (req, res) => {
    const { teacherId } = req.params;
    try {
        const [pendingRequests] = await dbConnection.execute(`
            SELECT lr.id, lr.student_id, lr.course_id, lr.leave_type_id, lr.reason, 
                   lr.start_date, lr.end_date, lr.status, lr.approval_comment,
                   lt.type_name AS leave_type, c.course_name, c.course_code, c.section, 
                   u.first_name, u.last_name,
                   CONCAT(u.first_name, ' ', u.last_name) AS student_name,
                   CASE WHEN lr.leave_document_url IS NOT NULL THEN true ELSE false END AS has_leave_document,
                   CASE WHEN lr.medical_certificate_url IS NOT NULL THEN true ELSE false END AS has_medical_certificate
            FROM leave_requests lr
            JOIN leave_types lt ON lr.leave_type_id = lt.id
            JOIN courses c ON lr.course_id = c.course_id
            JOIN users u ON lr.student_id = u.id_number
            JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
            WHERE ct.teacher_id = ? 
            ORDER BY lr.created_at DESC
        `, [teacherId]);

        res.render('LeaveHistory', { pendingRequests, teacherId: teacherId });
    } catch (error) {
        console.error('Error fetching leave requests:', error);
    }
});

// Route for viewing the leave document
router.get('/view-leave-document/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await dbConnection.execute(
            'SELECT leave_document_url FROM leave_requests WHERE id = ?',
            [id]
        );
        if (result.length > 0 && result[0].leave_document_url) {
            const fileBuffer = result[0].leave_document_url; // assuming it's a BLOB or binary data
            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', 'inline'); // Important to force viewing in browser
            res.send(fileBuffer); // send the PDF file as response
        } else {
            res.status(404).send('File not found');
        }
    } catch (error) {
        console.error('Error fetching leave document:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Route for viewing the medical certificate
router.get('/view-medical-certificate/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await dbConnection.execute(
            'SELECT medical_certificate_url FROM leave_requests WHERE id = ?',
            [id]
        );
        if (result.length > 0 && result[0].medical_certificate_url) {
            const fileBuffer = result[0].medical_certificate_url; // assuming it's a BLOB or binary data
            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', 'inline'); // Important to force viewing in browser
            res.send(fileBuffer); // send the PDF file as response
        } else {
            res.status(404).send('File not found');
        }
    } catch (error) {
        console.error('Error fetching medical certificate:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Route สำหรับการอนุมัติหรือปฏิเสธคำขอลางาน
router.post('/web/approve-leave-request/:leaveRequestId', async (req, res) => {
    const { leaveRequestId } = req.params;
    let { status, comment } = req.body; // รับค่า status และ comment จากฟอร์ม
    const approver_id = req.session.userID; // ดึง approver_id จาก session

    // ตรวจสอบว่าค่า status ตรงกับตัวเลือกใน ENUM
    const validStatuses = ['อนุมัติ', 'ไม่อนุมัติ']; // กำหนดค่า ENUM ที่ถูกต้อง
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid status value' });
    }

    try {
        const [[leaveRequest]] = await dbConnection.execute(
            'SELECT student_id FROM leave_requests WHERE id = ?',
            [leaveRequestId]
        );

        if (!leaveRequest) {
            return res.status(404).json({ success: false, error: 'Leave request not found' });
        }

        // บันทึกประวัติการอนุมัติพร้อมความคิดเห็น
        await dbConnection.execute(`
            INSERT INTO leave_approval_history (leave_request_id, student_id, approver_id, action, comment, action_date)
            VALUES (?, ?, ?, ?, ?, NOW())
        `, [leaveRequestId, leaveRequest.student_id, approver_id, status, comment]);

        // อัปเดตสถานะและบันทึก approval_comment ใน leave_requests
        await dbConnection.execute(`
            UPDATE leave_requests 
            SET status = ?, approver_id = ?, approval_date = NOW(), approval_comment = ?
            WHERE id = ?
        `, [status, approver_id, comment, leaveRequestId]);  // บันทึก comment ในฟิลด์ approval_comment
        const teacherId = req.session.teacherId;
        res.redirect('/leave-requests/' + approver_id); // กลับไปยังหน้าคำขอลาที่รอการอนุมัติ
    } catch (error) {
        console.error('Error approving leave request:', error);
        res.status(500).send('Internal Server Error');
    }
});

// API register
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

// API Login
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

// API Save attendance rule
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

// API Delete attendance rule
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

// API Edit antendance rules
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
            attendanceRules: rules, teacherId: teacherId
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
            return res.status(400).json({ success: false, error: 'ข้อความนี้เคยถูกส่งแล้ว ขอแนะนำให้แก้ไขเพิ่มเติม' });
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
            errorMessage: null,
            teacherId: teacherId
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


//-------------------------------------------------------------------------------------------------------------
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
// router.get('/api/student_courses/:studentId', ifNotLoggedIn, async (req, res) => {
//     const { studentId } = req.params;
//     try {
//       const [courses] = await dbConnection.execute(`
//         SELECT DISTINCT c.course_id, c.course_code, c.course_name
//         FROM enrollments e
//         JOIN courses c ON e.course_code = c.course_code AND e.section = c.section
//         WHERE e.student_id = ?
//       `, [studentId]);
//       res.json(courses);
//     } catch (error) {
//       console.error('Error fetching student courses:', error);
//       res.status(500).json({ error: 'Internal Server Error' });
//     }
//   });
//---------------ส่งแจ้งเตือน----------------
// Get messages for specific courses
router.post('/api/course_messages', async (req, res) => {
    const { teacher_id, course_code, section, title, message } = req.body;

    try {
        // ตรวจสอบว่ามีข้อมูลครบถ้วน
        if (!teacher_id || !course_code || !section || !title || !message) {
            return res.status(400).json({ success: false, error: 'Missing required fields' });
        }

        // บันทึกข้อความลงในฐานข้อมูล
        const [result] = await dbConnection.execute(`
        INSERT INTO messages (teacher_id, course_code, section, title, message)
        VALUES (?, ?, ?, ?, ?)
      `, [teacher_id, course_code, section, title, message]);



        // ส่งคืน JSON response
        res.json({ success: true, message_id: result.insertId });
    } catch (error) {
        console.error('Error sending course message:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
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
//---------------ลา---------------------
//ประเภทของการลา
router.get('/api/leave-types', async (req, res) => {
    try {
        const [leaveTypes] = await dbConnection.execute('SELECT * FROM leave_types WHERE is_active = TRUE');
        res.json(leaveTypes);
    } catch (error) {
        console.error('Error fetching leave types:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});


//ส่งใบลา
// API สำหรับส่งคำขอลา
router.post('/api/leave-request', upload.fields([
    { name: 'leave_document', maxCount: 1 },
    { name: 'medical_certificate', maxCount: 1 }
]), async (req, res) => {
    const {
        student_id,
        course_id,
        leave_type_id,
        reason,
        start_date,
        end_date,
        status = 'รออนุมัติ'
    } = req.body;

    let leave_document = null;
    let medical_certificate = null;

    if (req.files['leave_document']) {
        leave_document = req.files['leave_document'][0].buffer;
    }
    if (req.files['medical_certificate']) {
        medical_certificate = req.files['medical_certificate'][0].buffer;
    }

    const connection = await dbConnection.getConnection();
    try {
        await connection.beginTransaction();

        const [result] = await connection.execute(`
        INSERT INTO leave_requests 
        (student_id, course_id, leave_type_id, reason, start_date, end_date, status, leave_document_url, medical_certificate_url) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [student_id, course_id, leave_type_id, reason, start_date, end_date, status, leave_document, medical_certificate]);

        await connection.commit();
        res.json({
            success: true,
            message: 'Leave request submitted successfully',
            leave_request_id: result.insertId
        });
    } catch (error) {
        await connection.rollback();
        console.error('Error submitting leave request:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    } finally {
        connection.release();
    }
});

//ประวัติลา
router.post('/api/leave-request', upload.fields([
    { name: 'leave_document', maxCount: 1 },
    { name: 'medical_certificate', maxCount: 1 }
]), async (req, res) => {
    const {
        student_id,
        course_id,
        leave_type_id,
        reason,
        start_date,
        end_date,
        status = 'รออนุมัติ'
    } = req.body;

    let leave_document_url = null;
    let medical_certificate_url = null;

    if (req.files) {
        if (req.files['leave_document']) {
            leave_document_url = '/uploads/' + req.files['leave_document'][0].filename;
        }
        if (req.files['medical_certificate']) {
            medical_certificate_url = '/uploads/' + req.files['medical_certificate'][0].filename;
        }
    }

    // ตรวจสอบและแทนที่ค่า undefined ด้วย null
    const safeValues = [
        student_id || null,
        course_id || null,
        null,  // teacher_id เป็น null
        leave_type_id || null,
        reason || null,
        start_date || null,
        end_date || null,
        status,
        leave_document_url,
        medical_certificate_url
    ];

    try {
        const [result] = await dbConnection.execute(`
          INSERT INTO leave_requests 
          (student_id, course_id, teacher_id, leave_type_id, reason, start_date, end_date, status, leave_document_url, medical_certificate_url) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, safeValues);

        res.json({ success: true, leave_request_id: result.insertId });
    } catch (error) {
        console.error('Error submitting leave request:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});
router.post('/api/leave-attachment', async (req, res) => {
    const { leave_request_id, file_type, file_url } = req.body;
    try {
        await dbConnection.execute(`
        INSERT INTO leave_attachments 
        (leave_request_id, file_type, file_url) 
        VALUES (?, ?, ?)
      `, [leave_request_id, file_type, file_url]);

        res.json({ success: true });
    } catch (error) {
        console.error('Error saving leave attachment:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

//----------------------------------------------ส่วนอาจารย์-------------------------------------------


// API สำหรับดึงข้อมูลใบลาที่รออนุมัติสำหรับอาจารย์
router.get('/api/pending-leave-requests/:teacherId', async (req, res) => {
    const { teacherId } = req.params;
    try {
        const [pendingRequests] = await dbConnection.execute(`
        SELECT lr.id, lr.student_id, lr.course_id, lr.leave_type_id, lr.reason, 
               lr.start_date, lr.end_date, lr.status, 
               lt.type_name AS leave_type, c.course_name, c.course_code, c.section, 
               u.first_name, u.last_name,
               CONCAT(u.first_name, ' ', u.last_name) AS student_name,
               CASE WHEN lr.leave_document_url IS NOT NULL THEN true ELSE false END AS has_leave_document,
               CASE WHEN lr.medical_certificate_url IS NOT NULL THEN true ELSE false END AS has_medical_certificate
        FROM leave_requests lr
        JOIN leave_types lt ON lr.leave_type_id = lt.id
        JOIN courses c ON lr.course_id = c.course_id
        JOIN users u ON lr.student_id = u.id_number
        JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
        WHERE ct.teacher_id = ? AND lr.status = 'รออนุมัติ'
        ORDER BY lr.created_at DESC
      `, [teacherId]);

        res.json(pendingRequests);
    } catch (error) {
        console.error('Error fetching pending leave requests:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// API สำหรับอนุมัติหรือปฏิเสธใบลา
router.post('/api/approve-leave-request/:leaveRequestId', async (req, res) => {
    const { leaveRequestId } = req.params;
    const { status, comment, approver_id } = req.body;

    try {
        // ดึง student_id จาก leave_requests
        const [[leaveRequest]] = await dbConnection.execute(
            'SELECT student_id FROM leave_requests WHERE id = ?',
            [leaveRequestId]
        );

        if (!leaveRequest) {
            return res.status(404).json({ success: false, error: 'Leave request not found' });
        }

        // บันทึกการอนุมัติ/ปฏิเสธใบลาลงในตาราง leave_approval_history
        await dbConnection.execute(`
        INSERT INTO leave_approval_history 
        (leave_request_id, student_id, approver_id, action, comment, action_date)
        VALUES (?, ?, ?, ?, ?, NOW())
      `, [leaveRequestId, leaveRequest.student_id, approver_id, status, comment]);

        // อัปเดตสถานะของคำขอลาในตาราง leave_requests
        await dbConnection.execute(`
        UPDATE leave_requests 
        SET status = ?, approver_id = ?, approval_date = NOW(), approval_comment = ?
        WHERE id = ?
      `, [status, approver_id, comment, leaveRequestId]);

        res.json({ success: true, message: 'Leave request processed successfully' });
    } catch (error) {
        console.error('Error approving leave request:', error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

// API สำหรับดาวน์โหลดไฟล์
router.get('/download/:fileType/:leaveRequestId', async (req, res) => {
    const { fileType, leaveRequestId } = req.params;
    try {
        let columnName;
        if (fileType === 'leave') {
            columnName = 'leave_document_url';
        } else if (fileType === 'medical') {
            columnName = 'medical_certificate_url';
        } else {
            return res.status(400).send('Invalid file type');
        }

        const [result] = await dbConnection.execute(
            `SELECT ${columnName} FROM leave_requests WHERE id = ?`,
            [leaveRequestId]
        );

        if (result.length > 0 && result[0][columnName]) {
            const fileBuffer = result[0][columnName];
            console.log(`Sending file for ${fileType}, size: ${fileBuffer.length} bytes`);

            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', `attachment; filename="${fileType}_${leaveRequestId}.pdf"`);
            res.setHeader('Content-Length', fileBuffer.length);

            res.send(fileBuffer);
        } else {
            console.log(`File not found for ${fileType}, leaveRequestId: ${leaveRequestId}`);
            res.status(404).send('File not found');
        }
    } catch (error) {
        console.error('Error downloading file:', error);
        res.status(500).send('Internal Server Error');
    }
});

router.get('/api/student_courses/:studentId', async (req, res) => {
    const { studentId } = req.params;

    // ตรวจสอบ authentication (ถ้าจำเป็น)
    // if (!req.session.isLoggedIn) {
    //   return res.status(401).json({ error: 'Unauthorized' });
    // }

    try {
        console.log(`Fetching courses for student ID: ${studentId}`);

        const [courses] = await dbConnection.execute(`
        SELECT DISTINCT c.course_id, c.course_code, c.course_name, c.section
        FROM enrollments e
        JOIN courses c ON e.course_code = c.course_code AND e.section = c.section
        WHERE e.student_id = ?
      `, [studentId]);

        console.log('Fetched courses:', courses);

        if (courses.length === 0) {
            console.log('No courses found for this student');
            return res.status(404).json({ error: 'No courses found for this student' });
        }

        const formattedCourses = courses.map(course => ({
            course_id: course.course_id.toString(),
            course_code: course.course_code,
            course_name: course.course_name,
            section: course.section,
            name: `${course.course_code} - ${course.course_name}`
        }));

        console.log('Sending formatted courses:', formattedCourses);
        res.json(formattedCourses);
    } catch (error) {
        console.error('Error fetching student courses:', error);
        res.status(500).json({ error: 'Internal Server Error', details: error.message });
    }
});

// API สำหรับดึงประวัติการลาของนักศึกษา
// In routes.js
router.get('/api/leave-history/:studentId', async (req, res) => {
    const { studentId } = req.params;
    try {
        const [leaveHistory] = await dbConnection.execute(`
        SELECT 
          lr.id,
          lr.student_id,
          lr.course_id, 
          c.course_name, 
          c.course_code,
          c.section,
          lt.type_name as leave_type,
          lr.reason,
          lr.start_date,
          lr.end_date,
          lr.status as action,
          lr.approval_comment as comment,
          lr.approval_date as action_date
        FROM leave_requests lr
        JOIN courses c ON lr.course_id = c.course_id
        JOIN leave_types lt ON lr.leave_type_id = lt.id
        WHERE lr.student_id = ?
        ORDER BY lr.created_at DESC, lr.approval_date DESC
      `, [studentId]);

        res.json(leaveHistory);
    } catch (error) {
        console.error('Error fetching leave history:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});



// Get teacher courses
router.get('/api/teacher_courses/:teacherId', async (req, res) => {
    const { teacherId } = req.params;
    try {
        const [rows] = await dbConnection.execute(`
        SELECT DISTINCT c.course_code, c.course_name, ct.section
        FROM courses c
        JOIN course_teachers ct ON c.course_code = ct.course_code
        WHERE ct.teacher_id = ?
      `, [teacherId]);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching teacher courses:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


// Get teacher courses for attendance setting
router.get('/api/teacher_courses_for_attendance/:teacherId', async (req, res) => {
    const { teacherId } = req.params;
    try {
        const [rows] = await dbConnection.execute(`
        SELECT DISTINCT c.course_code, c.course_name, ct.section
        FROM courses c
        JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
        WHERE ct.teacher_id = ?
      `, [teacherId]);

        console.log('Courses fetched for teacher:', rows); // เพิ่ม log เพื่อตรวจสอบข้อมูลที่ส่งกลับ
        res.json(rows);
    } catch (error) {
        console.error('Error fetching teacher courses for attendance:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get attendance rules
router.get('/api/attendance-rules/:courseCode/:section', async (req, res) => {
    const { courseCode, section } = req.params;
    try {
        const [rules] = await dbConnection.execute(`
        SELECT id, course_code, section, 
               DATE_FORMAT(date, '%Y-%m-%d') as date, 
               TIME_FORMAT(present_until, '%H:%i') as present_until, 
               TIME_FORMAT(late_until, '%H:%i') as late_until
        FROM attendance_rules
        WHERE course_code = ? AND section = ?
        ORDER BY date
      `, [courseCode, section]);

        res.json(rules);
    } catch (error) {
        console.error('Error fetching attendance rules:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Set attendance rule
router.post('/api/set-attendance-rule', async (req, res) => {
    const { course_code, section, date, present_until, late_until } = req.body;

    console.log('Received data:', { course_code, section, date, present_until, late_until });

    // ตรวจสอบว่าข้อมูลครบถ้วนหรือไม่
    if (!course_code || !section || !date || !present_until || !late_until) {
        console.log('Missing fields:', { course_code, section, date, present_until, late_until });
        return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    try {
        await dbConnection.execute(`
        INSERT INTO attendance_rules (course_code, section, date, present_until, late_until)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE present_until = ?, late_until = ?
      `, [course_code, section, date, present_until, late_until, present_until, late_until]);

        res.json({ success: true, message: 'Attendance rule set successfully' });
    } catch (error) {
        console.error('Error setting attendance rule:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
});


// Delete attendance rule
router.delete('/api/attendance-rule/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const [result] = await dbConnection.execute('DELETE FROM attendance_rules WHERE id = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Attendance rule not found' });
        }

        res.json({ success: true, message: 'Attendance rule deleted successfully' });
    } catch (error) {
        console.error('Error deleting attendance rule:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


// Get attendance summary for PBox1
router.get('/api/pbox1-attendance-summary/:courseCode/:section/:startDate/:endDate', async (req, res) => {
    const { courseCode, section, startDate, endDate } = req.params;

    try {
        // Fetch attendance data
        const [results] = await dbConnection.execute(`
        SELECT 
          date,
          status,
          COUNT(*) as count
        FROM attendance
        WHERE course_code = ? AND section = ? AND date BETWEEN ? AND ?
        GROUP BY date, status
        ORDER BY date
      `, [courseCode, section, startDate, endDate]);

        // Process the results to create a summary
        const summary = {};
        results.forEach(result => {
            if (!summary[result.date]) {
                summary[result.date] = { present: 0, late: 0, absent: 0 };
            }
            summary[result.date][result.status] = result.count;
        });

        // Get total number of students enrolled in the course
        const [enrollmentResult] = await dbConnection.execute(`
        SELECT COUNT(DISTINCT student_id) as total_students
        FROM enrollments
        WHERE course_code = ? AND section = ?
      `, [courseCode, section]);

        const totalStudents = enrollmentResult[0].total_students;

        // Get course name
        const [courseResult] = await dbConnection.execute(`
        SELECT course_name
        FROM courses
        WHERE course_code = ? AND section = ?
      `, [courseCode, section]);

        const courseName = courseResult[0]?.course_name || 'Unknown Course';

        res.json({
            course_code: courseCode,
            course_name: courseName,
            section,
            total_students: totalStudents,
            summary: summary
        });

    } catch (error) {
        console.error('Error fetching PBox1 attendance summary:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get teacher's courses for PBox1
router.get('/api/pbox1-teacher-courses/:teacherId', async (req, res) => {
    const { teacherId } = req.params;

    try {
        const [courses] = await dbConnection.execute(`
        SELECT DISTINCT c.course_code, c.course_name, ct.section
        FROM courses c
        JOIN course_teachers ct ON c.course_code = ct.course_code AND c.section = ct.section
        WHERE ct.teacher_id = ?
      `, [teacherId]);

        res.json(courses);
    } catch (error) {
        console.error('Error fetching teacher courses for PBox1:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});
module.exports = router;
