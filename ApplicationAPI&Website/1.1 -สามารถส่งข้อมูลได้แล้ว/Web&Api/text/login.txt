const express = require('express');
const path = require('path');
const cookieSession = require('cookie-session');
const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');
const { body, validationResult } = require('express-validator');

const app = express();

const dbConnection = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "079bf16f",
    database: "mysql_nodejs"
});
module.exports = dbConnection;

// Check Connection
dbConnection.getConnection()
    .then(connection => {
        console.log("Database connected successfully");
        connection.release();
    })
    .catch(error => {
        console.error("Database connection failed:", error);
    });

// Set view engine to ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static files such as CSS, images
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.urlencoded({ extended: false }));

app.use(cookieSession({
    name: 'session',
    keys: ['key1', 'key2'],
    maxAge: 3600 * 1000 // 1 hour
}));

// Middleware to check login status
const ifNotLoggedIn = (req, res, next) => {
    if (!req.session.isLoggedIn) {
        return res.render('login'); // If not logged in, render login page
    }
    next();
};

const ifLoggedin = (req, res, next) => {
    if (req.session.isLoggedIn) {
        return res.redirect('/home'); // If logged in, redirect to home
    }
    next();
};

// Root page
app.get('/', ifLoggedin, (req, res) => {
    res.redirect('/home'); // Redirect to /home if logged in
});

// HOME PAGE
app.get('/home', ifNotLoggedIn, async (req, res) => {
    try {
        // const [results] = await dbConnection.query('SELECT * FROM subjects');
        res.render('home'); // Pass subjects to home.ejs res.render('home', { subjects: results });
    } catch (err) {
        console.error(err);
        res.status(500).send("Internal Server Error");
    }
});
// END HOME PAGE

// REGISTER PAGE
app.post('/register', [
    // ตรวจสอบ role ว่ามีค่าเป็น student หรือ teacher เท่านั้น
    body('role').isIn(['student', 'teacher']).withMessage('Invalid role selected!'),
    body('first_name').trim().not().isEmpty().withMessage('First Name cannot be empty!'),
    body('last_name').trim().not().isEmpty().withMessage('Last Name cannot be empty!'),
    body('id_number').trim().not().isEmpty().withMessage('ID Number cannot be empty!').custom((value) => {
        return dbConnection.execute('SELECT `id_number` FROM `users` WHERE `id_number`=?', [value])
        .then(([rows]) => {
            if (rows.length > 0) {
                return Promise.reject('This ID Number is already in use!');
            }
            return true;
        });
    }),
    body('password').trim().isLength({ min: 6 }).withMessage('The password must be at least 6 characters long'),
], (req, res, next) => {
    const validation_result = validationResult(req);
    const { first_name, last_name, id_number, password, role } = req.body;

    if (validation_result.isEmpty()) {
        bcrypt.hash(password, 12).then((hash_pass) => {
            dbConnection.execute("INSERT INTO `users`(`first_name`, `last_name`, `id_number`, `password`, `role`) VALUES(?,?,?,?,?)", [first_name, last_name, id_number, hash_pass, role])
            .then(result => {
                res.send(`Your account has been created successfully. Now you can <a href="/">Login</a>`);
            }).catch(err => {
                next(err);
            });
        })
        .catch(err => {
            next(err);
        });
    } else {
        let allErrors = validation_result.errors.map((error) => {
            return error.msg;
        });
        res.render('register', {
            register_errors: allErrors,
            old_data: req.body
        });
    }
});
// End register page

// Login page
app.post('/', ifLoggedin, [
    body('user_id').trim().not().isEmpty().withMessage('User ID cannot be empty!').custom((value) => {
        console.log('Received Login User ID:', value); // Debugging
        return dbConnection.execute('SELECT user_id FROM users WHERE user_id=?', [value])
        .then(([rows]) => {
            if(rows.length === 1){
                return true;
            }
            return Promise.reject('Invalid User ID!');
        });
    }),
    body('user_password').trim().not().isEmpty().withMessage('Password is empty!'),
], (req, res, next) => {
    const validation_result = validationResult(req);
    const { user_password, user_id } = req.body;

    console.log('Login Request Body:', req.body); // Debugging

    if(validation_result.isEmpty()){
        dbConnection.execute("SELECT * FROM `users` WHERE `user_id`=?", [user_id])
        .then(([rows]) => {
            console.log('Query Result:', rows); // Log complete result to check structure

            if (rows.length > 0) {
                const hashedPassword = rows[0].user_password;
                console.log('Hashed Password from DB:', hashedPassword); // Debugging
                
                // Ensure `user_password` and `hashedPassword` are not undefined or null
                if (!user_password || !hashedPassword) {
                    console.error('Error: user_password or hashedPassword is missing');
                    return res.render('login', {
                        login_errors: ['An error occurred. Please try again.']
                    });
                }

                bcrypt.compare(user_password, hashedPassword)
                .then(compare_result => {
                    if(compare_result === true){
                        req.session.isLoggedIn = true;
                        req.session.userID = rows[0].user_id;
                        res.redirect('/');
                    }
                    else{
                        res.render('login', {
                            login_errors: ['Invalid Password!']
                        });
                    }
                })
                .catch(err => {
                    console.error('Error during bcrypt.compare:', err); // Debugging
                    next(err);
                });
            } else {
                res.render('login', {
                    login_errors: ['Invalid User ID!']
                });
            }
        }).catch(err => {
            console.error('Error during database query:', err); // Debugging
            next(err);
        });
    }
    else{
        let allErrors = validation_result.errors.map((error) => {
            return error.msg;
        });
        res.render('login', {
            login_errors: allErrors
        });
    }
});

// LOGOUT
app.get('/logout', (req, res) => {
    req.session = null;
    res.redirect('/');
});
// END OF LOGOUT

// Register page
app.get('/register', (req, res) => {
    res.render('register'); // Render register.ejs
});

// Classroom Page
app.get('/classroom', async (req, res) => {
    try {
        const [results] = await dbConnection.query('SELECT * FROM subjects ORDER BY year DESC');
        res.render('classroom'); // Pass subjects to classroom.ejs res.render('classroom', { subjects: results });
    } catch (err) {
        console.error(err);
        res.status(500).send("Internal Server Error");
    }
});

// Subject/id/year
// app.get('/subject/:name/:year', (req, res) => {
//     const subjectName = req.params.name;
//     const year = req.params.year;

//     // Construct the view file name based on subjectName and year
//     const viewFile = `${subjectName}_${year}.ejs`;

//     // Render the view file if it exists
//     res.render(viewFile, { subjectName, year });
// });

// Middleware to handle 404 errors
app.use((req, res) => {
    res.status(404).send('<h1>404 Page Not Found!!!</h1>');
});

// Start server
app.listen(3000, () => console.log("Server is running on http://localhost:3000"));
