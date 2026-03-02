const { prisma } = require("../utils/prisma");

// สร้าง Report ใหม่ และบันทึกประวัติสถานะแรก (FILED)
const createReportCase = async (data) => {
  const { reporterId, driverId, bookingId, routeId, category, description } = data;

  return prisma.reportCase.create({
    data: {
      reporterId,
      driverId,
      bookingId,
      routeId,
      category,
      description,
      status: 'FILED',
      statusHistory: {
        create: {
          toStatus: 'FILED',
          changedById: reporterId,
          note: 'Initial report filed'
        }
      }
    },
    include: { reporter: true, driver: true }
  });
};

// ดึงรายการ Report ทั้งหมด (สามารถใส่เงื่อนไข filter และ order ได้)
const getReports = async (where = {}, orderBy = { createdAt: "desc" }) => {
  return prisma.reportCase.findMany({
    where,
    include: {
      reporter: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      driver: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      booking: true,
      route: true,
      evidences: true
    },
    orderBy
  });
};

// ดึงรายละเอียด Report รายเคส พร้อมประวัติสถานะและหลักฐาน
const getReportById = async (id) => {
  return prisma.reportCase.findUnique({
    where: { id },
    include: {
      reporter: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      driver: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      booking: true,
      route: true,
      evidences: true,
      statusHistory: {
        include: { changedBy: { select: { id: true, username: true } } },
        orderBy: { createdAt: "desc" }
      }
    }
  });
};

// อัปเดตสถานะ Report, บันทึกประวัติ, และจัดการระบบใบเหลือง/ใบแดงอัตโนมัติ
const updateReportStatus = async (id, { status, adminNotes, resolvedById, note }) => {
  const currentReport = await prisma.reportCase.findUnique({ where: { id } });
  if (!currentReport) return null;

  const updateData = {
    status,
    adminNotes: adminNotes !== undefined ? adminNotes : currentReport.adminNotes,
  };

  if (status === 'RESOLVED' || status === 'REJECTED') {
    updateData.resolvedById = resolvedById;
    updateData.resolvedAt = new Date();
  }
  if (status === 'CLOSED') {
    updateData.closedAt = new Date();
  }

  const [updatedReport, historyRecord] = await prisma.$transaction([
    prisma.reportCase.update({
      where: { id },
      data: updateData
    }),
    prisma.reportCaseStatusHistory.create({
      data: {
        reportCaseId: id,
        fromStatus: currentReport.status,
        toStatus: status,
        changedById: resolvedById,
        note: note || `Status updated to ${status}`
      }
    })
  ]);

  // ระบบแจกใบเหลือง (เมื่อเคสถูกตั้งเป็น RESOLVED)
  if (status === 'RESOLVED') {
    const targetUserId = currentReport.driverId; // คนที่ถูกรายงาน
    const targetUser = await prisma.user.findUnique({ where: { id: targetUserId } });

    if (targetUser) {
      const now = new Date();
      let currentCards = targetUser.yellowCardCount || 0;

      // ถ้าระยะเวลาใบเหลืองหมดอายุ ให้รีเซ็ตกลับไปนับ 0 ใหม่
      if (targetUser.yellowCardExpiresAt && targetUser.yellowCardExpiresAt < now) {
        currentCards = 0;
      }

      currentCards += 1; // เพิ่มใบเหลือง
      
     // ถ้าครบ 3 ใบ แจกใบแดงแล้วแบนถาวรลงตาราง Blacklist และรีเซ็ตใบเหลือง
      if (currentCards >= 3) {
        await prisma.$transaction([
          prisma.user.update({
            where: { id: targetUserId },
            data: { 
              yellowCardCount: 0, 
              yellowCardExpiresAt: null,
              isActive: false 
            }
          }),

          prisma.blacklist.create({
            data: {
              userId: targetUserId,
              type: targetUser.role === 'PASSENGER' ? 'PASSENGER' : 'DRIVER',
              reason: 'สะสมใบเหลืองครบ 3 ใบ',
              createdById: resolvedById,
              status: 'ACTIVE',
              suspendedUntil: null
            }
          })
        ]);
      } else {
        // ถ้าไม่ถึง 3 ใบ ให้อัปเดตจำนวนใบเหลืองและยืดเวลาหมดอายุไปอีก 30 วัน
        const newExpiresAt = new Date();
        newExpiresAt.setDate(newExpiresAt.getDate() + 30);

        await prisma.user.update({
          where: { id: targetUserId },
          data: {
            yellowCardCount: currentCards,
            yellowCardExpiresAt: newExpiresAt
          }
        });
      }
    }
  }

  return [updatedReport, historyRecord];
};

// แนบหลักฐานหลายไฟล์ลงในเคส Report
const addEvidencesToReport = async (reportCaseId, evidencesData, uploadedById) => {
  const formattedData = evidencesData.map(evidence => ({
    reportCaseId,
    type: evidence.type,
    url: evidence.url,
    fileName: evidence.fileName,
    mimeType: evidence.mimeType,
    fileSize: evidence.fileSize,
    uploadedById
  }));

  return prisma.reportEvidence.createMany({
    data: formattedData
  });
};

module.exports = {
  createReportCase,
  getReports,
  getReportById,
  updateReportStatus,
  addEvidencesToReport
};