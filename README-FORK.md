# Robot Framework Dashboard - Custom Fork

This is a customized fork of the [original robotframework-dashboard](https://github.com/timdegroot1996/robotframework-dashboard) with additional deployment and containerization features.

## 🚀 Added Features

### Docker & Containerization
- **Dockerfile** - Production-ready container image
- **Dockerfile.prod** - Multi-stage production build
- **.dockerignore** - Optimized build context
- **docker-compose.yml** - Local development setup

### Kubernetes Deployment
- **helm/** - Complete Helm chart for Kubernetes deployment
- **k8s/** - Raw Kubernetes manifests
- **k8s-production.yaml** - Production-ready deployment
- **values-production.yaml** - Production Helm values

### Deployment Scripts
- **deploy.sh** - Local/development deployment
- **deploy-production.sh** - Production deployment script
- **deploy-production-k8s.sh** - Kubernetes production deployment
- **Makefile** - Automation tasks

### Documentation
- **KUBERNETES.md** - Kubernetes deployment guide

## 🔧 Deployment Options

### 1. Docker (Local Development)
```bash
# Build and run locally
docker-compose up -d

# Or build manually
docker build -t robotframework-dashboard .
docker run -p 8000:8000 robotframework-dashboard
```

### 2. Kubernetes (Production)
```bash
# Using Helm
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --namespace qa-auto-test \
  --values values-production.yaml

# Using raw manifests
kubectl apply -f k8s/
```

### 3. Automated Deployment
```bash
# Production deployment to Kubernetes
./deploy-production-k8s.sh
```

## 📦 Container Registry

The production image is available at:
```
sankaram04/robotframework-dashboard:latest
```

## 🌐 Production Access

- **URL:** https://robotframework-dashboard.example.com
- **Namespace:** qa-auto-test
- **Ingress:** Nginx with Let's Encrypt TLS

## 🔄 Maintenance

### Keeping Up with Upstream
```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream changes to your fork
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

### Making Changes
```bash
# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to your fork
git push origin feature/my-new-feature
```

## 📋 Configuration

### Environment Variables
- `ROBOTDASHBOARD_HOST`: Server host (default: 0.0.0.0)
- `ROBOTDASHBOARD_PORT`: Server port (default: 8000)
- `DATABASE_PATH`: SQLite database path
- `LOG_DIR`: Robot logs directory

### Storage
- **Data Volume:** 5Gi (ceph-block)
- **Logs Volume:** 2Gi (ceph-block)

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## 📄 License

Same as original project. See the original repository for license details.

---

**Note:** This fork includes enterprise deployment features and Kubernetes configurations not present in the original repository.
