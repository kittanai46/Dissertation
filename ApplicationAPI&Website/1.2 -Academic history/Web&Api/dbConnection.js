// dbConnection.js
const mysql = require('mysql2/promise');

const dbConnection = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "079bf16f",
    database: "mysql_nodejs"
});

module.exports = dbConnection;