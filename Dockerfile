# Build stage
FROM node:20-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# Install certbot and dependencies
RUN apk add --no-cache certbot curl openssl

# Create directories for SSL
RUN mkdir -p /etc/nginx/ssl /var/www/certbot

# Copy SSL configuration
COPY nginx-ssl.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Generate self-signed certificate for initial setup
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Copy SSL renewal script
COPY ssl/ssl-renew.sh /etc/periodic/daily/ssl-renew
RUN chmod +x /etc/periodic/daily/ssl-renew

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Expose ports
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]