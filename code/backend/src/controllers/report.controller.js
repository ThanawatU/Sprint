const reportService = require('../services/report.service');
const { auditLog, getUserFromRequest } = require('../utils/auditLog');
const multer = require('multer');

exports.createReport = async (req, res) => {
  try {
    const { driverId, bookingId, routeId, category, description } = req.body;
    const reporterId = req.user.id;

    const report = await reportService.createReportCase({
      reporterId,
      driverId,
      bookingId,
      routeId,
      category,
      description
    });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'CREATE_REPORT',
      entity: 'ReportCase',
      entityId: report.id,
      req,
      metadata: { category }
    });

    res.status(201).json({ message: "Report created successfully", data: report });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to create report" });
  }
};

exports.getReports = async (req, res) => {
  try {
    const { status, category, q } = req.query;
    const where = {};

    if (status) where.status = status;
    if (category) where.category = category;
    if (q) {
      where.OR = [
        { description: { contains: q, mode: "insensitive" } },
        { driver: { username: { contains: q, mode: "insensitive" } } },
        { reporter: { username: { contains: q, mode: "insensitive" } } }
      ];
    }

    const records = await reportService.getReports(where);
    
    // Add Log management
    await auditLog({
      ...getUserFromRequest(req),
      action: 'VIEW_REPORTS',
      entity: 'ReportCase',
      req,
      metadata: { filters: { status, category, searchQuery: q } }
    });
    
    res.json(records);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to fetch reports" });
  }
};

exports.getReportById = async (req, res) => {
  try {
    const { id } = req.params;
    const report = await reportService.getReportById(id);

    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    if (req.user.role !== 'ADMIN' && req.user.id !== report.reporterId && req.user.id !== report.driverId) {
      return res.status(403).json({ message: "Access denied" });
    }

    // Add Log management
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

exports.updateReportStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, adminNotes, note } = req.body;

    const result = await reportService.updateReportStatus(id, {
      status,
      adminNotes,
      resolvedById: req.user.id,
      note
    });

    if (!result) {
      return res.status(404).json({ message: "Report not found" });
    }

    await auditLog({
      ...getUserFromRequest(req),
      action: 'UPDATE_REPORT_STATUS',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { newStatus: status }
    });

    res.json({ message: "Report status updated", data: result[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to update report status" });
  }
};

exports.addEvidence = async (req, res) => {
  try {
    const { id } = req.params;
    const { evidences } = req.body;

    const result = await reportService.addEvidencesToReport(id, evidences, req.user.id);

    // Add Log management
    await auditLog({
      ...getUserFromRequest(req),
      action: 'ADD_REPORT_EVIDENCE',
      entity: 'ReportCase',
      entityId: id,
      req,
      metadata: { evidenceCount: result.count }
    });

    res.status(201).json({ 
      message: "Evidences added successfully", 
      count: result.count
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to add evidences" });
  }
};

// ดึงประวัติการ Report (Passenger)
exports.getMyReports = async (req, res) => {
  try {
    const userId = req.user.id;
    const { keyword, category, status } = req.query;

    const where = {
      reporterId: userId,
    };

    // Add Log management
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

// ดึงประวัติที่ตัวเองถูก Report (Driver)
exports.getReportsAgainstMe = async (req, res) => {
  try {
    const userId = req.user.id;

    const records = await reportService.getReports({
      driverId: userId
    });

    // Add Log management
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