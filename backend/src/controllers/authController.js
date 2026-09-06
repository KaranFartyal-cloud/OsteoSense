'use strict';

const bcrypt = require('bcrypt');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');
const tokenService = require('../services/tokenService');

const SALT_ROUNDS = 12;

/**
 * POST /api/v1/auth/register
 */
const register = asyncHandler(async (req, res) => {
  const { fullName, phoneNumber, password, role, healthCenterId, location } = req.body;

  const existing = await User.findOne({ phoneNumber });
  if (existing) {
    throw ApiError.conflict('An account with this phone number already exists');
  }

  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

  const user = await User.create({
    fullName,
    phoneNumber,
    passwordHash,
    role,
    healthCenterId,
    location,
  });

  const { accessToken, refreshToken } = tokenService.issueTokenPair(user);
  await user.save();

  res.status(201).json({
    success: true,
    data: { user, accessToken, refreshToken },
  });
});

/**
 * POST /api/v1/auth/login
 */
const login = asyncHandler(async (req, res) => {
  const { phoneNumber, password } = req.body;

  // select('+passwordHash') needed since it's select:false on the schema
  const user = await User.findOne({ phoneNumber }).select('+passwordHash +refreshTokens');

  // Generic message regardless of whether phone or password was wrong,
  // to avoid leaking which one was incorrect (user enumeration protection).
  if (!user || !user.isActive) {
    throw ApiError.unauthorized('Invalid credentials');
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    throw ApiError.unauthorized('Invalid credentials');
  }

  const { accessToken, refreshToken } = tokenService.issueTokenPair(user);
  await user.save();

  res.status(200).json({
    success: true,
    data: { user, accessToken, refreshToken },
  });
});

/**
 * POST /api/v1/auth/refresh
 */
const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  let decoded;
  try {
    decoded = tokenService.verifyRefreshToken(refreshToken);
  } catch (err) {
    throw ApiError.unauthorized('Invalid or expired refresh token');
  }

  const user = await User.findById(decoded.sub).select('+refreshTokens');
  if (!user || !user.isActive) {
    throw ApiError.unauthorized('Invalid or expired refresh token');
  }

  // Ensures the token hasn't been revoked (e.g. via logout) even if its signature is still valid.
  if (!user.refreshTokens.includes(refreshToken)) {
    throw ApiError.unauthorized('Refresh token has been revoked');
  }

  // Rotate: remove the old refresh token, issue a fresh pair.
  user.refreshTokens = user.refreshTokens.filter((t) => t !== refreshToken);
  const { accessToken, refreshToken: newRefreshToken } = tokenService.issueTokenPair(user);
  await user.save();

  res.status(200).json({
    success: true,
    data: { accessToken, refreshToken: newRefreshToken },
  });
});

/**
 * POST /api/v1/auth/logout
 * Protected route.
 */
const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  const user = await User.findById(req.user._id).select('+refreshTokens');
  if (user) {
    user.refreshTokens = user.refreshTokens.filter((t) => t !== refreshToken);
    await user.save();
  }

  res.status(200).json({ success: true, message: 'Logged out' });
});

/**
 * GET /api/v1/auth/me
 * Protected route.
 */
const me = asyncHandler(async (req, res) => {
  res.status(200).json({ success: true, data: { user: req.user } });
});

module.exports = { register, login, refresh, logout, me };
