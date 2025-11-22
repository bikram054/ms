#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting all microservices with 'local' profile...${NC}"

# Function to start a service
start_service() {
    service_name=$1
    port=$2
    echo -e "${GREEN}Starting $service_name on port $port...${NC}"
    
    cd $service_name
    mvn spring-boot:run -Dspring-boot.run.profiles=local > /dev/null 2>&1 &
    cd ..
    
    echo -e "Started $service_name (PID: $!)"
}

# 1. Infrastructure Services
start_service "eureka-server" 8761
echo "Waiting for Eureka to initialize..."
sleep 15

# 2. Core Business Services
start_service "user-service" 8081
start_service "product-service" 8082
start_service "order-service" 8083

# 3. Edge Services
start_service "gateway-server" 8080

echo -e "${BLUE}All services started!${NC}"
echo -e "Stop all with: ${GREEN}./stop-all.sh${NC}"

