SHELL := /bin/bash

.PHONY: build build-native build-native-all deploy deploy-remote pull-images update-images undeploy logs clean status k8s-status perf-test postman-test setup-cluster k0s-start k0s-stop k0s-reset

setup-cluster:
	@echo "Setting up single-node k0s cluster..."
	curl -sSLf https://get.k0s.sh | sudo sh
	sudo k0s install controller --single
	sudo k0s start
	@echo "Waiting for k0s to start..."
	@sleep 10
	@echo "Exporting kubeconfig..."
	mkdir -p ~/.kube
	sudo k0s kubeconfig admin > ~/.kube/config
	chmod 600 ~/.kube/config
	@echo "Cluster setup complete!"

k0s-start:
	@echo "Starting k0s..."
	sudo k0s start
	@echo "k0s started!"

k0s-stop:
	@echo "Stopping k0s..."
	sudo k0s stop
	@echo "k0s stopped!"

k0s-reset:
	@echo "Resetting k0s (uninstalling)..."
	sudo k0s stop || true
	sudo k0s reset
	@echo "k0s reset complete!"

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
	@echo "Deploying to k0s Kubernetes (using local images)..."
	sudo k0s kubectl apply -f k8s/namespace.yaml
	sudo k0s kubectl apply -f k8s/
	@echo "Waiting for deployments to be ready..."
	sudo k0s kubectl wait --for=condition=available --timeout=300s deployment --all -n ms
	@echo "Deployment complete!"

deploy-remote:
	@echo "Deploying to k0s using remote images from ghcr.io/bikram054/ms..."
	./deploy-remote.sh

pull-images:
	@echo "Pre-pulling images from ghcr.io/bikram054/ms to k0s nodes..."
	@for service in eureka-server gateway-server user-service product-service order-service; do \
		echo "Pulling $$service..."; \
		sudo k0s ctr images pull ghcr.io/bikram054/ms/$$service:latest || true; \
	done
	@echo "All images pulled!"

update-images:
	@echo "Updating deployments with latest images..."
	sudo k0s kubectl rollout restart deployment --all -n ms
	@echo "Waiting for rollout to complete..."
	sudo k0s kubectl rollout status deployment --all -n ms
	@echo "Update complete!"

undeploy:
	@echo "Removing microservices from k0s..."
	sudo k0s kubectl delete -f k8s/ --ignore-not-found=true
	@echo "Microservices removed!"

logs:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Showing logs for gateway-server (default)..."; \
		echo "Use: make logs SERVICE=<service-name> to view specific service"; \
		sudo k0s kubectl logs -n ms -l app=gateway-server -f; \
	else \
		echo "Showing logs for $(SERVICE)..."; \
		sudo k0s kubectl logs -n ms -l app=$(SERVICE) -f; \
	fi

status:
	@echo "Microservices Status:"
	@sudo k0s kubectl get pods -n ms

k8s-status:
	@echo "=== Kubernetes Resources in ms namespace ==="
	@sudo k0s kubectl get all -n ms
	@echo ""
	@echo "=== Pod Details ==="
	@sudo k0s kubectl get pods -n ms -o wide

clean:
	@echo "Cleaning up ms namespace..."
	sudo k0s kubectl delete namespace ms --ignore-not-found=true
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
