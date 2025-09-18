# Etapa 1: Build Angular
FROM node:20-bullseye AS build

WORKDIR /app

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# Copiar package.json y package-lock.json
COPY package*.json ./
RUN npm install

# Copiar el resto del proyecto
COPY . .

# Build producción Angular con baseHref=/ para servir desde la raíz
RUN npx ng build eCommerce --configuration production

# Verificar que el build se generó correctamente
RUN ls -la /app/dist/eCommerce

# Etapa 2: Servir con Nginx
FROM nginx:alpine

# Limpiar HTML por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar build Angular al root de Nginx
COPY --from=build /app/dist/eCommerce/* /usr/share/nginx/html/

# Copiar nginx.conf personalizado
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
