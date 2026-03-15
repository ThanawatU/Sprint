# Changelog

All notable changes to this project will be documented in this file.

---

## [1.0.0] - 2026-02-13 - Wisit_2348

### Added

- Added .env file for Docker Compose configuration

- Updated .gitignore to exclude .env files

- Added `CORS_ORIGIN` environment variable

- Added CHANGE-LOG.md , AI-Declaration.md

### Changed

- Removed unnecessary build tools (python3, make, g++)

- Ensured Prisma works with openssl on Alpine

- Database migrations run automatically before server start

- Moved to build-time configuration using ARG

### Removed

- Duplicate Nuxt plugin file (fixes "Cannot redefine property $api" error)

- Removed `migrate` service (migrations now run automatically in backend)

---

## [1.0.0] - 2026-02-15 - ThanawatU

### Added

- Added `AuditLog` model to schema.prisma
- Completed Blacklist API
- Added Postman's Blacklist collection to test folder

### Changed

- Modify auth.controller.js to audit users Login and Password change activity
- Fixed Auditlog bug between User table and Auditlog table
- Fixed Directory conflict for prisma

---

## [1.0.0] - 2026-02-15 - Phakorn_2160

### Added

- System Logging Infrastructure for performance monitoring and issue tracking
  - `SystemLog` model in `prisma/schema.prisma` with fields: level, requestId, method, path, statusCode, duration, userId, ipAddress, userAgent, error (JSON), metadata (JSON)
  - `LogLevel` enum (INFO, WARN, ERROR) for categorizing log severity
  - Indexed fields for efficient querying: level, requestId, statusCode, createdAt, userId
- `src/utils/logger.js` - Lightweight structured JSON logger with configurable console output via `LOG_TO_CONSOLE` env var
- `src/services/systemLog.service.js` - Fire-and-forget database logging service (non-blocking)
- `src/middlewares/requestLogger.js` - HTTP request/response logging middleware

- Request Tracing - Every API request receives unique `X-Request-ID` header for debugging

### Changed

- `server.js` - Added `requestLogger` middleware after `metricsMiddleware`
- `src/middlewares/errorHandler.js` - Integrated error logging with full stack trace capture
- `.env.example` - Added `LOG_TO_CONSOLE` configuration variable

### Miscellaneous

- Log Levels automatically determined by status code (INFO: 2xx, WARN: 4xx, ERROR: 5xx)
- Excluded Paths `/health`, `/metrics`, `/documentation` skipped to reduce noise
- Non-blocking Database writes use fire-and-forget pattern to avoid impacting request latency
- Graceful Failure DB write failures log to console but never crash the application
- Post-Deployment run migration to create SystemLog table:
  ```bash
  docker compose exec backend npx prisma migrate dev --name add_system_log
  ```

---

## [1.0.0] - 2026-02-16 - Wisit_2348

### Changed

- Added `AccessLog` model structure to align with the latest authentication and session tracking requirements.
- Adjusted `expiresAt` field behavior in `AuditLog` to ensure proper log retention and expiration handling.
- Fixed and updated database migrations to correctly reflect the current Prisma schema.

---

## [1.0.0] - 2026-02-16 - Wisit_2348

### Added

- Created utility modules for accessLog and auditLog.

### Changed

- Updated migration files to align with the auditLog schema (log retention not implemented yet).
- Added audit log recording in the following controllers:auth.controller blacklist.controller booking.controller driverVerification.controller router.controller user.controller vehicle.controller
- Added const createdAt = new Date(); in audit.service.

### Removed

- Removed expiration date fields from auditLog, accessLog, and all related components.

### Fixed

- Bug fixes in requestLogger.js ,systemLog.service to connect database and backend

---

## [1.0.0] - 2026-02-16 - Phakorn_2160

### Added

- `src/services/blacklist.service.js` - Blacklist checking service with `checkBlacklistByIdentifiers()` and `checkBlacklistByUserId()` functions

### Changed

- `src/services/user.service.js` - Registration now checks if email, nationalIdNumber, or phoneNumber belongs to a blacklisted user before allowing account creation (returns 403 if blacklisted)

---

## [1.0.0] - 2026-02-17 - Nattaphat_0126

### Added

