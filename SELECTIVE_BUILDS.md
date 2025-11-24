# Selective Service Building Guide

## Overview

The GitHub Actions workflow now supports building only the services that have changed, saving time and resources.

## How It Works

### Automatic Detection (Pull Requests)

On pull requests, the workflow automatically detects which services changed:

```yaml
eureka-server/**     → Builds eureka-server only
gateway-server/**    → Builds gateway-server only
user-service/**      → Builds user-service only
product-service/**   → Builds product-service only
order-service/**     → Builds order-service only
```

**Common files trigger all services:**
- `pom.xml` (parent POM)
- `Containerfile` or `Containerfile.eureka-jvm`
- `.github/workflows/**`

### Main Branch (Push)

Pushes to `main` branch **always build all services** to ensure consistency.

### Manual Trigger

You can manually trigger builds for specific services:

1. Go to: https://github.com/bikram054/ms/actions
2. Click "Native Build" workflow
3. Click "Run workflow"
4. Enter services to build:
   - `all` - Build all services
   - `user-service` - Build only user-service
   - `user-service,product-service` - Build multiple services

## Examples

### Scenario 1: Fix Bug in User Service

```bash
# Edit user service code
vim user-service/src/main/java/...

# Commit and push
git add user-service/
git commit -m "fix: user service bug"
git push
```

**Result**: Only `user-service` builds (~5-6 min instead of 25-30 min for all)

### Scenario 2: Update Parent POM

```bash
# Edit parent pom.xml
vim pom.xml

# Commit and push
git add pom.xml
git commit -m "chore: update dependencies"
git push
```

**Result**: All services build (dependency change affects all)

### Scenario 3: Manual Build

Need to rebuild gateway-server without code changes?

```bash
# Use GitHub UI or gh CLI
gh workflow run native-build.yml -f services=gateway-server
```

## Build Time Savings

| Scenario | Services Built | Time |
|----------|---------------|------|
| All services | 5 | ~25-30 min |
| Single service | 1 | ~5-6 min |
| Two services | 2 | ~10-12 min |

**Savings**: Up to 80% reduction in build time for single-service changes!

## Local Testing

To build a specific service locally:

```bash
# Native image
make build-native SERVICE=user-service

# Or with buildah directly
buildah bud \
  --build-arg SERVICE_NAME=user-service \
  --build-arg PORT=8081 \
  -t user-service:latest \
  -f Containerfile .
```

## Tips

1. **Keep changes isolated**: Work on one service at a time for faster builds
2. **Use feature branches**: PRs will only build changed services
3. **Test locally first**: Use `make build-native SERVICE=...` before pushing
4. **Monitor builds**: Check GitHub Actions to see which services are building
