const express = require('express');
const blacklistController = require('../controllers/blacklist.controller');
const validate = require('../middlewares/validate');
const { protect, requireAdmin} = require('../middlewares/auth');

const {
  createBlacklistSchema,
  addEvidenceSchema
} = require('../validations/blacklist.validation');

const router = express.Router();

// POST /api/blacklists
router.post(
  '/admin',
  protect,
  requireAdmin,
  validate({ body: createBlacklistSchema }),
  blacklistController.createBlacklist
);

// GET /api/blacklists
router.get(
    '/admin',
    protect,
    requireAdmin,
    blacklistController.getBlacklists
)

// GET /api/blacklists/:id/admin
router.get(
    '/admin/:id',
    protect,
    requireAdmin,
    blacklistController.getBlacklistById
)

// PATCH /api/blacklists/:id/lift
router.patch(
    '/admin/:id/lift',
    protect,
    requireAdmin,
    blacklistController.liftBlacklist
)

// POST /api/blacklists/:id/evidence
router.post(
    '/admin/:id/evidence',
    protect,
    requireAdmin,
    validate({ body: addEvidenceSchema }),
    blacklistController.addEvidence
)

// POST /api/blacklists/:id/edit
router.put(
  '/admin/:id/edit',
  protect,
  requireAdmin,
  blacklistController.updateBlacklist
);

module.exports = router;