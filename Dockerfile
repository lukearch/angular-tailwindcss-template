FROM node:21-alpine as base

FROM base as deps

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* ./

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  else echo "Lockfile not found."; exit 1; \
  fi

FROM base as builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN \
  if [-f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  else echo "Lockfile not found."; exit 1; \
  fi

FROM base as runner

WORKDIR /app

COPY --from=builder /app/dist ./dist

EXPOSE 4000

CMD ["node", "dist/your-project-name/server/server.mjs"]