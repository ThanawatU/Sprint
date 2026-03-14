const reportService = require('../services/report.service');
const { auditLog, getUserFromRequest } = require('../utils/auditLog');
const { prisma } = require('../utils/prisma');

// 1. สร้าง Report (รองรับทั้งคนเดียว และ หลายคนพร้อมกัน)
exports.createReport = async (req, res) => {
  try {
    const { reportedUserIds, bookingId, routeId, category, description } = req.body;
    const reporterId = req.user.id;

    const result = await reportService.createReportCase({
      reporterId,
      reportedUserIds,
      bookingId,
      routeId,
      category,
      description
    });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'CREATE_REPORT',
      entity: 'ReportCase',
      req,
      metadata: { 
        isGroup: result.groupId !== null, 
        groupId: result.groupId, 
        reportedCount: reportedUserIds.length 
      }
    });

    res.status(201).json({ 
      success: true, 
      message: result.groupId 
        ? `Successfully created group report with ${reportedUserIds.length} cases.` 
        : "Successfully created report case.",
      groupId: result.groupId,
      cases: result.cases,
      data: result.cases 
    });
  } catch (error) {
    console.error(error);
    const statusCode = error.message.includes("รายงาน") || error.message.includes("Trip") ? 400 : 500;
    res.status(statusCode).json({ success: false, message: error.message || "Failed to create reports" });
  }
};

// 2. ดึงรายการ Report ทั้งหมด (สำหรับ Admin)
exports.getReports = async (req, res) => {
  try {
    const { status, category, q, routeId } = req.query;
    const where = {};

    if (status) where.status = status;
    if (category) where.category = category;
    if (routeId) where.routeId = routeId; // ค้นหาตาม Trip
    if (q) {
      where.OR = [
        { description: { contains: q, mode: "insensitive" } },
        { reportedUser: { username: { contains: q, mode: "insensitive" } } },
        { reporter: { username: { contains: q, mode: "insensitive" } } }
      ];
    }

    const records = await reportService.getReports(where);
    
    await auditLog({
      ...getUserFromRequest(req),
      action: 'VIEW_REPORTS',
      entity: 'ReportCase',
      req,
      metadata: { filters: { status, category, routeId, searchQuery: q } }
    });
    
    res.json(records);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to fetch reports" });
  }
};

// 3. ดึงรายละเอียด Report รายเคส (รองรับทั้งแบบ Group และ เดี่ยว)
exports.getReportById = async (req, res) => {
  try {
    const { id } = req.params;
    const isGroup = id.startsWith('REP-');
    
    const report = isGroup 
      ? await reportService.getReportByGroupId(id)
      : await reportService.getReportById(id);

    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    // เช็คสิทธิ์การเข้าดู
    if (req.user.role !== 'ADMIN' && req.user.id !== report.reporterId) {
      const isReportedUser = report.reportedUsers?.some(u => u.id === req.user.id);
      if (!isReportedUser) return res.status(403).json({ message: "Access denied" });
    }

    await auditLog({
      ...getUserFromRequest(req),
      action: 'VIEW_REPORT',
      entity: 'ReportCase',
      entityId: id,
      req
    });

    res.json(report);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to fetch report" });
  }
};

// 4. แอดมินรับเรื่อง (PENDING -> UNDER_REVIEW)
exports.assignReport = async (req, res) => {
  try {
    const { id } = req.params;
    const isGroup = id.startsWith('REP-');
    
    const reports = isGroup 
      ? await prisma.reportCase.findMany({ where: { groupId: id }, select: { id: true } })
      : [{ id }];

    if (!reports.length) return res.status(404).json({ message: 'Report not found' });

    const ids = reports.map(r => r.id);
    const updated = await reportService.assignReport(ids, req.user.id);

    await auditLog({
      ...getUserFromRequest(req),
      action: 'ASSIGN_REPORT',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { isGroup, affectedIds: ids }
    });

    res.json({ success: true, message: "Report assigned successfully", data: updated });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message || 'Failed to assign report' });
  }
};

