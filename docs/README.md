# Robot Framework Dashboard Helm Repository

This is the official Helm repository for Robot Framework Dashboard.

## Quick Start

```bash
# Add the Helm repository
helm repo add robotframework-dashboard https://mappadurai.github.io/robotframework-dashboard/
helm repo update

# Simple installation with ingress
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=your-domain.com
```

## Simple Deployment Examples

### Basic Installation (No Ingress)
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard
```

### With Ingress (Recommended)
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=dashboard.example.com
```

### With Custom Namespace
```bash
kubectl create namespace dashboard
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --namespace dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=dashboard.example.com
```

### With Custom Storage
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=dashboard.example.com \
  --set persistence.data.storageClass=fast-ssd \
  --set persistence.logs.storageClass=fast-ssd
```

## Available Charts

| Chart | Description | App Version | Chart Version |
|-------|-------------|-------------|---------------|
| [robotframework-dashboard](https://github.com/mappadurai/robotframework-dashboard) | A FastAPI web application for visualizing Robot Framework test results | 1.1.3 | 1.0.2 |

## Key Features

- **Simple Deployment**: One command with hostname sets up ingress and TLS automatically
- **Persistent Storage**: Data and logs are preserved across pod restarts
- **TLS Ready**: Automatic Let's Encrypt certificate management with cert-manager
- **Flexible Configuration**: Support for custom storage classes, resources, and namespaces

## Requirements

- Kubernetes 1.19+
- Helm 3.2.0+
- Ingress Controller (nginx recommended)
- cert-manager (for TLS certificates)

## Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.hostname` | Simple hostname setup (recommended) | `""` |
| `ingress.className` | Ingress class name | `nginx` |
| `persistence.data.storageClass` | Storage class for data | `standard` |
| `persistence.logs.storageClass` | Storage class for logs | `standard` |
| `image.tag` | Container image tag | `latest` |

For advanced configuration options, see the [full documentation](https://github.com/mappadurai/robotframework-dashboard/tree/main/helm/robotframework-dashboard).

## Docker Image

Uses the official Docker image: [`sankaram04/robotframework-dashboard`](https://hub.docker.com/r/sankaram04/robotframework-dashboard)

## Troubleshooting

### Common Issues

#### 1. Simple Hostname Not Working
**Solution**: Ensure you're using the latest chart version (1.0.2+):
```bash
helm repo update
helm upgrade robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=your-domain.com
```

#### 2. Storage Class Issues
Check available storage classes and specify the correct one:
```bash
kubectl get storageclass
# Then use: --set persistence.data.storageClass=your-storage-class
```

#### 3. Pod Issues
Check pod logs:
```bash
kubectl logs -l app.kubernetes.io/name=robotframework-dashboard
```

## Support

- **Issues**: [GitHub Issues](https://github.com/mappadurai/robotframework-dashboard/issues)
- **Chart Documentation**: [Helm Chart](https://github.com/mappadurai/robotframework-dashboard/tree/main/helm/robotframework-dashboard)
- **Upstream Project**: [timdegroot1996/robotframework-dashboard](https://github.com/timdegroot1996/robotframework-dashboard)

## License

MIT License - see [LICENSE](https://github.com/mappadurai/robotframework-dashboard/blob/main/LICENSE) for details.
