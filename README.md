# Weather Agent

An AI agent built with Google ADK that uses MCP to fetch live weather data and answer questions grounded in real retrieved information.

---

## What it does

You ask something like "what's the weather in Ahmedabad today?" or "will it rain in London this week?" and the agent calls a live weather tool before answering. It never guesses — every response is based on data it actually retrieved.

Under the hood:
- **Google ADK** runs the agent loop
- **MCP (Model Context Protocol)** connects the agent to a local weather server
- **Open-Meteo** provides the weather data (free, no API key needed)
- **Gemini 2.0 Flash** is the model

---

## How it's put together

```
weather-agent/
├── adk_agent/
│   └── mcp_weather_app/
│       ├── __init__.py
│       ├── agent.py             ← LlmAgent definition
│       ├── tools.py             ← MCP toolset pointing to weather_server.py
│       └── weather_server.py   ← our MCP server (FastMCP + Open-Meteo)
├── setup/
│   ├── setup_env.sh             ← enable GCP APIs, write .env
│   └── deploy_cloudrun.sh       ← build and deploy to Cloud Run
├── cleanup/
│   └── cleanup_env.sh
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── start_weather_agent.sh
└── README.md
```

`weather_server.py` is a Python MCP server built with FastMCP. It exposes two tools — `get_current_weather` and `get_forecast` — which geocode the city name and pull data from Open-Meteo's REST API. The ADK spawns this server as a subprocess via `StdioServerParameters`, so there's nothing extra to install or run manually.

---

## Running locally

You need Python 3.11+, a Google Cloud project, and about 2 minutes.

**Step 1 — authenticate**

```bash
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

**Step 2 — set up environment**

```bash
chmod +x setup/setup_env.sh
./setup/setup_env.sh
```

**Step 3 — run**

```bash
chmod +x start_weather_agent.sh
./start_weather_agent.sh
```

Open `http://localhost:8000` in your browser.

---

## Deploy to Cloud Run

```bash
chmod +x setup/deploy_cloudrun.sh
./setup/deploy_cloudrun.sh
```

Builds via Cloud Build, deploys to Cloud Run in us-central1, and prints the public URL at the end.

---

## Things to try

- "What's the weather in Mumbai right now?"
- "Will it rain in Delhi this week?"
- "Compare the weather in Tokyo and Sydney today."
- "Is it a good day to go hiking in Bangalore?"

---

## Cleanup

```bash
chmod +x cleanup/cleanup_env.sh
./cleanup/cleanup_env.sh
```
