# Robot Framework Dashboard Makefile

.PHONY: help build test deploy-k8s deploy-docker clean

# Default target
help:
	@echo "Robot Framework Dashboard Deployment Commands"
	@echo "============================================="
	@echo ""
	@echo "Available targets:"
	@echo "  build          Build Docker image"
	@echo "  test           Test the application locally"
	@echo "  deploy-k8s     Deploy to Kubernetes"
	@echo "  deploy-docker  Deploy using Docker Compose"
	@echo "  clean          Clean up deployments"
	@echo "  logs-k8s       Show Kubernetes logs"
	@echo "  logs-docker    Show Docker Compose logs"
	@echo ""
	@echo "Environment variables:"
	@echo "  REGISTRY       Docker registry (optional)"
	@echo "  TAG           Docker image tag (default: latest)"

# Build Docker image
build:
	@echo "Building Docker image..."
	docker build -t robotframework-dashboard:latest .

# Test locally
test:
	@echo "Starting local test..."
	docker run --rm -p 8000:8000 robotframework-dashboard:latest &
	@echo "Waiting for service to start..."
	@sleep 10
	@echo "Testing health endpoint..."
	curl -f http://localhost:8000/ || echo "Health check failed"

# Deploy to Kubernetes
deploy-k8s:
	@echo "Deploying to Kubernetes..."
	./deploy-production.sh kubernetes

# Deploy using Docker Compose
deploy-docker:
	@echo "Deploying using Docker Compose..."
	./deploy-production.sh docker-compose

# Clean up Kubernetes deployment
clean-k8s:
	@echo "Cleaning up Kubernetes deployment..."
	kubectl delete namespace robotframework-dashboard --ignore-not-found=true

# Clean up Docker Compose deployment
clean-docker:
	@echo "Cleaning up Docker Compose deployment..."
	docker-compose down -v

# Show Kubernetes logs
logs-k8s:
	kubectl logs -f deployment/robotframework-dashboard -n robotframework-dashboard

# Show Docker Compose logs
logs-docker:
	docker-compose logs -f

# Port forward for Kubernetes
port-forward:
	kubectl port-forward service/robotframework-dashboard-service 8080:80 -n robotframework-dashboard

# Full cleanup
clean: clean-k8s clean-docker
	docker rmi robotframework-dashboard:latest 2>/dev/null || true

# Development setup
dev-setup:
	pip install -r requirements.txt
	pip install python-multipart
	pip install -e .

# Run locally for development
dev-run:
	robotdashboard --server default
