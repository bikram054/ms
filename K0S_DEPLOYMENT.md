# Quick Reference: K0s Deployment Commands

## Deploy Using Remote Images (Recommended)

```bash
# Deploy all services from ghcr.io/bikram054/ms
make deploy-remote

# Or use the script directly
./deploy-remote.sh
```

## Other Useful Commands

```bash
# Pre-pull all images to k0s nodes
make pull-images

# Update running deployments with latest images
make update-images

# Check deployment status
make status

# View detailed k8s status
make k8s-status

# View logs (default: gateway-server)
make logs

# View logs for specific service
make logs SERVICE=user-service

# Remove all deployments
make undeploy

# Complete cleanup (deletes namespace)
make clean
```

## Deploy Using Local Images

```bash
# Build all native images first
make build-native-all

# Deploy to k0s
make deploy
```

## For Private Registries

```bash
# Setup image pull secret
./setup-image-pull-secret.sh

# Then deploy
make deploy-remote
```

## Troubleshooting

```bash
# Check pod events
sudo k0s kubectl describe pod <pod-name> -n ms

# View pod logs
sudo k0s kubectl logs <pod-name> -n ms -f

# Verify images
sudo k0s kubectl get pods -n ms -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n'

# Force restart deployments
sudo k0s kubectl wait --for=condition=available --timeout=300s deployment --all -n ms
```

## Access Services

After deployment, get the NodePort for services:

```bash
# Gateway
GATEWAY_PORT=$(sudo k0s kubectl get svc gateway-server -n ms -o jsonpath='{.spec.ports[0].nodePort}')
echo "Gateway: http://localhost:$GATEWAY_PORT"

# Eureka
EUREKA_PORT=$(sudo k0s kubectl get svc eureka-server -n ms -o jsonpath='{.spec.ports[0].nodePort}')
echo "Eureka: http://localhost:$EUREKA_PORT"
```
