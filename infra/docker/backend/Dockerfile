FROM node:20-alpine

WORKDIR /app/backend

# Dépendances système pour SQLite
RUN apk add --no-cache python3 make g++ bash

# Copier package.json et installer deps
COPY ../../backend/package*.json ./
RUN npm install -g pino-pretty
RUN npm install

# Créer dossier pour DB
RUN mkdir -p ./data

# Copier le code TS
COPY ../../backend/src ./src
COPY ../../backend/tsconfig.json ./

EXPOSE 3000

CMD ["npx", "tsx", "src/main.ts"]
