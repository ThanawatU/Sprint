const monitorService = require('../services/monitor.service');

exports.getLogs = async (req, res) => {
  try {
    const { level = 'ALL', type = 'SystemLog' } = req.query;

    let logs;

    switch (type) {
      case 'AuditLog':
        logs = await monitorService.getLatestAuditLogs(level);
        break;

      case 'AccessLog':
        logs = await monitorService.getLatestAccessLogs(level);
        break;

      default:
        logs = await monitorService.getLatestSystemLogs(level);
    }

    res.json(logs);

  } catch (error) {
    console.error('getLogs controller error:', error);
    res.status(500).json({ message: 'Failed to fetch logs' });
  }
};

exports.getSummary = async (req, res) => {
  try {
    const summary = await monitorService.getSystemSummary();
    res.json(summary);

  } catch (error) {
    console.error('getSummary controller error:', error);
    res.status(500).json({ message: 'Failed to fetch summary' });
  }
};
