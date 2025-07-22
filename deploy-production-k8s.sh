#!/bin/bash

# Production deployment script for Robot Framework Dashboard
set -e

NAMESPACE="qa-auto-test"
RELEASE_NAME="robotframework-dashboard"
IMAGE_TAG="latest"

echo "🚀 Starting Robot Framework Dashboard deployment to production"
echo "Namespace: $NAMESPACE"
echo "Release: $RELEASE_NAME"

# Check if namespace exists, create if not
if ! kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace $NAMESPACE
fi

# Check if we're using the correct context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current context: $CURRENT_CONTEXT"

if [ "$CURRENT_CONTEXT" != "test" ]; then
    echo "❌ Not in 'test' context. Please run: kubectl config use-context test"
    exit 1
fi

# Option 1: Try to use local image (if cluster can access local registry)
echo "🐳 Checking if local image exists..."
if docker image inspect robotframework-dashboard:$IMAGE_TAG >/dev/null 2>&1; then
    echo "✅ Local image found: robotframework-dashboard:$IMAGE_TAG"
    
    # Try to save and load the image to a location accessible by the cluster
    echo "📦 Saving image..."
    docker save robotframework-dashboard:$IMAGE_TAG > /tmp/robotframework-dashboard.tar
    
    echo "🔄 This step requires manual intervention:"
    echo "   You need to load this image into your cluster's registry or nodes"
    echo "   Image saved to: /tmp/robotframework-dashboard.tar"
    echo ""
    echo "   Options:"
    echo "   1. Upload to your company's Docker registry"
    echo "   2. Load on each cluster node (if you have access)"
    echo "   3. Use the production manifest with init container (recommended)"
    echo ""
    
    read -p "Press Enter to continue with Helm deployment (assuming image is available) or Ctrl+C to stop..."
fi

# Deploy using Helm
echo "📋 Deploying with Helm..."

# Check if Helm release exists
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "📄 Upgrading existing release..."
    helm upgrade $RELEASE_NAME ./helm/robotframework-dashboard \
        --namespace $NAMESPACE \
        --values values-production.yaml \
        --wait \
        --timeout 10m
else
    echo "🆕 Installing new release..."
    helm install $RELEASE_NAME ./helm/robotframework-dashboard \
        --namespace $NAMESPACE \
        --values values-production.yaml \
        --wait \
        --timeout 10m
fi

echo "✅ Deployment completed!"
echo ""
echo "📊 Checking deployment status..."
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=robotframework-dashboard
echo ""
kubectl get services -n $NAMESPACE -l app.kubernetes.io/name=robotframework-dashboard
echo ""
kubectl get ingress -n $NAMESPACE

echo ""
echo "🌐 Your application should be available at:"
echo "   https://robotframework-dashboard.example.com"
echo ""
echo "📝 To check logs:"
echo "   kubectl logs -f deployment/robotframework-dashboard -n $NAMESPACE"
echo ""
echo "🔍 To check pod status:"
echo "   kubectl describe pods -l app.kubernetes.io/name=robotframework-dashboard -n $NAMESPACE"
