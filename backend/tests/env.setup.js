'use strict';

// Runs before the test framework is installed (jest "setupFiles"),
// ensuring src/config/env.js sees valid values when app.js is first required.
// dotenv.config() inside env.js will NOT override these since they're already set.
process.env.NODE_ENV = 'test';
process.env.JWT_ACCESS_SECRET = 'test_access_secret_key_for_jest_runs_only';
process.env.JWT_REFRESH_SECRET = 'test_refresh_secret_key_for_jest_runs_only';
process.env.JWT_ACCESS_EXPIRY = '15m';
process.env.JWT_REFRESH_EXPIRY = '7d';
process.env.MONGODB_URI = 'mongodb://localhost:27017/jointsaathi_test_placeholder';
process.env.AI_SERVICE_URL = 'http://localhost:8000';
process.env.CORS_ORIGINS = 'http://localhost:3000';
