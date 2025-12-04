FROM alpine:3.20

RUN apk add --no-cache nginx openssl nodejs npm curl tar

RUN mkdir -p /etc/nginx/ssl /root/.stremio-server /app

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/stremio.key \
    -out /etc/nginx/ssl/stremio.crt \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1" \
    && chmod 644 /etc/nginx/ssl/stremio.*

WORKDIR /app

# Scarica e unpack Stremio - sistema per scompattare senza sottocartella
RUN curl -L https://github.com/Stremio/stremio-service/releases/download/v1.6.0/server-linux-x64.tar.gz | tar -xz --strip-components=1 \
    && chmod +x start.sh

RUN sed -i 's|listen 80;|listen 12470 ssl http2;|' /etc/nginx/conf.d/default.conf

EXPOSE 12470

CMD nginx -g "daemon off;" & sleep 5 && ./start.sh
