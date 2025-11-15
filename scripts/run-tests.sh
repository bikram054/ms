#!/usr/bin/env bash
set -euo pipefail

# Run full build, bring up docker-compose, wait for health, then run Newman tests
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[run-tests] Building services (skip tests)..."
mvn -f product-service/pom.xml clean package -DskipTests
mvn -f user-service/pom.xml clean package -DskipTests
mvn -f order-service/pom.xml clean package -DskipTests

echo "[run-tests] Recreating docker-compose services..."
docker-compose -f "$ROOT_DIR/docker-compose.yml" down --remove-orphans || true
docker-compose -f "$ROOT_DIR/docker-compose.yml" up --build -d

services=(user-service product-service order-service)
echo "[run-tests] Waiting for services to report healthy (timeout: 120s)"
timeout=120
interval=2
for ((i=0;i<timeout;i+=interval)); do
  all_healthy=true
  for svc in "${services[@]}"; do
    status=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-health{{end}}' "$svc" 2>/dev/null || echo "no-container")
    printf "[run-tests] %s: %s\n" "$svc" "$status"
    if [ "$status" != "healthy" ]; then
      all_healthy=false
    fi
  done
  if $all_healthy; then
    echo "[run-tests] All services healthy"
    break
  fi
  sleep $interval
done

if ! $all_healthy; then
  echo "[run-tests] ERROR: Services did not become healthy in time"
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
  for svc in "${services[@]}"; do
    echo "--- logs for $svc (last 200 lines) ---"
    docker logs --tail 200 "$svc" || true
  done
  exit 2
fi

echo "[run-tests] Running Newman collection..."
docker run --rm --network=host -v "$ROOT_DIR/postman":/etc/newman -w /etc/newman postman/newman:alpine \
  run api-tests.postman_collection.json -e api-environment.postman_environment.json --reporters cli

rc=$?
if [ $rc -ne 0 ]; then
  echo "[run-tests] Newman reported failures (exit $rc)"
  exit $rc
fi

echo "[run-tests] All tests passed"
exit 0
