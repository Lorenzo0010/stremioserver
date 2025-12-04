FROM alpine:3.20

# Installa NGINX, OpenSSL e dipendenze Stremio
RUN apk add --no-cache \
    nginx \
    openssl \
    nodejs \
    npm \
    curl \
    && rm -rf /var/cache/apk/*

# Crea directory necessarie
RUN mkdir -p /etc/nginx/ssl /root/.stremio-server /app

# Copia nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Genera certificati self-signed automaticamente
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/stremio.key \
    -out /etc/nginx/ssl/stremio.crt \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1" \
    && chmod 644 /etc/nginx/ssl/stremio.*

# Scarica e installa Stremio Server
WORKDIR /app
RUN curl -L https://github.com/Stremio/stremio-service/releases/latest/download/server-linux-x64.tar.gz | tar xz \
    && mv server-linux-x64/* . \
    && rm -rf server-linux-x64 *.tar.gz \
    && chmod +x start.sh

# Configura NGINX per HTTPS porta 12470
RUN sed -i 's|listen 80;|listen 12470 ssl http2;|' /etc/nginx/conf.d/default.conf

# Espone porta HTTPS
EXPOSE 12470

# Avvia NGINX + Stremio
CMD nginx -g "daemon off;" & /app/start.sh
