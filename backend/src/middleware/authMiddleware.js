'use strict';

const jwt = require('jsonwebtoken');
const env = require('../config/env');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');

/**
 * Verifies the Bearer access token from the Authorization header,
 * fetches the user from the DB (not just trusting the decoded payload)
 * so that a deactivated user (isActive: false) is immediately locked out
 * even if their token hasn't expired yet, and attaches the user to req.user.
 */
const authMiddleware = asyncHandler(async (req, _res, next) => {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');

  if (scheme !== 'Bearer' || !token) {
    throw ApiError.unauthorized('Unauthorized: missing or malformed access token');
  }

  let decoded;
  try {
    decoded = jwt.verify(token, env.JWT_ACCESS_SECRET);
  } catch (err) {
    throw ApiError.unauthorized('Unauthorized: invalid or expired access token');
  }

  const user = await User.findById(decoded.sub);

  if (!user || !user.isActive) {
    throw ApiError.unauthorized('Unauthorized: account not found or deactivated');
  }

  req.user = user;
  next();
});

module.exports = authMiddleware;
