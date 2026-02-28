const express = require('express');
const integrityController = require('../controllers/integrity.controller');
const validate = require('../middlewares/validate');
const { protect, requireAdmin } = require('../middlewares/auth');

const {
  verifyLogParamSchema,
  verifyBatchQuerySchema
} = require('../validations/integrity.validation');

const router = express.Router();

// GET /api/integrity/verify — ตรวจสอบ integrity แบบ batch
router.get(
  '/verify',
  protect,
  requireAdmin,
  validate({ query: verifyBatchQuerySchema }),
  integrityController.verifyBatchLogs
);

// GET /api/integrity/verify/:id — ตรวจสอบ integrity record เดียว
router.get(
  '/verify/:id',
  protect,
  requireAdmin,
  validate({ params: verifyLogParamSchema }),
  integrityController.verifySingleLog
);

module.exports = router;
