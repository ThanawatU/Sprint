const { z } = require("zod");

const createBlacklistSchema = z.object({
  userId: z.string().uuid(),
  type: z.enum(["DRIVER", "PASSENGER"]),
  reason: z.string().max(200),
  suspendedUntil: z.date().optional()
});

const addEvidenceSchema = z.object({
  type: z.enum(["IMAGE", "VIDEO"]),
  url: z.string().url()
});

module.exports = {
    createBlacklistSchema,
    addEvidenceSchema
}