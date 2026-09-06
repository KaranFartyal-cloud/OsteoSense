'use strict';

const mongoose = require('mongoose');
const env = require('./env');
const logger = require('../utils/logger');

const MAX_RETRIES = 5;
const RETRY_DELAY_MS = 3000;

mongoose.set('strictQuery', true);

/**
 * Connects to MongoDB with exponential-ish retry logic.
 * In a field-deployment context (health camps with patchy connectivity
 * to the DB server, or DB spinning up slightly after the app in docker-compose),
 * failing to connect on the first attempt shouldn't crash the whole process.
 */
async function connectDB(retries = MAX_RETRIES) {
  try {
    await mongoose.connect(env.MONGODB_URI, {
      serverSelectionTimeoutMS: 8000,
    });
    logger.info('MongoDB connected', { uri: maskUri(env.MONGODB_URI) });
  } catch (err) {
    logger.error('MongoDB connection failed', { error: err.message, retriesLeft: retries - 1 });

    if (retries <= 1) {
      logger.error('Exhausted MongoDB connection retries. Exiting.');
      process.exit(1);
    }

    await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
    return connectDB(retries - 1);
  }
}

mongoose.connection.on('disconnected', () => {
  logger.warn('MongoDB disconnected');
});

mongoose.connection.on('reconnected', () => {
  logger.info('MongoDB reconnected');
});

function maskUri(uri) {
  // Avoid logging credentials if present in the connection string
  return uri.replace(/\/\/(.*):(.*)@/, '//***:***@');
}

module.exports = connectDB;
