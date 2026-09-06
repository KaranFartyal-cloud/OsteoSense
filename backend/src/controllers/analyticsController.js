'use strict';

const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Screening = require('../models/Screening');
const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');

/**
 * GET /api/v1/analytics/overview
 * All aggregations are scoped to req.user._id (IDOR guard) so one agent
 * never sees another agent's stats.
 */
const getOverview = asyncHandler(async (req, res) => {
  const agentId = req.user._id;

  const [totalPatients, totalScreenings, riskAgg, confidenceAgg] = await Promise.all([
    Patient.countDocuments({ agentId, isDeleted: false }),
    Screening.countDocuments({ agentId }),
    Screening.aggregate([
      { $match: { agentId } },
      { $group: { _id: '$riskLevel', count: { $sum: 1 } } },
    ]),
    Screening.aggregate([
      { $match: { agentId, confidence: { $ne: null } } },
      { $group: { _id: null, avgConfidence: { $avg: '$confidence' } } },
    ]),
  ]);

  const riskDistribution = { low: 0, medium: 0, high: 0 };
  riskAgg.forEach((bucket) => {
    if (bucket._id in riskDistribution) riskDistribution[bucket._id] = bucket.count;
  });

  const avgConfidence = confidenceAgg[0]?.avgConfidence ?? null;

  res.status(200).json({
    success: true,
    data: {
      totalPatients,
      totalScreenings,
      riskDistribution,
      avgConfidence: avgConfidence !== null ? Math.round(avgConfidence * 100) / 100 : null,
    },
  });
});

/**
 * GET /api/v1/analytics/trends?period=30d
 */
const getTrends = asyncHandler(async (req, res) => {
  const agentId = req.user._id;
  const period = req.query.period || '30d';

  const match = period.match(/^(\d+)d$/);
  const days = match ? parseInt(match[1], 10) : 30;
  if (![7, 30, 90].includes(days)) {
    throw ApiError.badRequest('period must be one of: 7d, 30d, 90d');
  }

  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);

  const groupByWeek = days > 30;
  const dateFormat = groupByWeek ? '%G-W%V' : '%Y-%m-%d';

  const trends = await Screening.aggregate([
    { $match: { agentId, screeningDate: { $gte: startDate } } },
    {
      $group: {
        _id: { $dateToString: { format: dateFormat, date: '$screeningDate' } },
        count: { $sum: 1 },
      },
    },
    { $sort: { _id: 1 } },
    { $project: { _id: 0, date: '$_id', count: 1 } },
  ]);

  res.status(200).json({ success: true, data: trends });
});

/**
 * GET /api/v1/analytics/risk-distribution
 * Lightweight standalone endpoint for when the frontend only needs this chart.
 */
const getRiskDistribution = asyncHandler(async (req, res) => {
  const agentId = req.user._id;

  const riskAgg = await Screening.aggregate([
    { $match: { agentId } },
    { $group: { _id: '$riskLevel', count: { $sum: 1 } } },
  ]);

  const riskDistribution = { low: 0, medium: 0, high: 0 };
  riskAgg.forEach((bucket) => {
    if (bucket._id in riskDistribution) riskDistribution[bucket._id] = bucket.count;
  });

  res.status(200).json({ success: true, data: riskDistribution });
});

/**
 * GET /api/v1/analytics/locations
 * Surfaces the worst-affected villages first -- directly relevant to the
 * problem statement's "identify high-risk regions" objective.
 */
const getLocations = asyncHandler(async (req, res) => {
  const agentId = req.user._id;

  const locations = await Screening.aggregate([
    { $match: { agentId } },
    {
      $lookup: {
        from: 'patients',
        localField: 'patientId',
        foreignField: '_id',
        as: 'patient',
      },
    },
    { $unwind: '$patient' },
    {
      $group: {
        _id: { $ifNull: ['$patient.village', 'Unknown'] },
        totalScreenings: { $sum: 1 },
        highRiskCount: {
          $sum: { $cond: [{ $eq: ['$riskLevel', 'high'] }, 1, 0] },
        },
      },
    },
    {
      $project: {
        _id: 0,
        village: '$_id',
        totalScreenings: 1,
        highRiskCount: 1,
        riskPercentage: {
          $round: [
            {
              $multiply: [
                { $cond: [{ $eq: ['$totalScreenings', 0] }, 0, { $divide: ['$highRiskCount', '$totalScreenings'] }] },
                100,
              ],
            },
            1,
          ],
        },
      },
    },
    { $sort: { highRiskCount: -1 } },
  ]);

  res.status(200).json({ success: true, data: locations });
});

module.exports = { getOverview, getTrends, getRiskDistribution, getLocations };
