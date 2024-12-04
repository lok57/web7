#!/bin/sh

# Create required directories
mkdir -p docker/nginx/ssl \
         docker/nginx/certbot/www \
         docker/nginx/certbot/conf

# Set proper permissions
chmod -R 755 docker/nginx/ssl docker/nginx/certbot

# Generate self-signed certificate for development
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout docker/nginx/ssl/localhost.key \
    -out docker/nginx/ssl/localhost.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

echo "SSL setup completed successfully!"