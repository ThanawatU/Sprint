const { prisma } = require('./prisma');
const { logger } = require('./logger');
const { getNow } = require('./timestamp');

const {
  computeAccessHash, 
  prepareLogHashes,
} = require("../services/logIntegrity.service.js")

const {
  getLatestSystemLogHash,
  getLatestAccessLogHash,
} = require("../middlewares/audit.tools.js")


/**
 * บันทึก login ของผู้ใช้ไปยัง AccessLog
 */
const logLogin = async ({
  userId,
  ipAddress,
  userAgent,
  sessionId
}) => {
  try {
    // Login time + 90 days = expiration
    const loginTime = getNow();
    
    const data = {
      userId,
      loginTime,
      logoutTime: null,
      ipAddress,
      userAgent: userAgent?.substring(0, 500) || null,
      sessionId,
      createdAt: loginTime
    }

    const prevHash      = await getLatestAccessLogHash();
    const integrityHash = computeAccessHash(data, prevHash);
    data.integrityHash = integrityHash;
    data.prevHash = prevHash;
    await prisma.accessLog.create({
      data
    });
  } catch (error) {
    logger.error('AccessLog login record failed', {
      error: error.message,
      userId
    });
  }
};

/**
 * บันทึก logout ของผู้ใช้ไปยัง AccessLog
 */
const logLogout = async ({
  userId,
  sessionId
}) => {
  try {
    const logoutTime = getNow();

    // หาเซสชันที่ล่าสุด
    const accessLog = await prisma.accessLog.findFirst({
      where: {
        userId,
        ...(sessionId ? { sessionId } : {}),
        logoutTime: null // ยังไม่ logout
      },
      orderBy: {
        loginTime: 'desc'
      }
    });

    if (accessLog) {
      await prisma.accessLog.update({
        where: {
          id: accessLog.id
        },
        data: {
          logoutTime
        }
      });
    }
  } catch (error) {
    logger.error('AccessLog logout record failed', {
      error: error.message,
      userId
    });
  }
};

module.exports = { logLogin, logLogout };
