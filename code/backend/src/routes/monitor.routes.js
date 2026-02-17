const express = require("express");
const router = express.Router();
const { prisma } = require("../utils/prisma");

router.get("/logs", async (req, res) => {
  try {
    const { level = "ALL", type = "SystemLog" } = req.query;

    const modelMap = {
      AuditLog: prisma.auditLog,
      AccessLog: prisma.accessLog,
      SystemLog: prisma.systemLog,
    };

    const model = modelMap[type] || prisma.systemLog;

    const whereCondition =
      type === "SystemLog" && level !== "ALL" ? { level } : undefined;

    const logs = await model.findMany({
      where: whereCondition,
      orderBy: { createdAt: "desc" },
      take: 100,
    });

    const formattedLogs = logs.map((log) => {
      if (type === "AuditLog") {
        return {
          id: log.id,
          createdAt: log.createdAt,
          userId: log.userId,
          role: log.role,
          action: log.action,
          entity: log.entity,
          entityId: log.entityId,
          ipAddress: log.ipAddress,
        };
      }

      if (type === "AccessLog") {
        return {
          id: log.id,
          userId: log.userId,
          loginTime: log.loginTime,
          logoutTime: log.logoutTime,
          ipAddress: log.ipAddress,
          sessionId: log.sessionId,
          createdAt: log.createdAt,
        };
      }

      return {
        id: log.id,
        createdAt: log.createdAt,
        userId: log.userId,
        method: log.method,
        endpoint: log.path,
        statusCode: log.statusCode,
        responseTime: log.duration,
        level: log.level,
        ipAddress: log.ipAddress,
      };
    });

    res.json(formattedLogs);
  } catch (error) {
    console.error("Fetch logs error:", error);
    res.status(500).json({ message: "Failed to fetch logs" });
  }
});

router.get("/logs/summary", async (req, res) => {
  try {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const total = await prisma.systemLog.count();

    const errorCount = await prisma.systemLog.count({
      where: {
        level: "ERROR",
        createdAt: { gte: fiveMinutesAgo },
      },
    });

    const avgData = await prisma.systemLog.aggregate({
      where: {
        createdAt: { gte: fiveMinutesAgo },
      },
      _avg: { duration: true },
    });

    const avgResponse = avgData._avg.duration || 0;

    res.json({
      total,
      errorCount,
      avgResponse: Math.round(avgResponse),
      highError: errorCount > 10,
      highLatency: avgResponse > 2000,
    });
  } catch (error) {
    console.error("Fetch summary error:", error);
    res.status(500).json({ message: "Failed to fetch summary" });
  }
});

//กราฟ
router.get('/logs/trend', async (req, res) => {
  try {
    const result = await prisma.$queryRaw`
      SELECT 
        date_trunc('hour', "createdAt") AS hour,
        level,
        COUNT(*) AS count
      FROM "SystemLog"
      WHERE "createdAt" >= NOW() - INTERVAL '24 hours'
      GROUP BY hour, level
      ORDER BY hour ASC;
    `;

    res.json(result);

  } catch (error) {
    console.error("Trend error:", error);
    res.status(500).json({ message: "Failed to fetch trend" });
  }
});

module.exports = router;
