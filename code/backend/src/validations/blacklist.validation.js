const { z } = require("zod");

const createBlacklistSchema = z.object({
  userId: z.string().min(10),
  type: z.enum(["DRIVER", "PASSENGER"]),
  reason: z.string().max(200),
  suspendedUntil: z
        .string()
        .datetime()
        .nullable()
        .optional()
});

const addEvidenceSchema = z.object({
  type: z.enum(["IMAGE", "VIDEO"]),
  url: z.string().url()
});

module.exports = {
    createBlacklistSchema,
    addEvidenceSchema
}