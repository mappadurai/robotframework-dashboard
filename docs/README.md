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
| [robotframework-dashboard](https://github.com/mappadurai/robotframework-dashboard) | A FastAPI web application for visualizing Robot Framework test results | 1.1.3 | 1.0.0 |

## Installation Options

### Option 1: Default Installation
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard
```

### Option 2: With Ingress
```bash
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard \
  --set ingress.enabled=true \
  --set ingress.hostname=your-domain.com
```

### Option 3: With Custom Namespace
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
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Storage size | `5Gi` |

## Docker Image

The chart uses the official Docker image: [`sankaram04/robotframework-dashboard`](https://hub.docker.com/r/sankaram04/robotframework-dashboard)

```bash
docker pull sankaram04/robotframework-dashboard:1.1.3
```

## Source Code

- **Chart Source**: [GitHub - mappadurai/robotframework-dashboard](https://github.com/mappadurai/robotframework-dashboard)
- **Upstream Source**: [GitHub - timdegroot1996/robotframework-dashboard](https://github.com/timdegroot1996/robotframework-dashboard)

## Support

- **Issues**: [GitHub Issues](https://github.com/mappadurai/robotframework-dashboard/issues)
- **Documentation**: [README](https://github.com/mappadurai/robotframework-dashboard/blob/main/README.md)

## License

MIT License - see [LICENSE](https://github.com/mappadurai/robotframework-dashboard/blob/main/LICENSE) for details.
