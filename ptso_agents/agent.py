from google.adk.agents.llm_agent import Agent
from google.adk.agents.remote_a2a_agent import AGENT_CARD_WELL_KNOWN_PATH
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent
from google.genai import types
from utils.util import load_instruction_from_file


wardrobe_agent = RemoteA2aAgent(
    name="wardrobe_agent",
    description="Agent that handles fetching wardrobe data.",
    agent_card=(
        f"http://localhost:8005/a2a/wardrobe_agent{AGENT_CARD_WELL_KNOWN_PATH}"
    ),
)

weather_agent = RemoteA2aAgent(
    name="weather_agent",
    description="Agent that handles fetching weather data.",
    agent_card=(
        f"http://localhost:8005/a2a/weather_agent{AGENT_CARD_WELL_KNOWN_PATH}"
    ),
)


root_agent = Agent(
    model="gemini-2.0-flash",
    name="root_agent",
    description="You are an agent that can help a user with their wardrobe. You have subagents that can do this",
    instruction=load_instruction_from_file("ptso_agent_instructions.txt"),
    sub_agents=[wardrobe_agent, weather_agent],
    generate_content_config=types.GenerateContentConfig(
        safety_settings=[
            types.SafetySetting(  # avoid false alarm about rolling dice.
                category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold=types.HarmBlockThreshold.OFF,
            ),
        ]
    ),
)