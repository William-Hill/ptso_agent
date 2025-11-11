"""
Wardrobe Agent with A2A Protocol Support
Exposes the wardrobe agent as an A2A agent that can be consumed by other agents.
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

async def create_wardrobe_agent_a2a():
    """Creates a wardrobe agent that can be exposed via A2A protocol.
    
    Returns:
        FastAPI app: The A2A-enabled wardrobe agent app.
    """
    # Get LLM configuration
    llm_config = get_llm_config()
    print_llm_info()
    
    # Create the underlying LLM agent with configurable model
    wardrobe_agent = LlmAgent(
        name="wardrobe_agent",
        model=llm_config.get_model_name(),
        description="You are a helpful agent who can help a user pick options for their wardrobe.",
        instruction=load_instruction_from_file("agent_instructions/wardrobe_agent_instructions.txt"),
        output_key="wardrobe_recommendations"
    )
    
    # Create Agent Card for A2A exposure
    agent_card = AgentCard(
        name="Wardrobe Agent",
        description="Provides clothing recommendations based on temperature and weather conditions",
        version="1.0.0",
        url="http://localhost:8002",
        defaultInputModes=["text/plain"],
        defaultOutputModes=["text/plain"],
        capabilities={},
        skills=[]
    )
    
    # Use to_a2a() to create A2A-compatible app
    a2a_app = to_a2a(wardrobe_agent, port=8002, agent_card=agent_card)
    
    return a2a_app

def main():
    """Main function to run the wardrobe agent as an A2A service."""
    import uvicorn
    print("Wardrobe Agent A2A service starting...")
    uvicorn.run("wardrobe_agent_a2a:a2a_app", host="0.0.0.0", port=8002, reload=False)

# Create the A2A app at module level
import asyncio
a2a_app = asyncio.run(create_wardrobe_agent_a2a())

if __name__ == "__main__":
    main()