- **Log Retention System**:
  - `src/services/logRetention.service.js` - Added `cleanupOldLogs` function to automatically delete SystemLog and AccessLog entries older than 90 days.
- **Automated Testing (Robot Framework)**:
  - `test/blacklist_test.robot` - Added test suite for **Blacklist Lifecycle** (Create -> Get All/By ID -> Lift -> Add Evidence) to verify admin operations.
  - `test/auditlog_test.robot` - Added **Data Integrity Verification** test to ensure `AuditLog` correctly records userId, role, action, and request context (IP/UserAgent) upon Admin Login.
  - `test/audit_log_test.robot` - Added comprehensive audit log test suite covering:
    - Driver & Passenger Login.
    - Vehicle Creation (Driver) with amenities validation.
    - Route Creation & Booking Flow (Driver creates route -> Passenger books).

### Changed

- **Backend Server**:
  - `server.js` - Integrated `node-cron` to schedule the **Log Retention** task to run daily at 03:00 AM (GMT+7).
  - `package.json` - Added `node-cron` dependency to support scheduled tasks.

---

## [1.0.0] - 2026-02-17 - Pimapsorn_5095

### Added

- Created utility modules for accessLog and auditLog handling.
- Implemented getLatestAccessLogs in monitor.service to support LOGIN/LOGOUT display.
- Created Monitor Dashboard page to display: system logs,Audit logs,Access logs (LOGIN / LOGOUT)
  Real-time summary (total requests, errors in last 5 minutes, average response time)
- Connected frontend Monitor Dashboard with backend /monitor/logs and /monitor/logs/summary APIs.
- Created User Manual documentation

### Changed

- Updated monitor.controller to support dynamic log type selection (SystemLog, AuditLog, AccessLog).
- Updated monitor.service to: Support date filtering, Normalize access log output,
  Standardize response fields for frontend usage
- Improved AccessLog UI to visually distinguish

## Fixed

- Fixed database connection issue in requestLogger.js.
- Fixed AccessLog not updating logout time correctly.
- Fixed Monitor Dashboard log filtering by selected date.

---

## [1.0.0] - 2026-02-17 - Yodsanon_0215

### Added

- Added API base URL sanitization in the frontend to prevent duplicated paths (`//`) when calling backend endpoints.
- Recreated Prisma migrations and initialized a clean database migration structure.

### Fixed

- Fixed duplicated Prisma migrations and database schema mismatch issues.
- Resolved `P2022` error caused by missing `AuditLog.expiresAt` column in the database.

---

## [1.0.0] - 2026-02-17 - Yodsanon_0215

### Added

- Added UAT scenarios for Audit Log and Blacklist management.
- Implemented automated API tests using Robot Framework for AuditLog, AccessLog, SystemLog, and Blacklist workflow.

---

## [1.0.0] - 2026-02-17 - Kanyapat_5037

### Added

- Created Blacklist Management page
- Added log retention deletion function
- Implemented Robot Framework automated test cases for Log Retention feature
- Added Privacy Policy updates for Log Retention and Blacklist compliance

### Fixed

- Resolved 404 error on route `/blacklists/:id/edit`
- Fixed Cloudinary upload error

---

## [1.0.0] - 2026-02-17 - Wisit_2348

### Added

- AI Declaration
- Sprint Backlog File
- Adapt Blueprint

---

## [2.0.0] - 2026-02-26 - Phakorn_2160

### Added

- `ExportRequest` model in `prisma/schema.prisma` for tracking log export requests with approval workflow (status, reviewer, rejection reason) and export result metadata (filePath, fileSize, recordCount)
- `ExportStatus` enum (PENDING, APPROVED, REJECTED, PROCESSING, COMPLETED, FAILED)
- `ExportFormat` enum (CSV, JSON, PDF)
- `integrityHash` field (`VarChar(64)`) on `AuditLog` model for SHA-256 tamper detection
- `@@index([createdAt])` on `AccessLog` for date range queries and retention cleanup
- `@@index([integrityHash])` on `AuditLog`
- Report database core: `ReportCase`, `ReportCaseStatusHistory`, `ReportEvidence`
- Report enums: `ReportCategory`, `ReportCaseStatus`, `ReportEvidenceType`
- Prisma migration `20260226153400_add_report_case_tables` (tables, indexes, foreign keys)

### Changed

