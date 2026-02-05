FROM node:22-slim AS builder
WORKDIR /app
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
COPY react/package.json react/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY react/ ./
RUN pnpm run build

FROM nginx:alpine AS runner
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]