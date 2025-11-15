#!/usr/bin/env bash
services=("order-service" "product-service" "user-service")
timeout=120
interval=3
elapsed=0
while [ $elapsed -lt $timeout ]; do
  all_healthy=true
  for s in "${services[@]}"; do
    name=$(docker ps --format '{{.Names}}' | grep -E "${s}" | head -n1)
    if [ -z "$name" ]; then
      echo "${s}: not running"
      all_healthy=false
      continue
    fi
    status=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}nohealth{{end}}' "$name" 2>/dev/null || echo "noinspect")
    printf "%s -> %s : %s\n" "$s" "$name" "$status"
    if [ "$status" != "healthy" ]; then
      all_healthy=false
    fi
  done
  if $all_healthy; then
    echo "ALL_SERVICES_HEALTHY"
    exit 0
  fi
  sleep $interval
  elapsed=$((elapsed+interval))
done
echo "HEALTH_CHECK_TIMEOUT"
exit 2
