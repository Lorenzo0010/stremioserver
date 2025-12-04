FROM alpine:3.20

# Installa dipendenze
RUN apk add --no-cache \
    nginx \
    openssl \
    nodejs \
    npm \
    curl \
    tar \
    && rm -rf /var/cache/apk/*

# Crea directory
RUN mkdir -p /etc/nginx/ssl /root/.stremio-server /app

# Copia nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Genera certificati self-signed
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/stremio.key \
    -out /etc/nginx/ssl/stremio.crt \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1" \
    && chmod 644 /etc/nginx/ssl/stremio.*

# Installa Stremio Server (URL STABILE)
WORKDIR /app
RUN curl -L https://github.com/Stremio/server-docker/releases/download/v1.0.0/stremio-server.tar.gz | tar xz \
    && mv stremio-server/* . \
    && rm -rf stremio-server *.tar.gz \
    && chmod +x start.sh || \
    (curl -L https://github.com/Stremio/stremio-service/releases/download/v1.6.0/server-linux-x64.tar.gz | tar xz \
    && mv server-linux-x64/* . \
    && rm -rf server-linux-x64 *.tar.gz \
    && chmod +x start.sh)

# Configura NGINX per porta 12470 HTTPS
RUN sed -i 's|listen 80;|listen 12470 ssl http2;|' /etc/nginx/conf.d/default.conf

# Espone porta
EXPOSE 12470

# Avvia entrambi i servizi
CMD nginx -g "daemon off;" & sleep 5 && cd /app && ./start.sh
