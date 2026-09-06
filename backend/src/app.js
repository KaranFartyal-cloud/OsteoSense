require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const connectDB = require('./config/database');
const logger = require('./utils/logger');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const PreventiveCare = require('./models/PreventiveCare');

// ─── Routes ───────────────────────────────────────────────────────────────────
const authRoutes = require('./routes/auth');
const patientRoutes = require('./routes/patients');
const screeningRoutes = require('./routes/screenings');
const analyticsRoutes = require('./routes/analytics');
const syncRoutes = require('./routes/sync');
const preventiveCareRoutes = require('./routes/preventiveCare');

const app = express();

// ─── Connect to MongoDB ───────────────────────────────────────────────────────
connectDB().then(async () => {
  // Seed preventive care content if empty
  await PreventiveCare.seedDefaults();
  logger.info('Preventive care content seeded/verified');
});

// ─── Security Middleware ───────────────────────────────────────────────────────
app.use(helmet());

app.use(
  cors({
    origin: (process.env.CORS_ORIGIN || 'http://localhost:3000').split(','),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Global rate limiter
const globalLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
  max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
  message: { success: false, error: 'Too many requests. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(globalLimiter);

// Stricter limiter for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, error: 'Too many authentication attempts. Please wait 15 minutes.' },
});

// ─── General Middleware ────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(
  morgan('combined', {
    stream: { write: (message) => logger.http(message.trim()) },
  })
);

// ─── Health Check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'JointSaathi API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// ─── API Routes ───────────────────────────────────────────────────────────────
const API_PREFIX = '/api/v1';

app.use(`${API_PREFIX}/auth`, authLimiter, authRoutes);
app.use(`${API_PREFIX}/patients`, patientRoutes);
app.use(`${API_PREFIX}/screenings`, screeningRoutes);
app.use(`${API_PREFIX}/analytics`, analyticsRoutes);
app.use(`${API_PREFIX}/sync`, syncRoutes);
app.use(`${API_PREFIX}/preventive-care`, preventiveCareRoutes);

// ─── Swagger Docs ─────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'production') {
  const swaggerOptions = {
    definition: {
      openapi: '3.0.0',
      info: {
        title: 'JointSaathi API',
        version: '1.0.0',
        description: 'AI-Assisted Osteoarthritis Risk Screening API for NER Healthcare Workers',
      },
      servers: [{ url: `http://localhost:${process.env.PORT || 5000}/api/v1` }],
      components: {
        securitySchemes: {
          bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        },
      },
      security: [{ bearerAuth: [] }],
    },
    apis: ['./src/routes/*.js'],
  };
  const swaggerSpec = swaggerJsdoc(swaggerOptions);
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  logger.info('Swagger docs available at /api/docs');
}

// ─── Error Handling ───────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

module.exports = app;
