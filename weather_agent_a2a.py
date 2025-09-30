"""
Weather Agent with A2A Protocol Support
Exposes the weather agent as an A2A agent that can be consumed by other agents.
"""

from google.adk.agents.llm_agent import LlmAgent
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters
from a2a.types import AgentCard
from google.adk.a2a.utils.agent_to_a2a import to_a2a
from dotenv import load_dotenv
from utils.util import load_instruction_from_file
from llm_config import get_llm_config, print_llm_info
from contextlib import AsyncExitStack
import asyncio

load_dotenv()

async def create_weather_agent_a2a():
    """Creates a weather agent that can be exposed via A2A protocol.
    
    Returns:
        FastAPI app: The A2A-enabled weather agent app.
    """
    # Get LLM configuration
    llm_config = get_llm_config()
    print_llm_info()
    
    # Create the underlying LLM agent with configurable model
    weather_agent = LlmAgent(
        name="weather_agent",
        model=llm_config.get_model_name(),
        instruction=load_instruction_from_file("agent_instructions/weather_agent_instructions.txt"),
        output_key="temperature"
    )
    
    # Create Agent Card for A2A exposure
    agent_card = AgentCard(
        name="Weather Agent",
        description="Fetches current weather data from PostgreSQL database",
        version="1.0.0",
        url="http://localhost:8001",
        defaultInputModes=["text/plain"],
        defaultOutputModes=["text/plain"],
        capabilities={},
        skills=[]
    )
    
    # Use to_a2a() to create A2A-compatible app
    a2a_app = to_a2a(weather_agent, port=8001, agent_card=agent_card)
    
    return a2a_app

def main():
    """Main function to run the weather agent as an A2A service."""
    import uvicorn
    print("Weather Agent A2A service starting...")
    uvicorn.run("weather_agent_a2a:a2a_app", host="0.0.0.0", port=8001, reload=False)

# Create the A2A app at module level
import asyncio
a2a_app = asyncio.run(create_weather_agent_a2a())

if __name__ == "__main__":
    main()

