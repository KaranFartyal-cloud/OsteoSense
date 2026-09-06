const mongoose = require('mongoose');

const screeningSchema = new mongoose.Schema(
  {
    agentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Patient',
      required: true,
      index: true,
    },

    // ─── Symptom Questionnaire Data ───────────────────────────────────────
    painLevel: {
      type: Number,
      min: 0,
      max: 10,
      required: true,
    },
    stiffnessDuration: {
      type: String,
      enum: ['none', '<30', '30-60', '>60'],
      default: 'none',
    },
    swelling: {
      type: Boolean,
      default: false,
    },
    pastInjury: {
      type: Boolean,
      default: false,
    },
    pastInjuryDetail: {
      type: String,
      trim: true,
    },

    // ─── Gait Test Data ───────────────────────────────────────────────────
    gaitData: {
      type: String, // JSON string of raw sensor readings
    },

    // ─── AI Result ────────────────────────────────────────────────────────
    riskLevel: {
      type: String,
      enum: ['low', 'medium', 'high'],
      required: true,
      index: true,
    },
    confidence: {
      type: Number, // 0.0 – 1.0
      min: 0,
      max: 1,
    },
    contributingFactors: {
      type: [String], // List of factor labels
      default: [],
    },
    reasoning: {
      type: String, // Textual explanation from AI
    },

    // ─── Provenance ───────────────────────────────────────────────────────
    // Which system computed this result?
    resultSource: {
      type: String,
      enum: ['ai_service', 'rule_based_fallback', 'on_device'],
      default: 'ai_service',
    },
    // Original local device ID (for sync deduplication)
    localId: {
      type: Number,
    },
  },
  {
    timestamps: true, // createdAt = screeningDate
  }
);

screeningSchema.index({ agentId: 1, createdAt: -1 });
screeningSchema.index({ patientId: 1, createdAt: -1 });
screeningSchema.index({ agentId: 1, riskLevel: 1 });

module.exports = mongoose.model('Screening', screeningSchema);
