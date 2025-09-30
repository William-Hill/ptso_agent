#!/bin/bash

# Script to start A2A agents locally with Docker Compose

echo "🚀 Starting PTSO Agent A2A System with Docker Compose..."

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# API Keys (add your actual keys here)
GOOGLE_API_KEY=your_google_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here

# Database
DATABASE_URL=postgresql://ptso_user:ptso_password@postgres:5432/ptso_db

# Agent URLs (for Docker Compose)
WEATHER_AGENT_URL=http://weather-agent:8001
WARDROBE_AGENT_URL=http://wardrobe-agent:8002
EOF
    echo "⚠️  Please edit .env file with your actual API keys before running the agents."
fi

# Build and start services
echo "🔨 Building Docker images..."
docker-compose -f docker-compose-a2a.yml build

echo "🚀 Starting services..."
docker-compose -f docker-compose-a2a.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🏥 Checking service health..."

# Check database
if docker-compose -f docker-compose-a2a.yml exec postgres pg_isready -U ptso_user -d ptso_db; then
    echo "✅ Database is ready"
else
    echo "❌ Database is not ready"
fi

# Check weather agent
if curl -s http://localhost:8001/health > /dev/null; then
    echo "✅ Weather Agent is ready"
else
    echo "❌ Weather Agent is not ready"
fi

# Check wardrobe agent
if curl -s http://localhost:8002/health > /dev/null; then
    echo "✅ Wardrobe Agent is ready"
else
    echo "❌ Wardrobe Agent is not ready"
fi

# Check PTSO agent
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ PTSO Agent is ready"
else
    echo "❌ PTSO Agent is not ready"
fi

echo ""
echo "🎉 A2A Agent System is running!"
echo ""
echo "📊 Service URLs:"
echo "  • PTSO Agent (Main):     http://localhost:8000"
echo "  • Weather Agent:         http://localhost:8001"
echo "  • Wardrobe Agent:        http://localhost:8002"
echo "  • Database:              localhost:5432"
echo ""
echo "🔍 Health Checks:"
echo "  • PTSO Agent Health:     http://localhost:8000/health"
echo "  • Weather Agent Health:  http://localhost:8001/health"
echo "  • Wardrobe Agent Health: http://localhost:8002/health"
echo ""
echo "💬 Test the system:"
echo "  curl -X POST http://localhost:8000/ask -H 'Content-Type: application/json' -d '{\"message\": \"What should I wear in Atlanta today?\"}'"
echo ""
echo "🛑 To stop the system:"
echo "  docker-compose -f docker-compose-a2a.yml down"
