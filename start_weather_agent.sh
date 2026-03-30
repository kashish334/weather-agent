#!/bin/bash
set -e

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate
pip install --quiet -r requirements.txt
npm install -g mcp-openmeteo 2>/dev/null || true

cd adk_agent
adk web
