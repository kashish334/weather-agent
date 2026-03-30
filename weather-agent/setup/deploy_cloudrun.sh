#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="us-central1"
SERVICE="weather-agent"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE}"

echo "Building and deploying $SERVICE to Cloud Run..."

gcloud builds submit --tag "$IMAGE" --project="$PROJECT_ID" .

gcloud run deploy "$SERVICE" \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --memory 1Gi \
    --cpu 1 \
    --set-env-vars "GOOGLE_GENAI_USE_VERTEXAI=1,GOOGLE_CLOUD_PROJECT=${PROJECT_ID},GOOGLE_CLOUD_LOCATION=${REGION}" \
    --project="$PROJECT_ID"

URL=$(gcloud run services describe "$SERVICE" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)")

echo ""
echo "Live at: $URL"
