#!/bin/bash
# SSL Certificate Setup with Let's Encrypt

DOMAIN="muhammadqodir.com"
EMAIL="admin@muhammadqodir.com"

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
        server_name $DOMAIN www.$DOMAIN;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://\$host\$request_uri;
        }
    }
}
EOF

echo "📁 Created temporary nginx config..."

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
  -d $DOMAIN \
  -d www.$DOMAIN

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