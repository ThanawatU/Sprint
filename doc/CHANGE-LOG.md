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

### Changed

- Modify auth.controller.js to audit users Login and Password change activity

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
