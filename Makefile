SHELL := /bin/bash

.PHONY: build build-native build-native-all deploy undeploy logs clean status k8s-status perf-test postman-test

build:
	@echo "Building all services with Maven parallel build (1 thread per CPU core)..."
	mvn -T 1C clean package -DskipTests

build-native:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE parameter is required"; \
		echo "Usage: make build-native SERVICE=user-service"; \
		echo "Available services: eureka-server, gateway-server, user-service, product-service, order-service"; \
		exit 1; \
	fi
	@case $(SERVICE) in \
		eureka-server) PORT=8761 ;; \
		gateway-server) PORT=8080 ;; \
		user-service) PORT=8081 ;; \
		product-service) PORT=8082 ;; \
		order-service) PORT=8083 ;; \
		*) echo "Error: Unknown service $(SERVICE)"; exit 1 ;; \
	esac; \
	echo "Building native image for $(SERVICE) on port $$PORT..."; \
	buildah bud \
		--build-arg SERVICE_NAME=$(SERVICE) \
		--build-arg PORT=$$PORT \
		-t $(SERVICE):native \
		-f Containerfile .

build-native-all:
	@echo "Building native images for all services..."
	@for service in eureka-server gateway-server user-service product-service order-service; do \
		case $$service in \
			eureka-server) port=8761 ;; \
			gateway-server) port=8080 ;; \
			user-service) port=8081 ;; \
			product-service) port=8082 ;; \
			order-service) port=8083 ;; \
		esac; \
		echo "Building $$service:native (port $$port)..."; \
		buildah bud \
			--build-arg SERVICE_NAME=$$service \
			--build-arg PORT=$$port \
			-t $$service:native \
			-f Containerfile . || exit 1; \
	done
	@echo "All native images built successfully!"

deploy:
	@echo "Deploying to k0s Kubernetes..."
	sudo k0s kubectl apply -f k8s/namespace.yaml
	sudo k0s kubectl apply -f k8s/
	@echo "Waiting for deployments to be ready..."
	sudo k0s kubectl wait --for=condition=available --timeout=300s deployment --all -n microservices
	@echo "Deployment complete!"

undeploy:
	@echo "Removing microservices from k0s..."
	sudo k0s kubectl delete -f k8s/ --ignore-not-found=true
	@echo "Microservices removed!"

logs:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Showing logs for gateway-server (default)..."; \
		echo "Use: make logs SERVICE=<service-name> to view specific service"; \
		sudo k0s kubectl logs -n microservices -l app=gateway-server -f; \
	else \
		echo "Showing logs for $(SERVICE)..."; \
		sudo k0s kubectl logs -n microservices -l app=$(SERVICE) -f; \
	fi

status:
	@echo "Microservices Status:"
	@sudo k0s kubectl get pods -n microservices

k8s-status:
	@echo "=== Kubernetes Resources in microservices namespace ==="
	@sudo k0s kubectl get all -n microservices
	@echo ""
	@echo "=== Pod Details ==="
	@sudo k0s kubectl get pods -n microservices -o wide

clean:
	@echo "Cleaning up microservices namespace..."
	sudo k0s kubectl delete namespace microservices --ignore-not-found=true
	@echo "Cleanup complete!"

perf-test:
	@echo "Running JMeter performance tests..."
	docker run --rm --network ms_microservices-network \
		-v $(PWD)/tests/performance-tests:/tests \
		-v $(PWD)/tests/performance-tests/results:/results \
		alpine/jmeter:latest \
		-n -t /tests/test-plan.jmx \
		-l /results/results-$(shell date +%Y%m%d-%H%M%S).jtl \
		-Jgateway.host=gateway-server \
		-Jgateway.port=8080 \
		-Jauth.username=${AUTH_USERNAME} \
		-Jauth.password=${AUTH_PASSWORD}

postman-test:
	@echo "Running Postman tests via gateway..."
	docker run --rm --network ms_microservices-network \
		-v $(PWD)/tests/functional-tests:/etc/newman \
		postman/newman:alpine \
		run api-tests.postman_collection.json \
		-e api-environment.postman_environment.json \
		--env-var gatewayBaseUrl=http://gateway-server:8080
