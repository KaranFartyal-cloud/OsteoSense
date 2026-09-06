'use strict';

require('dotenv').config();

/**
 * Centralized environment variable access + validation.
 * Fails fast at boot if required vars are missing, instead of
 * surfacing confusing runtime errors deep in the request lifecycle.
 */

const REQUIRED_VARS = [
  'MONGODB_URI',
  'JWT_ACCESS_SECRET',
  'JWT_REFRESH_SECRET',
];

function validateEnv() {
  const missing = REQUIRED_VARS.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    // eslint-disable-next-line no-console
    console.error(
      `[FATAL] Missing required environment variables: ${missing.join(', ')}\n` +
        'Copy .env.example to .env and fill in the values before starting the server.'
    );
    process.exit(1);
  }

  if (process.env.NODE_ENV === 'production') {
    if (
      process.env.JWT_ACCESS_SECRET.length < 32 ||
      process.env.JWT_REFRESH_SECRET.length < 32
    ) {
      // eslint-disable-next-line no-console
      console.error(
        '[FATAL] JWT secrets must be at least 32 characters long in production.'
      );
      process.exit(1);
    }
  }
}

validateEnv();

const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT, 10) || 5000,
  MONGODB_URI: process.env.MONGODB_URI,
  JWT_ACCESS_SECRET: process.env.JWT_ACCESS_SECRET,
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET,
  JWT_ACCESS_EXPIRY: process.env.JWT_ACCESS_EXPIRY || '15m',
  JWT_REFRESH_EXPIRY: process.env.JWT_REFRESH_EXPIRY || '7d',
  AI_SERVICE_URL: process.env.AI_SERVICE_URL || 'http://localhost:8000',
  CORS_ORIGINS: (process.env.CORS_ORIGINS || 'http://localhost:3000')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean),
  MAX_REFRESH_TOKENS_PER_USER:
    parseInt(process.env.MAX_REFRESH_TOKENS_PER_USER, 10) || 5,
  isProduction: process.env.NODE_ENV === 'production',
  isTest: process.env.NODE_ENV === 'test',
};

module.exports = env;
