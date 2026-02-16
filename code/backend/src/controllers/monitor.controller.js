const monitorService = require('../services/monitor.service');

exports.getLogs = async (req, res) => {
  try {
    const { level } = req.query;
    const logs = await monitorService.getLatestSystemLogs(level);
    res.json(logs);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch logs' });
  }
};

exports.getSummary = async (req, res) => {
  try {
    const summary = await monitorService.getSystemSummary();
    res.json(summary);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch summary' });
  }
};
