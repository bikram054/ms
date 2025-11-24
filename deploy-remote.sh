#!/bin/bash

# Deploy microservices to k0s using prebuilt images from GitHub Container Registry
# Images are pulled from ghcr.io/bikram054/ms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}K0s Deployment - Remote Images${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if k0s is running
echo -e "${YELLOW}Checking k0s status...${NC}"
if ! sudo k0s status &> /dev/null; then
    echo -e "${RED}Error: k0s is not running${NC}"
    echo "Please start k0s first with: sudo k0s start"
    exit 1
fi
echo -e "${GREEN}✓ k0s is running${NC}"
echo ""

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace...${NC}"
sudo k0s kubectl apply -f k8s/namespace.yaml
echo -e "${GREEN}✓ Namespace created/verified${NC}"
echo ""

# Pre-pull images for faster deployment
echo -e "${YELLOW}Pre-pulling images from ghcr.io/bikram054/ms...${NC}"
for service in eureka-server gateway-server user-service product-service order-service; do
    echo "  Pulling $service..."
    sudo k0s ctr images pull ghcr.io/bikram054/ms/$service:latest 2>/dev/null || true
done
echo -e "${GREEN}✓ Images pre-pulled${NC}"
echo ""

# Deploy all services
echo -e "${YELLOW}Deploying microservices...${NC}"
echo "Images will be pulled from: ghcr.io/bikram054/ms"
echo ""

sudo k0s kubectl apply -f k8s/eureka-server.yaml
echo -e "${GREEN}✓ Eureka Server deployed${NC}"

sudo k0s kubectl apply -f k8s/gateway-server.yaml
echo -e "${GREEN}✓ Gateway Server deployed${NC}"

sudo k0s kubectl apply -f k8s/user-service.yaml
echo -e "${GREEN}✓ User Service deployed${NC}"

sudo k0s kubectl apply -f k8s/product-service.yaml
echo -e "${GREEN}✓ Product Service deployed${NC}"

sudo k0s kubectl apply -f k8s/order-service.yaml
echo -e "${GREEN}✓ Order Service deployed${NC}"

echo ""
echo -e "${YELLOW}Waiting for deployments to be ready (timeout: 5 minutes)...${NC}"
if sudo k0s kubectl wait --for=condition=available --timeout=300s deployment --all -n ms; then
    echo -e "${GREEN}✓ All deployments are ready!${NC}"
else
    echo -e "${RED}Warning: Some deployments may not be ready yet${NC}"
    echo "Check status with: make status"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}========================================${NC}"
sudo k0s kubectl get pods -n ms

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Services${NC}"
echo -e "${GREEN}========================================${NC}"
sudo k0s kubectl get svc -n ms

echo ""
echo -e "${YELLOW}To view logs:${NC} make logs SERVICE=<service-name>"
echo -e "${YELLOW}To check status:${NC} make status"
echo -e "${YELLOW}To undeploy:${NC} make undeploy"
echo ""

# Get gateway NodePort
GATEWAY_PORT=$(sudo k0s kubectl get svc gateway-server -n ms -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
if [ "$GATEWAY_PORT" != "N/A" ]; then
    echo -e "${GREEN}Gateway is accessible at: http://localhost:$GATEWAY_PORT${NC}"
fi

# Get Eureka NodePort
EUREKA_PORT=$(sudo k0s kubectl get svc eureka-server -n ms -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
if [ "$EUREKA_PORT" != "N/A" ]; then
    echo -e "${GREEN}Eureka Dashboard: http://localhost:$EUREKA_PORT${NC}"
fi

echo ""
