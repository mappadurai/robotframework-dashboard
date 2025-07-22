# Robot Framework Dashboard - Kubernetes Deployment

This repository contains everything you need to deploy Robot Framework Dashboard to Kubernetes.

## 🚀 Quick Start

### Prerequisites

- Docker
- Kubernetes cluster
- kubectl configured
- (Optional) Helm 3.x for Helm deployment

### Option 1: Direct Kubernetes Deployment

1. **Build and Deploy using the script:**
   ```bash
   ./deploy.sh
   ```

2. **Manual deployment:**
   ```bash
   # Build Docker image
   docker build -t robotframework-dashboard:latest .
   
   # Apply Kubernetes manifests
   kubectl apply -f k8s/
   
   # Wait for deployment
   kubectl wait --for=condition=available --timeout=300s deployment/robotframework-dashboard -n robotframework-dashboard
   ```

### Option 2: Helm Deployment

```bash
# Install using Helm
helm install robotframework-dashboard ./helm/robotframework-dashboard
```

## 📁 Project Structure

```
├── Dockerfile                          # Container definition
├── .dockerignore                      # Docker ignore file
├── deploy.sh                          # Deployment script
├── k8s/                              # Kubernetes manifests
│   ├── namespace.yaml                # Namespace
│   ├── configmap.yaml               # Configuration
│   ├── pvc.yaml                     # Persistent volumes
│   ├── deployment.yaml              # Main deployment
│   ├── service.yaml                 # Service
│   └── ingress.yaml                 # Ingress (optional)
└── helm/                            # Helm chart
    └── robotframework-dashboard/    # Helm chart files
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ROBOTDASHBOARD_HOST` | `0.0.0.0` | Server host |
| `ROBOTDASHBOARD_PORT` | `8000` | Server port |
| `DATABASE_PATH` | `/app/data/robot_results.db` | Database path |
| `LOG_DIR` | `/app/robot_logs` | Log directory |

### Persistent Storage

The deployment creates two persistent volumes:
- **Data Volume (5Gi)**: Stores the SQLite database
- **Logs Volume (2Gi)**: Stores uploaded log files

### Resources

Default resource requests and limits:
- **Requests**: 200m CPU, 256Mi memory
- **Limits**: 500m CPU, 512Mi memory

## 🌐 Accessing the Application

### 1. Port Forwarding (Development)
```bash
kubectl port-forward service/robotframework-dashboard-service 8080:80 -n robotframework-dashboard
```
Then access: http://localhost:8080

### 2. Ingress (Production)
1. Update `k8s/ingress.yaml` with your domain
2. Configure your DNS to point to your ingress controller
3. Access via your configured domain

### 3. LoadBalancer Service
Change service type in `k8s/service.yaml`:
```yaml
spec:
  type: LoadBalancer
```

## 🐳 Docker Image

The Docker image is based on Python 3.12-slim and includes:
- All required dependencies
- Health checks
- Proper security practices
- Multi-stage build optimization

### Building Custom Image

```bash
# Build
docker build -t your-registry/robotframework-dashboard:latest .

# Push to registry
docker push your-registry/robotframework-dashboard:latest

# Update deployment to use your image
sed -i 's|robotframework-dashboard:latest|your-registry/robotframework-dashboard:latest|' k8s/deployment.yaml
```

## 📊 Monitoring and Health Checks

The deployment includes:
- **Liveness Probe**: Checks if the application is running
- **Readiness Probe**: Checks if the application is ready to serve traffic
- **Health Check**: Built into the Docker image

## 🔒 Security Considerations

1. **Network Policies**: Consider implementing network policies to restrict traffic
2. **RBAC**: The deployment doesn't require special permissions
3. **Security Context**: Run as non-root user (TODO: implement)
4. **Secrets**: Store sensitive data in Kubernetes secrets if needed

## 🔄 Scaling

Since the application uses SQLite, it's designed to run as a single replica. For high availability:

1. Consider using external database (MySQL/PostgreSQL)
2. Implement database connection pooling
3. Use ReadWriteMany volumes if needed

## 📝 Usage After Deployment

1. **Admin Interface**: Access the main interface for uploading files and configuration
2. **Dashboard**: View test results and analytics at `/dashboard`
3. **API**: Use the REST API for automation (see `/docs` for API documentation)

### Uploading Test Results

- Via Web UI: Use the admin interface
- Via API: POST to `/add-outputs` or `/upload-output`
- Via kubectl: Copy files to the pod and process locally

## 🧹 Cleanup

### Remove Kubernetes deployment:
```bash
kubectl delete namespace robotframework-dashboard
```

### Remove Helm deployment:
```bash
helm uninstall robotframework-dashboard
```

## 🔧 Troubleshooting

### Common Issues

1. **Pod not starting**:
   ```bash
   kubectl logs deployment/robotframework-dashboard -n robotframework-dashboard
   kubectl describe pod <pod-name> -n robotframework-dashboard
   ```

2. **Storage issues**:
   ```bash
   kubectl get pvc -n robotframework-dashboard
   kubectl describe pvc <pvc-name> -n robotframework-dashboard
   ```

3. **Network issues**:
   ```bash
   kubectl get svc -n robotframework-dashboard
   kubectl get ingress -n robotframework-dashboard
   ```

### Debug Mode

To debug the application:
```bash
kubectl exec -it deployment/robotframework-dashboard -n robotframework-dashboard -- /bin/bash
```

## 📈 Performance Tuning

For better performance:

1. **Increase resources** in `k8s/deployment.yaml`
2. **Use faster storage class** for PVCs
3. **Enable horizontal pod autoscaling** (after implementing external database)
4. **Configure ingress caching** for static assets

## 🔄 Updates and Maintenance

### Update the application:
```bash
# Build new image
docker build -t robotframework-dashboard:v2 .

# Update deployment
kubectl set image deployment/robotframework-dashboard robotframework-dashboard=robotframework-dashboard:v2 -n robotframework-dashboard
```

### Backup data:
```bash
kubectl exec deployment/robotframework-dashboard -n robotframework-dashboard -- tar czf - /app/data | tar xzf - -C ./backup/
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Update documentation
4. Test your changes
5. Submit a pull request

## 📄 License

This project is licensed under the same license as Robot Framework Dashboard.
