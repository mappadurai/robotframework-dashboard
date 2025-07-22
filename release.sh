#!/bin/bash

# Manual Release Script for Robot Framework Dashboard
# Usage: ./release.sh [version]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_VERSION="1.1.3"
DOCKER_IMAGE="sankaram04/robotframework-dashboard"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get version from command line or use default
VERSION=${1:-$DEFAULT_VERSION}

print_status "🚀 Starting release process for version: $VERSION"

# Verify we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_error "Not on main branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check if git working directory is clean
if ! git diff-index --quiet HEAD --; then
    print_error "Working directory is not clean. Please commit your changes first."
    exit 1
fi

# Extract current version from version.py
CURRENT_VERSION=$(python3 -c "exec(open('robotframework_dashboard/version.py').read()); print(__version__.split()[-1])")
print_status "Current version in code: $CURRENT_VERSION"

# Confirm version
echo
read -p "Do you want to release version $VERSION? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Release cancelled."
    exit 0
fi

# Update Helm chart version
print_status "📦 Updating Helm chart version..."
sed -i.bak "s/appVersion: .*/appVersion: \"$VERSION\"/" helm/robotframework-dashboard/Chart.yaml
rm helm/robotframework-dashboard/Chart.yaml.bak

# Build Docker image
print_status "🐳 Building Docker image..."
docker build -t ${DOCKER_IMAGE}:${VERSION} .
docker tag ${DOCKER_IMAGE}:${VERSION} ${DOCKER_IMAGE}:latest

print_success "Docker image built successfully!"

# Test the image
print_status "🧪 Testing Docker image..."
CONTAINER_ID=$(docker run -d -p 8000:8000 ${DOCKER_IMAGE}:${VERSION})
sleep 5

# Check if container is running
if docker ps | grep -q $CONTAINER_ID; then
    print_success "Container is running successfully!"
    docker stop $CONTAINER_ID > /dev/null
    docker rm $CONTAINER_ID > /dev/null
else
    print_error "Container failed to start!"
    docker logs $CONTAINER_ID
    docker rm $CONTAINER_ID > /dev/null
    exit 1
fi

# Ask about pushing to Docker Hub
echo
read -p "Do you want to push to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "📤 Pushing to Docker Hub..."
    docker push ${DOCKER_IMAGE}:${VERSION}
    docker push ${DOCKER_IMAGE}:latest
    print_success "Images pushed to Docker Hub!"
else
    print_warning "Skipping Docker Hub push."
fi

# Commit Helm chart changes
print_status "📝 Committing Helm chart version update..."
git add helm/robotframework-dashboard/Chart.yaml
git commit -m "Release v$VERSION - Update Helm chart appVersion"

# Create and push tag
print_status "🏷️  Creating git tag..."
git tag -a "v$VERSION" -m "Release version $VERSION"

# Ask about pushing to GitHub
echo
read -p "Do you want to push to GitHub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "📤 Pushing to GitHub..."
    git push origin main
    git push origin "v$VERSION"
    print_success "Changes pushed to GitHub!"
else
    print_warning "Skipping GitHub push."
fi

# Summary
echo
print_success "🎉 Release $VERSION completed successfully!"
echo
echo "📋 Summary:"
echo "  - Docker image: ${DOCKER_IMAGE}:${VERSION}"
echo "  - Docker image: ${DOCKER_IMAGE}:latest"
echo "  - Git tag: v$VERSION"
echo "  - Helm chart app version updated"
echo
echo "🚀 Next steps:"
echo "  1. Verify the release on GitHub: https://github.com/mappadurai/robotframework-dashboard/releases"
echo "  2. Test the deployment with the new image"
echo "  3. Update documentation if needed"
echo
echo "📦 Installation commands:"
echo "  Docker: docker run -p 8000:8000 ${DOCKER_IMAGE}:${VERSION}"
echo "  Helm:   helm upgrade robotframework-dashboard ./helm/robotframework-dashboard --set image.tag=${VERSION}"