- Added report relations on `User`, `Booking`, and `Route` to support case linking and history/evidence workflows

---

## [2.0.0] - 2026-02-26 - Yodsanon_0215

### Added

- `src/services/report.service.js` - Implemented core business logic for Report Case management (create, get all, get by ID).
- Added `ReportCaseStatusHistory` automated tracking inside `report.service.js` using Prisma `$transaction` during status updates.
- Added multiple file upload support for `ReportEvidence` using `prisma.reportEvidence.createMany`.
- `src/controllers/report.controller.js` - Created HTTP request handlers for the report lifecycle.
- Added specific report query endpoints for Passenger (`GET /api/reports/my`) and Driver (`GET /api/reports/against-me`).
- Integrated `AuditLog` tracking in `report.controller.js` for actions: `CREATE_REPORT` and `UPDATE_REPORT_STATUS`.
- `src/routes/report.routes.js` - Defined API endpoints for Report functionality with `protect` and `requireAdmin` middlewares.
- `src/validations/report.validation.js` - Added Zod validation schemas (`createReportSchema`, `updateReportStatusSchema`, `addReportEvidenceSchema`).
- Implemented file upload validation rules (maximum 3 images and 3 videos per report evidence submission).
- Added `Report.postman_collection.json` in `test/Sprint 2` for API testing.

### Changed

- `src/routes/index.js` - Mounted the new report routes at `/api/reports`.

---

## [2.0.0] - 2026-02-27 - Phakorn_2160

### Added

- Implemented export management with request lifecycle endpoints (create, list, approve, reject, download).
- Added export generators for CSV, JSON, and PDF with validation and Swagger documentation.
- Added export route module and scheduled cleanup for expired export files.

### Changed

- Integrated export routes into backend server and route index.
- Standardized metadata and timestamp handling across logging utilities and services.
- Updated backend dependencies and `.gitignore` to support export workflow.

### Fixed

- Improved error handling and logging consistency in middleware and services for export flows.

---

## [2.0.0] - 2026-02-28 - Phakorn_2160

### Added

- File integrity validation for audit logs using SHA-256 hashing (Node.js built-in `crypto`, zero new dependencies)
- `src/utils/integrityHash.js` — `computeIntegrityHash()` and `verifyIntegrityHash()` utilities
- `src/services/integrity.service.js` — Single and batch verification with pagination and date filtering
- `src/controllers/integrity.controller.js`, `src/routes/integrity.routes.js`, `src/validations/integrity.validation.js` — Admin-only verification API endpoints
- `src/docs/integrity.doc.js` — Swagger documentation for integrity endpoints
- API: `GET /api/integrity/verify` (batch) and `GET /api/integrity/verify/:id` (single), both admin-only

### Changed

- `src/services/audit.service.js` — `logAudit()` now computes and stores SHA-256 integrity hash on every audit log creation
- `src/routes/index.js` — Registered integrity routes at `/integrity`

---

## [2.0.0] - 2026-03-03 - Nattaphat_0126

### Added

- Added Auto-approval logic for export requests by `ADMIN` role in `audit.controller.js`
- Added PDF export generation logic and format support in `audit.service.js` and `audit.routes.js`
- Implemented Export Request Management UI for administrators in `admin/exports/index.vue`
- Added User Log Request History and submission form for regular users in `profile/logs.vue`

### Changed

- Enhanced `ProfileSidebar.vue` and `AdminSidebar.vue` to include new log export navigation menus
- Updated User Management table in `admin/users/index.vue` to display User IDs for better tracking

---

## [2.0.0] - 2026-02-27 - Thanawat_2128

### Added

- Added `audit.routes.js`, `audit.controller.js` and `auditAccess.middleware.js` - Implemented Log core Service, Log Search & Filter API, and Access Control for Audit Log Management Service

### Changed

- Fixed Bugs in `audit.controller.js`

## [2.0.0] - 2026-02-28 - Thanawat_2128

### Added

- Added Hash chain system to `AuditLog`, `AccessLog` and `SystemLog`
- Added Automate Weekly check for Hash chain

### Changed

- Modify DB trigger on UPDATE and DELETE on Log Tables

- Fixed Bugs in `audit.controller.js`

---

## [2.0.0] - 2026-03-01 - Wisit_2348

### Added

