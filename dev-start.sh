#!/bin/bash

# Development Environment Setup and Run Script

set -e

echo "🚀 Starting Dental Clinic Development Environment..."

# Check if .env.dev exists
if [ ! -f .env.dev ]; then
    echo "❌ .env.dev file not found!"
    if [ -f .env.dev.example ]; then
        echo "📋 Creating .env.dev from example..."
        cp .env.dev.example .env.dev
        echo "✅ .env.dev created from example"
        echo "⚠️  Please edit .env.dev and configure your settings before continuing"
        echo "Run: nano .env.dev"
    else
        echo "Please copy .env.dev.example to .env.dev and configure your settings"
    fi
    exit 1
fi

echo "🔍 Checking port availability..."

# Check if ports are available
if command -v ss >/dev/null 2>&1; then
    PORT_CHECK_CMD="ss -tln"
elif command -v netstat >/dev/null 2>&1; then
    PORT_CHECK_CMD="netstat -tln"
else
    echo "⚠️  Warning: Cannot check ports (ss or netstat not found)"
    PORT_CHECK_CMD=""
fi

if [ -n "$PORT_CHECK_CMD" ]; then
    if $PORT_CHECK_CMD | grep -q ":80 "; then
        echo "⚠️  Warning: Port 80 is already in use (nginx may conflict)"
    fi

    if $PORT_CHECK_CMD | grep -q ":3000 "; then
        echo "❌ Error: Port 3000 is already in use"
        echo "Please stop the service using port 3000:"
        if command -v ss >/dev/null 2>&1; then
            ss -tlnp | grep :3000
        fi
        exit 1
    fi

    if $PORT_CHECK_CMD | grep -q ":5433 "; then
        echo "❌ Error: Port 5433 is already in use"
        echo "Please stop the service using port 5433:"
        if command -v ss >/dev/null 2>&1; then
            ss -tlnp | grep :5433
        fi
        exit 1
    fi

    echo "✅ All required ports are available"
fi

# Load development environment
export $(cat .env.dev | grep -v '^#' | xargs)

echo "📦 Building and starting development containers..."

# Stop any existing containers
docker-compose -f docker/docker-compose.dev.yml down

# Build and start services
docker-compose -f docker/docker-compose.dev.yml up --build -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
if docker-compose -f docker/docker-compose.dev.yml ps | grep -q "Up"; then
    echo "✅ Development environment is running!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   - Frontend: http://localhost"
    echo "   - Backend API: http://localhost:3000"
    echo "   - Database: localhost:5433"
    echo ""
    echo "📋 To view logs:"
    echo "   docker-compose -f docker/docker-compose.dev.yml logs -f"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose -f docker/docker-compose.dev.yml down"
else
    echo "❌ Failed to start development environment"
    echo "Check logs: docker-compose -f docker/docker-compose.dev.yml logs"
    exit 1
fi