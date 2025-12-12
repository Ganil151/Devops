# Container Security Scanning

Comprehensive container and Docker security scanning with Trivy.

## Contents

- **[container-security-guide.md](./container-security-guide.md)** - Complete container security guide covering:
  - Docker image vulnerability scanning
  - Registry integration (AWS ECR, GCR, ACR)
  - Dockerfile security analysis
  - Multi-stage build security
  - Container compliance and policies
  - Performance optimization strategies

## Key Features

- **Image Scanning**: Detect vulnerabilities in container images
- **Registry Integration**: Scan images from private/public registries
- **Dockerfile Analysis**: Security best practices validation
- **Runtime Security**: Scan running containers
- **Compliance**: CIS benchmarks and custom policies

## Quick Examples

```bash
# Basic image scan
trivy image nginx:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan private registry
trivy image --username user --password pass registry.example.com/app:v1.0

# Dockerfile security scan
trivy config --file-patterns dockerfile:Dockerfile .
```

## Use Cases

- Pre-deployment security validation
- Registry security monitoring
- Container compliance checking
- Supply chain security assessment
- Runtime security analysis