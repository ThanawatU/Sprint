<<<<<<< HEAD
const { prisma } = require("../utils/prisma"); // adjust path if needed
=======
const prisma = require("../utils/prisma");
>>>>>>> 7cab97d (Phakorn_2160: Implement system logging infrastructure for performance monitoring and error tracking)

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
