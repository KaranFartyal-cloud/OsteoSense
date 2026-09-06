'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const mongoSanitize = require('express-mongo-sanitize');
const swaggerUi = require('swagger-ui-express');

const env = require('./config/env');
const swaggerSpec = require('./config/swagger');
const logger = require('./utils/logger');
const { generalLimiter } = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const notFound = require('./middleware/notFound');

const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');
const screeningRoutes = require('./routes/screeningRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');
const syncRoutes = require('./routes/syncRoutes');
const preventiveCareRoutes = require('./routes/preventiveCareRoutes');

const app = express();

// Security headers
app.use(helmet());

// CORS - explicit allowed origins from env (comma-separated list supported)
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow non-browser tools (curl/Postman/mobile app native fetch) with no Origin header.
      if (!origin || env.CORS_ORIGINS.includes(origin)) {
        return callback(null, true);
      }
      return callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true,
  })
);

// Body parsing
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

// Prevent NoSQL injection via query params / body
app.use(mongoSanitize());

// HTTP request logging piped through winston, skipped in test env
if (!env.isTest) {
  app.use(
    morgan('combined', {
      stream: { write: (message) => logger.info(message.trim()) },
    })
  );
}

// General rate limiting (auth routes have their own stricter limiter)
app.use('/api/v1', generalLimiter);

// Health check
app.get('/health', (_req, res) => {
  res.status(200).json({ success: true, status: 'ok', timestamp: new Date().toISOString() });
});

// API docs
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/patients', patientRoutes);
app.use('/api/v1/screenings', screeningRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/sync', syncRoutes);
app.use('/api/v1/preventive-care', preventiveCareRoutes);

// 404 + centralized error handler (must be last)
app.use(notFound);
app.use(errorHandler);

module.exports = app;
