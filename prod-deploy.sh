#!/bin/bash

# Production Deployment Script

set -e

echo "🚀 Deploying Dental Clinic to Production..."

# Check if .env.prod exists
if [ ! -f .env.prod ]; then
    echo "❌ .env.prod file not found!"
    echo "Please copy .env.prod.example to .env.prod and configure your production settings"
    exit 1
fi

echo "🔍 Checking port availability..."

# Check if ports are available
if ss -tln | grep -q ":80 "; then
    echo "⚠️  Warning: Port 80 is already in use"
    ss -tlnp | grep :80
fi

if ss -tln | grep -q ":3000 "; then
    echo "❌ Error: Port 3000 is already in use"
    echo "Please stop the service using port 3000 or change the port in docker-compose files"
    ss -tlnp | grep :3000
    exit 1
fi

if ss -tln | grep -q ":5433 "; then
    echo "❌ Error: Port 5433 is already in use"
    echo "Please stop the service using port 5433 or change the port in docker-compose files"
    ss -tlnp | grep :5433
    exit 1
fi

echo "✅ All required ports are available"

# Load production environment
export $(cat .env.prod | grep -v '^#' | xargs)

# Validate required environment variables
if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "CHANGE_THIS_STRONG_PASSWORD_IN_PRODUCTION" ]; then
    echo "❌ Please set a strong POSTGRES_PASSWORD in .env.prod"
    exit 1
fi

if [ -z "$SECRET_KEY" ] || [ "$SECRET_KEY" = "CHANGE_THIS_VERY_STRONG_SECRET_KEY_IN_PRODUCTION_32_CHARS_LONG" ]; then
    echo "❌ Please set a strong SECRET_KEY in .env.prod"
    exit 1
fi

if [ -z "$BOT_TOKEN" ] || [ "$BOT_TOKEN" = "YOUR_REAL_TELEGRAM_BOT_TOKEN_HERE" ]; then
    echo "❌ Please set your real BOT_TOKEN in .env.prod"
    exit 1
fi

if [ -z "$LETSENCRYPT_EMAIL" ] || [ "$LETSENCRYPT_EMAIL" = "your-email@domain.com" ]; then
    echo "❌ Please set your LETSENCRYPT_EMAIL in .env.prod"
    exit 1
fi

echo "🔒 Setting up SSL certificates..."

# First, get SSL certificate
docker-compose -f docker/docker-compose.prod.yml --profile ssl-setup up certbot

if [ $? -ne 0 ]; then
    echo "❌ Failed to obtain SSL certificate"
    echo "Make sure your domain stom.muhammadqodir.com points to this server"
    exit 1
fi

echo "📦 Building and starting production containers..."

# Stop any existing containers
docker-compose -f docker/docker-compose.prod.yml down

# Build and start services
docker-compose -f docker/docker-compose.prod.yml up --build -d

echo "⏳ Waiting for services to be ready..."
sleep 20

# Check if services are running
if docker-compose -f docker/docker-compose.prod.yml ps | grep -q "Up"; then
    echo "✅ Production environment is running!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   - Website: https://stom.muhammadqodir.com"
    echo "   - Admin: https://stom.muhammadqodir.com/admin"
    echo ""
    echo "📋 To view logs:"
    echo "   docker-compose -f docker/docker-compose.prod.yml logs -f"
    echo ""
    echo "🔄 To update SSL certificates:"
    echo "   docker-compose -f docker/docker-compose.prod.yml --profile ssl-renew up certbot-renew"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose -f docker/docker-compose.prod.yml down"
else
    echo "❌ Failed to start production environment"
    echo "Check logs: docker-compose -f docker/docker-compose.prod.yml logs"
    exit 1
fi

# Setup SSL renewal cron job
echo "⚙️ Setting up SSL certificate auto-renewal..."
(crontab -l 2>/dev/null; echo "0 12 * * * cd $(pwd) && docker-compose -f docker/docker-compose.prod.yml --profile ssl-renew up certbot-renew && docker-compose -f docker/docker-compose.prod.yml exec nginx nginx -s reload") | crontab -

echo "✅ SSL auto-renewal cron job added"