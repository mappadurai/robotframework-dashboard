#!/bin/bash

# Production Deployment Script for Robot Framework Dashboard
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEPLOYMENT_TYPE=${1:-"kubernetes"}
REGISTRY=${REGISTRY:-""}
TAG=${TAG:-"latest"}

echo -e "${GREEN}🤖 Robot Framework Dashboard Production Deployment${NC}"
echo "========================================================="

# Function to print colored output
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_step "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if [[ "$DEPLOYMENT_TYPE" == "kubernetes" ]] && ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    if [[ "$DEPLOYMENT_TYPE" == "docker-compose" ]] && ! command -v docker-compose &> /dev/null; then
        log_error "docker-compose is not installed"
        exit 1
    fi
    
    log_info "All dependencies satisfied"
}

# Build Docker image
build_image() {
    log_step "Building Docker image..."
    
    if [[ -n "$REGISTRY" ]]; then
        IMAGE_NAME="${REGISTRY}/robotframework-dashboard:${TAG}"
    else
        IMAGE_NAME="robotframework-dashboard:${TAG}"
    fi
    
    docker build -t "$IMAGE_NAME" .
    
    if [[ -n "$REGISTRY" ]]; then
        log_step "Pushing image to registry..."
        docker push "$IMAGE_NAME"
    fi
    
    log_info "Image built successfully: $IMAGE_NAME"
}

# Deploy to Kubernetes
deploy_kubernetes() {
    log_step "Deploying to Kubernetes..."
    
    # Update image in deployment if using registry
    if [[ -n "$REGISTRY" ]]; then
        sed -i.bak "s|robotframework-dashboard:latest|${REGISTRY}/robotframework-dashboard:${TAG}|g" k8s/deployment.yaml
    fi
    
    # Apply manifests
    kubectl apply -f k8s/
    
    # Wait for deployment
    log_step "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/robotframework-dashboard -n robotframework-dashboard
    
    # Show status
    kubectl get pods,svc,ingress -n robotframework-dashboard
    
    # Restore original file if modified
    if [[ -n "$REGISTRY" ]]; then
        mv k8s/deployment.yaml.bak k8s/deployment.yaml
    fi
    
    log_info "Kubernetes deployment completed"
}

# Deploy using Docker Compose
deploy_docker_compose() {
    log_step "Deploying using Docker Compose..."
    
    # Update image in docker-compose if using registry
    if [[ -n "$REGISTRY" ]]; then
        sed -i.bak "s|build:|#build:|g" docker-compose.yml
        sed -i "s|#image: robotframework-dashboard|image: ${REGISTRY}/robotframework-dashboard:${TAG}|g" docker-compose.yml
    fi
    
    # Deploy
    docker-compose up -d
    
    # Wait for health check
    log_step "Waiting for health check..."
    sleep 30
    
    # Show status
    docker-compose ps
    
    # Restore original file if modified
    if [[ -n "$REGISTRY" ]]; then
        mv docker-compose.yml.bak docker-compose.yml
    fi
    
    log_info "Docker Compose deployment completed"
}

# Perform health check
health_check() {
    log_step "Performing health check..."
    
    if [[ "$DEPLOYMENT_TYPE" == "kubernetes" ]]; then
        kubectl port-forward service/robotframework-dashboard-service 8080:80 -n robotframework-dashboard &
        PORT_FORWARD_PID=$!
        sleep 5
        HEALTH_URL="http://localhost:8080"
    else
        HEALTH_URL="http://localhost:8000"
    fi
    
    # Wait for service to be ready
    for i in {1..30}; do
        if curl -s "$HEALTH_URL" > /dev/null; then
            log_info "Health check passed ✅"
            break
        fi
        sleep 2
    done
    
    # Kill port-forward if running
    if [[ -n "$PORT_FORWARD_PID" ]]; then
        kill $PORT_FORWARD_PID 2>/dev/null || true
    fi
}

# Show access information
show_access_info() {
    log_step "Access Information:"
    
    if [[ "$DEPLOYMENT_TYPE" == "kubernetes" ]]; then
        echo "Kubernetes Deployment:"
        echo "  Internal: http://robotframework-dashboard-service.robotframework-dashboard.svc.cluster.local"
        echo "  Port Forward: kubectl port-forward service/robotframework-dashboard-service 8080:80 -n robotframework-dashboard"
        echo "  Then access: http://localhost:8080"
        
        # Check if ingress exists
        if kubectl get ingress robotframework-dashboard-ingress -n robotframework-dashboard &>/dev/null; then
            INGRESS_HOST=$(kubectl get ingress robotframework-dashboard-ingress -n robotframework-dashboard -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || echo "not-configured")
            echo "  Ingress: http://${INGRESS_HOST} (if DNS configured)"
        fi
    else
        echo "Docker Compose Deployment:"
        echo "  Direct access: http://localhost:8000"
        echo "  Via Nginx: http://localhost:80"
    fi
}

# Main execution
main() {
    check_dependencies
    build_image
    
    case "$DEPLOYMENT_TYPE" in
        "kubernetes")
            deploy_kubernetes
            ;;
        "docker-compose")
            deploy_docker_compose
            ;;
        *)
            log_error "Unknown deployment type: $DEPLOYMENT_TYPE"
            echo "Usage: $0 [kubernetes|docker-compose]"
            exit 1
            ;;
    esac
    
    health_check
    show_access_info
    
    log_info "Deployment completed successfully! 🎉"
}

# Show usage if help requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Robot Framework Dashboard Production Deployment Script"
    echo ""
    echo "Usage: $0 [deployment-type]"
    echo ""
    echo "Deployment Types:"
    echo "  kubernetes      Deploy to Kubernetes cluster (default)"
    echo "  docker-compose  Deploy using Docker Compose"
    echo ""
    echo "Environment Variables:"
    echo "  REGISTRY        Docker registry URL (optional)"
    echo "  TAG            Docker image tag (default: latest)"
    echo ""
    echo "Examples:"
    echo "  $0 kubernetes"
    echo "  REGISTRY=myregistry.com $0 kubernetes"
    echo "  $0 docker-compose"
    exit 0
fi

# Run main function
main
