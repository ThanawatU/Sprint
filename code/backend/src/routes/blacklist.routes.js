const express = require('express');
const blacklistController = require('../controllers/blacklist.controller');
const validate = require('../middlewares/validate');
<<<<<<< HEAD
const { protect, requireAdmin} = require('../middlewares/auth');
=======
const { protect } = require('../middlewares/auth');
const requireAdmin = require('../middlewares/requireAdmin');
>>>>>>> 86d4c30 (Added blacklist.controller, admin.blacklist.routes and blacklist.routes)

const {
  createBlacklistSchema,
  addEvidenceSchema
} = require('../validations/blacklist.validation');

const router = express.Router();

// POST /api/blacklists
router.post(
  '/',
  protect,
  requireAdmin,
  validate({ body: createBlacklistSchema }),
  blacklistController.createBlacklist
);

// GET /api/blacklists
router.get(
    '/',
    protect,
    requireAdmin,
    blacklistController.getBlacklists
)

// GET /api/blacklists/:id
router.get(
    '/:id',
    protect,
    requireAdmin,
    blacklistController.getBlacklists
)

// PATCH /api/blacklists/:id/lift
router.patch(
    '/:id/lift',
    protect,
    requireAdmin,
    blacklistController.liftBlacklist
)

// POST /api/blacklists/:id/evidence
router.post(
    '/:id/evidence',
    protect,
    requireAdmin,
    validate({ body: addEvidenceSchema }),
    blacklistController.addEvidence
<<<<<<< HEAD
)

module.exports = router;
=======
)
>>>>>>> 86d4c30 (Added blacklist.controller, admin.blacklist.routes and blacklist.routes)
