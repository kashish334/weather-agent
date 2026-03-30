import os
import dotenv
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters


def get_weather_toolset() -> MCPToolset:
    dotenv.load_dotenv()

    return MCPToolset(
        connection_params=StdioServerParameters(
            command="npx",
            args=["-y", "mcp-openmeteo"],
            env={**os.environ},
        )
    )
