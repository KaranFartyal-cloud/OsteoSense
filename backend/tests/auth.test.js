'use strict';

require('./setup');
const request = require('supertest');
const app = require('../src/app');

const BASE = '/api/v1/auth';

function validRegisterBody(overrides = {}) {
  return {
    fullName: 'Priya Sharma',
    phoneNumber: '9876543210',
    password: 'SecurePass123',
    role: 'agent',
    healthCenterId: 'PHC-KHONSA-01',
    location: 'Khonsa, Arunachal Pradesh',
    ...overrides,
  };
}

describe('POST /auth/register', () => {
  it('registers a new agent successfully', async () => {
    const res = await request(app).post(`${BASE}/register`).send(validRegisterBody());

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user).toBeDefined();
    expect(res.body.data.user.phoneNumber).toBe('9876543210');
    expect(res.body.data.user.passwordHash).toBeUndefined();
    expect(res.body.data.accessToken).toEqual(expect.any(String));
    expect(res.body.data.refreshToken).toEqual(expect.any(String));
  });

  it('rejects duplicate phone number registration with 409', async () => {
    await request(app).post(`${BASE}/register`).send(validRegisterBody());

    const res = await request(app).post(`${BASE}/register`).send(validRegisterBody());

    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
  });

  it('rejects invalid input (short password, bad phone number) with 400', async () => {
    const res = await request(app)
      .post(`${BASE}/register`)
      .send(validRegisterBody({ phoneNumber: '12345', password: 'short' }));

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(Array.isArray(res.body.errors)).toBe(true);
    expect(res.body.errors.length).toBeGreaterThan(0);
  });
});

describe('POST /auth/login', () => {
  beforeEach(async () => {
    await request(app).post(`${BASE}/register`).send(validRegisterBody());
  });

  it('logs in successfully with correct credentials', async () => {
    const res = await request(app)
      .post(`${BASE}/login`)
      .send({ phoneNumber: '9876543210', password: 'SecurePass123' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toEqual(expect.any(String));
    expect(res.body.data.refreshToken).toEqual(expect.any(String));
  });

  it('rejects login with wrong password using generic message', async () => {
    const res = await request(app)
      .post(`${BASE}/login`)
      .send({ phoneNumber: '9876543210', password: 'WrongPassword1' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Invalid credentials');
  });

  it('rejects login for a non-existent user with generic message', async () => {
    const res = await request(app)
      .post(`${BASE}/login`)
      .send({ phoneNumber: '9111111111', password: 'SecurePass123' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Invalid credentials');
  });
});

describe('GET /auth/me', () => {
  it('returns the authenticated user profile with a valid token', async () => {
    const registerRes = await request(app).post(`${BASE}/register`).send(validRegisterBody());
    const { accessToken } = registerRes.body.data;

    const res = await request(app).get(`${BASE}/me`).set('Authorization', `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.data.user.phoneNumber).toBe('9876543210');
  });

  it('rejects requests without a token', async () => {
    const res = await request(app).get(`${BASE}/me`);
    expect(res.status).toBe(401);
  });
});
