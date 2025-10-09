# Production Server Deployment Guide

## Server Requirements

### Minimum System Requirements

- **OS**: Ubuntu 20.04 LTS / 22.04 LTS yoki CentOS 7/8
- **RAM**: 2GB minimum (4GB tavsiya etiladi)
- **CPU**: 2 cores minimum
- **Disk**: 20GB minimum
- **Network**: Internet ulanishi va 80/443 portlar ochiq

### Required Software

- Docker 20.10+
- Docker Compose 2.0+
- Git
- Curl/Wget

## Quick Production Deployment

### 1. Server Tayyorlash

```bash
# System yangilash
sudo apt update && sudo apt upgrade -y

# Docker o'rnatish
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose o'rnatish
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout/login qiling yoki:
newgrp docker
```

### 2. Loyihani Klonlash

```bash
cd /home/$USER
git clone https://github.com/muhammadkodir-alijonov/dent-bot.git
cd dent-bot
```

### 3. Environment Konfiguratsiya

```bash
# Production environment yaratish
cp .env.prod.example .env.prod

# .env.prod ni tahrirlash
nano .env.prod
```

**MUHIM**: Quyidagi qiymatlarni o'zgartiring:

- `POSTGRES_PASSWORD` - Kuchli database paroli
- `SECRET_KEY` - Kuchli maxfiy kalit
- `BOT_TOKEN` - Telegram bot tokeni (ixtiyoriy)
- `ADMIN_PASSWORD` - Admin panel paroli
- `LETSENCRYPT_EMAIL` - SSL sertifikat uchun email
- `DOMAIN` - Sizning domeningiz

### 4. DNS Sozlash

Domeningizni serveringizga yo'naltiring:

```
A    stom.muhammadqodir.com    YOUR_SERVER_IP
```

### 5. Firewall Sozlash

```bash
# UFW firewall
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable

# Yoki iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### 6. Production Deploy

```bash
# Deployment script ishga tushirish
chmod +x scripts/prod-deploy.sh
./scripts/prod-deploy.sh
```

## Manual Deployment (Step by Step)

### 1. Konteynerlarni Ishga Tushirish

```bash
# Production muhitda ishga tushirish
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
```

### 2. SSL Sertifikat Olish

```bash
# Let's Encrypt SSL
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec nginx \
    certbot --nginx --non-interactive --agree-tos \
    --email YOUR_EMAIL -d YOUR_DOMAIN
```

### 3. SSL Auto-Renewal

```bash
# Crontab ga qo'shish
echo "0 12 * * * /home/$USER/dent-bot/scripts/ssl-renew.sh" | crontab -
```

## Service Management

### Logs Ko'rish

```bash
# Barcha loglar
docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f

# Ma'lum service logi
docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f backend
docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f nginx
docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f db
```

### Service Restart

```bash
# Barcha serviclarni restart
docker-compose --env-file .env.prod -f docker-compose.prod.yml restart

# Ma'lum serviceni restart
docker-compose --env-file .env.prod -f docker-compose.prod.yml restart backend
```

### Service Stop/Start

```bash
# To'xtatish
docker-compose --env-file .env.prod -f docker-compose.prod.yml down

# Ishga tushirish
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d
```

## Database Management

### Backup Yaratish

```bash
# Database backup
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec db \
    pg_dump -U dental_prod_user dental_clinic_prod > backup_$(date +%Y%m%d).sql
```

### Backup Qayta Tiklash

```bash
# Database restore
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T db \
    psql -U dental_prod_user -d dental_clinic_prod < backup_file.sql
```

## Monitoring & Maintenance

### System Resource Monitoring

```bash
# Docker stats
docker stats

# Service status
docker-compose --env-file .env.prod -f docker-compose.prod.yml ps

# Disk usage
df -h
# Production Deployment Guide (Step-by-Step)

