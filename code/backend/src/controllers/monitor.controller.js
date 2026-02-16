const monitorService = require('../services/monitor.service');

exports.getLogs = async (req, res) => {
  try {
    const logs = await monitorService.fetchLatestLogs();
    res.json(logs);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch logs' });
  }
};

exports.getSummary = async (req, res) => {
  try {
    const summary = await monitorService.fetchSummary();
    res.json(summary);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch summary' });
  }
};
