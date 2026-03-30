# Weather Agent

A small AI agent I built for the ADK + MCP mini project. It connects to a live weather source through MCP, pulls real forecast data, and answers questions based on what it actually retrieves rather than what the model remembers from training.

---

## What it does

You ask it something like "what's the weather in Ahmedabad today?" or "should I carry a jacket in London this weekend?" and it goes and fetches the real data before answering. The whole point is that the agent's response is grounded in live retrieval, not guesswork.

Under the hood it uses:
- **Google ADK** to define and run the agent
- **MCP (Model Context Protocol)** to connect to the weather tool
- **Open-Meteo** as the data source (free, no API key needed)
- **Gemini 2.0 Flash** as the model

---

## How it's put together

```
weather-agent/
├── adk_agent/
│   └── mcp_weather_app/
│       ├── __init__.py
│       ├── agent.py          ← agent definition and instructions
│       └── tools.py          ← MCP toolset setup
├── setup/
│   ├── setup_env.sh          ← enable GCP APIs, write .env
│   └── deploy_cloudrun.sh    ← build image and push to Cloud Run
├── cleanup/
│   └── cleanup_env.sh        ← tear down Cloud Run and the image
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── start_weather_agent.sh    ← run locally in one step
└── README.md
```

The agent code is all in `adk_agent/mcp_weather_app/`. `agent.py` defines the LlmAgent and its instructions. `tools.py` spins up the MCP connection to Open-Meteo via a stdio subprocess (npx handles the install automatically).

---

## Running it locally

You'll need Python 3.11+, Node.js 18+, and a Google Cloud project set up.

**Step 1 — authenticate**

```bash
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

**Step 2 — set up the environment**

```bash
chmod +x setup/setup_env.sh
./setup/setup_env.sh
```

This enables the Vertex AI, Cloud Run, and Cloud Build APIs and drops a `.env` file in the right place.

**Step 3 — run**

```bash
chmod +x start_weather_agent.sh
./start_weather_agent.sh
```

Open `http://localhost:8000` in your browser and start chatting.

---

## Deploying to Cloud Run

```bash
chmod +x setup/deploy_cloudrun.sh
./setup/deploy_cloudrun.sh
```

It builds the container through Cloud Build, pushes it to Container Registry, and deploys it to Cloud Run in us-central1. The Cloud Run URL prints at the end — that's your submission link.

---

## Things you can ask it

- "What's the weather in Mumbai right now?"
- "Is it going to rain in Delhi this week?"
- "Compare the weather in New York and Toronto today."
- "Good day for a run in Bangalore?"

Each of those triggers a real MCP tool call to Open-Meteo. The agent won't answer without fetching first.

---

## Why Open-Meteo

Honestly, it was the simplest option that actually worked end-to-end. It's free, there's no API key to manage, the `mcp-openmeteo` npm package exposes it as proper MCP tools, and the JSON it returns (temperatures, wind speed, WMO weather codes) is structured enough that the model can reason over it without any extra parsing.

---

## Cleanup

```bash
chmod +x cleanup/cleanup_env.sh
./cleanup/cleanup_env.sh
```

Deletes the Cloud Run service and the container image so you're not paying for idle resources.
