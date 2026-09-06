'use strict';

const mongoose = require('mongoose');

const { Schema } = mongoose;

const screeningSchema = new Schema(
  {
    patientId: {
      type: Schema.Types.ObjectId,
      ref: 'Patient',
      required: true,
      index: true,
    },
    agentId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    screeningDate: {
      type: Date,
      default: Date.now,
      index: true,
    },
    painLevel: {
      type: Number,
      required: true,
      min: 0,
      max: 10,
    },
    stiffnessDuration: {
      type: String, // e.g. "30 minutes"
    },
    swelling: {
      type: Boolean,
      default: false,
    },
    pastInjury: {
      type: String, // free-text description or empty
    },
    gaitRawData: {
      type: Schema.Types.Mixed, // raw sensor feature array, stored as-is
    },
    riskLevel: {
      type: String,
      enum: ['low', 'medium', 'high'],
      required: true,
      index: true,
    },
    confidence: {
      type: Number,
      min: 0,
      max: 1,
    },
    contributingFactors: {
      type: [String],
      default: [],
    },
    aiReasoning: {
      type: String,
    },
    doctorRecommendations: {
      type: String,
    },
    source: {
      // 'ml_model' | 'fallback_rules' - which prediction path produced this result
      type: String,
      enum: ['ml_model', 'fallback_rules'],
    },
    synced: {
      type: Boolean,
      default: true, // false for offline-queued records synced later
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

screeningSchema.index({ patientId: 1, screeningDate: -1 });
screeningSchema.index({ riskLevel: 1, createdAt: -1 });

module.exports = mongoose.model('Screening', screeningSchema);
