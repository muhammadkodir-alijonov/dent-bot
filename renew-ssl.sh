#!/bin/bash

# SSL Certificate Renewal Script

set -e

echo "🔄 Renewing SSL certificates..."

# Load production environment
if [ -f .env.prod ]; then
    export $(cat .env.prod | grep -v '^#' | xargs)
fi

# Renew certificates
docker-compose -f docker/docker-compose.prod.yml --profile ssl-renew up certbot-renew

if [ $? -eq 0 ]; then
    echo "✅ SSL certificates renewed successfully"
    
    # Reload nginx to use new certificates
    echo "🔄 Reloading nginx..."
    docker-compose -f docker/docker-compose.prod.yml exec nginx nginx -s reload
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx reloaded successfully"
    else
        echo "⚠️ Failed to reload nginx, please check manually"
    fi
else
    echo "⚠️ Certificate renewal failed or not needed"
fi

echo "📅 Next renewal check will be in 12 hours"