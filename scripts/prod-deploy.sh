#!/bin/bash

echo "🚀 Dental Clinic Production Deployment (Port 8080)"
echo "=================================================="

# Loyiha katalogiga o'tish
cd /root/project/dent-bot

# Eski konteynerlarni to'xtatish
echo "🛑 Eski dental clinic konteynerlarni to'xtatish..."
docker-compose --env-file .env.prod -f docker-compose.prod.yml down 2>/dev/null || true

# Production'ni ishga tushirish
echo "🚀 Production konteynerlarni ishga tushirish..."
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --build

# Kutish
echo "⏳ Servislar ishga tushishini kutish (10 sekund)..."
sleep 10

# Test qilish
echo ""
echo "🧪 Servislarni test qilish:"
echo "=========================="

# Database test
if docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T db pg_isready -U dental_prod_user -d dental_clinic_prod; then
    echo "✅ Database (port 5433): OK"
else
    echo "❌ Database: FAIL"
fi

# Backend test
if curl -f http://localhost:3000/health &> /dev/null; then
    echo "✅ Backend API (port 3000): OK"
else
    echo "❌ Backend API: FAIL"
fi

# Web sayt test
if curl -f http://localhost:8080/ &> /dev/null; then
    echo "✅ Web Sayt (port 8080): OK"
else
    echo "❌ Web Sayt: FAIL"
fi

echo ""
echo "🌐 Access URL'lar:"
echo "=================="
echo "Web Sayt: http://stom.muhammadqodir.com/"
echo "Backend API: http://stom.muhammadqodir.com:3000/"
echo "Admin Panel: http://stom.muhammadqodir.com/admin"
echo ""
echo "📊 Ishlab turgan konteynerlar:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep dent-bot

echo ""
echo "✅ Production deployment tugadi!"