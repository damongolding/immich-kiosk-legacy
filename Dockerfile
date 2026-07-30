# ---- Stage 1: Build with Node ----
FROM node:26 AS build

WORKDIR /app

COPY . .

RUN npm ci

RUN npm run build

# ---- Stage 2: Runtime with Caddy ----
FROM caddy:2-alpine AS runtime

RUN apk add --no-cache jq

# Copy built Vite assets
COPY --from=build /app/dist /srv

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Copy the env-inject script and set it as the entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
