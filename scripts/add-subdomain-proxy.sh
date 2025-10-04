#!/bin/bash

echo "🔧 Blog nginx'iga stom subdomain qo'shish..."

# Blog nginx konteynerini topish
BLOG_NGINX_CONTAINER=$(docker ps --format "{{.Names}}" | grep nginx | head -1)

if [ -z "$BLOG_NGINX_CONTAINER" ]; then
    echo "❌ Nginx konteyneri topilmadi!"
    exit 1
fi

echo "📋 Blog nginx konteyneri: $BLOG_NGINX_CONTAINER"

# Proxy konfiguratsiyasini hosil qilish
cat > /tmp/stom-proxy.conf << 'EOF'
# Stom subdomain proxy configuration
server {
    listen 80;
    server_name stom.muhammadqodir.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Konfiguratsiyani konteynarga nusxalash
docker cp /tmp/stom-proxy.conf $BLOG_NGINX_CONTAINER:/etc/nginx/conf.d/stom-proxy.conf

# Nginx konfiguratsiyasini tekshirish
echo "🧪 Nginx konfiguratsiyasini tekshirish..."
if docker exec $BLOG_NGINX_CONTAINER nginx -t; then
    echo "✅ Konfiguratsiya to'g'ri"
    
    # Nginx'ni reload qilish
    echo "🔄 Nginx'ni reload qilish..."
    docker exec $BLOG_NGINX_CONTAINER nginx -s reload
    echo "✅ Nginx reload tugadi"
    
    echo ""
    echo "🌐 Endi stom.muhammadqodir.com ishlashi kerak!"
    echo "Test qiling: curl -I http://stom.muhammadqodir.com/"
else
    echo "❌ Nginx konfiguratsiyasida xatolik!"
fi

# Temp faylni o'chirish
rm -f /tmp/stom-proxy.conf