const express = require('express');
const path = require('path');
const cookieSession = require('cookie-session');

if (typeof process.loadEnvFile === 'function') {
  try {
    process.loadEnvFile(path.join(__dirname, '.env'));
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
}

const routes = require('./routes');
const dbConnection = require('./dbConnection');
const cors = require('cors');
const app = express();

const allowedOrigins = (process.env.CORS_ORIGINS || '*')
  .split(',')
  .map(origin => origin.trim())
  .filter(Boolean);
const sessionKeys = (process.env.SESSION_KEYS || 'development-key-change-me')
  .split(',')
  .map(key => key.trim())
  .filter(Boolean);

if (process.env.NODE_ENV === 'production' && sessionKeys.includes('development-key-change-me')) {
  throw new Error('SESSION_KEYS must be configured in production');
}

app.set('trust proxy', 1);
app.use(cors({
  origin: allowedOrigins.includes('*') ? '*' : allowedOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(cookieSession({
    name: 'session',
    keys: sessionKeys,
    maxAge: 24 * 60 * 60 * 1000,
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.COOKIE_SECURE === 'true'
}));

// Middleware
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true, limit: '2mb' }));
app.use(express.static(path.join(__dirname, 'public')));

// ตั้งค่า view engine เป็น ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// เพิ่ม logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

app.get('/health', async (req, res) => {
  try {
    await dbConnection.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(503).json({ status: 'error', database: 'disconnected' });
  }
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

// Start server
const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';
app.listen(PORT, HOST, () => console.log(`Server is running on http://${HOST}:${PORT}`));

module.exports = app; // เพื่อการทดสอบ
