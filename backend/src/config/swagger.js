"use strict";

const swaggerJsdoc = require("swagger-jsdoc");
const env = require("./env");

const options = {
  definition: {
    openapi: "3.0.3",
    info: {
      title: "JointSaathi API",
      version: "1.0.0",
      description:
        "AI-assisted Osteoarthritis (OA) risk screening backend for healthcare " +
        "workers conducting field screenings in rural health camps across the " +
        "North Eastern Region (NER) of India. Built for Smart India Hackathon " +
        "(MDoNER problem statement).",
      contact: {
        name: "JointSaathi Team",
      },
    },
    servers: [
      {
        url: `https://osteosense.onrender.com/api/v1`,
        description: "Local development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
      schemas: {
        ApiError: {
          type: "object",
          properties: {
            success: { type: "boolean", example: false },
            message: { type: "string", example: "Invalid credentials" },
            errors: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  field: { type: "string" },
                  message: { type: "string" },
                },
              },
            },
          },
        },
      },
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ["./src/routes/*.js"],
};

module.exports = swaggerJsdoc(options);
