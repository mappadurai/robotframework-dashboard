#!/bin/bash

# Robot Framework Dashboard Kubernetes Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_IMAGE_NAME="robotframework-dashboard"
DOCKER_TAG="latest"
NAMESPACE="robotframework-dashboard"

echo -e "${GREEN}🤖 Robot Framework Dashboard Kubernetes Deployment${NC}"
echo "=================================================="

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed. Please install kubectl and try again."
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info > /dev/null 2>&1; then
    log_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

# Build Docker image
log_info "Building Docker image..."
docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .

# If using a remote registry, tag and push the image
# Uncomment and modify the following lines if you're using a remote registry
# REGISTRY="your-registry.com"
# docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
# docker push ${REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}

# Apply Kubernetes manifests
log_info "Applying Kubernetes manifests..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Apply PVCs
kubectl apply -f k8s/pvc.yaml

# Apply Deployment
kubectl apply -f k8s/deployment.yaml

# Apply Service
kubectl apply -f k8s/service.yaml

# Apply Ingress (optional)
if [ -f "k8s/ingress.yaml" ]; then
    log_warn "Applying Ingress. Make sure to update the host and ingress class in k8s/ingress.yaml"
    kubectl apply -f k8s/ingress.yaml
fi

# Wait for deployment to be ready
log_info "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/robotframework-dashboard -n ${NAMESPACE}

# Get deployment status
log_info "Deployment status:"
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}

# Get external access information
log_info "Access information:"
echo "Internal cluster access:"
echo "  Service: http://robotframework-dashboard-service.${NAMESPACE}.svc.cluster.local"

# Check if ingress is configured
if kubectl get ingress robotframework-dashboard-ingress -n ${NAMESPACE} > /dev/null 2>&1; then
    INGRESS_HOST=$(kubectl get ingress robotframework-dashboard-ingress -n ${NAMESPACE} -o jsonpath='{.spec.rules[0].host}')
    echo "External access (if DNS is configured):"
    echo "  URL: http://${INGRESS_HOST}"
fi

# Port forwarding option
echo ""
log_info "For local testing, you can use port forwarding:"
echo "  kubectl port-forward service/robotframework-dashboard-service 8080:80 -n ${NAMESPACE}"
echo "  Then access: http://localhost:8080"

echo ""
log_info "Deployment completed successfully! 🎉"
