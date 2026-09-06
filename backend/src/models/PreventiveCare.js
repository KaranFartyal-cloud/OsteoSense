'use strict';

const mongoose = require('mongoose');

const { Schema } = mongoose;

const preventiveCareSchema = new Schema(
  {
    category: {
      type: String,
      enum: ['exercises', 'diet', 'lifestyle'],
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    content: {
      type: String,
      required: true,
    },
    imageUrl: {
      type: String,
    },
    language: {
      type: String,
      enum: ['en', 'hi'],
      default: 'en',
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

module.exports = mongoose.model('PreventiveCare', preventiveCareSchema);
