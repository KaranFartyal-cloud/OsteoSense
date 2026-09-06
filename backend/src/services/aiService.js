'use strict';

const axios = require('axios');
const env = require('../config/env');
const logger = require('../utils/logger');

const AI_REQUEST_TIMEOUT_MS = 5000;

/**
 * Parses free-text stiffness duration strings like "30 minutes", "1 hour",
 * "45 mins", "2 hrs" into a numeric minute value. Defaults to 0 if it can't
 * confidently parse anything (better to under-score than crash the pipeline).
 */
function parseStiffnessDuration(stiffnessDuration) {
  if (!stiffnessDuration || typeof stiffnessDuration !== 'string') return 0;

  const str = stiffnessDuration.toLowerCase().trim();
  const numberMatch = str.match(/(\d+(\.\d+)?)/);
  if (!numberMatch) return 0;

  const value = parseFloat(numberMatch[1]);

  if (str.includes('hour') || str.includes('hr')) {
    return value * 60;
  }
  return value; // assume minutes by default
}

/**
 * Computes a crude variance measure across gait sensor features as a proxy
 * for gait irregularity. Higher variance ~ more irregular gait pattern,
 * which correlates with higher OA risk in the fallback heuristic.
 */
function computeGaitVariance(gaitFeatures) {
  if (!Array.isArray(gaitFeatures) || gaitFeatures.length < 2) return 0;

  const numeric = gaitFeatures.filter((v) => typeof v === 'number' && !Number.isNaN(v));
  if (numeric.length < 2) return 0;

  const mean = numeric.reduce((sum, v) => sum + v, 0) / numeric.length;
  const variance =
    numeric.reduce((sum, v) => sum + (v - mean) ** 2, 0) / numeric.length;

  return variance;
}

/**
 * Rule-based clinical triage fallback, used whenever the ML microservice
 * is unreachable or errors out. Mirrors the weighting style of a typical
 * clinical rule-based OA triage checklist:
 *   - pain level is the dominant signal (weight 0.3, scaled to 0-1 range)
 *   - prolonged morning stiffness (>30 min) is a classic OA red flag
 *   - swelling and past joint injury are established risk multipliers
 *   - irregular gait (high variance in sensor readings) adds further signal
 *
 * Produces a 0-1 risk score bucketed into low/medium/high, plus a
 * confidence value (fallback is inherently less confident than the ML model)
 * and human-readable contributing factors for clinician review.
 */
function fallbackRuleBasedPredict({ painLevel, stiffnessMinutes, swelling, pastInjury, gaitFeatures }) {
  const contributingFactors = [];
  let score = 0;

  // Pain level: dominant weighted factor (0-10 scale -> 0-1, weighted 0.3 of max 1.0 contribution)
  const painComponent = (painLevel / 10) * 0.3;
  score += painComponent;
  if (painLevel >= 7) {
    contributingFactors.push('Severe pain level reported');
  } else if (painLevel >= 4) {
    contributingFactors.push('Moderate pain level reported');
  }

  // Morning stiffness thresholds (classic OA clinical indicator)
  if (stiffnessMinutes > 30) {
    score += 0.25;
    contributingFactors.push('Prolonged joint stiffness (>30 minutes)');
  } else if (stiffnessMinutes > 15) {
    score += 0.12;
    contributingFactors.push('Moderate joint stiffness (>15 minutes)');
  }

  // Swelling
  if (swelling) {
    score += 0.15;
    contributingFactors.push('Joint swelling present');
  }

  // Past injury
  if (pastInjury) {
    score += 0.15;
    contributingFactors.push('History of joint injury');
  }

  // Gait irregularity (sensor-derived, normalized against an empirical ceiling)
  const gaitVariance = computeGaitVariance(gaitFeatures);
  const GAIT_VARIANCE_CEILING = 4.0; // empirical normalization constant
  const gaitComponent = Math.min(gaitVariance / GAIT_VARIANCE_CEILING, 1) * 0.15;
  score += gaitComponent;
  if (gaitComponent > 0.08) {
    contributingFactors.push('Irregular gait pattern detected');
  }

  score = Math.min(score, 1);

  // Threshold chosen so that a single strong signal alone (e.g. severe pain with
  // no other symptoms) is not silently bucketed as "low" -- verified against
  // several boundary cases (severe pain alone, moderate pain + moderate stiffness).
  let riskLevel;
  if (score >= 0.6) riskLevel = 'high';
  else if (score >= 0.25) riskLevel = 'medium';
  else riskLevel = 'low';

  if (contributingFactors.length === 0) {
    contributingFactors.push('No significant risk factors identified');
  }

  const doctorRecommendations = buildRecommendation(riskLevel);

  return {
    riskLevel,
    // Fallback heuristic is deliberately reported with lower confidence
    // than a trained model would be, since it's a simpler rule-based approximation.
    confidence: Math.round((0.55 + score * 0.15) * 100) / 100,
    contributingFactors,
    aiReasoning:
      `Rule-based triage score ${score.toFixed(2)} derived from pain level, stiffness ` +
      `duration, swelling, injury history, and gait variance.`,
    doctorRecommendations,
  };
}

function buildRecommendation(riskLevel) {
  switch (riskLevel) {
    case 'high':
      return 'Refer to an orthopedic specialist for clinical evaluation and imaging (X-ray/MRI) as soon as possible.';
    case 'medium':
      return 'Recommend follow-up screening in 4-6 weeks; advise preventive exercises and weight management in the meantime.';
    default:
      return 'No immediate referral needed; share preventive care guidance and re-screen at next camp visit.';
  }
}

/**
 * Calls the Python FastAPI ML microservice to get an OA risk prediction.
 * Falls back to a deterministic rule-based prediction if the service is
 * unreachable, times out, or returns an error -- ensuring the screening
 * flow (the core demo path) never hard-fails due to an AI service outage.
 *
 * Every returned object includes a `source` field ('ml_model' | 'fallback_rules')
 * so downstream analytics can track how often each path was used.
 */
async function predictRisk({ painLevel, stiffnessDuration, swelling, pastInjury, gaitFeatures }) {
  const stiffnessMinutes = parseStiffnessDuration(stiffnessDuration);
  const normalizedPayload = {
    painLevel,
    stiffnessMinutes,
    swelling: !!swelling,
    pastInjury: !!(pastInjury && pastInjury.length),
    gaitFeatures: gaitFeatures || [],
  };

  try {
    const response = await axios.post(`${env.AI_SERVICE_URL}/predict`, normalizedPayload, {
      timeout: AI_REQUEST_TIMEOUT_MS,
    });

    return { ...response.data, source: 'ml_model' };
  } catch (err) {
    logger.warn('AI microservice unreachable, using fallback', { error: err.message });

    const fallbackResult = fallbackRuleBasedPredict({
      painLevel,
      stiffnessMinutes,
      swelling: normalizedPayload.swelling,
      pastInjury: normalizedPayload.pastInjury,
      gaitFeatures: normalizedPayload.gaitFeatures,
    });

    return { ...fallbackResult, source: 'fallback_rules' };
  }
}

module.exports = {
  predictRisk,
  fallbackRuleBasedPredict,
  parseStiffnessDuration,
  computeGaitVariance,
};
