'use strict';

const ApiError = require('../utils/ApiError');

/**
 * Higher-order function returning middleware that validates req[source]
 * against a Zod schema. On success, req[source] is replaced with the
 * parsed (and coerced/defaulted) value. On failure, a 400 ApiError with
 * field-level messages is forwarded to the error handler.
 *
 * @param {import('zod').ZodSchema} schema
 * @param {'body'|'query'|'params'} [source='body']
 */
function validate(schema, source = 'body') {
  return (req, res, next) => {
    const result = schema.safeParse(req[source]);

    if (!result.success) {
      const errors = result.error.issues.map((issue) => ({
        field: issue.path.join('.') || source,
        message: issue.message,
      }));
      return next(ApiError.badRequest('Validation failed', errors));
    }

    req[source] = result.data;
    return next();
  };
}

module.exports = validate;
