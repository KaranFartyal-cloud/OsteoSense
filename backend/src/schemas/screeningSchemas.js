'use strict';

const { z } = require('zod');

const objectIdRegex = /^[0-9a-fA-F]{24}$/;

const objectId = (fieldName) =>
  z
    .string({ required_error: `${fieldName} is required` })
    .regex(objectIdRegex, `${fieldName} must be a valid ObjectId`);

const createScreeningSchema = z.object({
  patientId: objectId('patientId'),
  painLevel: z.coerce
    .number({ required_error: 'painLevel is required' })
    .min(0, 'painLevel must be between 0 and 10')
    .max(10, 'painLevel must be between 0 and 10'),
  stiffnessDuration: z.string().trim().optional(),
  swelling: z.coerce.boolean().optional().default(false),
  pastInjury: z.string().trim().optional().default(''),
  gaitFeatures: z.array(z.number()).optional().default([]),
});

const listScreeningsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
  riskLevel: z.enum(['low', 'medium', 'high']).optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  patientId: z
    .string()
    .regex(objectIdRegex, 'patientId must be a valid ObjectId')
    .optional(),
});

const patientIdParamSchema = z.object({
  patientId: objectId('patientId'),
});

module.exports = {
  createScreeningSchema,
  listScreeningsQuerySchema,
  patientIdParamSchema,
};
