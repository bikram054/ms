# Configuration Profiles (dev / prod)

This document explains how the `dev` and `prod` Spring profiles are organized and how to use them.

## Files added

For each service we added two profile files under `src/main/resources`:

- `application-dev.properties` — development overrides
- `application-prod.properties` — production overrides

Common defaults are kept in `application.properties` and profile files override only the environment-specific settings.

## What goes in each file

- `application.properties` — shared defaults (actuator settings, logging defaults, feature flags)
- `application-dev.properties` — verbose logging, H2 console enabled, actuator exposes more endpoints
- `application-prod.properties` — restricted actuator exposure, production DB settings (validate), reduced logging

## Running with profiles

### Locally (dev)

Run services with the `dev` profile to enable debugging and H2 console:

```bash
# single service
cd /home/samanta/ms/order-service
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# or multiple in separate terminals
cd /home/samanta/ms/product-service
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Docker / Production (prod)

`docker-compose.yml` sets `SPRING_PROFILES_ACTIVE=prod` for each service by default. To build and run in prod:

```bash
cd /home/samanta/ms
mvn -f order-service/pom.xml clean package -DskipTests
mvn -f product-service/pom.xml clean package -DskipTests
mvn -f user-service/pom.xml clean package -DskipTests

docker-compose up --build -d
```

To override at runtime:

```bash
SPRING_PROFILES_ACTIVE=dev docker-compose up --build -d
```

## Notes

- Keep secrets out of property files; use environment variables or a secret manager in production.
- Use `application.yml` if you prefer a single-file multi-profile approach.
- For Kubernetes, set `SPRING_PROFILES_ACTIVE` in the Deployment manifest and mount ConfigMaps/Secrets as needed.
