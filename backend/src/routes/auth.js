const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { generateTokenPair, verifyRefreshToken } = require('../utils/jwt');
const { authenticate } = require('../middleware/auth');
const { validate, registerSchema, loginSchema, refreshSchema } = require('../middleware/validation');
const logger = require('../utils/logger');

/**
 * POST /api/v1/auth/register
 * Register a new health worker or self-check user.
 */
router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const { fullName, phoneNumber, password, role, healthCenterId, location } = req.validatedBody;

    const existing = await User.findOne({ phoneNumber });
    if (existing) {
      return res.status(409).json({
        success: false,
        error: 'Phone number already registered',
      });
    }

    const user = await User.create({ fullName, phoneNumber, password, role, healthCenterId, location });

    const tokens = generateTokenPair({ id: user._id, phoneNumber: user.phoneNumber, role: user.role });

    // Store refresh token in DB
    user.refreshToken = tokens.refreshToken;
    await user.save({ validateBeforeSave: false });

    logger.info(`New user registered: ${phoneNumber} (${role})`);

    res.status(201).json({
      success: true,
      data: {
        user: user.toJSON(),
        ...tokens,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/auth/login
 */
router.post('/login', validate(loginSchema), async (req, res, next) => {
  try {
    const { phoneNumber, password } = req.validatedBody;

    // +password because it's select:false in the schema
    const user = await User.findOne({ phoneNumber }).select('+password +refreshToken');
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials',
      });
    }

    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials',
      });
    }

    const tokens = generateTokenPair({ id: user._id, phoneNumber: user.phoneNumber, role: user.role });
    user.refreshToken = tokens.refreshToken;
    await user.save({ validateBeforeSave: false });

    logger.info(`User logged in: ${phoneNumber}`);

    res.json({
      success: true,
      data: {
        user: user.toJSON(),
        ...tokens,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/auth/refresh
 * Exchange a valid refresh token for a new token pair.
 */
router.post('/refresh', validate(refreshSchema), async (req, res, next) => {
  try {
    const { refreshToken } = req.validatedBody;

    let decoded;
    try {
      decoded = verifyRefreshToken(refreshToken);
    } catch {
      return res.status(401).json({
        success: false,
        error: 'Invalid or expired refresh token',
      });
    }

    const user = await User.findById(decoded.id).select('+refreshToken');
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({
        success: false,
        error: 'Refresh token revoked',
      });
    }

    const tokens = generateTokenPair({ id: user._id, phoneNumber: user.phoneNumber, role: user.role });
    user.refreshToken = tokens.refreshToken;
    await user.save({ validateBeforeSave: false });

    res.json({
      success: true,
      data: tokens,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/auth/logout
 * Invalidate the refresh token.
 */
router.post('/logout', authenticate, async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, { refreshToken: null });
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/auth/me
 * Return current user info.
 */
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    res.json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
