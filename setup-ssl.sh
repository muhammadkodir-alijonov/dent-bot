#!/bin/bash
# SSL Certificate Setup with Let's Encrypt for Dental Clinic

DOMAIN="stom.muhammadqodir.com"
EMAIL="muhammadkodir.alijonov@gmail.com"

echo "🔒 Setting up SSL certificates for $DOMAIN..."

# Create directories
mkdir -p ./certbot/conf
mkdir -p ./certbot/www

# Create initial nginx config for certificate challenge
cat > nginx.ssl-init.conf << EOF
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name $DOMAIN;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 404;
        }
    }
}
EOF

echo "📁 Created temporary nginx config..."

# Stop any existing containers on port 80
echo "🛑 Stopping containers on port 80..."
docker ps --format "table {{.ID}}\t{{.Ports}}" | grep "0.0.0.0:80" | awk '{print $1}' | xargs -r docker stop || true

# Run nginx with temporary config
docker run --rm -d \
  --name nginx-ssl-init \
  -p 80:80 \
  -v $(pwd)/nginx.ssl-init.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/certbot/www:/var/www/certbot:ro \
  nginx:alpine

echo "🌐 Started temporary nginx server..."

# Get SSL certificate
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN

# Stop temporary nginx
docker stop nginx-ssl-init

echo "✅ SSL certificate obtained!"
echo "📝 Update your docker-compose.prod.yml to mount certificate volumes:"
echo ""
echo "volumes:"
echo "  - ./certbot/conf:/etc/letsencrypt:ro"
echo "  - ./certbot/www:/var/www/certbot:ro"
echo ""
echo "🔄 Now you can start production with SSL!"