- Added Audit Log for Passenger report system.
- Added Audit Log support for exporting audit logs to file.
- Extended Audit Log coverage in the following controllers:
  - user.controller
  - report.controller
  - notification.controller
  - integrity.controller
  - export.controller
  - driverVerification.controller
  - blacklist.controller
  - auth.controller
- Added new environment variables related to Audit Log Key in .env (Docker environment)

### Fixed

- Updated version for Sprint 2 (changed to version 2.0.0)

### Fixed

- Fixed an issue where Logout action was not recorded in Access Log.
- Fixed Audit Log configuration issue related to missing or incorrect AUDIT_LOG_KEY in Docker.
- Fixed Monitor Dashboard icon issue.

---

## [2.0.0] - 2026-03-01 - Yodsanon_0215

### Added

- Added `yellowCardCount` and `yellowCardExpiresAt` fields to the `User` model in `schema.prisma`.
- Implemented automatic yellow card issuance in `report.service.js` when an admin updates a report status to `RESOLVED`.
- Added 30-day expiration tracking for yellow cards. If a user receives a new card within 30 days, the expiration extends; otherwise, it resets to zero.
- Added logic to permanently blacklist users (`suspendedUntil: null`) and deactivate their accounts (`isActive: false`) upon receiving their 3rd yellow card.

### Changed

- `src/services/report.service.js` - Modified `updateReportStatus` to trigger the Yellow/Red card.

---

## [2.0.0] - 2026-03-02 - Wisit_2348

### Added

- Added Report Management page for report handling and monitoring.
- Added a sidebar navigation link to the Report Management page.
- Added 4LsRetroSpective File

---

## [2.0.0] - 2026-03-03 - Yodsanon_0215

### Added

- Added groupId field to the ReportCase model in schema.prisma for multi-user reporting.
- Implemented addEvidencesToReportGroup in report.service.js to support bulk evidence uploads for grouped reports.
- Added logic to automatically generate and assign groupId (e.g., REP-xxxx) when reporting multiple users.

### Changed

- src/controllers/report.controller.js - Updated createReport and addEvidence to support group-based reporting and evidence distribution.

- src/validations/report.validation.js - Updated createReportSchema to accept an array of reportedUserIds.

---

## [2.0.0] - 2026-03-03 - Kanyapat_5037

### Added

- Report Detail page for admin dashboard
- Report grouping support (groupId) for multiple reported users.
- Admin case management section (issue yellow card + resolution controls).
- Yellow card system with 30-day expiration and automatic suspension after 3 cards.
- Notification system to send resolution updates back to reporter.
- API blocking for suspended users via authentication middleware.
- Added reject button for admin case management.

### Fixed

- Fixed routing path to admin report detail page.

---

## [2.0.0] - 2026-03-03 - Pimapsorn_5095

### Added
- Report form page with multi-user selection support.
- Report history page (My Reports) with search and filter.
- Admin report detail page and case management system.
- Yellow/Red card policy system (30-day expiration, auto-suspension after 3 yellow cards).
- Group report support using `groupId` and `reportedUserIds[]`.
- Evidence upload support with Cloudinary integration.
- User Manual documentation

### Changed
- Notification system for case resolution updates.
- Refactored report structure to support multiple reported users.
- Updated frontend to use checkbox multi-select for reporting.
- Improved authentication handling (cookie-based token).
- Unified UI styling for report-related pages.

### Fixed
- Fixed single-user report limitation.
- Fixed token 400 error issue.
- Fixed duplicate/incorrect report display.
- Fixed admin routing path issue.
- Fixed Docker database connection issue.
- Fixed passenger selection not appearing in report table.
## [2.0.0] - 2026-03-03 - Wisit_2348

### Added
- Added automated API tests for the report module.

### Changed
- Reorganized project documentation files for better structure and maintainability.

### Fixed
- Fixed bugs related to the report system.

## [2.0.0] - 2026-03-03 - Wisit_2348

### Added

- Added automated API tests for the report module.
- Added A-DAPT Blueprint FOR SPRINT 2

### Changed

- Reorganized project documentation files for better structure and maintainability.

### Fixed

- Fixed bugs related to the report system.

---

## [2.0.0] - 2026-03-03 - Kanyapat_5037

### Added

