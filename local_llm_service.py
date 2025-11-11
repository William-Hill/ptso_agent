"""
Local LLM Service
Provides a unified interface for local LLM backends (Ollama, vLLM, etc.)
"""

import asyncio
import aiohttp
import json
from typing import Dict, Any, Optional, List
from llm_config import LLMConfig, LLMProvider

class LocalLLMService:
    """Service for interacting with local LLM backends."""
    
    def __init__(self, config: LLMConfig):
        """Initialize the local LLM service.
        
        Args:
            config: LLM configuration
        """
        self.config = config
        self.base_url = config.config.get("base_url")
        self.model = config.get_model_name()
        self.temperature = config.config.get("temperature", 0.7)
        self.max_tokens = config.config.get("max_tokens", 4096)
    
    async def generate(self, prompt: str, system_prompt: str = None) -> str:
        """Generate text using the local LLM.
        
        Args:
            prompt: User prompt
            system_prompt: Optional system prompt
            
        Returns:
            Generated text
        """
        if self.config.provider == LLMProvider.OLLAMA:
            return await self._generate_ollama(prompt, system_prompt)
        elif self.config.provider == LLMProvider.VLLM:
            return await self._generate_vllm(prompt, system_prompt)
        else:
            return await self._generate_generic(prompt, system_prompt)
    
    async def _generate_ollama(self, prompt: str, system_prompt: str = None) -> str:
        """Generate text using Ollama."""
        url = f"{self.base_url}/api/generate"
        
        payload = {
            "model": self.model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": self.temperature,
                "num_predict": self.max_tokens
            }
        }
        
        if system_prompt:
            payload["system"] = system_prompt
        
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=payload) as response:
                if response.status == 200:
                    data = await response.json()
                    return data.get("response", "")
                else:
                    error_text = await response.text()
                    raise Exception(f"Ollama API error: {response.status} - {error_text}")
    
    async def _generate_vllm(self, prompt: str, system_prompt: str = None) -> str:
        """Generate text using vLLM."""
        url = f"{self.base_url}/v1/chat/completions"
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": self.temperature,
            "max_tokens": self.max_tokens
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=payload) as response:
                if response.status == 200:
                    data = await response.json()
                    return data["choices"][0]["message"]["content"]
                else:
                    error_text = await response.text()
                    raise Exception(f"vLLM API error: {response.status} - {error_text}")
    
    async def _generate_generic(self, prompt: str, system_prompt: str = None) -> str:
        """Generate text using a generic OpenAI-compatible API."""
        url = f"{self.base_url}/v1/chat/completions"
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": self.temperature,
            "max_tokens": self.max_tokens
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=payload) as response:
                if response.status == 200:
                    data = await response.json()
                    return data["choices"][0]["message"]["content"]
                else:
                    error_text = await response.text()
                    raise Exception(f"Generic API error: {response.status} - {error_text}")
    
    async def health_check(self) -> bool:
        """Check if the local LLM service is healthy."""
        try:
            if self.config.provider == LLMProvider.OLLAMA:
                url = f"{self.base_url}/api/tags"
            else:
                url = f"{self.base_url}/v1/models"
            
            async with aiohttp.ClientSession() as session:
                async with session.get(url, timeout=5) as response:
                    return response.status == 200
        except Exception:
            return False

# Global local LLM service
_local_llm_service = None

def get_local_llm_service() -> Optional[LocalLLMService]:
    """Get the global local LLM service."""
    return _local_llm_service

def initialize_local_llm_service(config: LLMConfig):
    """Initialize the global local LLM service."""
    global _local_llm_service
    _local_llm_service = LocalLLMService(config)

async def test_local_llm():
    """Test the local LLM service."""
    from llm_config import get_llm_config
    
    config = get_llm_config()
    if config.provider not in [LLMProvider.OLLAMA, LLMProvider.VLLM, LLMProvider.LOCAL]:
        print("❌ Not using a local LLM provider")
        return False
    
    service = LocalLLMService(config)
    
    print(f"🧪 Testing {config.provider.value} service...")
    
    # Health check
    if not await service.health_check():
        print(f"❌ {config.provider.value} service is not healthy")
        return False
    
    print(f"✅ {config.provider.value} service is healthy")
    
    # Test generation
    try:
        response = await service.generate("Hello, how are you?")
        print(f"✅ Generated response: {response[:100]}...")
        return True
    except Exception as e:
        print(f"❌ Generation failed: {e}")
        return False

if __name__ == "__main__":
    asyncio.run(test_local_llm())
