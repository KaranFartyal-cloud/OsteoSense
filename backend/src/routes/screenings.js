const express = require('express');
const router = express.Router();
const Screening = require('../models/Screening');
const Patient = require('../models/Patient');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');
const { validate, screeningSchema } = require('../middleware/validation');
const { predictRisk } = require('../services/aiService');
const { generateScreeningReport } = require('../services/pdfService');
const logger = require('../utils/logger');

router.use(authenticate);

/**
 * POST /api/v1/screenings
 * Create a new screening: calls AI service (or fallback), stores result.
 * This endpoint IS the AI prediction step — the response contains the risk result.
 */
router.post('/', validate(screeningSchema), async (req, res, next) => {
  try {
    const { patientId, painLevel, stiffnessDuration, swelling, pastInjury, pastInjuryDetail, gaitData } = req.validatedBody;

    // Verify patient belongs to this agent (IDOR prevention)
    const patient = await Patient.findOne({ _id: patientId, agentId: req.user.id });
    if (!patient) {
      return res.status(404).json({ success: false, error: 'Patient not found' });
    }

    // Call AI service (with automatic fallback)
    const aiResult = await predictRisk({
      painLevel,
      stiffnessDuration,
      swelling,
      pastInjury,
      gaitData,
    });

    // Save screening with AI result
    const screening = await Screening.create({
      agentId: req.user.id,
      patientId,
      painLevel,
      stiffnessDuration,
      swelling,
      pastInjury,
      pastInjuryDetail,
      gaitData,
      ...aiResult, // riskLevel, confidence, contributingFactors, reasoning, resultSource
    });

    // Update patient's latest risk level (denormalized for list display)
    await Patient.findByIdAndUpdate(patientId, { latestRiskLevel: aiResult.riskLevel });

    logger.info(`Screening created: ${screening._id}, risk=${aiResult.riskLevel}, source=${aiResult.resultSource}`);

    res.status(201).json({ success: true, data: { screening } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/screenings
 * List all screenings for this agent.
 */
router.get('/', async (req, res, next) => {
  try {
    const { page = 1, limit = 50, riskLevel } = req.query;
    const filter = { agentId: req.user.id };
    if (riskLevel) filter.riskLevel = riskLevel;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [screenings, total] = await Promise.all([
      Screening.find(filter)
        .populate('patientId', 'fullName age gender village')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Screening.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data: {
        screenings,
        pagination: { total, page: parseInt(page), limit: parseInt(limit) },
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/screenings/patient/:patientId
 * All screenings for a specific patient (agent-scoped).
 */
router.get('/patient/:patientId', async (req, res, next) => {
  try {
    // Verify patient ownership first
    const patient = await Patient.findOne({ _id: req.params.patientId, agentId: req.user.id });
    if (!patient) {
      return res.status(404).json({ success: false, error: 'Patient not found' });
    }

    const screenings = await Screening.find({
      patientId: req.params.patientId,
      agentId: req.user.id,
    }).sort({ createdAt: -1 });

    res.json({ success: true, data: { screenings, patient } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/screenings/:id
 * Get a single screening (agent-scoped).
 */
router.get('/:id', async (req, res, next) => {
  try {
    const screening = await Screening.findOne({
      _id: req.params.id,
      agentId: req.user.id,
    }).populate('patientId', 'fullName age gender village address contact occupation height weight');

    if (!screening) {
      return res.status(404).json({ success: false, error: 'Screening not found' });
    }

    res.json({ success: true, data: { screening } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/screenings/:id/report
 * Stream a PDF report for the given screening.
 */
router.get('/:id/report', async (req, res, next) => {
  try {
    const screening = await Screening.findOne({
      _id: req.params.id,
      agentId: req.user.id,
    });

    if (!screening) {
      return res.status(404).json({ success: false, error: 'Screening not found' });
    }

    const patient = await Patient.findById(screening.patientId);
    const agent = await User.findById(req.user.id);

    if (!patient || !agent) {
      return res.status(404).json({ success: false, error: 'Patient or agent not found' });
    }

    generateScreeningReport(screening, patient, agent, res);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
