const { prisma } = require("../utils/prisma"); // adjust path if needed
const { getNow } = require("../utils/timestamp");
const { computeIntegrityHash } = require("../utils/integrityHash");

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
    const createdAt = getNow();
    
    const record = await prisma.auditLog.create({
      data: {
        userId,
        role,
        action,
        entity,
        entityId,
        ipAddress: req?.ip,
        userAgent: req?.headers["user-agent"],
        metadata,
        createdAt
      }
    });

    const integrityHash = computeIntegrityHash(record);

    await prisma.auditLog.update({
      where: { id: record.id },
      data: { integrityHash }
    });
  } catch (error) {
    console.error("Audit log failed:", error);
  }
};

module.exports = { logAudit };
