#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "No project set. Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "Project: $PROJECT_ID"

gcloud services enable aiplatform.googleapis.com --project="$PROJECT_ID"
gcloud services enable run.googleapis.com --project="$PROJECT_ID"
gcloud services enable cloudbuild.googleapis.com --project="$PROJECT_ID"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/../adk_agent/mcp_weather_app/.env"
mkdir -p "$(dirname "$ENV_FILE")"

echo ""
echo "Choose how to authenticate the model:"
echo "  1) Google AI Studio API key (easiest, free)"
echo "  2) Vertex AI (uses your GCP project)"
read -p "Enter 1 or 2 [default: 1]: " CHOICE
CHOICE=${CHOICE:-1}

if [ "$CHOICE" = "2" ]; then
    cat > "$ENV_FILE" <<ENVEOF
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_CLOUD_LOCATION=us-central1
AGENT_MODEL=gemini-1.5-flash
ENVEOF
    echo "Vertex AI config written. Run: gcloud auth application-default login"
else
    read -p "Paste your Google AI Studio API key: " API_KEY
    cat > "$ENV_FILE" <<ENVEOF
GOOGLE_GENAI_USE_VERTEXAI=0
GOOGLE_API_KEY=$API_KEY
AGENT_MODEL=gemini-1.5-flash
ENVEOF
    echo "AI Studio config written."
fi

echo "Done. .env written to $ENV_FILE"
