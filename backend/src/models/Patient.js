'use strict';

const mongoose = require('mongoose');

const { Schema } = mongoose;

const CONTACT_REGEX = /^[6-9]\d{9}$/;

const patientSchema = new Schema(
  {
    agentId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Patient name is required'],
      trim: true,
    },
    age: {
      type: Number,
      required: [true, 'Age is required'],
      min: [0, 'Age cannot be negative'],
      max: [150, 'Age is not realistic'],
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      required: true,
    },
    contact: {
      type: String,
      trim: true,
      validate: {
        validator: (v) => !v || CONTACT_REGEX.test(v),
        message: (props) => `${props.value} is not a valid 10-digit contact number`,
      },
    },
    village: {
      type: String,
      trim: true,
      index: true,
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
      type: Number, // cm
    },
    weight: {
      type: Number, // kg
    },
    isDeleted: {
      type: Boolean,
      default: false,
      index: true,
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

// Efficient patient list queries: scoped by agent, excluding soft-deleted, newest first.
patientSchema.index({ agentId: 1, isDeleted: 1, createdAt: -1 });

// Full-text search across name and village.
patientSchema.index({ name: 'text', village: 'text' });

module.exports = mongoose.model('Patient', patientSchema);
