const express = require('express');
const path = require('path');
const cookieSession = require('cookie-session');
const cors = require('cors'); // Middleware for handling CORS
const routes = require('./routes');
const dbConnection = require('./dbConnection');
const app = express();

// Enable CORS for requests from Flutter and the web
app.use(cors({
    origin: '*', // Allow requests from any origin. You can restrict this if needed.
    methods: ['GET', 'POST'], // Only allow GET and POST requests.
    allowedHeaders: ['Content-Type'], // Allow specific headers.
}));

// Set up cookie-session for handling sessions
app.use(cookieSession({
    name: 'session',
    keys: ['key1', 'key2'], // Encryption keys for the session
    maxAge: 3600 * 1000 // 1 hour session expiration
}));

// Check database connection
dbConnection.getConnection()
    .then(connection => {
        console.log("Database connected successfully");
        connection.release();
    })
    .catch(error => {
        console.error("Database connection failed:", error);
    });

// Middleware to parse incoming requests
app.use(express.urlencoded({ extended: false }));
app.use(express.json()); // Parses JSON request bodies

// Serve static files for web (e.g., stylesheets, images)
app.use(express.static(path.join(__dirname, 'public')));

// Set the view engine for rendering web pages (optional if you're using ejs templates for the web app)
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Use the routes defined in routes.js
app.use('/', routes);

// 404 handler for any unrecognized routes
app.use((req, res) => {
    res.status(404).json({ error: '404 Page Not Found!' });
});

// Start the server
app.listen(4000, () => {
    console.log("Server is running on http://192.168.1.171:4000");
});
