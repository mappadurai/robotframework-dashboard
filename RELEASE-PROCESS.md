# Release Process Documentation

This document outlines the release process for the Robot Framework Dashboard project.

## 🔄 Automated Release Process (Recommended)

### GitHub Actions Setup

1. **Add Docker Hub Secrets** to your GitHub repository:
   - Go to your repo → Settings → Secrets and variables → Actions
   - Add these secrets:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username (sankaram04)
     - `DOCKERHUB_TOKEN`: Your Docker Hub access token

2. **Automated Triggers**:
   - **Push to main**: Builds and pushes `latest` tag
   - **Git tags**: Creates full release with version tags
   - **Manual trigger**: Can specify custom version

### Creating a Release

#### Option 1: Git Tag Release
```bash
git tag -a v1.1.3 -m "Release version 1.1.3"
git push origin v1.1.3
```

#### Option 2: Manual GitHub Action
1. Go to your repository on GitHub
2. Navigate to Actions → "Build and Release"
3. Click "Run workflow"
4. Enter the version (e.g., 1.1.3)
5. Click "Run workflow"

## 🛠️ Manual Release Process

### Prerequisites
- Docker installed and logged into Docker Hub
- Git repository access
- Python 3.12+ installed

### Using the Release Script
```bash
# Release current version (1.1.3)
./release.sh

# Release specific version
./release.sh 1.2.0
```

### Manual Step-by-Step

1. **Ensure you're on main branch and clean working directory**:
   ```bash
   git checkout main
   git pull origin main
   git status  # Should show clean working directory
   ```

2. **Update version if needed** (optional):
   ```bash
   # Edit robotframework_dashboard/version.py
   # Update __version__ = "Robotdashboard 1.1.3"
   ```

3. **Build Docker image**:
   ```bash
   docker build -t sankaram04/robotframework-dashboard:1.1.3 .
   docker tag sankaram04/robotframework-dashboard:1.1.3 sankaram04/robotframework-dashboard:latest
   ```

4. **Test the image**:
   ```bash
   docker run -d -p 8000:8000 sankaram04/robotframework-dashboard:1.1.3
   # Test that it works at http://localhost:8000
   docker stop <container_id>
   ```

5. **Push to Docker Hub**:
   ```bash
   docker push sankaram04/robotframework-dashboard:1.1.3
   docker push sankaram04/robotframework-dashboard:latest
   ```

6. **Update Helm chart**:
   ```bash
   # Edit helm/robotframework-dashboard/Chart.yaml
   # Update appVersion: "1.1.3"
   ```

7. **Commit and tag**:
   ```bash
   git add helm/robotframework-dashboard/Chart.yaml
   git commit -m "Release v1.1.3 - Update Helm chart appVersion"
   git tag -a v1.1.3 -m "Release version 1.1.3"
   git push origin main
   git push origin v1.1.3
   ```

## 📦 Release Artifacts

Each release creates:

1. **Docker Images**:
   - `sankaram04/robotframework-dashboard:1.1.3` (version-specific)
   - `sankaram04/robotframework-dashboard:latest` (latest release)

2. **Git Tag**: `v1.1.3`

3. **GitHub Release**: Automatic release notes with installation instructions

4. **Updated Helm Chart**: AppVersion updated to match release

## 🔍 Quality Checks

### Automated Checks (GitHub Actions)
- ✅ Python tests (if available)
- ✅ Docker image builds for multiple architectures (amd64, arm64)
- ✅ Security vulnerability scanning with Trivy
- ✅ Multi-platform support

### Manual Testing Checklist
- [ ] Docker image runs successfully
- [ ] Web interface accessible on port 8000
- [ ] Database functionality works
- [ ] File upload/processing works
- [ ] Helm chart deploys successfully

## 🚀 Deployment

### Docker
```bash
# Latest version
docker run -p 8000:8000 sankaram04/robotframework-dashboard:latest

# Specific version
docker run -p 8000:8000 sankaram04/robotframework-dashboard:1.1.3
```

### Kubernetes (Helm)
```bash
# Install new release
helm install robotframework-dashboard ./helm/robotframework-dashboard \
  --set image.tag=1.1.3

# Upgrade existing deployment
helm upgrade robotframework-dashboard ./helm/robotframework-dashboard \
  --set image.tag=1.1.3
```

### Kubernetes (kubectl)
```bash
# Update deployment image
kubectl set image deployment/robotframework-dashboard \
  robotframework-dashboard=sankaram04/robotframework-dashboard:1.1.3 \
  -n robotframework-dashboard
```

## 🔄 Rollback Process

### Docker
```bash
# Roll back to previous version
docker run -p 8000:8000 sankaram04/robotframework-dashboard:1.1.2
```

### Helm
```bash
# Roll back to previous release
helm rollback robotframework-dashboard

# Roll back to specific revision
helm rollback robotframework-dashboard 2
```

## 🛡️ Security

- All images are scanned for vulnerabilities using Trivy
- Multi-architecture builds (amd64, arm64)
- Regular dependency updates through upstream sync
- No secrets in Docker images

## 📋 Versioning Strategy

- **Major.Minor.Patch** format (e.g., 1.1.3)
- Follows upstream version from original repository
- Docker tags include both version-specific and `latest`
- Git tags prefixed with `v` (e.g., v1.1.3)

## 🔗 Links

- **Docker Hub**: https://hub.docker.com/r/sankaram04/robotframework-dashboard
- **GitHub Repository**: https://github.com/mappadurai/robotframework-dashboard
- **GitHub Releases**: https://github.com/mappadurai/robotframework-dashboard/releases
- **Original Project**: https://github.com/timdegroot1996/robotframework-dashboard
