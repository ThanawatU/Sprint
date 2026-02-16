const express = require('express');
const router = express.Router();
const { prisma } = require('../utils/prisma');


//Latest 100 System Logs
router.get('/logs', async (req, res) => {
  try {
    const logs = await prisma.systemLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: 100
    });
    res.json(
      logs.map(log => ({
        id: log.id,
        createdAt: log.createdAt,
        method: log.method,
        endpoint: log.path,
        statusCode: log.statusCode,
        responseTime: log.duration,
        level: log.level
      }))
    );

  } catch (error) {
    console.error('Fetch logs error:', error);
    res.status(500).json({ message: 'Failed to fetch logs' });
  }
});


// GET Summary
router.get('/logs/summary', async (req, res) => {
  try {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const total = await prisma.systemLog.count();

    const errorCount = await prisma.systemLog.count({
      where: {
        level: 'ERROR',
        createdAt: { gte: fiveMinutesAgo }
      }
    });

    const avgData = await prisma.systemLog.aggregate({
        where: {
          createdAt: { gte: fiveMinutesAgo }
        },
         _avg: { duration: true }
    });

    const avgResponse = avgData._avg.duration || 0;

   const ERROR_THRESHOLD = 10;
    const LATENCY_THRESHOLD = 2000;

const highError = errorCount > ERROR_THRESHOLD;
const highLatency = avgResponse > LATENCY_THRESHOLD;

    res.json({
      total,
      errorCount,
      avgResponse: Math.round(avgResponse),
      highError,
      highLatency
    });

  } catch (error) {
    console.error('Fetch summary error:', error);
    res.status(500).json({ message: 'Failed to fetch summary' });
  }
});

module.exports = router;
