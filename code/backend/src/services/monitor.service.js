const { prisma } = require("../utils/prisma");

const getLatestSystemLogs = async (level = 'ALL', limit = 100) => {
  try {

    const whereCondition =
      level && level !== 'ALL'
        ? { level }
        : undefined;

    const logs = await prisma.systemLog.findMany({
      where: whereCondition,
      orderBy: { createdAt: "desc" },
      take: limit,
      select: {
        id: true,
        createdAt: true,
        method: true,
        path: true,
        statusCode: true,
        duration: true,
        level: true,
        userId: true,
        ipAddress: true,
        requestId: true
      }
    });

    return logs.map(log => ({
      id: log.id,
      createdAt: log.createdAt,
      method: log.method,
      endpoint: log.path,
      statusCode: log.statusCode,
      responseTime: log.duration,
      level: log.level,
      userId: log.userId,
      ipAddress: log.ipAddress,
      requestId: log.requestId
    }));

  } catch (error) {
    console.error("getLatestSystemLogs error:", error);
    throw error;
  }
};


const getSystemSummary = async () => {
  try {

    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
    const [total, errorCount, avgData] = await Promise.all([

      prisma.systemLog.count(),

      prisma.systemLog.count({
        where: {
          level: "ERROR",
          createdAt: { gte: fiveMinutesAgo }
        }
      }),

      prisma.systemLog.aggregate({
        where: {
          createdAt: { gte: fiveMinutesAgo }
        },
        _avg: { duration: true }
      })

    ]);

    const avgResponse = avgData._avg.duration || 0;

    const ERROR_THRESHOLD = 10;
    const LATENCY_THRESHOLD = 2000;

    return {
      total,
      errorCount,
      avgResponse: Math.round(avgResponse),
      highError: errorCount > ERROR_THRESHOLD,
      highLatency: avgResponse > LATENCY_THRESHOLD
    };

  } catch (error) {
    console.error("getSystemSummary error:", error);
    throw error;
  }
};

module.exports = {
  getLatestSystemLogs,
  getSystemSummary
};
