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

### Technical Details

- Log Levels automatically determined by status code (INFO: 2xx, WARN: 4xx, ERROR: 5xx)
- Excluded Paths `/health`, `/metrics`, `/documentation` skipped to reduce noise
- Non-blocking Database writes use fire-and-forget pattern to avoid impacting request latency
- Graceful Failure DB write failures log to console but never crash the application

### Post-Deployment

Run migration to create SystemLog table:
```bash
docker compose exec backend npx prisma migrate dev --name add_system_log
```

---

## Version Guidelines

### Categories

- **Added**: New features

- **Changed**: Changes in existing functionality

- **Deprecated**: Soon-to-be removed features

- **Removed**: Removed features

- **Fixed**: Bug fixes

- **Security**: Security improvements

---

## Links

---
