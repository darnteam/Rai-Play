import httpx
from typing import Optional
import os
from configuration import GROQ_API_KEY, GROQ_API_URL, MODEL_NAME


class ChatService:
    """Service for interacting with the Groq API for chat completion."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or GROQ_API_KEY
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        self.system_prompt = (
            "You are a friendly assistant for teens aged 12 to 17. "
            "Answer clearly and kindly. Keep it short and easy to understand. "
            "Use simple words and give examples when helpful. "
            "Be casual and fun, but avoid slang or anything inappropriate. "
            "If you're unsure or it's not safe to answer, suggest they ask a trusted adult. "
            "Stay kind, helpful, and supportive."
        )


    async def get_chat_response(self, user_message: str) -> str:
        """Send a prompt to the Groq API and return the model's response."""
        payload = {
            "model": MODEL_NAME,
            "messages": [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": user_message}
            ],
            "temperature": 0.7
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(GROQ_API_URL, json=payload, headers=self.headers)
            if response.status_code != 200:
                raise RuntimeError(f"Groq API error: {response.status_code} - {response.text}")

            data = response.json()
            return data["choices"][0]["message"]["content"].strip()
