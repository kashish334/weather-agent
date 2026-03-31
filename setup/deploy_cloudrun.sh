#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="us-central1"
SERVICE="weather-agent"
REPO="${REGION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE}"
IMAGE="${REPO}/${SERVICE}"

echo "Project : $PROJECT_ID"
echo "Image   : $IMAGE"
echo ""

# 1. Enable required APIs
echo "Enabling APIs..."
gcloud services enable artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    --project="$PROJECT_ID"

# 2. Create Artifact Registry repo if it doesn't exist
echo "Creating Artifact Registry repository (if needed)..."
gcloud artifacts repositories create "$SERVICE" \
    --repository-format=docker \
    --location="$REGION" \
    --project="$PROJECT_ID" 2>/dev/null || echo "  (already exists, skipping)"

# 3. Grant Cloud Build SA permission to push to this repo
CB_SA="$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"
echo "Granting Artifact Registry Writer to Cloud Build SA: $CB_SA"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${CB_SA}" \
    --role="roles/artifactregistry.writer" \
    --quiet

# 4. Build and push via Cloud Build
echo "Building image..."
gcloud builds submit --tag "$IMAGE" --project="$PROJECT_ID" .

# 5. Deploy to Cloud Run
echo "Deploying to Cloud Run..."
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

# 6. Print live URL
URL=$(gcloud run services describe "$SERVICE" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)")

echo ""
echo "Live at: $URL"