# PTSO Agent (Put That Sh*t On Agent)

A smart wardrobe recommendation system that uses weather data and Google's Agent Development Kit (ADK) to help you decide what to wear based on current weather conditions.

## Overview

The PTSO Agent is a multi-agent system that combines weather data with wardrobe recommendations to help users make informed decisions about their daily attire. The system consists of three main agents:

1. **PTSO Agent (Root)**: The main orchestrator that coordinates between the weather and wardrobe agents
2. **Weather Agent**: Fetches current weather data from a PostgreSQL database
3. **Wardrobe Agent**: Analyzes temperature data and recommends appropriate clothing options

## Architecture

- **Data Source**: Weather data is fetched using a Conduit pipeline (conduit.io) and stored in PostgreSQL
- **Database**: PostgreSQL running in Docker Compose
- **Agent Framework**: Google Agent Development Kit (ADK)
- **Agent Communication**: Hierarchical delegation pattern where the PTSO agent can delegate tasks to specialized agents

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

## Usage

[Usage instructions will be added as the project develops]

## Project Structure

```
ptso_agent_demo/
├── agents/
│   ├── ptso_agent.py
│   ├── weather_agent.py
│   └── wardrobe_agent.py
├── database/
│   └── schema.sql
├── docker-compose.yml
├── requirements.txt
└── utils/
    └── util.py
```

## Contributing

[Contribution guidelines will be added]

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

- [Google Agent Development Kit](https://google.github.io/adk-docs/)
- [Conduit](https://conduit.io) 