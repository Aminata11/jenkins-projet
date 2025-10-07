# -----------------------------
# Étape 1 : Construction de l'application React
# -----------------------------
FROM node:20-alpine AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers nécessaires à l'installation
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du projet
COPY . .

# Définir une variable d'environnement pour l'API (si utilisée dans Vite)
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Construire l'application React (le dossier /app/build sera créé)
RUN npm run build


# -----------------------------
# Étape 2 : Servir avec Nginx
# -----------------------------
FROM nginx:stable-alpine

# Copier les fichiers construits depuis l'étape précédente
COPY --from=build /app/build /usr/share/nginx/html

# Exposer le port HTTP
EXPOSE 80

# Lancer Nginx en mode premier plan
CMD ["nginx", "-g", "daemon off;"]

