const { prisma } = require('../utils/prisma');
const { logger } = require('../utils/logger');
const { getNow } = require('../utils/timestamp');

const logRequest = ({
  level = 'INFO',
  requestId,
  method,
  path,
  statusCode,
  duration,
  userId,
  ipAddress,
  userAgent,
  error,
  metadata
}) => {
  const createdAt = getNow();

  prisma.systemLog.create({
    data: {
      level,
      requestId,
      method,
      path,
      statusCode,
      duration,
      userId,
      ipAddress,
      userAgent,
      error,
      metadata,
      createdAt
    }
  }).catch(err => {
    logger.error('SystemLog write failed', {
      error: err.message,
      requestId
    });
  });
};

module.exports = { logRequest };
