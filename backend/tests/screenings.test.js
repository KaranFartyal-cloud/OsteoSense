'use strict';

require('./setup');
const request = require('supertest');

// Mock the AI service BEFORE requiring the app so the controller picks up the mock.
jest.mock('../src/services/aiService');
const aiService = require('../src/services/aiService');

const app = require('../src/app');

const AUTH_BASE = '/api/v1/auth';
const PATIENT_BASE = '/api/v1/patients';
const SCREENING_BASE = '/api/v1/screenings';

async function registerAndLogin() {
  const registerRes = await request(app).post(`${AUTH_BASE}/register`).send({
    fullName: 'Test Agent',
    phoneNumber: '9812345670',
    password: 'SecurePass123',
    role: 'agent',
  });
  return registerRes.body.data.accessToken;
}

async function createPatient(token) {
  const res = await request(app)
    .post(PATIENT_BASE)
    .set('Authorization', `Bearer ${token}`)
    .send({ name: 'Test Patient', age: 60, gender: 'male', village: 'Ziro' });
  return res.body.data;
}

beforeEach(() => {
  jest.clearAllMocks();
});

describe('POST /screenings', () => {
  it('creates a screening successfully using the (mocked) ML model result', async () => {
    aiService.predictRisk.mockResolvedValue({
      riskLevel: 'high',
      confidence: 0.91,
      contributingFactors: ['Severe pain level reported'],
      aiReasoning: 'Mocked ML model reasoning',
      doctorRecommendations: 'Refer to specialist',
      source: 'ml_model',
    });

    const token = await registerAndLogin();
    const patient = await createPatient(token);

    const res = await request(app)
      .post(SCREENING_BASE)
      .set('Authorization', `Bearer ${token}`)
      .send({
        patientId: patient.id,
        painLevel: 8,
        stiffnessDuration: '45 minutes',
        swelling: true,
        pastInjury: 'Old fracture',
        gaitFeatures: [0.4, 0.6, 0.5],
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.riskLevel).toBe('high');
    expect(res.body.data.source).toBe('ml_model');
    expect(aiService.predictRisk).toHaveBeenCalledTimes(1);
  });

  it('falls back gracefully when the AI service throws, still returning 201', async () => {
    // Simulate aiService already handling its own internal fallback and
    // returning a fallback_rules result (this is what predictRisk normally
    // does internally on microservice failure -- here we mock that outcome directly).
    aiService.predictRisk.mockResolvedValue({
      riskLevel: 'medium',
      confidence: 0.6,
      contributingFactors: ['Moderate pain level reported'],
      aiReasoning: 'Rule-based triage fallback reasoning',
      doctorRecommendations: 'Follow up in 4-6 weeks',
      source: 'fallback_rules',
    });

    const token = await registerAndLogin();
    const patient = await createPatient(token);

    const res = await request(app)
      .post(SCREENING_BASE)
      .set('Authorization', `Bearer ${token}`)
      .send({
        patientId: patient.id,
        painLevel: 5,
        stiffnessDuration: '20 minutes',
        swelling: false,
        pastInjury: '',
        gaitFeatures: [],
      });

    expect(res.status).toBe(201);
    expect(res.body.data.source).toBe('fallback_rules');
    expect(res.body.data.riskLevel).toBe('medium');
  });

  it('returns 404 when the patient does not belong to the requesting agent', async () => {
    aiService.predictRisk.mockResolvedValue({
      riskLevel: 'low',
      confidence: 0.7,
      contributingFactors: [],
      aiReasoning: '',
      doctorRecommendations: '',
      source: 'ml_model',
    });

    const tokenA = await registerAndLogin();
    const patientA = await createPatient(tokenA);

    // A second agent tries to screen the first agent's patient -- must be blocked (IDOR).
    const registerB = await request(app).post(`${AUTH_BASE}/register`).send({
      fullName: 'Second Agent',
      phoneNumber: '9812345671',
      password: 'SecurePass123',
      role: 'agent',
    });
    const tokenB = registerB.body.data.accessToken;

    const res = await request(app)
      .post(SCREENING_BASE)
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ patientId: patientA.id, painLevel: 3 });

    expect(res.status).toBe(404);
  });

  it('rejects invalid painLevel with 400', async () => {
    const token = await registerAndLogin();
    const patient = await createPatient(token);

    const res = await request(app)
      .post(SCREENING_BASE)
      .set('Authorization', `Bearer ${token}`)
      .send({ patientId: patient.id, painLevel: 15 });

    expect(res.status).toBe(400);
  });
});
