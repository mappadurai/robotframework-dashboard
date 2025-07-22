# Publishing Robot Framework Dashboard Helm Chart

This guide explains how to make your Helm chart publicly available for easy installation.

## 🌟 Options for Publishing Helm Charts

### 1. GitHub Pages (Free & Easy)

#### Step 1: Create GitHub Repository
```bash
# Create a new repository on GitHub: robotframework-dashboard-helm
git clone https://github.com/YOUR_USERNAME/robotframework-dashboard-helm.git
cd robotframework-dashboard-helm
```

#### Step 2: Setup Chart Repository Structure
```bash
# Copy your chart
cp -r /path/to/robotframework-dashboard/helm/robotframework-dashboard ./charts/

# Create index
mkdir -p docs
helm package charts/robotframework-dashboard -d docs/
helm repo index docs/ --url https://YOUR_USERNAME.github.io/robotframework-dashboard-helm/

# Commit and push
git add .
git commit -m "Add Robot Framework Dashboard Helm Chart"
git push origin main
```

#### Step 3: Enable GitHub Pages
1. Go to repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: main, folder: /docs
4. Save

#### Step 4: Users can now install via:
```bash
helm repo add robotframework-dashboard https://YOUR_USERNAME.github.io/robotframework-dashboard-helm/
helm repo update
helm install robotframework-dashboard robotframework-dashboard/robotframework-dashboard
```

### 2. Artifact Hub (Recommended for Discovery)

#### Step 1: Create metadata file
```yaml
# .artifacthub/config.yaml
repositoryID: <your-repo-id>
owners:
  - name: sankaram04
    email: your-email@example.com
```

#### Step 2: Add to Chart.yaml
```yaml
annotations:
  artifacthub.io/category: testing
  artifacthub.io/displayName: Robot Framework Dashboard
  artifacthub.io/keywords: |
    - robotframework
    - testing
    - dashboard
    - automation
  artifacthub.io/license: MIT
  artifacthub.io/links: |
    - name: Chart Source
      url: https://github.com/sankaram04/robotframework-dashboard-helm
    - name: Docker Image
      url: https://hub.docker.com/r/sankaram04/robotframework-dashboard
```

#### Step 3: Submit to Artifact Hub
- Visit https://artifacthub.io/
- Sign in with GitHub
- Add your repository

### 3. Helm Hub Registry (OCI)

#### Using GitHub Container Registry
```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | helm registry login ghcr.io -u YOUR_USERNAME --password-stdin

# Package and push
helm package charts/robotframework-dashboard
helm push robotframework-dashboard-1.0.0.tgz oci://ghcr.io/YOUR_USERNAME
```

#### Users install via:
```bash
helm install robotframework-dashboard oci://ghcr.io/YOUR_USERNAME/robotframework-dashboard --version 1.0.0
```

## 📋 Pre-Publishing Checklist

### 1. Chart Quality
```bash
# Lint the chart
helm lint helm/robotframework-dashboard/

# Test template rendering
helm template test helm/robotframework-dashboard/ --values helm/robotframework-dashboard/values.yaml

# Test installation
helm install test-release helm/robotframework-dashboard/ --dry-run --debug
```

### 2. Documentation
- [ ] Complete README.md with installation instructions
- [ ] Document all configuration parameters
- [ ] Include example values files
- [ ] Add troubleshooting section

### 3. Versioning
```bash
# Update Chart.yaml version before each release
version: 1.0.0  # Chart version
appVersion: "0.9.4"  # Application version
```

### 4. Security Review
- [ ] No hardcoded secrets
- [ ] Proper RBAC permissions
- [ ] Security context configured
- [ ] Resource limits set

## 🚀 Automated Publishing with GitHub Actions

Create `.github/workflows/helm-publish.yml`:

```yaml
name: Publish Helm Chart

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Helm
      uses: azure/setup-helm@v3
      with:
        version: v3.10.0
    
    - name: Package Chart
      run: |
        helm package helm/robotframework-dashboard -d docs/
        helm repo index docs/ --url https://${{ github.repository_owner }}.github.io/robotframework-dashboard-helm/
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: \${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./docs
```

## 📊 Making Your Chart Discoverable

### 1. SEO & Documentation
- Use clear, descriptive README
- Include screenshots/GIFs
- Add comprehensive examples
- Use proper keywords in Chart.yaml

### 2. Community Engagement
- Share on Robot Framework forums
- Create blog posts about deployment
- Submit to awesome lists
- Present at meetups/conferences

### 3. Maintenance
- Regular updates
- Respond to issues
- Update documentation
- Monitor for security vulnerabilities

## 🔗 Example Repository Structure

```
robotframework-dashboard-helm/
├── .github/
│   └── workflows/
│       └── helm-publish.yml
├── .artifacthub/
│   └── config.yaml
├── charts/
│   └── robotframework-dashboard/
│       ├── Chart.yaml
│       ├── README.md
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
├── docs/
│   ├── index.yaml
│   └── robotframework-dashboard-1.0.0.tgz
├── examples/
│   ├── basic-install.md
│   ├── production-setup.md
│   └── multi-environment.md
└── README.md
```

## 📝 Publishing Commands

### Initial Setup
```bash
# Clone your repo
git clone https://github.com/sankaram04/robotframework-dashboard.git
cd robotframework-dashboard

# Create separate Helm repo
git clone https://github.com/sankaram04/robotframework-dashboard-helm.git helm-repo
cd helm-repo

# Copy chart
cp -r ../helm/robotframework-dashboard ./charts/
```

### Publish New Version
```bash
# Update version in Chart.yaml
# Package chart
helm package charts/robotframework-dashboard -d docs/

# Update index
helm repo index docs/ --url https://sankaram04.github.io/robotframework-dashboard-helm/

# Commit and push
git add .
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main --tags
```

## 🎯 Benefits of Public Helm Chart

1. **Easy Installation**: One-command deployment
2. **Version Management**: Semantic versioning
3. **Configuration**: Flexible via values.yaml
4. **Community**: Others can contribute and report issues
5. **Professional**: Looks professional and trustworthy
6. **Discoverability**: Found via Artifact Hub and searches

## 📞 Support & Community

After publishing, consider:
- Creating GitHub Discussions for Q&A
- Setting up issue templates
- Writing contribution guidelines
- Creating a roadmap
- Monitoring usage metrics
