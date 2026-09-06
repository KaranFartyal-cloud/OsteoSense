'use strict';

const express = require('express');
const patientController = require('../controllers/patientController');
const validate = require('../middleware/validate');
const authMiddleware = require('../middleware/authMiddleware');
const {
  createPatientSchema,
  updatePatientSchema,
  listPatientsQuerySchema,
  searchPatientsQuerySchema,
} = require('../schemas/patientSchemas');

const router = express.Router();

// All patient routes require authentication.
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Patients
 *   description: Patient records management (scoped per field agent)
 */

/**
 * @swagger
 * /patients:
 *   post:
 *     summary: Register a new patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, age, gender]
 *             properties:
 *               name: { type: string, example: "Tenzin Norbu" }
 *               age: { type: integer, example: 58 }
 *               gender: { type: string, enum: [male, female, other], example: male }
 *               contact: { type: string, example: "9876543210" }
 *               village: { type: string, example: "Tawang" }
 *               address: { type: string }
 *               occupation: { type: string, example: "Farmer" }
 *               height: { type: number, example: 165 }
 *               weight: { type: number, example: 70 }
 *     responses:
 *       201:
 *         description: Patient created
 *   get:
 *     summary: List patients belonging to the authenticated agent
 *     tags: [Patients]
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
 *         name: village
 *         schema: { type: string }
 *       - in: query
 *         name: riskLevel
 *         schema: { type: string, enum: [low, medium, high] }
 *     responses:
 *       200:
 *         description: Paginated list of patients, each with their latest screening attached
 */
router
  .route('/')
  .post(validate(createPatientSchema), patientController.createPatient)
  .get(validate(listPatientsQuerySchema, 'query'), patientController.listPatients);

/**
 * @swagger
 * /patients/search:
 *   get:
 *     summary: Full-text search across the agent's own patients (by name/village)
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: q
 *         required: true
 *         schema: { type: string, minLength: 2 }
 *     responses:
 *       200:
 *         description: Matching patients (max 20)
 */
router.get(
  '/search',
  validate(searchPatientsQuerySchema, 'query'),
  patientController.searchPatients
);

/**
 * @swagger
 * /patients/{id}:
 *   get:
 *     summary: Get a single patient with screening history summary
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Patient detail
 *       404:
 *         description: Patient not found
 *   put:
 *     summary: Update a patient's details
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Updated patient
 *       404:
 *         description: Patient not found
 *   delete:
 *     summary: Soft-delete a patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Patient deleted (soft)
 *       404:
 *         description: Patient not found
 */
router
  .route('/:id')
  .get(patientController.getPatientById)
  .put(validate(updatePatientSchema), patientController.updatePatient)
  .delete(patientController.deletePatient);

module.exports = router;
