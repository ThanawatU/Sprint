const express = require('express');
const reportController = require('../controllers/report.controller');
const validate = require('../middlewares/validate');
const { protect, requireAdmin } = require('../middlewares/auth');

const {
  createReportSchema,
  updateReportStatusSchema,
  addReportEvidenceSchema
} = require('../validations/report.validation');

const router = express.Router();

// --- User Routes ---
// POST /api/reports
router.post(
  '/', 
  protect, 
  validate({ body: createReportSchema }), 
  reportController.createReport
);

// GET /api/reports/my
router.get(
  '/my',
  protect,
  reportController.getMyReports);

// GET /api/reports/against-me
router.get(
  '/against-me', 
  protect, 
  reportController.getReportsAgainstMe
);

// GET /api/reports/:id
router.get(
  '/:id', 
  protect, 
  reportController.getReportById
);

// POST /api/reports/:id/evidence
router.post(
  '/:id/evidence', 
  protect, 
  validate({ body: addReportEvidenceSchema }), 
  reportController.addEvidence
);

// --- Admin Routes ---
// GET /api/reports/admin/all
router.get(
  '/admin/all', 
  protect, 
  requireAdmin, 
  reportController.getReports
);

// PATCH /api/reports/admin/:id/status
router.patch(
  '/admin/:id/status', 
  protect, 
  requireAdmin, 
  validate({ body: updateReportStatusSchema }), 
  reportController.updateReportStatus
);

module.exports = router;