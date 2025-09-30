"""
LLM Configuration System
Supports both local and commercial LLM backends
"""

import os
from typing import Dict, Any, Optional
from enum import Enum

class LLMProvider(Enum):
    """Supported LLM providers."""
    GEMINI = "gemini"
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    OLLAMA = "ollama"
    VLLM = "vllm"
    LOCAL = "local"

class LLMConfig:
    """Configuration for LLM backends."""
    
    def __init__(self, provider: LLMProvider = None, **kwargs):
        """Initialize LLM configuration.
        
        Args:
            provider: LLM provider to use
            **kwargs: Additional configuration parameters
        """
        self.provider = provider or self._detect_provider()
        self.config = self._get_default_config()
        self.config.update(kwargs)
    
    def _detect_provider(self) -> LLMProvider:
        """Auto-detect LLM provider from environment variables."""
        if os.getenv('OLLAMA_BASE_URL'):
            return LLMProvider.OLLAMA
        elif os.getenv('VLLM_BASE_URL'):
            return LLMProvider.VLLM
        elif os.getenv('OPENAI_API_KEY'):
            return LLMProvider.OPENAI
        elif os.getenv('ANTHROPIC_API_KEY'):
            return LLMProvider.ANTHROPIC
        elif os.getenv('GOOGLE_API_KEY') or os.getenv('GEMINI_API_KEY'):
            return LLMProvider.GEMINI
        else:
            return LLMProvider.GEMINI  # Default fallback
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Get default configuration for the provider."""
        configs = {
            LLMProvider.GEMINI: {
                "model": "gemini-2.0-flash",
                "api_key": os.getenv('GOOGLE_API_KEY') or os.getenv('GEMINI_API_KEY'),
                "base_url": "https://generativelanguage.googleapis.com/v1beta",
                "temperature": 0.7,
                "max_tokens": 4096
            },
            LLMProvider.OPENAI: {
                "model": "gpt-4o",
                "api_key": os.getenv('OPENAI_API_KEY'),
                "base_url": "https://api.openai.com/v1",
                "temperature": 0.7,
                "max_tokens": 4096
            },
            LLMProvider.ANTHROPIC: {
                "model": "claude-3-5-sonnet-20241022",
                "api_key": os.getenv('ANTHROPIC_API_KEY'),
                "base_url": "https://api.anthropic.com",
                "temperature": 0.7,
                "max_tokens": 4096
            },
            LLMProvider.OLLAMA: {
                "model": "llama3.1:8b",
                "base_url": os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
                "temperature": 0.7,
                "max_tokens": 4096
            },
            LLMProvider.VLLM: {
                "model": "meta-llama/Llama-3.1-8B-Instruct",
                "base_url": os.getenv('VLLM_BASE_URL', 'http://localhost:8000'),
                "temperature": 0.7,
                "max_tokens": 4096
            },
            LLMProvider.LOCAL: {
                "model": "local-model",
                "base_url": "http://localhost:8080",
                "temperature": 0.7,
                "max_tokens": 4096
            }
        }
        return configs.get(self.provider, configs[LLMProvider.GEMINI])
    
    def get_model_name(self) -> str:
        """Get the model name for the current provider."""
        return self.config.get("model", "gemini-2.0-flash")
    
    def get_adk_config(self) -> Dict[str, Any]:
        """Get configuration for Google ADK."""
        if self.provider == LLMProvider.GEMINI:
            return {
                "model": self.get_model_name(),
                "api_key": self.config.get("api_key"),
                "temperature": self.config.get("temperature", 0.7)
            }
        elif self.provider == LLMProvider.OPENAI:
            return {
                "model": f"openai/{self.get_model_name()}",
                "api_key": self.config.get("api_key"),
                "base_url": self.config.get("base_url"),
                "temperature": self.config.get("temperature", 0.7)
            }
        elif self.provider == LLMProvider.ANTHROPIC:
            return {
                "model": f"anthropic/{self.get_model_name()}",
                "api_key": self.config.get("api_key"),
                "base_url": self.config.get("base_url"),
                "temperature": self.config.get("temperature", 0.7)
            }
        elif self.provider == LLMProvider.OLLAMA:
            return {
                "model": f"ollama/{self.get_model_name()}",
                "base_url": self.config.get("base_url"),
                "temperature": self.config.get("temperature", 0.7)
            }
        elif self.provider == LLMProvider.VLLM:
            return {
                "model": f"vllm/{self.get_model_name()}",
                "base_url": self.config.get("base_url"),
                "temperature": self.config.get("temperature", 0.7)
            }
        else:
            return {
                "model": f"custom/{self.get_model_name()}",
                "base_url": self.config.get("base_url"),
                "temperature": self.config.get("temperature", 0.7)
            }
    
    def validate(self) -> bool:
        """Validate the configuration."""
        if self.provider in [LLMProvider.GEMINI, LLMProvider.OPENAI, LLMProvider.ANTHROPIC]:
            return bool(self.config.get("api_key"))
        elif self.provider in [LLMProvider.OLLAMA, LLMProvider.VLLM, LLMProvider.LOCAL]:
            return bool(self.config.get("base_url"))
        return True
    
    def __str__(self) -> str:
        """String representation of the configuration."""
        return f"LLMConfig(provider={self.provider.value}, model={self.get_model_name()})"

# Global LLM configuration
llm_config = LLMConfig()

def get_llm_config() -> LLMConfig:
    """Get the global LLM configuration."""
    return llm_config

def set_llm_provider(provider: LLMProvider, **kwargs):
    """Set the LLM provider and configuration."""
    global llm_config
    llm_config = LLMConfig(provider, **kwargs)

def print_llm_info():
    """Print current LLM configuration information."""
    config = get_llm_config()
    print(f"🤖 LLM Configuration:")
    print(f"   Provider: {config.provider.value}")
    print(f"   Model: {config.get_model_name()}")
    print(f"   Valid: {'✅' if config.validate() else '❌'}")
    
    if config.provider in [LLMProvider.OLLAMA, LLMProvider.VLLM, LLMProvider.LOCAL]:
        print(f"   Base URL: {config.config.get('base_url')}")
    elif config.provider in [LLMProvider.GEMINI, LLMProvider.OPENAI, LLMProvider.ANTHROPIC]:
        api_key = config.config.get('api_key')
        if api_key:
            print(f"   API Key: {'*' * (len(api_key) - 4) + api_key[-4:]}")
        else:
            print(f"   API Key: ❌ Not set")
