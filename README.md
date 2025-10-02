# Stomatologiya Klinikasi - Web App & Telegram Bot

Professional stomatologiya klinikasi uchun to'liq web aplikatsiya va Telegram bot.

## 🏗️ Arxitektura

```
stom/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI asosiy fayl
│   │   ├── database.py          # Database modellari
│   │   ├── schemas.py           # Pydantic sxemalari
│   │   ├── crud.py              # CRUD operatsiyalar
│   │   ├── telegram_bot.py      # Telegram bot
│   │   ├── templates/           # HTML sahifalar
│   │   │   ├── base.html
│   │   │   ├── index.html
│   │   │   ├── item_detail.html
│   │   │   ├── admin_login.html
│   │   │   └── admin_dashboard.html
│   │   └── static/
│   │       ├── css/style.css
│   │       ├── js/main.js
│   │       └── images/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
├── db/
│   └── init.sql                 # Boshlang'ich ma'lumotlar
└── docker/
    ├── docker-compose.yml
    ├── .env.dev
    └── .env.prod
```

## 🚀 Xususiyatlar

### User Panel
- 🔍 **Search**: Xizmatlarni qidirish imkoniyati
- 📂 **Kategoriyalar**: Plomba, Karonka, Implant, Ortodontiya, Profilaktika
- 📱 **Responsive**: Telegram Web App uchun optimallashtirilgan
- 🖼️ **Media**: Har bir xizmat uchun rasm va batafsil ma'lumot

### Admin Panel
- 🔐 **Autentifikatsiya**: Xavfsiz admin kirish
- ➕ **CRUD**: Kategoriya va xizmatlar boshqaruvi
- 📊 **Statistika**: Real vaqt hisobot va grafiklar
- 🖼️ **Media Upload**: Rasmlarni yuklash va boshqarish

### Telegram Bot
- 🤖 **Web App Launch**: Telegram ichida web app ochish
- 🔄 **Echo**: Barcha xabarlarni takrorlash
- 📲 **Deep Linking**: To'g'ridan-to'g'ri xizmatlarga yo'naltirish

## 🛠️ Texnologiyalar

- **Backend**: FastAPI + Python 3.11
- **Database**: PostgreSQL 15
- **Frontend**: HTML5 + Bootstrap 5 + JavaScript
- **Bot**: aiogram 3.2
- **Container**: Docker + Docker Compose
- **ORM**: SQLAlchemy

## 📦 O'rnatish

### 1. Repository clone qilish
```bash
git clone <repository-url>
cd stom
```

### 2. Environment o'rnatish
```bash
# Development uchun
cp docker/.env.dev docker/.env

# Telegram bot tokenini o'rnating
# .env faylida BOT_TOKEN ni o'zgartiring
```

### 3. Docker bilan ishga tushirish
```bash
cd docker
docker-compose up -d
```

### 4. Ma'lumotlar bazasini tekshirish
```bash
# Konteyner ichiga kirish
docker exec -it docker_backend_1 bash

# Migration (agar kerak bo'lsa)
alembic upgrade head
```

## 🔧 Sozlash

### Telegram Bot Token
1. [@BotFather](https://t.me/BotFather) ga boring
2. `/newbot` buyrug'ini yuboring
3. Bot nomini va username kiriting
4. Olingan tokenni `.env` fayliga qo'shing

### Web App URL
1. Bot sozlamalarida Web App URL ni o'rnating:
   - Development: `http://localhost:8000`
   - Production: sizning domeningiz

### Admin Hisobi
Default admin hisobi:
- **Username**: `jahongir_stom`
- **Password**: `jahonfir!@#`

⚠️ **Muhim**: Production da parolni o'zgartiring!

## 🌐 Foydalanish

### Web Panel
- Bosh sahifa: `http://localhost:8000`
- Admin panel: `http://localhost:8000/admin`

### API Endpoints
- `GET /api/categories` - Kategoriyalar ro'yxati
- `GET /api/items` - Xizmatlar ro'yxati
- `GET /api/items/{id}` - Xizmat tafsilotlari

### Telegram Bot
1. Botingizni ishga tushiring
2. `/start` buyrug'ini yuboring
3. "Klinikani ochish" tugmasini bosing

## 📱 Mobile Optimization

Loyiha Telegram Web App uchun optimallashtirilgan:
- Responsive dizayn
- Touch-friendly interface
- Fast loading
- Minimal bandwidth usage

## 🐳 Docker Commands

```bash
# Loyihani ishga tushirish
docker-compose up -d

# Loglarni ko'rish
docker-compose logs -f

# Konteynerlarni to'xtatish
docker-compose down

# Ma'lumotlar bazasini tozalash
docker-compose down -v
```

## 📊 Database Schema

### Categories
- `id` - Primary key
- `name` - Kategoriya nomi
- `description` - Tavsif
- `created_at` - Yaratilgan sana

### Items
- `id` - Primary key
- `name` - Xizmat nomi
- `price` - Narx
- `description` - Batafsil tavsif
- `duration` - Davomiylik
- `min_sessions` - Minimal seanslar
- `max_sessions` - Maksimal seanslar
- `image_url` - Rasm URL
- `category_id` - Kategoriya ID (Foreign Key)
- `created_at` - Yaratilgan sana

### Admins
- `id` - Primary key
- `username` - Foydalanuvchi nomi
- `hashed_password` - Shifrlangan parol
- `created_at` - Yaratilgan sana

## 🔒 Xavfsizlik

- Parollar bcrypt bilan shifrlanadi
- SQL Injection himoyasi (SQLAlchemy ORM)
- XSS himoyasi (Jinja2 templates)
- CORS sozlamalari
- Environment variables orqali sensitive ma'lumotlar

## 🚀 Production Deploy

### 1. Server tayyorlash
```bash
# Docker o'rnatish
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose o'rnatish
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Environment sozlash
```bash
# Production environment
cp docker/.env.prod docker/.env

# Environment o'zgaruvchilarini o'rnating:
# - BOT_TOKEN
# - SECRET_KEY
# - Database credentials
# - WEBAPP_URL
```

### 3. SSL sertifikat
```bash
# Let's Encrypt bilan
sudo apt install certbot
sudo certbot certonly --standalone -d yourdomain.com
```

### 4. Nginx konfiguratsiya
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📞 Support

Muammolar yoki savolllar uchun:
- Issues: GitHub Issues
- Email: support@stomclinic.uz
- Telegram: @your_support_bot

## 📝 License

MIT License - batafsil ma'lumot `LICENSE` faylida.

---

**© 2024 Stomatologiya Klinikasi. Barcha huquqlar himoyalangan.**