// 5. แอดมินอนุมัติเคส (RESOLVED + แจกใบเหลืองอัตโนมัติ)
exports.resolveReport = async (req, res) => {
  try {
    const { id } = req.params;
    const { adminNotes } = req.body;

    const result = await reportService.resolveReport(id, req.user.id, adminNotes);

    if (!result) return res.status(404).json({ message: "Report not found" });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'RESOLVE_REPORT',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { adminNotes, isGroup: id.startsWith('REP-') }
    });

    res.json({ success: true, message: "Report resolved and yellow card issued", data: result });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to resolve report" });
  }
};

// 6. แอดมินปฏิเสธเคส (REJECTED)
exports.rejectReport = async (req, res) => {
  try {
    const { id } = req.params;
    const { adminNotes } = req.body;

    const result = await reportService.rejectReport(id, req.user.id, adminNotes);

    if (!result) return res.status(404).json({ message: "Report not found" });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'REJECT_REPORT',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { adminNotes, isGroup: id.startsWith('REP-') }
    });

    res.json({ success: true, message: "Report rejected", data: result });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to reject report" });
  }
};

// 7. เพิ่มหลักฐาน และ Timestamp
exports.addEvidence = async (req, res) => {
  try {
    const { id } = req.params; 
    const { evidences } = req.body;
    const isGroup = id.startsWith('REP-');

    const result = isGroup 
      ? await reportService.addEvidencesToReportGroup(id, evidences, req.user.id)
      : await reportService.addEvidencesToReport(id, evidences, req.user.id);

    await auditLog({
      ...getUserFromRequest(req),
      action: 'ADD_REPORT_EVIDENCE',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { evidenceCount: evidences.length, isGroup }
    });

    res.status(201).json({ success: true, message: "Evidence uploaded successfully", data: result });
  } catch (error) {
    console.error("Error Detail:", error);
    const statusCode = error.message.includes("ดำเนินการไปแล้ว") ? 403 : 500;
    res.status(statusCode).json({ success: false, message: error.message || "Failed to add evidences" });
  }
};

// 8. ดึงประวัติการ Report ที่เราส่งเอง
exports.getMyReports = async (req, res) => {
  try {
    const records = await reportService.getReports({ reporterId: req.user.id });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'VIEW_MY_REPORTS',
      entity: 'ReportCase',
      req,
      metadata: { recordCount: records.length }
    });

    res.json({ success: true, data: records });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to fetch your reports" });
  }
};

// 9. ดึงประวัติที่คนอื่นรีพอร์ตเรา
exports.getReportsAgainstMe = async (req, res) => {
  try {
    const records = await reportService.getReports({ reportedUserId: req.user.id });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'VIEW_REPORTS_AGAINST_ME',
      entity: 'ReportCase',
      req,
      metadata: { recordCount: records.length }
    });

    res.json({ success: true, data: records });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to fetch reports against you" });
  }
};

// 10. ผู้ใช้ยกเลิก Report ด้วยตัวเอง
exports.cancelReport = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // เรียกใช้ Service สำหรับยกเลิก
    const result = await reportService.cancelReport(id, userId);

    if (!result) return res.status(404).json({ message: "Report not found" });

    // เก็บ Audit Log ตอนผู้ใช้กดยกเลิก
    await auditLog({
      ...getUserFromRequest(req),
      action: 'CANCEL_REPORT',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { isGroup: id.startsWith('REP-') }
    });

    res.json({ success: true, message: "Report has been successfully cancelled", data: result });
  } catch (error) {
    console.error(error);
    const statusCode = error.message.includes("403") || error.message.includes("400") ? 400 : 500;
    res.status(statusCode).json({ success: false, message: error.message || "Failed to cancel report" });
  }
};