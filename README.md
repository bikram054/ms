# Microservices Architecture

A Spring Boot microservices application with service discovery, configuration management, and API gateway.

## Architecture

- **Config Server** (8888) - Centralized configuration management
- **Eureka Server** (8761) - Service discovery and registration
- **Gateway Server** (8080) - API gateway with Redis caching
- **Admin Server** (9090) - Spring Boot Admin for monitoring
- **User Service** (8081) - User management
- **Product Service** (8082) - Product catalog
- **Order Service** (8083) - Order processing
- **Redis** (6379) - Caching layer

## Prerequisites

- Java 21
- Maven 3.6+
- Docker & Docker Compose

## Quick Start

```bash
# Build all services
mvn clean package

# Start all services
docker-compose up -d

# Check service health
docker-compose ps
```

## Service URLs

- Gateway: http://localhost:8080
- Eureka Dashboard: http://localhost:8761
- Admin Dashboard: http://localhost:9090
- Config Server: http://localhost:8888

## Development

```bash
# Build specific service
mvn clean package -pl user-service

# Run performance tests
./run-perf-test.sh

# Stop all services
docker-compose down
```

## Testing

- Postman collection: `postman/api-tests.postman_collection.json`
- Performance tests: `performance-tests/test-plan.jmx`
- Test data: `performance-tests/data/`

## Configuration

Service configurations are in `config-repo/` directory and managed by Config Server.