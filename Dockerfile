# -----------------------------
# Étape 1 : Build du projet Vite + React
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

# Définir la variable d'environnement si nécessaire
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Construire le projet (Vite génère le dossier /app/dist)
RUN npm run build && ls -l /app/dist


# -----------------------------
# Étape 2 : Servir les fichiers statiques avec Nginx
# -----------------------------
FROM nginx:stable-alpine

# Copier les fichiers du dossier dist dans le répertoire web de Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Démarrer Nginx en premier plan
CMD ["nginx", "-g", "daemon off;"]
