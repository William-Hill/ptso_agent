#!/bin/bash

# Startup script for A2A agents with local Ollama instance

set -e

echo "🤖 Starting PTSO Agent A2A System with Local Ollama"
echo "====================================================="

# Check if Ollama is running locally
echo "🔍 Checking local Ollama instance..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Local Ollama is running"
    
    # Show available models
    echo "📋 Available models:"
    curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "   (jq not installed, showing raw output)"
    curl -s http://localhost:11434/api/tags 2>/dev/null || echo "   Could not fetch models"
else
    echo "❌ Local Ollama is not running!"
    echo "   Please start Ollama first:"
    echo "   ollama serve"
    echo ""
    echo "   Then pull a model:"
    echo "   ollama pull llama3.1:8b"
    exit 1
fi

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file for local Ollama..."
    cat > .env << EOF
# LLM Configuration for Local Ollama
OLLAMA_BASE_URL=http://host.docker.internal:11434
LLM_PROVIDER=ollama

# Database
DATABASE_URL=postgresql://ptso_user:ptso_password@postgres:5432/ptso_db

# Agent URLs
WEATHER_AGENT_URL=http://weather-agent:8001
WARDROBE_AGENT_URL=http://wardrobe-agent:8002
EOF
    echo "✅ Created .env file for local Ollama configuration"
fi

echo ""
echo "🚀 Starting A2A agents with local Ollama..."

# Build and start services
echo "🔨 Building Docker images..."
docker compose -f docker-compose-local-ollama.yml build

echo "🚀 Starting services..."
docker compose -f docker-compose-local-ollama.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check service health
echo "🏥 Checking service health..."

# Check database
if docker compose -f docker-compose-local-ollama.yml exec postgres pg_isready -U ptso_user -d ptso_db; then
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
echo "🎉 A2A Agent System is running with local Ollama!"
echo ""
echo "📊 Service URLs:"
echo "  • PTSO Agent (Main):     http://localhost:8000"
echo "  • Weather Agent:         http://localhost:8001"
echo "  • Wardrobe Agent:        http://localhost:8002"
echo "  • Database:              localhost:5433"
echo "  • Local Ollama:          http://localhost:11434"
echo ""
echo "🔍 Health Checks:"
echo "  • PTSO Agent Health:     http://localhost:8000/health"
echo "  • Weather Agent Health:  http://localhost:8001/health"
echo "  • Wardrobe Agent Health: http://localhost:8002/health"
echo "  • Ollama Health:         http://localhost:11434/api/tags"
echo ""
echo "💬 Test the system:"
echo "  curl -X POST http://localhost:8000/ask -H 'Content-Type: application/json' -d '{\"message\": \"What should I wear in Atlanta today?\"}'"
echo ""
echo "🧪 Run comprehensive tests:"
echo "  python test-a2a-agents.py"
echo ""
echo "🛑 To stop the system:"
echo "  docker-compose -f docker-compose-local-ollama.yml down"
echo ""
echo "💡 Tips:"
echo "  • Your local Ollama models are shared with the Docker containers"
echo "  • No need to run Ollama in Docker - using your local instance"
echo "  • Models are cached locally for faster startup"
