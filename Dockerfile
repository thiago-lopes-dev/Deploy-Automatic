# ========================================================
# STAGE 1: Base & Dependencies
# ========================================================
FROM node:20-alpine AS base

WORKDIR /app
COPY package*.json ./

# Install only production dependencies for the final image
RUN npm ci --only=production && \
    cp -R node_modules prod_node_modules && \
    npm ci

# ========================================================
# STAGE 2: Build/Test
# ========================================================
FROM base AS builder
COPY . .
# Roda testes se existirem
RUN npm test --if-present

# ========================================================
# STAGE 3: Production Image
# ========================================================
FROM node:20-alpine

LABEL org.opencontainers.image.source="https://github.com/seu-usuario/seu-repo"
LABEL org.opencontainers.image.description="API Sistema - Produção"

ENV NODE_ENV=production
WORKDIR /app

# Usuário não-root por segurança
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copia apenas o necessário do stage anterior
COPY --from=base /app/prod_node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

# Healthcheck interno
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["npm", "start"]
