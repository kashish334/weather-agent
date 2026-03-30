import os
import dotenv
from mcp_weather_app import tools
from google.adk.agents import LlmAgent

dotenv.load_dotenv()

weather_toolset = tools.get_weather_toolset()

root_agent = LlmAgent(
    model="gemini-2.0-flash",
    name="weather_agent",
    instruction="""
        You are a weather assistant that gives people accurate, useful weather information.

        You have access to a live weather tool. Always use it before answering — never guess
        or rely on memory for current conditions. Weather changes constantly.

        When someone asks about weather:
        - Pull the live data first
        - Tell them the temperature, what the sky looks like, humidity, and wind
        - Give a short practical note at the end (good day for a walk? bring a jacket?)

        If they ask about multiple cities, check each one separately and compare them.
        Keep answers friendly and to the point — nobody wants a wall of text about clouds.
    """,
    tools=[weather_toolset],
)
