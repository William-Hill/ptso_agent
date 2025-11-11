#!/bin/bash

# Deployment script for A2A agents to Cloud Run

set -e

PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
REGION=${REGION:-"us-central1"}

echo "Deploying A2A agents to Cloud Run..."

# Build and push weather agent
echo "Building weather agent..."
docker build -f Dockerfile.weather -t gcr.io/$PROJECT_ID/weather-agent-a2a:latest .
docker push gcr.io/$PROJECT_ID/weather-agent-a2a:latest

# Deploy weather agent to Cloud Run
echo "Deploying weather agent..."
gcloud run deploy weather-agent-a2a \
  --image gcr.io/$PROJECT_ID/weather-agent-a2a:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8001 \
  --memory 2Gi \
  --cpu 1

# Build and push wardrobe agent
echo "Building wardrobe agent..."
docker build -f Dockerfile.wardrobe -t gcr.io/$PROJECT_ID/wardrobe-agent-a2a:latest .
docker push gcr.io/$PROJECT_ID/wardrobe-agent-a2a:latest

# Deploy wardrobe agent to Cloud Run
echo "Deploying wardrobe agent..."
gcloud run deploy wardrobe-agent-a2a \
  --image gcr.io/$PROJECT_ID/wardrobe-agent-a2a:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8002 \
  --memory 2Gi \
  --cpu 1

echo "Deployment complete!"
echo "Weather agent URL: https://weather-agent-a2a-xxxxx-uc.a.run.app"
echo "Wardrobe agent URL: https://wardrobe-agent-a2a-xxxxx-uc.a.run.app"

