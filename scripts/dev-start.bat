@echo off
echo 🚀 Starting Dental Clinic Development Environment...

REM Check if .env.dev exists
if not exist .env.dev (
    echo ❌ .env.dev file not found!
    echo 📋 Creating .env.dev from example...
    if exist .env.dev.example (
        copy .env.dev.example .env.dev >nul
        echo ✅ .env.dev created from example
        echo ⚠️ Please edit .env.dev and configure your settings before continuing
        echo Opening .env.dev file for editing...
        notepad .env.dev
    ) else (
        echo Please copy .env.dev.example to .env.dev and configure your settings
    )
    pause
    exit /b 1
)

echo 🔍 Checking port availability...

REM Check ports using netstat (Windows equivalent)
netstat -an | findstr :80 >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️ Warning: Port 80 may be in use
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

echo 📦 Building and starting development containers...

REM Stop any existing containers
docker-compose -f docker-compose.dev.yml down

REM Build and start services
docker-compose -f docker-compose.dev.yml up --build -d

echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

echo ✅ Development environment is running!
echo.
echo 🌐 Application URLs:
echo    - Frontend: http://localhost
echo    - Backend API: http://localhost:3000
echo    - Database: localhost:5433
echo.
echo 📋 To view logs:
echo    docker-compose -f docker-compose.dev.yml logs -f
echo.
echo 🛑 To stop:
echo    docker-compose -f docker-compose.dev.yml down

pause