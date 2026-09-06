'use strict';

const express = require('express');
const analyticsController = require('../controllers/analyticsController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Analytics
 *   description: Aggregate insights scoped to the authenticated agent's data
 */

/**
 * @swagger
 * /analytics/overview:
 *   get:
 *     summary: High-level overview stats (patients, screenings, risk distribution, avg confidence)
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Overview stats
 */
router.get('/overview', analyticsController.getOverview);

/**
 * @swagger
 * /analytics/trends:
 *   get:
 *     summary: Screening volume over time, for a line chart
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: period
 *         schema: { type: string, enum: [7d, 30d, 90d], default: 30d }
 *     responses:
 *       200:
 *         description: Array of { date, count }
 */
router.get('/trends', analyticsController.getTrends);

/**
 * @swagger
 * /analytics/risk-distribution:
 *   get:
 *     summary: Lightweight risk-level distribution for chart widgets
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: { low, medium, high } counts
 */
router.get('/risk-distribution', analyticsController.getRiskDistribution);

/**
 * @swagger
 * /analytics/locations:
 *   get:
 *     summary: Screening counts and high-risk rates grouped by village
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Villages sorted by high-risk count descending
 */
router.get('/locations', analyticsController.getLocations);

module.exports = router;
