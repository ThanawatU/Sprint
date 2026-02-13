# Docker Setup Guide

Quick start guide for running Pai Nam Nae with Docker naja.

## Prerequisites

- Docker 24+
- Docker Compose v2+

## Quick Start

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Edit .env with actual values (required: JWT_SECRET, GOOGLE_MAPS keys, Cloudinary)

# 3. Start all services
docker compose up -d

# 4. Run database migrations (first time only)
docker compose run --rm migrate

# 5. View logs
docker compose logs -f
```

## Services

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3001 | http://localhost:3001 |
| Backend API | 3000 | http://localhost:3000 |
| API Docs | 3000 | http://localhost:3000/documentation |
| PostgreSQL | 5432 | localhost:5432 |

## Common Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Stop and remove volumes (this deletes database btw)
docker compose down -v

# Rebuild after code changes
docker compose build --no-cache
docker compose up -d

# View logs
docker compose logs -f backend
docker compose logs -f frontend

# Run Prisma commands
docker compose exec backend npx prisma studio
docker compose exec backend npx prisma migrate dev

# Access database
docker compose exec postgres psql -U pnn_user -d pnn_db
```

## Development Mode

For development with hot-reload, use the override file:

```bash
# Create docker-compose.override.yml for dev overrides
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```

## Troubleshooting

**Database connection refused:**
```bash
# Wait for postgres to be healthy
docker compose ps
# Should show postgres as "healthy"
```

**Migrations not applied:**
```bash
docker compose run --rm migrate
```

**Prisma client mismatch:**
```bash
docker compose exec backend npx prisma generate
docker compose restart backend
```

**Fresh start:**
```bash
docker compose down -v
docker compose up -d
docker compose run --rm migrate
```
