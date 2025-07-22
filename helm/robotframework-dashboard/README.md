# Robot Framework Dashboard Helm Chart

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-sankaram04%2Frobotframework--dashboard-blue)](https://hub.docker.com/r/sankaram04/robotframework-dashboard)
[![Helm](https://img.shields.io/badge/Helm-Chart-blue)](https://helm.sh/)

A Helm chart for deploying [Robot Framework Dashboard](https://github.com/timdegroot1996/robotframework-dashboard) - A FastAPI web application for visualizing Robot Framework test results.

## Features

- 🚀 **Easy Deployment**: One-command deployment to Kubernetes
- 🔒 **Security**: TLS/SSL support with cert-manager integration
- 💾 **Persistence**: Configurable persistent volumes for data and logs
- 🔧 **Configurable**: Highly customizable through values.yaml
- 📊 **Monitoring**: Built-in health checks and probes
- 🌐 **Ingress**: NGINX ingress controller support

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- NGINX Ingress Controller (if using ingress)
- cert-manager (if using TLS)

## Installation

### Add the Helm Repository (Future)
```bash
# This will be available once published to a Helm repository
helm repo add robotframework-dashboard https://your-charts-repo.com
helm repo update
```

### Install from Source
```bash
# Clone the repository
git clone https://github.com/sankaram04/robotframework-dashboard.git
cd robotframework-dashboard

# Install the chart
helm install robotframework-dashboard ./helm/robotframework-dashboard
```

### Install with Custom Values
```bash
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --set ingress.hosts[0].host=robotdashboard.yourdomain.com \
  --set persistence.data.storageClass=your-storage-class
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `sankaram04/robotframework-dashboard` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.hosts[0].host` | Hostname for the ingress | `robotframework-dashboard.example.com` |
| `ingress.tls` | TLS configuration | `[]` |
| `persistence.data.enabled` | Enable data persistence | `true` |
| `persistence.data.size` | Data volume size | `5Gi` |
| `persistence.data.storageClass` | Data storage class | `standard` |
| `persistence.logs.enabled` | Enable logs persistence | `true` |
| `persistence.logs.size` | Logs volume size | `2Gi` |
| `persistence.logs.storageClass` | Logs storage class | `standard` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `200m` |
| `resources.requests.memory` | Memory request | `256Mi` |

## Examples

### Basic Installation
```bash
helm install my-dashboard ./helm/robotframework-dashboard
```

### Production Installation with Custom Domain
```bash
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --set ingress.hosts[0].host=robotdashboard.company.com \
  --set ingress.tls[0].secretName=robotdashboard-tls \
  --set ingress.tls[0].hosts[0]=robotdashboard.company.com \
  --set persistence.data.storageClass=fast-ssd \
  --set persistence.logs.storageClass=fast-ssd
```

### Development Installation (No Persistence)
```bash
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --set persistence.data.enabled=false \
  --set persistence.logs.enabled=false \
  --set ingress.enabled=false
```

## Accessing the Dashboard

After installation, you can access the dashboard via:

1. **Ingress (if enabled)**: https://your-configured-hostname
2. **Port Forward**: 
   ```bash
   kubectl port-forward service/robotframework-dashboard 8080:80
   ```
   Then access http://localhost:8080

## Storage Classes

Make sure to set the correct storage class for your environment:

- **AWS EKS**: `gp2` or `gp3`
- **GKE**: `standard` or `premium-rwo`
- **AKS**: `default` or `managed-premium`
- **On-premise**: Check with your cluster administrator

## TLS/SSL Configuration

To enable TLS with cert-manager:

```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: robotdashboard.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: robotdashboard-tls
      hosts:
        - robotdashboard.yourdomain.com
```

## Monitoring and Health Checks

The chart includes:
- **Liveness Probe**: Checks if the application is running
- **Readiness Probe**: Checks if the application is ready to serve traffic
- **Health Endpoint**: Available at `/health`

## Troubleshooting

### Pod Not Starting
```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=robotframework-dashboard

# Check pod logs
kubectl logs -l app.kubernetes.io/name=robotframework-dashboard

# Describe pod for events
kubectl describe pod -l app.kubernetes.io/name=robotframework-dashboard
```

### PVC Issues
```bash
# Check PVC status
kubectl get pvc

# Check storage class
kubectl get storageclass
```

### Ingress Issues
```bash
# Check ingress status
kubectl get ingress

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## Upgrading

```bash
# Upgrade to latest version
helm upgrade robotframework-dashboard ./helm/robotframework-dashboard

# Upgrade with new values
helm upgrade robotframework-dashboard ./helm/robotframework-dashboard \
  --values my-values.yaml
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall robotframework-dashboard

# Optionally delete PVCs (data will be lost!)
kubectl delete pvc -l app.kubernetes.io/name=robotframework-dashboard
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License - see the original project for details.

## Links

- [Original Project](https://github.com/timdegroot1996/robotframework-dashboard)
- [Docker Image](https://hub.docker.com/r/sankaram04/robotframework-dashboard)
- [Robot Framework](https://robotframework.org/)
- [Helm](https://helm.sh/)
