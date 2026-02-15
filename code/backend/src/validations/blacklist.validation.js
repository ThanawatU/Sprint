const { z } = require("zod");

const createBlacklistSchema = z.object({
<<<<<<< HEAD
  userId: z.string().min(10),
  type: z.enum(["DRIVER", "PASSENGER"]),
  reason: z.string().max(200),
  suspendedUntil: z
        .string()
        .datetime()
        .nullable()
        .optional()
=======
  userId: z.string().uuid(),
  type: z.enum(["DRIVER", "PASSENGER"]),
  reason: z.string().max(200),
  suspendedUntil: z.date().optional()
>>>>>>> 3b0b0ac (Added blacklist.controller, admin.blacklist.routes and blacklist.routes)
});

const addEvidenceSchema = z.object({
  type: z.enum(["IMAGE", "VIDEO"]),
  url: z.string().url()
});

module.exports = {
    createBlacklistSchema,
    addEvidenceSchema
}