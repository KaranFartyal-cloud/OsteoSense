'use strict';

const app = require('./src/app');
const connectDB = require('./src/config/db');
const env = require('./src/config/env');
const logger = require('./src/utils/logger');

let server;

async function start() {
  await connectDB();

  server = app.listen(env.PORT, () => {
    logger.info(`JointSaathi backend listening on port ${env.PORT}`, {
      env: env.NODE_ENV,
    });
    logger.info(`API docs available at http://localhost:${env.PORT}/api-docs`);
  });
}

// Graceful shutdown
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

function shutdown() {
  logger.info('Shutting down gracefully...');
  if (server) {
    server.close(() => {
      logger.info('HTTP server closed.');
      process.exit(0);
    });
  } else {
    process.exit(0);
  }
}

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Promise Rejection', { reason: reason?.message || reason });
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception', { error: err.message, stack: err.stack });
  process.exit(1);
});

start();
