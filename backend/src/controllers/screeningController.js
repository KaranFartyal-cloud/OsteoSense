'use strict';

const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');
const aiService = require('../services/aiService');
const { generateScreeningReportPdf } = require('../services/pdfService');

/**
 * POST /api/v1/screenings
 * The single most important endpoint in the system -- creates a new
 * screening by combining clinical inputs with an AI (or fallback) risk
 * prediction. Response time matters here (AI call is capped at 5s
 * inside aiService, with automatic fallback).
 */
const createScreening = asyncHandler(async (req, res) => {
  const { patientId, painLevel, stiffnessDuration, swelling, pastInjury, gaitFeatures } = req.body;

  if (!mongoose.Types.ObjectId.isValid(patientId)) {
    throw ApiError.badRequest('Invalid patientId');
  }

  // IDOR guard: the patient must belong to the requesting agent.
  const patient = await Patient.findOne({
    _id: patientId,
    agentId: req.user._id,
    isDeleted: false,
  });
  if (!patient) {
    throw ApiError.notFound('Patient not found');
  }

  const prediction = await aiService.predictRisk({
    painLevel,
    stiffnessDuration,
    swelling,
    pastInjury,
    gaitFeatures,
  });

  const screening = await Screening.create({
    patientId,
    agentId: req.user._id,
    painLevel,
    stiffnessDuration,
    swelling,
    pastInjury,
    gaitRawData: gaitFeatures,
    riskLevel: prediction.riskLevel,
    confidence: prediction.confidence,
    contributingFactors: prediction.contributingFactors,
    aiReasoning: prediction.aiReasoning,
    doctorRecommendations: prediction.doctorRecommendations,
    source: prediction.source,
    synced: true,
  });

  res.status(201).json({ success: true, data: screening });
});

/**
 * GET /api/v1/screenings
 */
const listScreenings = asyncHandler(async (req, res) => {
  const { page, limit, riskLevel, startDate, endDate, patientId } = req.query;

  // IDOR guard: always scope to req.user's own screenings.
  const filter = { agentId: req.user._id };
  if (riskLevel) filter.riskLevel = riskLevel;
  if (patientId) filter.patientId = patientId;
  if (startDate || endDate) {
    filter.screeningDate = {};
    if (startDate) filter.screeningDate.$gte = startDate;
    if (endDate) filter.screeningDate.$lte = endDate;
  }

  const [data, total] = await Promise.all([
    Screening.find(filter)
      .sort({ screeningDate: -1 })
      .skip((page - 1) * limit)
      .limit(limit),
    Screening.countDocuments(filter),
  ]);

  res.status(200).json({
    success: true,
    data,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) || 0 },
  });
});

/**
 * GET /api/v1/screenings/:id
 */
const getScreeningById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw ApiError.notFound('Screening not found');
  }

  // IDOR guard: scope to req.user's own screenings.
  const screening = await Screening.findOne({ _id: id, agentId: req.user._id }).populate(
    'patientId',
    'name age village gender'
  );

  if (!screening) {
    throw ApiError.notFound('Screening not found');
  }

  res.status(200).json({ success: true, data: screening });
});

/**
 * GET /api/v1/screenings/patient/:patientId
 */
const getScreeningsByPatient = asyncHandler(async (req, res) => {
  const { patientId } = req.params;

  // IDOR guard: verify the patient belongs to req.user before returning any screenings.
  const patient = await Patient.findOne({
    _id: patientId,
    agentId: req.user._id,
    isDeleted: false,
  });
  if (!patient) {
    throw ApiError.notFound('Patient not found');
  }

  const screenings = await Screening.find({ patientId }).sort({ screeningDate: -1 });

  res.status(200).json({ success: true, data: screenings });
});

/**
 * GET /api/v1/screenings/:id/report
 * Streams a generated PDF directly in the response (no disk persistence).
 */
const getScreeningReport = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw ApiError.notFound('Screening not found');
  }

  // IDOR guard: scope to req.user's own screenings.
  const screening = await Screening.findOne({ _id: id, agentId: req.user._id }).populate(
    'patientId',
    'name age village gender'
  );

  if (!screening) {
    throw ApiError.notFound('Screening not found');
  }

  const pdfBuffer = await generateScreeningReportPdf(screening.toObject());

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader(
    'Content-Disposition',
    `attachment; filename="screening-report-${screening._id}.pdf"`
  );
  res.status(200).send(pdfBuffer);
});

module.exports = {
  createScreening,
  listScreenings,
  getScreeningById,
  getScreeningsByPatient,
  getScreeningReport,
};
