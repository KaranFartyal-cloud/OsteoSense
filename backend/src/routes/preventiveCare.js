const express = require('express');
const router = express.Router();
const PreventiveCare = require('../models/PreventiveCare');
const { authenticate } = require('../middleware/auth');

router.use(authenticate);

/**
 * GET /api/v1/preventive-care
 * List all preventive care articles, grouped by category.
 * ?category=exercises|diet|lifestyle to filter
 */
router.get('/', async (req, res, next) => {
  try {
    const { category } = req.query;
    const filter = { isActive: true };
    if (category && ['exercises', 'diet', 'lifestyle'].includes(category)) {
      filter.category = category;
    }

    const articles = await PreventiveCare.find(filter)
      .sort({ category: 1, order: 1 })
      .select('-content'); // Exclude full content for list view

    // Group by category
    const grouped = {
      exercises: articles.filter((a) => a.category === 'exercises'),
      diet: articles.filter((a) => a.category === 'diet'),
      lifestyle: articles.filter((a) => a.category === 'lifestyle'),
    };

    res.json({ success: true, data: { articles, grouped } });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/preventive-care/:id
 * Get full article content.
 */
router.get('/:id', async (req, res, next) => {
  try {
    const article = await PreventiveCare.findOne({ _id: req.params.id, isActive: true });
    if (!article) {
      return res.status(404).json({ success: false, error: 'Article not found' });
    }
    res.json({ success: true, data: { article } });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
