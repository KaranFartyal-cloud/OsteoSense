'use strict';

/**
 * Catches any request that didn't match a route and forwards a
 * consistent 404 JSON response, rather than Express's default HTML page.
 */
function notFound(req, res) {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
}

module.exports = notFound;
