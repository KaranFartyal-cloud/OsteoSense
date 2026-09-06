'use strict';

/**
 * Wraps an async Express route handler / middleware so that any rejected
 * promise (thrown error) is forwarded to next(), landing in errorHandler
 * instead of crashing the process or hanging the request.
 *
 * Usage: router.post('/', asyncHandler(async (req, res) => { ... }))
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
