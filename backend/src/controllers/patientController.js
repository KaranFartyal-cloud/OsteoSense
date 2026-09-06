'use strict';

const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');

/**
 * POST /api/v1/patients
 */
const createPatient = asyncHandler(async (req, res) => {
  const patient = await Patient.create({
    ...req.body,
    agentId: req.user._id, // always derived from the authenticated agent, never from client input
  });

  res.status(201).json({ success: true, data: patient });
});

/**
 * GET /api/v1/patients
 * Attaches each patient's latest screening (riskLevel, screeningDate) via $lookup
 * for the mobile app's patient-list risk badges.
 */
const listPatients = asyncHandler(async (req, res) => {
  const { page, limit, village, riskLevel } = req.query;

  // IDOR guard: every query MUST scope to req.user.id so one agent can never see another's patients.
  const match = { agentId: req.user._id, isDeleted: false };
  if (village) match.village = village;

  const pipeline = [
    { $match: match },
    { $sort: { createdAt: -1 } },
    {
      $lookup: {
        from: 'screenings',
        let: { patientId: '$_id' },
        pipeline: [
          { $match: { $expr: { $eq: ['$patientId', '$$patientId'] } } },
          { $sort: { screeningDate: -1 } },
          { $limit: 1 },
          { $project: { riskLevel: 1, screeningDate: 1, confidence: 1, _id: 0 } },
        ],
        as: 'latestScreening',
      },
    },
    {
      $addFields: {
        latestScreening: { $arrayElemAt: ['$latestScreening', 0] },
      },
    },
  ];

  // Optional filter on latest screening's risk level (post-lookup)
  if (riskLevel) {
    pipeline.push({ $match: { 'latestScreening.riskLevel': riskLevel } });
  }

  pipeline.push(
    {
      $facet: {
        data: [{ $skip: (page - 1) * limit }, { $limit: limit }],
        totalCount: [{ $count: 'count' }],
      },
    }
  );

  const [result] = await Patient.aggregate(pipeline);
  const data = (result?.data || []).map((doc) => {
    doc.id = doc._id;
    delete doc._id;
    delete doc.__v;
    return doc;
  });
  const total = result?.totalCount?.[0]?.count || 0;

  res.status(200).json({
    success: true,
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit) || 0,
    },
  });
});

/**
 * GET /api/v1/patients/search?q=
 * Scoped to req.user's own patients only.
 */
const searchPatients = asyncHandler(async (req, res) => {
  const { q } = req.query;

  const patients = await Patient.find(
    {
      agentId: req.user._id, // IDOR guard: scope search to this agent's patients only
      isDeleted: false,
      $text: { $search: q },
    },
    { score: { $meta: 'textScore' } }
  )
    .sort({ score: { $meta: 'textScore' } })
    .limit(20);

  res.status(200).json({ success: true, data: patients });
});

/**
 * GET /api/v1/patients/:id
 */
const getPatientById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw ApiError.notFound('Patient not found');
  }

  // IDOR guard: agentId must match req.user._id
  const patient = await Patient.findOne({ _id: id, agentId: req.user._id, isDeleted: false });
  if (!patient) {
    throw ApiError.notFound('Patient not found');
  }

  const [screeningCount, mostRecentScreening] = await Promise.all([
    Screening.countDocuments({ patientId: patient._id }),
    Screening.findOne({ patientId: patient._id }).sort({ screeningDate: -1 }),
  ]);

  const payload = patient.toJSON();
  payload.screeningHistoryCount = screeningCount;
  payload.mostRecentScreening = mostRecentScreening || null;

  res.status(200).json({ success: true, data: payload });
});

/**
 * PUT /api/v1/patients/:id
 */
const updatePatient = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw ApiError.notFound('Patient not found');
  }

  // IDOR guard: only update if it belongs to req.user
  const patient = await Patient.findOneAndUpdate(
    { _id: id, agentId: req.user._id, isDeleted: false },
    { $set: req.body },
    { new: true, runValidators: true }
  );

  if (!patient) {
    throw ApiError.notFound('Patient not found');
  }

  res.status(200).json({ success: true, data: patient });
});

/**
 * DELETE /api/v1/patients/:id
 * Soft delete only.
 */
const deletePatient = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw ApiError.notFound('Patient not found');
  }

  // IDOR guard: only soft-delete if it belongs to req.user
  const patient = await Patient.findOneAndUpdate(
    { _id: id, agentId: req.user._id, isDeleted: false },
    { $set: { isDeleted: true } },
    { new: true }
  );

  if (!patient) {
    throw ApiError.notFound('Patient not found');
  }

  res.status(200).json({ success: true, message: 'Patient deleted' });
});

module.exports = {
  createPatient,
  listPatients,
  searchPatients,
  getPatientById,
  updatePatient,
  deletePatient,
};
