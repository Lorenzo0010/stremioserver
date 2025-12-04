FROM stremio/server:latest

# Installa NGINX su base esistente (usa apk se disponibile, altrimenti apt)
USER root
RUN apk add --no-cache nginx openssl 2>/dev/null || \
    apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/* || \
    echo "No package manager found, skipping NGINX install"

# Crea SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copia nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Genera certificati self-signed
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/stremio.key \
    -out /etc/nginx/ssl/stremio.crt \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1" \
    && chmod 644 /etc/nginx/ssl/stremio.*

# Configura NGINX per HTTPS 12470
RUN sed -i 's|listen 80;|listen 12470 ssl http2;|' /etc/nginx/conf.d/default.conf || \
    echo "listen 12470 ssl http2;" >> /etc/nginx/conf.d/default.conf

# Espone porta HTTPS
EXPOSE 12470

# Avvia NGINX + Stremio originale
CMD nginx -g "daemon off;" & /start.sh
