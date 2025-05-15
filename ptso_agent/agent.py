from google.adk.agents.llm_agent import LlmAgent
from google.adk.agents.sequential_agent import SequentialAgent
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters
from dotenv import load_dotenv
from utils.util import load_instruction_from_file
from contextlib import AsyncExitStack
import asyncio

load_dotenv()  # 🔑 Load API keys

async def get_agent_async():
    """Creates and configures the root agent with all sub-agents.

    Returns:
        tuple:
            - LlmAgent: The root PTSO agent with properly initialized sub-agents
            - AsyncExitStack: Combined exit stack for all MCP resources
    """
    # Create a combined exit stack for all resources
    exit_stack = AsyncExitStack()
    
    # Initialize sub-agents with their MCP tools
    weather_tools, weather_exit = await MCPToolset.from_server(
        connection_params=StdioServerParameters(
            command="npx",
            args=[
                "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://ptso_user:ptso_password@localhost:5432/ptso_db"
            ]
        )
    )
    await exit_stack.enter_async_context(weather_exit)
    
    wardrobe_tools, wardrobe_exit = await MCPToolset.from_server(
        connection_params=StdioServerParameters(
            command="npx",
            args=[
                "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://ptso_user:ptso_password@localhost:5432/ptso_db"
            ]
        )
    )
    await exit_stack.enter_async_context(wardrobe_exit)

    # Create sub-agents with their respective tools
    weather_agent = LlmAgent(
        name="weather_agent",
        model="gemini-2.0-flash",
        instruction=load_instruction_from_file("../agent_instructions/weather_agent_instructions.txt"),
        tools=weather_tools,
        output_key="temperature"
    )

    wardrobe_agent = LlmAgent(
        name="wardrobe_agent",
        model="gemini-2.0-flash",
        description="You are a helpful agent who can help a user pick options for their wardrobe.",
        instruction=load_instruction_from_file("../agent_instructions/wardrobe_agent_instructions.txt"),
        tools=wardrobe_tools,
        output_key="wardrobe_recommendations"
    )

    # Create the PTSO agent with initialized sub-agents
    ptso_agent = SequentialAgent(
        name="ptso_agent",
        description="You are an agent that can help a user with their wardrobe. You have subagents that can do this",
        sub_agents=[weather_agent, wardrobe_agent],
    )

    return ptso_agent, exit_stack


# Create the root agent
root_agent = get_agent_async()