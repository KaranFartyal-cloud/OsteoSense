const { verifyAccessToken } = require('../utils/jwt');
const logger = require('../utils/logger');

/**
 * JWT authentication middleware.
 * Extracts Bearer token from Authorization header, verifies it,
 * and attaches the decoded user payload to req.user.
 */
const authenticate = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Access token required',
      });
    }

    const token = authHeader.substring(7);
    const decoded = verifyAccessToken(token);

    req.user = decoded; // { id, phoneNumber, role, iat, exp }
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: 'Token expired',
        code: 'TOKEN_EXPIRED',
      });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        code: 'TOKEN_INVALID',
      });
    }
    logger.error(`Auth middleware error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Authentication error',
    });
  }
};

/**
 * Role-based authorization middleware.
 * Usage: authorize('agent') or authorize('agent', 'admin')
 */
const authorize = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({
      success: false,
      error: 'Insufficient permissions',
    });
  }
  next();
};

module.exports = { authenticate, authorize };
