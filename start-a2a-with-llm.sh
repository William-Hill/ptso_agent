#!/bin/bash

# Enhanced startup script for A2A agents with LLM configuration support

set -e

echo "🤖 Starting PTSO Agent A2A System with LLM Configuration"
echo "========================================================"

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
    cp .env.example .env
    echo "⚠️  Please edit .env file with your API keys and LLM configuration."
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# LLM Configuration Menu
echo ""
echo "🤖 Choose your LLM configuration:"
echo "1) Commercial LLM (Gemini/OpenAI/Claude) - Default"
echo "2) Local LLM with Ollama"
echo "3) Local LLM with vLLM (GPU required)"
echo "4) Custom configuration"

read -p "Enter your choice (1-4): " llm_choice

case $llm_choice in
    1)
        echo "🔧 Using Commercial LLM configuration..."
        export LLM_PROVIDER=gemini
        COMPOSE_PROFILES=""
        ;;
    2)
        echo "🔧 Using Ollama local LLM..."
        export LLM_PROVIDER=ollama
        export OLLAMA_BASE_URL=http://ollama:11434
        COMPOSE_PROFILES="local-llm"
        ;;
    3)
        echo "🔧 Using vLLM local LLM (GPU required)..."
        export LLM_PROVIDER=vllm
        export VLLM_BASE_URL=http://vllm:8000
        COMPOSE_PROFILES="local-llm"
        ;;
    4)
        echo "🔧 Using custom configuration from .env file..."
        COMPOSE_PROFILES=""
        ;;
    *)
        echo "Invalid choice. Using default (Commercial LLM)"
        export LLM_PROVIDER=gemini
        COMPOSE_PROFILES=""
        ;;
esac

echo ""
echo "🚀 Starting services with LLM provider: $LLM_PROVIDER"

# Build and start services
echo "🔨 Building Docker images..."
if [ -n "$COMPOSE_PROFILES" ]; then
    docker-compose -f docker-compose-a2a.yml --profile $COMPOSE_PROFILES build
else
    docker-compose -f docker-compose-a2a.yml build
fi

echo "🚀 Starting services..."
if [ -n "$COMPOSE_PROFILES" ]; then
    docker-compose -f docker-compose-a2a.yml --profile $COMPOSE_PROFILES up -d
else
    docker-compose -f docker-compose-a2a.yml up -d
fi

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check service health
echo "🏥 Checking service health..."

# Check database
if docker-compose -f docker-compose-a2a.yml exec postgres pg_isready -U ptso_user -d ptso_db; then
    echo "✅ Database is ready"
else
    echo "❌ Database is not ready"
fi

# Check LLM service if using local LLM
if [ "$LLM_PROVIDER" = "ollama" ]; then
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo "✅ Ollama service is ready"
    else
        echo "❌ Ollama service is not ready"
    fi
elif [ "$LLM_PROVIDER" = "vllm" ]; then
    if curl -s http://localhost:8000/v1/models > /dev/null; then
        echo "✅ vLLM service is ready"
    else
        echo "❌ vLLM service is not ready"
    fi
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

if [ "$LLM_PROVIDER" = "ollama" ]; then
    echo "  • Ollama LLM:            http://localhost:11434"
elif [ "$LLM_PROVIDER" = "vllm" ]; then
    echo "  • vLLM LLM:              http://localhost:8000"
fi

echo ""
echo "🔍 Health Checks:"
echo "  • PTSO Agent Health:     http://localhost:8000/health"
echo "  • Weather Agent Health:  http://localhost:8001/health"
echo "  • Wardrobe Agent Health: http://localhost:8002/health"

if [ "$LLM_PROVIDER" = "ollama" ]; then
    echo "  • Ollama Health:         http://localhost:11434/api/tags"
elif [ "$LLM_PROVIDER" = "vllm" ]; then
    echo "  • vLLM Health:           http://localhost:8000/v1/models"
fi

echo ""
echo "💬 Test the system:"
echo "  curl -X POST http://localhost:8000/ask -H 'Content-Type: application/json' -d '{\"message\": \"What should I wear in Atlanta today?\"}'"
echo ""
echo "🧪 Run comprehensive tests:"
echo "  python test-a2a-agents.py"
echo ""
echo "🛑 To stop the system:"
if [ -n "$COMPOSE_PROFILES" ]; then
    echo "  docker-compose -f docker-compose-a2a.yml --profile $COMPOSE_PROFILES down"
else
    echo "  docker-compose -f docker-compose-a2a.yml down"
fi
