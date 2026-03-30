FROM python:3.12-slim

RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY adk_agent/ ./adk_agent/

RUN npm install -g mcp-openmeteo

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "cd adk_agent && adk web --host 0.0.0.0 --port ${PORT}"]
