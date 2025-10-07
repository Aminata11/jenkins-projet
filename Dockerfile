# -----------------------------
# Étape 1 : Build du projet Vite + React
# -----------------------------
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Vite génère le dossier /app/dist
RUN npm run build 


# -----------------------------
# Étape 2 : Servir les fichiers statiques avec Nginx
# -----------------------------
FROM nginx:stable-alpine

# ❗ Correction ici : dist au lieu de build
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
