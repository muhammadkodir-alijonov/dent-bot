#!/bin/bash

# Production Deployment Script for Dental Clinic
# Run this on your production server

set -e

echo "🚀 Starting production deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="stom.muhammadqodir.com"
EMAIL="muhammadkodir.alijonov@gmail.com"
PROJECT_DIR="/home/$(whoami)/dent-bot"

echo -e "${BLUE}📋 Production Deployment Configuration:${NC}"
echo -e "Domain: ${YELLOW}${DOMAIN}${NC}"
echo -e "Email: ${YELLOW}${EMAIL}${NC}"
echo -e "Project Directory: ${YELLOW}${PROJECT_DIR}${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ This script should NOT be run as root for security reasons${NC}"
   exit 1
fi

# Check required commands
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        exit 1
    fi
}

echo -e "${BLUE}🔍 Checking requirements...${NC}"
check_command docker
check_command docker-compose
check_command git

# Create project directory if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}📁 Creating project directory...${NC}"
    mkdir -p "$PROJECT_DIR"
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Clone or update repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📥 Cloning repository...${NC}"
    git clone https://github.com/muhammadkodir-alijonov/dent-bot.git .
else
    echo -e "${YELLOW}🔄 Updating repository...${NC}"
    git pull origin main
fi

# Check if .env.prod exists
if [ ! -f ".env.prod" ]; then
    echo -e "${RED}❌ .env.prod file not found!${NC}"
    echo -e "${YELLOW}Please create .env.prod with production settings${NC}"
    echo -e "You can copy from .env.prod.example and modify it"
    exit 1
fi

# Verify SSL/Domain configuration
echo -e "${BLUE}🔒 SSL Configuration${NC}"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
read -p "Are these settings correct? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please update domain settings in this script${NC}"
    exit 1
fi

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose --env-file .env.prod -f docker-compose.prod.yml down || true

# Remove old images (optional, saves space)
read -p "🗑️  Remove old Docker images to save space? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
fi

# Build and start services
echo -e "${BLUE}🏗️  Building and starting services...${NC}"
docker-compose --env-file .env.prod -f docker-compose.prod.yml up --build -d

# Wait for services to start
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 30

# Check service health
echo -e "${BLUE}🏥 Checking service health...${NC}"

# Check database
if docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T db pg_isready -U dental_prod_user -d dental_clinic_prod; then
    echo -e "${GREEN}✅ Database is running${NC}"
else
    echo -e "${RED}❌ Database is not ready${NC}"
    echo "Checking logs:"
    docker-compose --env-file .env.prod -f docker-compose.prod.yml logs db
fi

# Check backend
if curl -f http://localhost:3000/health &> /dev/null; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is not ready${NC}"
    echo "Checking logs:"
    docker-compose --env-file .env.prod -f docker-compose.prod.yml logs backend
fi

# Check nginx
if curl -f http://localhost:80 &> /dev/null; then
    echo -e "${GREEN}✅ Nginx is running${NC}"
else
    echo -e "${RED}❌ Nginx is not ready${NC}"
    echo "Checking logs:"
    docker-compose --env-file .env.prod -f docker-compose.prod.yml logs nginx
fi

# SSL Certificate setup
echo -e "${BLUE}🔐 Setting up SSL certificates...${NC}"
echo "This will set up Let's Encrypt SSL for $DOMAIN"

# Initial certificate request (first time only)
if [ ! -d "./certbot/conf/live/$DOMAIN" ]; then
    echo -e "${YELLOW}📜 Requesting initial SSL certificate...${NC}"
    
    # Create temporary nginx config for certificate challenge
    docker-compose --env-file .env.prod -f docker-compose.prod.yml exec nginx \
        certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SSL certificate obtained successfully${NC}"
    else
        echo -e "${RED}❌ Failed to obtain SSL certificate${NC}"
        echo -e "${YELLOW}Make sure:${NC}"
        echo "1. Domain $DOMAIN points to this server"
        echo "2. Ports 80 and 443 are accessible"
        echo "3. No firewall is blocking the ports"
    fi
else
    echo -e "${GREEN}✅ SSL certificate already exists${NC}"
fi

# Setup automatic SSL renewal
echo -e "${BLUE}🔄 Setting up automatic SSL renewal...${NC}"

# Create renewal script
cat > ssl-renew.sh << 'EOF'
#!/bin/bash
cd /home/$(whoami)/dent-bot
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T certbot certbot renew --nginx
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T nginx nginx -s reload
EOF

chmod +x ssl-renew.sh

# Add to crontab (runs twice daily)
(crontab -l 2>/dev/null; echo "0 12 * * * $PROJECT_DIR/ssl-renew.sh") | crontab -

echo -e "${GREEN}✅ SSL renewal cron job added${NC}"

# Show final status
echo -e "\n${GREEN}🎉 Deployment completed!${NC}"
echo -e "\n${BLUE}📊 Service Status:${NC}"
docker-compose --env-file .env.prod -f docker-compose.prod.yml ps

echo -e "\n${BLUE}🌐 Access URLs:${NC}"
echo -e "HTTP: ${YELLOW}http://$DOMAIN${NC}"
echo -e "HTTPS: ${YELLOW}https://$DOMAIN${NC}"
echo -e "Admin: ${YELLOW}https://$DOMAIN/admin${NC}"

echo -e "\n${BLUE}🔧 Management Commands:${NC}"
echo -e "View logs: ${YELLOW}docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f${NC}"
echo -e "Stop: ${YELLOW}docker-compose --env-file .env.prod -f docker-compose.prod.yml down${NC}"
echo -e "Restart: ${YELLOW}docker-compose --env-file .env.prod -f docker-compose.prod.yml restart${NC}"

echo -e "\n${GREEN}🚀 Dental clinic application is now running in production!${NC}"