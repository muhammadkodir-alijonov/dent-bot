@echo off
echo 🚀 Deploying Dental Clinic to Production...

REM Check if .env.prod exists
if not exist .env.prod (
    echo ❌ .env.prod file not found!
    echo 📋 Creating .env.prod from example...
    if exist .env.prod.example (
        copy .env.prod.example .env.prod >nul
        echo ✅ .env.prod created from example
        echo ⚠️ IMPORTANT: Please edit .env.prod and configure your production settings!
        echo Opening .env.prod file for editing...
        notepad .env.prod
        echo Press any key after configuring .env.prod...
    ) else (
        echo Please copy .env.prod.example to .env.prod and configure your production settings
    )
    pause
    exit /b 1
)

echo 🔍 Checking port availability...

REM Check ports using netstat
netstat -an | findstr :80 >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️ Warning: Port 80 is already in use
    netstat -ano | findstr :80
)

netstat -an | findstr :3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ Error: Port 3000 is already in use
    echo Please stop the service using port 3000:
    netstat -ano | findstr :3000
    pause
    exit /b 1
)

netstat -an | findstr :5433 >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ Error: Port 5433 is already in use
    echo Please stop the service using port 5433:
    netstat -ano | findstr :5433
    pause
    exit /b 1
)

echo ✅ All required ports are available

echo 🔒 Setting up SSL certificates...

REM First, get SSL certificate
docker-compose -f docker-compose.prod.yml --profile ssl-setup up certbot

if %errorlevel% neq 0 (
    echo ❌ Failed to obtain SSL certificate
    echo Make sure your domain stom.muhammadqodir.com points to this server
    pause
    exit /b 1
)

echo 📦 Building and starting production containers...

REM Stop any existing containers
docker-compose -f docker-compose.prod.yml down

REM Build and start services
docker-compose -f docker-compose.prod.yml up --build -d

echo ⏳ Waiting for services to be ready...
timeout /t 20 /nobreak >nul

echo ✅ Production environment is running!
echo.
echo 🌐 Application URLs:
echo    - Website: https://stom.muhammadqodir.com
echo    - Admin: https://stom.muhammadqodir.com/admin
echo.
echo 📋 To view logs:
echo    docker-compose -f docker-compose.prod.yml logs -f
echo.
echo 🔄 To update SSL certificates:
echo    docker-compose -f docker-compose.prod.yml --profile ssl-renew up certbot-renew
echo.
echo 🛑 To stop:
echo    docker-compose -f docker-compose.prod.yml down

pause