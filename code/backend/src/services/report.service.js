const { prisma } = require("../utils/prisma");

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

const getReports = async (where = {}, orderBy = { createdAt: "desc" }) => {
  return prisma.reportCase.findMany({
    where,
    include: {
      reporter: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      driver: { select: { id: true, username: true, email: true, firstName: true, lastName: true } },
      booking: true,
      route: true,
    },
    orderBy
  });
};

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

  return prisma.$transaction([
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
};

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