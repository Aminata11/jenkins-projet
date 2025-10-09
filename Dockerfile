# Étape 1 : Build React
FROM node:20-alpine as build
WORKDIR /app
COPY package*.json ./
ENV npm_config_network_retry 5
ENV npm_config_fetch_retries 5
ENV npm_config_fetch_retry_maxtimeout 60000
ENV npm_config_strict_ssl false
RUN npm config delete proxy && npm config delete https-proxy && npm config set registry https://registry.npmjs.org/ && npm install --no-audit --legacy-peer-deps
RUN npm install
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build


# Étape 2 : Servir avec Nginx
FROM nginx:stable-alpine
COPY --from=build /app /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