## 1. Server tayyorlash

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl
# Docker o'rnatish
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Docker Compose o'rnatish
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
newgrp docker
```

## 2. Loyihani klonlash

```bash
git clone https://github.com/muhammadkodir-alijonov/dent-bot.git
cd dent-bot
```

## 3. Environment sozlash

```bash
cp .env.prod.example .env.prod
nano .env.prod
# (parollar, tokenlar, domen va emailni to'ldiring)
```

## 4. Docker Compose orqali ishga tushirish

```bash
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
```

## 5. SSL sertifikat o'rnatish (Let's Encrypt)

1. Nginx konteyneri to'liq ishga tushganini tekshiring:
    ```bash
    docker-compose --env-file .env.prod -f docker-compose.prod.yml ps
    ```
2. Certbot orqali SSL oling:
    ```bash
    docker-compose --env-file .env.prod -f docker-compose.prod.yml exec nginx \
      certbot --nginx --non-interactive --agree-tos \
      --email YOUR_EMAIL -d stom.muhammadqodir.com
    ```
3. Nginx konteynerini qayta ishga tushiring:
    ```bash
    docker-compose --env-file .env.prod -f docker-compose.prod.yml restart nginx
    ```

## 6. SSL auto-renewal (har 30 kunda yangilash)

```bash
crontab -e
# Pastga qo'shing:
0 3 */30 * * /home/$USER/dent-bot/scripts/ssl-renew.sh
```

## 7. Monitoring va servislarni boshqarish

```bash
# Loglar
docker-compose --env-file .env.prod -f docker-compose.prod.yml logs -f
# Servis status
docker-compose --env-file .env.prod -f docker-compose.prod.yml ps
# To'xtatish/ishga tushirish
docker-compose --env-file .env.prod -f docker-compose.prod.yml down
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d
```

## 8. Foydali buyruqlar

```bash
# Barcha konteynerlarni ko'rish
docker ps -a
# Disk usage
df -h
docker system df
# Docker volume va image tozalash
docker system prune -f --volumes
```

## 9. Muammolar va troubleshooting

- Nginx yoki backend loglarini tekshiring
- Portlar band bo'lsa: `sudo lsof -i :80` yoki `sudo lsof -i :443`
- SSL xatoliklari: sertifikat yo'li va domen nomini tekshiring
- Database xatolari: `docker-compose ... logs db`

## 10. Asosiy URLlar

- https://stom.muhammadqodir.com
- https://stom.muhammadqodir.com/admin
- https://stom.muhammadqodir.com/docs

---
```

### Health Checks

```bash
# Backend health
curl -f http://localhost:3000/health

# Database health
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec db \
    pg_isready -U dental_prod_user -d dental_clinic_prod

# Nginx status
curl -I http://localhost:80
```

### Log Rotation

```bash
# Docker log cleanup (haftalik)
echo "0 0 * * 0 docker system prune -f --volumes" | crontab -
```

## Security Best Practices

### 1. Regular Updates

```bash
# Container imagelarni yangilash
docker-compose --env-file .env.prod -f docker-compose.prod.yml pull
docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d --force-recreate
```

### 2. Backup Strategy

```bash
# Kunlik backup
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose --env-file .env.prod -f docker-compose.prod.yml exec -T db \
    pg_dump -U dental_prod_user dental_clinic_prod | \
    gzip > "/backups/dental_backup_$DATE.sql.gz"

# 30 kundan eski backuplarni o'chirish
find /backups -name "dental_backup_*.sql.gz" -mtime +30 -delete
```

### 3. Monitoring Alerts

```bash
# Diskwatch
echo "*/5 * * * * df -h / | awk 'NR==2{print \$5}' | sed 's/%//' | awk '{if(\$1 > 85) print \"Disk usage high: \" \$1 \"%\"}'" | crontab -
```

## Troubleshooting

### Common Issues

1. **Port 80/443 busy**

   ```bash
   sudo lsof -i :80
   sudo lsof -i :443
   ```

2. **SSL Certificate failed**

   - Domain DNS tekshiring
   - Firewall portlarini tekshiring
   - Domain ownership tasdiqlang

3. **Database connection failed**

   ```bash
   docker-compose --env-file .env.prod -f docker-compose.prod.yml logs db
   ```

4. **Backend 500 error**
   ```bash
   docker-compose --env-file .env.prod -f docker-compose.prod.yml logs backend
   ```

### Performance Tuning

```bash
# Nginx worker processes
# nginx.prod.conf da worker_processes auto;

# PostgreSQL tuning
# shared_buffers = 256MB
# effective_cache_size = 1GB
# maintenance_work_mem = 64MB
```

## Access URLs

- **Website**: https://stom.muhammadqodir.com
- **Admin Panel**: https://stom.muhammadqodir.com/admin
- **API Docs**: https://stom.muhammadqodir.com/docs
- **Health Check**: https://stom.muhammadqodir.com/health

## Support

Muammolar bo'lsa:

1. Logs tekshiring
2. Health check statusini tekshiring
3. GitHub Issues ga murojaat qiling
4. Telegram: @muhammadkodir_alijonov
