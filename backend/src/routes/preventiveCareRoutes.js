'use strict';

const express = require('express');
const preventiveCareController = require('../controllers/preventiveCareController');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: PreventiveCare
 *   description: Public, unauthenticated preventive-care content (exercises, diet, lifestyle)
 */

/**
 * @swagger
 * /preventive-care:
 *   get:
 *     summary: List preventive care content, optionally filtered
 *     tags: [PreventiveCare]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema: { type: string, enum: [exercises, diet, lifestyle] }
 *       - in: query
 *         name: lang
 *         schema: { type: string, enum: [en, hi], default: en }
 *     responses:
 *       200:
 *         description: List of preventive care items
 */
router.get('/', preventiveCareController.listPreventiveCare);

module.exports = router;
