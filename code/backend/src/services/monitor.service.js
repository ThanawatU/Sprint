const { prisma } = require("../utils/prisma");

const getLatestSystemLogs = async (level, limit = 100) => {
    const allowedLevels = ['INFO', 'WARN', 'ERROR'];
    const logs = await prisma.systemLog.findMany({
        where: allowedLevels.includes(level)
            ? { level }
            : undefined,
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
            userId: true
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
        userId: log.userId
    }));
};



const getSystemSummary = async () => {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const total = await prisma.systemLog.count();

    const errorCount = await prisma.systemLog.count({
        where: {
            level: "ERROR",
            createdAt: { gte: fiveMinutesAgo }
        }
    });

    const avgData = await prisma.systemLog.aggregate({
        where: {
            createdAt: { gte: fiveMinutesAgo }
        },
        _avg: {
            duration: true
        }
    });
    
    const avgResponse = avgData._avg.duration || 0;
    return {
        total,
        errorCount,
        avgResponse: Math.round(avgResponse),
        highError: errorCount > 10,
        highLatency: avgResponse > 2000
    };
};


module.exports = {
    getLatestSystemLogs,
    getSystemSummary
};
