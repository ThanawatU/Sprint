const prisma = require("../utils/prisma");

const logAudit = async ({
  userId,
  role,
  action,
  entity,
  entityId,
  req,
  metadata
}) => {
  try {
    await prisma.auditLog.create({
      data: {
        userId,
        role,
        action,
        entity,
        entityId,
        ipAddress: req?.ip,
        userAgent: req?.headers["user-agent"],
        metadata
      }
    });
  } catch (error) {
    console.error("Audit log failed:", error);
  }
};

module.exports = { logAudit };
