'use strict';

const jwt = require('jsonwebtoken');
const env = require('../config/env');

/**
 * Signs a short-lived access token. `sub` is the user's Mongo _id.
 */
function signAccessToken(user) {
  return jwt.sign({ sub: user._id.toString(), role: user.role }, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_EXPIRY,
  });
}

/**
 * Signs a longer-lived refresh token, stored server-side in
 * user.refreshTokens so it can be individually revoked (logout)
 * or invalidated in bulk.
 */
function signRefreshToken(user) {
  return jwt.sign({ sub: user._id.toString() }, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_EXPIRY,
  });
}

function verifyAccessToken(token) {
  return jwt.verify(token, env.JWT_ACCESS_SECRET);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, env.JWT_REFRESH_SECRET);
}

/**
 * Generates a fresh access+refresh pair, pushes the refresh token onto
 * the user's refreshTokens array, and caps the array at
 * MAX_REFRESH_TOKENS_PER_USER (evicting the oldest) to support a bounded
 * number of concurrent device sessions per agent.
 *
 * Does NOT save the user document -- caller is responsible for `await user.save()`
 * so it can be combined with other mutations in a single write.
 */
function issueTokenPair(user) {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  user.refreshTokens.push(refreshToken);
  if (user.refreshTokens.length > env.MAX_REFRESH_TOKENS_PER_USER) {
    user.refreshTokens = user.refreshTokens.slice(
      user.refreshTokens.length - env.MAX_REFRESH_TOKENS_PER_USER
    );
  }

  return { accessToken, refreshToken };
}

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  issueTokenPair,
};
