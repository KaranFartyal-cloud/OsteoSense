"use strict";

const mongoose = require("mongoose");
const ApiError = require("../utils/ApiError");
const logger = require("../utils/logger");
const env = require("../config/env");

/**
 * Centralized error handler. MUST be the last middleware registered in app.js.
 * Normalizes all thrown errors (ApiError, Mongoose errors, JWT errors, or
 * unexpected bugs) into the standard { success: false, message, errors? } shape.
 */
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, _next) {
  let statusCode = 500;
  let message = "Internal server error";
  let errors = [];

  if (err instanceof ApiError) {
    statusCode = err.statusCode;
    message = err.message;
    errors = err.errors || [];
  } else if (err instanceof mongoose.Error.ValidationError) {
    statusCode = 400;
    message = "Validation failed";
    errors = Object.values(err.errors).map((e) => ({
      field: e.path,
      message: e.message,
    }));
  } else if (err instanceof mongoose.Error.CastError) {
    statusCode = 400;
    message = `Invalid value for field '${err.path}'`;
    errors = [{ field: err.path, message: `Invalid ${err.kind}` }];
  } else if (err.code === 11000) {
    // Mongo duplicate key error
    statusCode = 409;
    const field = Object.keys(
      err.keyPattern || err.keyValue || { field: 1 },
    )[0];
    message = `A record with this ${field} already exists`;
    errors = [{ field, message: "Duplicate value" }];
  } else if (
    err.name === "JsonWebTokenError" ||
    err.name === "TokenExpiredError"
  ) {
    statusCode = 401;
    message = "Invalid or expired token";
  }

  // Always log the full error server-side, regardless of what's sent to the client.
  // Never log req.body directly here -- it may contain passwords/tokens.
  logger.error(message, {
    statusCode,
    path: req.originalUrl,
    method: req.method,
    stack: err.stack,
  });

  const response = { success: false, message };
  if (errors.length) response.errors = errors;
  if (!env.isProduction && statusCode === 500) response.stack = err.stack;

  res.status(statusCode).json(response);
}

module.exports = errorHandler;
