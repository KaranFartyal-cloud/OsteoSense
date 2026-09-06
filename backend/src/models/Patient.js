const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema(
  {
    agentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true, // ⚠️ CRITICAL: all queries MUST scope by agentId to prevent IDOR
    },
    fullName: {
      type: String,
      required: [true, 'Patient name is required'],
      trim: true,
      maxlength: [100, 'Name cannot exceed 100 characters'],
    },
    age: {
      type: Number,
      required: [true, 'Age is required'],
      min: [1, 'Age must be at least 1'],
      max: [120, 'Age cannot exceed 120'],
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      required: [true, 'Gender is required'],
    },
    contact: {
      type: String,
      trim: true,
    },
    village: {
      type: String,
      trim: true,
      index: true, // For village-wise analytics
    },
    address: {
      type: String,
      trim: true,
    },
    occupation: {
      type: String,
      trim: true,
    },
    height: {
      type: Number, // centimeters
    },
    weight: {
      type: Number, // kilograms
    },
    // Latest risk level — denormalized for quick list display
    latestRiskLevel: {
      type: String,
      enum: ['low', 'medium', 'high', null],
      default: null,
      index: true,
    },
    // Whether this record was synced from local device (offline-created)
    syncedFromLocal: {
      type: Boolean,
      default: false,
    },
    // Original local device ID (for sync deduplication)
    localId: {
      type: Number,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for agent-scoped searches
patientSchema.index({ agentId: 1, fullName: 'text', village: 'text' });
patientSchema.index({ agentId: 1, latestRiskLevel: 1 });
patientSchema.index({ agentId: 1, createdAt: -1 });

module.exports = mongoose.model('Patient', patientSchema);
