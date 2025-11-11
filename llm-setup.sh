#!/bin/bash

# LLM Setup Script
# Helps configure different LLM backends for the A2A agent system

set -e

echo "🤖 LLM Setup for PTSO Agent A2A System"
echo "========================================"

# Function to setup Ollama
setup_ollama() {
    echo "📦 Setting up Ollama..."
    
    # Check if Ollama is installed
    if ! command -v ollama &> /dev/null; then
        echo "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
    fi
    
    # Start Ollama service
    echo "Starting Ollama service..."
    ollama serve &
    sleep 5
    
    # Pull a model
    echo "Pulling Llama 3.1 8B model..."
    ollama pull llama3.1:8b
    
    # Set environment variables
    export OLLAMA_BASE_URL=http://localhost:11434
    export LLM_PROVIDER=ollama
    
    echo "✅ Ollama setup complete!"
    echo "   Model: llama3.1:8b"
    echo "   URL: http://localhost:11434"
}

# Function to setup vLLM
setup_vllm() {
    echo "📦 Setting up vLLM..."
    
    # Check if vLLM is available
    if ! python -c "import vllm" 2>/dev/null; then
        echo "Installing vLLM..."
        pip install vllm
    fi
    
    # Start vLLM server
    echo "Starting vLLM server..."
    python -m vllm.entrypoints.openai.api_server \
        --model meta-llama/Llama-3.1-8B-Instruct \
        --host 0.0.0.0 \
        --port 8000 &
    sleep 10
    
    # Set environment variables
    export VLLM_BASE_URL=http://localhost:8000
    export LLM_PROVIDER=vllm
    
    echo "✅ vLLM setup complete!"
    echo "   Model: meta-llama/Llama-3.1-8B-Instruct"
    echo "   URL: http://localhost:8000"
}

# Function to setup commercial LLMs
setup_commercial() {
    echo "📦 Setting up Commercial LLM..."
    
    echo "Please choose your commercial LLM provider:"
    echo "1) Google Gemini (default)"
    echo "2) OpenAI GPT"
    echo "3) Anthropic Claude"
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            read -p "Enter your Google API key: " api_key
            export GOOGLE_API_KEY="$api_key"
            export LLM_PROVIDER=gemini
            echo "✅ Google Gemini configured!"
            ;;
        2)
            read -p "Enter your OpenAI API key: " api_key
            export OPENAI_API_KEY="$api_key"
            export LLM_PROVIDER=openai
            echo "✅ OpenAI configured!"
            ;;
        3)
            read -p "Enter your Anthropic API key: " api_key
            export ANTHROPIC_API_KEY="$api_key"
            export LLM_PROVIDER=anthropic
            echo "✅ Anthropic Claude configured!"
            ;;
        *)
            echo "Invalid choice. Using default (Google Gemini)"
            export LLM_PROVIDER=gemini
            ;;
    esac
}

# Function to test LLM configuration
test_llm() {
    echo "🧪 Testing LLM configuration..."
    
    python -c "
from llm_config import get_llm_config, print_llm_info
import os

# Set provider from environment
if 'LLM_PROVIDER' in os.environ:
    from llm_config import set_llm_provider, LLMProvider
    provider_map = {
        'ollama': LLMProvider.OLLAMA,
        'vllm': LLMProvider.VLLM,
        'gemini': LLMProvider.GEMINI,
        'openai': LLMProvider.OPENAI,
        'anthropic': LLMProvider.ANTHROPIC
    }
    if os.environ['LLM_PROVIDER'] in provider_map:
        set_llm_provider(provider_map[os.environ['LLM_PROVIDER']])

print_llm_info()
"
}

# Main menu
echo "Choose your LLM setup:"
echo "1) Local LLM with Ollama"
echo "2) Local LLM with vLLM"
echo "3) Commercial LLM (Gemini/OpenAI/Claude)"
echo "4) Test current configuration"
echo "5) Exit"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        setup_ollama
        test_llm
        ;;
    2)
        setup_vllm
        test_llm
        ;;
    3)
        setup_commercial
        test_llm
        ;;
    4)
        test_llm
        ;;
    5)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "🎉 LLM setup complete!"
echo "You can now run your A2A agents with the configured LLM."
echo ""
echo "To start the agents:"
echo "  ./start-a2a-local.sh"
