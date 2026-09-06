'use strict';

const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const asyncHandler = require('../utils/asyncHandler');
const logger = require('../utils/logger');
const aiService = require('../services/aiService');

/**
 * Processes a single offline-queued sync item (create/update of a
 * patient or screening). Isolated so a failure in one item never
 * aborts the whole batch (used with Promise.allSettled below).
 */
async function processSyncItem(item, agentId) {
  const { type, localId, action, data } = item;

  if (type === 'patient') {
    if (action === 'create') {
      const patient = await Patient.create({ ...data, agentId });
      return { localId, serverId: patient._id, success: true };
    }
    if (action === 'update' && data.id) {
      // IDOR guard: only update patients belonging to this agent.
      const patient = await Patient.findOneAndUpdate(
        { _id: data.id, agentId },
        { $set: data },
        { new: true }
      );
      if (!patient) throw new Error('Patient not found or not owned by this agent');
      return { localId, serverId: patient._id, success: true };
    }
    throw new Error(`Unsupported patient sync action: ${action}`);
  }

  if (type === 'screening') {
    if (action === 'create') {
      const prediction = await aiService.predictRisk({
        painLevel: data.painLevel,
        stiffnessDuration: data.stiffnessDuration,
        swelling: data.swelling,
        pastInjury: data.pastInjury,
        gaitFeatures: data.gaitFeatures,
      });

      const screening = await Screening.create({
        patientId: data.patientId,
        agentId,
        painLevel: data.painLevel,
        stiffnessDuration: data.stiffnessDuration,
        swelling: data.swelling,
        pastInjury: data.pastInjury,
        gaitRawData: data.gaitFeatures,
        riskLevel: prediction.riskLevel,
        confidence: prediction.confidence,
        contributingFactors: prediction.contributingFactors,
        aiReasoning: prediction.aiReasoning,
        doctorRecommendations: prediction.doctorRecommendations,
        source: prediction.source,
        synced: true,
      });
      return { localId, serverId: screening._id, success: true };
    }
    throw new Error(`Unsupported screening sync action: ${action}`);
  }

  throw new Error(`Unsupported sync item type: ${type}`);
}

/**
 * POST /api/v1/sync/batch
 * Reconciles the mobile app's offline-queued records with the server.
 * Individual item failures are caught and reported without failing
 * the whole batch, so a single malformed record doesn't block the rest.
 */
const batchSync = asyncHandler(async (req, res) => {
  const { items } = req.body;
  const agentId = req.user._id;

  const settled = await Promise.allSettled(
    items.map((item) => processSyncItem(item, agentId))
  );

  const results = settled.map((outcome, idx) => {
    if (outcome.status === 'fulfilled') {
      return outcome.value;
    }
    logger.warn('Sync item failed', { localId: items[idx].localId, error: outcome.reason.message });
    return {
      localId: items[idx].localId,
      success: false,
      error: outcome.reason.message,
    };
  });

  res.status(200).json({ success: true, results });
});

/**
 * GET /api/v1/sync/status
 * Returns server time + last-modified timestamps for this agent's data,
 * so the mobile app can decide what needs re-fetching.
 */
const getSyncStatus = asyncHandler(async (req, res) => {
  const agentId = req.user._id;

  const [lastPatientUpdate, lastScreeningUpdate] = await Promise.all([
    Patient.findOne({ agentId }).sort({ updatedAt: -1 }).select('updatedAt'),
    Screening.findOne({ agentId }).sort({ updatedAt: -1 }).select('updatedAt'),
  ]);

  res.status(200).json({
    success: true,
    data: {
      serverTime: new Date().toISOString(),
      lastPatientUpdate: lastPatientUpdate?.updatedAt || null,
      lastScreeningUpdate: lastScreeningUpdate?.updatedAt || null,
    },
  });
});

module.exports = { batchSync, getSyncStatus };
