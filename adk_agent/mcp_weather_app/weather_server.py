"""
weather_server.py

A small MCP server that exposes two tools:
  - get_current_weather(city)
  - get_forecast(city, days)

It geocodes the city name using Open-Meteo's free geocoding API,
then fetches weather data from Open-Meteo's forecast API.
No API key required.
"""

import sys
import requests
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("weather")

WMO_CODES = {
    0: "Clear sky",
    1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Icy fog",
    51: "Light drizzle", 53: "Moderate drizzle", 55: "Dense drizzle",
    61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain",
    71: "Slight snow", 73: "Moderate snow", 75: "Heavy snow",
    80: "Slight showers", 81: "Moderate showers", 82: "Violent showers",
    95: "Thunderstorm", 96: "Thunderstorm with hail", 99: "Thunderstorm with heavy hail",
}


def geocode(city: str) -> dict:
    url = "https://geocoding-api.open-meteo.com/v1/search"
    resp = requests.get(url, params={"name": city, "count": 1, "language": "en", "format": "json"}, timeout=10)
    resp.raise_for_status()
    results = resp.json().get("results")
    if not results:
        raise ValueError(f"City not found: {city}")
    r = results[0]
    return {"lat": r["latitude"], "lon": r["longitude"], "name": r["name"], "country": r.get("country", "")}


@mcp.tool()
def get_current_weather(city: str) -> str:
    """Get the current weather conditions for a city.

    Args:
        city: Name of the city, e.g. 'London', 'Mumbai', 'New York'
    """
    loc = geocode(city)
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": loc["lat"],
        "longitude": loc["lon"],
        "current": "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weathercode,precipitation",
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "timezone": "auto",
    }
    resp = requests.get(url, params=params, timeout=10)
    resp.raise_for_status()
    c = resp.json()["current"]

    condition = WMO_CODES.get(c["weathercode"], "Unknown")
    return (
        f"Current weather in {loc['name']}, {loc['country']}:\n"
        f"  Temperature   : {c['temperature_2m']}°C (feels like {c['apparent_temperature']}°C)\n"
        f"  Condition     : {condition}\n"
        f"  Humidity      : {c['relative_humidity_2m']}%\n"
        f"  Wind          : {c['wind_speed_10m']} km/h\n"
        f"  Precipitation : {c['precipitation']} mm"
    )


@mcp.tool()
def get_forecast(city: str, days: int = 7) -> str:
    """Get a day-by-day weather forecast for a city.

    Args:
        city: Name of the city
        days: Number of days to forecast (1-16, default 7)
    """
    days = max(1, min(days, 16))
    loc = geocode(city)
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": loc["lat"],
        "longitude": loc["lon"],
        "daily": "temperature_2m_max,temperature_2m_min,weathercode,precipitation_sum,wind_speed_10m_max",
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "timezone": "auto",
        "forecast_days": days,
    }
    resp = requests.get(url, params=params, timeout=10)
    resp.raise_for_status()
    daily = resp.json()["daily"]

    lines = [f"{days}-day forecast for {loc['name']}, {loc['country']}:\n"]
    for i, date in enumerate(daily["time"]):
        condition = WMO_CODES.get(daily["weathercode"][i], "Unknown")
        lines.append(
            f"  {date}  {condition:<25} "
            f"High {daily['temperature_2m_max'][i]}°C / Low {daily['temperature_2m_min'][i]}°C  "
            f"Rain {daily['precipitation_sum'][i]}mm  Wind {daily['wind_speed_10m_max'][i]}km/h"
        )
    return "\n".join(lines)


if __name__ == "__main__":
    mcp.run(transport="stdio")
