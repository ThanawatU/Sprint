# =============================================================================
# Backend Dockerfile - Express.js with Prisma & PostgreSQL
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Dependencies
# -----------------------------------------------------------------------------
FROM node:20-alpine AS deps

# Install build dependencies for native modules (bcrypt)
RUN apk add --no-cache python3 make g++ 

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./
COPY prisma ./prisma/

# Install all dependencies (including devDependencies for prisma)
RUN npm ci

# Generate Prisma Client
RUN npx prisma generate

# -----------------------------------------------------------------------------
# Stage 2: Production dependencies only
# -----------------------------------------------------------------------------
FROM node:20-alpine AS prod-deps

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package.json package-lock.json ./
COPY prisma ./prisma/

# Install production dependencies only
RUN npm ci --omit=dev

# Generate Prisma Client for production
RUN npx prisma generate

# -----------------------------------------------------------------------------
# Stage 3: Production runtime
# -----------------------------------------------------------------------------
FROM node:20-alpine AS runner

# Add labels for better container management
LABEL maintainer="Pai Nam Nae Team"
LABEL description="Backend API for Pai Nam Nae ride-sharing application"

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 expressjs

WORKDIR /app

# Copy production dependencies
COPY --from=prod-deps /app/node_modules ./node_modules

# Copy Prisma schema and generated client
COPY --from=prod-deps /app/prisma ./prisma
COPY --from=prod-deps /app/node_modules/.prisma ./node_modules/.prisma

# Copy application source
COPY --chown=expressjs:nodejs . .

# Remove unnecessary files
RUN rm -rf .env .env.* .git .gitignore *.md

# Switch to non-root user
USER expressjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Default command
CMD ["node", "server.js"]
