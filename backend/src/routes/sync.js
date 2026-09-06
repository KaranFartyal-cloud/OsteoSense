const express = require('express');
const router = express.Router();
const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const { authenticate } = require('../middleware/auth');
const { validate, syncBatchSchema } = require('../middleware/validation');
const logger = require('../utils/logger');
const { predictRisk } = require('../services/aiService');

router.use(authenticate);

/**
 * POST /api/v1/sync/batch
 * Accept a batch of offline-created patients and screenings.
 * Each item has: entityType, action, localId, data
 * Returns: mapping of localId → serverId for client to update local DB.
 */
router.post('/batch', validate(syncBatchSchema), async (req, res, next) => {
  try {
    const { items } = req.validatedBody;
    const agentId = req.user.id;
    const results = [];
    const errors = [];

    for (const item of items) {
      try {
        if (item.entityType === 'patients') {
          if (item.action === 'insert') {
            // Check for deduplication by localId
            const existing = await Patient.findOne({ agentId, localId: item.localId });
            if (existing) {
              results.push({ localId: item.localId, serverId: existing._id.toString(), entityType: 'patients', status: 'deduplicated' });
              continue;
            }

            const patient = await Patient.create({
              ...item.data,
              agentId,
              localId: item.localId,
              syncedFromLocal: true,
            });
            results.push({ localId: item.localId, serverId: patient._id.toString(), entityType: 'patients', status: 'created' });

          } else if (item.action === 'update') {
            await Patient.findOneAndUpdate(
              { agentId, localId: item.localId },
              item.data,
              { new: true }
            );
            results.push({ localId: item.localId, entityType: 'patients', status: 'updated' });
          }

        } else if (item.entityType === 'screenings') {
          if (item.action === 'insert') {
            // Find the server patient ID from the local patient ID mapping
            const serverPatient = await Patient.findOne({ agentId, localId: item.data.patientLocalId });
            if (!serverPatient && !item.data.patientServerId) {
              errors.push({ localId: item.localId, error: 'Patient not found on server' });
              continue;
            }

            const existing = await Screening.findOne({ agentId, localId: item.localId });
            if (existing) {
              results.push({ localId: item.localId, serverId: existing._id.toString(), entityType: 'screenings', status: 'deduplicated' });
              continue;
            }

            // Re-run AI to get server-authoritative result (replaces on-device estimate)
            const aiResult = await predictRisk({
              painLevel: item.data.painLevel,
              stiffnessDuration: item.data.stiffnessDuration,
              swelling: item.data.swelling,
              pastInjury: item.data.pastInjury,
              gaitData: item.data.gaitData,
            });

            const patientId = serverPatient?._id || item.data.patientServerId;
            const screening = await Screening.create({
              agentId,
              patientId,
              ...item.data,
              ...aiResult,
              localId: item.localId,
              syncedFromLocal: true,
            });

            // Update patient risk level
            await Patient.findByIdAndUpdate(patientId, { latestRiskLevel: aiResult.riskLevel });

            results.push({ localId: item.localId, serverId: screening._id.toString(), entityType: 'screenings', status: 'created' });
          }
        }
      } catch (itemError) {
        errors.push({ localId: item.localId, entityType: item.entityType, error: itemError.message });
      }
    }

    logger.info(`Sync batch: ${results.length} succeeded, ${errors.length} failed for agent ${agentId}`);

    res.json({
      success: true,
      data: {
        results,
        errors,
        summary: { total: items.length, succeeded: results.length, failed: errors.length },
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/sync/status
 * Returns current sync status for the authenticated agent.
 */
router.get('/status', async (req, res, next) => {
  try {
    const agentId = req.user.id;

    const [patientCount, screeningCount] = await Promise.all([
      Patient.countDocuments({ agentId }),
      Screening.countDocuments({ agentId }),
    ]);

    res.json({
      success: true,
      data: {
        totalPatients: patientCount,
        totalScreenings: screeningCount,
        lastSyncAt: new Date().toISOString(),
      },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
