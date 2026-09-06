"use strict";

const express = require("express");
const { z } = require("zod");
const syncController = require("../controllers/syncController");
const validate = require("../middleware/validate");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.use(authMiddleware);

const syncItemSchema = z.object({
  type: z.enum(["patient", "screening"]),
  localId: z.string().min(1),
  action: z.enum(["create", "update"]),
  data: z.record(z.any()),
});

const batchSyncSchema = z.object({
  items: z.array(syncItemSchema).min(1).max(200),
});

/**
 * @swagger
 * tags:
 *   name: Sync
 *   description: Offline-first data reconciliation for the mobile app
 */

/**
 * @swagger
 * /sync/batch:
 *   post:
 *     summary: Push a batch of offline-queued patient/screening records
 *     tags: [Sync]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Per-item sync results (partial failures allowed)
 */
router.post("/batch", validate(batchSyncSchema), syncController.batchSync);

/**
 * @swagger
 * /sync/status:
 *   get:
 *     summary: Get server time and last-modified timestamps for this agent's data
 *     tags: [Sync]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Sync status
 */
router.get("/status", syncController.getSyncStatus);

module.exports = router;
