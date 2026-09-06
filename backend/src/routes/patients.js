const express = require('express');
const router = express.Router();
const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const { authenticate } = require('../middleware/auth');
const { validate, patientSchema } = require('../middleware/validation');
const logger = require('../utils/logger');

// All patient routes require authentication
router.use(authenticate);

/**
 * POST /api/v1/patients
 * Create a new patient scoped to the authenticated agent.
 */
router.post('/', validate(patientSchema), async (req, res, next) => {
  try {
    const patient = await Patient.create({
      ...req.validatedBody,
      agentId: req.user.id, // CRITICAL: always scope to current agent
    });

    logger.info(`Patient created: ${patient._id} by agent ${req.user.id}`);

    res.status(201).json({ success: true, data: { patient } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/patients
 * List all patients belonging to the authenticated agent.
 * Supports: ?search=name&riskLevel=high&village=xyz&page=1&limit=20
 */
router.get('/', async (req, res, next) => {
  try {
    const { search, riskLevel, village, page = 1, limit = 50 } = req.query;

    // CRITICAL: Always filter by agentId — prevents IDOR cross-agent data leakage
    const filter = { agentId: req.user.id };

    if (riskLevel && ['low', 'medium', 'high'].includes(riskLevel)) {
      filter.latestRiskLevel = riskLevel;
    }
    if (village) {
      filter.village = new RegExp(village, 'i');
    }
    if (search) {
      filter.$or = [
        { fullName: new RegExp(search, 'i') },
        { village: new RegExp(search, 'i') },
        { contact: new RegExp(search, 'i') },
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [patients, total] = await Promise.all([
      Patient.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
      Patient.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data: {
        patients,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/patients/search
 * Text-search patients by name/village (agent-scoped).
 */
router.get('/search', async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q) return res.json({ success: true, data: { patients: [] } });

    const patients = await Patient.find({
      agentId: req.user.id,
      $or: [
        { fullName: new RegExp(q, 'i') },
        { village: new RegExp(q, 'i') },
        { contact: new RegExp(q, 'i') },
      ],
    }).limit(20);

    res.json({ success: true, data: { patients } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/patients/:id
 * Get a single patient — MUST belong to the authenticated agent.
 */
router.get('/:id', async (req, res, next) => {
  try {
    const patient = await Patient.findOne({
      _id: req.params.id,
      agentId: req.user.id, // CRITICAL: ownership check
    });

    if (!patient) {
      return res.status(404).json({ success: false, error: 'Patient not found' });
    }

    res.json({ success: true, data: { patient } });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /api/v1/patients/:id
 * Update patient — MUST belong to the authenticated agent.
 */
router.put('/:id', validate(patientSchema), async (req, res, next) => {
  try {
    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, agentId: req.user.id },
      req.validatedBody,
      { new: true, runValidators: true }
    );

    if (!patient) {
      return res.status(404).json({ success: false, error: 'Patient not found' });
    }

    logger.info(`Patient updated: ${patient._id}`);
    res.json({ success: true, data: { patient } });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /api/v1/patients/:id
 * Soft-delete — MUST belong to the authenticated agent.
 */
router.delete('/:id', async (req, res, next) => {
  try {
    const patient = await Patient.findOneAndDelete({
      _id: req.params.id,
      agentId: req.user.id,
    });

    if (!patient) {
      return res.status(404).json({ success: false, error: 'Patient not found' });
    }

    // Also delete all associated screenings
    await Screening.deleteMany({ patientId: req.params.id, agentId: req.user.id });

    logger.info(`Patient deleted: ${req.params.id} by agent ${req.user.id}`);
    res.json({ success: true, message: 'Patient deleted successfully' });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
