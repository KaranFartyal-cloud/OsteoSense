'use strict';

const rateLimit = require('express-rate-limit');
const env = require('../config/env');

// Rate limiters use an in-memory store that persists for the lifetime of the
// process (or the window). In NODE_ENV=test, a single Jest file can easily
// fire more than 5 auth requests against the same IP across many `it()` blocks
// sharing one `app` instance -- that's a test-runner artifact, not something
// we want to police. Skip enforcement entirely in test env so status-code
// assertions reflect actual handler behavior rather than incidental request volume.
const skipInTest = () => env.isTest;

/**
 * Strict limiter for auth endpoints prone to brute-force / credential
 * stuffing (login, register): 5 requests per 15 minutes per IP.
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  skip: skipInTest,
  message: {
    success: false,
    message: 'Too many attempts. Please try again after 15 minutes.',
  },
});

/**
 * General-purpose limiter applied globally to the rest of the API:
 * 100 requests per 15 minutes per IP.
 */
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  skip: skipInTest,
  message: {
    success: false,
    message: 'Too many requests. Please slow down and try again shortly.',
  },
});

module.exports = { authLimiter, generalLimiter };
