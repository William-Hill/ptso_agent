# PTSO Agent (Put That Sh*t On Agent) with A2A Protocol

A smart wardrobe recommendation system that uses weather data and Google's Agent Development Kit (ADK) with Agent2Agent (A2A) protocol to help you decide what to wear based on current weather conditions.

## Overview

The PTSO Agent is a multi-agent system that combines weather data with wardrobe recommendations to help users make informed decisions about their daily attire. The system consists of three main agents that communicate using the A2A protocol:

1. **PTSO Agent (Root)**: The main orchestrator that coordinates between remote weather and wardrobe agents
2. **Weather Agent**: Fetches current weather data from a PostgreSQL database (deployed as A2A service)
3. **Wardrobe Agent**: Analyzes temperature data and recommends appropriate clothing options (deployed as A2A service)

## Architecture

- **Data Source**: Weather data is fetched using a Conduit pipeline (conduit.io) and stored in PostgreSQL
- **Database**: PostgreSQL running in Docker Compose
- **Agent Framework**: Google Agent Development Kit (ADK) with A2A Protocol
- **Agent Communication**: A2A protocol for distributed agent communication across services
- **Deployment**: Cloud Run for scalable, serverless A2A agent services

## Prerequisites

- Docker and Docker Compose
- Python 3.x
- Google Agent Development Kit (ADK)
- Conduit

## Setup

1. Clone the repository:
```bash
git clone [repository-url]
cd ptso_agent_demo
```

2. Set up the database:
```bash
docker-compose up -d
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## A2A Protocol Integration with Flexible LLM Support

This project now supports the Agent2Agent (A2A) protocol with flexible LLM backend options, enabling distributed agent communication with both local and commercial LLM providers. The A2A protocol allows agents to communicate across different deployments, making the system more scalable and interoperable.

### 🤖 LLM Backend Options

The system supports multiple LLM backends for maximum flexibility:

#### **Commercial LLMs** (Recommended for production)
- **Google Gemini**: `gemini-2.0-flash`, `gemini-1.5-pro`
- **OpenAI GPT**: `gpt-4o`, `gpt-4o-mini`, `gpt-3.5-turbo`
- **Anthropic Claude**: `claude-3-5-sonnet-20241022`, `claude-3-haiku-20240307`

#### **Local LLMs** (Cost-effective, privacy-focused)
- **Ollama**: `llama3.1:8b`, `llama3.1:70b`, `mistral:7b`, `codellama:7b`
- **vLLM**: `meta-llama/Llama-3.1-8B-Instruct`, `microsoft/DialoGPT-medium`
- **Custom Local APIs**: Any OpenAI-compatible local service

### Key A2A Features

- **Agent Cards**: Each agent exposes its capabilities through standardized Agent Cards
- **Remote Communication**: Agents can communicate across different services and deployments
- **Scalability**: Individual agents can be scaled independently
- **Interoperability**: A2A agents can be consumed by other systems and platforms

### A2A Agent Services

1. **Weather Agent A2A Service** (`weather_agent_a2a.py`)
   - Exposes weather data retrieval capabilities
   - Deployed as a Cloud Run service
   - Input: City name
   - Output: Temperature and weather data

2. **Wardrobe Agent A2A Service** (`wardrobe_agent_a2a.py`)
   - Exposes wardrobe recommendation capabilities
   - Deployed as a Cloud Run service
   - Input: Temperature and city
   - Output: Clothing recommendations

3. **PTSO Agent A2A Client** (`ptso_agent_a2a.py`)
   - Consumes remote A2A agents
   - Coordinates between weather and wardrobe services
   - Provides unified interface for users

## Usage

### Local Development

#### Option 1: Docker Compose with LLM Configuration (Recommended)

The easiest way to run all A2A agents locally with your preferred LLM:

1. **Configure your LLM backend:**
```bash
# Interactive LLM setup
./llm-setup.sh

