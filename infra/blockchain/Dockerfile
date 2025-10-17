# Utilise Node 20 pour ESM + Hardhat 3
FROM node:22-alpine

WORKDIR /app

# Copier package.json et package-lock.json pour installer les dépendances
COPY package*.json ./
#RUN npm ci
RUN npm install --legacy-peer-deps



# Copier le reste du code Hardhat
COPY . .

#RUN npx hardhat compile

# Lancer Hardhat directement (pas de tsx)
CMD ["npx", "hardhat", "node"]
