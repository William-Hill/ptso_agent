#!/usr/bin/env python3
"""
Test script for A2A agents running in Docker Compose
"""

import asyncio
import aiohttp
import json
import sys

async def test_agent_health(agent_name: str, url: str) -> bool:
    """Test if an agent is healthy."""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{url}/health") as response:
                if response.status == 200:
                    data = await response.json()
                    print(f"✅ {agent_name}: {data}")
                    return True
                else:
                    print(f"❌ {agent_name}: HTTP {response.status}")
                    return False
    except Exception as e:
        print(f"❌ {agent_name}: {e}")
        return False

async def test_ptso_agent():
    """Test the PTSO agent with a sample request."""
    try:
        async with aiohttp.ClientSession() as session:
            payload = {
                "message": "What should I wear in Atlanta today?"
            }
            
            async with session.post(
                "http://localhost:8000/ask",
                json=payload,
                headers={"Content-Type": "application/json"}
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    print("✅ PTSO Agent Response:")
                    print(f"   {data['response']}")
                    return True
                else:
                    print(f"❌ PTSO Agent: HTTP {response.status}")
                    error_text = await response.text()
                    print(f"   Error: {error_text}")
                    return False
    except Exception as e:
        print(f"❌ PTSO Agent: {e}")
        return False

async def main():
    """Run all tests."""
    print("🧪 Testing A2A Agent System...")
    print("=" * 50)
    
    # Test individual agents
    agents = [
        ("Weather Agent", "http://localhost:8001"),
        ("Wardrobe Agent", "http://localhost:8002"),
        ("PTSO Agent", "http://localhost:8000")
    ]
    
    all_healthy = True
    
    for agent_name, url in agents:
        healthy = await test_agent_health(agent_name, url)
        all_healthy = all_healthy and healthy
    
    print("\n" + "=" * 50)
    
    if all_healthy:
        print("🎉 All agents are healthy!")
        
        # Test the full workflow
        print("\n🔄 Testing full workflow...")
        success = await test_ptso_agent()
        
        if success:
            print("\n✅ A2A Agent System is working correctly!")
            sys.exit(0)
        else:
            print("\n❌ A2A Agent System test failed!")
            sys.exit(1)
    else:
        print("❌ Some agents are not healthy!")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
