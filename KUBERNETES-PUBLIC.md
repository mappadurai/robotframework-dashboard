# Kubernetes Deployment Guide - Robot Framework Dashboard

This guide covers deploying Robot Framework Dashboard on Kubernetes using the public Docker image.

## 📦 Quick Start

### Prerequisites
- Kubernetes cluster (1.19+)
- kubectl configured
- Helm 3.x (optional, for Helm deployment)

### Using Public Docker Image
The application is available as a public Docker image: `sankaram04/robotframework-dashboard:latest`

## 🚀 Deployment Options

### 1. Helm Deployment (Recommended)

```bash
# Basic installation
helm install robotframework-dashboard ./helm/robotframework-dashboard

# Production installation with custom domain
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --set ingress.hosts[0].host=robotdashboard.yourdomain.com \
  --set persistence.data.storageClass=your-storage-class
```

### 2. Raw Kubernetes Manifests

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or step by step
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## ⚙️ Configuration

### Environment-Specific Values

#### Development
```bash
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --values helm/robotframework-dashboard/values-dev.yaml
```

#### Production
```bash
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --values helm/robotframework-dashboard/values-prod.yaml
```

### Custom Configuration

Create your own `my-values.yaml`:

```yaml
image:
  repository: sankaram04/robotframework-dashboard
  tag: "latest"

ingress:
  enabled: true
  hosts:
    - host: robotdashboard.mycompany.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: robotdashboard-tls
      hosts:
        - robotdashboard.mycompany.com

persistence:
  data:
    storageClass: "your-storage-class"
    size: 10Gi
```

## 🔧 Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image | `sankaram04/robotframework-dashboard` |
| `image.tag` | Image tag | `latest` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.hosts[0].host` | Hostname | `robotframework-dashboard.example.com` |
| `persistence.data.size` | Data volume size | `5Gi` |
| `persistence.logs.size` | Logs volume size | `2Gi` |
| `persistence.data.storageClass` | Storage class | `standard` |

## 🌐 Accessing the Dashboard

### Via Ingress (Production)
Access via the configured hostname: `https://robotdashboard.yourdomain.com`

### Via Port Forward (Development)
```bash
kubectl port-forward service/robotframework-dashboard 8080:80
# Access: http://localhost:8080
```

## 🔒 Security & Production Setup

### TLS Configuration
```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    - secretName: robotdashboard-tls
      hosts:
        - robotdashboard.yourdomain.com
```

### Resource Limits
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi
```

## 📊 Monitoring & Health Checks

The application provides:
- **Health endpoint**: `GET /health`
- **Liveness probe**: Configured for automatic restart
- **Readiness probe**: Ensures traffic only goes to ready pods

## 🔧 Troubleshooting

### Common Issues

1. **Pod Pending**: Check storage class availability
   ```bash
   kubectl get storageclass
   kubectl describe pod -l app.kubernetes.io/name=robotframework-dashboard
   ```

2. **Image Pull Errors**: Verify image name and registry access
   ```bash
   kubectl logs -l app.kubernetes.io/name=robotframework-dashboard
   ```

3. **PVC Not Binding**: Check storage class and capacity
   ```bash
   kubectl get pvc
   kubectl describe pvc
   ```

### Debug Commands
```bash
# Check all resources
kubectl get all -l app.kubernetes.io/name=robotframework-dashboard

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# View logs
kubectl logs -f deployment/robotframework-dashboard

# Shell into pod
kubectl exec -it deployment/robotframework-dashboard -- /bin/bash
```

## 📈 Scaling

### Horizontal Scaling
```bash
kubectl scale deployment robotframework-dashboard --replicas=3
```

### Auto-scaling
```bash
kubectl autoscale deployment robotframework-dashboard \
  --cpu-percent=70 --min=2 --max=10
```

## 🔄 Updates & Maintenance

### Rolling Updates
```bash
# Update to new image version
helm upgrade robotframework-dashboard ./helm/robotframework-dashboard \
  --set image.tag=v1.1.0
```

### Rollback
```bash
helm rollback robotframework-dashboard 1
```

## 💾 Backup & Recovery

### Database Backup
```bash
kubectl exec deployment/robotframework-dashboard -- \
  sqlite3 /app/data/robot_results.db .dump > backup.sql
```

### Restore
```bash
kubectl cp backup.sql robotframework-dashboard-pod:/tmp/
kubectl exec deployment/robotframework-dashboard -- \
  sqlite3 /app/data/robot_results.db < /tmp/backup.sql
```

## 🏗️ Multi-Environment Setup

### Namespace Strategy
```bash
# Create environments
kubectl create namespace robotdashboard-dev
kubectl create namespace robotdashboard-prod

# Deploy to specific environment
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --namespace robotdashboard-prod \
  --values values-prod.yaml
```

## 📚 Additional Resources

- [Helm Chart Documentation](./helm/robotframework-dashboard/README.md)
- [Docker Image](https://hub.docker.com/r/sankaram04/robotframework-dashboard)
- [Original Project](https://github.com/timdegroot1996/robotframework-dashboard)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
