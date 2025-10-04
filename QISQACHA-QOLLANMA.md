# 🦷 Stomatologiya Klinika - Qisqacha Qo'llanma

## 🚀 Tezkor Ishga Tushirish

### Development (Ishlab chiqish)

1. **Loyihani yuklab oling:**

```bash
git clone https://github.com/muhammadkodir-alijonov/dent-bot.git
cd dent-bot
```

2. **Development muhitini sozlang:**

```bash
# .env.dev faylini tahrirlang
notepad .env.dev
# Yoki Linux/Mac da: nano .env.dev
```

3. **Ishga tushiring:**

````bash
# Linux/Mac
chmod +x scripts/dev-start.sh
./scripts/dev-start.sh

# Windows
scripts\dev-start.bat

# WSL (Windows)
wsl ./scripts/dev-start.sh
```4. **Kirish:**

- 🌐 Web: http://localhost
- ⚙️ API: http://localhost:3000

### Production (Ishlab chiqarish)

1. **Production muhitini sozlang:**

```bash
# .env.prod faylini tahrirlang
notepad .env.prod

# Majburiy o'zgartirishlar:
# - POSTGRES_PASSWORD (kuchli parol)
# - SECRET_KEY (32 ta belgi)
# - BOT_TOKEN (haqiqiy bot token)
# - LETSENCRYPT_EMAIL (elektron pochta)
````

2. **Production ga deploy qiling:**

```bash
# Linux/Unix systems
chmod +x scripts/prod-deploy.sh
./scripts/prod-deploy.sh
```

3. **Kirish:**

- 🌐 Sayt: https://stom.muhammadqodir.com
- 🔧 Admin: https://stom.muhammadqodir.com/admin

## ⚙️ Boshqaruv Buyruqlari

### Development

```bash
# Ishga tushirish
docker-compose -f docker/docker-compose.dev.yml up --build

# Loglarni ko'rish
docker-compose -f docker/docker-compose.dev.yml logs -f

# To'xtatish
docker-compose -f docker/docker-compose.dev.yml down
```

### Production

```bash
# Ishga tushirish
docker-compose -f docker/docker-compose.prod.yml up --build -d

# SSL yangilash
./scripts/renew-ssl.sh

# Loglarni ko'rish
docker-compose -f docker/docker-compose.prod.yml logs -f

# To'xtatish
docker-compose -f docker/docker-compose.prod.yml down
```

## 🔧 Muhim Sozlamalar

### .env.dev (Development)

```bash
POSTGRES_DB=dental_clinic_dev
POSTGRES_USER=dental_user
POSTGRES_PASSWORD=dev_password_123
SECRET_KEY=development_secret_key
BOT_TOKEN=your_bot_token
WEBAPP_URL=http://localhost:3000
DEBUG=true
```

### .env.prod (Production)

```bash
POSTGRES_DB=dental_clinic_prod
POSTGRES_USER=dental_prod_user
POSTGRES_PASSWORD=KUCHLI_PAROL_YOZING
SECRET_KEY=32_BELGIDAN_IBORAT_MAXFIY_KALIT
BOT_TOKEN=HAQIQIY_BOT_TOKEN
WEBAPP_URL=https://stom.muhammadqodir.com
DEBUG=false
LETSENCRYPT_EMAIL=sizning@email.com
```

## 🛠 Tizim Talablari

- **Docker** va **Docker Compose**
- **Domen nomi** (production uchun)
- **Telegram Bot Token**
- **Elektron pochta** (SSL uchun)

## 📞 Yordam

Muammolar bo'lsa:

- 📧 Email: alijonov@domain.com
- 💬 Telegram: @muhammadkodir_alijonov
- 🐛 GitHub Issues

## 🏥 Foydalanuvchi Hisobotlari

**Admin hisobi (default):**

- Login: admin
- Parol: admin123 (dev) / o'zgartirilgan (prod)

**Telegram Bot:**

1. @BotFather da bot yarating
2. Token ni .env fayliga qo'ying
3. Webhook avtomatik sozlanadi
