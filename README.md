# 🦷 Stomatologiya Klinika Management System

Professional dental clinic management system with Telegram bot integration and modern web interface.

## ✨ Features

- 📋 Patient management system
- 📅 Appointment scheduling
- 🏥 Treatment history tracking
- 📊 Admin dashboard
- 🤖 Telegram bot integration
- 🔐 Secure authentication
- 📱 Responsive web interface
- 🔄 Real-time notifications

## 🛠 Tech Stack

- **Backend**: FastAPI (Python 3.11)
- **Database**: PostgreSQL 15
- **Frontend**: HTML5, CSS3, JavaScript (Tailwind CSS)
- **Bot**: Aiogram 3.x (Telegram Bot API)
- **Web Server**: Nginx
- **Containerization**: Docker & Docker Compose
- **SSL**: Let's Encrypt (Certbot)

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Domain name (for production)
- Telegram Bot Token
- **Available ports**: 80, 8080, 5433

### Development Setup

1. **Clone the repository:**

```bash
git clone https://github.com/muhammadkodir-alijonov/dent-bot.git
cd dent-bot
```

2. **Check port availability (important!):**

```bash
# Check if required ports are free
sudo ss -tlnp | grep -E ":(80|3000|5433)"

# If any ports are busy, you'll see output like:
# 0.0.0.0:8080    LISTEN    1234/some-service

# Stop conflicting services or change ports in docker-compose files
```

3. **Setup development environment:**

```bash
# Copy development environment file
cp .env.dev.example .env.dev

# Edit your development settings (IMPORTANT!)
nano .env.dev

# Configure these required settings:
# - POSTGRES_PASSWORD (change from default)
# - BOT_TOKEN (your Telegram bot token)
# - SECRET_KEY (32 character secret key)
# - ADMIN_PASSWORD (change from default)
```

4. **Start development environment:**

**Linux/Mac:**

```bash
# Make script executable and run
chmod +x scripts/dev-start.sh
./scripts/dev-start.sh
```

**Windows:**

```cmd
# Use Windows batch file
scripts\dev-start.bat

# Or with WSL
wsl ./scripts/dev-start.sh
```

**Manual (any OS):**

```bash
docker-compose -f docker-compose.dev.yml up --build
```

5. **Access the application:**

- 🌐 Web Interface: http://localhost
- - ⚙️ Backend API: http://localhost:3000
- 🗄️ Database: localhost:5433

### Production Deployment

1. **Prepare production environment:**

```bash
# Copy production environment file
cp .env.prod.example .env.prod

# Configure your production settings (CRITICAL!)
nano .env.prod

# MUST CHANGE these settings:
# - POSTGRES_PASSWORD (strong password)
# - SECRET_KEY (32 character random string)
# - BOT_TOKEN (your real Telegram bot token)
# - ADMIN_PASSWORD (strong admin password)
# - LETSENCRYPT_EMAIL (your email for SSL)
```

2. **Important: Update these settings in .env.prod:**

```bash
POSTGRES_PASSWORD=your_strong_password_here
SECRET_KEY=your_32_character_secret_key_here
BOT_TOKEN=your_real_telegram_bot_token
LETSENCRYPT_EMAIL=your_email@domain.com
```

3. **Deploy to production:**

**Linux Server:**

```bash
# Make script executable and run
chmod +x scripts/prod-deploy.sh
./scripts/prod-deploy.sh
```

**Windows Server:**

```cmd
# Use Windows batch file
scripts\prod-deploy.bat

# Or with WSL
wsl ./scripts/prod-deploy.sh
```

**Manual:**

```bash
docker-compose -f docker-compose.prod.yml up --build -d
```

4. **Access production:**

- 🌐 Website: https://stom.muhammadqodir.com
- 🔧 Admin Panel: https://stom.muhammadqodir.com/admin

## 📁 Project Structure

```
dent-bot/
├── 📂 backend/                 # FastAPI application
│   ├── 📂 app/                # Main application code
│   ├── 📄 Dockerfile          # Development Docker image
│   ├── 📄 Dockerfile.prod     # Production Docker image
│   └── 📄 requirements.txt    # Python dependencies
├── 📂 db/                     # Database initialization
├── 📂 docker/                 # Docker configurations
│   ├── 📄 docker-compose.dev.yml   # Development setup
│   └── 📄 docker-compose.prod.yml  # Production setup
├── 📂 scripts/               # Deployment scripts
├── 📄 nginx.dev.conf         # Nginx development config
├── 📄 nginx.prod.conf        # Nginx production config
├── 📄 .env.dev               # Development environment
└── 📄 .env.prod              # Production environment
```

## ⚙️ Configuration

### Environment Files

- **`.env.dev`**: Development settings (HTTP, debug mode, relaxed security)
- **`.env.prod`**: Production settings (HTTPS, optimized, secure)

### Key Environment Variables

| Variable            | Development             | Production                       | Description          |
| ------------------- | ----------------------- | -------------------------------- | -------------------- |
| `WEBAPP_URL`        | `http://localhost:8000` | `https://stom.muhammadqodir.com` | Application base URL |
| `DEBUG`             | `true`                  | `false`                          | Debug mode           |
| `POSTGRES_PASSWORD` | `dev_password_123`      | `strong_password`                | Database password    |
| `SECRET_KEY`        | `dev_key`               | `32_char_secure_key`             | JWT secret key       |

## 🔧 Management Commands

### Development

```bash
# Start development environment
./scripts/dev-start.sh

# View logs
docker-compose -f docker/docker-compose.dev.yml logs -f

# Stop environment
docker-compose -f docker/docker-compose.dev.yml down
```

### Production

```bash
# Deploy production
./scripts/prod-deploy.sh

# View logs
docker-compose -f docker/docker-compose.prod.yml logs -f

# Renew SSL certificates
./scripts/renew-ssl.sh

# Stop production
docker-compose -f docker/docker-compose.prod.yml down
```

## 🔒 Security Features

### Production Security

- 🔐 HTTPS with Let's Encrypt SSL
- 🛡️ Security headers (XSS, CSRF protection)
- ⚡ Rate limiting
- 🔄 Automated SSL renewal
- 👤 Non-root container users
- 🚫 Debug mode disabled

### Development Security

- 🔓 HTTP only (no SSL complexity)
- 🐛 Debug mode enabled
- 🔍 Verbose logging
- ⏱️ No rate limiting
- 🔄 Hot reloading

## 📊 Monitoring & Logs

### Log Locations

- **Nginx**: `/var/log/nginx/` (in container)
- **Backend**: `/app/logs/` (in container)
- **Database**: Docker logs

### Health Checks

- **Backend**: `/health` endpoint
- **Database**: PostgreSQL `pg_isready`
- **Nginx**: `/nginx-health` endpoint

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/muhammadkodir-alijonov/dent-bot/issues)
- 📧 **Email**: alijonov@domain.com
- 💬 **Telegram**: @muhammadkodir_alijonov

## 🏥 About

Professional dental clinic management system designed for modern dental practices. Streamline your patient management, appointments, and communication with integrated Telegram bot functionality.

---

**Made with ❤️ for dental professionals**
