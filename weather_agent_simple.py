"""
Weather Agent - Simplified version without A2A protocol
Works with current Google ADK version
"""

from google.adk.agents.llm_agent import LlmAgent
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters
from dotenv import load_dotenv
from utils.util import load_instruction_from_file
from llm_config import get_llm_config, print_llm_info
from contextlib import AsyncExitStack
import asyncio
from fastapi import FastAPI
import uvicorn
import os

load_dotenv()

async def create_weather_agent():
    """Creates a weather agent with MCP tools.
    
    Returns:
        LlmAgent: Weather agent
    """
    # Initialize MCP tools for database access
    weather_tools, weather_exit = await MCPToolset.from_server(
        connection_params=StdioServerParameters(
            command="npx",
            args=[
                "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://ptso_user:ptso_password@postgres:5432/ptso_db"
            ]
        )
    )
    
    # Get LLM configuration
    llm_config = get_llm_config()
    print_llm_info()
    
    # Create the underlying LLM agent with configurable model
    weather_agent = LlmAgent(
        name="weather_agent",
        model=llm_config.get_model_name(),
        instruction=load_instruction_from_file("agent_instructions/weather_agent_instructions.txt"),
        tools=weather_tools,
        output_key="temperature",
        **llm_config.get_adk_config()
    )
    
    return weather_agent

async def main():
    """Main function to run the weather agent as a web service."""
    weather_agent = await create_weather_agent()
    
    # Create FastAPI app
    app = FastAPI(title="Weather Agent", description="Weather data agent")
    
    @app.get("/")
    async def root():
        return {"message": "Weather Agent is running!", "status": "healthy"}
    
    @app.get("/health")
    async def health():
        return {"status": "healthy", "agent": "weather_agent"}
    
    @app.post("/query")
    async def query_weather(request: dict):
        try:
            # Simple query processing
            city = request.get("city", "Atlanta")
            response = await weather_agent.run(f"Get weather data for {city}")
            return {"response": response, "city": city}
        except Exception as e:
            return {"error": str(e)}
    
    # Run the web server
    port = int(os.getenv('PORT', 8001))
    config = uvicorn.Config(app, host="0.0.0.0", port=port, log_level="info")
    server = uvicorn.Server(config)
    await server.serve()

if __name__ == "__main__":
    asyncio.run(main())
