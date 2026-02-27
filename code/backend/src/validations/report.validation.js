const { z } = require("zod");

//ตรวจสอบข้อมูลตอนผู้ใช้สร้าง Report
const createReportSchema = z.object({
  driverId: z.string().min(1, "Driver ID is required"),
  bookingId: z.string().optional().nullable(),
  routeId: z.string().optional().nullable(),
  category: z.enum([
    "DANGEROUS_DRIVING",
    "AGGRESSIVE_BEHAVIOR",
    "HARASSMENT",
    "NO_SHOW",
    "FRAUD_OR_SCAM",
    "OTHER"
  ], {
    errorMap: () => ({ message: "Invalid report category" })
  }),
  description: z.string().min(5, "Description must be at least 5 characters").max(1000, "Description is too long")
});

//ตรวจสอบข้อมูลตอนแอดมินอัปเดตสถานะ Report
const updateReportStatusSchema = z.object({
  status: z.enum([
    "FILED",
    "UNDER_REVIEW",
    "INVESTIGATING",
    "RESOLVED",
    "REJECTED",
    "CLOSED"
  ], {
    errorMap: () => ({ message: "Invalid report status" })
  }),
  adminNotes: z.string().max(1000).optional().nullable(),
  note: z.string().max(500).optional().nullable()
});

//ตรวจสอบข้อมูล
const addReportEvidenceSchema = z.object({
  evidences: z.array(
    z.object({
      type: z.enum(["VIDEO", "IMAGE", "AUDIO", "DOCUMENT"], {
        errorMap: () => ({ message: "Invalid evidence type" })
      }),
      url: z.string().url("Must be a valid URL"),
      fileName: z.string().optional().nullable(),
      mimeType: z.string().optional().nullable(),
      fileSize: z.number().int().positive().optional().nullable()
    })
  )
  .min(1, "At least one evidence is required")
  .max(6, "Cannot upload more than 6 files in total") // เปลี่ยนเป็น 6 (รูป 3 + วิดีโอ 3)
  .refine((items) => {
    // นับจำนวนรูปและวิดีโอ
    const imageCount = items.filter(item => item.type === "IMAGE").length;
    const videoCount = items.filter(item => item.type === "VIDEO").length;
    
    // กฎใหม่: อย่างละไม่เกิน 3
    return imageCount <= 3 && videoCount <= 3;
  }, { 
    message: "You can upload a maximum of 3 images and 3 videos." 
  })
});


module.exports = {
  createReportSchema,
  updateReportStatusSchema,
  addReportEvidenceSchema
};