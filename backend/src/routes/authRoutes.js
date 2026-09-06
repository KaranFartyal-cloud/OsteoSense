'use strict';

const express = require('express');
const authController = require('../controllers/authController');
const validate = require('../middleware/validate');
const authMiddleware = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/rateLimiter');
const {
  registerSchema,
  loginSchema,
  refreshSchema,
  logoutSchema,
} = require('../schemas/authSchemas');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Registration, login, and token management for field agents
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new field agent or user account
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [fullName, phoneNumber, password]
 *             properties:
 *               fullName: { type: string, example: "Priya Sharma" }
 *               phoneNumber: { type: string, example: "9876543210" }
 *               password: { type: string, example: "SecurePass123" }
 *               role: { type: string, enum: [agent, user], example: agent }
 *               healthCenterId: { type: string, example: "PHC-KHONSA-01" }
 *               location: { type: string, example: "Khonsa, Arunachal Pradesh" }
 *     responses:
 *       201:
 *         description: Account created, returns user + token pair
 *       409:
 *         description: Phone number already registered
 */
router.post('/register', authLimiter, validate(registerSchema), authController.register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Log in with phone number and password
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [phoneNumber, password]
 *             properties:
 *               phoneNumber: { type: string, example: "9876543210" }
 *               password: { type: string, example: "SecurePass123" }
 *     responses:
 *       200:
 *         description: Login successful, returns user + token pair
 *       401:
 *         description: Invalid credentials
 */
router.post('/login', authLimiter, validate(loginSchema), authController.login);

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Exchange a valid refresh token for a new access token
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken: { type: string }
 *     responses:
 *       200:
 *         description: New token pair issued
 *       401:
 *         description: Invalid, expired, or revoked refresh token
 */
router.post('/refresh', validate(refreshSchema), authController.refresh);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Revoke a specific refresh token (log out one device session)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken: { type: string }
 *     responses:
 *       200:
 *         description: Logged out successfully
 *       401:
 *         description: Missing or invalid access token
 */
router.post('/logout', authMiddleware, validate(logoutSchema), authController.logout);

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Get the currently authenticated user's profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Current user profile
 *       401:
 *         description: Missing or invalid access token
 */
router.get('/me', authMiddleware, authController.me);

module.exports = router;
