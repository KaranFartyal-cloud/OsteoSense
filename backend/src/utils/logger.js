'use strict';

const winston = require('winston');
const env = require('./../config/env');

const { combine, timestamp, errors, json, colorize, printf } = winston.format;

const devFormat = combine(
  colorize(),
  timestamp({ format: 'HH:mm:ss' }),
  errors({ stack: true }),
  printf(({ level, message, timestamp: ts, ...meta }) => {
    const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
    return `${ts} [${level}] ${message}${metaStr}`;
  })
);

const prodFormat = combine(timestamp(), errors({ stack: true }), json());

const logger = winston.createLogger({
  level: env.isProduction ? 'info' : 'debug',
  format: env.isProduction ? prodFormat : devFormat,
  transports: [new winston.transports.Console()],
  silent: env.isTest,
});

/**
 * IMPORTANT: never pass raw request bodies containing passwords, tokens,
 * or refreshTokens arrays to this logger. Redact before logging.
 */
module.exports = logger;
