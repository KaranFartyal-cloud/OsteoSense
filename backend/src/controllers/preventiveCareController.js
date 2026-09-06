'use strict';

const PreventiveCare = require('../models/PreventiveCare');
const asyncHandler = require('../utils/asyncHandler');

/**
 * GET /api/v1/preventive-care?category=&lang=
 * Public endpoint, no auth required. Small dataset -- no pagination needed.
 */
const listPreventiveCare = asyncHandler(async (req, res) => {
  const { category, lang } = req.query;

  const filter = { language: lang || 'en' };
  if (category) filter.category = category;

  const items = await PreventiveCare.find(filter).sort({ category: 1, createdAt: 1 });

  res.status(200).json({ success: true, data: items });
});

module.exports = { listPreventiveCare };
