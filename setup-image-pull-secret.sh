#!/bin/bash

# Setup image pull secret for private GitHub Container Registry
# This script is only needed if your ghcr.io packages are private

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Image Pull Secret${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}This script creates a Kubernetes secret for pulling private images from GitHub Container Registry.${NC}"
echo -e "${YELLOW}If your packages are public, you don't need this.${NC}"
echo ""

# Check if k0s is running
if ! sudo k0s status &> /dev/null; then
    echo -e "${RED}Error: k0s is not running${NC}"
    echo "Please start k0s first with: sudo k0s start"
    exit 1
fi

# Prompt for GitHub credentials
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -sp "Enter your GitHub Personal Access Token (with read:packages scope): " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: Username and token are required${NC}"
    exit 1
fi

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace...${NC}"
sudo k0s kubectl apply -f k8s/namespace.yaml

# Delete existing secret if it exists
sudo k0s kubectl delete secret ghcr-secret -n ms --ignore-not-found=true

# Create the secret
echo -e "${YELLOW}Creating image pull secret...${NC}"
sudo k0s kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username=$GITHUB_USERNAME \
    --docker-password=$GITHUB_TOKEN \
    --namespace=ms \
    --dry-run=client -o yaml | sudo k0s kubectl apply -f -
echo -e "${GREEN}✓ Image pull secret created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Update your k8s/*.yaml files to include imagePullSecrets:"
    echo "   spec:"
    echo "     imagePullSecrets:"
    echo "     - name: ghcr-secret"
    echo ""
    echo "2. Deploy your services: ./deploy-remote.sh"
else
    echo -e "${RED}Error: Failed to create secret${NC}"
    exit 1
fi
