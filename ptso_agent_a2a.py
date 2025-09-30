"""
PTSO Agent with A2A Protocol Support
Updated to consume remote A2A agents instead of local sub-agents.
"""

from google.adk.agents.llm_agent import LlmAgent
from a2a.types import AgentCard, AgentCapabilities, AgentSkill
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent
from google.adk.a2a.utils.agent_to_a2a import to_a2a
from dotenv import load_dotenv
from utils.util import load_instruction_from_file
from llm_config import get_llm_config, print_llm_info
import asyncio
import os

load_dotenv()

class PTSOAgentA2A:
    """PTSO Agent that coordinates with remote A2A agents."""
    
    def __init__(self, weather_agent_url: str = None, wardrobe_agent_url: str = None):
        """Initialize the PTSO agent with remote A2A agent URLs.
        
        Args:
            weather_agent_url: URL of the weather A2A agent service
            wardrobe_agent_url: URL of the wardrobe A2A agent service
        """
        self.weather_agent_url = weather_agent_url or os.getenv('WEATHER_AGENT_URL', 'http://localhost:8001')
        self.wardrobe_agent_url = wardrobe_agent_url or os.getenv('WARDROBE_AGENT_URL', 'http://localhost:8002')
        
        # Create remote A2A agents using agent card URLs (like in L5.py example)
        self.weather_agent = RemoteA2aAgent(
            name="weather_agent",
            description="Fetches current weather data from PostgreSQL database",
            agent_card=f"{self.weather_agent_url}/.well-known/agent-card.json"
        )
        self.wardrobe_agent = RemoteA2aAgent(
            name="wardrobe_agent", 
            description="Provides clothing recommendations based on temperature and weather conditions",
            agent_card=f"{self.wardrobe_agent_url}/.well-known/agent-card.json"
        )
        
        # Get LLM configuration
        llm_config = get_llm_config()
        print_llm_info()
        
        # Create the main PTSO agent with remote A2A agents as sub-agents
        self.ptso_agent = LlmAgent(
            name="ptso_agent",
            model=llm_config.get_model_name(),
            instruction=load_instruction_from_file("agent_instructions/ptso_agent_instructions.txt"),
            description="You are an agent that can help a user with their wardrobe by coordinating with specialized weather and wardrobe agents.",
            sub_agents=[self.weather_agent, self.wardrobe_agent]
        )
    
    async def get_weather_data(self, city: str) -> dict:
        """Get weather data from the remote weather A2A agent.
        
        Args:
            city: City name to get weather for
            
        Returns:
            dict: Weather data including temperature
        """
        try:
            print(f"Calling Weather Agent at {self.weather_agent_url} for city: {city}")
            # Use the correct method for RemoteA2aAgent - iterate through async generator
            response_parts = []
            async for part in self.weather_agent.run_async(f"Get weather data for {city}"):
                response_parts.append(part)
            response = "".join(str(part) for part in response_parts)
            return response
        except Exception as e:
            print(f"Error getting weather data: {e}")
            return {"error": "Failed to get weather data"}
    
    async def get_wardrobe_recommendations(self, temperature: float, city: str = None) -> dict:
        """Get wardrobe recommendations from the remote wardrobe A2A agent.
        
        Args:
            temperature: Current temperature
            city: Optional city name for context
            
        Returns:
            dict: Wardrobe recommendations
        """
        try:
            print(f"Calling Wardrobe Agent at {self.wardrobe_agent_url} for temp: {temperature}, city: {city}")
            # Use the correct method for RemoteA2aAgent - iterate through async generator
            response_parts = []
            async for part in self.wardrobe_agent.run_async(f"Get wardrobe recommendations for temperature {temperature} in {city or 'the current location'}"):
                response_parts.append(part)
            response = "".join(str(part) for part in response_parts)
            return response
        except Exception as e:
            print(f"Error getting wardrobe recommendations: {e}")
            return {"error": "Failed to get wardrobe recommendations"}
    
    async def process_user_request(self, user_input: str) -> str:
        """Process a user request by coordinating with remote A2A agents.
        
        Args:
            user_input: User's request (e.g., "What should I wear in Atlanta?")
            
        Returns:
            str: Formatted response with wardrobe recommendations
        """
        try:
            # Use the main PTSO agent with sub-agents (like in L5.py example)
            response_parts = []
            async for part in self.ptso_agent.run_async(user_input):
                # Handle different types of response parts
                if hasattr(part, 'text'):
                    response_parts.append(part.text)
                elif hasattr(part, 'content'):
                    response_parts.append(part.content)
                else:
                    response_parts.append(str(part))
            response = "".join(response_parts)
            return response
            
        except Exception as e:
            return f"Sorry, I encountered an error processing your request: {str(e)}"

async def create_ptso_agent_a2a():
    """Create and return a configured PTSO agent with A2A support.
    
    Returns:
        PTSOAgentA2A: Configured PTSO agent
    """
    # URLs can be configured via environment variables or passed as parameters
    return PTSOAgentA2A()

async def main():
    """Main function to demonstrate A2A agent usage."""
    ptso_agent = await create_ptso_agent_a2a()
    
    # Example usage
    user_request = "What should I wear in Atlanta today?"
    response = await ptso_agent.process_user_request(user_request)
    print(response)

async def web_interface():
    """Simple web interface for the PTSO agent."""
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    import uvicorn
    
    app = FastAPI(title="PTSO Agent A2A", description="Wardrobe recommendation system with A2A protocol")
    
    class UserRequest(BaseModel):
        message: str
    
    class AgentResponse(BaseModel):
        response: str
    
    # Initialize the agent
    ptso_agent = await create_ptso_agent_a2a()
    
    @app.get("/")
    async def root():
        return {"message": "PTSO Agent A2A is running!", "status": "healthy"}
    
    @app.get("/health")
    async def health():
        return {"status": "healthy", "agent_urls": {
            "weather": ptso_agent.weather_agent_url,
            "wardrobe": ptso_agent.wardrobe_agent_url
        }}
    
    @app.post("/ask", response_model=AgentResponse)
    async def ask_agent(request: UserRequest):
        try:
            response = await ptso_agent.process_user_request(request.message)
            return AgentResponse(response=response)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    # Run the web server
    port = int(os.getenv('PORT', 8000))
    config = uvicorn.Config(app, host="0.0.0.0", port=port, log_level="info")
    server = uvicorn.Server(config)
    await server.serve()

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "web":
        asyncio.run(web_interface())
    else:
        asyncio.run(main())

