from google.adk.agents import Agent
from google.adk.tools.mcp_tool.mcp_toolset import (
    MCPToolset,
    StdioServerParameters,
    StdioConnectionParams,
)

from utils.util import load_instruction_from_file

# Initialize sub-agents with their MCP tools
connection_params = StdioConnectionParams(
    server_params=StdioServerParameters(
        command="npx",
        args=[
            "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://ptso_user:ptso_password@localhost:5432/ptso_db"
            ]
    )
)


# Create sub-agents with their respective tools
try:
    root_agent = Agent(
        name="weather_agent",
        model="gemini-2.0-flash",
        instruction="""You are a helpful weather information agent that provides users with accurate weather and time information for different cities. Your responses should be clear, concise, and informative.

Database Information:
- You have access to a PostgreSQL database containing weather data
- The data is stored in a table called `weather_data`
- The table schema includes:
  - name: The city name
  - temp: The temperature reading
  - timestamp: When the weather reading was taken

Guidelines:
1. When users ask about weather in a specific city:
   - Query the weather_data table using the city name
   - Provide both the temperature and when it was recorded
   - If multiple readings exist, use the most recent one

2. When users ask about time:
   - Use the timestamp information from the weather data
   - Convert to the appropriate timezone if specified
   - If no recent data exists for a city, acknowledge this

3. Format your responses professionally:
   - Temperature should include units (e.g., °C or °F)
   - Timestamps should be in a readable format
   - Clearly indicate if data is not available

Always verify the data exists before making statements about weather conditions. If data is outdated or missing, inform the user accordingly.
 **Output:** Print ONLY the temperature and city's name, ready for the visualizer.""",
        tools=[
            MCPToolset(
                connection_params=connection_params,
            )
        ],
        output_key="temperature"
    )
except Exception as e:
    print(f"Error creating weather agent: {e}")