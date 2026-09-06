const express = require('express');
const router = express.Router();
const Screening = require('../models/Screening');
const Patient = require('../models/Patient');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

/**
 * GET /api/v1/analytics/overview
 * Aggregated stats for the authenticated agent.
 */
router.get('/overview', async (req, res, next) => {
  try {
    const agentId = req.user.id;

    const [patientCount, screeningCount, riskDist] = await Promise.all([
      Patient.countDocuments({ agentId }),
      Screening.countDocuments({ agentId }),
      Screening.aggregate([
        { $match: { agentId: require('mongoose').Types.ObjectId.createFromHexString(agentId) } },
        { $group: { _id: '$riskLevel', count: { $sum: 1 } } },
      ]),
    ]);

    const distribution = { low: 0, medium: 0, high: 0 };
    riskDist.forEach((d) => { distribution[d._id] = d.count; });

    res.json({
      success: true,
      data: {
        totalPatients: patientCount,
        totalScreenings: screeningCount,
        riskDistribution: distribution,
        highRiskCount: distribution.high,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/trends
 * Monthly screening counts for the past 12 months.
 */
router.get('/trends', async (req, res, next) => {
  try {
    const agentId = req.user.id;
    const twelveMonthsAgo = new Date();
    twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

    const trends = await Screening.aggregate([
      {
        $match: {
          agentId: require('mongoose').Types.ObjectId.createFromHexString(agentId),
          createdAt: { $gte: twelveMonthsAgo },
        },
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
          },
          count: { $sum: 1 },
          highRisk: { $sum: { $cond: [{ $eq: ['$riskLevel', 'high'] }, 1, 0] } },
          mediumRisk: { $sum: { $cond: [{ $eq: ['$riskLevel', 'medium'] }, 1, 0] } },
          lowRisk: { $sum: { $cond: [{ $eq: ['$riskLevel', 'low'] }, 1, 0] } },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ]);

    res.json({ success: true, data: { trends } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/risk-distribution
 * Current risk level distribution across all patients.
 */
router.get('/risk-distribution', async (req, res, next) => {
  try {
    const agentId = req.user.id;

    const dist = await Patient.aggregate([
      { $match: { agentId: require('mongoose').Types.ObjectId.createFromHexString(agentId) } },
      { $group: { _id: '$latestRiskLevel', count: { $sum: 1 } } },
    ]);

    const distribution = { low: 0, medium: 0, high: 0, unknown: 0 };
    dist.forEach((d) => {
      if (d._id) distribution[d._id] = d.count;
      else distribution.unknown += d.count;
    });

    res.json({ success: true, data: { distribution } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/locations
 * Village-wise risk breakdown, sorted by highest-risk-first.
 */
router.get('/locations', async (req, res, next) => {
  try {
    const agentId = req.user.id;

    const locations = await Patient.aggregate([
      {
        $match: {
          agentId: require('mongoose').Types.ObjectId.createFromHexString(agentId),
          village: { $exists: true, $ne: null, $ne: '' },
        },
      },
      {
        $group: {
          _id: '$village',
          totalPatients: { $sum: 1 },
          highRisk: { $sum: { $cond: [{ $eq: ['$latestRiskLevel', 'high'] }, 1, 0] } },
          mediumRisk: { $sum: { $cond: [{ $eq: ['$latestRiskLevel', 'medium'] }, 1, 0] } },
          lowRisk: { $sum: { $cond: [{ $eq: ['$latestRiskLevel', 'low'] }, 1, 0] } },
        },
      },
      // Sort by highest-risk-first (high count desc, then total desc)
      { $sort: { highRisk: -1, mediumRisk: -1, totalPatients: -1 } },
    ]);

    res.json({ success: true, data: { locations } });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
