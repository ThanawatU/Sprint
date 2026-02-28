const integrityService = require("../services/integrity.service");
const { auditLog, getUserFromRequest } = require('../utils/auditLog');

exports.verifySingleLog = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await integrityService.verifySingleLog(id);

    await auditLog({
      ...getUserFromRequest(req),
      action: 'VERIFY_INTEGRITY',
      entity: 'AuditLog',
      entityId: id,
      req,
      metadata: { isValid: result.isValid }
    });

    res.json({
      message: "Integrity verification completed",
      data: result
    });
  } catch (error) {
    console.error("verifySingleLog error:", error);
    res.status(error.statusCode || 500).json({
      message: error.message || "Failed to verify audit log integrity"
    });
  }
};

exports.verifyBatchLogs = async (req, res) => {
  try {
    const { page, limit, startDate, endDate } = req.query;

    const result = await integrityService.verifyBatchLogs({
      page: Number(page) || 1,
      limit: Number(limit) || 50,
      startDate,
      endDate
    });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'VERIFY_INTEGRITY_BATCH',
      entity: 'AuditLog',
      entityId: null,
      req,
      metadata: {
        checked: result.summary.checked,
        valid: result.summary.valid,
        invalid: result.summary.invalid
      }
    });

    res.json({
      message: "Batch integrity verification completed",
      data: result
    });
  } catch (error) {
    console.error("verifyBatchLogs error:", error);
    res.status(error.statusCode || 500).json({
      message: error.message || "Failed to verify audit log integrity"
    });
  }
};
