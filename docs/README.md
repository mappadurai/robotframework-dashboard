# Robot Framework Dashboard Helm Repository

This is the official Helm repository for Robot Framework Dashboard.

## Quick Start

```bash
# Add the Helm repository
helm repo add robotframework-dashboard https://mappadurai.github.io/robotframework-dashboard/
helm repo update

# Install the chart
helm install my-robotframework-dashboard robotframework-dashboard/robotframework-dashboard

# Install with custom values
helm install my-robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=dashboard.example.com
```

## Available Charts

| Chart | Description | App Version | Chart Version |
|-------|-------------|-------------|---------------|
| [robotframework-dashboard](https://github.com/mappadurai/robotframework-dashboard) | A FastAPI web application for visualizing Robot Framework test results | 1.1.3 | 1.0.1 |

## Installation Options

### Option 1: Default Installation
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard
```

### Option 2: With Ingress (Simple)
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=your-domain.com
```

### Option 3: With Ingress (Advanced)
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set "ingress.hosts[0].host=your-domain.com" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=Prefix"
```

### Option 4: With Custom Storage Class
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set persistence.data.storageClass=ceph-block \
  --set persistence.logs.storageClass=ceph-block
```

### Option 5: With Custom Namespace
```bash
kubectl create namespace robotframework-dashboard
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --namespace robotframework-dashboard
```

## Configuration

The chart supports extensive configuration options. See the [full documentation](https://github.com/mappadurai/robotframework-dashboard/tree/main/helm/robotframework-dashboard) for all available values.

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `sankaram04/robotframework-dashboard` |
| `image.tag` | Container image tag | `1.1.3` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.hostname` | Simple hostname setup | `""` |
| `ingress.className` | Ingress class name | `nginx` |
| `persistence.data.enabled` | Enable data persistence | `true` |
| `persistence.data.storageClass` | Storage class for data | `standard` |
| `persistence.data.size` | Data storage size | `5Gi` |
| `persistence.logs.enabled` | Enable logs persistence | `true` |
| `persistence.logs.storageClass` | Storage class for logs | `standard` |
| `persistence.logs.size` | Logs storage size | `2Gi` |

## Common Deployment Examples

### Production Deployment with Ingress
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --namespace qa-auto-test \
  --set image.tag=1.1.3 \
  --set ingress.enabled=true \
  --set ingress.hostname=robotframework-dashboard.test.eagleeyenetworks.com \
  --set ingress.className=nginx \
  --set persistence.data.storageClass=ceph-block \
  --set persistence.logs.storageClass=ceph-block
```

### Development Setup (No Persistence)
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set persistence.data.enabled=false \
  --set persistence.logs.enabled=false
```

### Custom Resource Limits
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=500m \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=1000m
```

## Docker Image

The chart uses the official Docker image: [`sankaram04/robotframework-dashboard`](https://hub.docker.com/r/sankaram04/robotframework-dashboard)

```bash
docker pull sankaram04/robotframework-dashboard:1.1.3
```

## Source Code

- **Chart Source**: [GitHub - mappadurai/robotframework-dashboard](https://github.com/mappadurai/robotframework-dashboard)
- **Upstream Source**: [GitHub - timdegroot1996/robotframework-dashboard](https://github.com/timdegroot1996/robotframework-dashboard)

## Troubleshooting

### Common Issues

#### 1. Ingress Configuration Error
```
Error: template: robotframework-dashboard/templates/ingress.yaml:18:21: executing "robotframework-dashboard/templates/ingress.yaml" at <.Values.ingress.tls>: range can't iterate over true
```

**Solution**: Use proper ingress configuration:
```bash
# Simple hostname approach (recommended)
--set ingress.hostname=your-domain.com

# OR advanced hosts configuration
--set "ingress.hosts[0].host=your-domain.com" \
--set "ingress.hosts[0].paths[0].path=/" \
--set "ingress.hosts[0].paths[0].pathType=Prefix"
```

#### 2. Storage Class Issues
If you get PVC pending issues, check available storage classes:
```bash
kubectl get storageclass
```

Then specify the correct storage class:
```bash
--set persistence.data.storageClass=your-storage-class
--set persistence.logs.storageClass=your-storage-class
```

#### 3. Pod CrashLoopBackOff
Check pod logs:
```bash
kubectl logs -n <namespace> deployment/robotframework-dashboard
```

Common fixes:
- Ensure proper resource limits
- Check persistent volume permissions
- Verify image tag exists

## Support

- **Issues**: [GitHub Issues](https://github.com/mappadurai/robotframework-dashboard/issues)
- **Documentation**: [README](https://github.com/mappadurai/robotframework-dashboard/blob/main/README.md)
- **Helm Chart**: [Chart Documentation](https://github.com/mappadurai/robotframework-dashboard/tree/main/helm/robotframework-dashboard)

## License

MIT License - see [LICENSE](https://github.com/mappadurai/robotframework-dashboard/blob/main/LICENSE) for details.
