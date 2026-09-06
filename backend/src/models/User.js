'use strict';

const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const { Schema } = mongoose;

const INDIAN_MOBILE_REGEX = /^[6-9]\d{9}$/;

const userSchema = new Schema(
  {
    fullName: {
      type: String,
      required: [true, 'Full name is required'],
      trim: true,
    },
    phoneNumber: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true,
      validate: {
        validator: (v) => INDIAN_MOBILE_REGEX.test(v),
        message: (props) => `${props.value} is not a valid 10-digit Indian mobile number`,
      },
    },
    passwordHash: {
      type: String,
      required: [true, 'Password is required'],
      select: false,
    },
    role: {
      type: String,
      enum: ['agent', 'user'],
      required: true,
      default: 'agent',
    },
    healthCenterId: {
      type: String,
      trim: true,
    },
    location: {
      type: String,
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    refreshTokens: {
      // Multiple device sessions supported; capped and pruned in tokenService.
      type: [String],
      default: [],
      select: false,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        delete ret.passwordHash;
        delete ret.refreshTokens;
        return ret;
      },
    },
  }
);

userSchema.index({ phoneNumber: 1 }, { unique: true });

userSchema.methods.comparePassword = async function comparePassword(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

module.exports = mongoose.model('User', userSchema);
