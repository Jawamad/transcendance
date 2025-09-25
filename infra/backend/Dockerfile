FROM node:20-alpine

WORKDIR /app/backend

# Dépendances système pour SQLite
RUN apk add --no-cache python3 make g++ bash

# Copier package.json et installer deps
COPY ./infra/backend/conf/package*.json ./
RUN npm install -g pino-pretty
RUN npm install

# Copier tsconfig + code source
COPY ./infra/backend/conf/tsconfig.json ./
COPY ./backend/src ./src

# Compiler TS → JS
RUN npx tsc

# Créer dossier pour DB
RUN mkdir -p ./data

EXPOSE 3000

# Lancer le JS compilé
CMD ["node", "dist/main.js"]
