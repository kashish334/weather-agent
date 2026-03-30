import os
import sys
import dotenv
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset, StdioServerParameters

dotenv.load_dotenv()

_SERVER = os.path.join(os.path.dirname(__file__), "weather_server.py")


def get_weather_toolset() -> McpToolset:
    return McpToolset(
        connection_params=StdioServerParameters(
            command=sys.executable,
            args=[_SERVER],
            env={**os.environ},
        )
    )