# Or use the enhanced startup script
./start-a2a-with-llm.sh
```

This will:
- Let you choose between commercial and local LLMs
- Start PostgreSQL database
- Build and run all A2A agents in containers
- Set up networking between agents
- Provide health checks and service URLs

2. **Test the system:**
```bash
python test-a2a-agents.py
```

3. **Access the services:**
- **PTSO Agent (Main)**: http://localhost:8000
- **Weather Agent**: http://localhost:8001  
- **Wardrobe Agent**: http://localhost:8002
- **Database**: localhost:5432
- **Ollama** (if using): http://localhost:11434
- **vLLM** (if using): http://localhost:8000

4. **Stop the system:**
```bash
docker-compose -f docker-compose-a2a.yml down
```

#### Option 2: Basic Docker Compose (Legacy)

For basic setup without LLM configuration:

```bash
./start-a2a-local.sh
```

#### Option 3: Manual Local Development

1. **Configure LLM backend:**
```bash
# Set up your preferred LLM
export GOOGLE_API_KEY="your_key_here"        # For Gemini
export OPENAI_API_KEY="your_key_here"        # For OpenAI
export OLLAMA_BASE_URL="http://localhost:11434"  # For Ollama
export LLM_PROVIDER="gemini"                 # Choose: gemini, openai, anthropic, ollama, vllm
```

2. **Start the database:**
```bash
docker-compose up -d
```

3. **Run individual A2A agents locally:**
```bash
# Terminal 1 - Weather Agent
python weather_agent_a2a.py

# Terminal 2 - Wardrobe Agent  
python wardrobe_agent_a2a.py

# Terminal 3 - PTSO Agent (consumes the above)
python ptso_agent_a2a.py web
```

### LLM Configuration Examples

#### **Using Google Gemini (Default)**
```bash
export GOOGLE_API_KEY="your_google_api_key"
export LLM_PROVIDER="gemini"
```

#### **Using OpenAI GPT**
```bash
export OPENAI_API_KEY="your_openai_api_key"
export LLM_PROVIDER="openai"
```

#### **Using Ollama (Local)**
```bash
# Start Ollama
ollama serve

# Pull a model
ollama pull llama3.1:8b

# Configure environment
export OLLAMA_BASE_URL="http://localhost:11434"
export LLM_PROVIDER="ollama"
```

#### **Using vLLM (Local, GPU required)**
```bash
# Start vLLM server
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --host 0.0.0.0 --port 8000

# Configure environment
export VLLM_BASE_URL="http://localhost:8000"
export LLM_PROVIDER="vllm"
```

### Cloud Deployment

1. Set your GCP project ID:
```bash
export PROJECT_ID="your-gcp-project-id"
```

2. Deploy A2A agents to Cloud Run:
```bash
./deploy-a2a.sh
```

3. Update the PTSO agent with the deployed service URLs:
```python
# In ptso_agent_a2a.py, update the URLs:
weather_agent_url = "https://weather-agent-a2a-xxxxx-uc.a.run.app"
wardrobe_agent_url = "https://wardrobe-agent-a2a-xxxxx-uc.a.run.app"
```

### A2A Agent Discovery

The A2A protocol supports agent discovery through Agent Cards. Each agent exposes:
- **Capabilities**: What the agent can do
- **Input Schema**: Expected input format
- **Output Schema**: Response format
- **Version**: Agent version for compatibility

## Project Structure

```
ptso_agent_demo/
├── agent_instructions/           # Agent instruction files
│   ├── ptso_agent_instructions.txt
│   ├── weather_agent_instructions.txt
│   └── wardrobe_agent_instructions.txt
├── ptso_agent/                  # Original agent implementation
│   ├── __init__.py
│   └── agent.py
├── ptso_agent_a2a.py           # A2A-enabled PTSO agent
├── weather_agent_a2a.py        # Weather agent A2A service
├── wardrobe_agent_a2a.py       # Wardrobe agent A2A service
├── Dockerfile.weather          # Docker config for weather agent
├── Dockerfile.wardrobe         # Docker config for wardrobe agent
├── cloud-run-deploy.yml       # Cloud Run deployment config
├── deploy-a2a.sh              # Deployment script
├── docker-compose.yml          # Local database setup
├── requirements.txt            # Python dependencies
├── pipelines/                  # Conduit pipeline config
│   └── weather-pipeline.yml
└── utils/                      # Utility functions
    └── util.py
```

## Contributing

[Contribution guidelines will be added]

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

- [Google Agent Development Kit](https://google.github.io/adk-docs/)
- [Conduit](https://conduit.io) 