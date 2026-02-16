const { prisma } = require("../utils/prisma");
const { auditLog, getUserFromRequest } = require('../utils/auditLog');

exports.createBlacklist = async (req, res) => {
  try {
    const { userId, type, reason, suspendedUntil } = req.body;

    const admin = req.user; // from JWT middleware

    if (admin.role !== "ADMIN") {
      return res.status(403).json({ message: "Forbidden " + admin.role });
    }

    const blacklist = await prisma.blacklist.create({
      data: {
        userId,
        type,
        reason,
        suspendedUntil,
        createdById: admin.id
      }
    });

    await auditLog({
      ...getUserFromRequest(req),
      action: 'ADD_TO_BLACKLIST',
      entity: 'Blacklist',
      entityId: blacklist.id,
      req,
      metadata: {
        userId: userId,
        type: type,
        reason: reason,
        suspendedUntil: suspendedUntil
      }
    });

    res.status(201).json(blacklist);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to blacklist user" });
  }
};

exports.getBlacklists = async (req, res) => {
  const records = await prisma.blacklist.findMany({
    include: {
      user: true,
      evidences: true
    },
    orderBy: {
      createdAt: "desc"
    }
  });

  res.json(records);
};

exports.getBlacklistById = async (req, res) => {
  const { id } = req.params;

  const record = await prisma.blacklist.findUnique({
    where: { id },
    include: {
      user: true,
      evidences: true
    }
  });

  if (!record) {
    return res.status(404).json({ message: "Not found" });
  }

  res.json(record);
};

exports.liftBlacklist = async (req, res) => {
  const { id } = req.params;

  const updated = await prisma.blacklist.update({
    where: { id },
    data: {
      status: "LIFTED",
      liftedAt: new Date(),
      liftedById: req.user.id
    }
  });

  await auditLog({
    ...getUserFromRequest(req),
    action: 'REMOVE_FROM_BLACKLIST',
    entity: 'Blacklist',
    entityId: id,
    req,
    metadata: {
      userId: updated.userId,
      type: updated.type,
      reason: updated.reason
    }
  });

  res.json(updated);
};

exports.checkBlacklist = async (userId) => {
  const activeBlacklist = await prisma.blacklist.findFirst({
    where: {
      userId,
      status: "ACTIVE",
      OR: [
        { suspendedUntil: null },
        { suspendedUntil: { gt: new Date() } }
      ]
    }
  });

  return activeBlacklist;
};

exports.addEvidence = async (req, res) => {
  const { id } = req.params;
  const { type, url } = req.body;

  const evidence = await prisma.blacklistEvidence.create({
    data: {
      blacklistId: id,
      type,
      url,
      uploadedById: req.user.id
    }
  });

  res.status(201).json(evidence);
};

exports.updateBlacklist = async (req, res) => {
  const { id } = req.params;
  const { reason, status, suspendedUntil } = req.body;

  const updated = await prisma.blacklist.update({
    where: { id },
    data: {
      reason,
      status,
      suspendedUntil
    }
  });

  res.json(updated);
};