- Added Admin Ban Report Robot
- Added Admin Reject Report Robot
- Added Passenger Report Robot
- Added Passenger Detail Report Robot
- Added Baned User Checked Robot

---

## [3.0.0] - 2026-03-14 - Phakorn_2160

### Added

- Added trip completion endpoint `PATCH /api/routes/:id/complete` for drivers.
- Added `src/services/reviewEligibility.service.js` with `validateTripCompletedBeforeReview(bookingId)` to enforce completed-trip review validation.
- Added review system schema design document `doc/Sprint3/ReviewSystemSchemaDesign.md` for team implementation alignment.

### Changed

- Updated route completion flow in `route.service.js` and `route.controller.js` to set route status to `COMPLETED`, notify passengers, and write audit logs.
- Updated route API docs in `src/docs/route.doc.js` to include `PATCH /api/routes/{id}/complete`.

---

## [3.0.0] - 2026-03-14 - Yodsanon_0215

### Added

- **Incident Report System**: Added a complete incident reporting system.
- **Route Participants API**: Added an API to fetch the list of passengers or the driver in a route, excluding the current user.
- **API Tests**: Added API test sets for both the Incident Report and Route Participants systems.

### Changed

- **Report System Refactoring**: Completely refactored and fixed the entire existing Report system (schema relations, status logic, and error handling).

---

## [3.0.0] - 2026-03-15 - Yodsanon_0215

### Added

- **Report System**: Added a get by routeID.

---

## [3.0.0] - 2026-03-14 - Thanawat_2128

### Added

- **Review System**: Added a Review System api to backend
- **API Tests**: Postman API Tests for Review System

### Changed

- **Prisma Schema**: Modified Prisma Schema to be compatible with Review System

### Fixed

- Fix conflicts on rebasing main branch

## [3.0.0] - 2026-03-15 - Yodsanon_0215

### Added

- **Report System**: Added a get by routeID.

---

## [3.0.0] - 2026-03-15 - Wisit_2348

### Added

- Trip-based report view showing route, date, and report count per trip
- Evidence management: image preview before upload, pagination, timestamps, pending deletion

### Changed

- Improved evidence card display with upload timestamps
- Increased visibility of report titles and status badges
- Updated Passenger Report UX/UI to enable report creation based on the trip where the incident occurred

### Fixed

- Fixed Prisma query issue with invalid `orderBy`

### Misc

- Added `formatDateTime()` utility for compact timestamp formatting

---

## [3.0.0] - 2026-03-15 - Wisit_2348

### Added

- Trip-based report view showing route, date, and report count per trip
- Evidence management: image preview before upload, pagination, timestamps, pending deletion

### Changed

- Improved evidence card display with upload timestamps
- Increased visibility of report titles and status badges
- Updated Passenger Report UX/UI to enable report creation based on the trip where the incident occurred

### Fixed

- Fixed Prisma query issue with invalid `orderBy`

### Misc

- Added `formatDateTime()` utility for compact timestamp formatting

---

## Version Guidelines

### Categories

- **Added**: New features

- **Changed**: Changes in existing functionality

- **Deprecated**: Soon-to-be removed features

- **Removed**: Removed features

- **Fixed**: Bug fixes

- **Security**: Security improvements

- **Miscellaneous**: Explain what's been done

---

## [3.0.0] - 2026-03-15 - Nattaphat_0126

### Added

* **Driver Report System**: Added the ability for drivers to report passengers directly from the "My Routes" and "Booking Requests" tabs.
* **Evidence Management for Drivers**: Implemented a report form modal supporting image and video uploads, accurately tracking `mimeType` and `fileSize` to ensure correct rendering on the Admin Dashboard.
* **Real-time Report State**: Implemented `reportedCasesSet` to fetch and store user report history on mount, immediately changing the UI button to "รายงานไปแล้ว" to prevent duplicate reporting.

### Changed

* **Report Creation Logic**: Refactored `createReportCase` in `report.service.js` to distinguish between roles. Drivers can now report multiple different passengers within the same trip, while passengers remain restricted to one report per trip.

### Fixed

* **Admin Booking CORS Issue**: Resolved a Cross-Origin Resource Sharing (CORS) error in the Admin Dashboard by replacing a hardcoded production URL with the `config.public.apiBase` environment variable.

---

## Links

---
