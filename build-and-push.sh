#!/bin/bash

# Configuration
IMAGE_NAME="liver23/subql-node-ethereum-fixed"
IMAGE_TAG="v6.1.1-fixed"
REGISTRY="docker.io"  # Docker Hub

# Build the custom image
echo "Building custom SubQuery Ethereum node image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Tag for your registry
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

# Push to your registry
echo "Pushing image to registry..."
docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Custom image built and pushed successfully!"
echo "Image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Update your docker-compose.yml to use:"
echo "image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" 