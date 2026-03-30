#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="us-central1"
SERVICE="weather-agent"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE}"

gcloud run services delete "$SERVICE" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --quiet || true

gcloud container images delete "$IMAGE" \
    --project="$PROJECT_ID" \
    --force-delete-tags \
    --quiet || true

echo "Cleanup done."
