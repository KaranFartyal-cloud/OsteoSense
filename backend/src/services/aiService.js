const axios = require('axios');
const logger = require('../utils/logger');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';
const AI_TIMEOUT_MS = 5000; // 5 second timeout as specified

/**
 * Rule-based OA risk calculation — pure JS fallback when AI service is unavailable.
 * Same algorithm mirrored in the Python service and the on-device TFLite.
 * This ensures the app NEVER fails even if the AI service is down.
 *
 * @param {Object} data - Screening input data
 * @returns {Object} - { riskLevel, confidence, contributingFactors, reasoning }
 */
const ruleBasedFallback = (data) => {
  const { painLevel, stiffnessDuration, swelling, pastInjury, gaitData } = data;

  let riskScore = 0;
  const factors = [];

  // Pain level contribution (max 3 points)
  if (painLevel >= 7) {
    riskScore += 3;
    factors.push('Severe pain level (≥7/10)');
  } else if (painLevel >= 4) {
    riskScore += 2;
    factors.push('Moderate pain level (4–6/10)');
  } else if (painLevel >= 2) {
    riskScore += 1;
    factors.push('Mild pain level (2–3/10)');
  }

  // Stiffness duration contribution (max 2 points)
  if (stiffnessDuration === '>60') {
    riskScore += 2;
    factors.push('Prolonged morning stiffness (>60 minutes)');
  } else if (stiffnessDuration === '30-60') {
    riskScore += 1;
    factors.push('Moderate morning stiffness (30–60 minutes)');
  }

  // Swelling (1 point)
  if (swelling) {
    riskScore += 2;
    factors.push('Joint swelling observed');
  }

  // Past injury (1 point)
  if (pastInjury) {
    riskScore += 1;
    factors.push('History of joint injury');
  }

  // Gait irregularity from parsed data (max 2 points)
  if (gaitData) {
    try {
      const parsed = typeof gaitData === 'string' ? JSON.parse(gaitData) : gaitData;
      const variance = parsed.variance || 0;
      if (variance > 0.7) {
        riskScore += 2;
        factors.push('Significant gait irregularity detected');
      } else if (variance > 0.4) {
        riskScore += 1;
        factors.push('Mild gait irregularity detected');
      }
    } catch {
      // Non-parseable gait data — skip
    }
  }

  // Convert score to risk level (max possible: 10)
  let riskLevel;
  let confidence;
  if (riskScore >= 6) {
    riskLevel = 'high';
    confidence = Math.min(0.65 + (riskScore - 6) * 0.05, 0.92);
  } else if (riskScore >= 3) {
    riskLevel = 'medium';
    confidence = Math.min(0.55 + (riskScore - 3) * 0.04, 0.72);
  } else {
    riskLevel = 'low';
    confidence = Math.min(0.70 + (3 - riskScore) * 0.06, 0.88);
  }

  const reasoning =
    riskLevel === 'high'
      ? 'Multiple significant risk factors detected. Clinical evaluation recommended urgently.'
      : riskLevel === 'medium'
      ? 'Moderate risk factors present. Lifestyle modifications and follow-up recommended.'
      : 'Risk factors are minimal. Encourage preventive measures and regular monitoring.';

  return {
    riskLevel,
    confidence: parseFloat(confidence.toFixed(3)),
    contributingFactors: factors.length > 0 ? factors : ['No significant risk factors detected'],
    reasoning,
    resultSource: 'rule_based_fallback',
  };
};

/**
 * Call the Python FastAPI AI microservice.
 * Falls back to rule-based calculation on any error (timeout, unreachable, etc.).
 *
 * @param {Object} screeningData - { painLevel, stiffnessDuration, swelling, pastInjury, gaitData }
 * @returns {Object} - AI result with riskLevel, confidence, contributingFactors, reasoning
 */
const predictRisk = async (screeningData) => {
  try {
    logger.info(`Calling AI service at ${AI_SERVICE_URL}/predict`);

    const response = await axios.post(
      `${AI_SERVICE_URL}/predict`,
      {
        pain_level: screeningData.painLevel,
        stiffness_duration: screeningData.stiffnessDuration || 'none',
        swelling: screeningData.swelling || false,
        past_injury: screeningData.pastInjury || false,
        gait_data: screeningData.gaitData || null,
      },
      {
        timeout: AI_TIMEOUT_MS,
        headers: { 'Content-Type': 'application/json' },
      }
    );

    const result = response.data;
    logger.info(`AI service responded: riskLevel=${result.risk_level}, confidence=${result.confidence}`);

    return {
      riskLevel: result.risk_level,
      confidence: result.confidence,
      contributingFactors: result.contributing_factors || [],
      reasoning: result.reasoning || '',
      resultSource: 'ai_service',
    };
  } catch (error) {
    if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT' || error.code === 'ENOTFOUND') {
      logger.warn(`AI service unavailable (${error.code}). Using rule-based fallback.`);
    } else {
      logger.warn(`AI service error: ${error.message}. Using rule-based fallback.`);
    }

    // CRITICAL: Never let AI service failure break the app
    return ruleBasedFallback(screeningData);
  }
};

module.exports = { predictRisk, ruleBasedFallback };
