const { z } = require('zod');

/**
 * Generic validation middleware factory.
 * Usage: validate(schema) → Express middleware that validates req.body
 */
const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    const errors = result.error.errors.map((e) => ({
      field: e.path.join('.'),
      message: e.message,
    }));
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: errors,
    });
  }
  req.validatedBody = result.data;
  next();
};

// ─── Auth Schemas ──────────────────────────────────────────────────────────

const registerSchema = z.object({
  fullName: z.string().min(2, 'Name must be at least 2 characters').max(100),
  phoneNumber: z
    .string()
    .regex(/^[6-9]\d{9}$/, 'Invalid Indian phone number (10 digits starting with 6-9)'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.enum(['agent', 'user']).default('agent'),
  healthCenterId: z.string().optional(),
  location: z.string().optional(),
});

const loginSchema = z.object({
  phoneNumber: z.string().min(10, 'Phone number required'),
  password: z.string().min(1, 'Password required'),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token required'),
});

// ─── Patient Schemas ────────────────────────────────────────────────────────

const patientSchema = z.object({
  fullName: z.string().min(2).max(100),
  age: z.number().int().min(1).max(120),
  gender: z.enum(['male', 'female', 'other']),
  contact: z.string().optional(),
  village: z.string().optional(),
  address: z.string().optional(),
  occupation: z.string().optional(),
  height: z.number().optional(), // cm
  weight: z.number().optional(), // kg
});

// ─── Screening Schemas ─────────────────────────────────────────────────────

const screeningSchema = z.object({
  patientId: z.string().min(1, 'Patient ID required'),
  painLevel: z.number().int().min(0).max(10),
  stiffnessDuration: z.string().optional(), // "none", "<30", "30-60", ">60"
  swelling: z.boolean().default(false),
  pastInjury: z.boolean().default(false),
  pastInjuryDetail: z.string().optional(),
  gaitData: z.string().optional(), // JSON string of sensor readings
});

// ─── Sync Schemas ──────────────────────────────────────────────────────────

const syncBatchSchema = z.object({
  items: z.array(
    z.object({
      entityType: z.enum(['patients', 'screenings']),
      action: z.enum(['insert', 'update', 'delete']),
      localId: z.number().int(),
      data: z.record(z.unknown()),
    })
  ).min(1),
});

module.exports = {
  validate,
  registerSchema,
  loginSchema,
  refreshSchema,
  patientSchema,
  screeningSchema,
  syncBatchSchema,
};
