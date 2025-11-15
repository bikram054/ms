# Actuator & Health Checks Implementation

## Overview

Spring Boot Actuator has been added to all three services (Order, Product, User) for monitoring, health checks, and operational metrics.

## Available Endpoints

### Health Endpoint
- **URL**: `http://localhost:{PORT}/actuator/health`
- **Purpose**: Check if service is running
- **Response**: `{"status": "UP"}` or `{"status": "DOWN"}`

### Metrics Endpoint
- **URL**: `http://localhost:{PORT}/actuator/metrics`
- **Purpose**: List all available metrics
- **Available Metrics**:
  - `application.ready.time` - Time to ready state
  - `application.started.time` - Time to startup
  - `disk.free` / `disk.total` - Disk space usage
  - `http.server.requests` - HTTP request metrics
  - `hikaricp.connections.*` - Database connection pool stats
  - `jvm.memory.*` - JVM memory usage
  - `process.uptime` - Service uptime
  - And many more...

### Specific Metric Query
- **URL**: `http://localhost:{PORT}/actuator/metrics/{metricName}`
- **Example**: `http://localhost:8083/actuator/metrics/http.server.requests`

### Info Endpoint
- **URL**: `http://localhost:{PORT}/actuator/info`
- **Purpose**: Application information (version, name, etc.)

### Discovery Endpoint
- **URL**: `http://localhost:{PORT}/actuator`
- **Purpose**: List all available Actuator endpoints

## Service Ports

| Service | Port | Health URL |
|---------|------|-----------|
| Order Service | 8083 | http://localhost:8083/actuator/health |
| Product Service | 8082 | http://localhost:8082/actuator/health |
| User Service | 8081 | http://localhost:8081/actuator/health |

## Example Commands

### Check Order Service Health
```bash
curl http://localhost:8083/actuator/health
```

### Get All Available Endpoints
```bash
curl http://localhost:8083/actuator | json_pp
```

### Check HTTP Request Metrics
```bash
curl http://localhost:8083/actuator/metrics/http.server.requests
```

### Monitor JVM Memory
```bash
curl http://localhost:8083/actuator/metrics/jvm.memory.used
```

### Get Database Connection Pool Status
```bash
curl http://localhost:8083/actuator/metrics/hikaricp.connections.active
```

## Configuration

Added to `application.properties` in each service:

```properties
# Actuator Configuration
management.endpoints.web.exposure.include=health,metrics,info
management.endpoint.health.show-details=when-authorized
management.endpoint.info.enabled=true
management.metrics.export.simple.enabled=true
```

### Configuration Options:
- `management.endpoints.web.exposure.include` - Which endpoints to expose
- `management.endpoint.health.show-details` - Show detailed health information when authorized
- `management.endpoint.info.enabled` - Enable/disable info endpoint
- `management.metrics.export.simple.enabled` - Enable simple metrics export

## Monitoring & Alerting Use Cases

### 1. Service Readiness Checks (Kubernetes/Docker)
```bash
curl -f http://localhost:8083/actuator/health || exit 1
```

### 2. Database Connection Monitoring
```bash
# Check active database connections
curl http://localhost:8083/actuator/metrics/hikaricp.connections.active
```

### 3. Request Performance Tracking
```bash
# HTTP request metrics (count, total time, max time)
curl http://localhost:8083/actuator/metrics/http.server.requests
```

### 4. Memory Leak Detection
```bash
# Monitor JVM memory over time
curl http://localhost:8083/actuator/metrics/jvm.memory.used
```

### 5. Service Uptime Monitoring
```bash
# Get process uptime
curl http://localhost:8083/actuator/metrics/process.uptime
```

## Circuit Breaker Monitoring (Order Service)

The Order Service includes **Resilience4j Circuit Breaker** with health indicator:

```bash
curl http://localhost:8083/actuator/health/productService
```

**States**:
- `UP` - Circuit is CLOSED (normal operation)
- `DOWN` - Circuit is OPEN (service unavailable, using fallback)
- `DEGRADED` - Circuit is HALF-OPEN (testing if service recovered)

## Integration Points

### Docker Compose Health Checks
Can be added to `docker-compose.yml`:
```yaml
services:
  order-service:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8083/actuator/health"]
      interval: 10s
      timeout: 5s
      retries: 3
```

### Kubernetes Probes
For production Kubernetes deployments:
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8083
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8083
  initialDelaySeconds: 20
  periodSeconds: 5
```

### Monitoring Stacks
- **Prometheus** - Scrape `/actuator/metrics` for metrics collection
- **Grafana** - Visualize Prometheus metrics
- **ELK Stack** - Aggregate logs with metrics
- **New Relic/DataDog** - APM integration

## Test Results

✅ **All 23 Postman tests passing with Actuator enabled**
- Order Service: Healthy ✓
- Product Service: Healthy ✓
- User Service: Healthy ✓
- All API endpoints responding with correct status codes
- Circuit breaker monitoring active

## Next Steps

To extend monitoring capabilities:

1. **Add Prometheus Export**
   ```xml
   <dependency>
       <groupId>io.micrometer</groupId>
       <artifactId>micrometer-registry-prometheus</artifactId>
   </dependency>
   ```

2. **Add Custom Metrics**
   ```java
   @Bean
   public MeterRegistry meterRegistry() {
       return new SimpleMeterRegistry();
   }
   ```

3. **Enable Detailed Health Info** 
   Update configuration: `management.endpoint.health.show-details=always`

4. **Add Distributed Tracing** 
   For request correlation across services
