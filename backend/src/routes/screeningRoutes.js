'use strict';

const express = require('express');
const screeningController = require('../controllers/screeningController');
const validate = require('../middleware/validate');
const authMiddleware = require('../middleware/authMiddleware');
const {
  createScreeningSchema,
  listScreeningsQuerySchema,
  patientIdParamSchema,
} = require('../schemas/screeningSchemas');

const router = express.Router();

// All screening routes require authentication.
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Screenings
 *   description: OA risk screenings, powered by the AI microservice with rule-based fallback
 */

/**
 * @swagger
 * /screenings:
 *   post:
 *     summary: Create a new OA risk screening for a patient
 *     description: >
 *       Calls the ML microservice for a risk prediction (5s timeout), automatically
 *       falling back to a rule-based clinical triage heuristic if the AI service is
 *       unreachable. The response always includes a `source` field indicating which
 *       path produced the result (`ml_model` or `fallback_rules`).
 *     tags: [Screenings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [patientId, painLevel]
 *             properties:
 *               patientId: { type: string, example: "6512f9a2b8e4a2d1f8c9e123" }
 *               painLevel: { type: integer, example: 7 }
 *               stiffnessDuration: { type: string, example: "30 minutes" }
 *               swelling: { type: boolean, example: true }
 *               pastInjury: { type: string, example: "Twisted knee in 2019" }
 *               gaitFeatures: { type: array, items: { type: number }, example: [0.42, 0.51, 0.39, 0.61] }
 *     responses:
 *       201:
 *         description: Screening created with AI risk assessment
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 data:
 *                   type: object
 *                   properties:
 *                     riskLevel: { type: string, example: high }
 *                     confidence: { type: number, example: 0.82 }
 *                     source: { type: string, example: ml_model }
 *       404:
 *         description: Patient not found
 *   get:
 *     summary: List screenings for the authenticated agent
 *     tags: [Screenings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *       - in: query
 *         name: riskLevel
 *         schema: { type: string, enum: [low, medium, high] }
 *       - in: query
 *         name: startDate
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: endDate
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: patientId
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Paginated list of screenings
 */
router
  .route('/')
  .post(validate(createScreeningSchema), screeningController.createScreening)
  .get(validate(listScreeningsQuerySchema, 'query'), screeningController.listScreenings);

/**
 * @swagger
 * /screenings/patient/{patientId}:
 *   get:
 *     summary: Get all screenings for a specific patient
 *     tags: [Screenings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: patientId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Screening history for the patient, newest first
 *       404:
 *         description: Patient not found
 */
router.get(
  '/patient/:patientId',
  validate(patientIdParamSchema, 'params'),
  screeningController.getScreeningsByPatient
);

/**
 * @swagger
 * /screenings/{id}:
 *   get:
 *     summary: Get a single screening (patient info populated)
 *     tags: [Screenings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Screening detail
 *       404:
 *         description: Screening not found
 */
router.get('/:id', screeningController.getScreeningById);

/**
 * @swagger
 * /screenings/{id}/report:
 *   get:
 *     summary: Download a PDF report for a screening
 *     tags: [Screenings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: PDF file stream
 *         content:
 *           application/pdf:
 *             schema: { type: string, format: binary }
 *       404:
 *         description: Screening not found
 */
router.get('/:id/report', screeningController.getScreeningReport);

module.exports = router;
