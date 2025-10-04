#!/bin/bash

# Tez Production Deployment Script
# Muammolarni tezda hal qilish uchun

set -e

echo "🚀 Tez production deployment boshlandi..."

# Ranglar
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Hozirgi katalogdan ishlash
echo -e "${BLUE}📁 Hozirgi katalog: $(pwd)${NC}"

# 1. Barcha Docker konteynerlarni to'xtatish
echo -e "${YELLOW}🛑 Barcha Docker konteynerlarni to'xtatish...${NC}"
docker stop $(docker ps -q) 2>/dev/null || true

# 2. .env.prod mavjudligini tekshirish
if [ ! -f ".env.prod" ]; then
    echo -e "${RED}❌ .env.prod fayli topilmadi!${NC}"
    echo -e "${YELLOW}Avval .env.prod faylini yarating${NC}"
    exit 1
fi

# 3. Docker-compose fayl mavjudligini tekshirish
if [ ! -f "docker-compose.prod.yml" ]; then
    echo -e "${RED}❌ docker-compose.prod.yml fayli topilmadi!${NC}"
    echo -e "${YELLOW}Loyiha katalogiga o'ting${NC}"
    exit 1
fi

# 4. Production konteynerlarni ishga tushirish
echo -e "${BLUE}🚀 Production konteynerlarni ishga tushirish...${NC}"
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --build

# 5. Servislar holatini tekshirish
echo -e "${YELLOW}⏳ Servislar ishga tushishini kutish (30 sekund)...${NC}"
sleep 30

# 6. Holatni tekshirish
echo -e "${BLUE}🏥 Servislar holatini tekshirish...${NC}"

# Database tekshirish
if docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T db pg_isready -U dental_prod_user -d dental_clinic_prod; then
    echo -e "${GREEN}✅ Database ishlamoqda${NC}"
else
    echo -e "${RED}❌ Database ishlamayapti${NC}"
fi

# Backend tekshirish
if curl -f http://localhost:3000/health &> /dev/null; then
    echo -e "${GREEN}✅ Backend ishlamoqda${NC}"
else
    echo -e "${RED}❌ Backend ishlamayapti${NC}"
    echo "Backend logs:"
    docker-compose --env-file .env.prod -f docker-compose.prod.yml logs --tail=20 backend
fi

# Nginx tekshirish
if curl -f http://localhost/ &> /dev/null; then
    echo -e "${GREEN}✅ Nginx ishlamoqda${NC}"
else
    echo -e "${RED}❌ Nginx ishlamayapti${NC}"
    echo "Nginx logs:"
    docker-compose --env-file .env.prod -f docker-compose.prod.yml logs --tail=20 nginx
fi

echo ""
echo -e "${GREEN}✅ Deployment tugadi!${NC}"
echo -e "${BLUE}Sayt: http://localhost/${NC}"
echo -e "${BLUE}Backend API: http://localhost:3000/${NC}"
echo ""
echo -e "${YELLOW}Loglarni ko'rish uchun:${NC}"
echo "docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f"
echo ""
echo -e "${YELLOW}Konteynerlarni to'xtatish uchun:${NC}"
echo "docker-compose --env-file .env.prod -f docker-compose.prod.yml down"