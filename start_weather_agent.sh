#!/bin/bash
set -e

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate
pip install --quiet -r requirements.txt

cd adk_agent
adk web --allow_origins "regex:https://.*\.cloudshell\.dev"
