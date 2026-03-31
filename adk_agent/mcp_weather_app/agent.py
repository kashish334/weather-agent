import os
import dotenv
from mcp_weather_app import tools
from google.adk.agents import LlmAgent

dotenv.load_dotenv()

weather_toolset = tools.get_weather_toolset()

# Read model from .env so it can be changed without touching code.
# gemini-1.5-flash works on both AI Studio and Vertex AI out of the box.
MODEL = os.getenv("AGENT_MODEL", "gemini-2.5-flash")

root_agent = LlmAgent(
    model=MODEL,
    name="weather_agent",
    instruction="""
        You are a weather assistant with access to live weather data.

        Always use the available tools before answering — never guess current conditions.

        You have two tools:
        - get_current_weather(city): real-time temperature, humidity, wind, and conditions
        - get_forecast(city, days): day-by-day forecast up to 16 days ahead

        When answering:
        - Fetch the data first, then respond based on what you get back
        - Give a short practical note at the end (umbrella? jacket? good for outdoor plans?)
        - For multi-city questions, call each city separately and compare
        - Keep it friendly and concise
    """,
    tools=[weather_toolset],
)
